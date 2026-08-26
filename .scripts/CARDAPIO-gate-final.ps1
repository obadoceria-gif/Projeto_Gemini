$ErrorActionPreference = "Stop"

$root =
    Split-Path $PSScriptRoot -Parent

$baseline =
    Join-Path $root "ui-desenvolvimento\index.html"

$harnessE2E =
    Join-Path $root ".tests\Cardapio\R14_3\R14_3_E2E_T1.html"

$harnessR151 =
    Join-Path $root ".tests\Cardapio\R15_1\R15_1_AUTO_T1B.html"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CARDAPIO OBA - GATE FINAL" -ForegroundColor Cyan
Write-Host " BASELINE OFICIAL: ui-desenvolvimento\index.html" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

function Falhar {
    param([string]$Texto)
    throw $Texto
}

function Pass {
    param([string]$Texto)
    Write-Host "[PASS] $Texto" -ForegroundColor Green
}

function Extrair-Script {
    param(
        [string]$Arquivo,
        [string]$Id
    )

    if (-not (Test-Path -LiteralPath $Arquivo)) {
        Falhar "Harness nao encontrado: $Arquivo"
    }

    $texto =
        [IO.File]::ReadAllText(
            $Arquivo,
            [Text.Encoding]::UTF8
        )

    $padrao =
        '(?s)<script\s+id=["'']' +
        [regex]::Escape($Id) +
        '["''][^>]*>.*?</script>'

    $m =
        [regex]::Match(
            $texto,
            $padrao
        )

    if (-not $m.Success) {
        Falhar "Runtime nao localizado: $Id"
    }

    return $m.Value
}

function Extrair-Painel {
    param(
        [string]$Dom,
        [string]$Id
    )

    $padrao =
        '<div\b(?=[^>]*\bid=["'']' +
        [regex]::Escape($Id) +
        '["''])[^>]*>(.*?)</div>'

    $m =
        [regex]::Match(
            $Dom,
            $padrao,
            (
                [Text.RegularExpressions.RegexOptions]::Singleline `
                -bor `
                [Text.RegularExpressions.RegexOptions]::IgnoreCase
            )
        )

    if (-not $m.Success) {
        Falhar "Painel nao encontrado: $Id"
    }

    $texto =
        [regex]::Replace(
            $m.Groups[1].Value,
            '<[^>]+>',
            ' '
        )

    $texto =
        [System.Net.WebUtility]::HtmlDecode(
            $texto
        )

    return (
        [regex]::Replace(
            $texto,
            '\s+',
            ' '
        ).Trim()
    )
}

$candidatosBrowser = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
)

$browser =
    $candidatosBrowser |
    Where-Object {
        $_ -and
        (Test-Path -LiteralPath $_)
    } |
    Select-Object -First 1

if (-not $browser) {
    Falhar "Chrome/Edge nao encontrado."
}

