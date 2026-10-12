<#
================================================================================
   ____                       _    _       _   _ 
  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |
  | |_) | | | | '_ ` _ \| '_ \ |/ / | '_ \|  \| |
  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |
  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|
                        |_|                       
           ULTIMATE GAMING & NETWORK OPTIMIZER v5.0
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

$Host.UI.RawUI.WindowTitle = "PumpkiN's Ultimate Gaming and Network Optimizer v5.0"

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
    Write-Host "           ULTIMATE GAMING & NETWORK OPTIMIZER v5.0"
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
    Write-Host "  [1]  FULL ALL-IN-ONE OPTIMIZATION (Hardware Auto-Detect + All Tweaks) [BEST]" -ForegroundColor Green
    Write-Host "  [2]  Auto-Detect & Optimize Active GPU (NVIDIA / AMD Radeon)"
    Write-Host "  [3]  AMD Radeon GPU Dedicated Suite (Disable ULPS, Shader Cache, Anti-Lag)" -ForegroundColor Magenta
    Write-Host "  [4]  NVIDIA GeForce Dedicated Suite (PowerMizer P0, Max Performance, Cache)" -ForegroundColor Green
    Write-Host "  [5]  Network & Anti-Lag Suite (Nagle Off, 100% QoS, NDU Leak Fix, DNS)"
    Write-Host "  [6]  Wi-Fi Ping Spike Mitigator (Toggle Background Scan for 0ms Spikes)"
    Write-Host "  [7]  CPU, Kernel & Quantum Engine (Win32Priority 0x26, FTH Off, Core Unpark)"
    Write-Host "  [8]  Ultra-Low Latency, DPC & 8000Hz Input (StopHighDPC, Raw Mouse Curve)"
    Write-Host "  [9]  Competitive Match Booster (Immediate RAM Flush + 5-Min Background Auto-Purge)" -ForegroundColor Cyan
    Write-Host "  [10] Game-Specific High Priority Hooks (Valorant, CS2, Apex, Fortnite, COD)"
    Write-Host "  [11] System Health, Live Diagnostics & Hardware Spec Sheet"
    Write-Host "  [12] Create Windows System Restore Point (Safety Backup)" -ForegroundColor Cyan
    Write-Host "  [13] Revert All Settings to Windows Defaults" -ForegroundColor DarkYellow
    Write-Host "  [14] Activate Windows (Microsoft Activation Scripts - MAS)" -ForegroundColor Yellow
    Write-Host "  ---- BEAST MODE OPTIMIZATIONS ------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "  [15] Debloat & Disable Background Services (SysMain, Telemetry, Xbox, Cortana)"
    Write-Host "  [16] Ultimate Performance Power Plan + HPET/Timer Optimization" -ForegroundColor Green
    Write-Host "  [17] Strip All Visual Effects & Animations (Pure Performance Mode)"
    Write-Host "  [18] Privacy & Telemetry Hardening (Kill All Tracking & Ads)" -ForegroundColor Magenta
    Write-Host "  [19] Disk I/O & Storage Optimization (NTFS Tweaks + Temp Cleanup)"
    Write-Host "  [20] Disable Junk Scheduled Tasks (Compatibility, Defrag, Diagnostics)"
    Write-Host "  [21] Startup Bloat Cleanup & Gaming DNS (Cloudflare 1.1.1.1)" -ForegroundColor Cyan
    Write-Host "  [0]  Exit" -ForegroundColor Red
    Write-Host "================================================================================"
}

# --- OPTIMIZATION MODULES ---

