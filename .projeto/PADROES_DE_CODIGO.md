# Padrões de Código

**Versão:** 1.0  
**Última atualização:** 06/08/2026

## Princípios

- simplicidade antes de abstração excessiva;
- Mobile First;
- JavaScript Vanilla;
- separação entre conteúdo, regra e apresentação;
- acessibilidade e desempenho como requisitos;
- nenhuma dependência sem benefício claro.

## JavaScript

- usar módulos ES6;
- nomes de funções e variáveis em inglês ou português, mas sem mistura dentro do mesmo domínio;
- preferir funções pequenas e com responsabilidade única;
- evitar estado global disperso;
- validar dados externos antes do uso;
- não inserir dados comerciais fixos no código;
- tratar erros de carregamento com mensagens úteis;
- não usar o telefone do cliente como destino do WhatsApp.

## JSON

- IDs em minúsculas, sem acentos e com hífens;
- preços como números;
- datas em `YYYY-MM-DD`;
- não apagar registros históricos apenas porque ficaram indisponíveis;
- usar `ativo` e `disponivel` com significados distintos;
- manter uma versão do catálogo.

## CSS

- Mobile First;
- evitar estilos inline;
- usar nomes de classes consistentes;
- preservar contraste e legibilidade;
- garantir áreas de toque adequadas;
- evitar efeitos que prejudiquem desempenho ou navegação.

## HTML

- HTML semântico;
- um único `h1` principal;
- imagens com `alt` adequado;
- formulários com rótulos e mensagens de erro;
- estrutura mínima, gerada por dados quando apropriado.

## Git

- um objetivo por commit;
- revisar `git diff` antes do commit;
- não versionar segredos;
- não publicar a nova versão sem checklist de aceite;
- mensagens de commit claras, por exemplo:

```text
docs: adiciona governança inicial do projeto
fix: corrige destino do WhatsApp
feat: adiciona modelo mestre de sabores
```
