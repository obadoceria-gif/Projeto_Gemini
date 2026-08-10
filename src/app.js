
import { getProducts } from './data.js';
import { getConfig } from './data/config.js';
import {
  initializeCatalogService,
  getCatalogVersion,
  getAllViewItems,
  buildLegacyProductsFromViewItems
} from './services/index.js';

/*
  Frontend mínimo para listagem, carrinho e envio por WhatsApp.
  Arquivo gerado automaticamente durante implementação inicial.
  Edite `data/config.json` para alterar telefone da loja, textos e mensagens.
*/
(async function () {
  const CART_KEY = 'oba_cart_v1';
  let config = { storePhone: '', storeName: 'Oba Doceria', welcomeText: '', phoneHint: '', whatsappPrompt: '' };

  // Estado centralizado
  const state = {
    cart: loadCart(),
    products: [],
    boxes: {
      'cx001': { capacity: 4, currentItems: 0 },
      'cx002': { capacity: 6, currentItems: 0 },
      'cx003': { capacity: 12, currentItems: 0 }
    }
  };

  function qs(sel) { return document.querySelector(sel); }
  function qsa(sel) { return Array.from(document.querySelectorAll(sel)); }

  function formatCurrency(v) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(v);
  }

  function sanitizeText(s) {
    return String(s).replace(/[<>]/g, '');
  }

  function saveCart(cart) { localStorage.setItem(CART_KEY, JSON.stringify(cart)); }
  function loadCart() { try { return JSON.parse(localStorage.getItem(CART_KEY)) || {}; } catch { return {}; } }

  function buildLayout() {
    if (qs('#oba-root')) return;
    const root = document.createElement('div');
    root.id = 'oba-root';
    root.innerHTML = `
      <section class="oba-intro">
        <header>
          <h1>${sanitizeText(config.storeName)}</h1>
          <p>${sanitizeText(config.welcomeText)}</p>
          <div style="margin-top:8px;"><button id="oba-run-diagnostics" class="oba-diagnose">Executar Diagnóstico</button></div>
        </header>
      </section>
      <section id="oba-products" class="oba-products"></section>
      <aside id="oba-cart" class="oba-cart">
        <h3>Carrinho</h3>
        <div id="oba-cart-list"></div>
        <div id="oba-cart-total"></div>
        <form id="oba-checkout-form" class="oba-checkout-form">
          <input name="nome" placeholder="Seu nome" required />
          <input name="telefone" placeholder="Telefone (ex: 11999998888)" required />
          <div class="oba-field-hint">${sanitizeText(config.phoneHint)}</div>
          <input name="endereco" placeholder="Endereço (opcional)" />
          <button type="button" id="oba-send-whatsapp">Enviar por WhatsApp</button>
        </form>
      </aside>
    `;
    document.body.appendChild(root);
  }

  function showDiagnostics(results) {
    let panel = qs('#oba-diagnostics');
    if (!panel) {
      panel = document.createElement('div');
      panel.id = 'oba-diagnostics';
      panel.className = 'oba-diagnostics';
      document.body.appendChild(panel);
    }
    panel.innerHTML = '';
    const title = document.createElement('h4');
    title.textContent = 'Resultados do Diagnóstico';
    panel.appendChild(title);
    const pre = document.createElement('pre');
    pre.style.maxHeight = '320px';
    pre.style.overflow = 'auto';
    pre.textContent = JSON.stringify(results, null, 2);
    panel.appendChild(pre);
    const close = document.createElement('button');
    close.textContent = 'Fechar';
    close.addEventListener('click', () => panel.remove());
    panel.appendChild(close);
  }

  async function runDiagnostics() {
    const btn = qs('#oba-run-diagnostics');
    if (!btn) return;
    btn.disabled = true;
    const original = btn.textContent;
    btn.textContent = 'Executando...';
    try {
      const mod = await import('./data/test.js');
      const results = await (mod.runDataTests ? mod.runDataTests() : window.runDataTests());
      showDiagnostics(results);
    } catch (err) {
      showDiagnostics([{ name: 'error', success: false, error: String(err) }]);
    } finally {
      btn.disabled = false;
      btn.textContent = original;
    }
  }

  function renderProducts(products) {
    const container = qs('#oba-products');
    container.innerHTML = '';
    products.forEach(p => {
      const card = document.createElement('article');
      card.className = 'oba-product';
      const imgMarkup = p.img ? `<img src="${sanitizeText(p.img)}" alt="${sanitizeText(p.nome)}" />` : '<div class="oba-image-placeholder">Imagem não disponível</div>';
      const disabled = !p.disponivel ? 'disabled' : '';
      const buttonText = p.disponivel ? 'Adicionar' : 'Indisponível';
      card.innerHTML = `
        ${imgMarkup}
        <h4>${sanitizeText(p.nome)}</h4>
        <div class="oba-price">${formatCurrency(p.preco)}</div>
        <div class="oba-actions">
          <button data-id="${p.id}" class="oba-add" ${disabled}>${buttonText}</button>
        </div>
      `;
      container.appendChild(card);
    });
    qsa('.oba-add').forEach(btn => btn.addEventListener('click', onAdd));
  }

  function onAdd(e) {
    const id = e.currentTarget.dataset.id;
    const product = state.products.find(p => p.id === id);

    if (!product) return;

    // Lógica de travas de capacidade para caixas
    if (product.type === 'caixa') {
      const box = state.boxes[product.id];
      if (box && box.currentItems >= box.capacity) {
        alert(`A caixa ${product.name} já está cheia!`);
        return;
      }
      if (box) box.currentItems++;
    }

    state.cart[id] = (state.cart[id] || 0) + 1;
    saveCart(state.cart);
    renderCart(state.products, state.cart);
  }

  function renderCart(products, cart) {
    const list = qs('#oba-cart-list');
    const totalEl = qs('#oba-cart-total');
    list.innerHTML = '';
    let total = 0;
    for (const id of Object.keys(cart)) {
      const qty = cart[id];
      const p = products.find(x => x.id === id);
      if (!p) continue;
      const subtotal = qty * p.preco;
      total += subtotal;
      const row = document.createElement('div');
      row.className = 'oba-cart-row';
      row.innerHTML = `${qty}x ${sanitizeText(p.nome)} â€” ${formatCurrency(subtotal)} <button data-id="${id}" class="oba-remove">-</button>`;
      list.appendChild(row);
    }
    totalEl.textContent = 'Total: ' + formatCurrency(total);
    qsa('.oba-remove').forEach(btn => btn.addEventListener('click', e => {
      const id = e.currentTarget.dataset.id;
      const product = state.products.find(p => p.id === id);
      if (!product) return;

      if (state.cart[id]) {
        state.cart[id]--;
        if (state.cart[id] <= 0) {
          delete state.cart[id];
        }

        // Lógica de travas de capacidade para caixas
        if (product.type === 'caixa') {
          const box = state.boxes[product.id];
          if (box && box.currentItems > 0) {
            box.currentItems--;
          }
        }
      }
      saveCart(state.cart);
      renderCart(products, state.cart);
    }));
  }

  function validatePhone(s) {
    const digits = String(s).replace(/\D/g, '');
    return digits.length >= 10 && digits.length <= 13 ? digits : null;
  }

  function buildWhatsAppMessage(products, cart, customer) {
    const lines = [];
    lines.push('Pedido - Oba Doceria');
    lines.push('---');
    let total = 0;
    for (const id of Object.keys(cart)) {
      const qty = cart[id];
      const p = products.find(x => x.id === id);
      if (!p) continue;
      const subtotal = qty * p.preco;
      total += subtotal;
      lines.push(`${qty}x ${p.nome} - ${formatCurrency(p.preco)} (subtotal ${formatCurrency(subtotal)})`);
    }
    lines.push('---');
    lines.push('Total: ' + formatCurrency(total));
    lines.push('');
    lines.push('Cliente: ' + sanitizeText(customer.nome));
    lines.push('Telefone: ' + sanitizeText(customer.telefone));
    if (customer.endereco) lines.push('Endereço: ' + sanitizeText(customer.endereco));
    lines.push('');
    lines.push('Por favor confirmar disponibilidade e preço final. Obrigado!');
    return lines.join('\n');
  }

  async function init() {
    await initializeCatalogService();

    console.info(
      '[Cardápio] Modelo Mestre inicializado:',
      getCatalogVersion()
    );

    config = await getConfig();
    buildLayout();
    state.products = buildLegacyProductsFromViewItems(getAllViewItems()); // ponte temporaria para a UI legada
    renderProducts(state.products);
    renderCart(state.products, state.cart);

    qs('#oba-send-whatsapp').addEventListener('click', () => {
      const form = qs('#oba-checkout-form');
      const nome = form.nome.value && sanitizeText(form.nome.value.trim());
      const telefoneRaw = form.telefone.value && form.telefone.value.trim();
      const telefone = validatePhone(telefoneRaw);
      const endereco = form.endereco.value && sanitizeText(form.endereco.value.trim());
      if (!nome) return alert('Preencha seu nome.');
      if (!telefone) return alert('Telefone inválido. Use apenas números.');
      const cart = state.cart; // Usa o carrinho do estado
      if (!Object.keys(cart).length) return alert('Seu carrinho está vazio.');
      const msg = buildWhatsAppMessage(state.products, cart, { nome, telefone: telefoneRaw, endereco });
      const encoded = encodeURIComponent(msg);
      const phone = config.storePhone || telefone;
      if (!phone) return alert('Telefone da loja não configurado. Edite data/config.json e preencha storePhone.');
      const url = `https://wa.me/${phone}?text=${encoded}`;
      window.open(url, '_blank');
    });
  }

  // aguarda função getProducts exportada por src/data.js
  try { await init(); } catch (err) { console.error('Erro iniciando app Oba:', err); }

})();