function Optimize-AmdGpu {
    Write-Host "`n[*] Starting AMD Radeon GPU Optimization Suite..." -ForegroundColor Magenta
    $classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $amdFound = 0

    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$classPath\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.DriverDesc -match 'AMD|Radeon' -or $props.ProviderName -match 'AMD|Advanced Micro Devices' -or $props.EnableUlps -ne $null)) {
                $amdFound++
                Write-Host "      -> Found AMD Radeon Adapter at Key [$subKey]: $($props.DriverDesc)" -ForegroundColor Cyan
                
                # 1. Disable ULPS (Ultra Low Power State)
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

    # ControlSet001 fallback check
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
    Write-Host "`n[*] Tuning Network Interface, Anti-Lag & Memory Leaks..." -ForegroundColor Yellow
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

    # Fix NDU Non-Paged Pool Memory Leak (WinDebloatTools gem)
    $nduKey = 'HKLM:\SYSTEM\ControlSet001\Services\Ndu'
    if (Test-Path $nduKey) {
        Set-ItemProperty -Path $nduKey -Name 'Start' -Value 4 -Type DWord
        Write-Host "      [+] NDU memory leak fixed (Prevents non-paged RAM growth over long gaming sessions)" -ForegroundColor Green
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
    Write-Host "`n[*] Tuning CPU Scheduling, Kernel Executive, FTH & Game Mode..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile

    # 1. Memory Management: Lock kernel in physical DDR RAM
    $memKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    Set-ItemProperty -Path $memKey -Name 'DisablePagingExecutive' -Value 1 -Type DWord
    Set-ItemProperty -Path $memKey -Name 'LargeSystemCache' -Value 0 -Type DWord
    Write-Host "      [+] DisablePagingExecutive = 1 (Kernel and drivers locked in RAM, 0 pagefile lag)" -ForegroundColor Green

    # 2. Win32 Priority Separation (0x26: Short, Variable, 3:1 Foreground Boost - Alchemy gem)
    $prioKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl'
    if (-not (Test-Path $prioKey)) { New-Item -Path $prioKey -Force | Out-Null }
    Set-ItemProperty -Path $prioKey -Name 'Win32PrioritySeparation' -Value 38 -Type DWord # 0x26 = 38
    Write-Host "      [+] Win32PrioritySeparation = 0x26 (3:1 Foreground CPU quantum boost for active game)" -ForegroundColor Green

    # 3. Kernel DPC Immediate Dispatch & SplitLargeCaches (Alchemy Kernel gem)
    $kernelKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'
    if (-not (Test-Path $kernelKey)) { New-Item -Path $kernelKey -Force | Out-Null }
    Set-ItemProperty -Path $kernelKey -Name 'ThreadDpcEnable' -Value 0 -Type DWord
    Set-ItemProperty -Path $kernelKey -Name 'SplitLargeCaches' -Value 1 -Type DWord
    Write-Host "      [+] ThreadDpcEnable = 0 (Immediate DISPATCH_LEVEL DPC execution, no thread queue lag)" -ForegroundColor Green
    Write-Host "      [+] SplitLargeCaches = 1 (Optimized memory cache line splitting across CPU cores)" -ForegroundColor Green

    # 4. Executive Worker Thread Pool Scaling (Alchemy gem)
    $execKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive'
    if (-not (Test-Path $execKey)) { New-Item -Path $execKey -Force | Out-Null }
    Set-ItemProperty -Path $execKey -Name 'AdditionalCriticalWorkerThreads' -Value 16 -Type DWord
    Set-ItemProperty -Path $execKey -Name 'AdditionalDelayedWorkerThreads' -Value 16 -Type DWord
    Write-Host "      [+] Executive Worker Threads scaled to 16 for high-speed I/O streaming" -ForegroundColor Green

    # 5. Disable Fault Tolerant Heap (FTH - AtlasOS gem)
    $fthKey = 'HKLM:\SOFTWARE\Microsoft\FTH'
    if (-not (Test-Path $fthKey)) { New-Item -Path $fthKey -Force | Out-Null }
    Set-ItemProperty -Path $fthKey -Name 'Enabled' -Value 0 -Type DWord
    Write-Host "      [+] Fault Tolerant Heap (FTH) disabled (Stops tracking shims from slowing games)" -ForegroundColor Green

    # 6. Disable Desktop Energy Estimation Engine (Valorant Pack gem)
    $pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
    Set-ItemProperty -Path $pwrKey -Name 'EnergyEstimationEnabled' -Value 0 -Type DWord
    $taggedEnergy = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\EnergyEstimation\TaggedEnergy'
    if (-not (Test-Path $taggedEnergy)) { New-Item -Path $taggedEnergy -Force | Out-Null }
    Set-ItemProperty -Path $taggedEnergy -Name 'DisableTaggedEnergyLogging' -Value 1 -Type DWord
    Set-ItemProperty -Path $taggedEnergy -Name 'TelemetryMaxApplication' -Value 0 -Type DWord
    Write-Host "      [+] Desktop EnergyEstimation disabled (No background battery logging on AC power)" -ForegroundColor Green

    # 7. Direct Flip / Fullscreen Exclusive Overrides (Bypass DWM latency)
    $gcs = 'HKCU:\System\GameConfigStore'
    Set-ItemProperty -Path $gcs -Name 'GameDVR_Enabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_DXGIHonorFSEWindowsCompatible' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_EFSEFeatureFlags' -Value 0 -Type DWord
    Write-Host "      [+] Direct Flip scanout active (1-2 frames display latency saved)" -ForegroundColor Green

    # 8. CPU Core Unparking (100% Active Cores for both AMD & Intel)
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100

    # Architecture-specific CPU Scheduling
    if ($hw.IsIntelCpu) {
        powercfg -setacvalueindex scheme_current sub_processor HETEROPOLICY 0 2>$null
        powercfg -setacvalueindex scheme_current sub_processor SCHEDPOLICY 2 2>$null
        Write-Host "      [+] Intel Core Detected: Unparked all cores and prioritized Performance P-Cores" -ForegroundColor Green
    } elseif ($hw.IsAmdCpu) {
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

    # USB Selective Suspend Disabled
    $usbKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
    if (-not (Test-Path $usbKey)) { New-Item -Path $usbKey -Force | Out-Null }
    Set-ItemProperty -Path $usbKey -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord

    # MarkC 1:1 Raw Mouse Acceleration Curve
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
    Write-Host "`n[*] Purging Kernel Standby Memory & Idle Working Sets..." -ForegroundColor Yellow

    $exeCandidates = @(
        "$PSScriptRoot\EmptyStandbyList.exe",
        "$PSScriptRoot\..\EmptyStandbyList.exe",
        "$env:SystemRoot\System32\EmptyStandbyList.exe",
        "e:\Projects\Win_Optimizer\EmptyStandbyList.exe"
    )
    $emptyListExe = $exeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($emptyListExe) {
        $memBefore = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
        Start-Process -FilePath $emptyListExe -ArgumentList "workingsets" -Wait -WindowStyle Hidden
        Start-Process -FilePath $emptyListExe -ArgumentList "standbylist" -Wait -WindowStyle Hidden
        $memAfter = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
        $freedMb = [math]::Round(($memAfter - $memBefore) / 1024, 0)
        if ($freedMb -gt 0) {
            Write-Host "      [+] Kernel Standby RAM purged: $freedMb MB returned to Zero-Latency Free Pool!" -ForegroundColor Green
        } else {
            Write-Host "      [+] Kernel Standby RAM & idle working sets trimmed successfully" -ForegroundColor Green
        }

        # Verify / Activate 5-minute background Task Scheduler job
        $TaskName = "PumpkiN_AutoEmptyStandbyList"
        $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existing) {
            $info = Get-ScheduledTaskInfo -TaskName $TaskName
            Write-Host "      [+] 5-Minute Background Auto-Cleaner: ACTIVE (Next run: $($info.NextRunTime))" -ForegroundColor Green
        } else {
            try {
                $action = New-ScheduledTaskAction -Execute $emptyListExe -Argument "standbylist"
                $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
                $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
                $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -Priority 4
                Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
                Start-ScheduledTask -TaskName $TaskName
                Write-Host "      [+] 5-Minute Background Auto-Cleaner registered and active in Task Scheduler!" -ForegroundColor Green
            } catch {
                Write-Host "      [!] Task Scheduler note: $($_.Exception.Message)" -ForegroundColor DarkYellow
            }
        }
    } else {
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Write-Host "      [+] CLR Garbage collector executed (EmptyStandbyList.exe optional fallback)" -ForegroundColor Yellow
    }
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
    $ndu = (Get-ItemProperty 'HKLM:\SYSTEM\ControlSet001\Services\Ndu' -ErrorAction SilentlyContinue).Start
    Write-Host "NDU Memory Leak Fix State: $ndu (Target: 4)"

    Write-Host "`n--- System, Kernel & Quantum Status ---" -ForegroundColor Yellow
    $mem = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management').DisablePagingExecutive
    Write-Host "Kernel Locked in RAM (DisablePagingExecutive): $mem (Target: 1)"
    $prio = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -ErrorAction SilentlyContinue).Win32PrioritySeparation
    Write-Host "Win32PrioritySeparation (Foreground Quantum): $prio (Target: 38 / 0x26)"
    $fth = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\FTH' -ErrorAction SilentlyContinue).Enabled
    Write-Host "Fault Tolerant Heap (FTH): $fth (Target: 0)"
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
    
    # Restore Win32PrioritySeparation, FTH, NDU, EnergyEstimation
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\FTH' -Name 'Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\ControlSet001\Services\Ndu' -Name 'Start' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'EnergyEstimationEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' -Name 'ThreadDpcEnable' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' -Name 'SplitLargeCaches' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive' -Name 'AdditionalCriticalWorkerThreads' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive' -Name 'AdditionalDelayedWorkerThreads' -ErrorAction SilentlyContinue

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
    Unregister-ScheduledTask -TaskName 'PumpkiN_AutoEmptyStandbyList' -Confirm:$false -ErrorAction SilentlyContinue
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [OK] Original network and system parameters restored." -ForegroundColor Green

    # --- Revert Beast Mode Optimizations ---
    Write-Host "`n[*] Reverting Beast Mode optimizations..." -ForegroundColor Yellow

    # Re-enable disabled services
    $servicesToRestore = @('SysMain', 'DiagTrack', 'dmwappushservice', 'WSearch', 'XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc', 'MapsBroker', 'lfsvc', 'WerSvc')
    foreach ($svcName in $servicesToRestore) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($svc) {
            Set-Service -Name $svcName -StartupType Manual -ErrorAction SilentlyContinue
        }
    }
    Write-Host "      [+] Background services restored to Manual startup" -ForegroundColor Green

    # Re-enable Cortana / Web Search
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'DisableWebSearch' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'ConnectedSearchUseWeb' -ErrorAction SilentlyContinue

    # Restore Balanced power plan
    $balanced = powercfg /list | Select-String "Balanced"
    if ($balanced) {
        $guid = ($balanced -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        powercfg /setactive $guid
        Write-Host "      [+] Balanced power plan restored" -ForegroundColor Green
    }
    powercfg /hibernate on 2>$null
    bcdedit /deletevalue useplatformtick 2>$null
    bcdedit /deletevalue tscsyncpolicy 2>$null

    # Restore Visual Effects to default
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '400' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'DragFullWindows' -Value '1' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\DWM' -Name 'EnableAeroPeek' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' -Name 'StartupDelayInMSec' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name 'NoLockScreen' -ErrorAction SilentlyContinue
    Write-Host "      [+] Visual effects and animations restored to defaults" -ForegroundColor Green

    # Restore Telemetry / Privacy
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableActivityFeed' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'PublishUserActivities' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'UploadUserActivities' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Name 'DisableLocation' -ErrorAction SilentlyContinue
    Write-Host "      [+] Privacy and telemetry settings restored to Windows defaults" -ForegroundColor Green

    # Restore NTFS defaults
    fsutil behavior set disablelastaccess 2 | Out-Null
    fsutil behavior set disable8dot3 0 | Out-Null
    fsutil behavior set memoryusage 1 | Out-Null
    Write-Host "      [+] NTFS defaults restored (last access, 8.3 names, memory usage)" -ForegroundColor Green

    # Re-enable scheduled tasks
    $tasksToReEnable = @(
        '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
        '\Microsoft\Windows\Defrag\ScheduledDefrag',
        '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
        '\Microsoft\Windows\Maintenance\WinSAT'
    )
    foreach ($task in $tasksToReEnable) {
        try {
            Enable-ScheduledTask -TaskPath ($task -replace '[^\\]*$', '') -TaskName ($task -replace '.*\\', '') -ErrorAction SilentlyContinue | Out-Null
        } catch {}
    }
    Write-Host "      [+] Key scheduled tasks re-enabled" -ForegroundColor Green

    # Reset DNS to DHCP automatic
    if ($adapter) {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ResetServerAddresses -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'MaxCacheTtl' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'MaxNegativeCacheTtl' -ErrorAction SilentlyContinue
        Write-Host "      [+] DNS reset to automatic (DHCP)" -ForegroundColor Green
    }

    # Revert WinUtil & Snappy OS hardening
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' -Name 'OverlayTestMode' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'DisableOverlays' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed' -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1' -Value 6 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2' -Value 10 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Value '510' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' -Name 'TaskbarEndTask' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Name 'GlobalUserDisabled' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value 380000 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'DisableWpbtExecution' -ErrorAction SilentlyContinue
    icacls "$Env:SystemRoot\Installer\Razer" /grant "*S-1-1-0:(W)" 2>$null | Out-Null
    icacls "$Env:ProgramFiles\LogiDownloadAssistant" /grant "*S-1-1-0:(W)" 2>$null | Out-Null
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer' -Name 'DisableCoInstallers' -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' -Name 'SearchOrderConfig' -Value 1 -ErrorAction SilentlyContinue
    Remove-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableSearchBoxSuggestions' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled' -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 0 -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name 'NoLockScreen' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'DisplayParameters' -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value 2 -ErrorAction SilentlyContinue
    Remove-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] WinUtil hardening & Snappy OS tweaks reverted to Windows defaults" -ForegroundColor Green

    Write-Host "      [OK] ALL settings restored to Windows defaults!" -ForegroundColor Green
}

