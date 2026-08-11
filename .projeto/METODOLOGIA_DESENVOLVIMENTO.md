# Metodologia de Desenvolvimento

## Ciclo obrigatório
diagnosticar → documentar → automatizar → aplicar → validar → testar visualmente → commit → push

## Regras
1. Código real é a fonte da verdade.
2. Git registra o histórico.
3. Mudanças pequenas e reversíveis.
4. Nenhum commit antes de validação.
5. Sempre que possível, usar scripts de aplicação e rollback.
6. Evitar edição manual repetitiva.
7. Não reconstruir algo que já existe e funciona.
8. UI oficial deve ser preservada durante a migração.
9. Mudanças de metodologia devem ser documentadas antes de continuar.
10. O workspace deve terminar limpo após cada etapa concluída.

## Instruções manuais
Sempre informar arquivo exato, linhas exatas quando conhecidas, trecho a substituir, local de colagem e validação esperada.

## Automação
Priorizar backup, snapshots, diagnósticos, busca de referências, criação de documentação, limpeza de artefatos, preparação para commit e checagens pré-deploy.

## Segurança
Automação nunca deve encerrar o terminal com `exit`, usar `git add .` indiscriminadamente, apagar sem backup, commitar antes dos testes ou sobrescrever a UI oficial sem snapshot.
