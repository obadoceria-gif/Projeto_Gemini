# METODOLOGIA DE DESENVOLVIMENTO

**Versão:** 1.0  
**Status:** Ativa  
**Última atualização:** 2026-08-10

## 1. Fonte da verdade

- Código atual: repositório Git oficial `Projeto_Gemini`.
- Histórico: Git / GitHub.
- Dados comerciais: `data/catalog-v1/`.
- Planejamento: `.projeto/PLANO_MESTRE.md`.
- Estado atual: `.projeto/STATUS.md`.
- Regras de negócio: `.projeto/REGRAS_DE_NEGOCIO.md`.

## 2. Fluxo oficial de cada tarefa

1. Consultar o Plano Mestre.
2. Definir uma tarefa pequena e verificável.
3. Identificar os arquivos afetados.
4. Procurar automação antes de pedir trabalho manual.
5. Alterar o mínimo necessário.
6. Executar diagnóstico automático.
7. Executar teste manual apenas do comportamento que não possa ser automatizado.
8. Corrigir antes de qualquer commit.
9. Atualizar documentação afetada.
10. Executar `git status`.
11. Fazer commit atômico.
12. Fazer `git push`.
13. Confirmar `working tree clean`.
14. Atualizar STATUS.

## 3. Regra das alterações manuais

Toda instrução manual deve informar:

- arquivo exato;
- caminho exato;
- intervalo de linhas;
- trecho atual a localizar;
- ação: inserir, substituir ou remover;
- trecho final esperado;
- teste a executar.

Não serão usadas instruções vagas como “altere a função” sem localizar o trecho.

## 4. Regra de incremento pequeno

Arquivos grandes, especialmente `src/app.js`, devem ser alterados de forma incremental.

Objetivo por tarefa:

- uma responsabilidade;
- uma alteração pequena;
- um diagnóstico;
- um commit.

## 5. Regra de diagnóstico

Toda camada importante deve possuir diagnóstico próprio em `diagnostics/`.

Diagnósticos atuais:

- `catalog-check.html`;
- `view-model-check.html`;
- `catalog-service-check.html`.

Diagnósticos futuros:

- integração com `app.js`;
- carrinho;
- preço;
- montagem de caixa;
- checkout;
- WhatsApp;
- pré-deploy.

## 6. Regra de aprovação

Uma Sprint só é concluída quando:

- diagnóstico aprovado;
- teste manual mínimo aprovado;
- commit criado;
- push concluído;
- `git status` limpo;
- documentação atualizada.

## 7. Mudanças de metodologia

Qualquer mudança deste documento exige registro em `DECISOES_TECNICAS.md`.

Não alterar metodologia apenas na conversa.
