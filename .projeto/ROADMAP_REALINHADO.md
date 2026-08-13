# Roadmap Realinhado

## R0 — Realinhamento
Concluído.

## R1 — Marco Zero da UI oficial
### R1.1 Proteção
- [x] produção definida como intocável;
- [x] branch de integração criada.

### R1.2 Cópia segura
- [ ] clonar `cardapio/main` somente para leitura;
- [ ] registrar hash do commit;
- [ ] copiar snapshot para `ui-oficial/`;
- [ ] não sobrescrever root.

### R1.3 Validação local
- [ ] abrir `/ui-oficial/`;
- [ ] comparar com GitHub Pages;
- [ ] validar imagens, navegação, modais, carrinho e checkout.

### R1.4 Marco Zero
- [ ] registrar aprovação;
- [ ] checkpoint Git do snapshot;
- [ ] iniciar integração arquitetural.

## R2–R8
Caixas → sabores → kits → carrinho → checkout → integrações → limpeza → deploy.

---

## R1.4-A - CONCLUIDA

- Integracao das caixas com o Modelo Mestre: concluida.
- Validacao funcional: concluida.
- Validacao visual: concluida.
- Proxima etapa: R1.4-B - integrar sabores, categorias, precos e imagens.

---

## R1.5 - INTEGRACAO REAL DE PEDIDOS - CONCLUIDA

Status: CONCLUIDA E VALIDADA.

Entregas confirmadas:

- Schema V2 de pedidos;
- endpoint do Modelo Mestre;
- integracao Google Apps Script;
- registro na aba Pedidos;
- registro detalhado na aba Itens_Pedido;
- suporte a pedidos com multiplos itens;
- totalizacao de caixas;
- WhatsApp integrado ao mesmo fluxo;
- teste real ponta a ponta aprovado;
- validacao de integridade do repositorio.

Resultado arquitetural:

`UI -> Schema V2 -> Apps Script -> Google Sheets -> WhatsApp`

A R1.5 passa a ser considerada baseline funcional para a proxima etapa.

### Proxima macroetapa

R1.6 - evolucao controlada da UI sobre a baseline funcional validada.
