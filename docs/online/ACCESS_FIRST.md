# Central Online — Gate Access-First

## Estado

A conta Cloudflare foi autenticada e validada.

O inventário da Fase 8D.6 confirmou que atualmente não existe
zona/domínio Cloudflare disponível para a Central.

## Regra obrigatória

A Central administrativa nunca deve receber uma rota pública antes
da camada de autenticação/autorização estar definida.

Enquanto isso:

- `workers_dev` permanece `false`;
- `preview_urls` permanece `false`;
- nenhuma rota pública é configurada;
- nenhum domínio é presumido;
- nenhum segredo é armazenado no navegador;
- o cardápio público atual permanece independente e intacto.

## Ordem de ativação

1. preparar Worker;
2. validar Worker sem exposição pública;
3. preparar Cloudflare Access;
4. definir identidade autorizada;
5. adicionar domínio/zona quando disponível;
6. conectar rota privada;
7. testar usuário não autenticado;
8. testar usuário autorizado;
9. somente então homologar a Central online;
10. posteriormente retirar a Central antiga da publicação pública.

## Rollback

Até a homologação completa da Central privada, nenhuma alteração
deve interromper o cardápio público ou a Central local conhecida
como estável.