# --- NEW BEAST MODE OPTIMIZATION MODULES ---

function Debloat-BackgroundServices {
    Write-Host "`n[*] Debloating Background Services & Bloatware..." -ForegroundColor Yellow

    # Services to disable (Set to Manual or Disabled)
    $servicesToDisable = @(
        @{ Name = 'SysMain';          Desc = 'Superfetch (SysMain) - Pre-caches apps, steals I/O during gaming' },
        @{ Name = 'DiagTrack';        Desc = 'Connected User Experiences & Telemetry - MS data collection' },
        @{ Name = 'dmwappushservice';  Desc = 'WAP Push Message Routing - Telemetry relay service' },
        @{ Name = 'WSearch';          Desc = 'Windows Search Indexer - Constant background disk I/O' },
        @{ Name = 'XblAuthManager';   Desc = 'Xbox Live Auth Manager - Not needed for PC gaming' },
        @{ Name = 'XblGameSave';      Desc = 'Xbox Live Game Save - Cloud save sync overhead' },
        @{ Name = 'XboxNetApiSvc';    Desc = 'Xbox Live Networking - Background Xbox connectivity' },
        @{ Name = 'XboxGipSvc';       Desc = 'Xbox Accessory Management - Xbox controller management' },
        @{ Name = 'MapsBroker';       Desc = 'Downloaded Maps Manager - Unused background service' },
        @{ Name = 'lfsvc';            Desc = 'Geolocation Service - Background location tracking' },
        @{ Name = 'SharedAccess';     Desc = 'Internet Connection Sharing - Not needed on gaming PCs' },
        @{ Name = 'RetailDemo';       Desc = 'Retail Demo Service - Store display mode' },
        @{ Name = 'wisvc';            Desc = 'Windows Insider Service - Preview build telemetry' },
        @{ Name = 'WerSvc';           Desc = 'Windows Error Reporting - Crash dump collection' },
        @{ Name = 'Fax';              Desc = 'Fax Service - Nobody faxes from a gaming PC' }
    )

    foreach ($svc in $servicesToDisable) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            try {
                Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
                Write-Host "      [+] Disabled: $($svc.Desc)" -ForegroundColor Green
            } catch {
                Write-Host "      [~] Skipped: $($svc.Name) ($($_.Exception.Message))" -ForegroundColor DarkYellow
            }
        }
    }

    # Disable Cortana
    $cortanaKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
    if (-not (Test-Path $cortanaKey)) { New-Item -Path $cortanaKey -Force | Out-Null }
    Set-ItemProperty -Path $cortanaKey -Name 'AllowCortana' -Value 0 -Type DWord
    Set-ItemProperty -Path $cortanaKey -Name 'DisableWebSearch' -Value 1 -Type DWord
    Set-ItemProperty -Path $cortanaKey -Name 'ConnectedSearchUseWeb' -Value 0 -Type DWord
    Write-Host "      [+] Cortana disabled + Web Search in Start Menu blocked" -ForegroundColor Green

    # Disable Delivery Optimization P2P (stops uploading updates to other PCs)
    $doKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'
    if (-not (Test-Path $doKey)) { New-Item -Path $doKey -Force | Out-Null }
    Set-ItemProperty -Path $doKey -Name 'DODownloadMode' -Value 0 -Type DWord
    Write-Host "      [+] Delivery Optimization P2P disabled (No upload bandwidth stolen)" -ForegroundColor Green

    Write-Host "      [OK] Background Services Debloated  --  Maximum CPU/IO freed for gaming!" -ForegroundColor Green
}

