// Loader de catálogo para Oba Doceria
const fallbackProducts = [
  { id: 'brigadeiro-tradicional', nome: 'Brigadeiro Tradicional', categoria: 'brigadeiros', preco: 2.5, img: '', disponivel: true },
  { id: 'brigadeiro-doce-de-leite', nome: 'Brigadeiro Doce de Leite', categoria: 'brigadeiros', preco: 3.0, img: '', disponivel: true },
  { id: 'palha-italiana', nome: 'Palha Italiana', categoria: 'doces', preco: 4.5, img: '', disponivel: true },
  { id: 'caixa-6', nome: 'Caixa 6 Unidades', categoria: 'embalagens', preco: 5.0, img: '', disponivel: true }
];

function validateProducts(products) {
  if (!Array.isArray(products)) return false;
  for (const p of products) {
    if (!p.id || !p.nome) return false;
    if (typeof p.preco !== 'number' || Number.isNaN(p.preco) || p.preco < 0) return false;
  }
  return true;
}

async function getProducts() {
  try {
    const res = await fetch('/data/products.json', { cache: 'no-cache' });
    if (!res.ok) throw new Error('fetch failed');
    const data = await res.json();
    if (!validateProducts(data)) throw new Error('validation failed');
    return data;
  } catch (err) {
    console.warn('Não foi possível carregar /data/products.json — usando fallback.', err);
    return fallbackProducts;
  }
}

export { getProducts, validateProducts };