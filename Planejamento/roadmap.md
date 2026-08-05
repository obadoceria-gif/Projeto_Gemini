# Roadmap de Implementação - Cardápio Interativo Oba Doceria (V2 Aprimorada)

## Regra do Fluxo: Toda etapa exige aprovação expressa do usuário antes do código ser alterado.

### [Aguardando Aprovação] Fase 1: Backup da Versão Estável e Desacoplamento de Dados
- [ ] **Etapa 1.0 (Segurança):** Criar snapshot de segurança do cardápio atual em `.auditoria/v_estavel/`.
- [ ] **Etapa 1.1:** Estruturar `src/data.js` com catálogo completo de caixas (4, 6, 12 un.), kits presenteáveis (mini naked cake, uvas verdes, morangos) e opcionais.
- [ ] **PAUSA PARA REVISÃO DO USUÁRIO:** Aguardar aprovação dos dados de `src/data.js`.

### [Pendente] Fase 2: Lógica do Carrinho e Regras de Negócio
- [ ] **Etapa 2.1:** Implementar estado centralizado (`state`) com travas de capacidade de itens por caixa.
- [ ] **Etapa 2.2:** Integrar cálculo de totais e formatar pedido para envio via WhatsApp.
- [ ] **PAUSA PARA REVISÃO DO USUÁRIO:** Validar o fluxo de checkout antes dos estilos visuais.

### [Pendente] Fase 3: Interface Visualmente Elegante
- [ ] **Etapa 3.1:** Estilizar vitrine de produtos e seletores de sabor com responsividade mobile.
- [ ] **PAUSA PARA REVISÃO FINAL:** Validação de aceite do projeto.
