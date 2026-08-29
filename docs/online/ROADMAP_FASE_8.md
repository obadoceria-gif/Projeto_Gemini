# ROADMAP — FASE 8

## 8A — Baseline e governança

Objetivo:
Preservar oficialmente a última versão válida e criar a branch da
arquitetura online.

Status:
Em implantação.

## 8B — Descoberta de domínio e Cloudflare

Objetivo:
Identificar:
- domínio oficial disponível
- conta Cloudflare
- zona DNS
- Workers
- Access
- limites/plano aplicáveis

Nenhuma alteração de DNS será feita sem validação prévia.

## 8C — Backend online

Criar:
- Worker API
- D1
- esquema inicial
- R2
- API de leitura/escrita

Importar cópia do catálogo atual.

Produção existente permanece intacta.

## 8D — Central online

Adaptar a Central homologada para:
- autenticação
- dados via API
- upload via R2
- rascunho
- preview
- histórico
- publicação

## 8E — Versionamento e rollback

Implementar:
- snapshots
- versões
- última versão válida
- restaurar versão
- auditoria

## 8F — Preview privado

Criar:
preview.<dominio>

Protegido por login.

## 8G — Cardápio público

Criar:
cardapio.<dominio>

O cardápio continuará público.

## 8H — Virada controlada

Somente depois de:
- testes automáticos
- homologação completa
- backup
- rollback validado

A versão local atual permanece disponível como recuperação.
