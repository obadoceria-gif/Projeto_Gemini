# Roadmap de Implementaзгo - Cardбpio Interativo Oba Doceria (V2 Aprimorada)

## Regra do Fluxo: Toda etapa exige aprovaзгo expressa do usuбrio antes do cуdigo ser alterado.

### [Concluído] Fase 1: Backup da Versão Estável e Desacoplamento de Dados
- [x] **Etapa 1.0 (Segurança):** Criar snapshot de segurança do cardápio atual em `.auditoria/v_estavel/`.
- [x] **Etapa 1.1:** Estruturar `src/data.js` com catálogo completo de caixas (4, 6, 12 un.), kits presenteáveis (mini naked cake, uvas verdes, morangos) e opcionais.
- [x] **PAUSA PARA REVISÃO DO USUÁRIO:** Aguardar aprovação dos dados de `src/data.js`.

### [Concluído] Fase 2: Lógica do Carrinho e Regras de Negócio
- [x] **Etapa 2.1:** Implementar estado centralizado (`state`) com travas de capacidade de itens por caixa.
- [x] **Etapa 2.2:** Integrar cálculo de totais e formatar pedido para envio via WhatsApp.
- [x] **PAUSA PARA REVISÃO DO USUÁRIO:** Validar o fluxo de checkout antes dos estilos visuais.

### [Pendente] Fase 3: Interface Visualmente Elegante
- [ ] **Etapa 3.1:** Estilizar vitrine de produtos e seletores de sabor com responsividade mobile.
- [ ] **PAUSA PARA REVISÃO FINAL:** Validação de aceite do projeto.

### [Pendente] Fase 4: Otimização e Deploy
- [ ] **Etapa 4.1:** Otimizar performance e realizar testes de usabilidade.
- [ ] **Etapa 4.2:** Preparar para deploy e documentar processo.
- [ ] **PAUSA PARA REVISÃO FINAL:** Validação de aceite do projeto e deploy.
