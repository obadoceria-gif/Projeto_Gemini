# MATRIZ DE TESTES

## Regra
Toda promocao deve registrar testes executados.

## Mobile
### Viewports
- [ ] 360px
- [x] 390px
- [ ] 430px

### Degustacao
- [x] Selecionar 12
- [x] Selecionar 25
- [x] Preco correto
- [x] Lightbox
- [x] Comparacao 12/25
- [x] Adicionar ao carrinho
- [x] Badge atualizado
- [x] Abrir carrinho

### Caixa normal
- [x] Selecionar tamanho
- [x] Montar sabores
- [x] Completar capacidade
- [x] Adicionar diretamente ao carrinho
- [x] Badge atualizado
- [x] Sem modal intermediario automatico

### Carrinho
- [x] Um item
- [x] Multiplos itens
- [x] Alterar quantidade
- [x] Remover item
- [x] Total consolidado
- [x] Continuar comprando
- [x] Abrir fechamento
- [ ] Testar muitos itens com lista interna rolavel

### Checkout
- [x] Nome
- [x] Data
- [x] Hora
- [x] Pagamento
- [ ] Separar checkout do carrinho
- [ ] Validacao completa de campos

### Console
- [x] Correcao do TypeError mobile-total/mobile-label
- [ ] Auditoria completa sem erros apos R1.17

## Desktop
- [x] Fluxo basico funcional
- [ ] Revisao responsiva completa apos R1.17
## R1.17-A - Fluxo por etapas

### Degustacao
- [x] Tela de escolha em viewport mobile
- [x] Seletor 12
- [x] Seletor 25
- [x] Continuar desabilitado sem escolha
- [x] Continuar habilitado apos escolha
- [x] Selecionar nao altera badge do carrinho
- [x] Tela de revisao separada
- [x] Voltar e alterar
- [x] Escolha preservada ao voltar
- [x] Salvar somente por acao explicita
- [x] Preco e quantidade na revisao
- [x] Acoes principais acessiveis sem procurar por rolagem
- [x] Console sem TypeError

### Proximo teste
R1.17-B:
- [ ] Carrinho com 1 item
- [ ] Carrinho com 2 itens
- [ ] Carrinho com muitos itens
- [ ] Header persistente
- [ ] Footer persistente
- [ ] Lista interna rolavel
## R1.17-B - Carrinho em viewport

- [x] Abrir carrinho pelo icone global
- [x] Header persistente
- [x] Footer persistente
- [x] Total sempre visivel
- [x] Continuar comprando sempre visivel
- [x] Ir para finalizacao sempre visivel
- [x] 1 produto
- [x] 2 produtos
- [x] 5 produtos
- [x] Produtos e unidades separados
- [x] Numeracao visual
- [x] Aumentar quantidade
- [x] Reduzir quantidade
- [x] Remover produto
- [x] Atualizacao de total
- [x] Lista central rolavel
- [x] Indicador de produtos abaixo
- [x] Indicador nao cobre footer
- [x] Scroll suave
- [x] Acessibilidade de foco revisada

### Proximo teste
R1.17-C:
- [ ] checkout em viewport propria
- [ ] nome
- [ ] data
- [ ] hora
- [ ] pagamento
- [ ] resumo compacto
- [ ] validacoes
- [ ] finalizacao

<!-- R1.17-C-TESTES -->

## Testes R1.17-C

**Resultado geral: APROVADO**

Validações executadas:

- abertura da etapa própria de checkout: OK;
- resumo de 2 produtos / 2 unidades: OK;
- cálculo do total: OK;
- preenchimento do nome: OK;
- preenchimento da data: OK;
- preenchimento da hora: OK;
- seleção da forma de pagamento: OK;
- retorno ao carrinho: OK;
- retorno ao checkout: OK;
- preservação dos itens: OK;
- FINALIZAR PEDIDO: OK;
- abertura do WhatsApp: OK;
- TypeError no console: NÃO IDENTIFICADO.

Teste visual realizado em viewport mobile.

## R1.17-D - Continuidade do fluxo

- [x] Candidato isolado
- [x] Carrinho abre normalmente
- [x] Proxima etapa indicada
- [x] Ir para finalizacao
- [x] Checkout em tela propria
- [x] Contexto de progresso
- [x] Voltar ao carrinho
- [x] Produtos preservados
- [x] Total preservado
- [x] Retornar ao checkout
- [x] Nome
- [x] Data
- [x] Hora
- [x] Pagamento
- [x] Finalizar pedido
- [x] WhatsApp
- [x] Console sem TypeError

### Proximo ciclo
R1.18:
- [ ] auditoria do fluxo completo;
- [ ] inconsistencias remanescentes;
- [ ] regressao funcional;
- [ ] mobile real;
- [ ] desktop;
- [ ] preparacao de baseline consolidada.