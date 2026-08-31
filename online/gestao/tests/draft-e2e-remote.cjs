"use strict";

const BASE =
  process.env.TEST_BASE_URL;

const PASSWORD =
  process.env.TEST_AUTH_PASSWORD;

if (!BASE || !PASSWORD) {
  throw new Error(
    "TEST_BASE_URL/TEST_AUTH_PASSWORD ausentes"
  );
}

function getCookies(headers) {

  if (
    typeof headers.getSetCookie ===
    "function"
  ) {
    return headers.getSetCookie();
  }

  const raw =
    headers.get("set-cookie");

  if (!raw) {
    return [];
  }

  return raw.split(
    /,(?=\s*[!#$%&'*+\-.^_`|~0-9A-Za-z]+=)/
  );
}

function makeJar(values) {

  const jar =
    new Map();

  for (
    const value of values
  ) {

    const first =
      value.split(";")[0];

    const pos =
      first.indexOf("=");

    if (pos > 0) {

      jar.set(
        first.slice(0, pos),
        first.slice(pos + 1)
      );
    }
  }

  return jar;
}

function cookieHeader(jar) {

  return Array
    .from(
      jar.entries()
    )
    .map(
      ([key, value]) =>
        `${key}=${value}`
    )
    .join("; ");
}

async function call(
  pathname,
  options = {}
) {

  const response =
    await fetch(
      BASE + pathname,
      {
        redirect: "manual",
        ...options
      }
    );

  return {
    status:
      response.status,

    headers:
      response.headers,

    text:
      await response.text()
  };
}

function parse(result) {

  try {
    return JSON.parse(
      result.text
    );
  }
  catch {
    throw new Error(
      `JSON invalido HTTP ${result.status}`
    );
  }
}

(async () => {

  const anonymous =
    await call(
      "/api/draft"
    );

  if (
    anonymous.status !== 401
  ) {
    throw new Error(
      `anonymous=${anonymous.status}`
    );
  }

  console.log(
    "PASS: anonymous Draft 401"
  );

  const login =
    await call(
      "/__auth/login",
      {
        method: "POST",

        headers: {
          "Content-Type":
            "application/x-www-form-urlencoded;charset=UTF-8"
        },

        body:
          new URLSearchParams({
            password:
              PASSWORD
          }).toString()
      }
    );

  if (
    ![302,303].includes(
      login.status
    )
  ) {
    throw new Error(
      `login=${login.status}`
    );
  }

  const jar =
    makeJar(
      getCookies(
        login.headers
      )
    );

  const admin =
    jar.get(
      "__Host-oba_admin"
    );

  const csrf =
    jar.get(
      "__Host-oba_csrf"
    );

  if (!admin || !csrf) {
    throw new Error(
      "cookies admin/csrf ausentes"
    );
  }

  const cookie =
    cookieHeader(jar);

  console.log(
    "PASS: login real"
  );

  const catalogResult =
    await call(
      "/api/catalog",
      {
        headers: {
          Cookie: cookie
        }
      }
    );

  if (
    catalogResult.status !== 200
  ) {
    throw new Error(
      `catalog=${catalogResult.status}`
    );
  }

  const catalog =
    parse(
      catalogResult
    );

  const keys = [
    "sabores",
    "categorias",
    "caixas",
    "produtos",
    "opcionais",
    "combos",
    "loja"
  ];

  const payload = {};

  for (
    const key of keys
  ) {

    if (!(key in catalog)) {
      throw new Error(
        `catalog sem ${key}`
      );
    }

    payload[key] =
      catalog[key];
  }

  console.log(
    "PASS: catalog 7/7"
  );

  const initial =
    await call(
      "/api/draft",
      {
        headers: {
          Cookie: cookie
        }
      }
    );

  if (
    initial.status !== 200
  ) {
    throw new Error(
      `GET initial=${initial.status}`
    );
  }

  const initialJson =
    parse(initial);

  if (
    initialJson.revision_id !== null
  ) {
    throw new Error(
      "DRAFT inicial nao esta vazio"
    );
  }

  console.log(
    "PASS: Draft inicial vazio"
  );

  const noCsrf =
    await call(
      "/api/draft",
      {
        method: "POST",

        headers: {
          Cookie:
            cookie,

          "Content-Type":
            "application/json"
        },

        body:
          JSON.stringify({
            payload
          })
      }
    );

  if (
    noCsrf.status !== 403
  ) {
    throw new Error(
      `POST sem CSRF=${noCsrf.status}`
    );
  }

  console.log(
    "PASS: CSRF obrigatorio"
  );

  const invalid =
    await call(
      "/api/draft",
      {
        method: "POST",

        headers: {
          Cookie:
            cookie,

          "X-CSRF-Token":
            csrf,

          "Content-Type":
            "application/json"
        },

        body:
          JSON.stringify({
            payload: {
              sabores: []
            }
          })
      }
    );

  if (
    invalid.status !== 400
  ) {
    throw new Error(
      `payload invalido=${invalid.status}`
    );
  }

  console.log(
    "PASS: payload invalido bloqueado"
  );

  const save =
    await call(
      "/api/draft",
      {
        method: "POST",

        headers: {
          Cookie:
            cookie,

          "X-CSRF-Token":
            csrf,

          "Content-Type":
            "application/json"
        },

        body:
          JSON.stringify({
            payload
          })
      }
    );

  if (
    save.status !== 200
  ) {
    throw new Error(
      `save=${save.status} ${save.text}`
    );
  }

  const saved =
    parse(save);

  if (
    saved.ok !== true ||
    saved.slot !== "DRAFT" ||
    !saved.revision_id ||
    !saved.payload_sha256
  ) {
    throw new Error(
      "resposta save invalida"
    );
  }

  if (
    saved.reused !== true
  ) {
    throw new Error(
      "baseline nao foi reutilizada"
    );
  }

  if (
    saved.slots.DRAFT !==
    saved.revision_id
  ) {
    throw new Error(
      "DRAFT nao aponta para revision"
    );
  }

  if (
    saved.slots.PUBLISHED !==
    saved.revision_id
  ) {
    throw new Error(
      "PUBLISHED divergiu da baseline"
    );
  }

  if (
    saved.slots.PREVIEW !== null
  ) {
    throw new Error(
      "PREVIEW foi alterado"
    );
  }

  console.log(
    "PASS: baseline reutilizada"
  );

  console.log(
    "PASS: DRAFT = PUBLISHED"
  );

  console.log(
    "PASS: PREVIEW preservado"
  );

  const reload =
    await call(
      "/api/draft",
      {
        headers: {
          Cookie: cookie
        }
      }
    );

  if (
    reload.status !== 200
  ) {
    throw new Error(
      `reload=${reload.status}`
    );
  }

  const loaded =
    parse(reload);

  if (
    loaded.revision_id !==
    saved.revision_id
  ) {
    throw new Error(
      "persistencia Draft divergente"
    );
  }

  console.log(
    "PASS: GET Draft persistido"
  );

  const legacy =
    await call(
      "/api/catalog",
      {
        method: "POST",

        headers: {
          Cookie:
            cookie,

          "X-CSRF-Token":
            csrf,

          "Content-Type":
            "application/json"
        },

        body: "{}"
      }
    );

  if (
    legacy.status !== 501
  ) {
    throw new Error(
      `POST catalog=${legacy.status}`
    );
  }

  console.log(
    "PASS: POST catalog continua 501"
  );

  console.log(
    `DRAFT_REVISION=${saved.revision_id}`
  );

  console.log(
    `DRAFT_SHA=${saved.payload_sha256}`
  );

  console.log(
    "DRAFT_E2E_REMOTE_OK"
  );

})().catch(error => {

  console.error(
    "DRAFT_E2E_FAIL:",
    error &&
    error.message
      ? error.message
      : String(error)
  );

  process.exit(1);
});