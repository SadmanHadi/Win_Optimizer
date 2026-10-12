<#
================================================================================
  PumpkiN's Modular Suite: Wi-Fi Background Roaming Spike Mitigator
================================================================================
#>

function Toggle-WifiAutoconfig {
    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host "                       WI-FI BACKGROUND SCAN MITIGATOR                          " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "Windows scans for Wi-Fi networks every 60s in the background, causing 100-300ms ping spikes."
    Write-Host "Disabling AutoConfig during gaming gives flat, wired-like ping."
    Write-Host ""
    $wifi = Get-NetAdapter | Where-Object { $_.InterfaceType -eq 71 -or $_.InterfaceDescription -match 'Wi-Fi|Wireless' } | Select-Object -First 1
    if (-not $wifi) {
        Write-Host "[!] No active Wi-Fi adapter detected on this PC." -ForegroundColor Yellow
        Read-Host "Press Enter to return"
        return
    }
    Write-Host "Active Wi-Fi Adapter: $($wifi.Name)" -ForegroundColor Green
    Write-Host "  [1] DISABLE Background Scan (Competitive Gaming Mode - ZERO Ping Spikes)" -ForegroundColor Green
    Write-Host "  [2] ENABLE Background Scan (Normal Mode - Discover New Wi-Fi Networks)" -ForegroundColor Yellow
    Write-Host "  [0] Back to Main Menu"
    $wChoice = Read-Host "`nSelect option [0-2]"
    switch ($wChoice) {
        "1" {
            netsh wlan set autoconfig enabled=no interface="$($wifi.Name)"
            Write-Host "`n[OK] Wi-Fi AutoConfig DISABLED! Background scanning is frozen for 0ms ping spikes." -ForegroundColor Green
        }
        "2" {
            netsh wlan set autoconfig enabled=yes interface="$($wifi.Name)"
            Write-Host "`n[OK] Wi-Fi AutoConfig ENABLED! Normal Wi-Fi discovery restored." -ForegroundColor Green
        }
    }
}

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"" -Verb RunAs
        exit
    }
    Toggle-WifiAutoconfig
    Read-Host "
Press Enter to exit"
}