# Estado Atual — Cardápio Oba Doceria

Atualizado em: 2026-08-26 10:28:01

## Baseline funcional

Arquivo:
\$baselineRel\

SHA256:
\$hashBaselineAntes\

## Estado funcional

- Montagem de caixa: aprovado
- Mínimo de 25 doces: aprovado
- Edição de caixa: aprovado
- Salvamento acima de 25 doces: aprovado
- Carrinho: aprovado
- Checkout: aprovado
- Geração de WhatsApp: aprovado
- R15.1 indicador de mais sabores: aprovado
- R15.2 modo debug invisível: aprovado

## Testes automatizados

- E2E comercial: 35/35
- UX R15.1: 11/11
- Debug R15.2: 12/12
- Contratos funcionais: 0 falhas
- Gates: 0 falhas

## Deploy

O GitHub contém a versão consolidada em main.
A publicação definitiva ainda deve ser configurada em um provedor de hospedagem.
Cloudflare Pages não possui projeto configurado na conta atualmente inspecionada.

## Próximo passo

1. concluir higienização;
2. executar gate final;
3. consolidar Git;
4. publicar em produção;
5. executar smoke test na URL pública;
6. liberar para clientes.