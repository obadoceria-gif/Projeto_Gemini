$ErrorActionPreference = "Stop"

$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

$branch = (git branch --show-current).Trim()
$head = (git rev-parse --short HEAD).Trim()
$tag = (git describe --tags --abbrev=0 2>$null)

$status = @(git status --short --untracked-files=all)

$stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$recent = @(
    git log -5 --pretty=format:"- %h %s"
)

$state = @"
# HANDOFF AUTOMATICO

Atualizado: $stamp

## Git

Branch: $branch

HEAD: $head

Última tag: $tag

## Workspace

$(
    if ($status.Count -eq 0) {
        "Limpo."
    } else {
        ($status -join "`n")
    }
)

## Últimos commits

$($recent -join "`n")

## Antes de continuar

Leia também:

- docs/CURRENT_STATE.md
- docs/DECISIONS.md
- docs/ROADMAP.md
- AGENTS.md

## Regra

Este arquivo contém o snapshot Git automático.

A IA responsável pelo encerramento da sessão deve complementar semanticamente:
- o que foi implementado;
- última fase aprovada;
- blockers;
- próximos passos;
- riscos e arquivos críticos.
"@

Set-Content ".\docs\HANDOFF_AUTO.md" $state -Encoding UTF8

Write-Host ""
Write-Host "[PASS] HANDOFF_AUTO.md atualizado" -ForegroundColor Green
Write-Host "Branch : $branch"
Write-Host "HEAD   : $head"
Write-Host "Tag    : $tag"
