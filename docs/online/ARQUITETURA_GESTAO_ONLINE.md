# FASE 8 — Gestão Online Segura

## Princípio fundamental

A versão local homologada anterior à Fase 8 permanece preservada e nunca
é sobrescrita durante o desenvolvimento da arquitetura online.

Baseline preservada:
- commit: 26feb44
- tag: cardapio-local-estavel-20260829

## Arquitetura alvo

### Cardápio público

Endereço sugerido:

cardapio.<dominio-oficial>

Acesso:
- público
- sem login
- sempre aponta para a última versão homologada

### Gestão

Endereço sugerido:

gestao.<dominio-oficial>

Acesso:
- privado
- login obrigatório
- Cloudflare Access
- somente usuários autorizados

### Preview

Endereço sugerido:

preview.<dominio-oficial>

Acesso:
- privado
- login obrigatório
- usado para homologação antes da publicação

## Plataforma

Cloudflare Workers:
- aplicação pública
- aplicação administrativa
- API
- publicação
- versionamento

Cloudflare D1:
- sabores
- categorias
- caixas
- produtos
- opcionais
- combos
- configurações
- versões
- auditoria
- estado de rascunho/publicação

Cloudflare R2:
- fotos dos sabores
- imagens de produtos
- imagens de combos
- demais arquivos de mídia

Cloudflare Access:
- autenticação do painel de gestão
- autenticação do preview
- usuários autorizados
- OTP ou provedor de identidade

GitHub:
- código-fonte
- histórico técnico
- releases
- documentação
- exportações de segurança

## Estados do catálogo

RASCUNHO
Alterações ainda não visíveis aos clientes.

PREVIEW
Visualização privada do rascunho.

PUBLICADO
Versão ativa para clientes.

ARQUIVADO
Versão antiga preservada para histórico/rollback.

## Fluxo de publicação

Editar
-> salvar rascunho
-> validar automaticamente
-> visualizar preview
-> homologar
-> publicar
-> criar versão
-> marcar como última versão válida

Produção nunca é sobrescrita antes da aprovação.

## Rollback

Toda publicação deve possuir:
- ID da versão
- data/hora
- usuário
- snapshot dos dados
- referência ao commit/deploy
- opção de restauração

Rollback deve promover uma versão anterior já validada.

## Modo manutenção

Não é automático.

Estados previstos:
- Normal
- Aviso informativo
- Manutenção

A edição normal não coloca o cardápio em manutenção.

## Alterações de layout

Mudanças visuais serão feitas em blocos isolados.

Fluxo obrigatório:

versão válida
-> branch
-> bloco isolado
-> alteração
-> testes
-> preview
-> aprovação visual
-> publicação
-> nova versão válida

Mudança visual e mudança de regra de negócio devem ser separadas sempre
que possível.

## Segurança

Nunca:
- armazenar senha no JavaScript
- expor token no navegador
- editar produção diretamente
- substituir a última versão válida
- publicar sem validação

Sempre:
- autenticação no servidor/borda
- backup
- versionamento
- preview
- auditoria
- rollback
