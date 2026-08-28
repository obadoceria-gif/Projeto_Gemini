@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".scripts\CARDAPIO-abrir-central.ps1"
if errorlevel 1 pause
