# STATUS DO PROJETO

## Projeto
Cardapio Virtual Interativo & Atendimento via WhatsApp

## Estado atual
- Branch ativa: feature/integracao-ui-oficial-modelo-mestre
- Baseline oficial: R1.16-K
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
R1.17 - Fluxo Mobile por Etapas

Objetivos:
1. Tela de selecao sem rolagem desnecessaria
2. Revisao de produto em tela propria
3. Carrinho com header e footer persistentes
4. Apenas a lista de itens rolavel quando necessario
5. Checkout separado do carrinho
6. Aplicar a mesma logica a degustacao e caixas normais
7. Prioridade para telas 360px, 390px e 430px

## Proxima acao
Iniciar R1.17-A com a arquitetura mobile por etapas.