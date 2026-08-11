# Decisão Técnica — Realinhamento da UI

**Data:** 2026-08-11

## Problema
A interface mínima de transição passou a ser tratada indevidamente como base visual do produto, provocando regressão de UX e duplicação de trabalho.

## Decisão
A interface mínima deixa de ser candidata a interface final. A UI moderna já publicada passa a ser a referência oficial de:
- identidade visual;
- navegação;
- fluxo de caixas;
- seleção de sabores;
- presenteáveis;
- personalizados;
- eventos;
- carrinho;
- checkout;
- WhatsApp.

## Preservar do projeto novo
- Modelo Mestre;
- catálogo versionado;
- loader;
- validator;
- View Model;
- Catalog Service;
- diagnósticos;
- governança;
- automações.

## Reaproveitar da UI anterior
- páginas de boas-vindas;
- Nossa Essência;
- seleção de experiências;
- modais;
- seleção de tamanho;
- filtros de sabores;
- cards com fotos;
- montagem de caixas;
- carrinho;
- checkout;
- fluxo de WhatsApp.

## Remover progressivamente da UI anterior
- `catalogo` hardcoded;
- `caixasConfigs` hardcoded;
- `kitsPresenteaveis` hardcoded;
- configurações comerciais hardcoded;
- URLs comerciais espalhadas;
- regras duplicadas.

## Resultado
Preservar a carroceria visual e substituir o motor de dados.
