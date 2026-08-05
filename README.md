# Projeto_Gemini
Projeto com duas contas Gemini (Planejamento e Execução)

## Cardápio Virtual Oba Doceria
Este projeto agora inclui um frontend mínimo para listagem de produtos, carrinho e envio de pedido via WhatsApp.

### Como usar
1. Abra `index.html` em um servidor local ou compartilhe o projeto por GitHub Pages.
2. Edite `data/config.json` para preencher `storePhone` com o número da loja no formato E.164 sem sinais, ex: `5511999999999`.
3. Atualize `data/products.json` para adicionar novos sabores, preços e imagens.
4. Abra a página em um navegador e faça pedidos.

### Estrutura de arquivos
- `index.html` - entrypoint da página.
- `src/styles.css` - estilos do cardápio.
- `src/app.js` - lógica do frontend do carrinho e geração do link do WhatsApp.
- `src/data.js` - loader de catálogo e configuração.
- `data/products.json` - catálogo editável de produtos.
- `data/config.json` - configurações da loja e textos de interface.

### Observações
- O sistema valida preços, mas ainda não possui backend. Confirme disponibilidade e preço final no WhatsApp antes de concluir o pedido.
- Faça sempre backup do estado estável em `.auditoria/v_estavel/` antes de qualquer alteração em produção.
