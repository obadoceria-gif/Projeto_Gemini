param([int]$PreferredPort = 5510)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$server = Join-Path $PSScriptRoot "CARDAPIO-central-local.ps1"

function Test-Central([int]$Port){
    try{
        $r=Invoke-WebRequest -Uri ("http://127.0.0.1:{0}/api/catalog" -f $Port) -UseBasicParsing -TimeoutSec 1
        return ($r.StatusCode -eq 200)
    }catch{
        return $false
    }
}

function Get-ListenerPid([int]$Port){
    try{
        $c=Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop | Select-Object -First 1
        if($null -ne $c){ return [int]$c.OwningProcess }
    }catch{}
    return $null
}

function Test-IsOurCentral([int]$PidValue){
    try{
        $p=Get-CimInstance Win32_Process -Filter "ProcessId=$PidValue" -ErrorAction Stop
        return ($p.CommandLine -match "CARDAPIO-central-local\.ps1")
    }catch{
        return $false
    }
}

function Test-ServerIsStale([int]$PidValue){
    try{
        $proc=Get-Process -Id $PidValue -ErrorAction Stop
        $serverWrite=(Get-Item -LiteralPath $server).LastWriteTimeUtc
        return ($proc.StartTime.ToUniversalTime() -lt $serverWrite)
    }catch{
        return $true
    }
}

$port=$PreferredPort

if(Test-Central $PreferredPort){
    $pidCentral=Get-ListenerPid $PreferredPort

    if($null -ne $pidCentral -and (Test-IsOurCentral $pidCentral)){
        if(Test-ServerIsStale $pidCentral){
            Write-Host "[INFO] Central ativa usa codigo antigo. Reiniciando..." -ForegroundColor Cyan
            Stop-Process -Id $pidCentral -Force
            Start-Sleep -Milliseconds 700
        }else{
            Write-Host "[PASS] Central atual ja esta ativa." -ForegroundColor Green
            Start-Process ("http://127.0.0.1:{0}/" -f $PreferredPort)
            exit 0
        }
    }else{
        # Endpoint respondeu, mas nao vamos encerrar processo desconhecido.
        Write-Host "[INFO] Porta $PreferredPort responde, mas processo nao foi reconhecido. Procurando porta alternativa." -ForegroundColor Cyan
        $port=$PreferredPort+1
    }
}
elseif($null -ne (Get-ListenerPid $PreferredPort)){
    # Porta ocupada por outro programa.
    $port=$PreferredPort+1
}

while($port -le ($PreferredPort+10)){
    if($null -eq (Get-ListenerPid $port)){ break }
    $port++
}

if($port -gt ($PreferredPort+10)){
    throw "Nenhuma porta livre entre $PreferredPort e $($PreferredPort+10)."
}

Write-Host "[INFO] Iniciando Central na porta $port..." -ForegroundColor Cyan

    $serverProcess = Start-Process `
        -FilePath "powershell.exe" `
        -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", "`"$server`"",
            "-Port", "$port",
            "-NoBrowser"
        ) `
        -PassThru

    $centralPronta = $false

    for($tentativa = 1; $tentativa -le 20; $tentativa++){

        Start-Sleep -Milliseconds 250

        if($serverProcess.HasExited){
            throw "Servidor da Central encerrou durante a inicializacao. ExitCode: $($serverProcess.ExitCode)"
        }

        try{

            $health = Invoke-WebRequest `
                -Uri ("http://127.0.0.1:{0}/api/status" -f $port) `
                -UseBasicParsing `
                -TimeoutSec 2

            if($health.StatusCode -eq 200){
                $centralPronta = $true
                break
            }
        }
        catch{
        }
    }

    if(-not $centralPronta){

        if(
            $serverProcess -and
            -not $serverProcess.HasExited
        ){
            Stop-Process `
                -Id $serverProcess.Id `
                -Force `
                -ErrorAction SilentlyContinue
        }

        throw "Central nao ficou pronta na porta $port."
    }

    Write-Host "[PASS] Central persistente ativa na porta $port." -ForegroundColor Green

    Start-Process ("http://127.0.0.1:{0}/" -f $port)

    exit 0