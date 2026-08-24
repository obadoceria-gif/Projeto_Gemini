# Metodologia de Desenvolvimento

## Ciclo obrigatório

diagnosticar
→ documentar
→ automatizar
→ aplicar
→ validar tecnicamente
→ validar visualmente
→ commit
→ push

## Princípios

1. Código real é a fonte da verdade.
2. Git é o histórico.
3. A UI oficial não será reconstruída se já existir.
4. Alterações devem ser pequenas e reversíveis.
5. Sempre criar backup antes de mudanças destrutivas.
6. Nunca commitar antes dos testes.
7. Mudança metodológica exige atualização da documentação.
8. O workspace deve terminar limpo ao final da etapa.

## Instruções de alteração manual

Sempre informar:
- arquivo exato;
- linhas exatas quando conhecidas;
- trecho atual;
- trecho novo;
- onde substituir;
- validação esperada.

## Automação

Automatizar sempre que possível:
- busca de arquivos;
- busca de referências;
- snapshots;
- backups;
- instalação de patches;
- rollback;
- diagnósticos;
- inventário;
- comparação;
- limpeza temporária;
- preparação Git;
- pré-deploy.

## Regras de segurança para scripts

Scripts não devem:
- usar `exit` quando executados no terminal interativo;
- usar `git add .`;
- apagar sem backup;
- criar commit automático sem validação;
- fazer push se a etapa anterior falhar;
- sobrescrever a UI oficial sem snapshot.
