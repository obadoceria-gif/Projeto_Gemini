# PROJECT BRIEF — Oba Doceria

## Objetivo

Disponibilizar um cardápio virtual para clientes e uma Central de Gestão privada para administração diária do catálogo.

O uso operacional final deve ser:

Entrar -> Editar -> Salvar rascunho -> Visualizar Preview -> Publicar.

A operação cotidiana não deve exigir VS Code, PowerShell, GitHub ou Cloudflare.

## Produtos

### Cardápio público

Permite visualizar produtos, sabores, caixas e opções, montar pedidos e seguir para atendimento.

### Central de Gestão

Administra sabores, categorias, caixas, produtos, opcionais, combos, configurações e futuramente mídia.

## Arquitetura alvo

Central privada
-> DRAFT
-> PREVIEW privado
-> PUBLISHED
-> Cardápio público.

Revisões são imutáveis. Slots DRAFT, PREVIEW e PUBLISHED apontam para revisões.

## Dados canônicos

- sabores -> flavors.json
- categorias -> categories.json
- caixas -> boxes.json
- produtos -> products.json
- opcionais -> options.json
- combos -> combos.json
- loja -> config.json

## Persistência online

Cloudflare D1:

- catalog_revisions
- catalog_slots
- catalog_promotions

## Princípios

Segurança, reversibilidade, versionamento, automação, zero edição direta de produção e preservação da última versão válida.
