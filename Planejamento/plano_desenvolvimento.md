# Plano de Desenvolvimento — Oba Doceria

## 1. Objetivo
Criar uma especificação técnica para evoluir o cardápio online da Oba Doceria, priorizando:
- facilidade de manutenção e atualização de produtos
- separação entre dados e interface
- otimização do layout para uma experiência moderna, acolhedora e intuitiva
- suporte a pedido direto via WhatsApp e finalização na página

## 2. Análise Crítica do Código Atual
O código atual demonstra um projeto funcional e com visual atraente, mas apresenta pontos de melhoria importantes:

### 2.1. Estrutura monolítica
- HTML, CSS e JavaScript estão combinados em um único arquivo.
- Vários blocos de script são repetidos, incluindo funções idênticas para modal e carrinho.
- Isso dificulta correção de bugs, testes e evolução incremental.

### 2.2. Dados embarcados diretamente no código
- Catálogo de doces, configurações de caixa e kits estão codificados diretamente nos arrays JavaScript.
- Isso torna a inclusão de novos sabores, alterações de preço ou novos kits mais trabalhosa.
- Faltam formatos de dados simples e reutilizáveis para edição posterior.

### 2.3. Interface e experiência do usuário
- A navegação em várias seções é interessante, mas pode ficar confusa sem um fluxo mais claro.
- Há muitos modais e passos que precisam ser simplificados para melhorar a fluidez.
- O carrinho/hambiente mobile ainda depende de várias verificações manuais de estado.

### 2.4. Código duplicado e lógica dispersa
- Funções repetidas em blocos duplicados, especialmente no modal de conclusão e no carrinho.
- Muitas funções manipulam diretamente o DOM em vez de trabalhar com um modelo de estado central.
- Pode haver inconsistência entre elementos visuais e dados quando o estado muda.

### 2.5. Acessibilidade e robustez
- Inputs recebem pouca validação além de presença de valores.
- Mensagens de erro/validação são feitas com alertas e confirm dialogs.
- Elementos de foco e suporte a teclado não estão explícitos.

## 3. Proposta de Refatoração
A proposta deve seguir três frentes principais:

### 3.1. Separação de dados e visual
- Mover produtos, categorias, kits e configurações para um arquivo de dados separado ou estrutura JSON.
- Definir um objeto de estado central (`state`) que controle caixa ativa, selecionados, carrinho e filtros.
- Reduzir lógica inline no HTML e usar renderização dinâmica consistente.

### 3.2. Modularização do código
- Criar módulos ou blocos claros para:
  - navegação e fluxo de telas
  - modais
  - catálogo e filtros
  - carrinho e checkout
  - notificações
- Eliminar duplicação de funções e centralizar o controle do DOM em renderers específicos.

### 3.3. Otimização do layout
- Tornar o layout mais limpo e responsivo, com foco em:
  - hierarquia visual mais clara
  - botões de ação consistentes
  - fluxo de compra linear (escolher caixa → sabores → revisão → carrinho)
  - experiência mobile com elementos fixos nativos no rodapé
- Utilizar classes Tailwind com padrões reutilizáveis para evitar estilos inline redundantes.

## 4. Plano de Implementação
### 4.1. Refatorar estrutura do projeto
- [ ] Separar `index.html` em:
  - `index.html` com marcação básica e slots para seções
  - `styles.css` ou manter Tailwind com estilos customizados reduzidos
  - `app.js` como arquivo principal de comportamento
  - `data.js` ou `produtos.json` para catálogo e configurações
- [ ] Extrair todo o CSS custom do `<style>` para um arquivo de estilo dedicado.

### 4.2. Estrutura de dados
- [ ] Criar um arquivo de dados contendo:
  - `caixas` e suas propriedades
  - `kitsPresenteaveis`
  - `catalogo` de doces organizados por categoria
  - `opcionais` para kits (laço, placa)
