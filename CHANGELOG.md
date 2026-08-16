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