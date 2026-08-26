$ErrorActionPreference = "Stop"

$root =
    Split-Path $PSScriptRoot -Parent

$baseline =
    Join-Path $root `
    "ui-desenvolvimento\__r1_20_b05_ux5_e4_r14_3_contexto_carrinho_candidate__.html"

$harness =
    Join-Path $root `
    ".tests\Cardapio\R14_3\R14_3_E2E_T1.html"

$nomeTemp =
    "__R14_3_E2E_HEADLESS_TEMP__.html"

$tempHtml =
    Join-Path `
        $root `
        "ui-desenvolvimento\$nomeTemp"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " R14.3 - E2E HEADLESS GATE FINAL" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $baseline)) {
    throw "Baseline R14.3 nao encontrada."
}

if (-not (Test-Path -LiteralPath $harness)) {
    throw "Harness E2E nao encontrado."
}

$hashBaselineAntes =
    (
        Get-FileHash `
            -LiteralPath $baseline `
            -Algorithm SHA256
    ).Hash

$hashHarnessAntes =
    (
        Get-FileHash `
            -LiteralPath $harness `
            -Algorithm SHA256
    ).Hash

$perfil =
    $null

try {

    # ========================================================
    # 1. NAVEGADOR
    # ========================================================

    Write-Host ""
    Write-Host "[1/6] Localizando navegador..." -ForegroundColor Yellow

    $candidatos = @(
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
    )

    $navegador =
        $candidatos |
        Where-Object {
            $_ -and
            (Test-Path -LiteralPath $_)
        } |
        Select-Object -First 1

    if (-not $navegador) {
        throw "Chrome/Edge nao encontrado."
    }

    Write-Host "[PASS] Navegador:" -ForegroundColor Green
    Write-Host $navegador

    # ========================================================
    # 2. STAGING
    # ========================================================

    Write-Host ""
    Write-Host "[2/6] Criando staging temporario..." -ForegroundColor Yellow

    if (Test-Path -LiteralPath $tempHtml) {

        Remove-Item `
            -LiteralPath $tempHtml `
            -Force
    }

    Copy-Item `
        -LiteralPath $harness `
        -Destination $tempHtml

    $hashTemp =
        (
            Get-FileHash `
                -LiteralPath $tempHtml `
                -Algorithm SHA256
        ).Hash

    if ($hashTemp -ne $hashHarnessAntes) {
        throw "Staging difere do harness mestre."
    }

    Write-Host "[PASS] Harness copiado sem alteracao." -ForegroundColor Green

    # ========================================================
    # 3. HTTP
    # ========================================================

    Write-Host ""
    Write-Host "[3/6] Validando HTTP 5501..." -ForegroundColor Yellow

    $timestamp =
        [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

    $url =
        "http://127.0.0.1:5501/ui-desenvolvimento/" +
        $nomeTemp +
        "?gateFinal=" +
        $timestamp

    $r =
        Invoke-WebRequest `
            -Uri $url `
            -UseBasicParsing `
            -TimeoutSec 5

    if ($r.StatusCode -ne 200) {
        throw "HTTP diferente de 200."
    }

    if (
        -not $r.Content.Contains(
            "r143-e2e-t1-runtime"
        )
    ) {
        throw "Servidor nao entregou harness E2E."
    }

    Write-Host "[PASS] HTTP 5501 / E2E." -ForegroundColor Green

    # ========================================================
    # 4. HEADLESS
    # ========================================================

    Write-Host ""
    Write-Host "[4/6] Executando navegador headless..." -ForegroundColor Yellow

    $perfil =
        Join-Path `
            $env:TEMP `
            (
                "oba-r143-e2e-" +
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

    $argumentos = @(
        "--headless=new",
        "--disable-gpu",
        "--no-first-run",
        "--no-default-browser-check",
        "--disable-extensions",
        "--disable-background-networking",
        "--disable-component-update",
        "--disable-sync",
        "--user-data-dir=$perfil",
        "--virtual-time-budget=12000",
        "--dump-dom",
        $url
    )

    $processo =
        Start-Process `
            -FilePath $navegador `
            -ArgumentList $argumentos `
            -RedirectStandardOutput $stdout `
            -RedirectStandardError $stderr `
            -Wait `
            -PassThru

    Write-Host (
        "[INFO] ExitCode navegador: " +
        $processo.ExitCode
    ) -ForegroundColor DarkGray

    if (-not (Test-Path -LiteralPath $stdout)) {
        throw "Chrome nao gerou stdout."
    }

    $dom =
        [IO.File]::ReadAllText(
            $stdout,
            [Text.Encoding]::UTF8
        )

    if ([string]::IsNullOrWhiteSpace($dom)) {
        throw "DOM headless vazio."
    }

    Write-Host "[PASS] DOM capturado." -ForegroundColor Green

    # ========================================================
    # 5. LER SOMENTE O PAINEL RENDERIZADO
    # ========================================================

    Write-Host ""
    Write-Host "[5/6] Lendo painel E2E renderizado..." -ForegroundColor Yellow

    $regexPainel =
        '<div\b(?=[^>]*\bid=["'']r143-e2e-t1-panel["''])[^>]*>(.*?)</div>'

    $matchPainel =
        [regex]::Match(
            $dom,
            $regexPainel,
            (
                [Text.RegularExpressions.RegexOptions]::Singleline `
                -bor `
                [Text.RegularExpressions.RegexOptions]::IgnoreCase
            )
        )

    if (-not $matchPainel.Success) {
        throw "Painel r143-e2e-t1-panel nao encontrado."
    }

    $painelHtml =
        $matchPainel.Groups[1].Value

    $painelTexto =
        [regex]::Replace(
            $painelHtml,
            '<[^>]+>',
            ' '
        )

    $painelTexto =
        [System.Net.WebUtility]::HtmlDecode(
            $painelTexto
        )

    $painelTexto =
        [regex]::Replace(
            $painelTexto,
            '\s+',
            ' '
        ).Trim()

    Write-Host ""
    Write-Host "PAINEL E2E:" -ForegroundColor Cyan
    Write-Host $painelTexto

    $matchPass =
        [regex]::Match(
            $painelTexto,
            'PASS:\s*([0-9]+)',
            [Text.RegularExpressions.RegexOptions]::IgnoreCase
        )

    $matchFail =
        [regex]::Match(
            $painelTexto,
            'FAIL:\s*([0-9]+)',
            [Text.RegularExpressions.RegexOptions]::IgnoreCase
        )

    $matchResultado =
        [regex]::Match(
            $painelTexto,
            'RESULTADO:\s*(APROVADO|REPROVADO)',
            [Text.RegularExpressions.RegexOptions]::IgnoreCase
        )

    if (-not $matchPass.Success) {
        throw "PASS nao localizado no painel."
    }

    if (-not $matchFail.Success) {
        throw "FAIL nao localizado no painel."
    }

    if (-not $matchResultado.Success) {
        throw "RESULTADO nao localizado no painel."
    }

    $pass =
        [int]$matchPass.Groups[1].Value

    $fail =
        [int]$matchFail.Groups[1].Value

    $resultado =
        $matchResultado.Groups[1].Value.ToUpperInvariant()

    Write-Host ""
    Write-Host "PASS: $pass" -ForegroundColor Green

    if ($fail -eq 0) {

        Write-Host "FAIL: 0" -ForegroundColor Green
    }
    else {

        Write-Host "FAIL: $fail" -ForegroundColor Red
    }

    if ($resultado -eq "APROVADO") {

        Write-Host "RESULTADO: APROVADO" -ForegroundColor Green
    }
    else {

        Write-Host "RESULTADO: REPROVADO" -ForegroundColor Red
    }

    # ========================================================
    # 6. DECISAO
    # ========================================================

    Write-Host ""
    Write-Host "[6/6] Decisao..." -ForegroundColor Yellow

    if (
        $pass -ne 35 -or
        $fail -ne 0 -or
        $resultado -ne "APROVADO"
    ) {

        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Red
        Write-Host " E2E HEADLESS: REPROVADO" -ForegroundColor Red
        Write-Host " PASS: $pass / FAIL: $fail / RESULTADO: $resultado" -ForegroundColor Red
        Write-Host "============================================================" -ForegroundColor Red

        exit 1
    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " E2E HEADLESS: APROVADO" -ForegroundColor Green
    Write-Host " 35 PASS / 0 FAIL" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green

    exit 0
}
finally {

    if (
        $tempHtml -and
        (Test-Path -LiteralPath $tempHtml)
    ) {

        Remove-Item `
            -LiteralPath $tempHtml `
            -Force `
            -ErrorAction SilentlyContinue
    }

    if (
        $perfil -and
        (Test-Path -LiteralPath $perfil)
    ) {

        Remove-Item `
            -LiteralPath $perfil `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue
    }

    $hashBaselineDepois =
        (
            Get-FileHash `
                -LiteralPath $baseline `
                -Algorithm SHA256
        ).Hash

    $hashHarnessDepois =
        (
            Get-FileHash `
                -LiteralPath $harness `
                -Algorithm SHA256
        ).Hash

    if ($hashBaselineDepois -ne $hashBaselineAntes) {
        Write-Host "[ERRO] Baseline foi alterada." -ForegroundColor Red
    }

    if ($hashHarnessDepois -ne $hashHarnessAntes) {
        Write-Host "[ERRO] Harness foi alterado." -ForegroundColor Red
    }
}