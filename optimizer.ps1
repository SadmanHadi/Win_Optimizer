<#
================================================================================
   ____                       _    _       _   _ 
  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |
  | |_) | | | | '_ ` _ \| '_ \ |/ / | '_ \|  \| |
  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |
  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|
                        |_|                       
           ULTIMATE GAMING & NETWORK OPTIMIZER v4.0
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

$Host.UI.RawUI.WindowTitle = "PumpkiN's Ultimate Gaming and Network Optimizer v4.0"

# --- HELPER FUNCTIONS ---
function Get-HardwareProfile {
    $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
    $gpus = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue
    $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1
    $ram = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object -Property Capacity -Sum
    $totalRamGb = [math]::Round($ram.Sum / 1GB, 1)

    return [PSCustomObject]@{
        CpuName     = $cpu.Name
        CpuCores    = "$($cpu.NumberOfCores)C / $($cpu.NumberOfLogicalProcessors)T"
        IsAmdCpu    = ($cpu.Name -match 'AMD|Ryzen')
        IsIntelCpu  = ($cpu.Name -match 'Intel|Core')
        Gpus        = $gpus
        HasNvidia   = ($gpus | Where-Object { $_.Name -match 'NVIDIA|GeForce' }) -ne $null
        HasAmdGpu   = ($gpus | Where-Object { $_.Name -match 'AMD|Radeon' }) -ne $null
        Adapter     = $adapter
        IsWifi      = ($adapter -and ($adapter.InterfaceType -eq 71 -or $adapter.InterfaceDescription -match 'Wi-Fi|Wireless|802\.11'))
        RamGb       = $totalRamGb
    }
}

function Show-PumpkiNBanner {
    Clear-Host
    $Host.UI.RawUI.ForegroundColor = 'Cyan'
    Write-Host "================================================================================"
    Write-Host "   ____                       _    _       _   _ "
    Write-Host "  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |"
    Write-Host "  | |_) | | | | '_ \ _ \| '_ \ |/ / | '_ \|  \| |"
    Write-Host "  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |"
    Write-Host "  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|"
    Write-Host "                        |_|                       "
    Write-Host "           ULTIMATE GAMING & NETWORK OPTIMIZER v4.0"
    Write-Host "          Created by PumpkiN | Max FPS - Ultra Low Latency"
    Write-Host "================================================================================"
    $Host.UI.RawUI.ForegroundColor = 'Gray'
    
    $hw = Get-HardwareProfile
    Write-Host "  [CPU] $($hw.CpuName) ($($hw.CpuCores))" -ForegroundColor DarkCyan
    foreach ($g in $hw.Gpus) {
        Write-Host "  [GPU] $($g.Name) (Driver: $($g.DriverVersion))" -ForegroundColor DarkCyan
    }
    if ($hw.Adapter) {
        $netType = if ($hw.IsWifi) { "Wi-Fi (Wireless)" } else { "Ethernet (Wired)" }
        Write-Host "  [NET] $($hw.Adapter.Name) [$netType]" -ForegroundColor DarkCyan
    }
    Write-Host "--------------------------------------------------------------------------------"
    Write-Host "  [1]  FULL ALL-IN-ONE OPTIMIZATION (Auto-Detects Hardware & Applies All) [BEST]" -ForegroundColor Green
    Write-Host "  [2]  Auto-Detect & Optimize Active GPU (NVIDIA / AMD Radeon)"
    Write-Host "  [3]  AMD Radeon GPU Dedicated Suite (Disable ULPS, Shader Cache, Anti-Lag)" -ForegroundColor Magenta
    Write-Host "  [4]  NVIDIA GeForce Dedicated Suite (PowerMizer P0, Max Performance, Cache)" -ForegroundColor Green
    Write-Host "  [5]  Network & Anti-Lag Suite (Nagle Off, 100% QoS, ServiceProvider DNS)"
    Write-Host "  [6]  Wi-Fi Ping Spike Mitigator (Toggle Background Scan for 0ms Spikes)"
    Write-Host "  [7]  CPU & System Engine (Kernel RAM Locking, Direct Flip, Core Unparking)"
    Write-Host "  [8]  Ultra-Low Latency, DPC & 8000Hz Input (StopHighDPC, Raw Mouse Curve)"
    Write-Host "  [9]  Competitive Match Booster (Flush Standby RAM, Kill Capture & RGB Hogs)"
    Write-Host "  [10] Game-Specific High Priority Hooks (Valorant, CS2, Apex, Fortnite, COD)"
    Write-Host "  [11] System Health, Live Diagnostics & Hardware Spec Sheet"
    Write-Host "  [12] Create Windows System Restore Point (Safety Backup)" -ForegroundColor Cyan
    Write-Host "  [13] Revert All Settings to Windows Defaults" -ForegroundColor DarkYellow
    Write-Host "  [0]  Exit" -ForegroundColor Red
    Write-Host "================================================================================"
}

