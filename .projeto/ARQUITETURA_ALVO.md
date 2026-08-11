# Arquitetura Alvo

## Dados
`data/catalog-v1/` — caixas, sabores, categorias, presenteáveis, opcionais e configuração comercial.

## Catálogo
`src/catalog/` — carregar, validar, normalizar e montar View Model.

## Serviços
`src/services/` — disponibilizar dados para a aplicação e evitar leitura direta de JSON pela UI.

## Interface
UI moderna reaproveitada. A UI não deve conhecer a estrutura bruta dos JSONs; deve consumir serviços/View Model.

## Integrações
WhatsApp, Google Sheets ou substituto futuro, assets e configurações externas.

## Fonte única de verdade
Dados comerciais devem existir em um único lugar.
