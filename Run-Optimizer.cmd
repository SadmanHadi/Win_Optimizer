@echo off
:: ==============================================================================
:: PumpkiN's Ultimate Windows Optimizer - 1-Click Administrative Launcher
:: Runs without ExecutionPolicy restrictions, elevates automatically, zero AV flags
:: ==============================================================================
setlocal EnableDelayedExpansion

cd /d "%~dp0"

:: Check for Administrator elevation
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :RunElevated
) else (
    goto :Elevate
)

:Elevate
echo [*] Requesting Administrator privileges...
powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -NoLogo -ExecutionPolicy Bypass -File \"\"%~dp0optimizer.ps1\"\" %*' -WorkingDirectory \"\"%~dp0\"\" -Verb RunAs"
exit /b

:RunElevated
powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -File "%~dp0optimizer.ps1" %*
exit /b
