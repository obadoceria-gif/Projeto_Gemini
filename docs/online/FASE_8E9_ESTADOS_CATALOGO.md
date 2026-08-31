# FASE 8E.9 — Estados do Catálogo

## Objetivo

Implementar uma camada segura de edição online na qual o catálogo
publicado nunca seja alterado diretamente durante uma edição.

Fluxo oficial:

RASCUNHO -> PREVIEW -> PUBLICADO

## Princípio central

Toda revisão do catálogo é imutável.

Uma alteração não modifica uma revisão anterior.
Ela cria uma nova revisão com:

- revision_id
- payload_json
- payload_sha256
- origem
- data de criação

Os estados operacionais são apenas ponteiros para revisões.

## Slots

### DRAFT

Representa a última revisão salva pelo administrador.

Salvar:

- cria nova revisão;
- move apenas DRAFT;
- não altera PREVIEW;
- não altera PUBLISHED.

### PREVIEW

Representa uma revisão explicitamente enviada para conferência.

Criar Preview:

- exige DRAFT válido;
- aponta PREVIEW para a revisão escolhida;
- não altera PUBLISHED.

### PUBLISHED

Representa a revisão oficial publicada pelo motor online.

Publicar:

- exige revisão previamente validada;
- altera PUBLISHED de forma atômica;
- registra a promoção;
- preserva a revisão publicada anterior.

## Rollback

Rollback não reescreve conteúdo.

Ele apenas promove novamente uma revisão histórica válida para
o slot PUBLISHED e registra a ação no log.

## Segurança

Operações de escrita deverão exigir:

- sessão administrativa válida;
- CSRF válido;
- método HTTP explicitamente permitido;
- validação estrutural do payload;
- SHA-256;
- revisão de origem conhecida;
- operação transacional;
- resposta fail-closed.

## Persistência

A persistência prevista é Cloudflare D1.

A FASE 8E.9A apenas prepara o schema e os contratos localmente.

Nenhum banco cloud é criado nesta subfase.

## Estado atual

A Central online permanece somente leitura.

A API atual GET continua sendo a referência funcional.

Nenhuma operação de:

- salvar;
- preview;
- publicar;
- rollback

é habilitada nesta subfase.

## Próximas subfases

### 8E.9B

Criar D1 no Workers Free e aplicar o schema.

### 8E.9C

Importar a versão atualmente publicada como primeira revisão imutável.

### 8E.9D

Implementar DRAFT e Salvar.

### 8E.9E

Implementar PREVIEW privado.

### 8E.9F

Implementar PUBLICAR de forma atômica.

### 8E.9G

Implementar rollback seguro.

### 8E.9H

Homologação completa do ciclo operacional.