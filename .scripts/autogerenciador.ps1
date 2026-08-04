# Script Autogerenciador
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("planejar", "executar", "auditar")]
    [string]$Acao,
    [string]$Descricao = ""
)

switch ($Acao) {
    "planejar" {
        Write-Host "--- [1/3] INICIANDO FASE DE PLANEJAMENTO ---" -ForegroundColor Cyan
        if ($Descricao -ne "") {
            Set-Content -Path ".plans/ideia_projeto.md" -Value "# Ideia do Projeto`n`n$Descricao"
        }
        git add . ; git commit -m "auto: inicio do planejamento" ; git push
        Write-Host "Revisão necessária: Abra .plans/plano_desenvolvimento.md e valide os requisitos!" -ForegroundColor Yellow
    }
    "executar" {
        Write-Host "--- [2/3] PLANO APROVADO! EXECUTANDO CÓDIGO ---" -ForegroundColor Green
        git add . ; git commit -m "auto: plano aprovado e inicio da execucao em src/" ; git push
        Write-Host "Execução concluída e sincronizada com o GitHub." -ForegroundColor Green
    }
    "auditar" {
        Write-Host "--- [3/3] ENVIANDO PARA REVISÃO CRÍTICA (AUDITORIA) ---" -ForegroundColor Magenta
        New-Item -ItemType Directory -Path .auditoria -Force
        Copy-Item -Path "src/*" -Destination ".auditoria/" -Recurse -Force
        git add . ; git commit -m "auto: snapshot enviado para .auditoria" ; git push
        Write-Host "Código espelhado em .auditoria/ para análise imparcial do modelo!" -ForegroundColor Magenta
    }
}
