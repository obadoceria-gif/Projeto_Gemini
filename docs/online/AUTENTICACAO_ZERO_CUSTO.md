# Autenticacao privada zero-custo

## Decisao

Cloudflare Zero Trust / Access nao faz parte da arquitetura operacional
do Cardapio Oba Doceria.

Motivo:

- requisito de zero cartao;
- requisito de zero mensalidade;
- requisito de zero cobranca automatica;
- evitar dependencia de produto que exija onboarding financeiro.

## Arquitetura adotada

A Central privada utiliza um gate de autenticacao executado diretamente
no Cloudflare Worker.

O Worker executa antes de qualquer asset estatico.

Fluxo:

1. requisicao chega ao Worker;
2. /health permanece tecnico;
3. /__auth/login fornece login;
4. demais paginas exigem sessao valida;
5. /api/* sem sessao retorna HTTP 401;
6. assets privados somente sao entregues apos autenticacao.

## Credenciais

Credenciais nunca devem existir:

- no HTML;
- no JavaScript publico;
- no wrangler.jsonc;
- no GitHub;
- no catalogo;
- em documentacao.

Producao utilizara Worker Secrets.

## Sessao

Cookie:

- HttpOnly;
- Secure;
- SameSite=Strict;
- prefixo __Host-;
- Path=/;
- expiracao maxima de 8 horas.

A sessao possui assinatura HMAC SHA-256 usando Web Crypto.

## Estado atual

Nesta fase:

- implementacao somente local;
- zero deploy;
- zero DNS;
- workers.dev desabilitado;
- preview URLs desabilitadas;
- nenhuma rota publica configurada.

## Regra financeira

Nenhum servico que exija:

- cartao;
- assinatura;
- upgrade pago;
- cobranca automatica;

pode ser habilitado sem aprovacao explicita.

## Proximas etapas

1. testes funcionais locais;
2. endurecimento CSRF;
3. rate limiting;
4. definicao segura da credencial administrativa;
5. secrets de producao;
6. deploy isolado;
7. validacao anonima;
8. somente depois, habilitacao controlada de endereco.
