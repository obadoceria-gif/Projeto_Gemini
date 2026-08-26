$ErrorActionPreference = "Stop"

$root =
    Split-Path $PSScriptRoot -Parent

$r151 =
    Join-Path $root `
    "ui-desenvolvimento\__r1_20_b05_ux5_e5_r15_1_mais_sabores_candidate__.html"

$harness =
    Join-Path $root `
    ".tests\Cardapio\R15_1\R15_1_AUTO_T1B.html"

$gateR14 =
    Join-Path $root `
    ".scripts\R14_3-e2e-headless.ps1"

$nomeTemp =
    "__R15_1_AUTO_HEADLESS_TEMP__.html"

$temp =
    Join-Path `
        $root `
        "ui-desenvolvimento\$nomeTemp"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " R15.1 - GATE DE REGRESSAO" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $r151)) {
    throw "R15.1 funcional nao encontrada."
}

if (-not (Test-Path -LiteralPath $harness)) {
    throw "Harness R15.1 nao encontrado."
}

if (-not (Test-Path -LiteralPath $gateR14)) {
    throw "Gate R14.3 nao encontrado."
}

$hashR151Antes =
    (
        Get-FileHash `
            -LiteralPath $r151 `
            -Algorithm SHA256
    ).Hash

$hashHarnessAntes =
    (
        Get-FileHash `
            -LiteralPath $harness `
            -Algorithm SHA256
    ).Hash

# ============================================================
# A. CONTRATO ESTATICO R15.1
# ============================================================

Write-Host ""
Write-Host "[1/5] Contrato estatico R15.1..." -ForegroundColor Yellow

$html =
    [IO.File]::ReadAllText(
        $r151,
        [Text.Encoding]::UTF8
    )

$checks = [ordered]@{

    "Runtime R15.1" =
        $html.Contains(
            "r151-mais-sabores-runtime"
        )

    "Styles R15.1" =
        $html.Contains(
            "r151-mais-sabores-styles"
        )

    "Indicador" =
        $html.Contains(
            "r151-mais-sabores"
        )

    "Texto" =
        $html.Contains(
            "Mais sabores abaixo"
        )

    "Atualizador" =
        $html.Contains(
            "atualizarAvisoMaisSaboresR151"
        )

    "MutationObserver" =
        $html.Contains(
            "new MutationObserver"
        )

    "Reduced motion" =
        $html.Contains(
            "prefers-reduced-motion"
        )
}

$passEstatico = 0
$failEstatico = 0

foreach ($check in $checks.GetEnumerator()) {

    if ($check.Value) {

        $passEstatico++

        Write-Host (
            "[PASS] " + $check.Key
        ) -ForegroundColor Green
    }
    else {

        $failEstatico++

        Write-Host (
            "[FAIL] " + $check.Key
        ) -ForegroundColor Red
    }
}

if ($failEstatico -ne 0) {
    throw "Contrato estatico R15.1 reprovado."
}

# ============================================================
# B. E2E R14.3
# ============================================================

Write-Host ""
Write-Host "[2/5] Executando E2E comercial R14.3..." -ForegroundColor Yellow

powershell.exe `
    -NoProfile `
    -ExecutionPolicy Bypass `
    -File $gateR14

if ($LASTEXITCODE -ne 0) {
    throw "E2E R14.3 reprovado."
}

Write-Host "[PASS] E2E comercial 35/35." -ForegroundColor Green

# ============================================================
# C. STAGING R15.1 T1B
# ============================================================

Write-Host ""
Write-Host "[3/5] Preparando teste comportamental R15.1..." -ForegroundColor Yellow

if (Test-Path -LiteralPath $temp) {

    Remove-Item `
        -LiteralPath $temp `
        -Force
}

Copy-Item `
    -LiteralPath $harness `
    -Destination $temp

$hashTemp =
    (
        Get-FileHash `
            -LiteralPath $temp `
            -Algorithm SHA256
    ).Hash

if ($hashTemp -ne $hashHarnessAntes) {
    throw "Staging R15.1 difere do harness mestre."
}

Write-Host "[PASS] Staging criado." -ForegroundColor Green

# ============================================================
# D. HEADLESS R15.1
# ============================================================

Write-Host ""
Write-Host "[4/5] Executando comportamento R15.1..." -ForegroundColor Yellow

$candidatos = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
)

$browser =
    $candidatos |
    Where-Object {
        $_ -and
        (Test-Path -LiteralPath $_)
    } |
    Select-Object -First 1

if (-not $browser) {
    throw "Chrome/Edge nao encontrado."
}