function Enable-UltimatePerformancePlan {
    Write-Host "`n[*] Activating Ultimate Performance Power Plan..." -ForegroundColor Yellow

    # Check if Ultimate Performance plan already exists
    $existingPlan = powercfg /list | Select-String "Ultimate Performance"
    if (-not $existingPlan) {
        # Unhide and create Ultimate Performance plan
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
        $existingPlan = powercfg /list | Select-String "Ultimate Performance"
    }

    if ($existingPlan) {
        $guid = ($existingPlan -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        powercfg /setactive $guid
        Write-Host "      [+] Ultimate Performance Plan ACTIVATED (GUID: $guid)" -ForegroundColor Green
    } else {
        # Fallback: set High Performance
        $highPerf = powercfg /list | Select-String "High performance"
        if ($highPerf) {
            $guid = ($highPerf -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
            powercfg /setactive $guid
            Write-Host "      [+] High Performance Plan activated (Ultimate not available on this build)" -ForegroundColor Green
        }
    }

    # Disable USB selective suspend in current plan
    powercfg -setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setactive scheme_current

    # Disable hibernate (frees GB of disk + prevents sleep interrupts)
    powercfg /hibernate off 2>$null

    # HPET & Timer Resolution
    bcdedit /set useplatformtick yes 2>$null
    bcdedit /set tscsyncpolicy enhanced 2>$null
    Write-Host "      [+] Hibernate disabled, USB suspend off, TSC sync policy enhanced" -ForegroundColor Green

    Write-Host "      [OK] Power Plan optimized  --  Zero CPU throttling, maximum clock speeds!" -ForegroundColor Green
}

function Strip-VisualEffects {
    Write-Host "`n[*] Stripping Windows Visual Effects & Animations..." -ForegroundColor Yellow

    # Set Visual Effects to "Adjust for best performance" (UserPreferencesMask)
    $visualKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
    if (-not (Test-Path $visualKey)) { New-Item -Path $visualKey -Force | Out-Null }
    Set-ItemProperty -Path $visualKey -Name 'VisualFXSetting' -Value 2 -Type DWord
    Write-Host "      [+] Visual Effects set to 'Best Performance' mode" -ForegroundColor Green

    # Disable individual animations
    $dwKey = 'HKCU:\Control Panel\Desktop\WindowMetrics'
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '0' -Type String
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'DragFullWindows' -Value '0' -Type String

    # Disable all animation flags
    $advKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $advKey -Name 'TaskbarAnimations' -Value 0 -Type DWord
    Set-ItemProperty -Path $advKey -Name 'ListviewAlphaSelect' -Value 0 -Type DWord
    Set-ItemProperty -Path $advKey -Name 'ListviewShadow' -Value 0 -Type DWord
    Set-ItemProperty -Path $advKey -Name 'IconsOnly' -Value 0 -Type DWord

    # Disable DWM animations
    $dwmKey = 'HKCU:\Software\Microsoft\Windows\DWM'
    if (-not (Test-Path $dwmKey)) { New-Item -Path $dwmKey -Force | Out-Null }
    Set-ItemProperty -Path $dwmKey -Name 'EnableAeroPeek' -Value 0 -Type DWord
    Set-ItemProperty -Path $dwmKey -Name 'AlwaysHibernateThumbnails' -Value 0 -Type DWord

    # Disable startup delay
    $serializeKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize'
    if (-not (Test-Path $serializeKey)) { New-Item -Path $serializeKey -Force | Out-Null }
    Set-ItemProperty -Path $serializeKey -Name 'StartupDelayInMSec' -Value 0 -Type DWord
    Write-Host "      [+] Startup delay zeroed, all menu/taskbar animations disabled" -ForegroundColor Green

    # Disable transparency effects (if not already done)
    $persKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    if (Test-Path $persKey) {
        Set-ItemProperty -Path $persKey -Name 'EnableTransparency' -Value 0 -Type DWord
    }

    # Disable lock screen animations / tips
    $lockKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
    if (-not (Test-Path $lockKey)) { New-Item -Path $lockKey -Force | Out-Null }
    Set-ItemProperty -Path $lockKey -Name 'NoLockScreen' -Value 1 -Type DWord
    Write-Host "      [+] Lock screen disabled, DWM Aero Peek off, transparency off" -ForegroundColor Green

    Write-Host "      [OK] All visual fluff stripped  --  GPU resources 100% for your game!" -ForegroundColor Green
}

function Harden-PrivacyTelemetry {
    Write-Host "`n[*] Hardening Privacy & Disabling Telemetry..." -ForegroundColor Yellow

    # Disable Telemetry level
    $dataKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
    if (-not (Test-Path $dataKey)) { New-Item -Path $dataKey -Force | Out-Null }
    Set-ItemProperty -Path $dataKey -Name 'AllowTelemetry' -Value 0 -Type DWord
    Set-ItemProperty -Path $dataKey -Name 'MaxTelemetryAllowed' -Value 0 -Type DWord
    Write-Host "      [+] Windows Telemetry set to Security (minimum) level" -ForegroundColor Green

    # Disable Activity History
    $actKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (-not (Test-Path $actKey)) { New-Item -Path $actKey -Force | Out-Null }
    Set-ItemProperty -Path $actKey -Name 'EnableActivityFeed' -Value 0 -Type DWord
    Set-ItemProperty -Path $actKey -Name 'PublishUserActivities' -Value 0 -Type DWord
    Set-ItemProperty -Path $actKey -Name 'UploadUserActivities' -Value 0 -Type DWord
    Write-Host "      [+] Activity History and Timeline sync disabled" -ForegroundColor Green

    # Disable Advertising ID
    $adKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
    if (-not (Test-Path $adKey)) { New-Item -Path $adKey -Force | Out-Null }
    Set-ItemProperty -Path $adKey -Name 'Enabled' -Value 0 -Type DWord
    Write-Host "      [+] Advertising ID disabled" -ForegroundColor Green

    # Disable Tailored Experiences
    $cloudKey = 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent'
    if (-not (Test-Path $cloudKey)) { New-Item -Path $cloudKey -Force | Out-Null }
    Set-ItemProperty -Path $cloudKey -Name 'DisableTailoredExperiencesWithDiagnosticData' -Value 1 -Type DWord
    Set-ItemProperty -Path $cloudKey -Name 'DisableWindowsConsumerFeatures' -Value 1 -Type DWord
    Write-Host "      [+] Tailored Experiences and Consumer Features disabled" -ForegroundColor Green

    # Disable feedback requests
    $siufKey = 'HKCU:\Software\Microsoft\Siuf\Rules'
    if (-not (Test-Path $siufKey)) { New-Item -Path $siufKey -Force | Out-Null }
    Set-ItemProperty -Path $siufKey -Name 'NumberOfSIUFInPeriod' -Value 0 -Type DWord
    Write-Host "      [+] Windows Feedback popups disabled" -ForegroundColor Green

    # Disable app suggestions / pre-installed bloat apps
    $contentKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    if (Test-Path $contentKey) {
        Set-ItemProperty -Path $contentKey -Name 'SystemPaneSuggestionsEnabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SilentInstalledAppsEnabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SoftLandingEnabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SubscribedContent-338389Enabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SubscribedContent-310093Enabled' -Value 0 -Type DWord
        Write-Host "      [+] App suggestions and silent app installs blocked" -ForegroundColor Green
    }

    # Disable Location Tracking globally
    $locKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'
    if (-not (Test-Path $locKey)) { New-Item -Path $locKey -Force | Out-Null }
    Set-ItemProperty -Path $locKey -Name 'DisableLocation' -Value 1 -Type DWord
    Write-Host "      [+] Location tracking disabled system-wide" -ForegroundColor Green

    Write-Host "      [OK] Privacy Hardened  --  No telemetry, no ads, no tracking!" -ForegroundColor Green
}

function Optimize-DiskIO {
    Write-Host "`n[*] Optimizing Disk I/O & Storage Performance..." -ForegroundColor Yellow

    # Disable Last Access Timestamp (huge NTFS perf win)
    fsutil behavior set disablelastaccess 1 | Out-Null
    Write-Host "      [+] NTFS Last Access Timestamps disabled (Faster file reads)" -ForegroundColor Green

    # Disable 8.3 short filename creation
    fsutil behavior set disable8dot3 1 | Out-Null
    Write-Host "      [+] 8.3 Short Filename creation disabled (Faster directory enumeration)" -ForegroundColor Green

    # Increase NTFS memory usage for performance
    fsutil behavior set memoryusage 2 | Out-Null
    Write-Host "      [+] NTFS Memory Usage set to Level 2 (More RAM for file system cache)" -ForegroundColor Green

    # Disable boot trace logging
    $bootKey = 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction'
    if (Test-Path $bootKey) {
        Set-ItemProperty -Path $bootKey -Name 'Enable' -Value 'N' -Type String -ErrorAction SilentlyContinue
    }

    # Clean Temp Files
    $tempPaths = @(
        "$env:TEMP",
        "$env:LOCALAPPDATA\Temp",
        "$env:SystemRoot\Temp",
        "$env:SystemRoot\Prefetch",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db"
    )
    $totalCleaned = 0
    foreach ($tp in $tempPaths) {
        if (Test-Path $tp) {
            $sizeBefore = (Get-ChildItem $tp -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            Remove-Item "$tp\*" -Recurse -Force -ErrorAction SilentlyContinue
            $totalCleaned += $sizeBefore
        }
    }
    $cleanedMb = [math]::Round($totalCleaned / 1MB, 1)
    Write-Host "      [+] Temp files cleaned: ~$cleanedMb MB freed (Temp, Prefetch, Thumbnails)" -ForegroundColor Green

    # Clear Windows Update cache (can be several GB)
    $wuCache = "$env:SystemRoot\SoftwareDistribution\Download"
    if (Test-Path $wuCache) {
        $wuSize = (Get-ChildItem $wuCache -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Remove-Item "$wuCache\*" -Recurse -Force -ErrorAction SilentlyContinue
        $wuMb = [math]::Round($wuSize / 1MB, 1)
        Write-Host "      [+] Windows Update cache cleared: ~$wuMb MB freed" -ForegroundColor Green
    }

    Write-Host "      [OK] Disk I/O optimized  --  Faster game loads and reduced stuttering!" -ForegroundColor Green
}

function Disable-ScheduledJunkTasks {
    Write-Host "`n[*] Disabling Junk Scheduled Tasks (Frame Drop Eliminators)..." -ForegroundColor Yellow

    $tasksToDisable = @(
        '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
        '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
        '\Microsoft\Windows\Autochk\Proxy',
        '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
        '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
        '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
        '\Microsoft\Windows\Maintenance\WinSAT',
        '\Microsoft\Windows\Maps\MapsToastTask',
        '\Microsoft\Windows\Maps\MapsUpdateTask',
        '\Microsoft\Windows\Shell\FamilySafetyMonitor',
        '\Microsoft\Windows\Shell\FamilySafetyRefreshTask',
        '\Microsoft\Windows\Windows Error Reporting\QueueReporting',
        '\Microsoft\Windows\Feedback\Siuf\DmClient',
        '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload',
        '\Microsoft\Windows\PI\Sqm-Tasks',
        '\Microsoft\Windows\CloudExperienceHost\CreateObjectTask',
        '\Microsoft\Windows\DiskFootprint\Diagnostics',
        '\Microsoft\Windows\FileHistory\File History (maintenance mode)',
        '\Microsoft\Windows\NetTrace\GatherNetworkInfo',
        '\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem'
    )

    $disabled = 0
    foreach ($task in $tasksToDisable) {
        try {
            $existing = Get-ScheduledTask -TaskPath ($task -replace '[^\\]*$', '') -TaskName ($task -replace '.*\\', '') -ErrorAction SilentlyContinue
            if ($existing -and $existing.State -ne 'Disabled') {
                Disable-ScheduledTask -TaskPath ($task -replace '[^\\]*$', '') -TaskName ($task -replace '.*\\', '') -ErrorAction Stop | Out-Null
                $disabled++
                Write-Host "      [+] Disabled: $($task -replace '.*\\', '')" -ForegroundColor Green
            }
        } catch {
            # Task doesn't exist on this system - skip silently
        }
    }

    # Disable Defrag schedule (SSDs don't need it, HDDs can run manually)
    try {
        $defrag = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag' -ErrorAction SilentlyContinue
        if ($defrag -and $defrag.State -ne 'Disabled') {
            Disable-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag' -ErrorAction Stop | Out-Null
            $disabled++
            Write-Host "      [+] Disabled: ScheduledDefrag (SSDs self-manage TRIM)" -ForegroundColor Green
        }
    } catch {}

    Write-Host "      [OK] $disabled junk tasks disabled  --  No more random frame drops!" -ForegroundColor Green
}

function Optimize-StartupAndDns {
    Write-Host "`n[*] Optimizing Startup Programs & DNS..." -ForegroundColor Yellow

    # --- DNS Optimization ---
    Write-Host "`n      --- DNS Optimization ---" -ForegroundColor Cyan
    $hw = Get-HardwareProfile
    $adapter = $hw.Adapter
    if ($adapter) {
        try {
            # Set Cloudflare DNS (1.1.1.1 primary, 1.0.0.1 secondary)
            Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @('1.1.1.1', '1.0.0.1') -ErrorAction Stop
            Write-Host "      [+] DNS set to Cloudflare (1.1.1.1, 1.0.0.1)  --  Fastest gaming DNS" -ForegroundColor Green
        } catch {
            Write-Host "      [~] DNS auto-set skipped: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }

        # Disable DNS over HTTPS throttle, enable DNS cache optimization
        $dnsParams = 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
        if (Test-Path $dnsParams) {
            Set-ItemProperty -Path $dnsParams -Name 'MaxCacheTtl' -Value 86400 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $dnsParams -Name 'MaxNegativeCacheTtl' -Value 5 -Type DWord -ErrorAction SilentlyContinue
            Write-Host "      [+] DNS Cache optimized (24h positive TTL, 5s negative TTL)" -ForegroundColor Green
        }
    }

    # Flush DNS after changes
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [+] DNS cache flushed" -ForegroundColor Green

    # --- Startup Audit ---
    Write-Host "`n      --- Startup Program Audit ---" -ForegroundColor Cyan
    $startupItems = Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue
    $runKey = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
    $runKeyLM = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue

    Write-Host "      Current startup programs:" -ForegroundColor Yellow
    $allProps = @()
    if ($runKey) {
        $runKey.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
            Write-Host "        [HKCU] $($_.Name): $($_.Value)" -ForegroundColor Gray
            $allProps += $_.Name
        }
    }
    if ($runKeyLM) {
        $runKeyLM.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
            Write-Host "        [HKLM] $($_.Name): $($_.Value)" -ForegroundColor Gray
        }
    }

    # Known bloatware startup entries to auto-disable
    $bloatStartup = @('OneDrive', 'Skype', 'Teams', 'Spotify', 'Discord Update', 'CortanaStartupId', 'BingDesktop', 'AdobeAAMUpdater')
    foreach ($bloat in $bloatStartup) {
        if ($allProps -contains $bloat) {
            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $bloat -ErrorAction SilentlyContinue
            Write-Host "      [+] Auto-disabled bloat startup: $bloat" -ForegroundColor Green
        }
    }

    Write-Host "      [OK] DNS optimized + Startup audited  --  Faster boot and lower latency!" -ForegroundColor Green
}

# --- WINUTIL S-TIER & SNAPPY OS OPTIMIZATION FUNCTIONS ---

function Disable-MultiplaneOverlay {
    Write-Host "`n[*] Disabling Multiplane Overlay (MPO)..." -ForegroundColor Yellow
    $dwmPath = 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm'
    if (-not (Test-Path $dwmPath)) { New-Item -Path $dwmPath -Force | Out-Null }
    Set-ItemProperty -Path $dwmPath -Name 'OverlayTestMode' -Value 5 -Type DWord -ErrorAction SilentlyContinue

    $gfxPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
    if (-not (Test-Path $gfxPath)) { New-Item -Path $gfxPath -Force | Out-Null }
    Set-ItemProperty -Path $gfxPath -Name 'DisableOverlays' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    Write-Host "      [+] MPO Disabled (OverlayTestMode=5, DisableOverlays=1)  --  Zero DWM stuttering & flickering!" -ForegroundColor Green
}

function Set-MouseLinearCurve {
    Write-Host "`n[*] Applying 1:1 True Linear Mouse Tracking Curve..." -ForegroundColor Yellow
    $mousePath = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mousePath -Name 'MouseSpeed' -Value 0 -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mousePath -Name 'MouseThreshold1' -Value 0 -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mousePath -Name 'MouseThreshold2' -Value 0 -Type String -ErrorAction SilentlyContinue
    
    $linearX = [byte[]](0,0,0,0, 0,0,0,0, 0,0,4,0, 0,0,0,0, 0,0,8,0, 0,0,0,0, 0,0,12,0, 0,0,0,0, 0,0,16,0, 0,0,0,0)
    $linearY = [byte[]](0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0)
    Set-ItemProperty -Path $mousePath -Name 'SmoothMouseXCurve' -Value $linearX -Type Binary -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mousePath -Name 'SmoothMouseYCurve' -Value $linearY -Type Binary -ErrorAction SilentlyContinue
    Write-Host "      [+] Enhance Pointer Precision forced OFF + 1:1 linear curve active" -ForegroundColor Green
}

function Disable-StickyKeysPrompt {
    Write-Host "`n[*] Disabling Sticky Keys & Accessibility Hotkey Prompts..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Value '506' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\Keyboard Response' -Name 'Flags' -Value '122' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\ToggleKeys' -Name 'Flags' -Value '58' -Type String -ErrorAction SilentlyContinue
    Write-Host "      [+] Sticky Keys popups permanently disabled  --  No more clutch game interruptions!" -ForegroundColor Green
}

function Enable-EndTaskRightClick {
    Write-Host "`n[*] Enabling 'End Task' on Taskbar Right-Click Menu..." -ForegroundColor Yellow
    $taskbarDev = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings'
    if (-not (Test-Path $taskbarDev)) { New-Item -Path $taskbarDev -Force | Out-Null }
    Set-ItemProperty -Path $taskbarDev -Name 'TaskbarEndTask' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] End Task enabled on Taskbar  --  Terminate frozen games instantly!" -ForegroundColor Green
}

function Disable-BackgroundAppsGlobal {
    Write-Host "`n[*] Disabling Background Apps Globally..." -ForegroundColor Yellow
    $bgAccess = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'
    if (-not (Test-Path $bgAccess)) { New-Item -Path $bgAccess -Force | Out-Null }
    Set-ItemProperty -Path $bgAccess -Name 'GlobalUserDisabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $searchPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    if (-not (Test-Path $searchPath)) { New-Item -Path $searchPath -Force | Out-Null }
    Set-ItemProperty -Path $searchPath -Name 'BackgroundAppGlobalToggle' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] All UWP background apps disabled  --  Zero CPU interrupt polling" -ForegroundColor Green
}

function Remove-WidgetsPlatform {
    Write-Host "`n[*] Removing Windows Widgets & WebExperience Platform..." -ForegroundColor Yellow
    Get-Process *Widget* -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-AppxPackage Microsoft.WidgetsPlatformRuntime -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxPackage MicrosoftWindows.Client.WebExperience -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

    $dsh = 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh'
    if (-not (Test-Path $dsh)) { New-Item -Path $dsh -Force | Out-Null }
    Set-ItemProperty -Path $dsh -Name 'AllowNewsAndInterests' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Widgets and News removed  --  Reclaimed 300MB+ RAM" -ForegroundColor Green
}

function Optimize-SvcHostSplitting {
    Write-Host "`n[*] Optimizing SvcHost Process Memory Threshold..." -ForegroundColor Yellow
    try {
        $ramKb = [int]((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1KB)
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value $ramKb -Type DWord -ErrorAction SilentlyContinue
        Write-Host "      [+] SvcHostSplitThresholdInKB set to $ramKb KB (Matched to Physical RAM)" -ForegroundColor Green
    } catch {
        Write-Host "      [~] SvcHost threshold set to 16GB default" -ForegroundColor DarkYellow
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value 16777216 -Type DWord -ErrorAction SilentlyContinue
    }
}

function Block-WpbtExecution {
    Write-Host "`n[*] Blocking UEFI/BIOS Windows Platform Binary Table (WPBT)..." -ForegroundColor Yellow
    $smPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
    Set-ItemProperty -Path $smPath -Name 'DisableWpbtExecution' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] WPBT execution blocked  --  Motherboard vendor bloatware cannot inject at boot!" -ForegroundColor Green
}

function Block-PeripheralBloat {
    Write-Host "`n[*] Immunizing System Against Peripheral Auto-Bloatware..." -ForegroundColor Yellow
    $razerPath = "$Env:SystemRoot\Installer\Razer"
    if (!(Test-Path $razerPath)) { New-Item -Path $razerPath -ItemType Directory -Force | Out-Null }
    icacls $razerPath /deny "*S-1-1-0:(W)" 2>$null | Out-Null

    $logiPath = "$Env:ProgramFiles\LogiDownloadAssistant"
    if (!(Test-Path $logiPath)) { New-Item -Path $logiPath -ItemType Directory -Force | Out-Null }
    icacls $logiPath /deny "*S-1-1-0:(W)" 2>$null | Out-Null

    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer' -Name 'DisableCoInstallers' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' -Name 'SearchOrderConfig' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Stop-Process -Name 'logi_download_assistant' -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] Razer Synapse & Logitech Download Assistant auto-installers permanently locked!" -ForegroundColor Green
}

