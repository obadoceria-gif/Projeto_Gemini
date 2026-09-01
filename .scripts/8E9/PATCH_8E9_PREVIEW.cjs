'use strict';
const fs = require('fs');
const workerFile = process.argv[2];
const centralFile = process.argv[3];
const bootstrapFile = process.argv[4];
if (!workerFile || !centralFile || !bootstrapFile) throw new Error('args ausentes');
let worker = fs.readFileSync(workerFile, 'utf8');
let central = fs.readFileSync(centralFile, 'utf8');
function fail(m){ throw new Error(m); }
function replaceExactCount(text, oldValue, newValue, expected, label){
  const count = text.split(oldValue).length - 1;
  if(count !== expected) fail(label+': esperado '+expected+', encontrado '+count);
  return text.split(oldValue).join(newValue);
}
function replaceOnce(text, oldValue, newValue, label){
  return replaceExactCount(text,oldValue,newValue,1,label);
}
function matchingBrace(text, open){
  let depth=0, quote=null, escape=false, lineComment=false, blockComment=false;
  for(let i=open;i<text.length;i++){
    const ch=text[i], next=text[i+1];
    if(lineComment){ if(ch==='\n') lineComment=false; continue; }
    if(blockComment){ if(ch==='*'&&next==='/'){ blockComment=false; i++; } continue; }
    if(quote){
      if(escape){ escape=false; continue; }
      if(ch==='\\'){ escape=true; continue; }
      if(ch===quote){ quote=null; }
      continue;
    }
    if(ch==='/'&&next==='/'){ lineComment=true; i++; continue; }
    if(ch==='/'&&next==='*'){ blockComment=true; i++; continue; }
    if(ch==='\''||ch==='"'||ch==='`'){ quote=ch; continue; }
    if(ch==='{') depth++;
    else if(ch==='}') { depth--; if(depth===0) return i; }
  }
  return -1;
}
function replaceFunction(text, marker, replacement, label){
  const start=text.indexOf(marker);
  if(start<0) fail(label+': inicio ausente');
  const open=text.indexOf('{',start);
  if(open<0) fail(label+': abertura ausente');
  const close=matchingBrace(text,open);
  if(close<0) fail(label+': fechamento ausente');
  return text.slice(0,start)+replacement+text.slice(close+1);
}

if(worker.includes('OBA_PREVIEW_API_BEGIN')) fail('Preview API ja instalada');
const draftEnd='/* OBA_DRAFT_API_END */';
const draftEndIndex=worker.indexOf(draftEnd);
if(draftEndIndex<0) fail('OBA_DRAFT_API_END ausente');

