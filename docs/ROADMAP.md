# ROADMAP

## Visao
Construir um cardapio virtual responsivo, simples, escalavel e integrado ao Modelo Mestre, com carrinho, checkout e atendimento via WhatsApp.

## Fase atual
R1.17 - Fluxo Mobile por Etapas

## Fases

### Concluido
- R1.1 a R1.5 - Governanca e integracao inicial
- R1.6 - Modelo Mestre como fonte das caixas
- R1.7 - Kits
- R1.8 - Opcionais
- R1.9 - Pagamentos
- R1.10 - Campos obrigatorios
- R1.11 - Canais de atendimento
- R1.12 - Versao do catalogo na mensagem
- R1.13-R1.15 - Integracao UI e protecoes de inicializacao
- R1.16 - Mobile First, degustacao e carrinho global

### Em andamento
R1.17 - Fluxo Mobile por Etapas

Entregas planejadas:
1. Selecao de produto em viewport unica
2. Tela de revisao de produto
3. Carrinho em layout de viewport
4. Header fixo do carrinho
5. Footer fixo do carrinho
6. Lista interna rolavel
7. Checkout em etapa separada
8. Padronizacao de caixas normais e degustacao

### Proximas fases
- Revisao integral do checkout
- Persistencia e restauracao de carrinho
- Catalogo completo e demais categorias
- Validacoes de pedido
- Integracao operacional
- Deploy e validacao de producao

## Regra de velocidade
Cada funcionalidade deve ter no maximo dois ciclos principais de refinamento antes de uma reavaliacao arquitetural.

Evitar sequencias longas de microversoes sem fechamento de objetivo.

Cada versao deve:
- fechar uma acao do roadmap;
- gerar teste;
- gerar documentacao;
- gerar baseline;
- permitir avancar para a proxima acao.
## Checkpoint R1.17-A

Status: CONCLUIDO

Entregue:
- Selecao de Degustacao em viewport mobile
- Revisao de produto em etapa propria
- Navegacao sem depender de rolagem para localizar acoes
- Estado temporario separado de item efetivamente salvo

Proxima entrega:
R1.17-B - Carrinho em viewport.

Objetivo:
- header do carrinho sempre visivel;
- area central dos itens adaptativa;
- rolagem somente da lista quando necessario;
- total e acoes sempre acessiveis.
## Checkpoint R1.17-B

Status: CONCLUIDO

Entregue:
- carrinho em viewport;
- header persistente;
- footer persistente;
- lista central rolavel;
- indicador explicito para produtos nao visualizados;
- produtos e unidades diferenciados;
- acessibilidade de foco revisada.

Proxima entrega:
R1.17-C - Checkout em etapa propria.

Objetivo:
- retirar os dados de entrega da tela de revisao do carrinho;
- criar etapa exclusiva de finalizacao;
- manter resumo compacto do pedido;
- manter total sempre visivel;
- validar nome, data, hora e pagamento;
- finalizar pedido via fluxo oficial.