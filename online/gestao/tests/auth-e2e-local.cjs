const fs = require("fs");

const base = process.env.TEST_BASE_URL;
const password = process.env.TEST_AUTH_PASSWORD;

if (!base || !password) {
  console.error("TEST_CONFIG_MISSING");
  process.exit(1);
}

let failures = 0;

function pass(message) {
  console.log(`PASS: ${message}`);
}

function fail(message) {
  failures += 1;
  console.error(`FAIL: ${message}`);
}

function expect(condition, message) {
  condition ? pass(message) : fail(message);
}

function getSetCookies(response) {
  if (typeof response.headers.getSetCookie === "function") {
    return response.headers.getSetCookie();
  }

  const combined = response.headers.get("set-cookie");

  if (!combined) return [];

  return combined.split(/,(?=\s*__Host-)/);
}

function cookieValue(setCookies, name) {
  for (const line of setCookies) {
    const match = line.match(
      new RegExp(`(?:^|\\s)${name}=([^;]*)`)
    );

    if (match) return match[1];
  }

  return "";
}

(async () => {
  // ----------------------------------------------------------
  // HEALTH
  // ----------------------------------------------------------

  let r = await fetch(`${base}/health`, {
    redirect: "manual",
  });

  expect(r.status === 200, "health HTTP 200");

  // ----------------------------------------------------------
  // ANONIMO
  // ----------------------------------------------------------

  r = await fetch(`${base}/`, {
    redirect: "manual",
  });

  expect(r.status === 303, "asset anonimo bloqueado");
  expect(
    r.headers.get("location") === "/__auth/login",
    "anonimo redirecionado ao login"
  );

  r = await fetch(`${base}/api/test`, {
    redirect: "manual",
  });

  expect(r.status === 401, "API anonima HTTP 401");

  // ----------------------------------------------------------
  // LOGIN PAGE
  // ----------------------------------------------------------

  r = await fetch(`${base}/__auth/login`, {
    redirect: "manual",
  });

  const loginHtml = await r.text();

  expect(r.status === 200, "login page HTTP 200");
  expect(
    loginHtml.includes("Gestao Oba Doceria"),
    "login page correta"
  );

  // ----------------------------------------------------------
  // SENHA ERRADA
  // ----------------------------------------------------------

  r = await fetch(`${base}/__auth/login`, {
    method: "POST",
    headers: {
      "Content-Type":
        "application/x-www-form-urlencoded",
      "CF-Connecting-IP": "198.51.100.10",
    },
    body: new URLSearchParams({
      password: "senha-errada-e2e",
    }),
    redirect: "manual",
  });

  expect(r.status === 401, "senha errada rejeitada");

  // ----------------------------------------------------------
  // LOGIN CORRETO
  // ----------------------------------------------------------

  r = await fetch(`${base}/__auth/login`, {
    method: "POST",
    headers: {
      "Content-Type":
        "application/x-www-form-urlencoded",
      "CF-Connecting-IP": "198.51.100.20",
    },
    body: new URLSearchParams({
      password,
    }),
    redirect: "manual",
  });

  expect(r.status === 303, "login correto aceito");

  const setCookies = getSetCookies(r);

  const session = cookieValue(
    setCookies,
    "__Host-oba_admin"
  );

  const csrf = cookieValue(
    setCookies,
    "__Host-oba_csrf"
  );

  expect(Boolean(session), "cookie de sessao criado");
  expect(Boolean(csrf), "cookie CSRF criado");

  const cookieHeader =
    `__Host-oba_admin=${session}; ` +
    `__Host-oba_csrf=${csrf}`;

  // ----------------------------------------------------------
  // ASSET AUTENTICADO
  // ----------------------------------------------------------

  r = await fetch(`${base}/`, {
    headers: {
      Cookie: cookieHeader,
    },
    redirect: "manual",
  });

  expect(r.status === 200, "asset autenticado liberado");

  const centralHtml = await r.text();

  expect(
    centralHtml.length > 100,
    "Central privada entregue"
  );

  // ----------------------------------------------------------
  // API AUTENTICADA
  // ----------------------------------------------------------

  r = await fetch(`${base}/api/test`, {
    headers: {
      Cookie: cookieHeader,
    },
    redirect: "manual",
  });

  expect(
    r.status === 501,
    "API autenticada alcança camada interna"
  );

  // ----------------------------------------------------------
  // CSRF
  // ----------------------------------------------------------

  r = await fetch(`${base}/api/test`, {
    method: "POST",
    headers: {
      Cookie: cookieHeader,
      "Content-Type": "application/json",
    },
    body: "{}",
    redirect: "manual",
  });

  expect(
    r.status === 403,
    "POST autenticado sem CSRF bloqueado"
  );

  r = await fetch(`${base}/api/test`, {
    method: "POST",
    headers: {
      Cookie: cookieHeader,
      "X-CSRF-Token": csrf,
      "Content-Type": "application/json",
    },
    body: "{}",
    redirect: "manual",
  });

  expect(
    r.status === 501,
    "POST com CSRF alcança camada interna"
  );

  // ----------------------------------------------------------
  // LOGOUT SEM CSRF
  // ----------------------------------------------------------

  r = await fetch(`${base}/__auth/logout`, {
    method: "POST",
    headers: {
      Cookie: cookieHeader,
    },
    redirect: "manual",
  });

  expect(
    r.status === 403,
    "logout sem CSRF bloqueado"
  );

  // ----------------------------------------------------------
  // LOGOUT COM CSRF
  // ----------------------------------------------------------

  r = await fetch(`${base}/__auth/logout`, {
    method: "POST",
    headers: {
      Cookie: cookieHeader,
      "X-CSRF-Token": csrf,
    },
    redirect: "manual",
  });

  expect(r.status === 303, "logout autorizado");

  const logoutCookies = getSetCookies(r);

  expect(
    logoutCookies.some(
      x =>
        x.includes("__Host-oba_admin=") &&
        x.includes("Max-Age=0")
    ),
    "sessao removida no logout"
  );

  // ----------------------------------------------------------
  // COOKIE ADULTERADO
  // ----------------------------------------------------------

  r = await fetch(`${base}/`, {
    headers: {
      Cookie:
        `__Host-oba_admin=${session}X; ` +
        `__Host-oba_csrf=${csrf}`,
    },
    redirect: "manual",
  });

  expect(
    r.status === 303,
    "sessao adulterada rejeitada"
  );

  // ----------------------------------------------------------
  // RATE LIMIT
  // ----------------------------------------------------------

  let statuses = [];

  for (let i = 0; i < 6; i++) {
    const rr = await fetch(
      `${base}/__auth/login`,
      {
        method: "POST",
        headers: {
          "Content-Type":
            "application/x-www-form-urlencoded",
          "CF-Connecting-IP": "198.51.100.99",
        },
        body: new URLSearchParams({
          password: `errada-${i}`,
        }),
        redirect: "manual",
      }
    );

    statuses.push(rr.status);
  }

  expect(
    statuses.slice(0, 5).every(x => x === 401),
    "cinco tentativas invalidas registradas"
  );

  expect(
    statuses[5] === 429,
    "sexta tentativa bloqueada por rate limit"
  );

  // ----------------------------------------------------------
  // HEADERS
  // ----------------------------------------------------------

  r = await fetch(`${base}/__auth/login`, {
    redirect: "manual",
  });

  expect(
    r.headers.get("x-frame-options") === "DENY",
    "X-Frame-Options DENY"
  );

  expect(
    r.headers
      .get("content-security-policy")
      ?.includes("frame-ancestors 'none'"),
    "CSP frame-ancestors"
  );

  expect(
    r.headers.get("cache-control") === "no-store",
    "Cache-Control no-store"
  );

  // ----------------------------------------------------------
  // RESULTADO
  // ----------------------------------------------------------

  if (failures > 0) {
    console.error("");
    console.error(
      `AUTH_E2E_LOCAL_FAIL: ${failures} falha(s)`
    );

    process.exit(1);
  }

  console.log("");
  console.log("AUTH_E2E_LOCAL_OK");
  console.log("PASS: login");
  console.log("PASS: logout");
  console.log("PASS: sessao");
  console.log("PASS: assets");
  console.log("PASS: API");
  console.log("PASS: CSRF");
  console.log("PASS: rate limiting local");
  console.log("PASS: headers de seguranca");
})();