const previewHelpers = `\n\n/* OBA_PREVIEW_API_BEGIN */\n\nasync function obaLoadCatalogSlot(env, slot) {\n  const row =\n    await env.DB\n      .prepare(\n        [\n          \"SELECT\",\n          \"s.slot,\",\n          \"s.revision_id,\",\n          \"s.updated_at,\",\n          \"r.payload_json,\",\n          \"r.payload_sha256,\",\n          \"r.created_at\",\n          \"FROM catalog_slots s\",\n          \"LEFT JOIN catalog_revisions r\",\n          \"ON r.revision_id = s.revision_id\",\n          \"WHERE s.slot = ?\",\n          \"LIMIT 1\"\n        ].join(\" \")\n      )\n      .bind(slot)\n      .first();\n\n  if (!row || !row.revision_id) {\n    return {\n      slot,\n      revision_id: null,\n      updated_at: row ? row.updated_at : null,\n      payload_sha256: null,\n      payload: null\n    };\n  }\n\n  let payload;\n  try {\n    payload = JSON.parse(row.payload_json);\n  }\n  catch {\n    throw new Error(\"slot_payload_corrupt\");\n  }\n\n  return {\n    slot,\n    revision_id: row.revision_id,\n    updated_at: row.updated_at,\n    payload_sha256: row.payload_sha256,\n    payload\n  };\n}\n\nasync function obaCatalogSlotsState(env) {\n  const rows =\n    await env.DB\n      .prepare(\n        [\n          \"SELECT slot, revision_id\",\n          \"FROM catalog_slots\",\n          \"ORDER BY slot\"\n        ].join(\" \")\n      )\n      .all();\n\n  const slots = { DRAFT: null, PREVIEW: null, PUBLISHED: null };\n  for (const row of rows.results || []) {\n    if (Object.prototype.hasOwnProperty.call(slots, row.slot)) {\n      slots[row.slot] = row.revision_id ?? null;\n    }\n  }\n  return slots;\n}\n\nasync function obaHandlePreviewApi(request, env, url) {\n  if (url.pathname !== \"/api/preview\") return null;\n\n  if (request.method === \"GET\") {\n    const preview = await obaLoadCatalogSlot(env, \"PREVIEW\");\n    const slots = await obaCatalogSlotsState(env);\n    return obaApiJson({ ok: true, ...preview, slots });\n  }\n\n  if (request.method !== \"POST\") {\n    return obaApiJson({ ok: false, error: \"method_not_allowed\" }, 405);\n  }\n\n  let body;\n  try { body = await request.json(); }\n  catch { return obaApiJson({ ok: false, error: \"invalid_json\" }, 400); }\n\n  if (!body || body.confirm !== \"PREVIEW\") {\n    return obaApiJson({ ok: false, error: \"preview_confirmation_required\" }, 400);\n  }\n\n  const draft = await obaLoadCatalogSlot(env, \"DRAFT\");\n  if (!draft.revision_id) {\n    return obaApiJson({ ok: false, error: \"draft_required\" }, 409);\n  }\n\n  const before = await obaLoadCatalogSlot(env, \"PREVIEW\");\n  const published = await obaLoadCatalogSlot(env, \"PUBLISHED\");\n\n  if (before.revision_id === draft.revision_id) {\n    return obaApiJson({\n      ok: true,\n      slot: \"PREVIEW\",\n      revision_id: draft.revision_id,\n      payload_sha256: draft.payload_sha256,\n      reused: true,\n      slots: {\n        DRAFT: draft.revision_id,\n        PREVIEW: before.revision_id,\n        PUBLISHED: published.revision_id\n      }\n    });\n  }\n\n  const now = new Date().toISOString();\n  await env.DB.batch([\n    env.DB\n      .prepare(\n        [\n          \"UPDATE catalog_slots\",\n          \"SET revision_id = ?,\",\n          \"updated_at = ?\",\n          \"WHERE slot = 'PREVIEW'\"\n        ].join(\" \")\n      )\n      .bind(draft.revision_id, now),\n\n    env.DB\n      .prepare(\n        [\n          \"INSERT INTO catalog_promotions\",\n          \"(\",\n          \"promotion_id,\",\n          \"action,\",\n          \"from_revision_id,\",\n          \"to_revision_id,\",\n          \"created_at,\",\n          \"created_by\",\n          \")\",\n          \"VALUES (?, ?, ?, ?, ?, ?)\"\n        ].join(\" \")\n      )\n      .bind(\n        \"promotion_\" + crypto.randomUUID().replaceAll(\"-\", \"\"),\n        \"PREVIEW_CREATED\",\n        before.revision_id,\n        draft.revision_id,\n        now,\n        \"admin\"\n      )\n  ]);\n\n  return obaApiJson({\n    ok: true,\n    slot: \"PREVIEW\",\n    revision_id: draft.revision_id,\n    payload_sha256: draft.payload_sha256,\n    reused: false,\n    slots: {\n      DRAFT: draft.revision_id,\n      PREVIEW: draft.revision_id,\n      PUBLISHED: published.revision_id\n    }\n  });\n}\n\nasync function obaPrivatePreviewPage(request, env) {\n  const preview = await obaLoadCatalogSlot(env, \"PREVIEW\");\n  if (!preview.revision_id || !preview.payload) {\n    return new Response(\n      \"<!doctype html><html lang='pt-BR'><meta charset='utf-8'><title>Preview indisponivel</title><body><h1>Preview ainda nao foi criado.</h1><p>Volte a Central e clique em Visualizar cardapio.</p></body></html>\",\n      { status: 409, headers: { \"Content-Type\": \"text/html; charset=utf-8\", \"Cache-Control\": \"no-store\", \"X-Robots-Tag\": \"noindex, nofollow\" } }\n    );\n  }\n\n  const assetUrl = new URL(request.url);\n  assetUrl.pathname = \"/ui-desenvolvimento/index.html\";\n  assetUrl.search = \"\";\n  assetUrl.hash = \"\";\n  const asset = await env.ASSETS.fetch(new Request(assetUrl.toString(), { method: \"GET\", headers: request.headers }));\n  if (!asset.ok) return new Response(\"Preview asset unavailable\", { status: 502 });\n\n  const source = await asset.text();\n  const inject = \"<base href='/ui-desenvolvimento/'><script src='/preview-bootstrap.js'></script>\";\n  const html = source.includes(\"<head>\") ? source.replace(\"<head>\", \"<head>\" + inject) : inject + source;\n\n  return new Response(html, {\n    status: 200,\n    headers: {\n      \"Content-Type\": \"text/html; charset=utf-8\",\n      \"Cache-Control\": \"no-store, no-cache, must-revalidate\",\n      \"Pragma\": \"no-cache\",\n      \"X-Robots-Tag\": \"noindex, nofollow, noarchive\",\n      \"X-Content-Type-Options\": \"nosniff\",\n      \"Referrer-Policy\": \"no-referrer\",\n      \"X-Frame-Options\": \"DENY\",\n      \"Content-Security-Policy\": \"default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; connect-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'self'\"\n    }\n  });\n}\n\n/* OBA_PREVIEW_API_END */\n`;
worker = worker.slice(0,draftEndIndex+draftEnd.length)+previewHelpers+worker.slice(draftEndIndex+draftEnd.length);

