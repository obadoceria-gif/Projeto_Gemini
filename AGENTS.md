# AGENTS.md — Oba Doceria

## Inicio obrigatório

Antes de alterar qualquer arquivo:

1. Leia `docs/HANDOFF.md`.
2. Leia `docs/CURRENT_STATE.md`.
3. Leia `docs/DECISIONS.md`.
4. Leia `docs/ROADMAP.md`.
5. Valide branch, HEAD e `git status`.

## Projeto

Cardápio Virtual Interativo + Central de Gestão da Oba Doceria.

Arquitetura operacional:

Central privada -> DRAFT -> PREVIEW -> PUBLISHED -> Cardápio público.

## Stack

- HTML5
- CSS3
- JavaScript Vanilla ES6+
- Node.js
- PowerShell
- Git/GitHub
- Cloudflare Workers
- Cloudflare Static Assets
- Cloudflare D1
- GitHub Pages

## Regras obrigatórias

- GitHub é a fonte canônica de código e histórico.
- Nunca alterar PUBLISHED diretamente durante edição.
- Toda edição passa por DRAFT.
- Toda publicação deve passar por PREVIEW.
- Criar checkpoint antes de cloud write ou mudança crítica.
- Executar testes antes de deploy.
- Falha pós-deploy exige rollback ou fail-closed.
- Nunca versionar passwords, tokens, secrets ou `.dev.vars`.
- Não alterar ExecutionPolicy.
- Usar o NPX confiável `C:\Program Files\nodejs\npx.cmd`.
- Não remover a Central pública antiga antes da substituta privada estar homologada.
- Não introduzir serviço pago ou cartão sem aprovação explícita.
- Preservar a última versão conhecida como válida.
- Preferir automação a edição manual.
- Separar mudança visual de mudança de regra de negócio quando possível.

## Código

Ao alterar código:

- identificar arquivo;
- validar sintaxe;
- executar gates existentes;
- executar `git diff --check`;
- validar regressões;
- documentar estado resultante;
- commit/push somente depois de aprovação automática.

## Handoff

No final de toda sessão significativa execute:

`.scripts\PROJECT-handoff.ps1`

ou peça à IA:

`Faça o handoff da sessão.`

A IA deve atualizar CURRENT_STATE, HANDOFF, CHANGELOG e, se necessário, ROADMAP e DECISIONS.
