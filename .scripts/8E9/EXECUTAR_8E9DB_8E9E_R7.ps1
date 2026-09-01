$ErrorActionPreference = "Stop"

function Pass($m) { Write-Host "[PASS] $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m) { throw $m }

function SecureToPlain {
    param([Security.SecureString]$Secure)
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
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
        if (-not $p.Start()) { throw "Nao foi possivel iniciar: $FileName" }

        if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
            try { $p.Kill() } catch {}
            throw "TIMEOUT apos $TimeoutSeconds s: $FileName"
        }

        return [PSCustomObject]@{
            ExitCode = $p.ExitCode
            StdOut = $p.StandardOutput.ReadToEnd()
            StdErr = $p.StandardError.ReadToEnd()
        }
    }
    finally {
        if ($p) { $p.Dispose() }
    }
}

function Invoke-D1Rows {
    param([Parameter(Mandatory=$true)][string]$Sql)

    $escaped = $Sql.Replace('"','\"')

    $result = Invoke-ObaProcess `
        -FileName $script:npx `
        -Arguments "--no-install wrangler d1 execute $script:db --remote --command `"$escaped`" --json" `
        -WorkingDirectory $script:gestao `
        -TimeoutSeconds 90

    if ($result.ExitCode -ne 0) {
        Write-Host $result.StdOut
        Write-Host $result.StdErr -ForegroundColor Yellow
        throw "Consulta D1 falhou."
    }

    $raw = $result.StdOut.Trim()

    try {
        $parsed = $raw | ConvertFrom-Json
    }
    catch {
        Write-Host "----- D1 STDOUT -----" -ForegroundColor Yellow
        Write-Host $result.StdOut
        Write-Host "----- D1 STDERR -----" -ForegroundColor Yellow
        Write-Host $result.StdErr
        throw "Wrangler nao retornou JSON valido no stdout."
    }

    $rows = @()

    foreach ($entry in @($parsed)) {
        if ($null -ne $entry -and $entry.PSObject.Properties.Name -contains "results") {
            foreach ($row in @($entry.results)) {
                if ($null -ne $row) { $rows += $row }
            }
        }
    }

    return $rows
}

function Get-D1State {
    $slotRows = @(Invoke-D1Rows "SELECT slot, revision_id FROM catalog_slots ORDER BY slot;")
    $revRows  = @(Invoke-D1Rows "SELECT COUNT(*) AS revisions FROM catalog_revisions;")
    $promRows = @(Invoke-D1Rows "SELECT COUNT(*) AS promotions FROM catalog_promotions;")

    $draft = @($slotRows | Where-Object { $_.slot -eq "DRAFT" }) | Select-Object -First 1
    $preview = @($slotRows | Where-Object { $_.slot -eq "PREVIEW" }) | Select-Object -First 1
    $published = @($slotRows | Where-Object { $_.slot -eq "PUBLISHED" }) | Select-Object -First 1
    $revisions = @($revRows | Where-Object { $_.PSObject.Properties.Name -contains "revisions" }) | Select-Object -First 1
    $promotions = @($promRows | Where-Object { $_.PSObject.Properties.Name -contains "promotions" }) | Select-Object -First 1

    if ($null -eq $draft -or $null -eq $preview -or $null -eq $published -or $null -eq $revisions -or $null -eq $promotions) {
        Write-Host "DEBUG slotRows:" -ForegroundColor Yellow
        $slotRows | ConvertTo-Json -Depth 5 | Write-Host
        Write-Host "DEBUG revRows:" -ForegroundColor Yellow
        $revRows | ConvertTo-Json -Depth 5 | Write-Host
        Write-Host "DEBUG promRows:" -ForegroundColor Yellow
        $promRows | ConvertTo-Json -Depth 5 | Write-Host
        throw "Estado D1 incompleto."
    }

    return [PSCustomObject]@{
        Draft = if ($null -eq $draft.revision_id) { $null } else { [string]$draft.revision_id }
        Preview = if ($null -eq $preview.revision_id) { $null } else { [string]$preview.revision_id }
        Published = if ($null -eq $published.revision_id) { $null } else { [string]$published.revision_id }
        Revisions = [int]$revisions.revisions
        Promotions = [int]$promotions.promotions
    }
}

$root = "C:\Users\pc_fa\Documents\Projeto_Gemini"
$gestao = Join-Path $root "online\gestao"
$npx = "C:\Program Files\nodejs\npx.cmd"
$db = "oba-cardapio-catalogo"
$baseUrl = "https://oba-cardapio-gestao.obadoceria.workers.dev"

$branchExpected = "feature/gestao-online-segura"

$workerRel = "online/gestao/src/index.js"
$centralRel = "online/gestao/public/index.html"
$bootstrapRel = "online/gestao/public/preview-bootstrap.js"
$testRel = "online/gestao/tests/central-preview-e2e.cjs"

$worker = Join-Path $root $workerRel
$central = Join-Path $root $centralRel
$bootstrap = Join-Path $root $bootstrapRel
$testFile = Join-Path $root $testRel

$patcher = Join-Path $root ".scripts\8E9\PATCH_8E9_PREVIEW.cjs"
$sourceTest = Join-Path $root ".scripts\8E9\CENTRAL_PREVIEW_E2E.cjs"

$deployed = $false
$d1Touched = $false
$password = $null

Set-Location $root

try {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host " FASE 8E.9D-B + 8E.9E-R7" -ForegroundColor Cyan
    Write-Host " CENTRAL -> DRAFT -> PREVIEW PRIVADO" -ForegroundColor Cyan
    Write-Host " RUNNER NOVO / D1 POR CONSULTAS JSON ISOLADAS" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan

    # 1/11
    Write-Host "`n[1/11] Validando baseline atual..." -ForegroundColor Yellow

    $branch = (git branch --show-current).Trim()
    $head = (git rev-parse --short HEAD).Trim()

    Write-Host "Branch : $branch"
    Write-Host "HEAD   : $head"

    if ($branch -ne $branchExpected) { Fail "Branch inesperada." }
    if (-not (Test-Path $npx)) { Fail "NPX global ausente." }
    if (-not (Test-Path $patcher)) { Fail "Patcher 8E9 ausente." }
    if (-not (Test-Path $sourceTest)) { Fail "E2E 8E9 ausente." }

    if (Test-Path ".\.wrangler\cache") {
        Remove-Item ".\.wrangler\cache" -Recurse -Force
    }

    $status = @(git status --short --untracked-files=all)
    if ($status.Count -gt 0) {
        git status --short --untracked-files=all
        Fail "Workspace nao esta limpo."
    }

    node.exe --check $worker
    if ($LASTEXITCODE -ne 0) { Fail "Worker baseline invalido." }

    Pass "BASELINE DINAMICA $head"
    Pass "WORKSPACE LIMPO"

    # 2/11
    Write-Host "`n[2/11] Criando checkpoint..." -ForegroundColor Yellow

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $audit = Join-Path $root ".auditoria\Online\8E9_R7_$stamp"
    New-Item -ItemType Directory -Force -Path $audit | Out-Null

    git bundle create (Join-Path $audit "PRE_8E9_R7.bundle") --all
    if ($LASTEXITCODE -ne 0) { Fail "Checkpoint Git falhou." }

    Copy-Item $worker (Join-Path $audit "worker.BASELINE.js") -Force
    Copy-Item $central (Join-Path $audit "central.BASELINE.html") -Force

    Pass "CHECKPOINT CRIADO"

    # 3/11
    Write-Host "`n[3/11] Auditando D1 com consultas isoladas..." -ForegroundColor Yellow

    $pre = Get-D1State

    Write-Host "DRAFT      : $($pre.Draft)"
    Write-Host "PREVIEW    : $($pre.Preview)"
    Write-Host "PUBLISHED  : $($pre.Published)"
    Write-Host "REVISOES   : $($pre.Revisions)"
    Write-Host "PROMOCOES  : $($pre.Promotions)"

    if ([string]::IsNullOrWhiteSpace($pre.Draft)) { Fail "DRAFT vazio." }
    if ([string]::IsNullOrWhiteSpace($pre.Published)) { Fail "PUBLISHED vazio." }
    if ($pre.Draft -ne $pre.Published) { Fail "DRAFT diverge de PUBLISHED na baseline." }

    if (
        -not [string]::IsNullOrWhiteSpace($pre.Preview) -and
        $pre.Preview -ne $pre.Draft
    ) {
        Fail "PREVIEW inicial inesperado."
    }

    Pass "D1 REAL IDENTIFICADO"
    Pass "DRAFT = PUBLISHED"
    Pass "PREVIEW CONTROLADO"

    # 4/11
    Write-Host "`n[4/11] Aplicando patch deterministico..." -ForegroundColor Yellow

    Copy-Item $sourceTest $testFile -Force

    $patch = Invoke-ObaProcess `
        -FileName "node.exe" `
        -Arguments "`"$patcher`" `"$worker`" `"$central`" `"$bootstrap`"" `
        -WorkingDirectory $root `
        -TimeoutSeconds 30

    if ($patch.StdOut) { Write-Host $patch.StdOut }
    if ($patch.StdErr) { Write-Host $patch.StdErr -ForegroundColor Yellow }

    if ($patch.ExitCode -ne 0 -or $patch.StdOut -notmatch "PATCH_8E9_PREVIEW_OK") {
        git restore --source=HEAD --staged --worktree -- $workerRel $centralRel
        Remove-Item $bootstrap -Force -ErrorAction SilentlyContinue
        Remove-Item $testFile -Force -ErrorAction SilentlyContinue
        Fail "Patch falhou. Arquivos funcionais restaurados."
    }

    node.exe --check $worker
    if ($LASTEXITCODE -ne 0) { Fail "Worker modificado invalido." }

    node.exe --check $bootstrap
    if ($LASTEXITCODE -ne 0) { Fail "Bootstrap invalido." }

    node.exe --check $testFile
    if ($LASTEXITCODE -ne 0) { Fail "E2E invalido." }

    Pass "PATCH APLICADO"
    Pass "NODE CHECKS"

    # 5/11
    Write-Host "`n[5/11] Executando gates locais..." -ForegroundColor Yellow

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
    finally { Pop-Location }

    git diff --check
    if ($LASTEXITCODE -ne 0) { Fail "git diff --check falhou." }

    $dry = Invoke-ObaProcess `
        -FileName $npx `
        -Arguments "--no-install wrangler deploy --dry-run" `
        -WorkingDirectory $gestao `
        -TimeoutSeconds 120

    if ($dry.StdOut) { Write-Host $dry.StdOut }
    if ($dry.StdErr) { Write-Host $dry.StdErr -ForegroundColor Yellow }

    if ($dry.ExitCode -ne 0) { Fail "Wrangler dry-run falhou." }

    Pass "GATES LOCAIS"
    Pass "WRANGLER BUILD"

    # 6/11
    Write-Host "`n[6/11] Deploy controlado da Central privada..." -ForegroundColor Yellow
    Warn "HAVERA DEPLOY DA CENTRAL PRIVADA."
    Warn "NAO HAVERA PROMOCAO PARA PUBLISHED."

    $deploy = Invoke-ObaProcess `
        -FileName $npx `
        -Arguments "--no-install wrangler deploy" `
        -WorkingDirectory $gestao `
        -TimeoutSeconds 120

    if ($deploy.StdOut) { Write-Host $deploy.StdOut }
    if ($deploy.StdErr) { Write-Host $deploy.StdErr -ForegroundColor Yellow }

    if ($deploy.ExitCode -ne 0) { Fail "Deploy falhou." }

    $deployed = $true
    Pass "CENTRAL PRIVADA DEPLOYADA"
    Start-Sleep -Seconds 5

    # 7/11
    Write-Host "`n[7/11] Executando E2E remoto..." -ForegroundColor Yellow
    Write-Host "Informe a senha administrativa uma vez." -ForegroundColor Cyan

    $secure = Read-Host "Senha administrativa" -AsSecureString
    $password = SecureToPlain $secure
    $secure = $null

    if ([string]::IsNullOrWhiteSpace($password)) { Fail "Senha vazia." }

    $d1Touched = $true

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

    if ($e2e.StdOut) { Write-Host $e2e.StdOut }
    if ($e2e.StdErr) { Write-Host $e2e.StdErr -ForegroundColor Yellow }

    if ($e2e.ExitCode -ne 0 -or $e2e.StdOut -notmatch "CENTRAL_PREVIEW_E2E_OK") {
        Fail "E2E Central/Preview falhou."
    }

    Pass "CENTRAL_PREVIEW_E2E_OK"

    # 8/11
    Write-Host "`n[8/11] Auditando D1 pos-E2E..." -ForegroundColor Yellow

    $post = Get-D1State

    Write-Host "DRAFT      : $($post.Draft)"
    Write-Host "PREVIEW    : $($post.Preview)"
    Write-Host "PUBLISHED  : $($post.Published)"
    Write-Host "REVISOES   : $($post.Revisions)"
    Write-Host "PROMOCOES  : $($post.Promotions)"

    if ($post.Revisions -ne $pre.Revisions) { Fail "Preview criou revisao inesperada." }
    if ($post.Draft -ne $pre.Draft) { Fail "DRAFT mudou inesperadamente." }
    if ($post.Preview -ne $pre.Draft) { Fail "PREVIEW nao aponta para DRAFT." }
    if ($post.Published -ne $pre.Published) { Fail "PUBLISHED FOI ALTERADO." }

    $expectedPromotionIncrease =
        if ($pre.Preview -eq $pre.Draft) { 0 } else { 1 }

    if ($post.Promotions -ne ($pre.Promotions + $expectedPromotionIncrease)) {
        Fail "Quantidade de promocoes inesperada."
    }

    Pass "ZERO NOVA REVISAO"
    Pass "DRAFT PRESERVADO"
    Pass "PREVIEW = DRAFT"
    Pass "PUBLISHED INTACTO"

    # 9/11
    Write-Host "`n[9/11] Atualizando documentacao..." -ForegroundColor Yellow

    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    @"
# CURRENT STATE

Atualizado: $now

## Git
Branch: $branchExpected
Baseline anterior da fase: $head

## Estado funcional
- Central privada autenticada.
- D1 operacional.
- GET/POST /api/draft homologados.
- Central carrega DRAFT.
- Salvar/arquivar/configuracao gravam DRAFT.
- GET/POST /api/preview homologados.
- /__preview privado autenticado.
- PREVIEW = DRAFT.
- PUBLISHED preservado.
- Publicacao direta antiga bloqueada.

## Ultima fase aprovada
8E.9D-B + 8E.9E — Central -> DRAFT -> PREVIEW privado.

## Proxima fase
8E.9F — PREVIEW -> PUBLISHED com confirmacao, smoke e rollback.

## Pendencia separada
Upload de imagens online.
"@ | Set-Content ".\docs\CURRENT_STATE.md" -Encoding UTF8

    @"
# HANDOFF

Atualizado: $now

Projeto: Oba Doceria — Cardapio Virtual + Central de Gestao.
Branch: $branchExpected

## Ultima fase aprovada
8E.9D-B + 8E.9E.

- Central -> DRAFT: operacional.
- DRAFT -> PREVIEW: operacional.
- Preview privado: operacional.
- Auth/CSRF: preservados.
- PUBLISHED: intacto.
- Publicacao direta antiga: bloqueada.

## Proximo passo
8E.9F — PREVIEW -> PUBLISHED + rollback seguro.

Leia AGENTS.md, docs/CURRENT_STATE.md, docs/DECISIONS.md e docs/ROADMAP.md antes de alterar codigo.
"@ | Set-Content ".\docs\HANDOFF.md" -Encoding UTF8

    Add-Content ".\docs\CHANGELOG.md" @"

## 2026-09-01 — 8E.9D-B + 8E.9E

### Added
- Central integrada ao DRAFT.
- API PREVIEW.
- Preview privado autenticado.
- E2E remoto de Preview.

### Security
- PUBLISHED preservado.
- CSRF exigido no Preview.
- Preview anonimo bloqueado.
"@

    Add-Content ".\docs\ROADMAP.md" @"

## Atualizacao 8E.9D-B + 8E.9E
Concluido: Central -> DRAFT -> PREVIEW privado.
Proximo: 8E.9F PREVIEW -> PUBLISHED + rollback.
"@

    Pass "DOCUMENTACAO ATUALIZADA"

    # 10/11
    Write-Host "`n[10/11] Consolidando Git..." -ForegroundColor Yellow

    $expected = @(
        $workerRel,
        $centralRel,
        $bootstrapRel,
        $testRel,
        "docs/CURRENT_STATE.md",
        "docs/HANDOFF.md",
        "docs/CHANGELOG.md",
        "docs/ROADMAP.md"
    ) | Sort-Object

    $actual = @(
        git -c core.quotepath=false diff --name-only
        git -c core.quotepath=false ls-files --others --exclude-standard
    ) |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Sort-Object -Unique

    $unexpected = @($actual | Where-Object { $_ -notin $expected })
    $missing = @($expected | Where-Object { $_ -notin $actual })

    if ($unexpected.Count -gt 0 -or $missing.Count -gt 0) {
        Write-Host "UNEXPECTED: $($unexpected -join ', ')"
        Write-Host "MISSING   : $($missing -join ', ')"
        git status --short --untracked-files=all
        Fail "Escopo Git final inesperado."
    }

    git add -- $expected
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

    # 11/11
    Write-Host "`n[11/11] Gate final..." -ForegroundColor Yellow

    if (Test-Path ".\.wrangler\cache") {
        Remove-Item ".\.wrangler\cache" -Recurse -Force
    }

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
    Write-Host "HEAD : $newHead"
    Write-Host "TAG  : $tag"

    Pass "CENTRAL CARREGA DRAFT"
    Pass "SALVAR -> DRAFT"
    Pass "ARQUIVAR -> DRAFT"
    Pass "CONFIGURACAO -> DRAFT"
    Pass "DRAFT -> PREVIEW"
    Pass "PREVIEW PRIVADO"
    Pass "AUTH + CSRF"
    Pass "PUBLISHED INTACTO"
    Pass "PUBLICACAO DIRETA BLOQUEADA"
    Pass "E2E REMOTO"
    Pass "GITHUB SINCRONIZADO"
    Pass "WORKSPACE LIMPO"
    Pass "CARDAPIO PUBLICO INTACTO"

    Write-Host ""
    Write-Host "PROXIMO AUTOMATICO:" -ForegroundColor Cyan
    Write-Host "8E.9F - PREVIEW -> PUBLISHED + ROLLBACK SEGURO" -ForegroundColor Cyan
}
catch {
    $password = $null
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " FASE 8E.9D-B + 8E.9E-R7 INTERROMPIDA" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    if ($deployed) {
        Warn "WORKER NOVO FOI DEPLOYADO. EXECUTANDO ROLLBACK..."
        try {
            $rb = Invoke-ObaProcess `
                -FileName $npx `
                -Arguments "--no-install wrangler rollback --message `"rollback automatico 8E.9E-R7`"" `
                -WorkingDirectory $gestao `
                -TimeoutSeconds 120

            if ($rb.StdOut) { Write-Host $rb.StdOut }
            if ($rb.StdErr) { Write-Host $rb.StdErr -ForegroundColor Yellow }

            if ($rb.ExitCode -eq 0) { Pass "ROLLBACK WORKER EXECUTADO" }
            else { Warn "ROLLBACK WORKER NAO CONFIRMADO." }
        }
        catch {
            Warn "ROLLBACK FALHOU: $($_.Exception.Message)"
        }
    }

    if ($d1Touched) {
        Warn "PREVIEW PODE TER SIDO ATUALIZADO PARA DRAFT."
        Warn "NAO APAGAR D1 MANUALMENTE."
    }

    Warn "NAO ALTERAR PUBLISHED MANUALMENTE."
    Warn "NAO AVANCAR PARA 8E.9F."
    throw
}
finally {
    $password = $null
}
