import { fetchJson } from './utils.js';

const fallbackConfig = {
  storePhone: '',
  storeName: 'Oba Doceria',
  welcomeText: 'Bem-vindo ao Cardápio Virtual da Oba Doceria! Escolha seus doces e finalize seu pedido por WhatsApp.',
  phoneHint: 'Telefone da loja no formato E.164 sem sinais, ex: 5511999999999',
  whatsappPrompt: 'Por favor confirmar disponibilidade e preço final. Obrigado!'
};

function validateConfig(config) {
  return Boolean(
    config &&
    typeof config.storePhone === 'string' &&
    typeof config.storeName === 'string' &&
    typeof config.welcomeText === 'string' &&
    typeof config.phoneHint === 'string' &&
    typeof config.whatsappPrompt === 'string'
  );
}

async function getConfig() {
  try {
    const data = await fetchJson('config.json');
    if (!validateConfig(data)) {
      throw new Error('Invalid config format');
    }
    return { ...fallbackConfig, ...data };
  } catch (error) {
    console.warn('Não foi possível carregar config.json. Usando fallback.', error);
    return fallbackConfig;
  }
}

export { getConfig, validateConfig, fallbackConfig };