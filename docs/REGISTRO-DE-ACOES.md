# REGISTRO DE ACOES

## Estado atual

### Concluido
- Integrar caixas ao Modelo Mestre
- Proteger inicializacao assincrona
- Corrigir undefined da degustacao
- Criar UX de selecao 12/25
- Implementar lightbox
- Melhorar experiencia Mobile First
- Criar carrinho global
- Eliminar painel de carrinho permanente
- Corrigir TypeError de elementos mobile removidos
- Unificar conclusao de caixas e degustacao
- Promover R1.16-K
- Consolidar documentacao da R1.16

### Agora
R1.17-A - Criar arquitetura mobile por etapas

Objetivo:
eliminar dependencia de rolagem para descobrir a proxima acao.

### Depois
R1.17-B - Carrinho em viewport
R1.17-C - Checkout separado
R1.17-D - Padronizacao de caixas
R1.17-E - Teste integral
R1.17-F - Promocao e documentacao

## Pendencias
- Substituir uma das imagens duplicadas da Degustacao
- Executar push da baseline quando autorizado
- Revisar multiplos itens no carrinho
- Revisar validacoes de checkout

## Regra de execucao
Cada nova tarefa deve:
1. autenticar baseline;
2. criar candidato;
3. alterar automaticamente;
4. validar estrutura;
5. testar runtime;
6. aprovar;
7. promover;
8. atualizar documentacao;
9. criar commit quando autorizado;
10. push apenas quando autorizado.
## R1.17-A

Status: CONCLUIDO

Problema:
A Caixa Degustacao concentrava escolha, detalhes e acoes em uma pagina vertical, exigindo rolagem.

Solucao:
Separar o fluxo em:
1. escolha;
2. revisao;
3. acao explicita.

Resultado:
Arquitetura aprovada em viewport mobile.

Proxima acao:
R1.17-B - Reestruturar o carrinho para trabalhar em uma viewport com areas persistentes.