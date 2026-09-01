# HANDOFF

Atualizado: 2026-08-31 22:39:10

## Comece aqui

Projeto:
Oba Doceria — Cardápio Virtual + Central de Gestão.

Branch:
feature/gestao-online-segura

Baseline técnica atual:
c4d4c2d

## Última fase aprovada

8E.9D-A — RASCUNHO ONLINE.

Resultado:

- GET /api/draft;
- POST /api/draft;
- autenticação;
- CSRF;
- SHA-256;
- D1 batch;
- revisão imutável;
- DRAFT = PUBLISHED baseline;
- GitHub sincronizado.

## Fase em andamento

8E.9D-B + 8E.9E.

Objetivo:

Central -> DRAFT -> PREVIEW privado.

## Último blocker

Patch local do Preview gerou JavaScript inválido:

SyntaxError: Invalid regular expression: missing /

A falha ocorreu antes de deploy.

Arquivos foram restaurados.

Não houve D1 write nem alteração PUBLISHED.

## Blocker operacional adicional

PSReadLine apresentou ArgumentOutOfRangeException ao receber blocos muito grandes por Ctrl+V.

Não voltar a usar scripts gigantes diretamente no console.

## Arquivos críticos

- online/gestao/src/index.js
- online/gestao/public/index.html
- online/gestao/wrangler.jsonc
- online/gestao/tests/
- data/catalog-v1/
- docs/CURRENT_STATE.md
- docs/DECISIONS.md
- docs/ROADMAP.md

## Regras críticas

1. Não alterar PUBLISHED diretamente.
2. DRAFT -> PREVIEW -> PUBLISHED.
3. Checkpoint antes de cloud write.
4. Testes/build antes de deploy.
5. Rollback/fail-closed em falha.
6. Não versionar secrets.
7. Usar C:\Program Files\nodejs\npx.cmd.
8. Zero custo e sem cartão.
9. Cardápio público deve permanecer intacto durante desenvolvimento.

## Próximos passos

1. Reimplementar Central -> DRAFT usando script persistente.
2. Implementar PREVIEW no Worker sem regex problemática.
3. Rodar Node check + gates + Wrangler dry-run.
4. Deploy privado + E2E.
5. Homologar PREVIEW mantendo PUBLISHED intacto.

Depois:

8E.9F — PREVIEW -> PUBLISHED + rollback.