- [ ] Garantir que os dados usem chaves consistentes (`id`, `nome`, `preco`, `img`, `categoria`).
- [ ] Incluir opcionais de configuração para novos sabores e imagens.

### 4.3. Fluxo de UI
- [ ] Definir claramente as páginas/etapas:
  1. Apresentação
  2. História/essência
  3. Escolha de experiência
  4. Fluxo de montagem ou kits
- [ ] Criar componentes de interface reutilizáveis para:
  - cards de sabor
  - cards de kit
  - botões de etapa
  - modais
- [ ] Validar automaticamente o progresso da caixa e exibir um resumo em tempo real.

### 4.4. Carrinho e checkout
- [ ] Centralizar o cálculo de valores e o armazenamento do carrinho.
- [ ] Simplificar o modal de checkout:
  - resumo de itens
  - formulário de entrega/telefone (ou apenas nome + data/hora + pagamento)
  - botão habilitado somente com dados completos
- [ ] Tornar o encerramento via WhatsApp mais confiável e legível.
- [ ] Preservar o carrinho em caso de navegação entre etapas, sem reiniciar o estado.

### 4.5. Melhoria de usabilidade
- [ ] Substituir `alert()` e `confirm()` por toast ou mensagens visuais no layout.
- [ ] Garantir textos de fallback quando imagens não carregam.
- [ ] Usar transições suaves e feedback visual nos botões.
- [ ] Exibir contagem de itens e valor em tempo real no mobile.

## 5. Tarefas de Prioridade
### Prioridade alta
- dados separados do código
- remoção de duplicação de funções
- reestruturação do fluxo de compra para evitar confusão
- centralização do estado do carrinho

### Prioridade média
- refatorar o layout mobile e o rodapé fixo
- melhorar a comunicação de erros/validação
- extração de templates HTML em funções de renderização

### Prioridade baixa
- otimizar animações e efeitos visuais
- detalhes extras de acessibilidade e internacionalização
- integração futura com CMS ou Google Sheets real

## 6. Entregáveis Esperados
- `Planejamento/plano_desenvolvimento.md` com especificação
- `index.html` limpo com marcação mínima e importação de scripts/estilos
- `data.js` ou `produtos.json` com catálogo e configurações
- `app.js` modular com fluxo de compra, modais e carrinho
- `styles.css` com ajustes visuais e padrão de marca

## 7. Recomendações Técnicas
- manter `Tailwind` para agilidade, mas reduzir classes customizadas repetidas
- usar `const`/`let` e evitar variáveis globais excessivas
- padronizar nomes em português para dados e IDs apenas quando fizer sentido
- documentar no `README.md` como atualizar produtos e imagens

## 8. Próximos Passos
1. Revisar o arquivo HTML atual e extrair o esquema de seções.
2. Criar o arquivo de dados e migrar o catálogo existente.
3. Reescrever os renderizadores de catálogo e modais com estado central.
4. Testar o fluxo completo de montagem de caixa, kits e checkout WhatsApp.
5. Ajustar layout responsivo e validar em mobile.

## 9. Manutenção do Catálogo e Segurança mínima

- Formato de edição: o catálogo foi movido para `data/products.json` para facilitar atualizações sem tocar no JavaScript. Cada item possui `id`, `nome`, `categoria`, `preco`, `img` e `disponivel`.
- Processo de publicação: crie uma branch, faça as alterações no `data/products.json`, abra um Pull Request e aguarde revisão antes de dar merge. Sempre gere um backup em `.auditoria/v_estavel/` antes de deploys.
- Validação: o frontend valida tipos e faixa de preço (número >= 0). Mesmo assim, preços exibidos no cliente são apenas referenciais — confirme manualmente via WhatsApp até integrar backend.
- Proteção básica: restrinja quem pode commitar no repositório, use revisão por pares e mantenha cópias estáveis em `.auditoria/v_estavel/` e em um branch de backup.

