# DOMÍNIO DO NEGÓCIO

**Versão:** 1.0  
**Status:** aprovado como base conceitual; implementação pendente.

## 1. Propósito

O núcleo do projeto representa o catálogo comercial da Oba Doceria. O Cardápio Virtual é uma interface que consulta esse núcleo, permite configurar itens e transforma as escolhas em um pedido.

## 2. Entidades

### Catálogo
Conjunto versionado de categorias, sabores, caixas, kits, combos, opcionais e configurações.

### Categoria
Agrupa sabores ou produtos para exibição e organização comercial.

### Sabor
Unidade comercial selecionável dentro de caixas montáveis. Possui preço unitário, categoria, imagem, disponibilidade e histórico por ID estável.

### Caixa
Produto configurável ou fechado.

- **Montável:** exige quantidade exata de doces e limita o total de sabores.
- **Fechada:** possui composição definida pela loja e preço fixo.

### Kit
Produto composto com preço fixo, descrição, imagem e opcionais permitidos.

### Combo
Conjunto promocional ou comercial formado por outros itens. Está previsto no modelo, mas ainda não possui registros oficiais consolidados.

### Opcional
Adicional associado a produtos compatíveis, como laço ou placa.

### Pedido configurado
Representa a escolha final do cliente. Deve registrar os itens, composições, preços usados e versão do catálogo.

### Cliente
Dados informados no checkout. Não deve ser confundido com o número de destino do WhatsApp da loja.

### Canal de atendimento
Meio pelo qual o pedido é encaminhado. O canal atual é WhatsApp, mas o domínio não deve depender dele.

## 3. Relacionamentos

```text
Catálogo
├── Categorias
│   └── Sabores
├── Caixas
│   └── Seleções de sabores
├── Kits
│   └── Opcionais permitidos
├── Combos
│   └── Componentes
└── Configuração comercial

Cliente
└── Pedido configurado
    └── Itens do catálogo + versão utilizada
```

## 4. Regras fundamentais

1. Produtos e sabores inativos não aparecem na vitrine.
2. Itens ativos podem ficar temporariamente indisponíveis sem perder o histórico.
3. Caixas montáveis só podem ser concluídas com a capacidade exata.
4. O limite de sabores é definido por caixa.
5. O preço de caixas montáveis é a soma das quantidades multiplicadas pelo preço unitário de cada sabor.
6. Caixas degustação e kits usam preço fixo.
7. Opcionais só podem ser usados nos produtos que os permitem.
8. O pedido deve registrar a versão do catálogo utilizada.
9. O telefone do cliente nunca pode ser usado como destino do pedido.
10. Dados comerciais não devem ficar fixos no HTML ou espalhados no JavaScript.

## 5. Ciclo de vida

```text
Catálogo publicado
→ escolha do produto
→ configuração
→ validação
→ carrinho
→ checkout
→ geração do pedido
→ envio ao canal de atendimento
```
