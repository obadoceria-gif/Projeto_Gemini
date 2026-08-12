# Política de Proteção da Produção

## Produção protegida
Repositório: `https://github.com/obadoceria-gif/cardapio`
Branch: `main`

## Proibições durante o desenvolvimento
Scripts do Projeto_Gemini não devem executar no repositório oficial:
- `git push`;
- `git merge`;
- `git commit`;
- `git switch`;
- escrita, exclusão ou renomeação de arquivos.

## Procedimento obrigatório
1. clonar a origem para uma cópia separada;
2. registrar hash do commit;
3. nunca desenvolver dentro do clone de referência;
4. copiar a UI para `Projeto_Gemini/ui-oficial/`;
5. desenvolver apenas na branch de integração do Projeto_Gemini;
6. validar antes de qualquer publicação.

## Publicação futura
A `main` oficial só será atualizada após testes completos, aprovação, backup/tag e plano de rollback.
