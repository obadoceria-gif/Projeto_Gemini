// Loader de catálogo para Oba Doceria
const fallbackProducts = [
  { id: 'brigadeiro-tradicional', nome: 'Brigadeiro Tradicional', categoria: 'brigadeiros', preco: 2.5, img: '', disponivel: true },
  { id: 'brigadeiro-doce-de-leite', nome: 'Brigadeiro Doce de Leite', categoria: 'brigadeiros', preco: 3.0, img: '', disponivel: true },
  { id: 'palha-italiana', nome: 'Palha Italiana', categoria: 'doces', preco: 4.5, img: '', disponivel: true },
  { id: 'caixa-6', nome: 'Caixa 6 Unidades', categoria: 'embalagens', preco: 5.0, img: '', disponivel: true }
];

const fallbackConfig = {
  storePhone: '',
  storeName: 'Oba Doceria',
  welcomeText: 'Bem-vindo ao Cardápio Virtual da Oba Doceria! Escolha seus doces e finalize seu pedido por WhatsApp.',
  phoneHint: 'Telefone da loja no formato E.164 sem sinais, ex: 5511999999999',
  whatsappPrompt: 'Por favor confirmar disponibilidade e preço final. Obrigado!'
};

function validateProducts(products) {
  if (!Array.isArray(products)) return false;
  for (const p of products) {
    if (!p || typeof p !== 'object') return false;
    if (!p.id || !p.nome) return false;
    if (typeof p.preco !== 'number' || Number.isNaN(p.preco) || p.preco < 0) return false;
    if (p.img && typeof p.img !== 'string') return false;
    if (typeof p.disponivel !== 'boolean') return false;
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

async function getConfig() {
  try {
    const res = await fetch('/data/config.json', { cache: 'no-cache' });
    if (!res.ok) throw new Error('fetch failed');
    const data = await res.json();
    return { ...fallbackConfig, ...data };
  } catch (err) {
    console.warn('Não foi possível carregar /data/config.json — usando fallback.', err);
    return fallbackConfig;
  }
}

export { getProducts, getConfig, validateProducts };