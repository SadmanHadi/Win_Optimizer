<#
================================================================================
  PumpkiN's Modular Suite: Kernel, Quantum & CPU Priority Scheduling Suite
================================================================================
#>

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

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"" -Verb RunAs
        exit
    }
    Optimize-CpuAndSystem
    Read-Host "
Press Enter to exit"
}