# STATUS DO PROJETO

## Projeto
Cardapio Virtual Interativo & Atendimento via WhatsApp

## Estado atual
- Branch ativa: feature/integracao-ui-oficial-modelo-mestre
- Baseline oficial: R1.17-A
- Commit da baseline: 19d0395b49d601bcffb024093136892cf866683b
- UI oficial: ui-desenvolvimento/index.html
- Estado Git na consolidacao documental: workspace limpo
- Push da R1.16-K: ainda nao executado

## Principios permanentes
- Mobile First
- Modelo Mestre como fonte de verdade para configuracoes
- Git como historico tecnico
- ChatGPT como arquiteto, desenvolvedor e revisor
- Automacao como regra preferencial
- Zero edicao manual quando houver alternativa automatizavel
- Alteracoes de codigo entregues em blocos completos
- Baseline autenticada antes de qualquer alteracao
- Aprovacao funcional antes de promocao
- Documentacao atualizada junto com cada promocao
- Nenhum commit ou push silencioso
- Testes mobile, desktop e console registrados

## R1.16 - concluido
Principais entregas:
- Integracao das caixas ao Modelo Mestre
- Protecao da inicializacao das caixas
- Correcao de undefined na caixa de degustacao
- Modal de quantidade para doces
- UX de degustacao revisada
- Lightbox e comparacao 12/25
- Mobile First para degustacao
- Carrinho global com badge
- Carrinho unico como fonte de verdade
- Eliminacao do painel grande de carrinho nas telas
- Degustacao adicionada diretamente ao carrinho
- Caixa normal adicionada diretamente ao carrinho ao concluir
- Eliminacao do modal intermediario no fluxo automatico
- Modal completo do carrinho mantido como centro do pedido

## Pendencias conhecidas
- As imagens Degustacao_12_Sabores.jpeg e Degustacao_25_Sabores.jpeg possuem nomes distintos, mas conteudo identico
- Push da baseline R1.16-K ainda pendente
- UX mobile ainda precisa evoluir para fluxo por etapas
- Carrinho precisa ser refinado para muitos itens sem perder acoes principais
- Checkout deve ser separado da revisao do carrinho

## Proxima fase
R1.17 - Fluxo Mobile por Etapas (em andamento)

Objetivos:
1. Tela de selecao sem rolagem desnecessaria
2. Revisao de produto em tela propria
3. Carrinho com header e footer persistentes
4. Apenas a lista de itens rolavel quando necessario
5. Checkout separado do carrinho
6. Aplicar a mesma logica a degustacao e caixas normais
7. Prioridade para telas 360px, 390px e 430px

## Proxima acao
Iniciar R1.17-B: carrinho em viewport com header/footer persistentes.
## R1.17-A - aprovado
Entregas:
- Caixa Degustacao convertida para fluxo mobile por etapas
- Etapa 1 dedicada a escolha 12/25
- Etapa 2 dedicada a revisao
- Selecao nao salva automaticamente no carrinho
- Acoes de salvar, ver carrinho, finalizar e voltar separadas
- Uso de 100dvh para controlar a viewport mobile
- Eliminacao da rolagem vazia no fluxo de Degustacao
- Opcao preservada ao voltar para alterar

Status:
APROVADO E PROMOVIDO.

Proxima acao:
R1.17-B - Carrinho em viewport.
## R1.17-B - aprovado

Status:
APROVADO E PROMOVIDO.

Entregas:
- carrinho em viewport mobile dedicada;
- header do carrinho permanentemente visivel;
- footer com total e acoes permanentemente visivel;
- somente a lista central rola quando necessario;
- diferenciacao entre produtos e unidades;
- numeracao visual dos produtos;
- indicador explicito de produtos ainda nao visualizados;
- faixa "AINDA HA X PRODUTOS";
- toque no indicador para continuar navegando;
- scroll suave;
- eliminacao da sobreposicao entre indicador e botoes;
- gerenciamento de foco e inert;
- melhoria de acessibilidade do carrinho.

Proxima acao:
R1.17-C - Checkout em etapa propria.

<!-- R1.17-C-FINAL -->

## R1.17-C — Checkout em etapa própria

**Estado:** APROVADA, PROMOVIDA E VERSIONADA.

A R1.17-C separa a finalização do pedido do carrinho e cria
uma etapa própria de checkout, otimizada para viewport mobile.

### Entregas confirmadas

- checkout em tela própria;
- resumo de produtos e unidades;
- total do pedido destacado;
- campo de nome;
- seleção de data;
- seleção de horário;
- forma de pagamento;
- validação dos campos obrigatórios;
- retorno ao carrinho;
- preservação do carrinho R1.17-B;
- integração com o fluxo oficial de finalização;
- abertura do WhatsApp validada funcionalmente;
- ausência de TypeError no teste final.

**Validação funcional:** aprovada em 2026-08-16 21:01:45.

**Próxima etapa:** R1.17-D.
