# MATRIZ DE TESTES

## Regra
Toda promocao deve registrar testes executados.

## Mobile
### Viewports
- [ ] 360px
- [x] 390px
- [ ] 430px

### Degustacao
- [x] Selecionar 12
- [x] Selecionar 25
- [x] Preco correto
- [x] Lightbox
- [x] Comparacao 12/25
- [x] Adicionar ao carrinho
- [x] Badge atualizado
- [x] Abrir carrinho

### Caixa normal
- [x] Selecionar tamanho
- [x] Montar sabores
- [x] Completar capacidade
- [x] Adicionar diretamente ao carrinho
- [x] Badge atualizado
- [x] Sem modal intermediario automatico

### Carrinho
- [x] Um item
- [x] Multiplos itens
- [x] Alterar quantidade
- [x] Remover item
- [x] Total consolidado
- [x] Continuar comprando
- [x] Abrir fechamento
- [ ] Testar muitos itens com lista interna rolavel

### Checkout
- [x] Nome
- [x] Data
- [x] Hora
- [x] Pagamento
- [ ] Separar checkout do carrinho
- [ ] Validacao completa de campos

### Console
- [x] Correcao do TypeError mobile-total/mobile-label
- [ ] Auditoria completa sem erros apos R1.17

## Desktop
- [x] Fluxo basico funcional
- [ ] Revisao responsiva completa apos R1.17
## R1.17-A - Fluxo por etapas

### Degustacao
- [x] Tela de escolha em viewport mobile
- [x] Seletor 12
- [x] Seletor 25
- [x] Continuar desabilitado sem escolha
- [x] Continuar habilitado apos escolha
- [x] Selecionar nao altera badge do carrinho
- [x] Tela de revisao separada
- [x] Voltar e alterar
- [x] Escolha preservada ao voltar
- [x] Salvar somente por acao explicita
- [x] Preco e quantidade na revisao
- [x] Acoes principais acessiveis sem procurar por rolagem
- [x] Console sem TypeError

### Proximo teste
R1.17-B:
- [ ] Carrinho com 1 item
- [ ] Carrinho com 2 itens
- [ ] Carrinho com muitos itens
- [ ] Header persistente
- [ ] Footer persistente
- [ ] Lista interna rolavel
## R1.17-B - Carrinho em viewport

- [x] Abrir carrinho pelo icone global
- [x] Header persistente
- [x] Footer persistente
- [x] Total sempre visivel
- [x] Continuar comprando sempre visivel
- [x] Ir para finalizacao sempre visivel
- [x] 1 produto
- [x] 2 produtos
- [x] 5 produtos
- [x] Produtos e unidades separados
- [x] Numeracao visual
- [x] Aumentar quantidade
- [x] Reduzir quantidade
- [x] Remover produto
- [x] Atualizacao de total
- [x] Lista central rolavel
- [x] Indicador de produtos abaixo
- [x] Indicador nao cobre footer
- [x] Scroll suave
- [x] Acessibilidade de foco revisada

### Proximo teste
R1.17-C:
- [ ] checkout em viewport propria
- [ ] nome
- [ ] data
- [ ] hora
- [ ] pagamento
- [ ] resumo compacto
- [ ] validacoes
- [ ] finalizacao

<!-- R1.17-C-TESTES -->

## Testes R1.17-C

**Resultado geral: APROVADO**

Validações executadas:

- abertura da etapa própria de checkout: OK;
- resumo de 2 produtos / 2 unidades: OK;
- cálculo do total: OK;
- preenchimento do nome: OK;
- preenchimento da data: OK;
- preenchimento da hora: OK;
- seleção da forma de pagamento: OK;
- retorno ao carrinho: OK;
- retorno ao checkout: OK;
- preservação dos itens: OK;
- FINALIZAR PEDIDO: OK;
- abertura do WhatsApp: OK;
- TypeError no console: NÃO IDENTIFICADO.

Teste visual realizado em viewport mobile.

## R1.17-D - Continuidade do fluxo

- [x] Candidato isolado
- [x] Carrinho abre normalmente
- [x] Proxima etapa indicada
- [x] Ir para finalizacao
- [x] Checkout em tela propria
- [x] Contexto de progresso
- [x] Voltar ao carrinho
- [x] Produtos preservados
- [x] Total preservado
- [x] Retornar ao checkout
- [x] Nome
- [x] Data
- [x] Hora
- [x] Pagamento
- [x] Finalizar pedido
- [x] WhatsApp
- [x] Console sem TypeError

### Proximo ciclo
R1.18:
- [ ] auditoria do fluxo completo;
- [ ] inconsistencias remanescentes;
- [ ] regressao funcional;
- [ ] mobile real;
- [ ] desktop;
- [ ] preparacao de baseline consolidada.

## R1.18-C - CONSOLIDACAO FINAL

Data: 2026-08-16 21:39:51

