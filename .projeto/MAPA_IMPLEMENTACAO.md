# Mapa de Implementação

## Fase A — Recuperar
Objetivo: fazer a UI moderna funcionar localmente sem mudança visual.

Saída esperada:
`http://127.0.0.1:5501/` visualmente equivalente à versão publicada.

## Fase B — Desacoplar caixas
Trocar `caixasConfigs` pelo Catalog Service.

## Fase C — Desacoplar sabores
Trocar `catalogo` pelo Modelo Mestre.

## Fase D — Desacoplar kits
Trocar `kitsPresenteaveis` pelo Modelo Mestre.

## Fase E — Centralizar configuração
Mover telefone, URLs e mensagens comerciais para configuração.

## Fase F — Integrar carrinho
Padronizar itens, quantidades, totais e persistência.

## Fase G — Integrar checkout
Validar dados do cliente, entrega e pagamento.

## Fase H — Integrar WhatsApp
Gerar mensagem final usando dados da arquitetura nova.

## Fase I — Remover legado
Eliminar constantes e funções antigas.

## Fase J — Publicar
Testes, performance, acessibilidade e deploy.
