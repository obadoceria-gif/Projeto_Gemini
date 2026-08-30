const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const wranglerPath = path.join(root, "wrangler.jsonc");

function fail(message) {
  console.error("[FAIL]", message);
  process.exit(1);
}

function pass(message) {
  console.log("[PASS]", message);
}

if (!fs.existsSync(wranglerPath)) {
  fail("wrangler.jsonc ausente");
}

const text = fs.readFileSync(wranglerPath, "utf8");

if (!/"workers_dev"\s*:\s*false/.test(text)) {
  fail("workers_dev deve permanecer false");
}

pass("workers_dev bloqueado");

if (!/"preview_urls"\s*:\s*false/.test(text)) {
  fail("preview_urls deve permanecer false");
}

pass("preview_urls bloqueadas");

if (/"routes?"\s*:/.test(text)) {
  fail("rota publica nao permitida antes do Access");
}

pass("nenhuma rota publica configurada");

const dangerous = [
  /CLOUDFLARE_API_TOKEN\s*[:=]\s*["'][^"']+/i,
  /CLOUDFLARE_API_KEY\s*[:=]\s*["'][^"']+/i,
  /Authorization\s*:\s*["']Bearer\s+[A-Za-z0-9._-]+/i
];

const scanExtensions = new Set([
  ".js", ".json", ".jsonc", ".html",
  ".css", ".md", ".txt", ".ps1"
]);

const ignoredDirs = new Set([
  "node_modules",
  ".wrangler",
  ".git"
]);

function scan(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (ignoredDirs.has(entry.name)) continue;

    const full = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      scan(full);
      continue;
    }

    if (!scanExtensions.has(path.extname(entry.name).toLowerCase())) {
      continue;
    }

    const content = fs.readFileSync(full, "utf8");

    for (const rule of dangerous) {
      if (rule.test(content)) {
        fail(`possivel segredo encontrado em ${path.relative(root, full)}`);
      }
    }
  }
}

scan(root);

pass("nenhum segredo literal detectado");
console.log("");
console.log("SECURITY_GATE_OK");
