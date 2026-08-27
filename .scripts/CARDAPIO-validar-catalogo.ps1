$ErrorActionPreference = "Stop"

$root =
    Split-Path -Parent $PSScriptRoot

$data =
    Join-Path $root "data\catalog-v1"

function Fail([string]$m) {
    throw $m
}

function LoadJson([string]$name) {

    $path =
        Join-Path $data $name

    if (!(Test-Path -LiteralPath $path)) {
        Fail "$name ausente."
    }

    try {
        return (
            [IO.File]::ReadAllText($path) |
            ConvertFrom-Json
        )
    }
    catch {
        Fail "$name invalido."
    }
}

$config     = LoadJson "config.json"
$categories = @(LoadJson "categories.json")
$flavors    = @(LoadJson "flavors.json")
$boxes      = @(LoadJson "boxes.json")
$options    = @(LoadJson "options.json")
$products   = @(LoadJson "products.json")
$combos     = @(LoadJson "combos.json")

if (!$config.store.whatsapp) {
    Fail "config.store.whatsapp ausente."
}

if ($categories.Count -eq 0) {
    Fail "Nenhuma categoria."
}

if ($flavors.Count -eq 0) {
    Fail "Nenhum sabor."
}

$idsCategorias =
    @($categories | ForEach-Object { $_.id })

if (
    @($idsCategorias | Sort-Object -Unique).Count `
    -ne $idsCategorias.Count
) {
    Fail "IDs duplicados em categories.json."
}

$idsSabores =
    @($flavors | ForEach-Object { $_.id })

if (
    @($idsSabores | Sort-Object -Unique).Count `
    -ne $idsSabores.Count
) {
    Fail "IDs duplicados em flavors.json."
}

foreach ($s in $flavors) {

    if (!$s.id -or !$s.nome -or !$s.categoriaId) {
        Fail "Sabor incompleto."
    }

    if ($idsCategorias -notcontains $s.categoriaId) {
        Fail "Categoria inexistente no sabor $($s.id)."
    }

    if ([double]$s.preco -lt 0) {
        Fail "Preco negativo no sabor $($s.id)."
    }
}

foreach ($b in $boxes) {

    if (!$b.id -or !$b.nome) {
        Fail "Caixa incompleta."
    }

    if ([int]$b.capacidade -lt 0) {
        Fail "Capacidade invalida em $($b.id)."
    }
}

foreach ($o in $options) {

    if (!$o.id -or !$o.nome) {
        Fail "Opcional incompleto."
    }

    if ([double]$o.preco -lt 0) {
        Fail "Preco negativo em $($o.id)."
    }
}

foreach ($p in $products) {

    if (!$p.id -or !$p.nome) {
        Fail "Produto incompleto."
    }

    if ([double]$p.preco -lt 0) {
        Fail "Preco negativo em $($p.id)."
    }
}

Write-Host ""
Write-Host "CATALOGO VALIDADO" -ForegroundColor Green
Write-Host "Categorias : $($categories.Count)"
Write-Host "Sabores    : $($flavors.Count)"
Write-Host "Caixas     : $($boxes.Count)"
Write-Host "Produtos   : $($products.Count)"
Write-Host "Opcionais  : $($options.Count)"
Write-Host "Combos     : $($combos.Count)"
Write-Host ""
Write-Host "[PASS] MODELO MESTRE VALIDO" -ForegroundColor Green