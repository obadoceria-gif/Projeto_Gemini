/*
  Frontend mínimo para listagem, carrinho e envio por WhatsApp.
  Arquivo gerado automaticamente durante implementação inicial.
  Edite `STORE_PHONE` para o número da loja no formato E.164 sem sinais (ex: 5511999999999).
*/
(async function () {
  const STORE_PHONE = ''; // <<< EDITE AQUI com o telefone da loja (ex: 5511999999999)
  const CART_KEY = 'oba_cart_v1';

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
      <section id="oba-products" class="oba-products"></section>
      <aside id="oba-cart" class="oba-cart">
        <h3>Carrinho</h3>
        <div id="oba-cart-list"></div>
        <div id="oba-cart-total"></div>
        <form id="oba-checkout-form" class="oba-checkout-form">
          <input name="nome" placeholder="Seu nome" required />
          <input name="telefone" placeholder="Telefone (ex: 11999998888)" required />
          <input name="endereco" placeholder="Endereço (opcional)" />
          <button type="button" id="oba-send-whatsapp">Enviar por WhatsApp</button>
        </form>
      </aside>
    `;
    document.body.appendChild(root);
  }

  function renderProducts(products) {
    const container = qs('#oba-products');
    container.innerHTML = '';
    products.forEach(p => {
      const card = document.createElement('article');
      card.className = 'oba-product';
      card.innerHTML = `
        <h4>${sanitizeText(p.nome)}</h4>
        <div class="oba-price">${formatCurrency(p.preco)}</div>
        <div class="oba-actions">
          <button data-id="${p.id}" class="oba-add">Adicionar</button>
        </div>
      `;
      container.appendChild(card);
    });
    qsa('.oba-add').forEach(btn => btn.addEventListener('click', onAdd));
  }

  function onAdd(e) {
    const id = e.currentTarget.dataset.id;
    const cart = loadCart();
    cart[id] = (cart[id] || 0) + 1;
    saveCart(cart);
    renderCart(window.__oba_products || [], cart);
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
      row.innerHTML = `${qty}x ${sanitizeText(p.nome)} — ${formatCurrency(subtotal)} <button data-id="${id}" class="oba-remove">-</button>`;
      list.appendChild(row);
    }
    totalEl.textContent = 'Total: ' + formatCurrency(total);
    qsa('.oba-remove').forEach(btn => btn.addEventListener('click', e => {
      const id = e.currentTarget.dataset.id;
      const cart = loadCart();
      if (!cart[id]) return;
      cart[id] = cart[id] - 1;
      if (cart[id] <= 0) delete cart[id];
      saveCart(cart);
      renderCart(products, cart);
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
    buildLayout();
    const products = await (window.__oba_products = (await (typeof getProducts === 'function' ? getProducts() : Promise.resolve([]))));
    renderProducts(products);
    renderCart(products, loadCart());

    qs('#oba-send-whatsapp').addEventListener('click', () => {
      const form = qs('#oba-checkout-form');
      const nome = form.nome.value && sanitizeText(form.nome.value.trim());
      const telefoneRaw = form.telefone.value && form.telefone.value.trim();
      const telefone = validatePhone(telefoneRaw);
      const endereco = form.endereco.value && sanitizeText(form.endereco.value.trim());
      if (!nome) return alert('Preencha seu nome.');
      if (!telefone) return alert('Telefone inválido. Use apenas números.');
      const cart = loadCart();
      if (!Object.keys(cart).length) return alert('Seu carrinho está vazio.');
      const msg = buildWhatsAppMessage(products, cart, { nome, telefone: telefoneRaw, endereco });
      const encoded = encodeURIComponent(msg);
      const phone = STORE_PHONE || telefone; // se loja não configurada, abre para o próprio cliente (útil para debug)
      if (!phone) return alert('Telefone da loja não configurado. Edite src/app.js e preencha STORE_PHONE.');
      const url = `https://wa.me/${phone}?text=${encoded}`;
      window.open(url, '_blank');
    });
  }

  // aguarda função getProducts exportada por src/data.js
  try { await init(); } catch (err) { console.error('Erro iniciando app Oba:', err); }

})();
