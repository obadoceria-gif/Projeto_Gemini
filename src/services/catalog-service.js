import {
  initializeCatalog,
  buildCatalogViewModel
} from '../catalog/index.js';

let catalog = null;
let viewModel = null;

export async function initializeCatalogService({ forceReload = false } = {}) {
  if (catalog && viewModel && !forceReload) {
    return { catalog, viewModel };
  }

  catalog = await initializeCatalog({ forceReload });
  viewModel = buildCatalogViewModel(catalog);

  return { catalog, viewModel };
}

export function getCatalogData() {
  if (!catalog) {
    throw new Error('CatalogService ainda não inicializado.');
  }
  return catalog;
}

export function getCatalogViewModel() {
  if (!viewModel) {
    throw new Error('CatalogService ainda não inicializado.');
  }
  return viewModel;
}

export function getCatalogVersion() {
  return getCatalogViewModel().catalogVersion;
}

export function getStore() {
  return getCatalogViewModel().store;
}

export function getSections() {
  return getCatalogViewModel().sections;
}

export function getAllViewItems() {
  return getSections().flatMap(section => section.items);
}

export function findViewItemById(itemId) {
  if (!itemId) return null;
  return getAllViewItems().find(item => item.id === itemId) ?? null;
}

export function getConfigurableBoxes() {
  return getAllViewItems().filter(item => item.kind === 'caixa-montavel');
}

export function getFixedPriceItems() {
  return getAllViewItems().filter(
    item => item.preco !== null && Number.isFinite(item.preco)
  );
}

export function clearCatalogServiceCache() {
  catalog = null;
  viewModel = null;
}