function Executar-Headless {
    param(
        [string]$Url,
        [int]$Tempo
    )

    $perfil =
        Join-Path `
            $env:TEMP `
            (
                "oba-gate-final-" +
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

    try {

        $argsBrowser = @(
            "--headless=new",
            "--disable-gpu",
            "--no-first-run",
            "--no-default-browser-check",
            "--disable-extensions",
            "--disable-background-networking",
            "--disable-component-update",
            "--disable-sync",
            "--user-data-dir=$perfil",
            "--window-size=390,844",
            "--virtual-time-budget=$Tempo",
            "--dump-dom",
            $Url
        )

        Start-Process `
            -FilePath $browser `
            -ArgumentList $argsBrowser `
            -RedirectStandardOutput $stdout `
            -RedirectStandardError $stderr `
            -Wait |
            Out-Null

        if (-not (Test-Path -LiteralPath $stdout)) {
            Falhar "Browser nao gerou stdout."
        }

        $dom =
            [IO.File]::ReadAllText(
                $stdout,
                [Text.Encoding]::UTF8
            )

        if ([string]::IsNullOrWhiteSpace($dom)) {
            Falhar "DOM headless vazio."
        }

        return $dom
    }
    finally {

        Remove-Item `
            -LiteralPath $perfil `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue
    }
}

if (-not (Test-Path -LiteralPath $baseline)) {
    Falhar "Baseline oficial nao encontrada."
}

$hashAntes =
    (
        Get-FileHash `
            -LiteralPath $baseline `
            -Algorithm SHA256
    ).Hash

$html =
    [IO.File]::ReadAllText(
        $baseline,
        [Text.Encoding]::UTF8
    )

# ============================================================
# 1. CONTRATO DA BASELINE
# ============================================================

Write-Host ""
Write-Host "[1/6] Contrato funcional..." -ForegroundColor Yellow

$contratos = @(
    "r152-debug-invisivel-runtime",
    "r151-mais-sabores-runtime",
    "indiceGlobalEdicaoR143",
    "editarCaixaCarrinhoR120B05",
    "_registrarCaixaNoCarrinho",
    "abrirCarrinhoViewportR117",
    "finalizarCheckoutR117C"
)

foreach ($contrato in $contratos) {

    if (-not $html.Contains($contrato)) {
        Falhar "Contrato ausente: $contrato"
    }

    Pass $contrato
}

# ============================================================
# 2. SERVIDOR
# ============================================================

Write-Host ""
Write-Host "[2/6] Servidor 5501..." -ForegroundColor Yellow

$urlBaseline =
    "http://127.0.0.1:5501/ui-desenvolvimento/index.html" +
    "?gate=" +
    [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

$r =
    Invoke-WebRequest `
        -Uri $urlBaseline `
        -UseBasicParsing `
        -TimeoutSec 8

if ($r.StatusCode -ne 200) {
    Falhar "HTTP 5501 diferente de 200."
}

if (-not $r.Content.Contains("r152-debug-invisivel-runtime")) {
    Falhar "Servidor nao entrega baseline oficial R15.2."
}

Pass "HTTP 5501 / baseline oficial"

# ============================================================
# 3. E2E COMERCIAL 35/35
# ============================================================

Write-Host ""
Write-Host "[3/6] E2E comercial..." -ForegroundColor Yellow

$runtimeE2E =
    Extrair-Script `
        -Arquivo $harnessE2E `
        -Id "r143-e2e-t1-runtime"

$tempE2E =
    Join-Path `
        $root `
        "ui-desenvolvimento\__CARDAPIO_GATE_FINAL_E2E__.html"

$htmlE2E =
    $html.Replace(
        "</body>",
        $runtimeE2E +
        "`r`n</body>"
    )

[IO.File]::WriteAllText(
    $tempE2E,
    $htmlE2E,
    [Text.UTF8Encoding]::new($false)
)

try {

    $urlE2E =
        "http://127.0.0.1:5501/ui-desenvolvimento/" +
        "__CARDAPIO_GATE_FINAL_E2E__.html" +
        "?e2e=" +
        [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

    $domE2E =
        Executar-Headless `
            -Url $urlE2E `
            -Tempo 12000

    $painelE2E =
        Extrair-Painel `
            -Dom $domE2E `
            -Id "r143-e2e-t1-panel"

    Write-Host "  $painelE2E"

    if ($painelE2E -notmatch 'PASS:\s*35') {
        Falhar "E2E nao atingiu 35 PASS."
    }

    if ($painelE2E -notmatch 'FAIL:\s*0') {
        Falhar "E2E apresentou FAIL."
    }

    if ($painelE2E -notmatch 'RESULTADO:\s*APROVADO') {
        Falhar "E2E nao aprovado."
    }

    Pass "E2E comercial 35/35"
}
finally {

    Remove-Item `
        -LiteralPath $tempE2E `
        -Force `
        -ErrorAction SilentlyContinue
}

# ============================================================
# 4. UX R15.1 11/11
# ============================================================

Write-Host ""
Write-Host "[4/6] UX R15.1..." -ForegroundColor Yellow

$runtime151 =
    Extrair-Script `
        -Arquivo $harnessR151 `
        -Id "r151-auto-t1b-runtime"

$temp151 =
    Join-Path `
        $root `
        "ui-desenvolvimento\__CARDAPIO_GATE_FINAL_R151__.html"

$html151 =
    $html.Replace(
        "</body>",
        $runtime151 +
        "`r`n</body>"
    )

[IO.File]::WriteAllText(
    $temp151,
    $html151,
    [Text.UTF8Encoding]::new($false)
)

try {

    $url151 =
        "http://127.0.0.1:5501/ui-desenvolvimento/" +
        "__CARDAPIO_GATE_FINAL_R151__.html" +
        "?r151=" +
        [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

    $dom151 =
        Executar-Headless `
            -Url $url151 `
            -Tempo 7000

    $painel151 =
        Extrair-Painel `
            -Dom $dom151 `
            -Id "r151-auto-t1b-panel"

    Write-Host "  $painel151"

    if ($painel151 -notmatch 'PASS:\s*11') {
        Falhar "R15.1 nao atingiu 11 PASS."
    }

    if ($painel151 -notmatch 'FAIL:\s*0') {
        Falhar "R15.1 apresentou FAIL."
    }

    if ($painel151 -notmatch 'RESULTADO:\s*APROVADO') {
        Falhar "R15.1 nao aprovado."
    }

    Pass "UX R15.1 11/11"
}
finally {

    Remove-Item `
        -LiteralPath $temp151 `
        -Force `
        -ErrorAction SilentlyContinue
}

# ============================================================
# 5. R15.2 CLIENTE / DEBUG
# ============================================================

Write-Host ""
Write-Host "[5/6] R15.2 cliente/debug..." -ForegroundColor Yellow

$urlCliente =
    "http://127.0.0.1:5501/ui-desenvolvimento/index.html" +
    "?cliente=" +
    [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

$domCliente =
    Executar-Headless `
        -Url $urlCliente `
        -Tempo 5000

if ($domCliente -notmatch 'data-oba-debug-panel=["'']1["'']') {
    Falhar "R15.2 nao reconheceu painel tecnico."
}

if ($domCliente -notmatch 'data-oba-debug-hidden=["'']1["'']') {
    Falhar "Painel tecnico nao ficou oculto no modo cliente."
}

Pass "R15.2 modo cliente"

$urlDebug =
    "http://127.0.0.1:5501/ui-desenvolvimento/index.html" +
    "?obaDebug=1&debug=" +
    [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

$domDebug =
    Executar-Headless `
        -Url $urlDebug `
        -Tempo 5000

if ($domDebug -notmatch 'data-oba-debug-panel=["'']1["'']') {
    Falhar "R15.2 nao reconheceu painel no modo debug."
}

$matchPainelOcultoDebug =
    [regex]::Match(
        $domDebug,
        'data-oba-debug-panel=["'']1["''][^>]*data-oba-debug-hidden=["'']1["'']',
        [Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

if ($matchPainelOcultoDebug.Success) {
    Falhar "Painel tecnico permaneceu oculto no modo debug."
}

Pass "R15.2 modo debug"

# ============================================================
# 6. INTEGRIDADE
# ============================================================

Write-Host ""
Write-Host "[6/6] Integridade..." -ForegroundColor Yellow

$hashDepois =
    (
        Get-FileHash `
            -LiteralPath $baseline `
            -Algorithm SHA256
    ).Hash

if ($hashDepois -ne $hashAntes) {
    Falhar "Baseline oficial foi alterada pelo gate."
}

Pass "Baseline byte a byte intacta"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " CARDAPIO GATE FINAL: APROVADO" -ForegroundColor Green
Write-Host " E2E COMERCIAL : 35/35" -ForegroundColor Green
Write-Host " UX R15.1      : 11/11" -ForegroundColor Green
Write-Host " DEBUG R15.2   : APROVADO" -ForegroundColor Green
Write-Host " BASELINE      : INTACTA" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

exit 0