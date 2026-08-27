param([switch]$DryRun)

$ErrorActionPreference = "Stop"

$root=Split-Path -Parent $PSScriptRoot
Set-Location $root

$branchEsperada="feature/central-manutencao-cardapio"
$validator=Join-Path $root ".scripts\CARDAPIO-validar-catalogo.ps1"
$urlBase="https://obadoceria-gif.github.io/Projeto_Gemini"
$stamp=Get-Date -Format "yyyyMMdd_HHmmss"
$audit=Join-Path $root ".auditoria\Cardapio\PUBLISH_$stamp"
New-Item -ItemType Directory -Path $audit -Force | Out-Null
$report=Join-Path $audit "PUBLISH_RESULTADO.txt"

function Fail([string]$m){ throw $m }

$branch=(git branch --show-current).Trim()
if($branch -ne $branchEsperada){ Fail "Publicacao exige a branch $branchEsperada." }

git fetch origin --prune --quiet
if($LASTEXITCODE -ne 0){ Fail "git fetch falhou." }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator | Out-Null
if($LASTEXITCODE -ne 0){ Fail "Catalogo reprovado." }

$status=@(git status --porcelain)
$permitidos=@()

foreach($line in $status){
    if($line.Length -lt 4){ continue }
    $path=$line.Substring(3).Trim()

    if($path -match '^data/catalog-v1/[^/]+\.json$'){ $permitidos += $path; continue }
    if($path -match '^Images/Catalogo/.+\.(jpg|jpeg|png|webp)$'){ $permitidos += $path; continue }

    Fail "Alteracao inesperada impede publicacao: $path"
}

$alterados=@($permitidos|Sort-Object -Unique)

if($alterados.Count -eq 0){
    if($DryRun){
        Write-Host "[PASS] PUBLISH DRY-RUN: ambiente limpo e catalogo valido." -ForegroundColor Green
        exit 0
    }
    Fail "Nenhuma alteracao para publicar."
}

$backupDir=Join-Path $audit "backup"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
foreach($rel in $alterados){
    $src=Join-Path $root ($rel -replace '/','\')
    if(Test-Path -LiteralPath $src){
        $dst=Join-Path $backupDir ($rel -replace '/','__')
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }
}

if($DryRun){
    Write-Host "[PASS] PUBLISH DRY-RUN" -ForegroundColor Green
    $alterados|ForEach-Object{Write-Host " - $_"}
    exit 0
}

git add -- $alterados
if($LASTEXITCODE -ne 0){ Fail "git add falhou." }

$staged=@(git diff --cached --name-only)
$fora=@($staged|Where-Object{
    $_ -notmatch '^data/catalog-v1/[^/]+\.json$' -and
    $_ -notmatch '^Images/Catalogo/.+\.(jpg|jpeg|png|webp)$'
})
if($fora.Count -gt 0){ git reset; Fail "Staging inesperado: $($fora -join ', ')" }

git diff --cached --check
if($LASTEXITCODE -ne 0){ git reset; Fail "git diff --check reprovou." }

git commit -m "content(cardapio): atualizar catalogo"
if($LASTEXITCODE -ne 0){ Fail "Commit falhou." }
$commitCatalogo=(git rev-parse HEAD).Trim()

git push -u origin $branchEsperada
if($LASTEXITCODE -ne 0){ Fail "Push da feature falhou." }

git fetch origin --quiet
$wt=Join-Path $env:TEMP ("oba-publish-"+[guid]::NewGuid().ToString("N"))
$mainCommit=$null
$tag=$null

try{
    git worktree add --detach $wt origin/main
    if($LASTEXITCODE -ne 0){ Fail "Falha ao preparar main." }

    Push-Location $wt
    try{
        git cherry-pick $commitCatalogo
        if($LASTEXITCODE -ne 0){ git cherry-pick --abort 2>$null; Fail "Cherry-pick falhou." }

        $mainCommit=(git rev-parse HEAD).Trim()
        git push origin HEAD:main
        if($LASTEXITCODE -ne 0){ Fail "Push main falhou." }

        $smokeOK=$false
        $erroSmoke=""

        for($attempt=1;$attempt -le 24;$attempt++){
            $todos=$true

            foreach($rel in $alterados){
                try{
                    $localPath=Join-Path $wt ($rel -replace '/','\')
                    $url="$urlBase/$rel?cb=$([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())"
                    $resp=Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 20 -Headers @{"Cache-Control"="no-cache";"Pragma"="no-cache"}
                    if($resp.StatusCode -ne 200){ throw "HTTP $($resp.StatusCode)" }

                    if($rel -match '\.json$'){
                        $a=([IO.File]::ReadAllText($localPath)|ConvertFrom-Json)|ConvertTo-Json -Depth 40 -Compress
                        $b=($resp.Content|ConvertFrom-Json)|ConvertTo-Json -Depth 40 -Compress
                        if($a -ne $b){ throw "JSON ainda nao propagou." }
                    }else{
                        $remoteBytes=$resp.RawContentStream.ToArray()
                        $localHash=(Get-FileHash -LiteralPath $localPath -Algorithm SHA256).Hash
                        $sha=[Security.Cryptography.SHA256]::Create()
                        try{
                            $remoteHash=([BitConverter]::ToString($sha.ComputeHash($remoteBytes))).Replace("-","")
                        }finally{$sha.Dispose()}
                        if($remoteHash -ne $localHash){ throw "Imagem ainda nao propagou." }
                    }
                }
                catch{
                    $todos=$false
                    $erroSmoke=[string]$_.Exception.Message
                    break
                }
            }

            if($todos){ $smokeOK=$true;break }
            Start-Sleep -Seconds 10
        }

        if(-not $smokeOK){
            git revert --no-edit $mainCommit
            if($LASTEXITCODE -eq 0){ git push origin HEAD:main }
            Fail "Smoke publico falhou; rollback solicitado. $erroSmoke"
        }

        $tag="cardapio-catalogo-"+(Get-Date -Format "yyyyMMdd-HHmmss")
        git tag -a $tag $mainCommit -m "Catalogo Oba Doceria publicado"
        git push origin "refs/tags/$tag"
        if($LASTEXITCODE -ne 0){ Fail "Tag falhou." }
    }
    finally{ Pop-Location }
}
finally{
    if(Test-Path -LiteralPath $wt){ git worktree remove --force $wt 2>$null }
    git worktree prune 2>$null
}

$result=@"
PUBLICACAO APROVADA
COMMIT FEATURE: $commitCatalogo
COMMIT MAIN: $mainCommit
TAG: $tag
ARQUIVOS:
$($alterados -join "`r`n")
BACKUP: $backupDir
"@

[IO.File]::WriteAllText($report,$result,[Text.UTF8Encoding]::new($false))

Write-Host "====================================================" -ForegroundColor Green
Write-Host " CATALOGO PUBLICADO COM SUCESSO" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host "Tag: $tag"