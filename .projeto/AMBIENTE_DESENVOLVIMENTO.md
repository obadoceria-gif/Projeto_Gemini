# Ambiente de Desenvolvimento

**Versão:** 1.0  
**Última atualização:** 06/08/2026  
**Status:** Ambiente local ainda não padronizado

## Pasta local auditada

```text
C:\Users\pc_fa\Documents\Projeto_Gemini
```

## Git

- repositório remoto atual do projeto em desenvolvimento: `obadoceria-gif/Projeto_Gemini`;
- branch auditada: `feature/cardapio-whatsapp-20260805-0004`;
- repositório original publicado: `obadoceria-gif/cardapio`.

## Ferramentas detectadas

- Git instalado;
- Node.js não detectado;
- npm/npx não detectados;
- Python não detectado;
- execução de scripts PowerShell bloqueada pela política local.

## Requisito de servidor HTTP

O projeto utiliza módulos ES6 e possui carregamento de dados por `fetch` em partes da arquitetura. Portanto, não se deve considerar `file://` como ambiente oficial de teste.

## Recomendação

Instalar a extensão **Live Server** no VS Code ou instalar uma versão LTS do Node.js. A opção mais simples para o usuário é o Live Server.

URL típica com Live Server:

```text
http://127.0.0.1:5500/
```

A porta pode variar.

## Fluxo de teste local

1. abrir a pasta raiz no VS Code;
2. iniciar um servidor HTTP na raiz;
3. abrir a URL local;
4. testar em largura mobile e desktop;
5. abrir o console do navegador;
6. validar catálogo, carrinho e WhatsApp;
7. somente então preparar commit.

## Deploy

A versão antiga continuará publicada enquanto a nova estiver em desenvolvimento. O deploy da nova versão só será configurado após estabilização e aceite.
