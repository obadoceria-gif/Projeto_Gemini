'use strict';

const BASE = process.env.TEST_BASE_URL;
const PASSWORD = process.env.TEST_AUTH_PASSWORD;

if (!BASE || !PASSWORD) {
  throw new Error('TEST_BASE_URL/TEST_AUTH_PASSWORD ausentes');
}

function getSetCookies(headers) {
  if (typeof headers.getSetCookie === 'function') return headers.getSetCookie();
  const raw = headers.get('set-cookie');
  if (!raw) return [];
  return raw.split(/,(?=\s*[!#$%&'*+\-.^_`|~0-9A-Za-z]+=)/);
}

function makeJar(values) {
  const jar = new Map();
  for (const value of values) {
    const first = value.split(';')[0];
    const pos = first.indexOf('=');
    if (pos > 0) jar.set(first.slice(0, pos), first.slice(pos + 1));
  }
  return jar;
}

function cookieHeader(jar) {
  return Array.from(jar.entries()).map(([k, v]) => `${k}=${v}`).join('; ');
}

async function call(pathname, options = {}) {
  const response = await fetch(BASE + pathname, { redirect: 'manual', ...options });
  return {
    status: response.status,
    headers: response.headers,
    text: await response.text()
  };
}

function parse(result) {
  try {
    return JSON.parse(result.text);
  } catch {
    throw new Error(`JSON invalido HTTP ${result.status}: ${result.text.slice(0, 200)}`);
  }
}

(async () => {
  const anonApi = await call('/api/preview');
  if (anonApi.status !== 401) throw new Error(`preview API anon=${anonApi.status}`);
  console.log('PASS: API Preview anonima 401');

  const anonPage = await call('/__preview');
  if (anonPage.status !== 303) throw new Error(`preview page anon=${anonPage.status}`);
  if ((anonPage.headers.get('location') || '') !== '/__auth/login') {
    throw new Error('preview anonimo sem redirect de login');
  }
  console.log('PASS: Preview visual anonimo bloqueado');

  const login = await call('/__auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
    body: new URLSearchParams({ password: PASSWORD }).toString()
  });

  if (![302, 303].includes(login.status)) throw new Error(`login=${login.status}`);

  const jar = makeJar(getSetCookies(login.headers));
  const admin = jar.get('__Host-oba_admin');
  const csrf = jar.get('__Host-oba_csrf');
  if (!admin || !csrf) throw new Error('cookies admin/csrf ausentes');

  const cookie = cookieHeader(jar);
  console.log('PASS: login real');

  const central = await call('/', { headers: { Cookie: cookie } });
  if (central.status !== 200) throw new Error(`Central=${central.status}`);

  for (const marker of [
    'obaLoadDraftCatalog',
    'obaSaveDraftWith',
    'obaPreparePreview',
    '/api/draft',
    '/api/preview',
    '/__preview',
    'Publicar apos Preview'
  ]) {
    if (!central.text.includes(marker)) throw new Error(`Central sem ${marker}`);
  }

  if (central.text.includes("await api('/api/publish'")) {
    throw new Error('publish legado continua executavel');
  }

  console.log('PASS: Central integrada ao Draft');

  const draftResult = await call('/api/draft', { headers: { Cookie: cookie } });
  if (draftResult.status !== 200) throw new Error(`GET Draft=${draftResult.status}`);
  const draft = parse(draftResult);
  if (!draft.revision_id || !draft.payload) throw new Error('Draft persistente ausente');

  console.log('PASS: Draft carregavel');

  const noCsrf = await call('/api/preview', {
    method: 'POST',
    headers: { Cookie: cookie, 'Content-Type': 'application/json' },
    body: JSON.stringify({ confirm: 'PREVIEW' })
  });

  if (noCsrf.status !== 403) throw new Error(`Preview sem CSRF=${noCsrf.status}`);
  console.log('PASS: CSRF obrigatorio no Preview');

  const badConfirm = await call('/api/preview', {
    method: 'POST',
    headers: {
      Cookie: cookie,
      'X-CSRF-Token': csrf,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ confirm: 'NAO' })
  });

  if (badConfirm.status !== 400) throw new Error(`confirmacao invalida=${badConfirm.status}`);
  console.log('PASS: confirmacao PREVIEW obrigatoria');

  const promotedResult = await call('/api/preview', {
    method: 'POST',
    headers: {
      Cookie: cookie,
      'X-CSRF-Token': csrf,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ confirm: 'PREVIEW' })
  });

  if (promotedResult.status !== 200) {
    throw new Error(`POST Preview=${promotedResult.status} ${promotedResult.text}`);
  }

  const promoted = parse(promotedResult);
  if (!promoted.ok || promoted.slot !== 'PREVIEW' || !promoted.revision_id) {
    throw new Error('resposta de promocao Preview invalida');
  }

  if (promoted.slots.DRAFT !== promoted.revision_id) {
    throw new Error('DRAFT diverge da revisao Preview');
  }

  if (promoted.slots.PREVIEW !== promoted.revision_id) {
    throw new Error('PREVIEW nao aponta para DRAFT');
  }

  console.log('PASS: DRAFT -> PREVIEW');

  const previewResult = await call('/api/preview', { headers: { Cookie: cookie } });
  if (previewResult.status !== 200) throw new Error(`GET Preview=${previewResult.status}`);

  const preview = parse(previewResult);
  if (preview.revision_id !== promoted.revision_id || !preview.payload) {
    throw new Error('Preview persistente invalido');
  }

  console.log('PASS: Preview persistente');

  const page = await call('/__preview?cb=' + Date.now(), { headers: { Cookie: cookie } });
  if (page.status !== 200) throw new Error(`Preview visual=${page.status}`);

  if (!page.text.includes("<base href='/ui-desenvolvimento/'>")) {
    throw new Error('base do Preview ausente');
  }

  if (!page.text.includes("src='/preview-bootstrap.js'")) {
    throw new Error('bootstrap do Preview ausente');
  }

  console.log('PASS: Preview visual privado');

  const bootstrap = await call('/preview-bootstrap.js', { headers: { Cookie: cookie } });
  if (bootstrap.status !== 200) throw new Error(`bootstrap=${bootstrap.status}`);
  if (!bootstrap.text.includes("'/api/preview'") || !bootstrap.text.includes("'flavors.json':'sabores'")) {
    throw new Error('bootstrap Preview invalido');
  }

  console.log('PASS: Bootstrap Preview');

  const legacy = await call('/api/catalog', {
    method: 'POST',
    headers: {
      Cookie: cookie,
      'X-CSRF-Token': csrf,
      'Content-Type': 'application/json'
    },
    body: '{}'
  });

  if (legacy.status !== 501) throw new Error(`POST /api/catalog=${legacy.status}`);
  console.log('PASS: escrita legada permanece 501');

  console.log('PREVIEW_REVISION=' + promoted.revision_id);
  console.log('PUBLISHED_REVISION=' + String(promoted.slots.PUBLISHED || ''));
  console.log('CENTRAL_PREVIEW_E2E_OK');
})().catch(error => {
  console.error('CENTRAL_PREVIEW_E2E_FAIL:', error && error.message ? error.message : String(error));
  process.exit(1);
});
