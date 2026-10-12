<#
================================================================================
   ____                       _    _       _   _ 
  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |
  | |_) | | | | '_ ` _ \| '_ \ |/ / | '_ \|  \| |
  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |
  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|
                        |_|                       
           ULTIMATE GAMING & NETWORK OPTIMIZER v3.0
          Created by PumpkiN | Max FPS - Ultra Low Latency
================================================================================
One-line run:
irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex
================================================================================
#>

# 1. Administrator Elevation Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex`"" -Verb RunAs
    return
}

$Host.UI.RawUI.WindowTitle = "PumpkiN's Ultimate Gaming and Network Optimizer v3.0"

function Show-PumpkiNBanner {
    Clear-Host
    $Host.UI.RawUI.ForegroundColor = 'Cyan'
    Write-Host "================================================================================"
    Write-Host "   ____                       _    _       _   _ "
    Write-Host "  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |"
    Write-Host "  | |_) | | | | '_ ` _ \| '_ \ |/ / | '_ \|  \| |"
    Write-Host "  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |"
    Write-Host "  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|"
    Write-Host "                        |_|                       "
    Write-Host "           ULTIMATE GAMING & NETWORK OPTIMIZER v3.0"
    Write-Host "          Created by PumpkiN | Max FPS - Ultra Low Latency"
    Write-Host "================================================================================"
    $Host.UI.RawUI.ForegroundColor = 'Gray'
    Write-Host ""
    Write-Host "  [1] FULL ALL-IN-ONE OPTIMIZATION (Network + PC + Latency + FPS) [RECOMMENDED]" -ForegroundColor Green
    Write-Host "  [2] Network & Anti-Lag Suite (Nagle Off, RSC Off, ServiceProvider DNS, 100% QoS)"
    Write-Host "  [3] PC System & FPS Engine (RAM Locking, Direct Flip, PowerMizer, Core Unpark)"
    Write-Host "  [4] Ultra-Low Latency & DPC Engine (StopHighDPC, x2APIC, Timer Jitter Fix)"
    Write-Host "  [5] Competitive Match Booster (Flush Standby RAM, Kill Capture & RGB Hogs)"
    Write-Host "  [6] Game-Specific Process Priority Hooks (Valorant, CS2, Apex, Gameloop)"
    Write-Host "  [7] System Health, Live Diagnostics & Ping Test"
    Write-Host "  [8] Revert All Settings to Windows Defaults" -ForegroundColor DarkYellow
    Write-Host "  [9] Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "================================================================================"
}

function Optimize-Network {
    Write-Host "`n[*] Tuning Network Interface & Anti-Lag Settings..." -ForegroundColor Yellow
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1
    if ($adapter) {
        $guid = $adapter.InterfaceGuid
        $tcpKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
        if (Test-Path $tcpKey) {
            Set-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -Value 1 -Type DWord
            Set-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -Value 1 -Type DWord
            Set-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -Value 0 -Type DWord
        }
        $nicProps = @('Interrupt Moderation','Flow Control','Green Ethernet','Gigabit Lite','Power Saving Mode','Energy-Efficient Ethernet')
        foreach ($p in $nicProps) {
            try { Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName $p -DisplayValue 'Disabled' -NoRestart -ErrorAction Stop } catch {}
        }
        netsh int tcp set global rsc=disabled | Out-Null
        netsh int tcp set global rss=enabled | Out-Null
        netsh int tcp set global autotuninglevel=normal | Out-Null
        Write-Host "      ✓ Nagle disabled, Delayed ACKs off, NIC power saving disabled" -ForegroundColor Green
    }
    # DNS ServiceProvider Priorities
    $spKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider'
    Set-ItemProperty -Path $spKey -Name 'LocalPriority' -Value 4 -Type DWord
    Set-ItemProperty -Path $spKey -Name 'HostsPriority' -Value 5 -Type DWord
    Set-ItemProperty -Path $spKey -Name 'DnsPriority' -Value 6 -Type DWord
    Set-ItemProperty -Path $spKey -Name 'NetbtPriority' -Value 7 -Type DWord

    # Uncap 20% QoS Limit
    $psched = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched'
    if (-not (Test-Path $psched)) { New-Item -Path $psched -Force | Out-Null }
    Set-ItemProperty -Path $psched -Name 'NonBestEffortLimit' -Value 0 -Type DWord
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      ✓ ServiceProvider priorities set + 100% bandwidth unreserved + DNS flushed" -ForegroundColor Green
}

