# FASE 8E.9C — Baseline Publicada Imutavel

## Resultado

A versao homologada atual foi registrada como primeira revisao
imutavel do catalogo no D1.

Revision ID:

pub_c3b7ee083866bb26a7a0b881

SHA-256:

c3b7ee083866bb26a7a0b8818d5db241b729bba9a1d1e41fdee415585dad60f7

## Conteudo

A revisao contem as sete entidades canonicas:

- sabores
- categorias
- caixas
- produtos
- opcionais
- combos
- loja

## Estado

DRAFT:

vazio

PREVIEW:

vazio

PUBLISHED:

pub_c3b7ee083866bb26a7a0b881

Revisoes:

1

Promocoes:

1

## Compatibilidade D1

A tentativa inicial utilizou BEGIN TRANSACTION e COMMIT em um
arquivo executado remotamente pelo Wrangler.

O D1 remoto rejeitou esses statements de controle transacional.

A recuperacao R1 removeu BEGIN/COMMIT e enviou os tres statements
como um unico batch D1.

## Garantias

- revisao imutavel;
- SHA-256 deterministico;
- PUBLISHED inicializado;
- DRAFT preservado vazio;
- PREVIEW preservado vazio;
- zero endpoint de escrita habilitado;
- zero deploy do Worker;
- zero alteracao visual publica;
- cardapio publico preservado.

## Proxima fase

FASE 8E.9D — RASCUNHO ONLINE.

A escrita administrativa passara a criar novas revisoes
imutaveis e mover somente o slot DRAFT.