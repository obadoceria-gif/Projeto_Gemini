"use strict";

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");

const configPath = path.join(
  root,
  "wrangler.jsonc"
);

const workerPath = path.join(
  root,
  "src",
  "index.js"
);

function pass(message) {
  console.log(`[PASS] ${message}`);
}

function fail(message) {
  console.error(`[FAIL] ${message}`);
  process.exit(1);
}

const config = fs.readFileSync(
  configPath,
  "utf8"
);

const worker = fs.readFileSync(
  workerPath,
  "utf8"
);

const workersDevTrue =
  /"workers_dev"\s*:\s*true/.test(config);

const workersDevFalse =
  /"workers_dev"\s*:\s*false/.test(config);

if (workersDevTrue === workersDevFalse) {
  fail(
    "workers_dev deve estar explicitamente true OU false"
  );
}

const state =
  workersDevTrue
    ? "ONLINE PROTEGIDO"
    : "ISOLADO";

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
  fail("AUTH_PASSWORD nao declarado no contrato");
}

if (!/"AUTH_SESSION_SECRET"/.test(config)) {
  fail("AUTH_SESSION_SECRET nao declarado no contrato");
}

if (!/env\.AUTH_PASSWORD/.test(worker)) {
  fail("Worker nao consome AUTH_PASSWORD via env");
}

if (!/env\.AUTH_SESSION_SECRET/.test(worker)) {
  fail("Worker nao consome AUTH_SESSION_SECRET via env");
}

if (!/__Host-oba_admin/.test(worker)) {
  fail("cookie administrativo ausente");
}

if (!/__Host-oba_csrf/.test(worker)) {
  fail("cookie CSRF ausente");
}

if (!/X-CSRF-Token/.test(worker)) {
  fail("protecao CSRF ausente");
}

if (!/crypto\.subtle/.test(worker)) {
  fail("WebCrypto/HMAC ausente");
}

if (!/LOGIN_MAX_ATTEMPTS/.test(worker)) {
  fail("limitador de login ausente");
}

if (
  /AUTH_PASSWORD\s*=\s*["'][^"']+["']/.test(worker)
) {
  fail("possivel AUTH_PASSWORD literal no codigo");
}

if (
  /AUTH_SESSION_SECRET\s*=\s*["'][^"']+["']/.test(worker)
) {
  fail(
    "possivel AUTH_SESSION_SECRET literal no codigo"
  );
}

pass(`workers.dev: ${state}`);
pass("preview_urls false");
pass("zero routes customizadas");
pass("run_worker_first true");
pass("ASSETS passa pelo Worker");
pass("AUTH_PASSWORD via env");
pass("AUTH_SESSION_SECRET via env");
pass("cookie administrativo presente");
pass("cookie CSRF presente");
pass("CSRF presente");
pass("WebCrypto/HMAC presente");
pass("limitador de login presente");
pass("zero secret literal");

console.log("SECURITY_GATE_OK");