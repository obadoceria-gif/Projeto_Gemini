/**
 * Carregador único do Modelo Mestre de Catálogo.
 *
 * Usa import.meta.url para que os caminhos funcionem tanto em ambiente local
 * quanto em GitHub Pages publicado dentro de um subdiretório.
 */

const CATALOG_BASE_URL = new URL('../../data/catalog-v1/', import.meta.url);

const FILES = Object.freeze({
  config: 'config.json',
  categories: 'categories.json',
  flavors: 'flavors.json',
  boxes: 'boxes.json',
  products: 'products.json',
  options: 'options.json',
  combos: 'combos.json'
});

async function fetchJson(filename) {
  const url = new URL(filename, CATALOG_BASE_URL);
  const response = await fetch(url, {
    headers: {
      Accept: 'application/json'
    },
    cache: 'no-store'
  });

  if (!response.ok) {
    throw new Error(
      `Falha ao carregar "${filename}" (${response.status} ${response.statusText}).`
    );
  }

  try {
    return await response.json();
  } catch {
    throw new Error(`Arquivo "${filename}" contém JSON inválido.`);
  }
}

export async function loadCatalog() {
  const entries = await Promise.all(
    Object.entries(FILES).map(async ([key, filename]) => {
      const data = await fetchJson(filename);
      return [key, data];
    })
  );

  return Object.fromEntries(entries);
}

export function getCatalogBaseUrl() {
  return CATALOG_BASE_URL.href;
}
