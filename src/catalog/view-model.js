/**
 * Adaptador do Modelo Mestre para a vitrine.
 *
 * Objetivo:
 * - preservar o Modelo Mestre como fonte de verdade;
 * - oferecer à UI uma estrutura simples e estável;
 * - não misturar regras de carrinho ou checkout.
 */

function sortByOrder(items) {
  return [...items].sort((a, b) => {
    const aOrder = Number.isFinite(a.ordem) ? a.ordem : Number.MAX_SAFE_INTEGER;
    const bOrder = Number.isFinite(b.ordem) ? b.ordem : Number.MAX_SAFE_INTEGER;
    return aOrder - bOrder || String(a.nome ?? '').localeCompare(String(b.nome ?? ''), 'pt-BR');
  });
}

function isVisible(item) {
  return item?.ativo !== false && item?.disponivel !== false;
}

function normalizeImage(image) {
  if (!image || typeof image !== 'string') return null;
  return image.trim() || null;
}

function normalizeFixedProduct(product) {
  return Object.freeze({
    id: product.id,
    kind: 'produto-fixo',
    sourceType: product.tipo ?? 'produto',
    nome: product.nome,
    descricao: product.descricao ?? '',
    preco: Number(product.preco),
    imagem: normalizeImage(product.imagem),
    configuravel: false,
    capacidade: null,
    maxSabores: null,
    opcionaisPermitidos: Array.isArray(product.opcionaisPermitidos)
      ? [...product.opcionaisPermitidos]
      : []
  });
}

function normalizeBox(box) {
  const isConfigurable = box.tipo === 'montavel';

  return Object.freeze({
    id: box.id,
    kind: isConfigurable ? 'caixa-montavel' : 'caixa-fechada',
    sourceType: 'caixa',
    nome: box.nome,
    descricao: isConfigurable
      ? `Monte sua caixa com ${box.capacidade} doces e até ${box.maxSabores} sabores.`
      : `Caixa fechada com ${box.capacidade} doces.`,
    preco: isConfigurable ? null : Number(box.precoFixo),
    imagem: normalizeImage(box.imagem),
    configuravel: isConfigurable,
    capacidade: box.capacidade,
    maxSabores: box.maxSabores,
    opcionaisPermitidos: []
  });
}

/**
 * Constrói a lista de cards que a interface pode exibir.
 *
 * As caixas montáveis não recebem preço artificial:
 * o preço só existirá depois que os sabores forem escolhidos.
 */
export function buildCatalogViewModel(catalog) {
  if (!catalog || typeof catalog !== 'object') {
    throw new Error('buildCatalogViewModel: catálogo inválido.');
  }

  const boxes = Array.isArray(catalog.boxes) ? catalog.boxes : [];
  const products = Array.isArray(catalog.products) ? catalog.products : [];

  const normalizedBoxes = sortByOrder(boxes.filter(isVisible)).map(normalizeBox);
  const normalizedProducts = sortByOrder(products.filter(isVisible)).map(normalizeFixedProduct);

  return Object.freeze({
    catalogVersion: catalog.config?.catalogVersion ?? null,
    store: Object.freeze({
      name: catalog.config?.store?.name ?? 'Oba Doceria',
      whatsapp: catalog.config?.store?.whatsapp ?? ''
    }),
    sections: Object.freeze([
      Object.freeze({
        id: 'caixas',
        titulo: 'Caixas',
        items: Object.freeze(normalizedBoxes)
      }),
      Object.freeze({
        id: 'presenteaveis',
        titulo: 'Presenteáveis',
        items: Object.freeze(normalizedProducts)
      })
    ])
  });
}