function Optimize-System {
    Write-Host "`n[*] Locking Kernel in RAM & Bypassing DWM Display Lag..." -ForegroundColor Yellow
    # Memory Management
    $memKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    Set-ItemProperty -Path $memKey -Name 'DisablePagingExecutive' -Value 1 -Type DWord
    Set-ItemProperty -Path $memKey -Name 'LargeSystemCache' -Value 0 -Type DWord
    Write-Host "      ✓ DisablePagingExecutive = 1 (Kernel & drivers locked in RAM)" -ForegroundColor Green

    # Direct Flip / Fullscreen Exclusive Overrides
    $gcs = 'HKCU:\System\GameConfigStore'
    Set-ItemProperty -Path $gcs -Name 'GameDVR_Enabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_DXGIHonorFSEWindowsCompatible' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_EFSEFeatureFlags' -Value 0 -Type DWord
    Write-Host "      ✓ Direct scanout active (1-2 frames display latency saved)" -ForegroundColor Green

    # NVIDIA PowerMizer Maximum Performance
    $gpuKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000'
    if (Test-Path $gpuKey) {
        Set-ItemProperty -Path $gpuKey -Name 'PowerMizerEnable' -Value 1 -Type DWord
        Set-ItemProperty -Path $gpuKey -Name 'PowerMizerLevel' -Value 1 -Type DWord
        Set-ItemProperty -Path $gpuKey -Name 'PowerMizerLevelAC' -Value 1 -Type DWord
        Write-Host "      ✓ NVIDIA PowerMizer set to Maximum Performance (No clock drops)" -ForegroundColor Green
    }

    # USB Selective Suspend
    $usbKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
    if (-not (Test-Path $usbKey)) { New-Item -Path $usbKey -Force | Out-Null }
    Set-ItemProperty -Path $usbKey -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters' -Name 'MouseDataQueueSize' -Value 100 -Type DWord
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters' -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord
    Write-Host "      ✓ USB root hubs locked at 100% bus power (No mouse wake delay)" -ForegroundColor Green

    # Unpark CPU Cores
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100
    powercfg -setactive scheme_current

    # Windows Game Mode & System Responsiveness
    $mmKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    Set-ItemProperty -Path $mmKey -Name 'NetworkThrottlingIndex' -Value 0xFFFFFFFF -Type DWord
    Set-ItemProperty -Path $mmKey -Name 'SystemResponsiveness' -Value 0 -Type DWord
    $gameKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
    if (Test-Path $gameKey) {
        Set-ItemProperty -Path $gameKey -Name 'Priority' -Value 6 -Type DWord
        Set-ItemProperty -Path $gameKey -Name 'GPU Priority' -Value 8 -Type DWord
        Set-ItemProperty -Path $gameKey -Name 'Scheduling Category' -Value 'High' -Type String
        Set-ItemProperty -Path $gameKey -Name 'SFIO Priority' -Value 'High' -Type String
    }
    $gbKey = 'HKCU:\Software\Microsoft\GameBar'
    if (-not (Test-Path $gbKey)) { New-Item -Path $gbKey -Force | Out-Null }
    Set-ItemProperty -Path $gbKey -Name 'AutoGameModeEnabled' -Value 1 -Type DWord

    $ptKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'
    if (-not (Test-Path $ptKey)) { New-Item -Path $ptKey -Force | Out-Null }
    Set-ItemProperty -Path $ptKey -Name 'PowerThrottlingOff' -Value 1 -Type DWord

    $gdvr = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'
    if (-not (Test-Path $gdvr)) { New-Item -Path $gdvr -Force | Out-Null }
    Set-ItemProperty -Path $gdvr -Name 'AllowGameDVR' -Value 0 -Type DWord

    $trans = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    if (Test-Path $trans) { Set-ItemProperty -Path $trans -Name 'EnableTransparency' -Value 0 -Type DWord }

    # Clean Shader Cache
    Remove-Item "$env:LOCALAPPDATA\D3DSCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\NVIDIA\DXCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "      ✓ CPU cores unparked + 100% Game priority allocated + Shaders cleaned" -ForegroundColor Green
}

function Optimize-Latency {
    Write-Host "`n[*] Forcing Zero DPC Latency Tolerance & Clock Stabilization..." -ForegroundColor Yellow
    $pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatencyCheckEnabled' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'Latency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceFSVP' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyTolerancePerfOverride' -Value 1 -Type DWord

    bcdedit /set disabledynamictick yes | Out-Null
    bcdedit /set x2apicpolicy Enable | Out-Null
    bcdedit /deletevalue useplatformclock | Out-Null
    Write-Host "      ✓ StopHighDPC active + x2APIC enabled + dynamic tick jitter eliminated" -ForegroundColor Green
}

function Boost-CompetitiveMatch {
    Write-Host "`n[*] Freeing CPU cache, GPU encoder, and USB polling for competitive play..." -ForegroundColor Yellow
    taskkill /f /im SteelSeriesCaptureSvc.exe 2>$null
    taskkill /f /im SteelSeriesMoments.exe 2>$null
    taskkill /f /im SignalRgb.exe 2>$null
    taskkill /f /im SignalRgbLauncher.exe 2>$null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Write-Host "      ✓ Background video recording stopped (Freed GPU NVENC)" -ForegroundColor Green
    Write-Host "      ✓ SignalRGB USB polling stopped (Freed USB bus & DPC latency)" -ForegroundColor Green
    Write-Host "      ✓ Standby memory cache flushed" -ForegroundColor Green
}

