$ErrorActionPreference = "Stop"

$root =
    Split-Path $PSScriptRoot -Parent

$arquivo =
    Join-Path `
        $root `
        "ui-desenvolvimento\__r1_20_b05_ux5_e4_r14_3_contexto_carrinho_candidate__.html"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " R14.3 - GATE DE REGRESSAO" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $arquivo)) {
    throw "R14.3 nao encontrada."
}

$html =
    [IO.File]::ReadAllText(
        $arquivo,
        [Text.Encoding]::UTF8
    )

$testes = [ordered]@{

    "R14 runtime" =
        $html.Contains(
            "r120-b05-ux5-e4-r14-runtime"
        )

    "Contexto R143" =
        $html.Contains(
            "indiceGlobalEdicaoR143"
        )

    "Origem carrinho" =
        [regex]::IsMatch(
            $html,
            "origemEditor\s*=\s*'carrinho'"
        )

    "Indice local recebe global" =
        [regex]::IsMatch(
            $html,
            "indiceCarrinhoEditor\s*=\s*indiceGlobalEdicaoR143"
        )

    "Salvar canonico" =
        $html.Contains(
            "_registrarCaixaNoCarrinho();"
        )

    "Carrinho R117" =
        $html.Contains(
            "window.abrirCarrinhoViewportR117();"
        )

    "Checkout R117C" =
        $html.Contains(
            "r117c-checkout-view"
        )

    "Finalizar checkout" =
        $html.Contains(
            "window.finalizarCheckoutR117C"
        )

    "Nome checkout" =
        $html.Contains(
            "r117c-name"
        )

    "Data checkout" =
        $html.Contains(
            "r117c-date"
        )

    "Hora checkout" =
        $html.Contains(
            "r117c-time"
        )

    "Pagamento checkout" =
        $html.Contains(
            "r117c-payment"
        )

    "Checkpoint R13" =
        $html.Contains(
            "r120-b05-ux5-e4-r13-checkpoint-runtime"
        )

    "R14.2 ausente" =
        -not $html.Contains(
            "r120-b05-ux5-e4-r14-2-runtime"
        )
}

$pass =
    0

$fail =
    0

foreach ($teste in $testes.GetEnumerator()) {

    if ($teste.Value) {

        $pass++

        Write-Host (
            "[PASS] " + $teste.Key
        ) -ForegroundColor Green
    }
    else {

        $fail++

        Write-Host (
            "[FAIL] " + $teste.Key
        ) -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "HTTP 5501..." -ForegroundColor Yellow

$timestamp =
    [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

$url =
    "http://127.0.0.1:5501/ui-desenvolvimento/" +
    "__r1_20_b05_ux5_e4_r14_3_contexto_carrinho_candidate__.html" +
    "?gate=" +
    $timestamp

try {

    $r =
        Invoke-WebRequest `
            -Uri $url `
            -UseBasicParsing `
            -TimeoutSec 5

    if (
        $r.StatusCode -eq 200 -and
        $r.Content.Contains(
            "indiceGlobalEdicaoR143"
        )
    ) {

        $pass++

        Write-Host "[PASS] HTTP 5501 / R14.3" -ForegroundColor Green
    }
    else {

        $fail++

        Write-Host "[FAIL] HTTP 5501 / R14.3" -ForegroundColor Red
    }
}
catch {

    $fail++

    Write-Host "[FAIL] HTTP 5501 / R14.3" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================="

Write-Host (
    "PASS: " + $pass
) -ForegroundColor Green

if ($fail -eq 0) {

    Write-Host "FAIL: 0" -ForegroundColor Green
    Write-Host "RESULTADO: APROVADO" -ForegroundColor Green
}
else {

    Write-Host (
        "FAIL: " + $fail
    ) -ForegroundColor Red

    Write-Host "RESULTADO: REPROVADO" -ForegroundColor Red

    exit 1
}

Write-Host "============================================="
Write-Host ""