param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$branchEsperada = "feature/central-manutencao-cardapio"
$validator = Join-Path $root ".scripts\CARDAPIO-validar-catalogo.ps1"
$urlBase = "https://obadoceria-gif.github.io/Projeto_Gemini"
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$audit = Join-Path $root ".auditoria\Cardapio\PUBLISH_$stamp"
New-Item -ItemType Directory -Path $audit -Force | Out-Null
$report = Join-Path $audit "PUBLISH_RESULTADO.txt"

function Fail([string]$m){ throw $m }

$branch=(git branch --show-current).Trim()
if($branch -ne $branchEsperada){ Fail "Publicacao exige a branch $branchEsperada." }

git fetch origin --prune --quiet
if($LASTEXITCODE -ne 0){ Fail "git fetch falhou." }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator | Out-Null
if($LASTEXITCODE -ne 0){ Fail "Catalogo reprovado antes da publicacao." }

$status=@(git status --porcelain)
$permitidos=New-Object System.Collections.Generic.List[string]

foreach($linha in $status){
    if($linha.Length -lt 4){ continue }
    $path=$linha.Substring(3).Trim()

    if($path -match '^data/catalog-v1/[^/]+\.json$'){
        $permitidos.Add($path)
        continue
    }

    Fail "Alteracao inesperada impede publicacao: $path"
}

$alterados=@($permitidos | Sort-Object -Unique)

if($alterados.Count -eq 0){
    if($DryRun){
        Write-Host "[PASS] PUBLISH DRY-RUN: ambiente limpo e catalogo valido." -ForegroundColor Green
        exit 0
    }
    Fail "Nenhuma alteracao de catalogo para publicar."
}

# Backup independente antes do commit.
$backupDir=Join-Path $audit "backup"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

foreach($rel in $alterados){
    $src=Join-Path $root ($rel -replace '/','\')
    Copy-Item -LiteralPath $src -Destination (Join-Path $backupDir ([IO.Path]::GetFileName($rel))) -Force
}

if($DryRun){
    Write-Host "[PASS] PUBLISH DRY-RUN" -ForegroundColor Green
    Write-Host "Arquivos publicaveis: $($alterados.Count)"
    $alterados | ForEach-Object { Write-Host " - $_" }
    exit 0
}

# Stage somente JSON comerciais.
git add -- $alterados
if($LASTEXITCODE -ne 0){ Fail "git add falhou." }

$staged=@(git diff --cached --name-only)
$fora=@($staged | Where-Object { $_ -notmatch '^data/catalog-v1/[^/]+\.json$' })
if($fora.Count -gt 0){
    git reset
    Fail "Staging inesperado: $($fora -join ', ')"
}

git diff --cached --check
if($LASTEXITCODE -ne 0){
    git reset
    Fail "git diff --check reprovou."
}

git commit -m "content(cardapio): atualizar catalogo"
if($LASTEXITCODE -ne 0){ Fail "Commit do catalogo falhou." }

$commitCatalogo=(git rev-parse HEAD).Trim()

git push -u origin $branchEsperada
if($LASTEXITCODE -ne 0){ Fail "Push da branch de manutencao falhou." }

# Integra exclusivamente o commit de catalogo na main.
git fetch origin --quiet
$wt=Join-Path $env:TEMP ("oba-publish-"+[guid]::NewGuid().ToString("N"))
$mainCommit=$null
$tag=$null
$rollbackCommit=$null

try{
    git worktree add --detach $wt origin/main
    if($LASTEXITCODE -ne 0){ Fail "Nao foi possivel preparar main temporaria." }

    Push-Location $wt
    try{
        git cherry-pick $commitCatalogo
        if($LASTEXITCODE -ne 0){
            git cherry-pick --abort 2>$null
            Fail "Cherry-pick do catalogo falhou."
        }

        $mainCommit=(git rev-parse HEAD).Trim()

        git push origin HEAD:main
        if($LASTEXITCODE -ne 0){ Fail "Push para main falhou." }

        # Smoke semantico dos JSON publicados.
        $smokeOK=$false
        $erroSmoke=""

        for($tentativa=1;$tentativa -le 24;$tentativa++){
            $todosOK=$true

            foreach($rel in $alterados){
                $nome=[IO.Path]::GetFileName($rel)
                $localPath=Join-Path $wt ($rel -replace '/','\')

                try{
                    $localObj=[IO.File]::ReadAllText($localPath) | ConvertFrom-Json
                    $localCanon=$localObj | ConvertTo-Json -Depth 30 -Compress

                    $publicUrl="$urlBase/$rel?cb=$([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())"
                    $resp=Invoke-WebRequest -Uri $publicUrl -UseBasicParsing -TimeoutSec 20 `
                        -Headers @{"Cache-Control"="no-cache";"Pragma"="no-cache"}

                    if($resp.StatusCode -ne 200){ throw "$nome HTTP $($resp.StatusCode)" }

                    $publicObj=$resp.Content | ConvertFrom-Json
                    $publicCanon=$publicObj | ConvertTo-Json -Depth 30 -Compress

                    if($publicCanon -ne $localCanon){
                        $todosOK=$false
                        $erroSmoke="$nome ainda nao propagou"
                        break
                    }
                }
                catch{
                    $todosOK=$false
                    $erroSmoke=[string]$_.Exception.Message
                    break
                }
            }

            if($todosOK){
                $smokeOK=$true
                break
            }

            Start-Sleep -Seconds 10
        }

        if(-not $smokeOK){
            # Rollback automatico da main se a publicacao nao puder ser confirmada.
            git revert --no-edit $mainCommit
            if($LASTEXITCODE -eq 0){
                $rollbackCommit=(git rev-parse HEAD).Trim()
                git push origin HEAD:main
            }
            Fail "Smoke publico falhou; rollback solicitado. Detalhe: $erroSmoke"
        }

        # Tag somente apos smoke aprovado.
        $tag="cardapio-catalogo-"+(Get-Date -Format "yyyyMMdd-HHmmss")
        git tag -a $tag $mainCommit -m "Catalogo Oba Doceria publicado"
        if($LASTEXITCODE -ne 0){ Fail "Criacao de tag falhou." }

        git push origin "refs/tags/$tag"
        if($LASTEXITCODE -ne 0){ Fail "Push da tag falhou." }
    }
    finally{
        Pop-Location
    }
}
finally{
    if(Test-Path -LiteralPath $wt){
        git worktree remove --force $wt 2>$null
    }
    git worktree prune 2>$null
}

$resultado=@"
PUBLICACAO DO CATALOGO

STATUS:
APROVADO

COMMIT FEATURE:
$commitCatalogo

COMMIT MAIN:
$mainCommit

TAG:
$tag

ARQUIVOS:
$($alterados -join "`r`n")

SMOKE PUBLICO:
APROVADO

BACKUP:
$backupDir
"@

[IO.File]::WriteAllText($report,$resultado,[Text.UTF8Encoding]::new($false))

Write-Host "====================================================" -ForegroundColor Green
Write-Host " CATALOGO PUBLICADO COM SUCESSO" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host "Commit main: $mainCommit"
Write-Host "Tag: $tag"
Write-Host "Relatorio: $report"