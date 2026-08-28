$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$data = Join-Path $root "data\catalog-v1"

function Fail([string]$m){ throw $m }

function LoadJson([string]$name){
    $path=Join-Path $data $name
    if(!(Test-Path -LiteralPath $path)){ Fail "$name ausente." }
    try{ return [IO.File]::ReadAllText($path) | ConvertFrom-Json }
    catch{ Fail "$name invalido." }
}

function List($v){
    $out=@()
    foreach($x in @($v)){
        if($x -is [System.Array]){ foreach($y in $x){ $out += ,$y } }
        else{ $out += ,$x }
    }
    return $out
}

function UniqueIds($items,[string]$name){
    $ids=@()
    foreach($x in @($items)){
        if([string]::IsNullOrWhiteSpace([string]$x.id)){ Fail "$name possui item sem id." }
        $ids += [string]$x.id
    }
    if(@($ids|Sort-Object -Unique).Count -ne $ids.Count){ Fail "IDs duplicados em $name." }
}

$config=LoadJson "config.json"
$categories=@(List (LoadJson "categories.json"))
$flavors=@(List (LoadJson "flavors.json"))
$boxes=@(List (LoadJson "boxes.json"))
$products=@(List (LoadJson "products.json"))
$options=@(List (LoadJson "options.json"))
$combos=@(List (LoadJson "combos.json"))

if([string]::IsNullOrWhiteSpace([string]$config.store.whatsapp)){ Fail "config.store.whatsapp ausente." }
if($categories.Count -eq 0){ Fail "Nenhuma categoria." }
if($flavors.Count -eq 0){ Fail "Nenhum sabor." }

UniqueIds $categories "categories.json"
UniqueIds $flavors "flavors.json"
UniqueIds $boxes "boxes.json"
UniqueIds $products "products.json"
UniqueIds $options "options.json"
UniqueIds $combos "combos.json"

$catIds=@($categories|ForEach-Object{[string]$_.id})
$optionIds=@($options|ForEach-Object{[string]$_.id})

foreach($c in $categories){
    if([string]::IsNullOrWhiteSpace([string]$c.nome)){ Fail "Categoria $($c.id) sem nome." }
    if($null -ne $c.precoReferencia -and [double]$c.precoReferencia -lt 0){ Fail "Preco de categoria invalido: $($c.id)." }
}

foreach($s in $flavors){
    if([string]::IsNullOrWhiteSpace([string]$s.nome)){ Fail "Sabor $($s.id) sem nome." }
    if($catIds -notcontains [string]$s.categoriaId){ Fail "Categoria inexistente no sabor $($s.id)." }
    if([double]$s.preco -lt 0){ Fail "Preco negativo no sabor $($s.id)." }
}

foreach($b in $boxes){
    if([string]::IsNullOrWhiteSpace([string]$b.nome)){ Fail "Caixa $($b.id) sem nome." }
    if([int]$b.capacidade -lt 0){ Fail "Capacidade invalida em $($b.id)." }
    if($null -ne $b.maxSabores -and [int]$b.maxSabores -lt 0){ Fail "maxSabores invalido em $($b.id)." }
    if($null -ne $b.precoFixo -and [double]$b.precoFixo -lt 0){ Fail "precoFixo invalido em $($b.id)." }
}

foreach($p in $products){
    if([string]::IsNullOrWhiteSpace([string]$p.nome)){ Fail "Produto $($p.id) sem nome." }
    if([double]$p.preco -lt 0){ Fail "Preco negativo em $($p.id)." }
    foreach($op in @($p.opcionaisPermitidos)){
        if($optionIds -notcontains [string]$op){ Fail "Opcional inexistente '$op' no produto $($p.id)." }
    }
}

foreach($o in $options){
    if([string]::IsNullOrWhiteSpace([string]$o.nome)){ Fail "Opcional $($o.id) sem nome." }
    if([double]$o.preco -lt 0){ Fail "Preco negativo em $($o.id)." }
}

foreach($c in $combos){
    if([string]::IsNullOrWhiteSpace([string]$c.nome)){ Fail "Combo $($c.id) sem nome." }
    if($null -ne $c.preco -and [double]$c.preco -lt 0){ Fail "Preco negativo em combo $($c.id)." }
}

Write-Host ""
Write-Host "CATALOGO VALIDADO" -ForegroundColor Green
Write-Host "Categorias : $($categories.Count)"
Write-Host "Sabores    : $($flavors.Count)"
Write-Host "Caixas     : $($boxes.Count)"
Write-Host "Produtos   : $($products.Count)"
Write-Host "Opcionais  : $($options.Count)"
Write-Host "Combos     : $($combos.Count)"
Write-Host "[PASS] MODELO MESTRE VALIDO" -ForegroundColor Green