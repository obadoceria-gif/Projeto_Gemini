const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");

const worker = fs.readFileSync(
  path.join(root, "src", "index.js"),
  "utf8"
);

const wrangler = fs.readFileSync(
  path.join(root, "wrangler.jsonc"),
  "utf8"
);

const gitignore = fs.readFileSync(
  path.join(root, ".gitignore"),
  "utf8"
);

const failures = [];

function check(condition, message) {
  if (!condition) {
    failures.push(message);
  }
}

check(
  /AUTH_PASSWORD/.test(worker),
  "AUTH_PASSWORD ausente"
);

check(
  /AUTH_SESSION_SECRET/.test(worker),
  "AUTH_SESSION_SECRET ausente"
);

check(
  /__Host-oba_admin/.test(worker),
  "cookie administrativo ausente"
);

check(
  /__Host-oba_csrf/.test(worker),
  "cookie CSRF ausente"
);

check(
  /HttpOnly/.test(worker),
  "HttpOnly ausente"
);

check(
  /Secure/.test(worker),
  "Secure ausente"
);

check(
  /SameSite=Strict/.test(worker),
  "SameSite Strict ausente"
);

/*
 * A duracao agora e definida pela constante SESSION_SECONDS.
 * Nao procurar mais Max-Age=28800 literalmente.
 */
check(
  /const\s+SESSION_SECONDS\s*=\s*60\s*\*\s*60\s*\*\s*8\s*;/.test(worker),
  "SESSION_SECONDS nao corresponde a 8 horas"
);

check(
  /Max-Age=\$\{SESSION_SECONDS\}/.test(worker),
  "cookies nao usam SESSION_SECONDS"
);

check(
  /crypto\.subtle/.test(worker),
  "Web Crypto ausente"
);

check(
  /crypto\.randomUUID/.test(worker),
  "randomUUID ausente"
);

check(
  /crypto\.getRandomValues/.test(worker),
  "getRandomValues ausente"
);

check(
  /constantTimeEqual/.test(worker),
  "comparacao controlada ausente"
);

check(
  /csrfValid/.test(worker),
  "CSRF ausente"
);

check(
  /LOGIN_MAX_ATTEMPTS\s*=\s*5/.test(worker),
  "limite de tentativas inesperado"
);

check(
  /isRateLimited/.test(worker),
  "rate limiting ausente"
);

check(
  /429/.test(worker),
  "HTTP 429 ausente"
);

check(
  /Content-Security-Policy/.test(worker),
  "Content-Security-Policy ausente"
);

check(
  /X-Frame-Options/.test(worker),
  "X-Frame-Options ausente"
);

check(
  /env\.ASSETS\.fetch/.test(worker),
  "ASSETS binding ausente"
);

check(
  /url\.pathname\.startsWith\("\/api\/"\)/.test(worker),
  "gate de API ausente"
);

check(
  /"run_worker_first"\s*:\s*true/.test(wrangler),
  "run_worker_first nao esta true"
);

check(
  /"workers_dev"\s*:\s*false/.test(wrangler),
  "workers_dev nao esta false"
);

check(
  /"preview_urls"\s*:\s*false/.test(wrangler),
  "preview_urls nao esta false"
);

check(
  !/"routes"\s*:/.test(wrangler),
  "rota publica configurada"
);

check(
  /^\.dev\.vars$/m.test(gitignore),
  ".dev.vars nao esta ignorado"
);

check(
  /^\.env$/m.test(gitignore),
  ".env nao esta ignorado"
);

const forbidden = [
  /AUTH_PASSWORD\s*[:=]\s*["'][^"']+["']/,
  /AUTH_SESSION_SECRET\s*[:=]\s*["'][^"']+["']/,
  /CLOUDFLARE_API_TOKEN\s*[:=]\s*["'][^"']+["']/,
];

for (const pattern of forbidden) {
  check(
    !pattern.test(worker),
    `segredo literal detectado: ${pattern}`
  );
}

if (failures.length > 0) {

  console.error("");
  console.error("AUTH_GATE_STATIC_FAIL");

  for (const failure of failures) {
    console.error(`- ${failure}`);
  }

  process.exit(1);
}

console.log("");
console.log("AUTH_GATE_STATIC_OK");
console.log("PASS: sessao maxima de 8 horas");
console.log("PASS: cookies endurecidos");
console.log("PASS: Web Crypto");
console.log("PASS: CSRF");
console.log("PASS: rate limiting local");
console.log("PASS: headers de seguranca");
console.log("PASS: APIs protegidas");
console.log("PASS: assets protegidos");
console.log("PASS: secrets fora do codigo");
console.log("PASS: zero rota publica");
