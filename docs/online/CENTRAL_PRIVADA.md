# Central Privada - Oba Doceria

## Estado

A Central de Gestão foi separada estruturalmente da superfície pública.

## Produção atual

O cardápio público existente continua intacto.

Nenhum DNS foi alterado.
Nenhum deploy Cloudflare foi realizado nesta fase.

## Estrutura

online/gestao/

- public/
- src/index.js
- wrangler.jsonc
- package.json

## Segurança

A Central NÃO utilizará senha armazenada no HTML ou JavaScript.

A autenticação deverá ocorrer antes da aplicação por meio de
Cloudflare Access.

O Worker foi configurado com:

- workers_dev = false
- preview_urls = false

Portanto, esta configuração não deve publicar automaticamente
uma URL pública workers.dev.

## Próximas etapas

1. instalar dependências localmente;
2. validar Worker por dry-run;
3. autenticar uma conta Cloudflare autorizada;
4. criar ambiente privado;
5. aplicar Cloudflare Access;
6. somente depois disponibilizar a Central;
7. posteriormente configurar domínio próprio, se desejado.

## Regra de produção

O cardápio público continua utilizando a última versão homologada
enquanto alterações são realizadas separadamente.

Nenhuma edição normal exige colocar a loja em manutenção.
