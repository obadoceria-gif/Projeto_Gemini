"use strict";

const BASE = process.env.TEST_BASE_URL;
const PASSWORD = process.env.TEST_AUTH_PASSWORD;

if (!BASE || !PASSWORD) {
  console.error("AUTH_E2E_REMOTE_FAIL: ambiente incompleto");
  process.exit(1);
}

let fails = 0;

function pass(msg) {
  console.log(`PASS: ${msg}`);
}

function fail(msg) {
  console.error(`FAIL: ${msg}`);
  fails++;
}

function getSetCookies(headers) {
  if (typeof headers.getSetCookie === "function") {
    const values = headers.getSetCookie();

    if (Array.isArray(values) && values.length > 0) {
      return values;
    }
  }

  const raw = headers.get("set-cookie");

  if (!raw) return [];

  return raw.split(
    /,(?=\s*[!#$%&'*+\-.^_`|~0-9A-Za-z]+=)/
  );
}

function cookieValue(cookies, name) {
  for (const cookie of cookies) {
    const m = cookie.match(
      new RegExp(`(?:^|\\s|;)${name}=([^;]+)`)
    );

    if (m) return m[1];
  }

  return null;
}

async function request(path, options = {}) {
  const response = await fetch(
    `${BASE}${path}`,
    {
      redirect: "manual",
      ...options
    }
  );

  const body = await response.text();

  return {
    status: response.status,
    location: response.headers.get("location") || "",
    body,
    headers: response.headers,
    setCookies: getSetCookies(response.headers)
  };
}

async function login(password) {
  const body = new URLSearchParams({
    password
  }).toString();

  return request(
    "/__auth/login",
    {
      method: "POST",
      headers: {
        "Content-Type":
          "application/x-www-form-urlencoded;charset=UTF-8"
      },
      body
    }
  );
}

(async () => {

  const health = await request("/health");

  health.status === 200
    ? pass("health HTTP 200")
    : fail(`health HTTP ${health.status}`);

  const root = await request("/");

  if (
    [301,302,303,307,308].includes(root.status) &&
    root.location.includes("/__auth/login")
  ) {
    pass("root anonimo bloqueado");
  }
  else {
    fail(`root anonimo HTTP ${root.status}`);
  }

  const anonApi = await request("/api/security-gate");

  anonApi.status === 401
    ? pass("API anonima HTTP 401")
    : fail(`API anonima HTTP ${anonApi.status}`);

  const loginPage = await request("/__auth/login");

  loginPage.status === 200
    ? pass("login page HTTP 200")
    : fail(`login page HTTP ${loginPage.status}`);

  /*
   * LOGIN CORRETO SEMPRE PRIMEIRO.
   */
  const good = await login(PASSWORD);

  [302,303].includes(good.status)
    ? pass("login correto aceito")
    : fail(`login correto HTTP ${good.status}`);

  const admin = cookieValue(
    good.setCookies,
    "__Host-oba_admin"
  );

  const csrf = cookieValue(
    good.setCookies,
    "__Host-oba_csrf"
  );

  admin
    ? pass("cookie de sessao criado")
    : fail("cookie de sessao criado");

  csrf
    ? pass("cookie CSRF criado")
    : fail("cookie CSRF criado");

  if (!admin || !csrf) {
    console.error(
      `DIAG: Set-Cookie detectados=${good.setCookies.length}`
    );

    throw new Error(
      "Cookies obrigatorios ausentes."
    );
  }

  const cookieHeader =
    `__Host-oba_admin=${admin}; ` +
    `__Host-oba_csrf=${csrf}`;

  const asset = await request(
    "/",
    {
      headers: {
        Cookie: cookieHeader
      }
    }
  );

  asset.status === 200
    ? pass("asset autenticado liberado")
    : fail(`asset autenticado HTTP ${asset.status}`);

  if (
    asset.status === 200 &&
    /<!doctype html|<html/i.test(asset.body)
  ) {
    pass("Central privada entregue");
  }
  else {
    fail("Central privada entregue");
  }

  const api = await request(
    "/api/security-gate",
    {
      headers: {
        Cookie: cookieHeader
      }
    }
  );

  api.status === 501
    ? pass("API autenticada alcanca camada interna")
    : fail(`API autenticada HTTP ${api.status}`);

  const noCsrf = await request(
    "/api/security-gate",
    {
      method: "POST",
      headers: {
        Cookie: cookieHeader,
        "Content-Type": "application/json"
      },
      body: "{}"
    }
  );

  noCsrf.status === 403
    ? pass("POST autenticado sem CSRF bloqueado")
    : fail(`POST sem CSRF HTTP ${noCsrf.status}`);

  const withCsrf = await request(
    "/api/security-gate",
    {
      method: "POST",
      headers: {
        Cookie: cookieHeader,
        "X-CSRF-Token": csrf,
        "Content-Type": "application/json"
      },
      body: "{}"
    }
  );

  withCsrf.status === 501
    ? pass("POST com CSRF alcanca camada interna")
    : fail(`POST com CSRF HTTP ${withCsrf.status}`);

  const tampered =
    `${admin.slice(0, -1)}${
      admin.endsWith("a") ? "b" : "a"
    }`;

  const tamperedResponse = await request(
    "/",
    {
      headers: {
        Cookie:
          `__Host-oba_admin=${tampered}; ` +
          `__Host-oba_csrf=${csrf}`
      }
    }
  );

  [301,302,303,307,308,401].includes(
    tamperedResponse.status
  )
    ? pass("sessao adulterada rejeitada")
    : fail(
        `sessao adulterada HTTP ${tamperedResponse.status}`
      );

  loginPage.headers.get("x-frame-options") === "DENY"
    ? pass("X-Frame-Options DENY")
    : fail("X-Frame-Options DENY");

  (
    loginPage.headers.get("content-security-policy") || ""
  ).includes("frame-ancestors")
    ? pass("CSP frame-ancestors")
    : fail("CSP frame-ancestors");

  (
    loginPage.headers.get("cache-control") || ""
  ).includes("no-store")
    ? pass("Cache-Control no-store")
    : fail("Cache-Control no-store");

  const logoutNoCsrf = await request(
    "/__auth/logout",
    {
      method: "POST",
      headers: {
        Cookie: cookieHeader
      }
    }
  );

  logoutNoCsrf.status === 403
    ? pass("logout sem CSRF bloqueado")
    : fail(
        `logout sem CSRF HTTP ${logoutNoCsrf.status}`
      );

  const logout = await request(
    "/__auth/logout",
    {
      method: "POST",
      headers: {
        Cookie: cookieHeader,
        "X-CSRF-Token": csrf
      }
    }
  );

  [302,303].includes(logout.status)
    ? pass("logout autorizado")
    : fail(`logout HTTP ${logout.status}`);

  const logoutRaw =
    logout.setCookies.join("\n");

  /__Host-oba_admin=.*Max-Age=0/i.test(logoutRaw)
    ? pass("sessao removida no logout")
    : fail("sessao removida no logout");

  /*
   * SENHA ERRADA SOMENTE DEPOIS DO FLUXO VALIDO.
   */
  const wrong = await login(
    `WRONG-${Date.now()}-${Math.random()}`
  );

  if (wrong.status === 401) {
    pass("senha errada rejeitada");
  }
  else if (wrong.status === 429) {
    pass("senha errada rejeitada por rate limit");
  }
  else {
    fail(`senha errada HTTP ${wrong.status}`);
  }

  /*
   * RATE LIMIT REMOTO E INFORMATIVO.
   */
  let saw429 = wrong.status === 429;

  if (!saw429) {
    for (let i = 0; i < 6; i++) {

      const r = await login(
        `RATE-${Date.now()}-${i}-${Math.random()}`
      );

      if (r.status === 429) {
        saw429 = true;
        break;
      }
    }
  }

  if (saw429) {
    pass("rate limit remoto observado");
  }
  else {
    console.log(
      "INFO: rate limit remoto nao deterministico"
    );
  }

  if (fails > 0) {
    console.error(
      `AUTH_E2E_REMOTE_FAIL: ${fails} falha(s)`
    );

    process.exit(1);
  }

  console.log("AUTH_E2E_REMOTE_OK");
  process.exit(0);

})().catch((error) => {
  console.error(
    "AUTH_E2E_REMOTE_EXCEPTION:",
    error && error.message
      ? error.message
      : String(error)
  );

  process.exit(1);
});