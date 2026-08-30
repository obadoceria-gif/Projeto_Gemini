const encoder = new TextEncoder();

const COOKIE_NAME = "__Host-oba_admin";

function response(body, status = 200, headers = {}) {
  return new Response(body, {
    status,
    headers: {
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
      "Referrer-Policy": "no-referrer",
      "X-Frame-Options": "DENY",
      ...headers,
    },
  });
}

function json(data, status = 200, headers = {}) {
  return response(JSON.stringify(data), status, {
    "Content-Type": "application/json; charset=utf-8",
    ...headers,
  });
}

function parseCookies(request) {
  const raw = request.headers.get("Cookie") || "";
  const out = {};

  for (const part of raw.split(";")) {
    const index = part.indexOf("=");

    if (index <= 0) continue;

    const key = part.slice(0, index).trim();
    const value = part.slice(index + 1).trim();

    out[key] = value;
  }

  return out;
}

function toBase64Url(bytes) {
  let binary = "";

  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary)
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");
}

function constantTimeEqual(a, b) {
  if (typeof a !== "string" || typeof b !== "string") return false;

  const aa = encoder.encode(a);
  const bb = encoder.encode(b);

  const max = Math.max(aa.length, bb.length);
  let diff = aa.length ^ bb.length;

  for (let i = 0; i < max; i++) {
    diff |= (aa[i] || 0) ^ (bb[i] || 0);
  }

  return diff === 0;
}

async function hmac(secret, value) {
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    {
      name: "HMAC",
      hash: "SHA-256",
    },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(value)
  );

  return toBase64Url(new Uint8Array(signature));
}

async function createSession(env) {
  const issuedAt = Math.floor(Date.now() / 1000);
  const expiresAt = issuedAt + 60 * 60 * 8;

  const nonce = crypto.randomUUID();

  const payload = `${issuedAt}.${expiresAt}.${nonce}`;
  const signature = await hmac(env.AUTH_SESSION_SECRET, payload);

  return `${payload}.${signature}`;
}

async function validateSession(request, env) {
  if (!env.AUTH_SESSION_SECRET) return false;

  const cookies = parseCookies(request);
  const token = cookies[COOKIE_NAME];

  if (!token) return false;

  const pieces = token.split(".");

  if (pieces.length !== 4) return false;

  const [issuedAtRaw, expiresAtRaw, nonce, signature] = pieces;

  const issuedAt = Number(issuedAtRaw);
  const expiresAt = Number(expiresAtRaw);

  if (
    !Number.isSafeInteger(issuedAt) ||
    !Number.isSafeInteger(expiresAt) ||
    !nonce ||
    !signature
  ) {
    return false;
  }

  const now = Math.floor(Date.now() / 1000);

  if (issuedAt > now + 60) return false;
  if (expiresAt <= now) return false;
  if (expiresAt - issuedAt > 60 * 60 * 8) return false;

  const payload = `${issuedAt}.${expiresAt}.${nonce}`;
  const expected = await hmac(env.AUTH_SESSION_SECRET, payload);

  return constantTimeEqual(expected, signature);
}

function loginPage(error = "") {
  const safeError = error
    ? '<p role="alert" class="error">Acesso nao autorizado.</p>'
    : "";

  return `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow,noarchive">
<title>Oba Doceria - Gestao</title>
<style>
*{box-sizing:border-box}
body{
  margin:0;
  min-height:100vh;
  display:grid;
  place-items:center;
  font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
  background:#f6f3ee;
  color:#28231f
}
main{
  width:min(92vw,420px);
  background:#fff;
  padding:32px;
  border-radius:18px;
  box-shadow:0 12px 40px rgba(0,0,0,.10)
}
h1{margin-top:0}
label{display:block;margin:18px 0 8px}
input{
  width:100%;
  padding:13px;
  font:inherit;
  border:1px solid #bbb;
  border-radius:9px
}
button{
  width:100%;
  margin-top:20px;
  padding:13px;
  border:0;
  border-radius:9px;
  font:inherit;
  font-weight:700;
  cursor:pointer
}
.error{color:#a00}
.small{font-size:.85rem;opacity:.7}
</style>
</head>
<body>
<main>
<h1>Gestao Oba Doceria</h1>
<p>Acesso administrativo.</p>
${safeError}
<form method="post" action="/__auth/login" autocomplete="off">
<label for="password">Senha</label>
<input
  id="password"
  name="password"
  type="password"
  required
  minlength="12"
  autocomplete="current-password">
<button type="submit">Entrar</button>
</form>
<p class="small">Area privada.</p>
</main>
</body>
</html>`;
}

async function handleLogin(request, env) {
  if (!env.AUTH_PASSWORD || !env.AUTH_SESSION_SECRET) {
    return response("Authentication not configured", 503);
  }

  const contentType = request.headers.get("Content-Type") || "";

  if (!contentType.includes("application/x-www-form-urlencoded")) {
    return response("Unsupported Media Type", 415);
  }

  const form = await request.formData();
  const password = String(form.get("password") || "");

  if (!constantTimeEqual(password, env.AUTH_PASSWORD)) {
    return response(loginPage("invalid"), 401, {
      "Content-Type": "text/html; charset=utf-8",
    });
  }

  const session = await createSession(env);

  return response("", 303, {
    "Location": "/",
    "Set-Cookie":
      `${COOKIE_NAME}=${session}; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=28800`,
  });
}

function handleLogout() {
  return response("", 303, {
    "Location": "/__auth/login",
    "Set-Cookie":
      `${COOKIE_NAME}=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0`,
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return json({
        ok: true,
        service: "oba-cardapio-gestao",
        auth: "worker-gate",
      });
    }

    if (url.pathname === "/__auth/login") {
      if (request.method === "GET") {
        return response(loginPage(), 200, {
          "Content-Type": "text/html; charset=utf-8",
        });
      }

      if (request.method === "POST") {
        return handleLogin(request, env);
      }

      return response("Method Not Allowed", 405, {
        "Allow": "GET, POST",
      });
    }

    if (url.pathname === "/__auth/logout") {
      if (request.method !== "POST") {
        return response("Method Not Allowed", 405, {
          "Allow": "POST",
        });
      }

      return handleLogout();
    }

    const authenticated = await validateSession(request, env);

    if (!authenticated) {
      if (url.pathname.startsWith("/api/")) {
        return json(
          {
            ok: false,
            error: "unauthorized",
          },
          401
        );
      }

      return response("", 303, {
        "Location": "/__auth/login",
      });
    }

    if (url.pathname.startsWith("/api/")) {
      return json({
        ok: false,
        error: "not_implemented",
      }, 501);
    }

    return env.ASSETS.fetch(request);
  },
};