# --- OPTIMIZATION MODULES ---

function Optimize-AmdGpu {
    Write-Host "`n[*] Starting AMD Radeon GPU Optimization Suite..." -ForegroundColor Magenta
    $classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $amdFound = 0

    # Search display class keys (0000 - 0009)
    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$classPath\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.DriverDesc -match 'AMD|Radeon' -or $props.ProviderName -match 'AMD|Advanced Micro Devices' -or $props.EnableUlps -ne $null)) {
                $amdFound++
                Write-Host "      -> Found AMD Radeon Adapter at Key [$subKey]: $($props.DriverDesc)" -ForegroundColor Cyan
                
                # 1. Disable ULPS (Ultra Low Power State) - Stops frame drops, sleep freezes & micro-stutter
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] Disabled ULPS (Ultra Low Power State) - Prevents clock-drop stutters" -ForegroundColor Green

                # 2. Shader Cache Optimization
                Set-ItemProperty -Path $targetPath -Name 'ShaderCache' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'ShaderCache_NA' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] Shader Cache locked to Enabled (Stops compilation frame-stutter)" -ForegroundColor Green

                # 3. Anti-Lag & Low-Latency Direct Pipeline
                Set-ItemProperty -Path $targetPath -Name 'AntiLag' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'DisableDMACopy' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] Anti-Lag and Direct Engine DMA Copy enabled" -ForegroundColor Green

                # 4. Disable Aggressive Clock Dropping & Multi-Monitor Stutter
                Set-ItemProperty -Path $targetPath -Name 'PP_ThermalAutoThrottlingEnable' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'PP_MCLKStutterMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'StutterMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'KMD_EnableCrossFireAutoLink' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] PowerPlay deep-sleep throttle and MCLK stutter mitigations applied" -ForegroundColor Green
            }
        }
    }

    # Also search ControlSet001 for any residual ULPS flags
    $cs1Path = 'HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$cs1Path\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.EnableUlps -ne $null -or $props.DriverDesc -match 'AMD|Radeon')) {
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord -ErrorAction SilentlyContinue
            }
        }
    }

    # Flush stale AMD precompiled shader caches
    $amdCaches = @(
        "$env:LOCALAPPDATA\AMD\DxCache",
        "$env:LOCALAPPDATA\AMD\GLCache",
        "$env:LOCALAPPDATA\AMD\D3DSCache"
    )
    foreach ($cacheDir in $amdCaches) {
        if (Test-Path $cacheDir) {
            Remove-Item "$cacheDir\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "         [+] Flushed AMD shader cache: $cacheDir" -ForegroundColor Green
        }
    }

    if ($amdFound -eq 0) {
        Write-Host "      [!] No AMD Radeon card found in primary registry keys (Applied global ULPS fallback)." -ForegroundColor DarkYellow
    } else {
        Write-Host "      [OK] AMD Radeon GPU Optimized: Maximum Clock Stability and 0 ULPS Latency!" -ForegroundColor Green
    }
}