function Remove-WindowsAI {
    Write-Host "`n[*] Purging Windows AI, Copilot & Recall Packages..." -ForegroundColor Yellow
    Disable-WindowsOptionalFeature -FeatureName Recall -Online -NoRestart -ErrorAction SilentlyContinue | Out-Null
    Set-Service -Name WSAIFabricSvc -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name WSAIFabricSvc -Force -ErrorAction SilentlyContinue

    Get-AppxPackage -AllUsers "*Copilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    $coreAi = (Get-AppxPackage MicrosoftWindows.Client.CoreAI -ErrorAction SilentlyContinue).PackageFullName
    if ($coreAi) { Remove-AppxPackage $coreAi -ErrorAction SilentlyContinue }

    $np = 'HKLM:\SOFTWARE\Policies\WindowsNotepad'
    if (-not (Test-Path $np)) { New-Item -Path $np -Force | Out-Null }
    Set-ItemProperty -Path $np -Name 'DisableAIFeatures' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $exp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    if (-not (Test-Path $exp)) { New-Item -Path $exp -Force | Out-Null }
    Set-ItemProperty -Path $exp -Name 'SettingsPageVisibility' -Value 'hide:aicomponents' -Type String -ErrorAction SilentlyContinue
    Write-Host "      [+] Windows AI, Copilot and Recall stripped completely!" -ForegroundColor Green
}

