## R1.17-D - Continuidade do Fluxo Mobile

### Adicionado
- feedback visual curto entre etapas;
- orientacao de proxima etapa no carrinho;
- contexto de progresso no checkout;
- feedback de retorno ao carrinho.

### Preservado
- carrinho em viewport R1.17-B;
- checkout em etapa propria R1.17-C;
- fluxo de finalizacao via WhatsApp;
- estado do pedido durante navegacao.

### Validado
- carrinho -> checkout;
- checkout -> carrinho;
- retorno ao checkout;
- preservacao de itens e total;
- finalizacao do pedido;
- console sem TypeError.

### Proxima etapa
R1.18 - consolidacao e auditoria do fluxo comercial completo.

---
## R1.17-B - Carrinho em Viewport
Data de consolidacao: 2026-08-16

### Adicionado
- Carrinho mobile em viewport dedicada
- Header persistente
- Footer persistente
- Lista central rolavel
- Contagem de produtos e unidades
- Numeracao dos produtos
- Indicador de continuidade para produtos ocultos
- Scroll suave pelo indicador
- Gerenciamento de foco e inert

### Melhorado
- Descoberta de produtos abaixo da area visivel
- Total e proximas acoes permanecem acessiveis
- Carrinhos extensos nao aumentam indefinidamente a pagina
- Usuario nao precisa adivinhar que existem produtos abaixo

### Validado
- 1 e 2 produtos
- multiplos produtos
- 5 produtos
- incremento de unidades
- remocao
- total
- lista interna rolavel
- indicador de continuidade
- header e footer persistentes

### Proxima etapa
R1.17-C - Checkout em etapa propria.

---
## R1.17-A - Fluxo Mobile por Etapas
Data de consolidacao: 2026-08-16

### Adicionado
- Tela dedicada de escolha da Caixa Degustacao
- Tela dedicada de revisao do produto
- Navegacao Voltar e alterar
- Acoes separadas para continuar comprando, ver carrinho e finalizar
- Controle mobile baseado em 100dvh

### Alterado
- Escolher 12/25 deixa de salvar automaticamente o produto
- Inclusao no carrinho acontece somente apos acao explicita do usuario
- Informacoes deixaram de ser empilhadas abaixo da foto
- Fluxo mobile passa a operar por etapas

### Validado
- Degustacao 12
- Degustacao 25
- Preservacao da escolha ao voltar
- Tela de escolha sem rolagem para encontrar a proxima acao
- Tela de revisao sem rolagem para encontrar a proxima acao
- Console sem TypeError

### Proxima etapa
R1.17-B - Carrinho em viewport com cabecalho e acoes persistentes.

---
# CHANGELOG

## R1.16-K - Mobile First e Carrinho Global
Data de consolidacao: 2026-08-16

### Adicionado
- Experiencia Mobile First para Caixa Degustacao
- Seletor de 12 e 25 doces
- Lightbox ampliado
- Comparacao 12/25
- Carrinho global com badge
- Modal unico de carrinho
- Conclusao direta de caixas normais no carrinho

### Alterado
- Degustacao deixou de depender de modal intermediario
- Carrinho deixou de ocupar painel permanente nas paginas
- Caixa normal concluida passa diretamente para o carrinho
- Badge passa a refletir itens salvos
- WhatsApp deixa de competir com produtos em areas criticas

### Corrigido
- Undefined em dados da caixa de degustacao
- Inicializacao prematura das configuracoes de caixas
- Dependencias antigas mobile-total e mobile-label
- Sobreposicao do WhatsApp
- Inconsistencia entre fluxo da degustacao e caixas normais

### Validado
- Caixa Degustacao 12
- Caixa Degustacao 25
- Caixa normal de 25 doces
- Carrinho com multiplos itens
- Alteracao de quantidade
- Remocao de itens
- Total consolidado
- Abertura do carrinho pelo badge
- Testes mobile em viewport aproximada de 390x844

### Pendencias
- Imagens 12/25 fisicamente distintas ainda nao existem
- Fluxo mobile por etapas ainda sera implementado
- Checkout ainda compartilha a mesma tela do carrinho

---

## R1.15
- Integracao de configuracoes do Modelo Mestre
- Protecao da inicializacao de caixas
- Estrutura de degustacao preparada para hidratacao assincrona

## R1.14 e anteriores
O historico tecnico completo permanece preservado no Git.

<!-- R1.17-C-CHANGELOG -->

## R1.17-C

### Adicionado

- checkout em etapa própria;
- resumo compacto do pedido;
- campos de entrega;
- seleção de pagamento;
- validação de preenchimento;
- navegação checkout → carrinho;
- integração checkout → fluxo oficial → WhatsApp.

### UX

O carrinho passa a ser dedicado à revisão dos produtos.
Os dados de entrega e finalização passam a ocupar uma etapa
independente, reduzindo excesso de conteúdo no mesmo viewport.

### Compatibilidade

A R1.17-B foi preservada como base do carrinho em viewport.

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

## R1.19-B01

- Adicionada proteção contra duplo envio no checkout.
- Adicionado lock temporário de finalização.
- Adicionado feedback visual PROCESSANDO PEDIDO....
- Adicionados ria-disabled e ria-busy durante processamento.
- Mantida compatibilidade com o fluxo legado e WhatsApp.