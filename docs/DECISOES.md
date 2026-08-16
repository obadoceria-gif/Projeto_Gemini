# DECISOES DE ARQUITETURA E UX

## D001 - Mobile First
Status: aprovado

Toda nova interface deve ser projetada primeiro para celular.

Referencias de teste:
- 360px
- 390px
- 430px
- 768px
- 1024px+

Desktop e expansao da experiencia mobile.

---

## D002 - Modelo Mestre
Status: aprovado

Configuracoes comerciais e estruturais devem vir do Modelo Mestre sempre que aplicavel.

Evitar duplicacao de regras no HTML.

---

## D003 - Carrinho unico
Status: aprovado

carrinhoDeCaixasConcluidas permanece como fonte de verdade para itens salvos.

Nao criar mini-carrinhos paralelos.

---

## D004 - Acesso global ao carrinho
Status: aprovado

O carrinho deve ser acessivel por icone global com badge.

O painel grande de carrinho nao deve ocupar permanentemente paginas de selecao.

---

## D005 - Produto selecionado nao significa produto salvo
Status: aprovado

Selecao e apenas estado temporario.

O badge do carrinho so aumenta depois da inclusao real do item.

---

## D006 - Fluxo por etapas
Status: aprovado para R1.17

Mobile deve evoluir para:

Selecao
-> Revisao do produto
-> Carrinho
-> Checkout
-> Finalizacao

---

## D007 - Rolagem
Status: aprovado

Nao tentar proibir toda rolagem.

Regra:
- evitar rolagem para descobrir a proxima acao;
- acoes principais sempre visiveis;
- listas extensas podem ter rolagem interna;
- evitar rolagem vazia.

---

## D008 - Automacao
Status: aprovado

Tudo que puder ser automatizado deve ser automatizado.

Auditorias devem gerar relatorios automaticamente.

Alteracoes de codigo devem ser entregues em blocos completos quando possivel.

---

## D009 - Documentacao obrigatoria
Status: aprovado

Cada baseline aprovada deve atualizar:
- STATUS.md
- CHANGELOG.md
- ROADMAP.md
- DECISOES.md quando aplicavel
- TESTES.md
- REGISTRO-DE-ACOES.md

---

## D010 - Imagens da Degustacao
Status: pendencia de conteudo

Os arquivos:
- Degustacao_12_Sabores.jpeg
- Degustacao_25_Sabores.jpeg

possuem nomes distintos, mas atualmente possuem conteudo identico.

O codigo permanece preparado para imagens distintas.
---

## D011 - Revisao de produto em etapa propria
Status: aprovado

No mobile, quando uma escolha comercial estiver concluida, o resumo e as decisoes seguintes devem preferencialmente ocupar uma etapa propria.

Padrao aprovado na R1.17-A:

Escolha
-> Revisao do produto
-> Acao explicita
-> Carrinho ou continuidade

Beneficios:
- reduz rolagem desnecessaria;
- separa selecao de confirmacao;
- mantem a proxima acao visivel;
- permite reutilizar o padrao em outras categorias.