# Arquitetura

**Versão:** 1.0  
**Última atualização:** 06/08/2026  
**Status:** Arquitetura atual auditada e arquitetura-alvo proposta

## Stack

- HTML5;
- CSS3;
- JavaScript Vanilla com módulos ES6;
- JSON para catálogo e configuração;
- `localStorage` para persistência local;
- Git e GitHub;
- GitHub Pages ou Cloudflare Pages.

## Estrutura atual

```text
Projeto_Gemini/
├── index.html
├── src/
│   ├── app.js
│   ├── data.js
│   ├── styles.css
│   └── data/
├── data/
├── Planejamento/
├── Execucao/
├── .auditoria/
├── .projeto/
├── README.md
└── STATUS.md
```

## Fluxo atual observado

```text
index.html
  ↓
src/app.js
  ├── src/data.js
  └── src/data/config.js
```

A implementação atual possui fontes de catálogo concorrentes e contratos de dados incompatíveis. Por isso, a interface ainda não pode ser considerada estável.

## Arquitetura-alvo

```text
index.html
  ↓
src/app.js
  ↓
src/services/
  ├── catalog-service.js
  ├── cart-service.js
  ├── checkout-service.js
  └── validation-service.js
  ↓
data/
  ├── config.json
  ├── categories.json
  ├── flavors.json
  ├── boxes.json
  ├── products.json
  ├── combos.json
  └── options.json
  ↓
assets/images/
```

## Responsabilidades

- `index.html`: estrutura mínima e ponto de entrada.
- `src/app.js`: inicialização e coordenação da interface.
- `src/services/`: regras de carregamento, carrinho, validação e checkout.
- `data/`: conteúdo comercial editável.
- `assets/images/`: imagens do catálogo.
- `.projeto/`: memória técnica e governança.
- `Planejamento/`: planejamento temporal e roadmap.
- `STATUS.md`: estado operacional atual.

## Regras arquiteturais

1. produtos, preços, sabores, contatos e combos não podem ficar fixados no HTML;
2. deve existir uma única fonte oficial para cada tipo de dado;
3. IDs comerciais devem permanecer estáveis;
4. caminhos devem funcionar em subdiretórios do GitHub Pages;
5. regras de negócio não devem ficar misturadas ao código de apresentação;
6. qualquer painel administrativo futuro deverá alimentar o mesmo modelo de dados;
7. o repositório publicado antigo permanece como referência até o aceite da nova versão.
