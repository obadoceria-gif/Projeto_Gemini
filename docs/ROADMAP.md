# ROADMAP

## Concluído

- Cardápio público funcional.
- Central de Gestão construída.
- Central privada online.
- Autenticação e segurança.
- Catálogo online em leitura.
- Imagens existentes disponíveis.
- D1.
- Modelo de revisões e slots.
- Baseline PUBLISHED.
- Backend DRAFT.
- Handoff portátil do projeto.

## Em andamento

### 8E.9D-B — Central -> DRAFT

- carregar DRAFT automaticamente;
- salvar edição no DRAFT;
- arquivar no DRAFT;
- salvar configurações no DRAFT;
- remover escrita direta por endpoints legados.

### 8E.9E — Preview privado

- POST /api/preview;
- GET /api/preview;
- DRAFT -> PREVIEW;
- /__preview autenticado;
- E2E privado;
- PUBLISHED intacto.

## Próximos blocos

### 8E.9F — Publicação segura

- PREVIEW -> PUBLISHED;
- confirmação explícita;
- auditoria;
- smoke;
- rollback automático.

### Rollback operacional

- selecionar última versão válida;
- promover revisão anterior sem apagar histórico.

### Mídia

- integrar upload de imagens ao modelo online;
- manter requisito zero custo/sem cartão.

### Homologação

- E2E completo;
- regressão;
- mobile;
- desktop;
- segurança;
- fluxo do pedido;
- gestão;
- Preview;
- publicação;
- rollback.

### Encerramento

- remover/excluir exposição da Central pública antiga somente após homologação;
- release final;
- documentação final;
- backups finais.
