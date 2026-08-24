import { fetchJson } from './utils.js';

const fallbackProducts = [
  {
    id: 'brigadeiro-tradicional',
    nome: 'Brigadeiro Tradicional',
    categoria: 'brigadeiros',
    preco: 2.5,
    img: '',
    disponivel: true,
    insumos: ['leite-condensado', 'manteiga', 'chocolate-povis']
  },
  {
    id: 'brigadeiro-doce-de-leite',
    nome: 'Brigadeiro Doce de Leite',
    categoria: 'brigadeiros',
    preco: 3.0,
    img: '',
    disponivel: true,
    insumos: ['leite-condensado', 'creme-de-leite', 'manteiga']
  },
  {
    id: 'palha-italiana',
    nome: 'Palha Italiana',
    categoria: 'doces',
    preco: 4.5,
    img: '',
    disponivel: true,
    insumos: ['chocolate-povis', 'biscoito', 'leite-condensado']
  },
  {
    id: 'caixa-6',
    nome: 'Caixa 6 Unidades',
    categoria: 'embalagens',
    preco: 5.0,
    img: '',
    disponivel: true,
    insumos: []
  }
];

function isValidProduct(product) {
  return Boolean(
    product &&
    typeof product.id === 'string' &&
    typeof product.nome === 'string' &&
    typeof product.categoria === 'string' &&
    typeof product.preco === 'number' &&
    product.preco >= 0 &&
    typeof product.disponivel === 'boolean' &&
    (!product.img || typeof product.img === 'string') &&
    (!product.insumos || Array.isArray(product.insumos))
  );
}

function validateProducts(products) {
  return Array.isArray(products) && products.every(isValidProduct);
}

async function getProducts() {
  try {
    const data = await fetchJson('products.json');
    if (!validateProducts(data)) {
      throw new Error('Invalid products format');
    }
    return data;
  } catch (error) {
    console.warn('Não foi possível carregar products.json. Usando fallback.', error);
    return fallbackProducts;
  }
}

function findProductById(id, products = []) {
  return products.find(product => product.id === id) || null;
}

function searchProducts(term, products = []) {
  if (!term) return products;
  const query = term.toString().toLowerCase();
  return products.filter(product =>
    product.nome.toLowerCase().includes(query) ||
    product.categoria.toLowerCase().includes(query)
  );
}

export { getProducts, findProductById, searchProducts, validateProducts };