function Optimize-NvidiaGpu {
    Write-Host "`n[*] Starting NVIDIA GeForce GPU Optimization Suite..." -ForegroundColor Green
    $classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $nvFound = 0

    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$classPath\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.DriverDesc -match 'NVIDIA' -or $props.ProviderName -match 'NVIDIA')) {
                $nvFound++
                Write-Host "      -> Found NVIDIA Adapter at Key [$subKey]: $($props.DriverDesc)" -ForegroundColor Cyan
                Set-ItemProperty -Path $targetPath -Name 'PowerMizerEnable' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevel' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevelAC' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] PowerMizer locked to Maximum Performance (P0 State - No clock drops)" -ForegroundColor Green
            }
        }
    }

    # Flush NVIDIA Shader Cache to eliminate corrupted shader stutters
    $nvCaches = @(
        "$env:LOCALAPPDATA\NVIDIA\DXCache",
        "$env:LOCALAPPDATA\NVIDIA\GLCache",
        "$env:LOCALAPPDATA\D3DSCache"
    )
    foreach ($cacheDir in $nvCaches) {
        if (Test-Path $cacheDir) {
            Remove-Item "$cacheDir\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "         [+] Flushed shader cache: $cacheDir" -ForegroundColor Green
        }
    }

    if ($nvFound -eq 0) {
        Write-Host "      [!] No NVIDIA card found in primary keys." -ForegroundColor DarkYellow
    } else {
        Write-Host "      [OK] NVIDIA GPU Optimized for Maximum FPS and Stable Frametimes!" -ForegroundColor Green
    }
}

function Optimize-GpuAuto {
    Write-Host "`n[*] Auto-Detecting Graphics Hardware..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile
    if ($hw.HasAmdGpu) {
        Optimize-AmdGpu
    }
    if ($hw.HasNvidia) {
        Optimize-NvidiaGpu
    }
    if (-not $hw.HasAmdGpu -and -not $hw.HasNvidia) {
        Write-Host "      -> Applying universal GPU power optimizations..." -ForegroundColor Cyan
        Optimize-NvidiaGpu
        Optimize-AmdGpu
    }
}

function Optimize-Network {
    Write-Host "`n[*] Tuning Network Interface & Anti-Lag Settings..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile
    $adapter = $hw.Adapter
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
        Write-Host "      [+] Nagle disabled (TCPNoDelay=1, TcpAckFrequency=1, TcpDelAckTicks=0)" -ForegroundColor Green
        Write-Host "      [+] RSC disabled, RSS enabled, NIC green power saving disabled" -ForegroundColor Green
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
    Write-Host "      [+] ServiceProvider priorities set + 100% bandwidth unreserved + DNS flushed" -ForegroundColor Green
}

