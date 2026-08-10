# PLANO MESTRE — Cardápio Virtual Interativo Oba Doceria

**Versão:** 1.0  
**Status:** Ativo  
**Última atualização:** 2026-08-10

## 1. Objetivo final

Construir um Cardápio Virtual Interativo, Mobile First, orientado por dados, simples de manter e preparado para:

- exibir produtos, caixas, sabores, kits, combos e opcionais;
- montar caixas configuráveis por capacidade e limite de sabores;
- calcular preços automaticamente;
- manter carrinho persistente;
- gerar pedido formatado;
- encaminhar pedido ao WhatsApp oficial da loja;
- permitir atualização comercial sem reescrever a interface;
- evoluir futuramente para um painel administrativo.

## 2. Princípio arquitetural central

O Modelo Mestre em `data/catalog-v1/` é a fonte oficial de dados comerciais.

Nenhum preço, produto, sabor, combo, contato ou regra comercial deve ficar espalhado no HTML ou duplicado em vários arquivos JavaScript.

## 3. Linha de chegada

O projeto será considerado pronto para publicação quando:

1. o Modelo Mestre for a única fonte de dados;
2. a montagem das caixas estiver funcional;
3. o carrinho estiver estável;
4. o checkout estiver validado;
5. a mensagem do WhatsApp estiver correta;
6. a interface estiver aprovada em celular e desktop;
7. os diagnósticos automáticos estiverem verdes;
8. o deploy for validado no GitHub Pages / Cloudflare Pages;
9. a documentação refletir o estado real do código.

## 4. Roadmap oficial

### Fase 0 — Fundação e governança

- [x] Criar governança técnica.
- [x] Criar Modelo Mestre.
- [x] Criar Marco Zero no Git.
- [x] Criar carregador do catálogo.
- [x] Criar validador do catálogo.
- [x] Criar View Model da vitrine.
- [x] Criar Catalog Service.
- [x] Fixar Live Server do Cardápio na porta 5501.
- [ ] Consolidar Plano Mestre, Metodologia e Automação.

### Fase 1 — Migração controlada do legado

- [ ] Inicializar Catalog Service no `app.js`.
- [ ] Substituir gradualmente `src/data.js`.
- [ ] Fazer a vitrine consumir exclusivamente o Modelo Mestre.
- [ ] Remover estruturas de caixas hardcoded.
- [ ] Remover fallback inseguro de WhatsApp.
- [ ] Isolar código legado que não pertence mais ao fluxo principal.

### Fase 2 — Motor de montagem de caixas

- [ ] Caixa 25.
- [ ] Caixa 35.
- [ ] Caixa 50.
- [ ] Caixa 100.
- [ ] Limite de sabores.
- [ ] Quantidade total obrigatória.
- [ ] Cálculo automático pelo preço dos sabores.
- [ ] Bloqueios e mensagens de validação.
- [ ] Caixa degustação como produto fechado.

### Fase 3 — Carrinho e pedido configurado

- [ ] Modelo de item configurado.
- [ ] Persistência no `localStorage`.
- [ ] Inclusão e remoção.
- [ ] Recalcular preços.
- [ ] Preservar versão do catálogo no pedido.

### Fase 4 — UX/UI Mobile First

- [ ] Vitrine orientada por dados.
- [ ] Imagens oficiais.
- [ ] Seletor de sabores.
- [ ] Feedback visual.
- [ ] Acessibilidade.
- [ ] Responsividade.
- [ ] Estados vazios/indisponíveis.

### Fase 5 — Checkout e WhatsApp

- [ ] Dados do cliente.
- [ ] Dados de entrega.
- [ ] Pagamento.
- [ ] Mensagem formatada.
- [ ] Destino exclusivo no WhatsApp oficial.
- [ ] Versão do catálogo no pedido.
- [ ] Testes de abertura do WhatsApp.

### Fase 6 — Automação, QA e pré-deploy

- [ ] Validação automática do catálogo.
- [ ] IDs duplicados.
- [ ] Referências quebradas.
- [ ] Imagens ausentes.
- [ ] Configuração da loja.
- [ ] Diagnóstico integrado.
- [ ] Checklist automático de pré-deploy.

### Fase 7 — Deploy

- [ ] Teste local completo.
- [ ] Teste em GitHub Pages.
- [ ] Comparação com versão publicada atual.
- [ ] Aprovação do usuário.
- [ ] Publicação.
- [ ] Rollback documentado.

### Fase 8 — Evolução futura

- [ ] Painel administrativo.
- [ ] Atualização comercial sem edição manual de JSON.
- [ ] Produtos sazonais.
- [ ] Combos.
- [ ] Integrações futuras.

## 5. Regra de mudança do plano

Qualquer alteração de metodologia, arquitetura, fonte de dados, processo de deploy ou sequência de desenvolvimento deve ser registrada em:

- `METODOLOGIA_DESENVOLVIMENTO.md`;
- `DECISOES_TECNICAS.md`;
- `STATUS.md`;
- `CHANGELOG.md`, quando aplicável.

O plano pode mudar, mas nunca silenciosamente.
