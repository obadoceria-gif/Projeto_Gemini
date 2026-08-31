# FASE 8E.9D-A — Rascunho Online

## Estado alvo homologado

Backend privado de RASCUNHO:

- GET /api/draft
- POST /api/draft
- autenticacao obrigatoria
- CSRF obrigatorio
- SHA-256 server-side
- revisoes imutaveis
- D1 batch
- somente DRAFT pode ser movimentado

Baseline PUBLISHED antes do teste:

pub_c3b7ee083866bb26a7a0b881

A homologacao exige:

- DRAFT = PUBLISHED
- PREVIEW vazio
- PUBLISHED preservado
- uma revisao total
- duas promocoes totais
- evento DRAFT_SAVED
- POST /api/catalog continua 501

O cardapio publico nao e alterado nesta fase.