# DOCUMENTAÇÃO MESTRE — CARDÁPIO OBA DOCERIA

## 1. Estado oficial

Status:

**PRODUÇÃO HOMOLOGADA E LIBERADA PARA CLIENTES**

URL oficial:

https://obadoceria-gif.github.io/Projeto_Gemini/

Repositório:

obadoceria-gif/Projeto_Gemini

Branch de produção:

main

Commit main no momento deste registro:

2fae67b

Tag de produção homologada:

cardapio-producao-2026-08-26

Commit da tag:

2fae67b

---

## 2. Baseline funcional

Arquivo principal:

ui-desenvolvimento/index.html

SHA256:

42F8968B159D3CF1E280FF325D6079B3CBB4E9B2BE202370F5017AF747B44299

Entrada pública:

index.html

O index.html da raiz direciona o cliente para:

ui-desenvolvimento/index.html

---

## 3. Arquitetura

Aplicação web estática.

Tecnologias principais:

- HTML5
- CSS3
- JavaScript Vanilla
- navegador
- localStorage
- integração com WhatsApp
- GitHub
- GitHub Pages

Não existe backend próprio nem banco de dados remoto para o fluxo atual.

---

## 4. Fluxo comercial homologado

Fluxo principal:

Entrada
→ seleção da caixa
→ escolha dos sabores
→ mínimo da caixa
→ carrinho
→ edição da caixa
→ salvar alterações
→ checkout
→ dados para entrega
→ WhatsApp

---

## 5. Regras homologadas

### Caixa personalizada

Mínimo comercial:

25 doces.

Acima de 25 doces:

permitido.

O cliente pode salvar alterações desde que o mínimo tenha sido atingido.

### Sabores

Existe limite de sabores conforme o tipo da caixa.

O indicador de existência de sabores adicionais foi homologado na R15.1.

### Edição

O cliente pode:

- aumentar quantidade;
- diminuir quantidade;
- remover sabores;
- escolher outros sabores;
- salvar alterações;
- cancelar alterações.

Salvar uma edição retorna ao carrinho.

### Carrinho

O carrinho permite:

- revisar caixa;
- editar caixa;
- continuar comprando;
- avançar para finalização.

### Checkout

Dados utilizados:

- nome;
- data;
- horário;
- forma de pagamento.

### WhatsApp

O pedido final é convertido em mensagem estruturada e encaminhado para o WhatsApp oficial.

---

## 6. Testes homologados

E2E comercial:

35/35 PASS.

UX R15.1:

11/11 PASS.

Debug R15.2:

12/12 PASS.

Smoke test público:

APROVADO.

Homologação visual mobile:

APROVADA.

---

## 7. Debug

Existe infraestrutura técnica de diagnóstico.

No acesso normal do cliente:

painéis técnicos permanecem ocultos.

Modo técnico:

?obaDebug=1

Esse modo não deve ser divulgado aos clientes.

---

## 8. Publicação

Hospedagem:

GitHub Pages.

Fonte:

main / root

URL:

https://obadoceria-gif.github.io/Projeto_Gemini/

Fluxo:

Git
→ origin/main
→ GitHub Pages
→ URL pública
→ smoke test.

---

## 9. Backup

A estratégia oficial de recuperação possui:

1. GitHub;
2. branch main;
3. tag de produção;
4. Git Bundle;
5. ZIP da produção;
6. cópia externa em OneDrive;
7. hashes SHA256.

O Git Bundle permite reconstruir o repositório Git mesmo se o repositório remoto original for perdido.

---

## 10. Segurança

A aplicação é pública e estática.

Não devem ser armazenados no código:

- senhas;
- tokens;
- chaves privadas;
- credenciais;
- dados bancários;
- dados sensíveis de clientes.

Principais classes de risco que devem permanecer monitoradas:

- XSS;
- innerHTML com entrada não sanitizada;
- manipulação indevida de parâmetros de URL;
- links externos;
- scripts externos;
- exposição de segredos;
- manipulação de localStorage;
- conteúdo HTTP dentro de HTTPS;
- comprometimento da conta GitHub.

Qualquer alteração futura deve executar auditoria automática de segurança antes da publicação.

---

## 11. Alterações futuras

Toda mudança deve partir da baseline homologada.

Fluxo obrigatório:

baseline
→ branch de desenvolvimento
→ alteração
→ testes automáticos
→ regressão
→ homologação
→ main
→ Pages
→ smoke público.

Nunca trabalhar diretamente sobre produção sem controle de versão.

---

## 12. Recuperação

Para recuperar exatamente esta versão:

git checkout cardapio-producao-2026-08-26

Para restaurar a partir do Git Bundle:

git clone <arquivo.bundle> Projeto_Gemini_restaurado

---

## 13. Regra de manutenção

Preservar sempre:

- montagem;
- regras de mínimo;
- sabores;
- edição;
- carrinho;
- checkout;
- WhatsApp;
- versão mobile;
- proteção dos elementos técnicos;
- testes automatizados.

Trabalho manual deve ser utilizado somente quando julgamento humano for realmente necessário.

---

## 14. Identificação desta documentação

Gerado em:

2026-08-26 19:03:36

Número de arquivos rastreados:

207

Baseline SHA256:

42F8968B159D3CF1E280FF325D6079B3CBB4E9B2BE202370F5017AF747B44299
---

## Fechamento de Segurança 2026-08-26

Status: **APROVADO E PUBLICADO**

### Hardening

- 3/3 links 	arget="_blank" protegidos por el="noopener noreferrer"
- window.open principal protegido com 
oopener,noreferrer
- R15.2: 12/12 contratos aprovados
- contratos funcionais centrais preservados
- HTTP local aprovado
- smoke público aprovado
- nenhum segredo evidente encontrado no secret scan

### Git

Commit de segurança:

196b3e6

Commit de segurança integrado em main:

129854cc0013b3d3cda8d949fb9ec3c7d15f24aa

Git blob oficial do arquivo ui-desenvolvimento/index.html:

8c3f51999d1553ba24ea61fa8528c7e9c2cc4b42

### Produção

https://obadoceria-gif.github.io/Projeto_Gemini/

### Integridade

O Git blob é a referência canônica entre worktrees.

O SHA256 do arquivo físico pode variar entre worktrees Windows
por normalização LF/CRLF sem representar alteração no conteúdo
versionado.

### Segurança

A versão passou pela auditoria e pelo hardening definidos neste
projeto. Isso reduz a superfície identificada de ataque, mas não
significa garantia absoluta contra todo ataque futuro.
