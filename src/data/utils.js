const DATA_PATH = '/data';

async function fetchJson(filename) {
  const response = await fetch(`${DATA_PATH}/${filename}`, { cache: 'no-cache' });
  if (!response.ok) {
    throw new Error(`${filename} fetch failed with ${response.status}`);
  }
  return await response.json();
}

function ensureArray(value) {
  return Array.isArray(value) ? value : [];
}

function sanitizeText(value) {
  return String(value || '').trim();
}

export { fetchJson, ensureArray, sanitizeText };