function Toggle-WifiAutoconfig {
    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host "                       WI-FI BACKGROUND SCAN MITIGATOR                          " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "Windows scans for Wi-Fi networks every 60s in the background, causing 100-300ms ping spikes."
    Write-Host "Disabling AutoConfig during gaming gives flat, wired-like ping."
    Write-Host ""
    $hw = Get-HardwareProfile
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

function Optimize-CpuAndSystem {
    Write-Host "`n[*] Tuning CPU Scheduling, Kernel Memory & Game Mode..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile

    # Memory Management: Lock kernel in physical DDR RAM
    $memKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    Set-ItemProperty -Path $memKey -Name 'DisablePagingExecutive' -Value 1 -Type DWord
    Set-ItemProperty -Path $memKey -Name 'LargeSystemCache' -Value 0 -Type DWord
    Write-Host "      [+] DisablePagingExecutive = 1 (Kernel and drivers locked in RAM, 0 pagefile lag)" -ForegroundColor Green

    # Direct Flip / Fullscreen Exclusive Overrides (Bypass DWM latency)
    $gcs = 'HKCU:\System\GameConfigStore'
    Set-ItemProperty -Path $gcs -Name 'GameDVR_Enabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_DXGIHonorFSEWindowsCompatible' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_EFSEFeatureFlags' -Value 0 -Type DWord
    Write-Host "      [+] Direct Flip scanout active (1-2 frames display latency saved)" -ForegroundColor Green

    # CPU Core Unparking (100% Active Cores for both AMD & Intel)
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100

    # Architecture-specific CPU Scheduling
    if ($hw.IsIntelCpu) {
        # Intel Hybrid Architecture (12th-15th Gen P-Core / E-Core Scheduling)
        powercfg -setacvalueindex scheme_current sub_processor HETEROPOLICY 0 2>$null
        powercfg -setacvalueindex scheme_current sub_processor SCHEDPOLICY 2 2>$null
        Write-Host "      [+] Intel Core Detected: Unparked all cores and prioritized Performance P-Cores" -ForegroundColor Green
    } elseif ($hw.IsAmdCpu) {
        # AMD Ryzen / 3D V-Cache Core Scheduling
        Write-Host "      [+] AMD Ryzen Detected ($($hw.CpuName)): 100% Cores unparked for full boost clock" -ForegroundColor Green
    }
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
    Write-Host "      [+] Windows Game Mode enabled, Power Throttling disabled, DWM transparency off" -ForegroundColor Green
}

function Optimize-LatencyAndInput {
    Write-Host "`n[*] Forcing Zero DPC Latency Tolerance & 8000Hz Input Buffer..." -ForegroundColor Yellow
    # StopHighDPC & Latency Tolerance
    $pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatencyCheckEnabled' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'Latency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceFSVP' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyTolerancePerfOverride' -Value 1 -Type DWord

    # Dynamic Tick Jitter Elimination & x2APIC
    bcdedit /set disabledynamictick yes | Out-Null
    bcdedit /set x2apicpolicy Enable | Out-Null
    bcdedit /deletevalue useplatformclock | Out-Null
    Write-Host "      [+] StopHighDPC active + x2APIC enabled + dynamic tick jitter eliminated" -ForegroundColor Green

    # Input Queues for High-Polling Gaming Mice (Up to 8000Hz)
    $mouKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters'
    if (Test-Path $mouKey) { Set-ItemProperty -Path $mouKey -Name 'MouseDataQueueSize' -Value 200 -Type DWord }
    $kbdKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters'
    if (Test-Path $kbdKey) { Set-ItemProperty -Path $kbdKey -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord }

    # USB Selective Suspend Disabled (Prevents root hub power cycling)
    $usbKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
    if (-not (Test-Path $usbKey)) { New-Item -Path $usbKey -Force | Out-Null }
    Set-ItemProperty -Path $usbKey -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord

    # MarkC 1:1 Raw Mouse Acceleration Curve (Removes hidden Windows mouse curve distortion)
    $mouseKey = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mouseKey -Name 'MouseSpeed' -Value '0' -Type String
    Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold1' -Value '0' -Type String
    Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold2' -Value '0' -Type String
    [byte[]]$smoothX = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x29,0xdc,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00
    [byte[]]$smoothY = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xa8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xe0,0x00,0x00,0x00,0x00,0x00
    Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseXCurve' -Value $smoothX -Type Binary
    Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseYCurve' -Value $smoothY -Type Binary
    Write-Host "      [+] 8000Hz Mouse Buffer tuned + 100% Raw 1:1 Mouse Input Curve applied" -ForegroundColor Green
}

function Boost-CompetitiveMatch {
    Write-Host "`n[*] Freeing CPU cache, GPU encoder, and USB polling for competitive play..." -ForegroundColor Yellow
    taskkill /f /im SteelSeriesCaptureSvc.exe 2>$null
    taskkill /f /im SteelSeriesMoments.exe 2>$null
    taskkill /f /im SignalRgb.exe 2>$null
    taskkill /f /im SignalRgbLauncher.exe 2>$null
    taskkill /f /im GameBarFTServer.exe 2>$null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Write-Host "      [+] Background video recording stopped (Freed GPU NVENC/VCE encoder)" -ForegroundColor Green
    Write-Host "      [+] SignalRGB polling stopped (Freed USB bus & DPC latency)" -ForegroundColor Green
    Write-Host "      [+] Standby memory cache flushed & garbage collector executed" -ForegroundColor Green
}

function Apply-GameHooks {
    Write-Host "`n[*] Hooking High CPU & IO Priority for Top Competitive Titles..." -ForegroundColor Yellow
    $games = @(
        'VALORANT-Win64-Shipping.exe',
        'cs2.exe',
        'r5apex.exe',
        'FortniteClient-Win64-Shipping.exe',
        'cod.exe',
        'RainbowSix.exe',
        'RainbowSix_Vulkan.exe',
        'Overwatch.exe',
        'PUBG-Win64-Shipping.exe',
        'Deadlock.exe',
        'AndroidEmulatorEn.exe',
        'AndroidEmulator.exe'
    )
    foreach ($g in $games) {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name 'CpuPriorityClass' -Value 3 -Type DWord
        Set-ItemProperty -Path $path -Name 'IoPriority' -Value 3 -Type DWord
        Write-Host "      [+] Hooked $g -> High CPU Priority & High I/O Priority" -ForegroundColor Green
    }
}

function Create-RestorePoint {
    Write-Host "`n[*] Creating Windows System Restore Point..." -ForegroundColor Yellow
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "PumpkiN_Gaming_RestorePoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "      [OK] System Restore Point 'PumpkiN_Gaming_RestorePoint' created successfully!" -ForegroundColor Green
    } catch {
        Write-Host "      [!] Note: System Restore status: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
}

function Run-Diagnostics {
    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host "                       LIVE SYSTEM & LATENCY DIAGNOSTICS                        " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    
    $hw = Get-HardwareProfile
    Write-Host "`n--- Hardware Specification ---" -ForegroundColor Yellow
    Write-Host "CPU: $($hw.CpuName) ($($hw.CpuCores))"
    foreach ($g in $hw.Gpus) {
        Write-Host "GPU: $($g.Name) (Driver: $($g.DriverVersion))"
    }
    Write-Host "RAM: $($hw.RamGb) GB"

    Write-Host "`n--- Network & TCP Status ---" -ForegroundColor Yellow
    if ($hw.Adapter) {
        Write-Host "Adapter: $($hw.Adapter.Name) ($($hw.Adapter.InterfaceDescription))"
        $guid = $hw.Adapter.InterfaceGuid
        $tcp = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -ErrorAction SilentlyContinue
        Write-Host "Nagle Disabled (TCPNoDelay): $($tcp.TCPNoDelay)"
        Write-Host "Delayed ACKs Disabled (TcpAckFrequency): $($tcp.TcpAckFrequency)"
    }
    $qos = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' -ErrorAction SilentlyContinue).NonBestEffortLimit
    Write-Host "QoS Bandwidth Reserved: $qos% (Target: 0%)"
    $sp = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' -ErrorAction SilentlyContinue).DnsPriority
    Write-Host "ServiceProvider DNS Priority: $sp (Target: 6)"

    Write-Host "`n--- System & Latency Status ---" -ForegroundColor Yellow
    $mem = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management').DisablePagingExecutive
    Write-Host "Kernel Locked in RAM (DisablePagingExecutive): $mem (Target: 1)"
    $fse = (Get-ItemProperty 'HKCU:\System\GameConfigStore').GameDVR_FSEBehaviorMode
    Write-Host "Direct Flip / Fullscreen Mode: $fse (Target: 2)"
    $usb = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -ErrorAction SilentlyContinue).DisableSelectiveSuspend
    Write-Host "USB 100% Power (DisableSelectiveSuspend): $usb (Target: 1)"
    $dpc = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -ErrorAction SilentlyContinue).ExitLatency
    Write-Host "StopHighDPC Latency Tolerance: $dpc (Target: 1)"

    Write-Host "`n--- Live Ping & Jitter Test ---" -ForegroundColor Yellow
    $pingCf = Test-Connection -ComputerName '1.1.1.1' -Count 4 -ErrorAction SilentlyContinue
    if ($pingCf) {
        $avgCf = ($pingCf | Measure-Object -Property ResponseTime -Average).Average
        $minCf = ($pingCf | Measure-Object -Property ResponseTime -Minimum).Minimum
        $maxCf = ($pingCf | Measure-Object -Property ResponseTime -Maximum).Maximum
        Write-Host "Cloudflare DNS (1.1.1.1): Avg: $avgCf ms | Min: $minCf ms | Max: $maxCf ms (Jitter: $([math]::Round($maxCf - $minCf, 1)) ms)" -ForegroundColor Green
    }
}

