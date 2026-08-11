# Plano Mestre — Cardápio Virtual Oba Doceria

**Versão:** 2026-08-11-realinhamento
**Status:** aprovado para realinhamento técnico e visual

## Objetivo
Construir o Cardápio Virtual da Oba Doceria preservando a experiência moderna já existente e substituindo progressivamente dados e regras hardcoded por uma arquitetura orientada a dados, validável, automatizada e sustentável.

## Princípio central
O projeto NÃO será reconstruído visualmente do zero. A interface moderna já existente passa a ser a referência oficial de UX/UI.

## Arquitetura alvo
Modelo Mestre → Loader → Validator → Catalog Service → View Model → Interface Oficial Moderna → Carrinho → Checkout → WhatsApp / integrações.

## Fases
### Fase 0 — Realinhamento
- congelar a interface mínima como laboratório técnico;
- preservar Catalog Service, View Model, loader, validator, diagnósticos e governança;
- registrar a UI oficial como referência de produto;
- não continuar evoluindo visualmente a interface mínima.

### Fase 1 — Recuperação da UI oficial
- incorporar a interface moderna ao projeto;
- executar localmente;
- validar paridade visual e funcional com a versão publicada;
- preservar navegação, modais, fluxo de caixas, filtros, fotos, carrinho e checkout.

### Fase 2 — Integração progressiva com o Modelo Mestre
- substituir `caixasConfigs`;
- substituir `catalogo`;
- substituir `kitsPresenteaveis`;
- substituir URLs e configurações comerciais hardcoded;
- conectar a UI ao Catalog Service sem regressão visual.

### Fase 3 — Regras e serviços
- capacidade de caixas;
- limite de sabores;
- preços;
- disponibilidade;
- opcionais;
- pedidos;
- WhatsApp;
- integrações externas.

### Fase 4 — Eliminação do legado
- remover dados duplicados;
- remover funções obsoletas;
- remover código de transição;
- garantir fonte única de verdade.

### Fase 5 — Automação e qualidade
- diagnósticos automáticos;
- validação de catálogo;
- validação de assets;
- smoke tests;
- pré-deploy automatizado;
- checklist de regressão.

### Fase 6 — Polimento e deploy
- responsividade;
- acessibilidade;
- performance;
- revisão visual;
- deploy controlado;
- validação em produção.
