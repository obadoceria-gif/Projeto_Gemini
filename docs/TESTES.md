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