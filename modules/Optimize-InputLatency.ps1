<#
================================================================================
 PumpkiN's Modular Suite: 8000Hz Input & Raw Mouse Response
 - Sets MouseDataQueueSize = 200 (prevents buffer drops on 1K-8KHz mice)
 - Disables USB Selective Suspend (prevents root hub sleep lag)
 - Applies MarkC 1:1 linear raw acceleration curve
================================================================================
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "================================================================================" -ForegroundColor Yellow
Write-Host "             ULTRA-LOW LATENCY, DPC & 8000Hz INPUT ENGINE                       " -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Yellow
Write-Host ""

$pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord
Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord
bcdedit /set disabledynamictick yes | Out-Null
bcdedit /set x2apicpolicy Enable | Out-Null
bcdedit /deletevalue useplatformclock | Out-Null
Write-Host "  [+] StopHighDPC zero latency tolerance applied + dynamic tick jitter eliminated" -ForegroundColor Green

Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters' -Name 'MouseDataQueueSize' -Value 200 -Type DWord
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters' -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord

$mouseKey = 'HKCU:\Control Panel\Mouse'
Set-ItemProperty -Path $mouseKey -Name 'MouseSpeed' -Value '0' -Type String
Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold1' -Value '0' -Type String
Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold2' -Value '0' -Type String
[byte[]]$sx = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x29,0xdc,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00
[byte[]]$sy = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xa8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xe0,0x00,0x00,0x00,0x00,0x00
Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseXCurve' -Value $sx -Type Binary
Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseYCurve' -Value $sy -Type Binary

Write-Host "  [+] 8000Hz Mouse Buffer tuned + 100% Raw 1:1 Mouse Input Curve applied" -ForegroundColor Green
Write-Host "`n[OK] Input latency optimizations applied successfully!" -ForegroundColor Green

Read-Host "`nPress Enter to exit"
