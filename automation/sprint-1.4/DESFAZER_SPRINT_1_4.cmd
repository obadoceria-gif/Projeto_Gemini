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

echo Restaurando arquivos alterados pela Sprint 1.4...
git restore -- src/app.js .projeto/STATUS.md 2>nul
if exist diagnostics\app-catalog-service-check.html del /q diagnostics\app-catalog-service-check.html
if exist .projeto\SPRINTS\SPRINT_1_4.md del /q .projeto\SPRINTS\SPRINT_1_4.md

echo Estado atual:
git status --short
pause
