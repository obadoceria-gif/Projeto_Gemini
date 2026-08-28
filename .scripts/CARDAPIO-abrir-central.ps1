param([int]$PreferredPort = 5510)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$server = Join-Path $PSScriptRoot "CARDAPIO-central-local.ps1"

function Test-Central([int]$Port){
    try {
        $r = Invoke-WebRequest -Uri ("http://127.0.0.1:{0}/api/catalog" -f $Port) -UseBasicParsing -TimeoutSec 1
        return ($r.StatusCode -eq 200)
    } catch { return $false }
}

if(Test-Central $PreferredPort){
    Start-Process ("http://127.0.0.1:{0}/" -f $PreferredPort)
    Write-Host "[PASS] Central ja estava ativa. Navegador aberto." -ForegroundColor Green
    exit 0
}

$port = $PreferredPort
while($port -le ($PreferredPort + 10)){
    $ocupada = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if(-not $ocupada){ break }
    $port++
}

if($port -gt ($PreferredPort + 10)){
    throw "Nao foi encontrada porta livre entre $PreferredPort e $($PreferredPort+10)."
}

if($port -ne $PreferredPort){
    Write-Host "[INFO] Porta $PreferredPort ocupada por outro processo. Usando $port." -ForegroundColor Cyan
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $server -Port $port