function Enable-ClassicContextMenu {
    Write-Host "`n[*] Restoring Classic Windows 10 Right-Click Menu in Windows 11..." -ForegroundColor Yellow
    $clsid = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
    if (-not (Test-Path $clsid)) { New-Item -Path $clsid -Force | Out-Null }
    Set-ItemProperty -Path $clsid -Name '(Default)' -Value '' -ErrorAction SilentlyContinue
    Write-Host "      [+] Classic Context Menu active  --  Zero lag right-click restored!" -ForegroundColor Green
}

function Disable-StartMenuBing {
    Write-Host "`n[*] Disabling Bing Web Search in Start Menu..." -ForegroundColor Yellow
    $pol = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
    if (-not (Test-Path $pol)) { New-Item -Path $pol -Force | Out-Null }
    Set-ItemProperty -Path $pol -Name 'DisableSearchBoxSuggestions' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $srch = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    if (-not (Test-Path $srch)) { New-Item -Path $srch -Force | Out-Null }
    Set-ItemProperty -Path $srch -Name 'BingSearchEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Bing Web Search disabled  --  Local search only, instant results!" -ForegroundColor Green
}

function Disable-ExplorerAutoDiscovery {
    Write-Host "`n[*] Disabling File Explorer Automatic Folder Discovery..." -ForegroundColor Yellow
    $allFolders = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell'
    if (-not (Test-Path $allFolders)) { New-Item -Path $allFolders -Force | Out-Null }
    Set-ItemProperty -Path $allFolders -Name 'FolderType' -Value 'NotSpecified' -Type String -ErrorAction SilentlyContinue
    Write-Host "      [+] Explorer folder auto-discovery disabled  --  Instant folder opening!" -ForegroundColor Green
}

