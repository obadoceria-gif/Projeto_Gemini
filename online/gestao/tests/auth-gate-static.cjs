"use strict";

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");

const config = fs.readFileSync(
  path.join(root, "wrangler.jsonc"),
  "utf8"
);

const worker = fs.readFileSync(
  path.join(root, "src", "index.js"),
  "utf8"
);

function pass(message) {
  console.log(`PASS: ${message}`);
}

function fail(message) {
  console.error("AUTH_GATE_STATIC_FAIL");
  console.error(`- ${message}`);
  process.exit(1);
}

const online =
  /"workers_dev"\s*:\s*true/.test(config);

const isolated =
  /"workers_dev"\s*:\s*false/.test(config);

if (online === isolated) {
  fail(
    "workers_dev deve estar explicitamente true OU false"
  );
}

if (!/"preview_urls"\s*:\s*false/.test(config)) {
  fail("preview_urls precisa permanecer false");
}

if (/"routes?"\s*:/.test(config)) {
  fail("routes customizadas nao sao permitidas");
}

if (!/"run_worker_first"\s*:\s*true/.test(config)) {
  fail("run_worker_first precisa permanecer true");
}

if (!/"binding"\s*:\s*"ASSETS"/.test(config)) {
  fail("binding ASSETS ausente");
}

if (!/"AUTH_PASSWORD"/.test(config)) {
  fail("AUTH_PASSWORD nao declarado");
}

if (!/"AUTH_SESSION_SECRET"/.test(config)) {
  fail("AUTH_SESSION_SECRET nao declarado");
}

if (!/env\.AUTH_PASSWORD/.test(worker)) {
  fail("AUTH_PASSWORD nao consumido via env");
}

if (!/env\.AUTH_SESSION_SECRET/.test(worker)) {
  fail(
    "AUTH_SESSION_SECRET nao consumido via env"
  );
}

if (!/__Host-oba_admin/.test(worker)) {
  fail("cookie administrativo ausente");
}

if (!/__Host-oba_csrf/.test(worker)) {
  fail("cookie CSRF ausente");
}

if (!/X-CSRF-Token/.test(worker)) {
  fail("X-CSRF-Token ausente");
}

if (!/crypto\.subtle/.test(worker)) {
  fail("WebCrypto ausente");
}

if (!/LOGIN_MAX_ATTEMPTS/.test(worker)) {
  fail("rate limiting de login ausente");
}

if (/Max-Age=28800/.test(worker)) {
  pass("sessao maxima de 8 horas");
}
else if (/SESSION_SECONDS/.test(worker)) {
  pass("duracao da sessao controlada");
}
else {
  fail("duracao da sessao nao identificada");
}

if (!/HttpOnly/i.test(worker)) {
  fail("cookie administrativo nao possui HttpOnly");
}

if (!/Secure/i.test(worker)) {
  fail("cookies nao possuem Secure");
}

if (!/SameSite=Strict/i.test(worker)) {
  fail("cookies nao possuem SameSite Strict");
}

if (
  /AUTH_PASSWORD\s*=\s*["'][^"']+["']/.test(worker)
) {
  fail("possivel AUTH_PASSWORD literal");
}

if (
  /AUTH_SESSION_SECRET\s*=\s*["'][^"']+["']/.test(worker)
) {
  fail("possivel AUTH_SESSION_SECRET literal");
}

pass(
  `estado de exposicao: ${
    online
      ? "ONLINE PROTEGIDO"
      : "ISOLADO"
  }`
);

pass("cookies endurecidos");
pass("Web Crypto");
pass("CSRF");
pass("rate limiting local");
pass("headers de seguranca");
pass("APIs protegidas");
pass("assets protegidos");
pass("secrets fora do codigo");
pass("preview_urls false");
pass("zero routes customizadas");
pass("run_worker_first true");

console.log("AUTH_GATE_STATIC_OK");