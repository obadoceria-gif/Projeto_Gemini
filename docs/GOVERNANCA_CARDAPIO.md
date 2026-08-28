# Governança e preservação do Cardápio Oba

## Fonte oficial

O Git/GitHub é a fonte oficial do projeto.

Branch de manutenção da Central:

\eature/central-manutencao-cardapio\

A produção continua separada e não deve ser alterada diretamente por rotinas de manutenção.

## Regra obrigatória antes de qualquer alteração

Executar:

\\\powershell
cd C:\Users\pc_fa\Documents\Projeto_Gemini
& ".\.scripts\CARDAPIO-pre-change.ps1" -Label "descricao-da-alteracao"
\\\

O Gate PRE-CHANGE exige workspace limpo e sincronizado com o remoto. Em seguida cria:

- Git bundle completo;
- ZIP do HEAD versionado;
- manifesto/checkpoint;
- segunda cópia no OneDrive quando disponível.

Se o PRE-CHANGE falhar, a alteração não deve começar.

## Fluxo padrão de mudança

1. PRE-CHANGE.
2. Aplicar alteração somente na branch adequada.
3. Testes automáticos.
4. Preview/homologação quando houver UI.
5. Commit somente após aprovação.
6. Push para GitHub.
7. Publicação somente por rotina homologada.
8. Smoke público.
9. Rollback em qualquer Gate reprovado.

## Política de arquivos

### Devem ficar no Git/GitHub

- código do cardápio;
- Central de Gestão;
- JSON comerciais;
- imagens usadas pelo catálogo;
- scripts permanentes \CARDAPIO-*.ps1\;
- testes permanentes;
- documentação permanente;
- histórico Git e tags.

### Não devem ficar no Git/GitHub

- \.auditoria/\;
- instaladores temporários \FASE*.ps1\;
- ZIPs e bundles gerados;
- logs;
- caches;
- workspace histórico local;
- relatórios transitórios.

## Backup externo

OneDrive é contingência de desastre, não fonte de trabalho.

A cópia externa deve conter checkpoints, bundles e arquivos de recuperação gerados automaticamente.

## Recuperação

### Recuperar pelo GitHub

Clonar o repositório e fazer checkout do commit/tag homologado.

### Recuperar por Git bundle

\\\powershell
git clone "CAMINHO_DO_BUNDLE" Projeto_Gemini_RECUPERADO
\\\

### Recuperar um arquivo

Usar Git para restaurar o arquivo a partir do commit homologado:

\\\powershell
git restore --source=<commit> -- caminho/do/arquivo
\\\

## Limpeza segura

Simular:

\\\powershell
& ".\.scripts\CARDAPIO-limpeza-segura.ps1"
\\\

Arquivar candidatos:

\\\powershell
& ".\.scripts\CARDAPIO-limpeza-segura.ps1" -Execute
\\\

A rotina arquiva; não apaga definitivamente.