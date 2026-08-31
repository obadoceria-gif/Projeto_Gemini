# FASE 8E.9B — D1 Persistente

## Resultado

O banco D1 `oba-cardapio-catalogo` foi criado anteriormente e
reutilizado com seguranca na recuperacao R1A.

Binding:

`DB`

Migration aplicada:

`0001_catalog_states.sql`

## Estrutura validada

- catalog_revisions
- catalog_slots
- catalog_promotions

Slots:

- DRAFT
- PREVIEW
- PUBLISHED

## Estado inicial

- DRAFT vazio
- PREVIEW vazio
- PUBLISHED vazio
- zero revisoes
- zero promocoes

## Incidentes recuperados

A primeira tentativa enviou um database_id invalido formado por
multiplos UUIDs concatenados.

A tentativa R1 detectou ainda um residuo local do wrangler.jsonc
apos restauracao simples.

A R1A realizou restauracao explicita do arquivo tanto no indice
quanto no working tree antes de reconstruir o binding.

Depois disso:

- o banco foi localizado pelo nome exato;
- exatamente um objeto D1 foi aceito;
- exatamente um UUID valido foi aceito;
- nenhum novo banco foi criado;
- a migration foi aplicada somente apos dry-run aprovado.

## Garantias

- nenhum deploy do Worker;
- nenhuma publicacao de catalogo;
- nenhuma revisao criada nesta fase;
- nenhum DNS alterado;
- cardapio publico preservado.

## Proxima fase

FASE 8E.9C — baseline publicada imutavel.