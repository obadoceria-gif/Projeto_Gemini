<!-- CARDAPIO_DOCS_START -->

# COMECE AQUI — Manual, Tira-Dúvidas e Manutenção

Para usar, entender ou manter o Cardápio Virtual Oba Doceria, comece por:

**[docs/INDICE_DOCUMENTACAO.md](docs/INDICE_DOCUMENTACAO.md)**

A partir desse índice você encontra:

- Manual de uso;
- Guia tira-dúvidas;
- Como funciona o cardápio;
- Como alterar sabores;
- Como alterar preços;
- Como alterar imagens;
- Como publicar alterações;
- Como recuperar backups.

## Referência funcional protegida

- Release funcional: `60fe160`
- Tag funcional: `cardapio-final-homologado-20260828-144517`

Novas mudanças devem ser tratadas como manutenção ou evolução, preservando essa release como referência segura.

<!-- CARDAPIO_DOCS_END -->

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
