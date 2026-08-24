# DECISÕES TÉCNICAS

## DT-001 — Código real como fonte técnica
O desenvolvimento deve trabalhar sobre o repositório real e atualizado.

## DT-002 — Cline não é dependência
Cline/OpenRouter podem ser usados opcionalmente, mas o projeto deve evoluir sem depender de créditos externos.

## DT-003 — Modelo Mestre
`data/catalog-v1/` é a fonte oficial de dados comerciais da nova arquitetura.

## DT-004 — Migração incremental
O legado será substituído por partes pequenas, testadas e commitadas individualmente.

## DT-005 — Diagnósticos antes do commit
Toda camada importante deve possuir validação independente antes de ser integrada.

## DT-006 — Live Server na porta 5501
O Cardápio Virtual usa a porta 5501 no ambiente atual para evitar conflito com outro projeto local.

## DT-007 — Automação antes de trabalho manual
Sempre que possível, validações e tarefas repetitivas devem ser automatizadas com ferramentas disponíveis no ambiente.

## DT-008 — Instruções manuais com localização exata
Toda alteração manual deve informar arquivo, caminho, linhas e local preciso de inserção/substituição.

## DT-009 — Mudanças de metodologia devem ser documentadas
Qualquer mudança relevante no fluxo de desenvolvimento deve atualizar a documentação de governança antes ou junto com a implementação.

## DT-010 — Evitar substituição ampla de arquivos grandes
Arquivos grandes, especialmente `src/app.js`, devem ser migrados incrementalmente, uma responsabilidade por vez.
