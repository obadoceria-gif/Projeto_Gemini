import { fetchJson } from './utils.js';

const fallbackSuppliers = [
  {
    id: 'fornecedor-laticinios',
    nome: 'Laticínios São João',
    contato: '(11) 98888-0000',
    email: 'contato@saojoaolaticinios.com.br',
    cidade: 'São Paulo'
  },
  {
    id: 'fornecedor-chocolate',
    nome: 'Chocolate Brasil',
    contato: '(11) 97777-1111',
    email: 'vendas@chocolatebrasil.com.br',
    cidade: 'Campinas'
  },
  {
    id: 'fornecedor-mercearia',
    nome: 'Mercearia Central',
    contato: '(11) 96666-2222',
    email: 'atendimento@merceariacentral.com.br',
    cidade: 'São Paulo'
  }
];

function isValidSupplier(supplier) {
  return Boolean(
    supplier &&
    typeof supplier.id === 'string' &&
    typeof supplier.nome === 'string' &&
    typeof supplier.contato === 'string' &&
    typeof supplier.email === 'string' &&
    typeof supplier.cidade === 'string'
  );
}

function validateSuppliers(suppliers) {
  return Array.isArray(suppliers) && suppliers.every(isValidSupplier);
}

async function getSuppliers() {
  try {
    const data = await fetchJson('suppliers.json');
    if (!validateSuppliers(data)) {
      throw new Error('Invalid suppliers format');
    }
    return data;
  } catch (error) {
    console.warn('Não foi possível carregar suppliers.json. Usando fallback.', error);
    return fallbackSuppliers;
  }
}

function findSupplierById(id, suppliers = []) {
  return suppliers.find(supplier => supplier.id === id) || null;
}

function searchSuppliers(term, suppliers = []) {
  if (!term) return suppliers;
  const query = term.toString().toLowerCase();
  return suppliers.filter(supplier =>
    supplier.nome.toLowerCase().includes(query) ||
    supplier.cidade.toLowerCase().includes(query)
  );
}

export { getSuppliers, findSupplierById, searchSuppliers, validateSuppliers }; 