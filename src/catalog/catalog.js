import { loadCatalog } from './loader.js';
import { validateCatalog } from './validator.js';

let cachedCatalog = null;

export async function initializeCatalog({ forceReload = false } = {}) {
  if (cachedCatalog && !forceReload) {
    return cachedCatalog;
  }

  const catalog = await loadCatalog();
  const validation = validateCatalog(catalog);

  if (!validation.valid) {
    const details = validation.errors.map(error => `- ${error}`).join('\n');
    throw new Error(`Modelo Mestre de Catálogo inválido:\n${details}`);
  }

  cachedCatalog = Object.freeze({
    ...catalog,
    validation
  });

  return cachedCatalog;
}

export function getCatalog() {
  if (!cachedCatalog) {
    throw new Error(
      'Catálogo ainda não inicializado. Execute initializeCatalog() antes de getCatalog().'
    );
  }

  return cachedCatalog;
}

export function clearCatalogCache() {
  cachedCatalog = null;
}
