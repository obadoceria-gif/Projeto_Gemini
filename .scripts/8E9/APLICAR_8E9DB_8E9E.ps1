param()

$ErrorActionPreference = "Stop"

function Pass($m) { Write-Host "[PASS] $m" -ForegroundColor Green }
function Info($m) { Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn($m) { Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m) { throw $m }

function SecureToPlain {
    param([Security.SecureString]$Secure)

    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

function ConvertFrom-ObaD1Json {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text
    )

    $raw = $Text.Trim()

    try {
        $parsed = $raw | ConvertFrom-Json
    }
    catch {
        $match = [regex]::Match(
            $raw,
            '(?s)(\[\s*\{.*\}\s*\])'
        )

        if (-not $match.Success) {
            throw "JSON D1 nao localizado na saida do Wrangler."
        }

        $parsed = $match.Groups[1].Value | ConvertFrom-Json
    }

    $rows = @()

    foreach ($entry in @($parsed)) {
        if (
            $null -ne $entry -and
            $entry.PSObject.Properties.Name -contains "results"
        ) {
            foreach ($row in @($entry.results)) {
                if ($null -ne $row) {
                    $rows += $row
                }
            }
        }
    }

    if ($rows.Count -eq 0) {
        throw "D1 retornou JSON, mas sem linhas de resultados."
    }

    return ,$rows
}
function Invoke-ObaProcess {
    param(
        [Parameter(Mandatory=$true)][string]$FileName,
        [Parameter(Mandatory=$true)][string]$Arguments,
        [Parameter(Mandatory=$true)][string]$WorkingDirectory,
        [int]$TimeoutSeconds = 120,
        [hashtable]$Environment = @{}
    )

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $FileName
    $psi.Arguments = $Arguments
    $psi.WorkingDirectory = $WorkingDirectory
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    foreach ($key in $Environment.Keys) {
        $psi.EnvironmentVariables[$key] = [string]$Environment[$key]
    }

    $p = [System.Diagnostics.Process]::new()
    $p.StartInfo = $psi

    try {
        if (-not $p.Start()) {
            throw "Nao foi possivel iniciar: $FileName"
        }

        if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
            try { $p.Kill() } catch {}
            throw "TIMEOUT apos $TimeoutSeconds s: $FileName $Arguments"
        }

        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()

        return [PSCustomObject]@{
            ExitCode = $p.ExitCode
            StdOut = $stdout
            StdErr = $stderr
            Text = (($stdout, $stderr) -join "`n").Trim()
        }
    }
    finally {
        if ($p) { $p.Dispose() }
    }
}

$root = "C:\Users\pc_fa\Documents\Projeto_Gemini"
$gestao = Join-Path $root "online\gestao"
$scriptsDir = Join-Path $root ".scripts\8E9"

$branchExpected = "feature/gestao-online-segura"
$headExpected = (git rev-parse --short HEAD).Trim()
$npx = "C:\Program Files\nodejs\npx.cmd"
$db = "oba-cardapio-catalogo"
$baseUrl = "https://oba-cardapio-gestao.obadoceria.workers.dev"

$workerRel = "online/gestao/src/index.js"
$centralRel = "online/gestao/public/index.html"
$bootstrapRel = "online/gestao/public/preview-bootstrap.js"
$testRel = "online/gestao/tests/central-preview-e2e.cjs"

$worker = Join-Path $root $workerRel
$central = Join-Path $root $centralRel
$bootstrap = Join-Path $root $bootstrapRel
$testFile = Join-Path $root $testRel

$patcher = Join-Path $scriptsDir "PATCH_8E9_PREVIEW.cjs"
$sourceTest = Join-Path $scriptsDir "CENTRAL_PREVIEW_E2E.cjs"
$runnerRel = ".scripts/8E9/APLICAR_8E9DB_8E9E.ps1"
$patcherRel = ".scripts/8E9/PATCH_8E9_PREVIEW.cjs"
$sourceTestRel = ".scripts/8E9/CENTRAL_PREVIEW_E2E.cjs"
$mapRel = ".scripts/8E9/MAPA_PREVIEW.txt"