let fetchIndex=worker.indexOf('async fetch(request, env)');
let draftDispatch=worker.indexOf('const obaDraftResponse',fetchIndex);
if(fetchIndex<0||draftDispatch<0) fail('dispatch Draft ausente');
const apiIfMarker='if (url.pathname.startsWith("/api/")) {';
let apiIfIndex=worker.lastIndexOf(apiIfMarker,draftDispatch);
if(apiIfIndex<fetchIndex) fail('IF API autenticado ausente');
const previewRoute=`    if (url.pathname === \"/__preview\") {\n      return obaPrivatePreviewPage(request, env);\n    }\n\n`;
worker=worker.slice(0,apiIfIndex)+previewRoute+worker.slice(apiIfIndex);
fetchIndex=worker.indexOf('async fetch(request, env)');
draftDispatch=worker.indexOf('const obaDraftResponse',fetchIndex);
const previewDispatch=`      const obaPreviewResponse =\n        await obaHandlePreviewApi(\n          request,\n          env,\n          url\n        );\n\n      if (obaPreviewResponse) {\n        return obaPreviewResponse;\n      }\n\n`;
worker=worker.slice(0,draftDispatch)+previewDispatch+worker.slice(draftDispatch);

// Central: substituir API wrapper por versao CSRF-aware + helpers DRAFT.
const apiMarker='async function api(url,opts){';
const apiStart=central.indexOf(apiMarker);
if(apiStart<0) fail('api() Central ausente');
const apiOpen=central.indexOf('{',apiStart);
const apiClose=matchingBrace(central,apiOpen);
if(apiClose<0) fail('api() Central invalida');
const centralApi=`async function api(url,opts={}){\n  const options={...opts};\n  const method=String(options.method||'GET').toUpperCase();\n  const headers=new Headers(options.headers||{});\n  if(!['GET','HEAD','OPTIONS'].includes(method)){\n    const token=String(document.cookie||'').split(';').map(x=>x.trim()).find(x=>x.startsWith('__Host-oba_csrf='));\n    const csrf=token?decodeURIComponent(token.slice('__Host-oba_csrf='.length)):'';\n    if(!csrf)throw new Error('Sessao sem CSRF. Entre novamente na Central.');\n    headers.set('X-CSRF-Token',csrf);\n  }\n  options.headers=headers;\n  const r=await fetch(url,options);\n  const text=await r.text();\n  let j={};\n  if(text){try{j=JSON.parse(text)}catch{j={error:text}}}\n  if(!r.ok)throw new Error(j.error||('HTTP '+r.status));\n  return j;\n}\n\nfunction obaNormalizeCatalog(raw){\n  const s=(raw&&((raw.catalog)||(raw.data)||(raw.state)))||raw||{};\n  return {\n    flavors:s.flavors||s.sabores||[],\n    categories:s.categories||s.categorias||[],\n    boxes:s.boxes||s.caixas||[],\n    products:s.products||s.produtos||[],\n    options:s.options||s.opcionais||[],\n    combos:s.combos||[],\n    config:s.config||s.loja||s.store||{}\n  };\n}\n\nfunction obaDraftPayload(state=catalogo){\n  return {\n    sabores:state.flavors||[],\n    categorias:state.categories||[],\n    caixas:state.boxes||[],\n    produtos:state.products||[],\n    opcionais:state.options||[],\n    combos:state.combos||[],\n    loja:state.config||{}\n  };\n}\n\nasync function obaLoadDraftCatalog(){\n  const draft=await api('/api/draft',{cache:'no-store'});\n  if(draft&&draft.payload)return obaNormalizeCatalog(draft.payload);\n  return obaNormalizeCatalog(await api('/api/catalog',{cache:'no-store'}));\n}\n\nasync function obaSaveDraftState(nextState){\n  const saved=await api('/api/draft',{\n    method:'POST',\n    headers:{'Content-Type':'application/json'},\n    body:JSON.stringify({payload:obaDraftPayload(nextState)})\n  });\n  return {...saved,backup:'DRAFT '+String(saved.revision_id||'')};\n}\n\nasync function obaSaveDraftWith(tipo,value){\n  const next={...catalogo,[tipo]:value};\n  const saved=await obaSaveDraftState(next);\n  catalogo[tipo]=value;\n  return saved;\n}\n\nasync function obaPreparePreview(){\n  return api('/api/preview',{\n    method:'POST',\n    headers:{'Content-Type':'application/json'},\n    body:JSON.stringify({confirm:'PREVIEW'})\n  });\n}\n`;
central=central.slice(0,apiStart)+centralApi+central.slice(apiClose+1);

