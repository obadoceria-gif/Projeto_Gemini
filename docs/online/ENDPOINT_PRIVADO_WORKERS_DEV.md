# Central privada online - OBA Doceria

## Estado oficial

Status: ONLINE E AUTENTICADA

Worker:
oba-cardapio-gestao

URL oficial:
https://oba-cardapio-gestao.obadoceria.workers.dev

Branch:
feature/gestao-online-segura

Baseline de homologacao do E2E remoto:
cb4c100

## Exposicao

- workers_dev: true
- preview_urls: false
- zero routes customizadas
- run_worker_first: true
- HTTPS
- Static Assets passam obrigatoriamente pelo Worker

## Autenticacao homologada

- login administrativo real aprovado
- AUTH_PASSWORD armazenado como Worker Secret
- AUTH_SESSION_SECRET armazenado como Worker Secret
- nenhum valor de secret no Git
- cookie administrativo Secure / HttpOnly / SameSite Strict
- cookie CSRF Secure / SameSite Strict
- sessao assinada com Web Crypto/HMAC
- CSRF validado
- logout validado
- sessao adulterada rejeitada
- headers de seguranca validados

## Acesso anonimo homologado

- /health: HTTP 200
- /: redireciona para /__auth/login
- /index.html: redireciona para /__auth/login
- API sem sessao: HTTP 401
- pagina de login: HTTP 200

## E2E remoto

O teste canonico de ambiente online e:

online/gestao/tests/auth-e2e-remote.cjs

A ordem de teste e:

1. acesso anonimo;
2. login correto;
3. cookies e sessao;
4. assets;
5. API;
6. CSRF;
7. sessao adulterada;
8. headers;
9. logout;
10. senha incorreta;
11. rate limit remoto informativo.

O rate limit atual usa estado do runtime e nao deve ser interpretado
como contador distribuido global.

## Fail-closed

Em emergencia:

1. alterar workers_dev para false;
2. manter preview_urls false;
3. manter zero routes customizadas;
4. executar deploy;
5. confirmar que workers.dev deixou de responder.

## Cardapio publico

O cardapio publico dos clientes permanece separado desta Central.

A ativacao da Central nao altera o endereco publico do cardapio.