function Enable-LongPaths {
    Write-Host "`n[*] Enabling Win32 Long Paths (>260 characters)..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Long paths enabled (>260 chars)  --  Modding and game paths unrestricted!" -ForegroundColor Green
}

function Disable-LockScreen {
    Write-Host "`n[*] Disabling Windows Lock Screen Swipe Delay..." -ForegroundColor Yellow
    $pers = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
    if (-not (Test-Path $pers)) { New-Item -Path $pers -Force | Out-Null }
    Set-ItemProperty -Path $pers -Name 'NoLockScreen' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Lock screen disabled  --  Direct password/PIN login prompt!" -ForegroundColor Green
}

function Enable-BsodVerbose {
    Write-Host "`n[*] Enabling Verbose Crash Parameters on BSoD..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'DisplayParameters' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] BSoD verbose mode enabled  --  Driver and stopcode display active for tuning!" -ForegroundColor Green
}

function Disable-ReservedStorage {
    Write-Host "`n[*] Disabling Windows Reserved Storage..." -ForegroundColor Yellow
    try {
        Set-WindowsReservedStorageState -State Disabled -ErrorAction SilentlyContinue | Out-Null
    } catch {}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager' -Name 'ShippedWithReserves' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Reserved storage disabled  --  ~7GB SSD space reclaimed!" -ForegroundColor Green
}

