# Roadmap de Implementação — Oba Doceria

## Fase 1: Desacoplamento de Dados e Estruturação (Prioridade Alta)
- [ ] **Etapa 1.1:** Criar `src/data.js` extraindo catálogos, caixas e kits do script monolítico.
- [ ] **Etapa 1.2:** Modularizar a estrutura de arquivos em `src/app.js` e `src/styles.css`.
- [ ] **Etapa 1.3:** Limpar o `index.html` mantendo apenas a marcação base e chamadas de scripts.

## Fase 2: Gerenciamento de Estado e Carrinho (Prioridade Alta)
- [ ] **Etapa 2.1:** Implementar o objeto de estado central (`state`) para caixa ativa e seleção de sabores.
- [ ] **Etapa 2.2:** Centralizar cálculos do carrinho e reescrever o fluxo de checkout via WhatsApp.

## Fase 3: Componentização e UI (Prioridade Média)
- [ ] **Etapa 3.1:** Substituir modais e alertas padrão (`alert`/`confirm`) por notificações visuais (toasts).
- [ ] **Etapa 3.2:** Ajustar responsividade do rodapé e navegação mobile.
