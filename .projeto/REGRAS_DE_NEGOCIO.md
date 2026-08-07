# Regras de Negócio

**Versão:** 1.0  
**Última atualização:** 06/08/2026  
**Status:** Em consolidação a partir do cardápio publicado

## Fonte comercial inicial

Enquanto a nova base não for validada, o repositório original `obadoceria-gif/cardapio` e o Catálogo 2026 são as referências comerciais para produtos, imagens, sabores, caixas, valores e contatos.

## Regras já identificadas

- existem caixas de 25, 35, 50 e 100 doces;
- o limite de sabores varia conforme a caixa;
- existem caixas degustação;
- existem kits presenteáveis;
- existem opcionais como laço e placa;
- sabores são organizados por categorias ou faixas de preço;
- o pedido é finalizado por mensagem formatada no WhatsApp;
- disponibilidade e preço final podem exigir confirmação da loja.

## Regras do Modelo Mestre

Cada item comercial deve possuir:

- ID estável;
- nome;
- tipo ou categoria;
- preço ou regra de cálculo;
- situação ativa/inativa;
- disponibilidade atual;
- ordem de exibição;
- imagem, quando aplicável;
- data ou versão de atualização.

## Estados de produto

- `ativo: true` e `disponivel: true`: aparece e pode ser selecionado;
- `ativo: true` e `disponivel: false`: aparece como indisponível ou pode ser ocultado conforme decisão de UX;
- `ativo: false`: não aparece, mas o registro é preservado para histórico.

## Caixas

Cada caixa deve informar:

- capacidade total;
- quantidade máxima de sabores;
- regra de preço;
- sabores permitidos;
- quantidade selecionada por sabor;
- validação antes da inclusão no carrinho.

Uma caixa só deve ser considerada pronta quando cumprir suas regras de capacidade e composição.

## Carrinho

O carrinho deve guardar uma fotografia do item no momento da inclusão, incluindo:

- ID;
- nome;
- quantidade;
- preço unitário ou total calculado;
- composição da caixa ou combo;
- opcionais;
- versão do catálogo utilizada.

## WhatsApp

A mensagem deve conter:

- identificação do pedido;
- cliente;
- itens e composições;
- subtotais e total;
- dados de retirada ou entrega;
- forma de pagamento, quando exigida;
- versão do catálogo;
- observação de confirmação.

O telefone de destino deve vir exclusivamente da configuração da loja. O telefone do cliente nunca pode ser usado como fallback de destino.

## Atualizações periódicas

Alterações de preço, sabor, disponibilidade, combo ou produto devem ser feitas nos dados, sem reescrever a interface.