central=replaceFunction(central,'async function atualizarStatus(){',`async function atualizarStatus(){\n  try{\n    const draft=await api('/api/draft',{cache:'no-store'});\n    const preview=await api('/api/preview',{cache:'no-store'});\n    const b=$('statusBadge');\n    const slots=preview.slots||{};\n    if(!draft.revision_id){\n      b.textContent='Rascunho vazio';\n      b.className='badge off';\n    }else if(slots.PREVIEW!==draft.revision_id){\n      b.textContent='Rascunho aguardando Preview';\n      b.className='badge off';\n    }else if(slots.PUBLISHED!==draft.revision_id){\n      b.textContent='Preview pronto para publicar';\n      b.className='badge off';\n    }else{\n      b.textContent='Sem alteracoes publicaveis';\n      b.className='badge ok';\n    }\n    window.__obaStatusPublicacao={draft,preview,slots};\n  }catch{}\n}`,'atualizarStatus');

central=replaceExactCount(central,"const res=await api('/api/'+tipo,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({items})});","const res=await obaSaveDraftWith(tipo,items);",2,'writes entidade');
central=replaceOnce(central,"catalogo=await api('/api/catalog',{cache:'no-store'});","catalogo=await obaLoadDraftCatalog();",'carregar Draft');
central=replaceOnce(central,"const res=await api('/api/config',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({config:cfg})});","const res=await obaSaveDraftWith('config',cfg);",'config Draft');
central=replaceOnce(central,"$('previewBtn').onclick=()=>window.open('/ui-desenvolvimento/index.html?preview='+Date.now(),'_blank','noopener,noreferrer');",`$('previewBtn').onclick=async()=>{\n  const b=$('previewBtn');\n  b.disabled=true;b.textContent='Preparando preview...';\n  try{\n    await obaPreparePreview();\n    await atualizarStatus();\n    window.open('/__preview?cb='+Date.now(),'_blank','noopener,noreferrer');\n    msg('Preview privado atualizado. O cardapio publicado continua intacto.');\n  }catch(err){msg(String(err.message||err),'erro')}\n  finally{b.disabled=false;b.textContent='Visualizar cardapio'}\n};`,'preview button');

