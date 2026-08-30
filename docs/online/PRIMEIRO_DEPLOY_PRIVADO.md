# Primeiro deploy da Central privada

## Baseline

Branch: feature/gestao-online-segura
HEAD de origem: 5ae0d7b
Worker: oba-cardapio-gestao
Estado remoto observado: NAO_CONFIRMADO_OU_AINDA_NAO_EXISTE

## Protecoes obrigatorias

- workers_dev = false
- preview_urls = false
- nenhuma rota publica configurada
- nenhum dominio Cloudflare atualmente disponivel
- nenhum segredo administrativo no navegador
- security gate obrigatorio antes de deploy

## Estrategia

O primeiro deploy cria/atualiza somente o recurso Worker.

Ele nao deve:

- ativar workers.dev;
- criar rota publica;
- alterar DNS;
- alterar o cardapio publico;
- remover a Central local;
- remover a Central antiga antes da homologacao privada.

Depois do Worker existir, a proxima etapa deve validar seu estado
remoto e preparar Cloudflare Access antes de qualquer superficie
publica de acesso.

## Ordem segura

1. checkpoint;
2. security gate;
3. dry-run;
4. deploy do Worker sem rota publica;
5. confirmar workers.dev desabilitado;
6. confirmar ausencia de rotas;
7. confirmar ausencia de URL publica funcional;
8. preparar Cloudflare Access;
9. somente depois definir dominio/rota privada;
10. homologar login;
11. posteriormente retirar a Central antiga do GitHub Pages.

## Rollback

O cardapio publico e a Central local permanecem independentes.
Nenhuma etapa deste primeiro deploy pode substituir a producao
publica existente.
