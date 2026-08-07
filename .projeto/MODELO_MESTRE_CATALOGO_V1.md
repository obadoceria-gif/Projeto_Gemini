# MODELO MESTRE DE CATÁLOGO V1

**Status:** proposta implementada em arquivos, ainda não conectada à interface atual.  
**Local:** `data/catalog-v1/`

## Conteúdo migrado

- 6 categorias;
- 55 sabores;
- 6 configurações de caixas;
- 2 kits presenteáveis;
- 2 opcionais;
- estrutura preparada para combos;
- configuração comercial e versão do catálogo.

## Segurança da migração

Os arquivos existentes em `data/` e o código atual não foram substituídos. Isso evita quebrar a aplicação antes da implementação do novo carregador e do motor de regras.

## Próxima etapa

Criar um validador do Modelo Mestre e um serviço de catálogo que carregue exclusivamente `data/catalog-v1/`. Somente depois dos testes a fonte antiga deverá ser removida.