$timestamp =
    [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

$url =
    "http://127.0.0.1:5501/ui-desenvolvimento/" +
    $nomeTemp +
    "?r151Gate=" +
    $timestamp

$r =
    Invoke-WebRequest `
        -Uri $url `
        -UseBasicParsing `
        -TimeoutSec 5

if (
    $r.StatusCode -ne 200 -or
    -not $r.Content.Contains(
        "r151-auto-t1b-runtime"
    )
) {
    throw "Servidor nao entregou harness R15.1."
}

$perfil =
    Join-Path `
        $env:TEMP `
        (
            "oba-r151-gate-" +
            [guid]::NewGuid().ToString("N")
        )

New-Item `
    -ItemType Directory `
    -Path $perfil `
    -Force |
    Out-Null

$stdout =
    Join-Path $perfil "stdout.txt"

$stderr =
    Join-Path $perfil "stderr.txt"

$argsBrowser = @(
    "--headless=new",
    "--disable-gpu",
    "--no-first-run",
    "--no-default-browser-check",
    "--disable-extensions",
    "--user-data-dir=$perfil",
    "--window-size=390,844",
    "--virtual-time-budget=5000",
    "--dump-dom",
    $url
)

try {

    $processo =
        Start-Process `
            -FilePath $browser `
            -ArgumentList $argsBrowser `
            -RedirectStandardOutput $stdout `
            -RedirectStandardError $stderr `
            -Wait `
            -PassThru

    $dom =
        [IO.File]::ReadAllText(
            $stdout,
            [Text.Encoding]::UTF8
        )

}
finally {

    Remove-Item `
        -LiteralPath $perfil `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue
}

if ([string]::IsNullOrWhiteSpace($dom)) {
    throw "DOM R15.1 vazio."
}

$matchPainel =
    [regex]::Match(
        $dom,
        '<div\b(?=[^>]*\bid=["'']r151-auto-t1b-panel["''])[^>]*>(.*?)</div>',
        (
            [Text.RegularExpressions.RegexOptions]::Singleline `
            -bor `
            [Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    )

if (-not $matchPainel.Success) {
    throw "Painel R15.1 T1B nao encontrado."
}

$painel =
    [System.Net.WebUtility]::HtmlDecode(
        (
            [regex]::Replace(
                $matchPainel.Groups[1].Value,
                '<[^>]+>',
                ' '
            )
        )
    )

$painel =
    [regex]::Replace(
        $painel,
        '\s+',
        ' '
    ).Trim()

$matchPass =
    [regex]::Match(
        $painel,
        'PASS:\s*([0-9]+)'
    )

$matchFail =
    [regex]::Match(
        $painel,
        'FAIL:\s*([0-9]+)'
    )

$aprovado =
    $painel -match
    'RESULTADO:\s*APROVADO'

if (
    -not $matchPass.Success -or
    -not $matchFail.Success
) {
    throw "PASS/FAIL R15.1 nao encontrados."
}

$pass =
    [int]$matchPass.Groups[1].Value

$fail =
    [int]$matchFail.Groups[1].Value

Write-Host "PASS: $pass" -ForegroundColor Green

if ($fail -eq 0) {
    Write-Host "FAIL: 0" -ForegroundColor Green
}
else {
    Write-Host "FAIL: $fail" -ForegroundColor Red
}

if (
    $pass -ne 11 -or
    $fail -ne 0 -or
    -not $aprovado
) {
    throw "Comportamento R15.1 reprovado."
}

Write-Host "[PASS] R15.1 comportamento 11/11." -ForegroundColor Green

# ============================================================
# E. LIMPEZA / INTEGRIDADE
# ============================================================

Write-Host ""
Write-Host "[5/5] Limpando e validando integridade..." -ForegroundColor Yellow

Remove-Item `
    -LiteralPath $temp `
    -Force `
    -ErrorAction SilentlyContinue

$hashR151Depois =
    (
        Get-FileHash `
            -LiteralPath $r151 `
            -Algorithm SHA256
    ).Hash

$hashHarnessDepois =
    (
        Get-FileHash `
            -LiteralPath $harness `
            -Algorithm SHA256
    ).Hash

if ($hashR151Depois -ne $hashR151Antes) {
    throw "R15.1 funcional foi alterada."
}

if ($hashHarnessDepois -ne $hashHarnessAntes) {
    throw "Harness mestre foi alterado."
}

Write-Host "[PASS] R15.1 intacta." -ForegroundColor Green
Write-Host "[PASS] Harness intacto." -ForegroundColor Green
Write-Host "[PASS] Staging removido." -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " R15.1 GATE: APROVADO" -ForegroundColor Green
Write-Host " E2E COMERCIAL: 35/35" -ForegroundColor Green
Write-Host " UX R15.1: 11/11" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green

exit 0