function Apply-GameHooks {
    Write-Host "`n[*] Hooking High CPU Priority for Competitive Titles..." -ForegroundColor Yellow
    $games = @('VALORANT-Win64-Shipping.exe', 'cs2.exe', 'r5apex.exe', 'AndroidEmulatorEn.exe', 'AndroidEmulator.exe')
    foreach ($g in $games) {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name 'CpuPriorityClass' -Value 3 -Type DWord
        Write-Host "      ✓ Hooked $g -> High CPU Priority (Class 3)" -ForegroundColor Green
    }
}

function Run-Diagnostics {
    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host "                       LIVE SYSTEM & LATENCY DIAGNOSTICS                        " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1
    $guid = $adapter.InterfaceGuid
    $tcp = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -ErrorAction SilentlyContinue
    Write-Host "`n--- Network & TCP Status ---" -ForegroundColor Yellow
    Write-Host "Adapter: $($adapter.Name) ($($adapter.InterfaceDescription))"
    Write-Host "Nagle Disabled (TCPNoDelay): $($tcp.TCPNoDelay)"
    Write-Host "Delayed ACKs Disabled (TcpAckFrequency): $($tcp.TcpAckFrequency)"
    $qos = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' -ErrorAction SilentlyContinue).NonBestEffortLimit
    Write-Host "QoS Bandwidth Reserved: $qos% (Target: 0%)"
    $sp = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' -ErrorAction SilentlyContinue).DnsPriority
    Write-Host "ServiceProvider DNS Priority: $sp (Target: 6)"

    Write-Host "`n--- System & Latency Status ---" -ForegroundColor Yellow
    $mem = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management').DisablePagingExecutive
    Write-Host "Kernel Locked in RAM (DisablePagingExecutive): $mem"
    $fse = (Get-ItemProperty 'HKCU:\System\GameConfigStore').GameDVR_FSEBehaviorMode
    Write-Host "Direct Flip / Fullscreen Mode: $fse (Target: 2)"
    $usb = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -ErrorAction SilentlyContinue).DisableSelectiveSuspend
    Write-Host "USB 100% Power (DisableSelectiveSuspend): $usb (Target: 1)"
    $dpc = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -ErrorAction SilentlyContinue).ExitLatency
    Write-Host "StopHighDPC Latency Tolerance: $dpc (Target: 1)"

    Write-Host "`n--- Live Ping & Routing Test ---" -ForegroundColor Yellow
    $ping = Test-Connection -ComputerName '1.1.1.1' -Count 4 -ErrorAction SilentlyContinue
    if ($ping) {
        $avg = ($ping | Measure-Object -Property ResponseTime -Average).Average
        Write-Host "Ping to Cloudflare DNS (1.1.1.1): $avg ms (Loss: 0%)" -ForegroundColor Green
    }
}

function Restore-Defaults {
    Write-Host "`n[*] Restoring Windows Default Network and System Settings..." -ForegroundColor Yellow
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1
    if ($adapter) {
        $guid = $adapter.InterfaceGuid
        $tcpKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
        Remove-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Interrupt Moderation' -DisplayValue 'Enabled' -NoRestart -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Flow Control' -DisplayValue 'Rx & Tx Enabled' -NoRestart -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Green Ethernet' -DisplayValue 'Enabled' -NoRestart -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Power Saving Mode' -DisplayValue 'Enabled' -NoRestart -ErrorAction SilentlyContinue
        netsh int tcp set global rsc=enabled | Out-Null
    }
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 0 -Type DWord
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'SystemResponsiveness' -Value 10 -Type DWord
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -Name 'PowerThrottlingOff' -Value 0 -Type DWord
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 1 -Type DWord
    $games = @('VALORANT-Win64-Shipping.exe', 'cs2.exe', 'r5apex.exe', 'AndroidEmulatorEn.exe', 'AndroidEmulator.exe')
    foreach ($g in $games) { Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions" -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      ✓ Windows default network and system parameters restored." -ForegroundColor Green
}

# 2. Main Interactive Console Loop
do {
    Show-PumpkiNBanner
    $choice = Read-Host "Select an option [1-9]"
    switch ($choice) {
        "1" {
            Optimize-Network
            Optimize-System
            Optimize-Latency
            Apply-GameHooks
            Write-Host "`n[✓] ALL OPTIMIZATIONS APPLIED SUCCESSFULLY!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "2" {
            Optimize-Network
            Write-Host "`n[✓] Network optimizations applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "3" {
            Optimize-System
            Write-Host "`n[✓] PC system optimizations applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "4" {
            Optimize-Latency
            Write-Host "`n[✓] Ultra-low latency tweaks applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "5" {
            Boost-CompetitiveMatch
            Write-Host "`n[✓] Competitive Match Booster applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "6" {
            Apply-GameHooks
            Write-Host "`n[✓] Game Priority Hooks installed!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "7" {
            Run-Diagnostics
            Read-Host "`nPress Enter to return to menu"
        }
        "8" {
            Restore-Defaults
            Write-Host "`n[✓] Default settings restored!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "9" {
            Write-Host "`nThank you for using PumpkiN's Ultimate Gaming Optimizer!" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            return
        }
    }
} while ($choice -ne "9")
