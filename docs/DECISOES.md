# DECISOES DE ARQUITETURA E UX

## D001 - Mobile First
Status: aprovado

Toda nova interface deve ser projetada primeiro para celular.

Referencias de teste:
- 360px
- 390px
- 430px
- 768px
- 1024px+

Desktop e expansao da experiencia mobile.

---

## D002 - Modelo Mestre
Status: aprovado

Configuracoes comerciais e estruturais devem vir do Modelo Mestre sempre que aplicavel.

Evitar duplicacao de regras no HTML.

---

## D003 - Carrinho unico
Status: aprovado

carrinhoDeCaixasConcluidas permanece como fonte de verdade para itens salvos.

Nao criar mini-carrinhos paralelos.

---

## D004 - Acesso global ao carrinho
Status: aprovado

O carrinho deve ser acessivel por icone global com badge.

O painel grande de carrinho nao deve ocupar permanentemente paginas de selecao.

---

## D005 - Produto selecionado nao significa produto salvo
Status: aprovado

Selecao e apenas estado temporario.

O badge do carrinho so aumenta depois da inclusao real do item.

---

## D006 - Fluxo por etapas
Status: aprovado para R1.17

Mobile deve evoluir para:

Selecao
-> Revisao do produto
-> Carrinho
-> Checkout
-> Finalizacao

---

## D007 - Rolagem
Status: aprovado

Nao tentar proibir toda rolagem.

Regra:
- evitar rolagem para descobrir a proxima acao;
- acoes principais sempre visiveis;
- listas extensas podem ter rolagem interna;
- evitar rolagem vazia.

---

## D008 - Automacao
Status: aprovado

Tudo que puder ser automatizado deve ser automatizado.

Auditorias devem gerar relatorios automaticamente.

Alteracoes de codigo devem ser entregues em blocos completos quando possivel.

---

## D009 - Documentacao obrigatoria
Status: aprovado

Cada baseline aprovada deve atualizar:
- STATUS.md
- CHANGELOG.md
- ROADMAP.md
- DECISOES.md quando aplicavel
- TESTES.md
- REGISTRO-DE-ACOES.md

---

## D010 - Imagens da Degustacao
Status: pendencia de conteudo

Os arquivos:
- Degustacao_12_Sabores.jpeg
- Degustacao_25_Sabores.jpeg

possuem nomes distintos, mas atualmente possuem conteudo identico.

O codigo permanece preparado para imagens distintas.
---

## D011 - Revisao de produto em etapa propria
Status: aprovado

No mobile, quando uma escolha comercial estiver concluida, o resumo e as decisoes seguintes devem preferencialmente ocupar uma etapa propria.

Padrao aprovado na R1.17-A:

Escolha
-> Revisao do produto
-> Acao explicita
-> Carrinho ou continuidade

Beneficios:
- reduz rolagem desnecessaria;
- separa selecao de confirmacao;
- mantem a proxima acao visivel;
- permite reutilizar o padrao em outras categorias.
---

## D012 - Carrinho em viewport com areas persistentes
Status: aprovado

No mobile, o carrinho deve utilizar tres regioes:

1. header persistente;
2. lista central adaptativa;
3. footer persistente.

Quando o conteudo exceder a area disponivel:
- somente a lista de produtos deve rolar;
- total e proximas acoes permanecem visiveis;
- a interface deve indicar explicitamente a existencia de produtos fora da area visivel.

A quantidade de produtos e de unidades deve ser apresentada separadamente.

<!-- R1.17-C-DECISAO -->

## Decisão R1.17-C — Separar carrinho e checkout

### Problema

A combinação de produtos, controles de quantidade e dados de
entrega no mesmo viewport aumentava a densidade visual e
prejudicava a experiência mobile.

### Decisão

O carrinho permanece dedicado à revisão dos itens.

A finalização passa para uma etapa própria contendo:

- resumo;
- total;
- nome;
- data;
- hora;
- pagamento;
- ação final.

### Regra arquitetural

Carrinho e checkout são estados/telas diferentes do fluxo.

### Resultado validado

O usuário consegue revisar o pedido, entrar no checkout,
retornar ao carrinho e finalizar pelo WhatsApp.

---

## D013 - Continuidade explicita entre etapas mobile

Status: aprovado

A navegacao mobile deve informar claramente:
- em qual etapa o usuario esta;
- qual e a proxima acao;
- quando houve retorno para uma etapa anterior.

A orientacao deve ser curta e nao competir com a acao principal.

Fluxos aprovados:
- carrinho -> checkout;
- checkout -> carrinho;
- checkout -> WhatsApp.

O estado comercial do pedido deve ser preservado durante a navegacao entre essas etapas.