### Resultado
- R1.18-A: auditoria consolidada aprovada.
- 67 checks executados.
- 67 checks aprovados.
- 0 falhas estruturais.
- R1.18-B: regressao funcional aprovada em navegador real.
- Fluxo validado: produto -> carrinho -> checkout -> voltar -> checkout -> WhatsApp.
- Carrinho preservou produtos, quantidades, subtotais e total.
- Checkout preservou o estado comercial.
- Validacoes de entrega verificadas.
- Finalizacao via WhatsApp verificada.
- Nenhum erro funcional observado no console durante a regressao.
- UX mobile consolidada.
- Carrinho em viewport propria consolidado.
- Checkout em etapa propria consolidado.
- Continuidade entre etapas consolidada.

### Decisao
R1.18 consolidada sobre o fluxo oficial.

### Seguranca
- promocao controlada;
- candidato temporario removido;
- documentacao versionada;
- push nao executado.

## R1.19-B01 — regressão funcional

Resultado: APROVADO.

Validado:
- finalização de pedido;
- abertura do WhatsApp;
- dados do pedido preservados;
- cliente, entrega e pagamento preservados;
- itens e total preservados;
- ausência de TypeError/ReferenceError no fluxo testado;
- proteção contra acionamentos repetidos.

Observação:
404 de favicon não relacionado ao checkout/R1.19-B01.
## R1.19-D — regressão funcional

Resultado: APROVADO.

Testado:
- inclusão de produto;
- modal persistente de confirmação;
- continuar após inclusão;
- abertura do carrinho;
- continuar comprando;
- lixeira com um toque;
- manter item;
- remover item;
- remoção do último item;
- fechamento e reabertura do carrinho;
- controle de foco do modal;
- controle de foco da viewport do carrinho.

Console:
- nenhum TypeError;
- nenhum ReferenceError;
- nenhum aviso Blocked aria-hidden após correções A11Y.

Observação conhecida:
favicon.ico 404 permanece independente desta implementação.
## R1.20-B01 — regressão funcional

Resultado: APROVADO.

Fluxo 1 — montagem:
- montagem incompleta;
- tentativa de saída;
- voltar à montagem;
- repetir fluxo;
- descartar montagem;
- comportamento correto.

Fluxo 2 — quantidade:
- quantidade inicial 1;
- redução para zero;
- manter item;
- repetir fluxo;
- remover item;
- comportamento correto.

Validação estrutural:
- chamadas nativas antes: 2;
- chamadas nativas depois: 0.

Console:
- nenhum TypeError;
- nenhum ReferenceError;
- nenhum Blocked aria-hidden.
============================================================
R1.20-B02 - ZERO alert() NATIVO + FEEDBACK INTEGRADO
Data: 2026-08-17 22:39:23
============================================================

RESULTADO:
- 4 alert() nativos eliminados.
- Checkout sem produtos migrado para feedback integrado.
- Checkout incompleto migrado para feedback integrado.
- Personalizados incompleto migrado para feedback integrado.
- Eventos incompleto migrado para feedback integrado.
- Modal reutilizavel R1.19-D preservado.
- Foco contextual preservado.
- Fluxos WhatsApp de Personalizados e Eventos preservados.

CORRECAO WPP1:
- Identificado window.open() da finalizacao dentro de fetch.finally().
- Adicionado mecanismo robusto de abertura do WhatsApp.
- Primeira tentativa: window.open().
- Fallback: window.location.assign().
- Teste funcional aprovado.
- WhatsApp abriu corretamente ao finalizar pedido.

VALIDACAO:
- alert() nativo restante: 0.
- R1.20-B01 preservado.
- R1.19-D preservado.
- Carrinho preservado.
- Checkout preservado.
- Acessibilidade preservada.
- Teste funcional aprovado.

STATUS:
CONCLUIDO E APROVADO.

PROXIMA ACAO:
R1.20-B03 - PROXIMO ITEM PRIORIZADO DO BACKLOG.
============================================================
## R1.20-B03 — asset Degustação 25 Sabores

Data: 2026-08-17 23:51:03

Status: encerrado tecnicamente / pendência externa de conteúdo.

Diagnóstico:
- Degustacao_12_Sabores.jpeg e Degustacao_25_Sabores.jpeg possuem conteúdo binário idêntico;
- inventário visual completo do ui-desenvolvimento analisado;
- 82 imagens físicas;
- 81 conteúdos únicos;
- nenhuma fotografia correta da Caixa Degustação 25 Sabores foi localizada.

Decisão:
- não reutilizar conscientemente a fotografia da caixa de 12 sabores como solução definitiva;
- não gerar ou inventar fotografia substituta;
- não substituir por asset sem autenticação;
- manter a referência atual até que a fotografia oficial correta seja fornecida;
- classificar a correção como dependência externa de conteúdo, não como bloqueio técnico.

Próxima ação:
R1.20-B04 — próximo gap técnico real do backlog.