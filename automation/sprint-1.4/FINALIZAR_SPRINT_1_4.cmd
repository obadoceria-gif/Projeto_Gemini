@echo off
setlocal
cd /d "%~dp0\..\.."
for /f "delims=" %%i in ('git rev-parse --show-toplevel 2^>nul') do set ROOT=%%i
if not defined ROOT (
  echo [ERRO] Repositorio Git nao encontrado.
  pause
  exit /b 1
)
cd /d "%ROOT%"

echo Este comando deve ser usado SOMENTE depois dos testes aprovados.
echo.
choice /C SN /M "Os diagnosticos e o teste visual foram aprovados"
if errorlevel 2 exit /b 0

echo [1/5] Atualizando documentacao final da Sprint...
git apply --check "%~dp0sprint-1.4-finalize.patch"
if errorlevel 1 (
  echo [ERRO] Nao foi possivel validar a atualizacao final da documentacao.
  pause
  exit /b 1
)
git apply "%~dp0sprint-1.4-finalize.patch"
if errorlevel 1 exit /b 1

echo [2/5] Adicionando somente arquivos da Sprint...
git add src/app.js diagnostics/app-catalog-service-check.html .projeto/STATUS.md .projeto/SPRINTS/SPRINT_1_4.md
if errorlevel 1 exit /b 1

echo [3/5] Criando commit...
git commit -m "feat: inicializa catalog service no app"
if errorlevel 1 exit /b 1

echo [4/5] Enviando ao GitHub...
git push
if errorlevel 1 exit /b 1

echo [5/5] Estado final:
git status
pause
