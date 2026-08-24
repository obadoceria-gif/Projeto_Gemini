# Arquitetura Alvo

## Camada 1 — Dados
`data/catalog-v1/`

Responsável por dados comerciais e configuração.

## Camada 2 — Catálogo
`src/catalog/`

Responsável por:
- carregar;
- validar;
- normalizar;
- montar View Model.

## Camada 3 — Serviços
`src/services/`

Responsável por expor dados e regras de acesso para a UI.

## Camada 4 — UI oficial
Interface moderna recuperada do projeto publicado.

A UI deve consumir serviços/View Model e não ler diretamente a estrutura bruta dos JSONs.

## Camada 5 — Operação
- carrinho;
- checkout;
- WhatsApp;
- integrações.

## Resultado desejado

UI moderna desacoplada dos dados comerciais.
