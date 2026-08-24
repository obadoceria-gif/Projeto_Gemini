import { fetchJson } from './utils.js';

const fallbackInputs = [
  {
    id: 'leite-condensado',
    nome: 'Leite Condensado',
    unidade: 'lata',
    preco: 5.5,
    fornecedorId: 'fornecedor-laticinios'
  },
  {
    id: 'manteiga',
    nome: 'Manteiga',
    unidade: 'kg',
    preco: 18.0,
    fornecedorId: 'fornecedor-laticinios'
  },
  {
    id: 'chocolate-povis',
    nome: 'Chocolate em Pó',
    unidade: 'pacote',
    preco: 8.5,
    fornecedorId: 'fornecedor-chocolate'
  },
  {
    id: 'creme-de-leite',
    nome: 'Creme de Leite',
    unidade: 'caixa',
    preco: 6.0,
    fornecedorId: 'fornecedor-laticinios'
  },
  {
    id: 'biscoito',
    nome: 'Biscoito',
    unidade: 'pacote',
    preco: 4.0,
    fornecedorId: 'fornecedor-mercearia'
  }
];

function isValidInput(input) {
  return Boolean(
    input &&
    typeof input.id === 'string' &&
    typeof input.nome === 'string' &&
    typeof input.unidade === 'string' &&
    typeof input.preco === 'number' &&
    input.preco >= 0 &&
    typeof input.fornecedorId === 'string'
  );
}

function validateInputs(inputs) {
  return Array.isArray(inputs) && inputs.every(isValidInput);
}

async function getInputs() {
  try {
    const data = await fetchJson('inputs.json');
    if (!validateInputs(data)) {
      throw new Error('Invalid inputs format');
    }
    return data;
  } catch (error) {
    console.warn('Não foi possível carregar inputs.json. Usando fallback.', error);
    return fallbackInputs;
  }
}

function findInputById(id, inputs = []) {
  return inputs.find(input => input.id === id) || null;
}

function searchInputs(term, inputs = []) {
  if (!term) return inputs;
  const query = term.toString().toLowerCase();
  return inputs.filter(input => input.nome.toLowerCase().includes(query));
}

function getInputsBySupplier(supplierId, inputs = []) {
  return inputs.filter(input => input.fornecedorId === supplierId);
}

export { getInputs, findInputById, searchInputs, getInputsBySupplier, validateInputs };