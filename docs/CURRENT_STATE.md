# CURRENT STATE

Atualizado: 2026-08-31 22:39:10

## Git

Branch: feature/gestao-online-segura

HEAD homologado antes da DOC-1: c4d4c2d

Tag funcional anterior:
gestao-online-draft-20260831-203523

## Produção

Cardápio público permanece operacional e não deve ser alterado durante as fases de edição/Preview.

Central privada online protegida por autenticação Worker.

## Concluído

- autenticação real;
- sessão assinada;
- CSRF;
- rate limiting de login;
- APIs e assets privados;
- Worker online;
- D1 criado e vinculado;
- sete entidades canônicas legíveis;
- imagens existentes online;
- modelo DRAFT/PREVIEW/PUBLISHED;
- revisão PUBLISHED baseline;
- GET /api/draft;
- POST /api/draft;
- SHA-256 server-side;
- revisão imutável;
- D1 batch;
- DRAFT homologado;
- DRAFT = baseline PUBLISHED;
- PREVIEW ainda não operacional;
- PUBLISHED preservado.

## Fase atual

8E.9D-B + 8E.9E

Objetivo:

Central -> DRAFT -> PREVIEW privado.

## Última tentativa

O patch Central/Preview foi interrompido localmente antes de deploy.

Erro:

SyntaxError: Invalid regular expression: missing /

O mecanismo restaurou Worker e Central.

Estado após a falha:

- zero deploy;
- zero D1 write;
- PUBLISHED intacto;
- cardápio público intacto.

Também foi identificado crash recorrente do PSReadLine ao colar scripts muito grandes.

## Regra operacional nova

Evitar blocos gigantes colados diretamente no console.

Preferir scripts persistentes em .scripts/ e comandos curtos.

## Próxima ação técnica

Corrigir e reaplicar o patch Central + DRAFT + PREVIEW usando arquivo/script persistente.

Depois:

PREVIEW -> PUBLISHED -> rollback -> mídia -> homologação final.
