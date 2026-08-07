# DECISÕES COMERCIAIS

## DC-001 — Catálogo publicado como linha de base

**Data:** 06/08/2026  
**Decisão:** os dados presentes no repositório público `obadoceria-gif/cardapio` serão usados como linha de base comercial inicial.  
**Observação:** futuras alterações deverão ocorrer no Modelo Mestre e receber nova versão de catálogo.

## DC-002 — Desativação em vez de exclusão

Produtos e sabores retirados de venda devem receber `ativo: false` e `disponivel: false`, preservando ID e histórico.

## DC-003 — Caixas montáveis

A linha de base possui caixas de 25, 35, 50 e 100 doces, com limites de 7, 7, 10 e 14 sabores, respectivamente.

## DC-004 — Caixas degustação

A linha de base possui opções de 12 sabores por R$ 40,00 e 25 sabores por R$ 75,00, tratadas como caixas fechadas.

## DC-005 — Opcionais

Laço decorativo e placa personalizada são adicionais independentes, com preços de R$ 4,50 e R$ 3,50 na linha de base.

## Regra de atualização

Toda mudança de preço, disponibilidade, produto ou sabor deverá:

1. atualizar o arquivo JSON correspondente;
2. atualizar `catalogVersion`;
3. ser testada antes da publicação;
4. ser registrada neste documento quando representar uma decisão relevante.
