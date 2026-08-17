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

<!-- R1.17-C-ROADMAP -->

## R1.17-C — CONCLUÍDA

Checkout em etapa própria implementado e aprovado.

Fluxo consolidado:

Produto
→ seleção/configuração
→ revisão
→ carrinho
→ checkout
→ WhatsApp

A arquitetura mobile passa a separar explicitamente:

1. escolha;
2. revisão;
3. carrinho;
4. finalização.

Próxima evolução: **R1.17-D**.

## Checkpoint R1.17-D

Status: CONCLUIDO

Fluxo mobile consolidado:

Produto
-> configuracao
-> revisao
-> carrinho
-> checkout
-> WhatsApp

Entregue:
- continuidade visual entre carrinho e checkout;
- proxima acao explicitada;
- retorno entre etapas preservando estado;
- feedback de navegacao;
- fluxo final funcional.

Proxima fase:
R1.18 - consolidacao e auditoria do fluxo comercial completo.

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
