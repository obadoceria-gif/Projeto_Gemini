param(
    [switch]$Execute
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$stamp=Get-Date -Format "yyyyMMdd_HHmmss"
$destino = if($env:OneDrive -and (Test-Path -LiteralPath $env:OneDrive)){
    Join-Path $env:OneDrive "OBA_DOCERIA\BACKUPS\CARDAPIO\ARQUIVADOS\$stamp"
}else{
    Join-Path $env:TEMP "Projeto_Gemini_ARQUIVADOS_$stamp"
}

$candidatos=@(
    Get-ChildItem -LiteralPath $root -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -match '^FASE[0-9].*\.ps1$' -or
        $_.Extension -in @(".zip",".bundle")
    }
)

Write-Host "CANDIDATOS A ARQUIVAMENTO:" -ForegroundColor Cyan
$candidatos | Select-Object Name,Length,LastWriteTime | Format-Table -AutoSize

if(-not $Execute){
    Write-Host "[INFO] Somente simulacao. Use -Execute para arquivar." -ForegroundColor Yellow
    exit 0
}

$status=@(git status --porcelain)
$trackedDirty=@($status | Where-Object { $_ -notmatch '^\?\?' })
if($trackedDirty.Count -gt 0){
    $trackedDirty | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    throw "Limpeza bloqueada: existem arquivos versionados modificados."
}

New-Item -ItemType Directory -Path $destino -Force | Out-Null

foreach($f in $candidatos){
    Move-Item -LiteralPath $f.FullName -Destination $destino -Force
    Write-Host "[PASS] Arquivado: $($f.Name)" -ForegroundColor Green
}

Write-Host "Destino: $destino" -ForegroundColor Cyan