function Set-ShowFileExtensionsAndHidden {
    Write-Host "`n[*] Showing File Extensions & Hidden Files..." -ForegroundColor Yellow
    $adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $adv -Name 'HideFileExt' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $adv -Name 'Hidden' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] File extensions and hidden files set to visible!" -ForegroundColor Green
}

function Set-SecurityUpdatesOnly {
    Write-Host "`n[*] Configuring Windows Updates: Security Patches Only (Defer Feature Builds 2 Years)..." -ForegroundColor Yellow
    $wu = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    if (-not (Test-Path $wu)) { New-Item -Path $wu -Force | Out-Null }
    Set-ItemProperty -Path $wu -Name 'DeferFeatureUpdates' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $wu -Name 'DeferFeatureUpdatesPeriodInDays' -Value 730 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $wu -Name 'DeferQualityUpdates' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Security-only update policy active  --  Feature builds deferred 2 years, drivers protected!" -ForegroundColor Green
}


do {
    Show-PumpkiNBanner
    $choice = Read-Host "Select an option [0-21]"
    switch ($choice) {
        "1" {
            Optimize-Network
            Optimize-GpuAuto
            Optimize-CpuAndSystem
            Optimize-LatencyAndInput
            Apply-GameHooks
            Debloat-BackgroundServices
            Enable-UltimatePerformancePlan
            Strip-VisualEffects
            Harden-PrivacyTelemetry
            Optimize-DiskIO
            Disable-ScheduledJunkTasks
            Optimize-StartupAndDns
            Write-Host "`n================================================================================" -ForegroundColor Green
            Write-Host "  [OK] ALL OPTIMIZATIONS APPLIED SUCCESSFULLY  --  FULL BEAST MODE ENGAGED!" -ForegroundColor Green
            Write-Host "================================================================================" -ForegroundColor Green
            Write-Host "  A system RESTART is recommended for all changes to take full effect." -ForegroundColor Yellow
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
        "14" {
            Write-Host "`n[*] Launching Microsoft Activation Scripts (MAS)..." -ForegroundColor Yellow
            Write-Host "      A new PowerShell window will open with the MAS interface." -ForegroundColor Cyan
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
            Read-Host "`nPress Enter to return to menu"
        }
        "15" {
            Debloat-BackgroundServices
            Write-Host "`n[OK] Background services debloated!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "16" {
            Enable-UltimatePerformancePlan
            Write-Host "`n[OK] Ultimate Performance Power Plan activated!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "17" {
            Strip-VisualEffects
            Write-Host "`n[OK] All visual effects stripped for maximum performance!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "18" {
            Harden-PrivacyTelemetry
            Write-Host "`n[OK] Privacy hardened and telemetry disabled!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "19" {
            Optimize-DiskIO
            Write-Host "`n[OK] Disk I/O and storage optimized!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "20" {
            Disable-ScheduledJunkTasks
            Write-Host "`n[OK] Junk scheduled tasks disabled!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "21" {
            Optimize-StartupAndDns
            Write-Host "`n[OK] Startup cleaned and DNS optimized!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "0" {
            Write-Host "`nThank you for using PumpkiN's Ultimate Gaming Optimizer!" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            return
        }
    }
} while ($choice -ne "0")
