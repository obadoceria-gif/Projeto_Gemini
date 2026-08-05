import { getProducts as fetchProducts, validateProducts } from './data/catalog.js';
import { getConfig, validateConfig } from './data/config.js';
import { getInputs, validateInputs } from './data/inputs.js';
import { getSuppliers, validateSuppliers } from './data/suppliers.js';

async function getDataReady() {
  const [products, config, inputs, suppliers] = await Promise.all([
    fetchProducts(),
    getConfig(),
    getInputs(),
    getSuppliers()
  ]);
  return { products, config, inputs, suppliers };
}

function validateAllData({ products, config, inputs, suppliers }) {
  return (
    validateProducts(products) &&
    validateConfig(config) &&
    validateInputs(inputs) &&
    validateSuppliers(suppliers)
  );
}

export {
  fetchProducts as getProducts,
  getConfig,
  getInputs,
  getSuppliers,
  getDataReady,
  validateProducts,
  validateConfig,
  validateInputs,
  validateSuppliers,
  validateAllData
};