param(
    [int]$Port = 5510,
    [switch]$SelfTest,
    [switch]$NoBrowser,
    [string]$DataDirOverride = "",
    [string]$AssetRootOverride = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dataDir = if([string]::IsNullOrWhiteSpace($DataDirOverride)){ Join-Path $root "data\catalog-v1" }else{ $DataDirOverride }
$assetRoot = if([string]::IsNullOrWhiteSpace($AssetRootOverride)){ Join-Path $root "Images\Catalogo" }else{ $AssetRootOverride }
$adminFile = Join-Path $root "manutencao-cardapio\index.html"
$publisher = Join-Path $root ".scripts\CARDAPIO-publicar-catalogo.ps1"

function Normalize-List($Value){
    $saida=@()
    if($null -eq $Value){ return $saida }
    foreach($item in @($Value)){
        if($item -is [System.Array]){ foreach($sub in $item){ $saida += ,$sub } }
        else{ $saida += ,$item }
    }
    return $saida
}

function Load-JsonFile([string]$Name){
    $path=Join-Path $dataDir $Name
    if(!(Test-Path -LiteralPath $path)){ throw "$Name ausente." }
    return [IO.File]::ReadAllText($path) | ConvertFrom-Json
}

function File-For-Entity([string]$Entity){
    switch($Entity){
        "categories" { "categories.json" }
        "flavors"    { "flavors.json" }
        "boxes"      { "boxes.json" }
        "products"   { "products.json" }
        "options"    { "options.json" }
        "combos"     { "combos.json" }
        "config"     { "config.json" }
        default      { throw "Entidade nao suportada: $Entity" }
    }
}

function Get-CatalogSnapshot{
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
    $ids=@()
    foreach($i in @($Items)){
        $id=[string]$i.id
        if([string]::IsNullOrWhiteSpace($id)){ throw "$Name com item sem id." }
        $ids += $id
    }
    if(@($ids|Sort-Object -Unique).Count -ne $ids.Count){ throw "IDs duplicados em $Name." }
}

function Validate-Entity([string]$Entity,$Payload){
    if($Entity -eq "config"){
        if($null -eq $Payload){ throw "Config ausente." }
        if([string]::IsNullOrWhiteSpace([string]$Payload.store.whatsapp)){ throw "WhatsApp ausente." }
        return $Payload
    }

    $items=@(Normalize-List $Payload)
    Validate-Ids $items ($Entity+".json")

    if($Entity -eq "categories"){
        foreach($x in $items){
            if([string]::IsNullOrWhiteSpace([string]$x.nome)){ throw "Categoria sem nome." }
            if($null -ne $x.precoReferencia -and [double]$x.precoReferencia -lt 0){ throw "Preco de referencia invalido." }
        }
    }

    if($Entity -eq "flavors"){
        $catIds=@(Normalize-List (Load-JsonFile "categories.json") | ForEach-Object {[string]$_.id})
        foreach($x in $items){
            if([string]::IsNullOrWhiteSpace([string]$x.nome)){ throw "Sabor sem nome." }
            if($catIds -notcontains [string]$x.categoriaId){ throw "Categoria invalida em $($x.id)." }
            if([double]$x.preco -lt 0){ throw "Preco invalido em $($x.id)." }
        }
    }

    if($Entity -eq "boxes"){
        foreach($x in $items){
            if([string]::IsNullOrWhiteSpace([string]$x.nome)){ throw "Caixa sem nome." }
            if([int]$x.capacidade -lt 0){ throw "Capacidade invalida." }
            if($null -ne $x.maxSabores -and [int]$x.maxSabores -lt 0){ throw "maxSabores invalido." }
            if($null -ne $x.precoFixo -and [double]$x.precoFixo -lt 0){ throw "precoFixo invalido." }
        }
    }

    if($Entity -eq "products"){
        foreach($x in $items){
            if([string]::IsNullOrWhiteSpace([string]$x.nome)){ throw "Produto sem nome." }
            if([double]$x.preco -lt 0){ throw "Preco invalido." }
        }
    }

    if($Entity -eq "options"){
        foreach($x in $items){
            if([string]::IsNullOrWhiteSpace([string]$x.nome)){ throw "Opcional sem nome." }
            if([double]$x.preco -lt 0){ throw "Preco invalido." }
        }
    }

    if($Entity -eq "combos"){
        foreach($x in $items){
            if([string]::IsNullOrWhiteSpace([string]$x.nome)){ throw "Combo sem nome." }
            if($null -ne $x.preco -and [double]$x.preco -lt 0){ throw "Preco invalido." }
        }
    }

    return $items
}

function Validate-WholeCatalog{
    $s=Get-CatalogSnapshot
    [void](Validate-Entity "config" $s.config)
    [void](Validate-Entity "categories" $s.categories)
    [void](Validate-Entity "flavors" $s.flavors)
    [void](Validate-Entity "boxes" $s.boxes)
    [void](Validate-Entity "products" $s.products)
    [void](Validate-Entity "options" $s.options)
    [void](Validate-Entity "combos" $s.combos)
}

function Save-EntityAtomic([string]$Entity,$Payload){
    $validated=Validate-Entity $Entity $Payload
    $fileName=File-For-Entity $Entity
    $path=Join-Path $dataDir $fileName

    $stamp=Get-Date -Format "yyyyMMdd_HHmmss"
    $audit=Join-Path $root ".auditoria\Cardapio\CENTRAL_SAVE_$stamp"
    New-Item -ItemType Directory -Path $audit -Force | Out-Null
    $backup=Join-Path $audit ($fileName+".bak")
    $temp=Join-Path $audit ($fileName+".tmp")

    Copy-Item -LiteralPath $path -Destination $backup -Force

    try{
        $json=if($Entity -eq "config"){
            $validated | ConvertTo-Json -Depth 40
        }else{
            @($validated) | ConvertTo-Json -Depth 40
        }

        [IO.File]::WriteAllText($temp,$json+[Environment]::NewLine,[Text.UTF8Encoding]::new($false))
        [void]([IO.File]::ReadAllText($temp)|ConvertFrom-Json)
        Copy-Item -LiteralPath $temp -Destination $path -Force
        Validate-WholeCatalog

        [ordered]@{ok=$true;entity=$Entity;backup=$backup}
    }
    catch{
        Copy-Item -LiteralPath $backup -Destination $path -Force
        throw
    }
    finally{
        Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
    }
}

function Safe-FileName([string]$Name){
    $base=[IO.Path]::GetFileNameWithoutExtension($Name)
    $ext=[IO.Path]::GetExtension($Name).ToLowerInvariant()
    $base=$base.Normalize([Text.NormalizationForm]::FormD)
    $chars=New-Object Text.StringBuilder

    foreach($ch in $base.ToCharArray()){
        $cat=[Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch)
        if($cat -eq [Globalization.UnicodeCategory]::NonSpacingMark){ continue }
        if([char]::IsLetterOrDigit($ch) -or $ch -eq '-' -or $ch -eq '_'){ [void]$chars.Append($ch) }
        elseif([char]::IsWhiteSpace($ch)){ [void]$chars.Append('-') }
    }

    $clean=$chars.ToString().Trim('-','_')
    if([string]::IsNullOrWhiteSpace($clean)){ $clean="imagem" }
    return ($clean+$ext)
}

function Save-Image($Payload){
    $allowedExt=@(".jpg",".jpeg",".png",".webp")
    $entity=[string]$Payload.entity
    $itemId=[string]$Payload.itemId
    $fileName=[string]$Payload.fileName
    $base64=[string]$Payload.base64

    if($entity -notin @("flavors","products","combos","config")){ throw "Upload nao permitido para $entity." }
    if([string]::IsNullOrWhiteSpace($itemId)){ throw "itemId ausente." }
    if([string]::IsNullOrWhiteSpace($fileName)){ throw "Nome de arquivo ausente." }

    $ext=[IO.Path]::GetExtension($fileName).ToLowerInvariant()
    if($allowedExt -notcontains $ext){ throw "Extensao nao permitida: $ext" }

    try{ $bytes=[Convert]::FromBase64String($base64) }
    catch{ throw "Imagem base64 invalida." }

    if($bytes.Length -le 0){ throw "Imagem vazia." }
    if($bytes.Length -gt 5MB){ throw "Imagem excede 5 MB." }

    # Assinaturas basicas.
    $okMagic=$false
    if($ext -in @(".jpg",".jpeg") -and $bytes.Length -gt 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8){ $okMagic=$true }
    if($ext -eq ".png" -and $bytes.Length -gt 7 -and $bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50 -and $bytes[2] -eq 0x4E -and $bytes[3] -eq 0x47){ $okMagic=$true }
    if($ext -eq ".webp" -and $bytes.Length -gt 11 -and [Text.Encoding]::ASCII.GetString($bytes,0,4) -eq "RIFF" -and [Text.Encoding]::ASCII.GetString($bytes,8,4) -eq "WEBP"){ $okMagic=$true }
    if(-not $okMagic){ throw "Conteudo nao corresponde a uma imagem suportada." }

    $sub=Join-Path $assetRoot $entity
    New-Item -ItemType Directory -Path $sub -Force | Out-Null

    $safe=Safe-FileName $fileName
    $stamp=Get-Date -Format "yyyyMMddHHmmss"
    $finalName=($itemId+"-"+$stamp+"-"+$safe)
    $dest=Join-Path $sub $finalName
    [IO.File]::WriteAllBytes($dest,$bytes)

    if([string]::IsNullOrWhiteSpace($AssetRootOverride)){
        $relative="Images/Catalogo/"+$entity+"/"+$finalName
    }else{
        $relative=$dest
    }

    return [ordered]@{ok=$true;path=$relative;bytes=$bytes.Length}
}

function Get-Status{
    $changed=@()
    if([string]::IsNullOrWhiteSpace($DataDirOverride)){
        $status=@(git -C $root status --porcelain -- "data/catalog-v1/*.json" "Images/Catalogo/*")
        foreach($line in $status){
            if($line.Length -ge 4){ $changed += $line.Substring(3).Trim() }
        }
    }
    [ordered]@{ok=$true;changed=@($changed|Sort-Object -Unique);dirty=($changed.Count -gt 0)}
}

function Read-HttpRequest($Stream){
    $head=New-Object IO.MemoryStream
    $tail=@()

    while($true){
        $b=$Stream.ReadByte()
        if($b -lt 0){ break }
        $head.WriteByte([byte]$b)
        $tail += [byte]$b
        if($tail.Count -gt 4){ $tail=$tail[($tail.Count-4)..($tail.Count-1)] }

        if($tail.Count -eq 4 -and $tail[0]-eq 13 -and $tail[1]-eq 10 -and $tail[2]-eq 13 -and $tail[3]-eq 10){ break }
        if($head.Length -gt 65536){ throw "Cabecalho HTTP excessivo." }
    }

    $headerText=[Text.Encoding]::ASCII.GetString($head.ToArray())
    $lines=$headerText -split "`r`n"
    if($lines.Count -eq 0){ return $null }

    $first=$lines[0].Split(' ')
    if($first.Count -lt 2){ throw "Requisicao HTTP invalida." }

    $method=$first[0].ToUpperInvariant()
    $path=$first[1]
    $headers=@{}

    foreach($line in $lines[1..($lines.Count-1)]){
        if([string]::IsNullOrWhiteSpace($line)){ continue }
        $idx=$line.IndexOf(':')
        if($idx -gt 0){
            $headers[$line.Substring(0,$idx).Trim().ToLowerInvariant()]=$line.Substring($idx+1).Trim()
        }
    }

    $length=0
    if($headers.ContainsKey("content-length")){ $length=[int]$headers["content-length"] }

    $body=""
    if($length -gt 0){
        $buffer=New-Object byte[] $length
        $read=0
        while($read -lt $length){
            $n=$Stream.Read($buffer,$read,$length-$read)
            if($n -le 0){ break }
            $read += $n
        }
        $body=[Text.Encoding]::UTF8.GetString($buffer,0,$read)
    }

    [ordered]@{method=$method;path=$path;headers=$headers;body=$body}
}

function Write-HttpResponse($Stream,[int]$Code,[string]$Status,[string]$Type,[byte[]]$Body){
    $h="HTTP/1.1 $Code $Status`r`n"+
       "Content-Type: $Type`r`n"+
       "Content-Length: $($Body.Length)`r`n"+
       "Cache-Control: no-store`r`n"+
       "Connection: close`r`n"+
       "X-Content-Type-Options: nosniff`r`n"+
       "X-Frame-Options: DENY`r`n"+
       "Referrer-Policy: no-referrer`r`n`r`n"

    $hb=[Text.Encoding]::ASCII.GetBytes($h)
    $Stream.Write($hb,0,$hb.Length)
    if($Body.Length -gt 0){ $Stream.Write($Body,0,$Body.Length) }
}

function Send-Json($Stream,[int]$Code,[string]$Status,$Object){
    $json=$Object|ConvertTo-Json -Depth 40 -Compress
    $body=[Text.UTF8Encoding]::new($false).GetBytes($json)
    Write-HttpResponse $Stream $Code $Status "application/json; charset=utf-8" $body
}

function Content-Type-For([string]$Path){
    switch([IO.Path]::GetExtension($Path).ToLowerInvariant()){
        ".html" {"text/html; charset=utf-8";break}
        ".json" {"application/json; charset=utf-8";break}
        ".css" {"text/css; charset=utf-8";break}
        ".js" {"application/javascript; charset=utf-8";break}
        ".png" {"image/png";break}
        ".jpg" {"image/jpeg";break}
        ".jpeg" {"image/jpeg";break}
        ".webp" {"image/webp";break}
        ".svg" {"image/svg+xml";break}
        default {"application/octet-stream"}
    }
}

function Try-StaticFile([string]$UrlPath){
    $pathOnly=($UrlPath -split '\?')[0]
    $decoded=[Uri]::UnescapeDataString($pathOnly).TrimStart('/')
    if([string]::IsNullOrWhiteSpace($decoded)){ return $null }

    $allowed=@("ui-desenvolvimento/","data/","Images/","images/","src/","assets/")
    $ok=$false
    foreach($prefix in $allowed){
        if($decoded.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){ $ok=$true;break }
    }
    if(-not $ok){ return $null }

    $candidate=[IO.Path]::GetFullPath((Join-Path $root ($decoded -replace '/','\')))
    $rootFull=[IO.Path]::GetFullPath($root+[IO.Path]::DirectorySeparatorChar)
    if(-not $candidate.StartsWith($rootFull,[StringComparison]::OrdinalIgnoreCase)){ throw "Path traversal bloqueado." }

    if(Test-Path -LiteralPath $candidate -PathType Leaf){
        return $candidate
    }

    # Compatibilidade com imagens legadas usadas pelo cardapio.
    # Ex.: Images/Sabores_Doces/Cappuccino.jpeg vive sob ui-desenvolvimento.
    if($decoded.StartsWith("Images/",[StringComparison]::OrdinalIgnoreCase) -or
       $decoded.StartsWith("images/",[StringComparison]::OrdinalIgnoreCase)){
        $uiRoot=[IO.Path]::GetFullPath((Join-Path $root "ui-desenvolvimento"))
        $uiCandidate=[IO.Path]::GetFullPath((Join-Path $uiRoot ($decoded -replace '/','\')))
        $uiPrefix=[IO.Path]::GetFullPath($uiRoot+[IO.Path]::DirectorySeparatorChar)

        if($uiCandidate.StartsWith($uiPrefix,[StringComparison]::OrdinalIgnoreCase) -and
           (Test-Path -LiteralPath $uiCandidate -PathType Leaf)){
            return $uiCandidate
        }
    }

    return $null
}

function Self-Test{
    $s=Get-CatalogSnapshot
    Validate-WholeCatalog
    if(@($s.categories).Count -lt 1){ throw "SelfTest categorias." }
    if(@($s.flavors).Count -lt 1){ throw "SelfTest sabores." }
    Write-Host "[PASS] CENTRAL 4A SELF-TEST" -ForegroundColor Green
}

if($SelfTest){ Self-Test; exit 0 }

$listener=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$Port)
$listener.Start()

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host " CENTRAL DE GESTAO OBA - ATIVA" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host "URL: http://127.0.0.1:$Port/"
Write-Host "Somente localhost. Ctrl+C para encerrar."

if(-not $NoBrowser){ Start-Process "http://127.0.0.1:$Port/" }

try{
    while($true){
        $client=$listener.AcceptTcpClient()
        try{
            $stream=$client.GetStream()
            $req=Read-HttpRequest $stream
            if($null -eq $req){ continue }

            try{
                if($req.method -eq "GET" -and ($req.path -eq "/" -or $req.path.StartsWith("/?"))){
                    $bytes=[IO.File]::ReadAllBytes($adminFile)
                    Write-HttpResponse $stream 200 "OK" "text/html; charset=utf-8" $bytes
                }
                elseif($req.method -eq "GET" -and $req.path -eq "/api/catalog"){
                    Send-Json $stream 200 "OK" (Get-CatalogSnapshot)
                }
                elseif($req.method -eq "GET" -and $req.path -eq "/api/status"){
                    Send-Json $stream 200 "OK" (Get-Status)
                }
                elseif($req.method -eq "POST" -and $req.path -match '^/api/(categories|flavors|boxes|products|options|combos|config)$'){
                    $entity=$Matches[1]
                    if([string]::IsNullOrWhiteSpace($req.body)){ throw "Body vazio." }
                    $payload=$req.body|ConvertFrom-Json
                    $value=if($entity -eq "config"){ $payload.config }else{ $payload.items }
                    Send-Json $stream 200 "OK" (Save-EntityAtomic $entity $value)
                }
                elseif($req.method -eq "POST" -and $req.path -eq "/api/upload-image"){
                    $payload=$req.body|ConvertFrom-Json
                    Send-Json $stream 200 "OK" (Save-Image $payload)
                }
                elseif($req.method -eq "POST" -and $req.path -eq "/api/publish"){
                    $payload=$req.body|ConvertFrom-Json
                    if([string]$payload.confirm -ne "PUBLICAR"){ throw "Confirmacao invalida." }
                    if(!(Test-Path -LiteralPath $publisher)){ throw "Publicador ausente." }

                    $psi=New-Object Diagnostics.ProcessStartInfo
                    $psi.FileName="powershell.exe"
                    $psi.Arguments='-NoProfile -ExecutionPolicy Bypass -File "'+$publisher+'"'
                    $psi.WorkingDirectory=$root
                    $psi.UseShellExecute=$false
                    $psi.RedirectStandardOutput=$true
                    $psi.RedirectStandardError=$true
                    $psi.CreateNoWindow=$true

                    $p=[Diagnostics.Process]::Start($psi)
                    $stdout=$p.StandardOutput.ReadToEnd()
                    $stderr=$p.StandardError.ReadToEnd()
                    $p.WaitForExit()

                    if($p.ExitCode -ne 0){ throw ("Publicacao falhou. "+$stderr+" "+$stdout) }
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
                Send-Json $stream 400 "Bad Request" @{ok=$false;error=[string]$_.Exception.Message}
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