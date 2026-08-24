@echo off
setlocal
cd /d "%~dp0\..\.."

for /f "delims=" %%i in ('git rev-parse --show-toplevel 2^>nul') do set ROOT=%%i
if not defined ROOT (
  echo [ERRO] Esta pasta nao esta dentro de um repositorio Git.
  pause
  exit /b 1
)
cd /d "%ROOT%"

echo [1/4] Verificando se o repositorio esta limpo...
for /f "delims=" %%i in ('git status --porcelain') do set DIRTY=1
if defined DIRTY (
  echo [ERRO] Existem alteracoes pendentes. A Sprint nao sera aplicada.
  git status
  pause
  exit /b 1
)

echo [2/4] Validando patch...
git apply --check "%~dp0sprint-1.4.patch"
if errorlevel 1 (
  echo [ERRO] O patch nao corresponde ao estado atual do projeto. Nada foi alterado.
  pause
  exit /b 1
)

echo [3/4] Aplicando Sprint 1.4...
git apply "%~dp0sprint-1.4.patch"
if errorlevel 1 (
  echo [ERRO] Falha ao aplicar a Sprint.
  pause
  exit /b 1
)

echo [4/4] Concluido.
echo.
echo Abra no navegador:
echo http://127.0.0.1:5501/diagnostics/app-catalog-service-check.html
echo.
echo Depois teste o cardapio em:
echo http://127.0.0.1:5501/
echo.
git status --short
pause
