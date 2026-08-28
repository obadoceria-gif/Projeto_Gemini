param(
    [string]$Label = "alteracao"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Fail([string]$m){ throw $m }
function Pass([string]$m){ Write-Host "[PASS] $m" -ForegroundColor Green }

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$branch = (git branch --show-current).Trim()

git fetch origin --prune --quiet
if($LASTEXITCODE -ne 0){ Fail "git fetch falhou." }

$status=@(git status --porcelain)
if($status.Count -gt 0){
    $status | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    Fail "PRE-CHANGE bloqueado: workspace nao esta limpo."
}

$head=(git rev-parse HEAD).Trim()
$remote=(git rev-parse "origin/$branch").Trim()
if($head -ne $remote){ Fail "PRE-CHANGE bloqueado: branch local difere da remota." }

$backupRoot = Join-Path $root ".auditoria\Cardapio\PRE_CHANGE_$stamp"
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

$bundle = Join-Path $backupRoot "Projeto_Gemini_$stamp.bundle"
git bundle create $bundle --all
if($LASTEXITCODE -ne 0){ Fail "Falha ao criar Git bundle." }

git bundle verify $bundle | Out-Null
if($LASTEXITCODE -ne 0){ Fail "Git bundle invalido." }

$archive = Join-Path $backupRoot "Projeto_Gemini_HEAD_$stamp.zip"
git archive --format=zip --output=$archive HEAD
if($LASTEXITCODE -ne 0){ Fail "git archive falhou." }

$manifest = Join-Path $backupRoot "CHECKPOINT.txt"
$lines = @(
    "OBA DOCERIA - PRE-CHANGE",
    "Label: $Label",
    "Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "Branch: $branch",
    "HEAD: $head",
    "Origin: $remote",
    "Bundle: $bundle",
    "Archive: $archive"
)
[IO.File]::WriteAllLines($manifest,$lines,[Text.UTF8Encoding]::new($false))

$external=$null
if($env:OneDrive -and (Test-Path -LiteralPath $env:OneDrive)){
    $external = Join-Path $env:OneDrive "OBA_DOCERIA\BACKUPS\CARDAPIO\PRE_CHANGE_$stamp"
    New-Item -ItemType Directory -Path $external -Force | Out-Null
    Copy-Item -LiteralPath $bundle,$archive,$manifest -Destination $external -Force
}

Pass "PRE-CHANGE APROVADO"
Write-Host "Backup local : $backupRoot" -ForegroundColor Cyan
if($external){ Write-Host "Backup externo: $external" -ForegroundColor Cyan }
Write-Host "HEAD protegido: $($head.Substring(0,7))" -ForegroundColor Cyan