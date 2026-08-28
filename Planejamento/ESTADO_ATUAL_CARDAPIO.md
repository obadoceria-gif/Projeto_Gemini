# Estado Atual do Cardápio

Atualizado em: 2026-08-28 00:39:50

## Situação geral

A Central de Gestão do Cardápio está funcional, homologada tecnicamente e aprovada visualmente.

Status consolidado:

- Central de Gestão: CONCLUÍDA E HOMOLOGADA
- CRUD de sabores: OK
- CRUD de categorias: OK
- CRUD de caixas: OK
- CRUD de produtos: OK
- CRUD de opcionais: OK
- CRUD de combos: OK
- Configurações da loja: OK
- Upload e preview de imagens: OK
- Arquivamento e reativação: OK
- Duplicação: OK
- Validações de dados: OK
- Rollback e preservação: OK
- Publicação real: HOMOLOGADA
- Smoke público: HOMOLOGADO
- Git/GitHub como fonte oficial: ATIVO
- PRE-CHANGE obrigatório: ATIVO
- Backup externo em OneDrive: ATIVO quando disponível

## Primeira edição real homologada

A alteração da descrição do sabor Cappuccino foi:

1. salva pela Central;
2. preservada por backup;
3. versionada na feature;
4. publicada na main;
5. validada no JSON público;
6. validada no cardápio público;
7. registrada em baseline recuperável.

Main homologada:
81ba7ca97783725f2df6281b13f745e4e554a8c0

Feature atual:
95aa97775d16888d44b0bb89df654a944d5b9f08

## Fluxo oficial de manutenção

1. Abrir a Central.
2. Criar ou editar item.
3. Salvar.
4. Visualizar cardápio.
5. Publicar alterações.
6. Aguardar validação automática.
7. Confirmar status "Tudo publicado".

O uso normal da Central não deve exigir edição manual de JSON, Git ou PowerShell.

## Regra obrigatória de preservação

Antes de qualquer alteração estrutural no projeto:

`powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\.scripts\CARDAPIO-pre-change.ps1" -Label "descricao-da-alteracao"
`

## Próximo objetivo do projeto

Retomar o desenvolvimento e fechamento do cardápio voltado ao cliente, sem continuar expandindo a Central sem necessidade.