## R1.18-C - CONSOLIDACAO FINAL

Data: 2026-08-16 21:39:51

### Resultado
- R1.18-A: auditoria consolidada aprovada.
- 67 checks executados.
- 67 checks aprovados.
- 0 falhas estruturais.
- R1.18-B: regressao funcional aprovada em navegador real.
- Fluxo validado: produto -> carrinho -> checkout -> voltar -> checkout -> WhatsApp.
- Carrinho preservou produtos, quantidades, subtotais e total.
- Checkout preservou o estado comercial.
- Validacoes de entrega verificadas.
- Finalizacao via WhatsApp verificada.
- Nenhum erro funcional observado no console durante a regressao.
- UX mobile consolidada.
- Carrinho em viewport propria consolidado.
- Checkout em etapa propria consolidado.
- Continuidade entre etapas consolidada.

### Decisao
R1.18 consolidada sobre o fluxo oficial.

### Seguranca
- promocao controlada;
- candidato temporario removido;
- documentacao versionada;
- push nao executado.

## Decisão R1.19-B01 — lock de finalização

Foi adotado lock de execução na função oficial de checkout para impedir múltiplos acionamentos do fluxo de finalização.

A solução preserva o fluxo legado e possui fail-safe temporizado para permitir nova tentativa caso a transição externa não prossiga.
## Decisão R1.19-D — confirmação explícita para ações relevantes

Foi rejeitado o padrão experimental de dois toques na lixeira.

Decisão adotada:
- um toque inicia a intenção;
- modal central exige decisão explícita;
- ações destrutivas usam REMOVER ITEM / MANTER ITEM;
- mensagens importantes não desaparecem automaticamente;
- toast permanece reservado para feedback secundário.

A mesma infraestrutura passou a ser reutilizável para decisões futuras.

Também foi definido que regiões marcadas com aria-hidden não podem manter foco em descendentes.
## Decisão R1.20-B01 — zero confirmação nativa

Foi definido que decisões relevantes da jornada não devem utilizar a interface nativa do navegador.

Padrão oficial:
- modal reutilizável da aplicação;
- ação explícita de confirmar;
- ação explícita de cancelar;
- foco e acessibilidade preservados;
- chamadas assíncronas somente quando a decisão precisa interromper o fluxo atual.

Os dois pontos legados foram migrados:
1. saída/descartes de montagem;
2. remoção quando quantidade chega a zero.
============================================================
R1.20-B02 - ZERO alert() NATIVO + FEEDBACK INTEGRADO
Data: 2026-08-17 22:39:23
============================================================

RESULTADO:
- 4 alert() nativos eliminados.
- Checkout sem produtos migrado para feedback integrado.
- Checkout incompleto migrado para feedback integrado.
- Personalizados incompleto migrado para feedback integrado.
- Eventos incompleto migrado para feedback integrado.
- Modal reutilizavel R1.19-D preservado.
- Foco contextual preservado.
- Fluxos WhatsApp de Personalizados e Eventos preservados.

CORRECAO WPP1:
- Identificado window.open() da finalizacao dentro de fetch.finally().
- Adicionado mecanismo robusto de abertura do WhatsApp.
- Primeira tentativa: window.open().
- Fallback: window.location.assign().
- Teste funcional aprovado.
- WhatsApp abriu corretamente ao finalizar pedido.

VALIDACAO:
- alert() nativo restante: 0.
- R1.20-B01 preservado.
- R1.19-D preservado.
- Carrinho preservado.
- Checkout preservado.
- Acessibilidade preservada.
- Teste funcional aprovado.

STATUS:
CONCLUIDO E APROVADO.

PROXIMA ACAO:
R1.20-B03 - PROXIMO ITEM PRIORIZADO DO BACKLOG.
============================================================
## R1.20-B03 — asset Degustação 25 Sabores

Data: 2026-08-17 23:51:03

Status: encerrado tecnicamente / pendência externa de conteúdo.

Diagnóstico:
- Degustacao_12_Sabores.jpeg e Degustacao_25_Sabores.jpeg possuem conteúdo binário idêntico;
- inventário visual completo do ui-desenvolvimento analisado;
- 82 imagens físicas;
- 81 conteúdos únicos;
- nenhuma fotografia correta da Caixa Degustação 25 Sabores foi localizada.

Decisão:
- não reutilizar conscientemente a fotografia da caixa de 12 sabores como solução definitiva;
- não gerar ou inventar fotografia substituta;
- não substituir por asset sem autenticação;
- manter a referência atual até que a fotografia oficial correta seja fornecida;
- classificar a correção como dependência externa de conteúdo, não como bloqueio técnico.

Próxima ação:
R1.20-B04 — próximo gap técnico real do backlog.