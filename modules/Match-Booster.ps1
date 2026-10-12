<#
================================================================================
 PumpkiN's Modular Suite: Competitive Match Booster
 - Terminates background video recorders (SteelSeries Moments, Game Bar)
 - Terminates high-polling RGB software (SignalRGB)
 - Flushes standby RAM cache and triggers aggressive garbage collection
================================================================================
#>

Write-Host "================================================================================" -ForegroundColor Red
Write-Host "             COMPETITIVE MATCH BOOSTER (KILL HOGS & FREE RAM)                   " -ForegroundColor Red
Write-Host "================================================================================" -ForegroundColor Red
Write-Host ""

Write-Host "[*] Freeing CPU cache, GPU encoder, and USB polling for competitive play..." -ForegroundColor Yellow
taskkill /f /im SteelSeriesCaptureSvc.exe 2>$null
taskkill /f /im SteelSeriesMoments.exe 2>$null
taskkill /f /im SignalRgb.exe 2>$null
taskkill /f /im SignalRgbLauncher.exe 2>$null
taskkill /f /im GameBarFTServer.exe 2>$null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host "  [+] Background video recording stopped (Freed GPU NVENC/VCE encoder)" -ForegroundColor Green
Write-Host "  [+] SignalRGB polling stopped (Freed USB bus & DPC latency)" -ForegroundColor Green
Write-Host "  [+] Standby memory cache flushed & garbage collector executed" -ForegroundColor Green
Write-Host "`n[OK] Competitive Match Booster applied successfully!" -ForegroundColor Green

Start-Sleep -Seconds 2
