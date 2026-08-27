param(
    [int]$Port = 5510,
    [switch]$SelfTest,
    [switch]$NoBrowser,
    [string]$DataDirOverride = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dataDir = if([string]::IsNullOrWhiteSpace($DataDirOverride)){
    Join-Path $root "data\catalog-v1"
}else{
    $DataDirOverride
}

$adminFile = Join-Path $root "manutencao-cardapio\index.html"
$validator = Join-Path $root ".scripts\CARDAPIO-validar-catalogo.ps1"

function Normalize-List($Value){
    $saida = @()
    if($null -eq $Value){ return $saida }

    foreach($item in @($Value)){
        if($item -is [System.Array]){
            foreach($sub in $item){ $saida += ,$sub }
        }else{
            $saida += ,$item
        }
    }

    return $saida
}

function Load-JsonFile([string]$Name){
    $path = Join-Path $dataDir $Name
    if(!(Test-Path -LiteralPath $path)){ throw "$Name ausente." }
    return [IO.File]::ReadAllText($path) | ConvertFrom-Json
}

function Get-CatalogSnapshot {
    [ordered]@{
        config     = Load-JsonFile "config.json"
        categories = @(Normalize-List (Load-JsonFile "categories.json"))
        flavors    = @(Normalize-List (Load-JsonFile "flavors.json"))
        boxes      = @(Normalize-List (Load-JsonFile "boxes.json"))
        products   = @(Normalize-List (Load-JsonFile "products.json"))
        options    = @(Normalize-List (Load-JsonFile "options.json"))
        combos     = @(Normalize-List (Load-JsonFile "combos.json"))
    }
}

function Validate-Ids($Items,[string]$Name){
    $ids = @()
    foreach($i in @($Items)){
        $id = [string]$i.id
        if([string]::IsNullOrWhiteSpace($id)){ throw "$Name com item sem id." }
        $ids += $id
    }
    if(@($ids | Sort-Object -Unique).Count -ne $ids.Count){
        throw "IDs duplicados em $Name."
    }
}

function Validate-Flavors($Items){
    $items = @(Normalize-List $Items)
    $cats = @(Normalize-List (Load-JsonFile "categories.json"))
    $catIds = @($cats | ForEach-Object { [string]$_.id })

    if($items.Count -eq 0){ throw "Lista de sabores vazia." }
    Validate-Ids $items "flavors.json"

    foreach($s in $items){
        if([string]::IsNullOrWhiteSpace([string]$s.nome)){ throw "Sabor $($s.id) sem nome." }
        if($catIds -notcontains [string]$s.categoriaId){ throw "Categoria invalida em $($s.id)." }
        if([double]$s.preco -lt 0){ throw "Preco negativo em $($s.id)." }
    }
    return $items
}

function Validate-Boxes($Items){
    $items = @(Normalize-List $Items)
    if($items.Count -eq 0){ throw "Lista de caixas vazia." }
    Validate-Ids $items "boxes.json"

    foreach($b in $items){
        if([string]::IsNullOrWhiteSpace([string]$b.nome)){ throw "Caixa $($b.id) sem nome." }
        if([int]$b.capacidade -lt 0){ throw "Capacidade invalida em $($b.id)." }
        if($null -ne $b.maxSabores -and [int]$b.maxSabores -lt 0){ throw "maxSabores invalido em $($b.id)." }
        if($null -ne $b.precoFixo -and [double]$b.precoFixo -lt 0){ throw "precoFixo invalido em $($b.id)." }
    }
    return $items
}

function Validate-Products($Items){
    $items = @(Normalize-List $Items)
    Validate-Ids $items "products.json"
    foreach($p in $items){
        if([string]::IsNullOrWhiteSpace([string]$p.nome)){ throw "Produto $($p.id) sem nome." }
        if([double]$p.preco -lt 0){ throw "Preco negativo em $($p.id)." }
    }
    return $items
}

function Validate-Options($Items){
    $items = @(Normalize-List $Items)
    Validate-Ids $items "options.json"
    foreach($o in $items){
        if([string]::IsNullOrWhiteSpace([string]$o.nome)){ throw "Opcional $($o.id) sem nome." }
        if([double]$o.preco -lt 0){ throw "Preco negativo em $($o.id)." }
    }
    return $items
}

function Validate-Config($Config){
    if($null -eq $Config){ throw "config ausente." }
    if([string]::IsNullOrWhiteSpace([string]$Config.store.whatsapp)){
        throw "config.store.whatsapp ausente."
    }
    return $Config
}

function Validate-Entity([string]$Entity,$Payload){
    switch($Entity){
        "flavors"  { return ,(Validate-Flavors $Payload) }
        "boxes"    { return ,(Validate-Boxes $Payload) }
        "products" { return ,(Validate-Products $Payload) }
        "options"  { return ,(Validate-Options $Payload) }
        "config"   { return (Validate-Config $Payload) }
        default    { throw "Entidade nao suportada: $Entity" }
    }
}

function File-For-Entity([string]$Entity){
    switch($Entity){
        "flavors"  { "flavors.json" }
        "boxes"    { "boxes.json" }
        "products" { "products.json" }
        "options"  { "options.json" }
        "config"   { "config.json" }
        default    { throw "Entidade nao suportada: $Entity" }
    }
}

function Validate-WholeCatalog {
    $s = Get-CatalogSnapshot
    [void](Validate-Config $s.config)
    [void](Validate-Flavors $s.flavors)
    [void](Validate-Boxes $s.boxes)
    [void](Validate-Products $s.products)
    [void](Validate-Options $s.options)
}

function Save-EntityAtomic([string]$Entity,$Payload){
    $validated = Validate-Entity $Entity $Payload
    $fileName = File-For-Entity $Entity
    $path = Join-Path $dataDir $fileName

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $audit = Join-Path $root ".auditoria\Cardapio\CENTRAL_SAVE_$stamp"
    New-Item -ItemType Directory -Path $audit -Force | Out-Null

    $backup = Join-Path $audit ($fileName + ".bak")
    $temp = Join-Path $audit ($fileName + ".tmp")

    Copy-Item -LiteralPath $path -Destination $backup -Force

    try{
        if($Entity -eq "config"){
            $json = $validated | ConvertTo-Json -Depth 30
        }else{
            $json = @($validated) | ConvertTo-Json -Depth 30
        }

        [IO.File]::WriteAllText(
            $temp,
            $json + [Environment]::NewLine,
            [Text.UTF8Encoding]::new($false)
        )

        [void]([IO.File]::ReadAllText($temp) | ConvertFrom-Json)
        Copy-Item -LiteralPath $temp -Destination $path -Force

        Validate-WholeCatalog

        [ordered]@{
            ok = $true
            entity = $Entity
            backup = $backup
        }
    }
    catch{
        Copy-Item -LiteralPath $backup -Destination $path -Force
        throw
    }
    finally{
        Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
    }
}

function Read-HttpRequest($Stream){
    $head = New-Object IO.MemoryStream
    $tail = @()

    while($true){
        $b = $Stream.ReadByte()
        if($b -lt 0){ break }
        $head.WriteByte([byte]$b)

        $tail += [byte]$b
        if($tail.Count -gt 4){ $tail = $tail[($tail.Count-4)..($tail.Count-1)] }

        if(
            $tail.Count -eq 4 -and
            $tail[0] -eq 13 -and
            $tail[1] -eq 10 -and
            $tail[2] -eq 13 -and
            $tail[3] -eq 10
        ){
            break
        }

        if($head.Length -gt 65536){ throw "Cabecalho HTTP excessivo." }
    }

    $headerBytes = $head.ToArray()
    $headerText = [Text.Encoding]::ASCII.GetString($headerBytes)
    $lines = $headerText -split "`r`n"
    if($lines.Count -eq 0){ return $null }

    $first = $lines[0].Split(' ')
    if($first.Count -lt 2){ throw "Requisicao HTTP invalida." }

    $method = $first[0].ToUpperInvariant()
    $path = $first[1]
    $headers = @{}

    foreach($line in $lines[1..($lines.Count-1)]){
        if([string]::IsNullOrWhiteSpace($line)){ continue }
        $idx = $line.IndexOf(':')
        if($idx -gt 0){
            $headers[$line.Substring(0,$idx).Trim().ToLowerInvariant()] =
                $line.Substring($idx+1).Trim()
        }
    }

    $length = 0
    if($headers.ContainsKey("content-length")){
        $length = [int]$headers["content-length"]
    }

    $body = ""
    if($length -gt 0){
        $buffer = New-Object byte[] $length
        $read = 0

        while($read -lt $length){
            $n = $Stream.Read($buffer,$read,$length-$read)
            if($n -le 0){ break }
            $read += $n
        }

        $body = [Text.Encoding]::UTF8.GetString($buffer,0,$read)
    }

    [ordered]@{
        method = $method
        path = $path
        headers = $headers
        body = $body
    }
}

function Write-HttpResponse($Stream,[int]$Code,[string]$Status,[string]$Type,[byte[]]$Body){
    $h = "HTTP/1.1 $Code $Status`r`n" +
         "Content-Type: $Type`r`n" +
         "Content-Length: $($Body.Length)`r`n" +
         "Cache-Control: no-store`r`n" +
         "Connection: close`r`n" +
         "X-Content-Type-Options: nosniff`r`n" +
         "X-Frame-Options: DENY`r`n" +
         "Referrer-Policy: no-referrer`r`n`r`n"

    $hb = [Text.Encoding]::ASCII.GetBytes($h)
    $Stream.Write($hb,0,$hb.Length)
    if($Body.Length -gt 0){ $Stream.Write($Body,0,$Body.Length) }
}

function Send-Json($Stream,[int]$Code,[string]$Status,$Object){
    $json = $Object | ConvertTo-Json -Depth 30 -Compress
    $body = [Text.UTF8Encoding]::new($false).GetBytes($json)
    Write-HttpResponse $Stream $Code $Status "application/json; charset=utf-8" $body
}

function Self-Test {
    $s = Get-CatalogSnapshot
    Validate-WholeCatalog

    if(@($s.categories).Count -ne 6){ throw "SelfTest categorias." }
    if(@($s.flavors).Count -ne 55){ throw "SelfTest sabores." }
    if(@($s.boxes).Count -ne 6){ throw "SelfTest caixas." }
    if(@($s.products).Count -ne 2){ throw "SelfTest produtos." }
    if(@($s.options).Count -ne 2){ throw "SelfTest opcionais." }

    Write-Host "[PASS] CENTRAL 3C SELF-TEST" -ForegroundColor Green
}

if($SelfTest){ Self-Test; exit 0 }

function Content-Type-For([string]$Path){
    switch([IO.Path]::GetExtension($Path).ToLowerInvariant()){
        ".html" { "text/html; charset=utf-8"; break }
        ".json" { "application/json; charset=utf-8"; break }
        ".css"  { "text/css; charset=utf-8"; break }
        ".js"   { "application/javascript; charset=utf-8"; break }
        ".png"  { "image/png"; break }
        ".jpg"  { "image/jpeg"; break }
        ".jpeg" { "image/jpeg"; break }
        ".webp" { "image/webp"; break }
        ".svg"  { "image/svg+xml"; break }
        default { "application/octet-stream" }
    }
}

function Try-StaticFile([string]$UrlPath){
    $pathOnly=($UrlPath -split '\?')[0]
    $decoded=[Uri]::UnescapeDataString($pathOnly).TrimStart('/')
    if([string]::IsNullOrWhiteSpace($decoded)){ return $null }

    $allowed=@(
        "ui-desenvolvimento/",
        "data/",
        "Images/",
        "images/",
        "src/",
        "assets/"
    )

    $ok=$false
    foreach($prefix in $allowed){
        if($decoded.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){
            $ok=$true
            break
        }
    }
    if(-not $ok){ return $null }

    $candidate=[IO.Path]::GetFullPath((Join-Path $root ($decoded -replace '/','\')))
    $rootFull=[IO.Path]::GetFullPath($root + [IO.Path]::DirectorySeparatorChar)

    if(-not $candidate.StartsWith($rootFull,[StringComparison]::OrdinalIgnoreCase)){
        throw "Path traversal bloqueado."
    }

    if(!(Test-Path -LiteralPath $candidate -PathType Leaf)){ return $null }
    return $candidate
}
function Content-Type-For([string]$Path){
    switch([IO.Path]::GetExtension($Path).ToLowerInvariant()){
        ".html" { "text/html; charset=utf-8"; break }
        ".json" { "application/json; charset=utf-8"; break }
        ".css"  { "text/css; charset=utf-8"; break }
        ".js"   { "application/javascript; charset=utf-8"; break }
        ".png"  { "image/png"; break }
        ".jpg"  { "image/jpeg"; break }
        ".jpeg" { "image/jpeg"; break }
        ".webp" { "image/webp"; break }
        ".svg"  { "image/svg+xml"; break }
        default { "application/octet-stream" }
    }
}

function Try-StaticFile([string]$UrlPath){
    $pathOnly=($UrlPath -split '\?')[0]
    $decoded=[Uri]::UnescapeDataString($pathOnly).TrimStart('/')
    if([string]::IsNullOrWhiteSpace($decoded)){ return $null }

    $allowed=@(
        "ui-desenvolvimento/",
        "data/",
        "Images/",
        "images/",
        "src/",
        "assets/"
    )

    $ok=$false
    foreach($prefix in $allowed){
        if($decoded.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){
            $ok=$true
            break
        }
    }
    if(-not $ok){ return $null }

    $candidate=[IO.Path]::GetFullPath((Join-Path $root ($decoded -replace '/','\')))
    $rootFull=[IO.Path]::GetFullPath($root + [IO.Path]::DirectorySeparatorChar)

    if(-not $candidate.StartsWith($rootFull,[StringComparison]::OrdinalIgnoreCase)){
        throw "Path traversal bloqueado."
    }

    if(!(Test-Path -LiteralPath $candidate -PathType Leaf)){ return $null }
    return $candidate
}
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$Port)
$listener.Start()

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host " CENTRAL DE MANUTENCAO OBA - ATIVA" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host "URL: http://127.0.0.1:$Port/"
Write-Host "Somente localhost. Ctrl+C para encerrar."

if(-not $NoBrowser){ Start-Process "http://127.0.0.1:$Port/" }

try{
    while($true){
        $client = $listener.AcceptTcpClient()
        try{
            $stream = $client.GetStream()
            $req = Read-HttpRequest $stream
            if($null -eq $req){ continue }

            try{
                if($req.method -eq "GET" -and ($req.path -eq "/" -or $req.path.StartsWith("/?"))){
                    $bytes = [IO.File]::ReadAllBytes($adminFile)
                    Write-HttpResponse $stream 200 "OK" "text/html; charset=utf-8" $bytes
                }
                elseif($req.method -eq "GET" -and $req.path -eq "/api/catalog"){
                    Send-Json $stream 200 "OK" (Get-CatalogSnapshot)
                }
                elseif($req.method -eq "POST" -and $req.path -match '^/api/(flavors|boxes|products|options|config)$'){
                    $entity = $Matches[1]
                    if([string]::IsNullOrWhiteSpace($req.body)){ throw "Body vazio." }

                    $payload = $req.body | ConvertFrom-Json
                    $value = if($entity -eq "config"){ $payload.config }else{ $payload.items }

                    $result = Save-EntityAtomic $entity $value
                    Send-Json $stream 200 "OK" $result
                }
                elseif($req.method -eq "POST" -and $req.path -eq "/api/publish"){
                    $payload=$req.body | ConvertFrom-Json
                    if([string]$payload.confirm -ne "PUBLICAR"){
                        throw "Confirmacao de publicacao invalida."
                    }

                    $pub=Join-Path $root ".scripts\CARDAPIO-publicar-catalogo.ps1"
                    if(!(Test-Path -LiteralPath $pub)){ throw "Publicador ausente." }

                    $psi=New-Object Diagnostics.ProcessStartInfo
                    $psi.FileName="powershell.exe"
                    $psi.Arguments='-NoProfile -ExecutionPolicy Bypass -File "'+$pub+'"'
                    $psi.WorkingDirectory=$root
                    $psi.UseShellExecute=$false
                    $psi.RedirectStandardOutput=$true
                    $psi.RedirectStandardError=$true
                    $psi.CreateNoWindow=$true

                    $p=[Diagnostics.Process]::Start($psi)
                    $stdout=$p.StandardOutput.ReadToEnd()
                    $stderr=$p.StandardError.ReadToEnd()
                    $p.WaitForExit()

                    if($p.ExitCode -ne 0){
                        throw ("Publicacao falhou. "+$stderr+" "+$stdout)
                    }

                    Send-Json $stream 200 "OK" @{ok=$true;output=$stdout}
                }
                elseif($req.method -eq "GET"){
                    $static=Try-StaticFile $req.path
                    if($null -ne $static){
                        $bytes=[IO.File]::ReadAllBytes($static)
                        Write-HttpResponse $stream 200 "OK" (Content-Type-For $static) $bytes
                    }else{
                        Send-Json $stream 404 "Not Found" @{ok=$false;error="Rota inexistente."}
                    }
                }
                elseif($req.method -eq "POST" -and $req.path -eq "/api/publish"){
                    $payload=$req.body | ConvertFrom-Json
                    if([string]$payload.confirm -ne "PUBLICAR"){
                        throw "Confirmacao de publicacao invalida."
                    }

                    $pub=Join-Path $root ".scripts\CARDAPIO-publicar-catalogo.ps1"
                    if(!(Test-Path -LiteralPath $pub)){ throw "Publicador ausente." }

                    $psi=New-Object Diagnostics.ProcessStartInfo
                    $psi.FileName="powershell.exe"
                    $psi.Arguments='-NoProfile -ExecutionPolicy Bypass -File "'+$pub+'"'
                    $psi.WorkingDirectory=$root
                    $psi.UseShellExecute=$false
                    $psi.RedirectStandardOutput=$true
                    $psi.RedirectStandardError=$true
                    $psi.CreateNoWindow=$true

                    $p=[Diagnostics.Process]::Start($psi)
                    $stdout=$p.StandardOutput.ReadToEnd()
                    $stderr=$p.StandardError.ReadToEnd()
                    $p.WaitForExit()

                    if($p.ExitCode -ne 0){
                        throw ("Publicacao falhou. "+$stderr+" "+$stdout)
                    }

                    Send-Json $stream 200 "OK" @{ok=$true;output=$stdout}
                }
                elseif($req.method -eq "GET"){
                    $static=Try-StaticFile $req.path
                    if($null -ne $static){
                        $bytes=[IO.File]::ReadAllBytes($static)
                        Write-HttpResponse $stream 200 "OK" (Content-Type-For $static) $bytes
                    }else{
                        Send-Json $stream 404 "Not Found" @{ok=$false;error="Rota inexistente."}
                    }
                }
                else{
                    Send-Json $stream 404 "Not Found" @{ok=$false;error="Rota inexistente."}
                }
            }
            catch{
                Send-Json $stream 400 "Bad Request" @{
                    ok = $false
                    error = [string]$_.Exception.Message
                }
            }
        }
        finally{
            $client.Close()
        }
    }
}
finally{
    $listener.Stop()
}