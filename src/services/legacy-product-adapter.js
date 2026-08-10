export function buildLegacyProductsFromViewItems(viewItems) {
  if (!Array.isArray(viewItems)) {
    throw new Error('buildLegacyProductsFromViewItems: viewItems deve ser um array.');
  }

  return viewItems.map(item => {
    const isConfigurableBox = item?.kind === 'caixa-montavel';
    const hasFixedPrice = Number.isFinite(item?.preco);

    return Object.freeze({
      id: item.id,
      nome: item.nome,
      name: item.nome,
      preco: hasFixedPrice ? item.preco : 0,
      img: '',
      disponivel: !isConfigurableBox && hasFixedPrice,
      type: isConfigurableBox ? 'caixa' : (item.sourceType ?? item.kind ?? 'produto'),
      configuravel: Boolean(item.configuravel),
      capacidade: item.capacidade ?? null,
      maxSabores: item.maxSabores ?? null
    });
  });
}