central=replaceFunction(central,"$('publicarBtn').onclick=async()=>{",`$('publicarBtn').onclick=()=>{\n  msg('Publicacao oficial protegida. Valide primeiro o Preview privado; PREVIEW -> PUBLISHED sera habilitado na proxima fase.','erro');\n};\n$('publicarBtn').textContent='Publicar apos Preview';`,'publish button');

const bootstrap=`'use strict';\n(function(){\n  const nativeFetch=window.fetch.bind(window);\n  const previewPromise=nativeFetch('/api/preview',{cache:'no-store'})\n    .then(async r=>{\n      const j=await r.json();\n      if(!r.ok||!j.payload)throw new Error(j.error||'Preview indisponivel');\n      return j.payload;\n    });\n  const map={\n    'flavors.json':'sabores',\n    'categories.json':'categorias',\n    'boxes.json':'caixas',\n    'products.json':'produtos',\n    'options.json':'opcionais',\n    'combos.json':'combos',\n    'config.json':'loja'\n  };\n  window.fetch=async function(input,init){\n    const raw=typeof input==='string'?input:(input&&input.url?input.url:String(input));\n    const u=new URL(raw,window.location.href);\n    const name=u.pathname.split('/').pop();\n    const key=map[name];\n    if(key){\n      const payload=await previewPromise;\n      return new Response(JSON.stringify(payload[key]),{status:200,headers:{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store'}});\n    }\n    return nativeFetch(input,init);\n  };\n})();\n`;

for(const m of ['OBA_PREVIEW_API_BEGIN','obaHandlePreviewApi','obaPrivatePreviewPage','PREVIEW_CREATED','/__preview']) if(!worker.includes(m)) fail('Worker gate ausente '+m);
for(const m of ['obaLoadDraftCatalog','obaSaveDraftWith','obaPreparePreview','/api/preview','/__preview','Publicar apos Preview']) if(!central.includes(m)) fail('Central gate ausente '+m);
if(central.includes("await api('/api/publish'")) fail('publish legado ainda ativo');
if(central.includes("catalogo=await api('/api/catalog',{cache:'no-store'});")) fail('carregamento legado ainda ativo');
const firstScript=central.match(/<script>([\s\S]*?)<\/script>/);
if(!firstScript) fail('script principal da Central ausente');
try{ new Function(firstScript[1]); }catch(e){ fail('Central JS invalido: '+e.message); }
try{ new Function(bootstrap); }catch(e){ fail('Bootstrap JS invalido: '+e.message); }

fs.writeFileSync(workerFile,worker,'utf8');
fs.writeFileSync(centralFile,central,'utf8');
fs.writeFileSync(bootstrapFile,bootstrap,'utf8');
console.log('PATCH_8E9_PREVIEW_OK');
