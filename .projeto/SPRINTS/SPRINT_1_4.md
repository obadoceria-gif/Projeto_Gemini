# Sprint 1.4 — Integração incremental do Catalog Service

**Status:** Em validação

## Objetivo

Inicializar o `Catalog Service` dentro do `src/app.js` sem substituir ainda o fluxo legado de produtos.

## Alterações

- Catalog Service inicializado antes do fluxo legado.
- Versão do Modelo Mestre registrada no Console.
- `getProducts()` e carrinho legado preservados temporariamente.
- Nenhuma alteração na montagem de caixas, checkout ou WhatsApp nesta Sprint.

## Critério de aprovação

1. Diagnóstico automático aprovado.
2. Cardápio principal continua carregando.
3. Console mostra a versão `2026.08.06-baseline`.
4. Nenhum novo erro JavaScript.
5. Commit e push somente depois dos testes.
