# Como Funciona o Cardápio Virtual

## Interface principal

ui-desenvolvimento/index.html

## Catálogo canônico

data/catalog-v1/

Arquivos:

- config.json
- categories.json
- flavors.json
- boxes.json
- products.json
- options.json
- combos.json

## Central

Interface: manutencao-cardapio/index.html

Servidor: .scripts/CARDAPIO-central-local.ps1

Publicador: .scripts/CARDAPIO-publicar-catalogo.ps1

## Fluxo de montagem

Escolher caixa -> escolher doces -> atingir mínimo -> revisar -> salvar -> registrar caixa -> abrir carrinho.

## Fluxo de edição

Carrinho -> Editar caixa -> alterar -> Salvar alterações -> substituir item -> retornar ao carrinho.

## Estado de edição

Ao concluir uma edição, o estado local e o índice global devem ser encerrados.

Isso evita a permanência indevida de EDITANDO CAIXA.

## Regra comercial

Mínimo: 25 doces.

Acima de 25 é permitido continuar.

## Publicação

A publicação é validada pelo GitHub, GitHub Pages, catálogo JSON e imagens.

## Release funcional

Commit: 60fe160

Tag: cardapio-final-homologado-20260828-144517
