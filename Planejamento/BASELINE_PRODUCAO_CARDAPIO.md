# Baseline Oficial de Produção — Cardápio Oba Doceria

## Status

**HOMOLOGADA E LIBERADA PARA CLIENTES**

Data de homologação: 2026-08-26

## Produção

URL oficial:

https://obadoceria-gif.github.io/Projeto_Gemini/

Fonte publicada:

- Repositório: Projeto_Gemini
- Branch de produção: main
- GitHub Pages: main / root
- Commit-base anterior ao registro: c7f6d66

## Validações homologadas

- E2E comercial: 35/35
- UX R15.1: 11/11
- Debug R15.2: 12/12
- Smoke HTTP público: APROVADO
- Redirecionamento raiz: APROVADO
- Painel técnico no modo cliente: OCULTO
- ?obaDebug=1: preservado para diagnóstico
- Homologação visual mobile: APROVADA

## Contrato de manutenção

Esta versão passa a ser a baseline oficial do Cardápio Oba Doceria.

Qualquer evolução futura deve:

1. partir desta baseline;
2. preservar os fluxos comerciais homologados;
3. preservar montagem, edição, carrinho, checkout e WhatsApp;
4. executar os gates automatizados antes da publicação;
5. impedir elementos de teste/debug no modo cliente;
6. evitar alterações diretas em produção sem validação;
7. manter trabalho manual restrito à homologação visual quando necessário.

## Regra de publicação

Produção somente após:

- testes automatizados aprovados;
- zero regressões conhecidas;
- commit consolidado em main;
- GitHub Pages atualizado;
- smoke test público aprovado.
