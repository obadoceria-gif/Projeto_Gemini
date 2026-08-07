# Decisões Técnicas

**Versão:** 1.0  
**Última atualização:** 06/08/2026

## DT-001 — Independência do Cline e OpenRouter

**Decisão:** o projeto não dependerá de agentes pagos para evoluir.  
**Motivo:** indisponibilidade de créditos e risco de bloqueio do desenvolvimento.  
**Consequência:** VS Code, Git e ChatGPT passam a compor o fluxo principal; o Cline é opcional.

## DT-002 — Código real como fonte da verdade

**Decisão:** alterações significativas serão baseadas nos arquivos reais e em uma linha de base identificável.  
**Motivo:** evitar decisões baseadas em memória ou descrições desatualizadas.

## DT-003 — Preservação do cardápio publicado

**Decisão:** o repositório `obadoceria-gif/cardapio` permanecerá como referência funcional e comercial até o aceite da nova versão.  
**Motivo:** ele contém catálogo, imagens, regras e deploy funcionando.

## DT-004 — Catálogo orientado por dados

**Decisão:** produtos, sabores, preços, caixas, combos, imagens, contatos e disponibilidade serão mantidos fora do HTML.  
**Motivo:** permitir atualizações periódicas com menor risco e esforço.

## DT-005 — Modelo Mestre de Catálogo

**Decisão:** a nova versão usará um modelo único e validável de dados.  
**Motivo:** eliminar fontes duplicadas e possibilitar um painel administrativo futuro.

## DT-006 — Governança em `.projeto/`

**Decisão:** a pasta `.projeto/` será a memória técnica oficial.  
**Motivo:** facilitar manutenção, transferência e assistência de outras IAs ou desenvolvedores.

## DT-007 — Aprovação antes de alterações estruturais

**Decisão:** mudanças estruturais relevantes exigem plano e aprovação do usuário antes da implementação.
