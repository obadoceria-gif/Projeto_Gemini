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
  if (!condition) failures.push(message);
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
  /HttpOnly/.test(worker),
  "cookie sem HttpOnly"
);

check(
  /Secure/.test(worker),
  "cookie sem Secure"
);

check(
  /SameSite=Strict/.test(worker),
  "cookie sem SameSite=Strict"
);

check(
  /__Host-oba_admin/.test(worker),
  "cookie __Host ausente"
);

check(
  /Max-Age=28800/.test(worker),
  "expiracao de sessao inesperada"
);

check(
  /constantTimeEqual/.test(worker),
  "comparacao controlada ausente"
);

check(
  /crypto\.subtle/.test(worker),
  "Web Crypto ausente"
);

check(
  /crypto\.randomUUID/.test(worker),
  "nonce criptografico ausente"
);

check(
  /env\.ASSETS\.fetch/.test(worker),
  "ASSETS binding ausente"
);

check(
  /url\.pathname\.startsWith\("\/api\/"\)/.test(worker),
  "gate API ausente"
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
  ".dev.vars nao ignorado"
);

check(
  /^\.env$/m.test(gitignore),
  ".env nao ignorado"
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

if (failures.length) {
  console.error("");
  console.error("AUTH_GATE_STATIC_FAIL");

  for (const failure of failures) {
    console.error(`- ${failure}`);
  }

  process.exit(1);
}

console.log("AUTH_GATE_STATIC_OK");
console.log("PASS: gate de autenticacao");
console.log("PASS: cookies endurecidos");
console.log("PASS: Web Crypto");
console.log("PASS: APIs protegidas");
console.log("PASS: assets protegidos");
console.log("PASS: secrets fora do codigo");
console.log("PASS: zero rota publica");