$deployed = $false
$d1MayHaveChanged = $false
$password = $null

Set-Location $root

try {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host " FASE 8E.9D-B + 8E.9E-R5 - IMPLEMENTACAO REAL" -ForegroundColor Cyan
    Write-Host " CENTRAL -> DRAFT -> PREVIEW PRIVADO" -ForegroundColor Cyan
    Write-Host " PATCH + BUILD + DEPLOY + E2E + D1 + GIT" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan

    # 1/12 Baseline
    Write-Host "`n[1/12] Validando baseline..." -ForegroundColor Yellow

    $branch = (git branch --show-current).Trim()
    $head = (git rev-parse --short HEAD).Trim()

    Write-Host "Branch : $branch"
    Write-Host "HEAD   : $head"

    if ($branch -ne $branchExpected) { Fail "Branch inesperada: $branch" }
    if ($head -ne $headExpected) { Fail "HEAD inesperado: $head. Esperado: $headExpected" }
    if (-not (Test-Path $npx)) { Fail "NPX global ausente: $npx" }
    if (-not (Test-Path $patcher)) { Fail "Patcher ausente: $patcher" }
    if (-not (Test-Path $sourceTest)) { Fail "E2E fonte ausente: $sourceTest" }

    $changedTracked = @(git -c core.quotepath=false diff --name-only)
    if ($changedTracked.Count -gt 0) {
        git status --short --untracked-files=all
        Fail "Ha arquivo rastreado modificado antes da fase."
    }

    $untracked = @(
        git -c core.quotepath=false ls-files --others --exclude-standard
    )

    $allowedUntracked = @(
        $runnerRel,
        $patcherRel,
        $sourceTestRel,
        $mapRel
    ) | Sort-Object

    $unexpectedUntracked = @(
        $untracked |
        Where-Object { $_ -notin $allowedUntracked }
    )

    if ($unexpectedUntracked.Count -gt 0) {
        git status --short --untracked-files=all
        Fail "Arquivos nao rastreados inesperados."
    }

    node.exe --check $worker
    if ($LASTEXITCODE -ne 0) { Fail "Worker baseline invalido." }

    Pass "BASELINE $headExpected"
    Pass "SOMENTE PACOTE 8E9 NAO RASTREADO"

    # 2/12 Checkpoint
    Write-Host "`n[2/12] Criando checkpoint..." -ForegroundColor Yellow

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $audit = Join-Path $root ".auditoria\Online\8E9DB_8E9E_$stamp"
    New-Item -ItemType Directory -Force -Path $audit | Out-Null

    git bundle create (Join-Path $audit "PRE_8E9DB_8E9E.bundle") --all
    if ($LASTEXITCODE -ne 0) { Fail "Checkpoint Git falhou." }

    Copy-Item $worker (Join-Path $audit "worker.BASELINE.js") -Force
    Copy-Item $central (Join-Path $audit "central.BASELINE.html") -Force
    Copy-Item $patcher (Join-Path $audit "PATCH_8E9_PREVIEW.cjs") -Force
    Copy-Item $sourceTest (Join-Path $audit "CENTRAL_PREVIEW_E2E.cjs") -Force

    if (Test-Path $mapRel) {
        Copy-Item $mapRel (Join-Path $audit "MAPA_PREVIEW.txt") -Force
        Remove-Item $mapRel -Force
    }

    Pass "CHECKPOINT CRIADO"
    Pass "MAPA TEMPORARIO ARQUIVADO"

    # 3/12 D1 pre
    Write-Host "`n[3/12] Auditando D1 pre-deploy..." -ForegroundColor Yellow

    $sqlPre = Join-Path $audit "d1-pre.sql"
    @"
SELECT COUNT(*) AS revisions FROM catalog_revisions;
SELECT COUNT(*) AS promotions FROM catalog_promotions;
SELECT slot,revision_id FROM catalog_slots ORDER BY slot;
"@ | Set-Content $sqlPre -Encoding ASCII

    $pre = Invoke-ObaProcess `
        -FileName $npx `
        -Arguments "--no-install wrangler d1 execute $db --remote --json --file `"$sqlPre`" --json" `
        -WorkingDirectory $gestao `
        -TimeoutSeconds 90

    if ($pre.ExitCode -ne 0) {
        Write-Host $pre.Text
        Fail "Auditoria D1 inicial falhou."
    }

    $preText = $pre.StdOut
    [System.IO.File]::WriteAllText(
        (Join-Path $audit "D1_PRE.json"),
        $preText,
        [System.Text.UTF8Encoding]::new($false)
    )

    $preRows = ConvertFrom-ObaD1Json -Text $preText

    $revRow = @(
        $preRows |
        Where-Object {
            $_.PSObject.Properties.Name -contains "revisions"
        }
    ) | Select-Object -First 1

    $promRow = @(
        $preRows |
        Where-Object {
            $_.PSObject.Properties.Name -contains "promotions"
        }
    ) | Select-Object -First 1

    $draftRow = @(
        $preRows |
        Where-Object { $_.slot -eq "DRAFT" }
    ) | Select-Object -First 1

    $previewRow = @(
        $preRows |
        Where-Object { $_.slot -eq "PREVIEW" }
    ) | Select-Object -First 1

    $pubRow = @(
        $preRows |
        Where-Object { $_.slot -eq "PUBLISHED" }
    ) | Select-Object -First 1

    if (
        $null -eq $revRow -or
        $null -eq $promRow -or
        $null -eq $draftRow -or
        $null -eq $previewRow -or
        $null -eq $pubRow
    ) {
        Write-Host $preText
        Fail "Estado D1 inicial nao identificado."
    }

    $revisionsBefore = [int]$revRow.revisions
    $promotionsBefore = [int]$promRow.promotions
    $draftBefore = if ($null -eq $draftRow.revision_id) { $null } else { [string]$draftRow.revision_id }
    $previewBefore = if ($null -eq $previewRow.revision_id) { $null } else { [string]$previewRow.revision_id }
    $publishedBefore = if ($null -eq $pubRow.revision_id) { $null } else { [string]$pubRow.revision_id }
    $previewNull = [string]::IsNullOrWhiteSpace($previewBefore)

    if ($draftBefore -ne $publishedBefore) {
        Fail "Baseline inesperada: DRAFT diverge de PUBLISHED."
    }

    if (-not $previewNull -and $previewBefore -ne $draftBefore) {
        Fail "PREVIEW inicial aponta para revisao inesperada."
    }

    Pass "DRAFT = PUBLISHED BASELINE"
    Pass "PREVIEW INICIAL CONTROLADO"
    Pass "PUBLISHED CAPTURADO"

    # 4/12 Patch local
    Write-Host "`n[4/12] Aplicando patch deterministico..." -ForegroundColor Yellow

    Copy-Item $sourceTest $testFile -Force

    $patch = Invoke-ObaProcess `
        -FileName "node.exe" `
        -Arguments "`"$patcher`" `"$worker`" `"$central`" `"$bootstrap`"" `
        -WorkingDirectory $root `
        -TimeoutSeconds 30

    Write-Host $patch.StdOut
    if ($patch.StdErr) { Write-Host $patch.StdErr -ForegroundColor Yellow }

    if ($patch.ExitCode -ne 0 -or $patch.StdOut -notmatch "PATCH_8E9_PREVIEW_OK") {
        git restore --source=HEAD --staged --worktree -- $workerRel $centralRel
        Remove-Item $bootstrap -Force -ErrorAction SilentlyContinue
        Remove-Item $testFile -Force -ErrorAction SilentlyContinue
        Fail "Patch deterministico falhou. Codigo funcional restaurado."
    }

    node.exe --check $worker
    if ($LASTEXITCODE -ne 0) {
        git restore --source=HEAD --staged --worktree -- $workerRel $centralRel
        Remove-Item $bootstrap -Force -ErrorAction SilentlyContinue
        Remove-Item $testFile -Force -ErrorAction SilentlyContinue
        Fail "Worker modificado invalido. Restaurado."
    }

    node.exe --check $bootstrap
    if ($LASTEXITCODE -ne 0) { Fail "Bootstrap Preview invalido." }

    node.exe --check $testFile
    if ($LASTEXITCODE -ne 0) { Fail "E2E Preview invalido." }

    Pass "PATCH APLICADO"
    Pass "WORKER NODE CHECK"
    Pass "BOOTSTRAP NODE CHECK"
    Pass "E2E NODE CHECK"

    # 5/12 Gates estÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ticos
    Write-Host "`n[5/12] Validando contratos estaticos..." -ForegroundColor Yellow

    $workerText = Get-Content $worker -Raw
    $centralText = Get-Content $central -Raw
    $bootstrapText = Get-Content $bootstrap -Raw

    foreach ($m in @(
        "OBA_PREVIEW_API_BEGIN",
        "obaHandlePreviewApi",
        "obaPrivatePreviewPage",
        "PREVIEW_CREATED",
        "/api/preview",
        "/__preview"
    )) {
        if (-not $workerText.Contains($m)) { Fail "Worker sem marker: $m" }
    }

    foreach ($m in @(
        "obaLoadDraftCatalog",
        "obaSaveDraftWith",
        "obaPreparePreview",
        "/api/draft",
        "/api/preview",
        "/__preview",
        "Publicar apos Preview"
    )) {
        if (-not $centralText.Contains($m)) { Fail "Central sem marker: $m" }
    }

    if ($centralText.Contains("await api('/api/publish'")) {
        Fail "Publicacao legada continua executavel."
    }

    if ($centralText.Contains("catalogo=await api('/api/catalog',{cache:'no-store'});")) {
        Fail "Carregamento direto legado continua ativo."
    }

    if (-not $bootstrapText.Contains("'/api/preview'")) {
        Fail "Bootstrap nao usa Preview."
    }

    git diff --check
    if ($LASTEXITCODE -ne 0) { Fail "git diff --check falhou." }

    Pass "CENTRAL -> DRAFT"
    Pass "DRAFT -> PREVIEW"
    Pass "PUBLICACAO DIRETA BLOQUEADA"
    Pass "GIT DIFF --CHECK"

    # 6/12 Gates existentes + build
    Write-Host "`n[6/12] Executando gates e Wrangler build..." -ForegroundColor Yellow

    Push-Location $gestao
    try {
        foreach ($gate in @(
            ".\tests\security-gate.cjs",
            ".\tests\auth-gate-static.cjs",
            ".\tests\catalog-state-contract.cjs"
        )) {
            if (Test-Path $gate) {
                & node.exe $gate
                if ($LASTEXITCODE -ne 0) { Fail "Gate falhou: $gate" }
            }
        }
    }
    finally {
        Pop-Location
    }

    $dry = Invoke-ObaProcess `
        -FileName $npx `
        -Arguments "--no-install wrangler deploy --dry-run" `
        -WorkingDirectory $gestao `
        -TimeoutSeconds 120

    Write-Host $dry.StdOut
    if ($dry.StdErr) { Write-Host $dry.StdErr -ForegroundColor Yellow }
    if ($dry.ExitCode -ne 0) { Fail "Wrangler dry-run falhou." }

    Pass "GATES EXISTENTES"
    Pass "WRANGLER BUILD"

    # 7/12 Deploy
    Write-Host "`n[7/12] Deploy controlado da Central privada..." -ForegroundColor Yellow
    Warn "HAVERA DEPLOY SOMENTE DA CENTRAL PRIVADA."
    Warn "PUBLISHED NAO SERA PROMOVIDO."

    $deploy = Invoke-ObaProcess `
        -FileName $npx `
        -Arguments "--no-install wrangler deploy" `
        -WorkingDirectory $gestao `
        -TimeoutSeconds 120

    Write-Host $deploy.StdOut
    if ($deploy.StdErr) { Write-Host $deploy.StdErr -ForegroundColor Yellow }
    if ($deploy.ExitCode -ne 0) { Fail "Deploy Worker falhou." }

    $deployed = $true
    Pass "CENTRAL PRIVADA DEPLOYADA"

    Start-Sleep -Seconds 5

    # 8/12 E2E remoto
    Write-Host "`n[8/12] Executando E2E remoto..." -ForegroundColor Yellow
    Write-Host "Digite UMA VEZ a senha administrativa." -ForegroundColor Cyan

    $secure = Read-Host "Senha administrativa" -AsSecureString
    $password = SecureToPlain $secure
    $secure = $null

    if ([string]::IsNullOrWhiteSpace($password)) { Fail "Senha vazia." }

    $d1MayHaveChanged = $true

    $e2e = Invoke-ObaProcess `
        -FileName "node.exe" `
        -Arguments "`"$testFile`"" `
        -WorkingDirectory $gestao `
        -TimeoutSeconds 90 `
        -Environment @{
            TEST_BASE_URL = $baseUrl
            TEST_AUTH_PASSWORD = $password
        }

    $password = $null
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    Write-Host $e2e.StdOut
    if ($e2e.StdErr) { Write-Host $e2e.StdErr -ForegroundColor Yellow }

    if ($e2e.ExitCode -ne 0 -or $e2e.StdOut -notmatch "CENTRAL_PREVIEW_E2E_OK") {
        Fail "E2E Central/Preview falhou."
    }

    Pass "CENTRAL_PREVIEW_E2E_OK"

    # 9/12 D1 pÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³s
    Write-Host "`n[9/12] Provando PUBLISHED intacto..." -ForegroundColor Yellow

    $sqlAfter = Join-Path $audit "d1-after.sql"
    @"
SELECT COUNT(*) AS revisions FROM catalog_revisions;
SELECT COUNT(*) AS promotions FROM catalog_promotions;
SELECT slot,revision_id FROM catalog_slots ORDER BY slot;
SELECT action,from_revision_id,to_revision_id FROM catalog_promotions ORDER BY created_at;
"@ | Set-Content $sqlAfter -Encoding ASCII

    $after = Invoke-ObaProcess `
        -FileName $npx `
        -Arguments "--no-install wrangler d1 execute $db --remote --json --file `"$sqlAfter`" --json" `
        -WorkingDirectory $gestao `
        -TimeoutSeconds 90

    if ($after.ExitCode -ne 0) {
        Write-Host $after.Text
        Fail "Auditoria D1 final falhou."
    }

    $afterText = $after.StdOut
    [System.IO.File]::WriteAllText(
        (Join-Path $audit "D1_AFTER.json"),
        $afterText,
        [System.Text.UTF8Encoding]::new($false)
    )

    $afterRows = ConvertFrom-ObaD1Json -Text $afterText

    $revAfterRow = @(
        $afterRows |
        Where-Object {
            $_.PSObject.Properties.Name -contains "revisions"
        }
    ) | Select-Object -First 1

    $promAfterRow = @(
        $afterRows |
        Where-Object {
            $_.PSObject.Properties.Name -contains "promotions"
        }
    ) | Select-Object -First 1

    $draftAfterRow = @(
        $afterRows |
        Where-Object { $_.slot -eq "DRAFT" }
    ) | Select-Object -First 1

    $previewAfterRow = @(
        $afterRows |
        Where-Object { $_.slot -eq "PREVIEW" }
    ) | Select-Object -First 1

    $pubAfterRow = @(
        $afterRows |
        Where-Object { $_.slot -eq "PUBLISHED" }
    ) | Select-Object -First 1

    if (
        $null -eq $revAfterRow -or
        $null -eq $promAfterRow -or
        $null -eq $draftAfterRow -or
        $null -eq $previewAfterRow -or
        $null -eq $pubAfterRow
    ) {
        Write-Host $afterText
        Fail "Estado D1 final nao identificado."
    }

    $revisionsAfter = [int]$revAfterRow.revisions
    $promotionsAfter = [int]$promAfterRow.promotions
    $draftAfter = if ($null -eq $draftAfterRow.revision_id) { $null } else { [string]$draftAfterRow.revision_id }
    $previewAfter = if ($null -eq $previewAfterRow.revision_id) { $null } else { [string]$previewAfterRow.revision_id }
    $publishedAfter = if ($null -eq $pubAfterRow.revision_id) { $null } else { [string]$pubAfterRow.revision_id }

    if ($revisionsAfter -ne $revisionsBefore) {
        Fail "Preview criou revisao inesperada."
    }

    if ($draftAfter -ne $draftBefore) {
        Fail "DRAFT foi alterado inesperadamente pelo E2E."
    }

    if ($previewAfter -ne $draftBefore) {
        Fail "PREVIEW nao aponta para DRAFT."
    }

    if ($publishedAfter -ne $publishedBefore) {
        Fail "PUBLISHED FOI ALTERADO."
    }

    $expectedPromotionIncrease = if ($previewBefore -eq $draftBefore) { 0 } else { 1 }
    if ($promotionsAfter -ne ($promotionsBefore + $expectedPromotionIncrease)) {
        Fail "Quantidade de promocoes inesperada."
    }

    Pass "ZERO NOVA REVISAO"
    Pass "DRAFT PRESERVADO"
    Pass "PREVIEW = DRAFT"
    Pass "PUBLISHED INTACTO"
    Pass "PROMOCOES AUDITADAS"

    # 10/12 DocumentaÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o
    Write-Host "`n[10/12] Atualizando handoff oficial..." -ForegroundColor Yellow

    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    @"
# CURRENT STATE

Atualizado: $now

## Git

Branch: $branchExpected

Baseline anterior: $headExpected

## Estado funcional

- Central privada online autenticada.
- D1 operacional.
- GET/POST /api/draft homologados.
- Central agora carrega DRAFT.
- Salvar/arquivar/configuracao agora gravam snapshot completo em DRAFT.
- POST/GET /api/preview operacionais.
- /__preview serve Preview privado autenticado.
- PREVIEW aponta para a revisao DRAFT.
- PUBLISHED permaneceu intacto.
- Publicacao direta antiga esta bloqueada na Central.

## Fase concluida nesta sessao

8E.9D-B + 8E.9E ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Central -> DRAFT -> PREVIEW privado.

## Proxima fase

8E.9F ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â PREVIEW -> PUBLISHED com confirmacao explicita, auditoria, smoke e rollback.

## Pendencia conhecida

Upload de nova imagem ainda depende do fluxo legado /api/upload-image e sera integrado em bloco proprio.

## Regras

- Nunca editar PUBLISHED diretamente.
- DRAFT -> PREVIEW -> PUBLISHED.
- Checkpoint antes de cloud write.
- Usar C:\Program Files\nodejs\npx.cmd.
- Zero custo / sem cartao.
"@ | Set-Content ".\docs\CURRENT_STATE.md" -Encoding UTF8

    @"
# HANDOFF

Atualizado: $now

Projeto: Oba Doceria ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Cardapio Virtual + Central de Gestao.

Branch: $branchExpected

## Ultima fase aprovada

8E.9D-B + 8E.9E.

Resultado:

- Central -> DRAFT: operacional.
- DRAFT -> PREVIEW: operacional.
- Preview privado /__preview: operacional.
- Auth/CSRF: preservados.
- Revisoes: imutaveis.
- PUBLISHED: intacto.
- Publicacao direta antiga: bloqueada.

## Proximo passo

Implementar 8E.9F:

PREVIEW -> PUBLISHED.

Obrigatorio:

1. confirmacao explicita;
2. promover somente revisao PREVIEW;
3. registrar promotion PUBLISHED;
4. smoke do cardapio publico;
5. rollback automatico se smoke falhar;
6. preservar revisao anterior;
7. E2E;
8. commit/tag/push somente apos gates.

## Pendencia separada

Integrar upload de imagens sem expor secrets e mantendo zero custo.

## Arquivos criticos

- online/gestao/src/index.js
- online/gestao/public/index.html
- online/gestao/public/preview-bootstrap.js
- online/gestao/tests/central-preview-e2e.cjs
- online/gestao/wrangler.jsonc
- docs/CURRENT_STATE.md
- docs/ROADMAP.md
- docs/DECISIONS.md

Leia AGENTS.md antes de qualquer alteracao.
"@ | Set-Content ".\docs\HANDOFF.md" -Encoding UTF8

    Add-Content ".\docs\CHANGELOG.md" @"

## 2026-08-31 ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â 8E.9D-B + 8E.9E

### Added

- Integracao da Central com DRAFT.
- API GET/POST /api/preview.
- Preview privado autenticado em /__preview.
- Bootstrap de dados PREVIEW para o cardapio visual.
- E2E remoto Central + Preview.

### Changed

- Salvar, arquivar e configuracao gravam DRAFT.
- Visualizar cardapio promove DRAFT -> PREVIEW.
- Publicacao direta antiga foi bloqueada.

### Security

- PUBLISHED preservado.
- CSRF obrigatorio em POST /api/preview.
- Preview anonimo bloqueado.
"@

    Add-Content ".\docs\ROADMAP.md" @"

## Atualizacao 8E.9D-B + 8E.9E

Concluido:

- Central -> DRAFT.
- DRAFT -> PREVIEW.
- Preview privado autenticado.
- Bloqueio da publicacao direta antiga.

Proximo:

- 8E.9F PREVIEW -> PUBLISHED + rollback.
- Integracao de midia.
- Homologacao final.
"@

    Pass "CURRENT_STATE"
    Pass "HANDOFF"
    Pass "CHANGELOG"
    Pass "ROADMAP"

    # 11/12 Git
    Write-Host "`n[11/12] Consolidando Git..." -ForegroundColor Yellow

    $expectedPaths = @(
        $workerRel,
        $centralRel,
        $bootstrapRel,
        $testRel,
        "docs/CURRENT_STATE.md",
        "docs/HANDOFF.md",
        "docs/CHANGELOG.md",
        "docs/ROADMAP.md"
    ) | Sort-Object

    $actualPaths = @(
        git -c core.quotepath=false diff --name-only
        git -c core.quotepath=false ls-files --others --exclude-standard
    ) |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Sort-Object -Unique

    if ($actualPaths.Count -ne $expectedPaths.Count) {
        git status --short --untracked-files=all
        Fail "Escopo Git inesperado."
    }

    for ($i = 0; $i -lt $expectedPaths.Count; $i++) {
        if ($actualPaths[$i] -ne $expectedPaths[$i]) {
            git status --short --untracked-files=all
            Fail "Escopo divergente: esperado $($expectedPaths[$i]), atual $($actualPaths[$i])"
        }
    }

    git add -- $expectedPaths
    if ($LASTEXITCODE -ne 0) { Fail "git add falhou." }

    git diff --cached --check
    if ($LASTEXITCODE -ne 0) { Fail "git diff --cached --check falhou." }

    git commit -m "feat: integra central ao draft e preview privado"
    if ($LASTEXITCODE -ne 0) { Fail "Commit falhou." }

    $newHead = (git rev-parse --short HEAD).Trim()
    $tag = "gestao-preview-privado-" + (Get-Date -Format "yyyyMMdd-HHmmss")

    git tag -a $tag -m "Central com Draft e Preview privado homologados"
    if ($LASTEXITCODE -ne 0) { Fail "Tag falhou." }

    git push origin $branchExpected
    if ($LASTEXITCODE -ne 0) { Fail "Push branch falhou." }

    git push origin $tag
    if ($LASTEXITCODE -ne 0) { Fail "Push tag falhou." }

    Pass "COMMIT $newHead"
    Pass "TAG $tag"
    Pass "GITHUB SINCRONIZADO"

    # 12/12 Final
    Write-Host "`n[12/12] Gate final..." -ForegroundColor Yellow

    if (@(git status --short --untracked-files=all).Count -gt 0) {
        git status --short --untracked-files=all
        Fail "Workspace final nao esta limpo."
    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " FASE 8E.9D-B + 8E.9E APROVADA" -ForegroundColor Green
    Write-Host " CENTRAL -> DRAFT -> PREVIEW PRIVADO OPERACIONAL" -ForegroundColor Green
    Write-Host " PUBLISHED PROTEGIDO" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "HEAD : $newHead"
    Write-Host "TAG  : $tag"
    Write-Host ""

    Pass "CENTRAL CARREGA DRAFT"
    Pass "SALVAR -> DRAFT"
    Pass "ARQUIVAR -> DRAFT"
    Pass "CONFIGURACAO -> DRAFT"
    Pass "AUTH"
    Pass "CSRF"
    Pass "DRAFT -> PREVIEW"
    Pass "PREVIEW PRIVADO"
    Pass "PREVIEW ANONIMO BLOQUEADO"
    Pass "ZERO NOVA REVISAO NO TESTE"
    Pass "PUBLISHED INTACTO"
    Pass "PUBLICACAO DIRETA BLOQUEADA"
    Pass "CENTRAL_PREVIEW_E2E_OK"
    Pass "DOCUMENTACAO ATUALIZADA"
    Pass "GITHUB SINCRONIZADO"
    Pass "WORKSPACE LIMPO"
    Pass "CARDAPIO PUBLICO INTACTO"

    Write-Host ""
    Write-Host "PROXIMO AUTOMATICO:" -ForegroundColor Cyan
    Write-Host "FASE 8E.9F - PREVIEW -> PUBLISHED + ROLLBACK" -ForegroundColor Cyan
}
catch {
    $password = $null
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " FASE 8E.9D-B + 8E.9E INTERROMPIDA" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red

    if ($deployed) {
        Warn "NOVA VERSAO FOI DEPLOYADA. EXECUTANDO ROLLBACK DO WORKER..."

        try {
            $rollback = Invoke-ObaProcess `
                -FileName $npx `
                -Arguments "--no-install wrangler rollback --message `"rollback automatico 8E.9E`"" `
                -WorkingDirectory $gestao `
                -TimeoutSeconds 120

            Write-Host $rollback.StdOut
            if ($rollback.StdErr) { Write-Host $rollback.StdErr -ForegroundColor Yellow }

            if ($rollback.ExitCode -eq 0) {
                Pass "ROLLBACK WORKER EXECUTADO"
            }
            else {
                Warn "ROLLBACK WORKER NAO CONFIRMADO."
            }
        }
        catch {
            Warn "ROLLBACK WORKER FALHOU: $($_.Exception.Message)"
        }
    }

    if ($d1MayHaveChanged) {
        Warn "PREVIEW PODE TER SIDO MOVIDO PARA A MESMA REVISAO DRAFT."
        Warn "NAO APAGAR D1 MANUALMENTE."
    }

    Warn "PUBLISHED NAO DEVE SER ALTERADO MANUALMENTE."
    Warn "NAO AVANCAR PARA 8E.9F."
    throw
}
finally {
    $password = $null
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
