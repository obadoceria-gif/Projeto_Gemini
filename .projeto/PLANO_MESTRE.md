# Plano Mestre — Cardápio Virtual Oba Doceria

**Versão:** 2026-08-11-R1-marco-zero
**Status:** estratégia de preservação da produção aprovada

## Objetivo final
Entregar uma nova versão do Cardápio Virtual que preserve a experiência moderna já existente e substitua progressivamente dados e regras hardcoded por uma arquitetura orientada a dados.

## Regra de ouro
O repositório oficial de produção `https://github.com/obadoceria-gif/cardapio`, branch `main`, permanece intocado durante o desenvolvimento.

## Arquitetura de trabalho
PRODUÇÃO OFICIAL (intocável)
→ cópia controlada / Marco Zero
→ Projeto_Gemini
→ integração com Modelo Mestre + Catalog Service + View Model
→ testes
→ aprovação
→ somente então publicação controlada

## Fases
### R0 — Realinhamento
Concluído.

### R1 — Recuperação segura da UI oficial
1. registrar política de proteção da produção;
2. clonar a `main` somente para leitura;
3. registrar hash exato do commit de origem;
4. copiar a UI para `ui-oficial/` dentro do Projeto_Gemini;
5. executar localmente sem alterar o root atual;
6. comparar com GitHub Pages;
7. declarar Marco Zero quando houver paridade visual e funcional.

### R2 — Caixas
Substituir `caixasConfigs` por dados do Catalog Service.

### R3 — Sabores e categorias
Substituir `catalogo` hardcoded pelo Modelo Mestre.

### R4 — Kits e opcionais
Migrar presenteáveis e opcionais.

### R5 — Carrinho e checkout
Integrar estado, totais e persistência.

### R6 — WhatsApp e integrações
Centralizar telefone, mensagens e integrações externas.

### R7 — Limpeza do legado
Remover hardcodes, duplicações e código temporário.

### R8 — Qualidade e publicação
Responsividade, acessibilidade, performance, testes e deploy controlado.
