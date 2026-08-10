# STATUS OFICIAL DO PROJETO

**Última atualização:** 2026-08-10

## Situação geral

Projeto em desenvolvimento ativo.

Branch de trabalho:
`feature/cardapio-whatsapp-20260805-0004`

Live Server do Cardápio:
`http://127.0.0.1:5501/`

## Concluído

### Governança
- [x] Pasta `.projeto`.
- [x] Modelo Mestre.
- [x] Marco Zero.
- [x] Git/GitHub operacionais.

### Catálogo
- [x] Loader.
- [x] Validator.
- [x] View Model.
- [x] Catalog Service.

### Diagnósticos
- [x] `catalog-check.html`.
- [x] `view-model-check.html`.
- [x] `catalog-service-check.html`.

### Ambiente
- [x] Live Server funcionando.
- [x] Porta 5501 registrada.

## Em andamento

### Governança 0.1
- [ ] Consolidar Plano Mestre.
- [ ] Consolidar Metodologia.
- [ ] Consolidar Automação.
- [ ] Criar diagnóstico da governança.

## Próxima tarefa técnica

Sprint 1.4:

Inicializar o `Catalog Service` dentro do `src/app.js` sem substituir ainda o fluxo legado de produtos.

## Não fazer ainda

- não remover `src/data.js`;
- não substituir `app.js` inteiro;
- não implementar montagem de caixas;
- não alterar checkout;
- não alterar deploy;
- não excluir código legado sem commit de segurança.