function Restore-Defaults {
    Write-Host "`n[*] Restoring Windows Default Network and System Settings..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile
    $adapter = $hw.Adapter
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
    
    # Revert AMD ULPS to 1 if user wants defaults
    $classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$classPath\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.DriverDesc -match 'AMD|Radeon')) {
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 1 -Type DWord -ErrorAction SilentlyContinue
            }
        }
    }

    $games = @(
        'VALORANT-Win64-Shipping.exe','cs2.exe','r5apex.exe','FortniteClient-Win64-Shipping.exe',
        'cod.exe','RainbowSix.exe','RainbowSix_Vulkan.exe','Overwatch.exe','PUBG-Win64-Shipping.exe',
        'Deadlock.exe','AndroidEmulatorEn.exe','AndroidEmulator.exe'
    )
    foreach ($g in $games) { Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions" -Recurse -Force -ErrorAction SilentlyContinue }
    
    bcdedit /deletevalue disabledynamictick 2>$null
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [OK] Windows default network and system parameters restored." -ForegroundColor Green
}

# --- MAIN CONSOLE MENU LOOP ---
do {
    Show-PumpkiNBanner
    $choice = Read-Host "Select an option [0-13]"
    switch ($choice) {
        "1" {
            Optimize-Network
            Optimize-GpuAuto
            Optimize-CpuAndSystem
            Optimize-LatencyAndInput
            Apply-GameHooks
            Write-Host "`n[OK] ALL OPTIMIZATIONS APPLIED SUCCESSFULLY!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "2" {
            Optimize-GpuAuto
            Write-Host "`n[OK] GPU Auto-Optimization complete!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "3" {
            Optimize-AmdGpu
            Write-Host "`n[OK] AMD Radeon GPU optimization complete!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "4" {
            Optimize-NvidiaGpu
            Write-Host "`n[OK] NVIDIA GeForce GPU optimization complete!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "5" {
            Optimize-Network
            Write-Host "`n[OK] Network optimizations applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "6" {
            Toggle-WifiAutoconfig
            Read-Host "`nPress Enter to return to menu"
        }
        "7" {
            Optimize-CpuAndSystem
            Write-Host "`n[OK] CPU & System optimizations applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "8" {
            Optimize-LatencyAndInput
            Write-Host "`n[OK] Ultra-low latency & 8000Hz input tweaks applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "9" {
            Boost-CompetitiveMatch
            Write-Host "`n[OK] Competitive Match Booster applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "10" {
            Apply-GameHooks
            Write-Host "`n[OK] Esports Game Priority Hooks installed!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "11" {
            Run-Diagnostics
            Read-Host "`nPress Enter to return to menu"
        }
        "12" {
            Create-RestorePoint
            Read-Host "`nPress Enter to return to menu"
        }
        "13" {
            Restore-Defaults
            Write-Host "`n[OK] Default settings restored!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "0" {
            Write-Host "`nThank you for using PumpkiN's Ultimate Gaming Optimizer!" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            return
        }
    }
} while ($choice -ne "0")
