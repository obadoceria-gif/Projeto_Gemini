import { getDataReady, getProducts, getConfig, getInputs, getSuppliers, validateAllData } from './data.js';

async function runDataTests() {
  const results = [];

  try {
    const data = await getDataReady();
    results.push({ name: 'getDataReady', success: true, value: data });
    results.push({ name: 'validateAllData', success: validateAllData(data) });
  } catch (error) {
    results.push({ name: 'getDataReady', success: false, error: error.message });
  }

  try {
    const products = await getProducts();
    results.push({ name: 'getProducts', success: Array.isArray(products) && products.length > 0 });
  } catch (error) {
    results.push({ name: 'getProducts', success: false, error: error.message });
  }

  try {
    const config = await getConfig();
    results.push({ name: 'getConfig', success: config && typeof config.storeName === 'string' });
  } catch (error) {
    results.push({ name: 'getConfig', success: false, error: error.message });
  }

  try {
    const inputs = await getInputs();
    results.push({ name: 'getInputs', success: Array.isArray(inputs) && inputs.length > 0 });
  } catch (error) {
    results.push({ name: 'getInputs', success: false, error: error.message });
  }

  try {
    const suppliers = await getSuppliers();
    results.push({ name: 'getSuppliers', success: Array.isArray(suppliers) && suppliers.length > 0 });
  } catch (error) {
    results.push({ name: 'getSuppliers', success: false, error: error.message });
  }

  return results;
}

window.runDataTests = runDataTests;
console.log('Data tests module loaded. Execute `runDataTests()` no console para rodar os testes.');