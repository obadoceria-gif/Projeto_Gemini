# AUTOMAÇÃO DO PROJETO

**Versão:** 1.0  
**Status:** Ativa  
**Última atualização:** 2026-08-10

## 1. Objetivo

Reduzir trabalho manual repetitivo, diminuir erros humanos e acelerar a evolução do Cardápio Virtual.

## 2. Regra principal

Sempre que uma tarefa puder ser validada ou executada automaticamente de forma confiável, a automação terá preferência sobre conferência manual.

## 3. Ambiente atual

Ferramentas confirmadas:

- VS Code;
- Git;
- Live Server;
- navegador.

Não disponíveis ou não confiáveis atualmente:

- Node.js;
- npm/npx;
- Python;
- scripts PowerShell `.ps1` dependentes de política de execução.

Por isso, a automação será priorizada com:

- JavaScript ES Modules;
- páginas de diagnóstico;
- APIs nativas do navegador;
- tarefas do VS Code quando apropriado;
- Git.

## 4. Automação já implementada

### Catálogo
`diagnostics/catalog-check.html`

### View Model
`diagnostics/view-model-check.html`

### Catalog Service
`diagnostics/catalog-service-check.html`

## 5. Backlog de automação

### Alta prioridade

- diagnóstico único que execute todos os diagnósticos;
- checagem de IDs duplicados;
- checagem de referências de categorias;
- checagem de opcionais inexistentes;
- checagem de WhatsApp;
- checagem de preços inválidos;
- checagem de imagens;
- checagem de arquivos obrigatórios.

### Média prioridade

- relatório automático de status do catálogo;
- comparação entre versões do catálogo;
- checklist de pré-deploy;
- relatório de alterações comerciais.

### Futuro

- painel administrativo;
- publicação do catálogo sem edição manual de JSON;
- importação/atualização assistida de catálogo.

## 6. Objetivo operacional

Chegar a um ponto em que uma atualização comercial siga:

```text
Editar dados
→ abrir diagnóstico integrado
→ corrigir qualquer erro
→ revisar visualmente
→ commit
→ deploy
```
