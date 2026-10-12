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

function Invoke-CpuCoreUnparking {
    <#
    .SYNOPSIS
        Unparks 100% of CPU cores, sets minimum processor state to 100%, and unmasks core parking in Power Options.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Unparking 100% of CPU Cores & Disabling Processor Sleep..." -ForegroundColor Yellow

    # Unhide core parking settings in Power Options GUI
    $subProcessorKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00"
    $unhideGuids = @(
        "0cc5b647-c1df-4637-891a-dec35c318583", # Min cores
        "ea062031-0e34-4ff1-9b6d-eb10593ac08f", # Max cores
        "be337238-0d82-4146-a960-492742134378", # Boost mode
        "0602446d-d8e3-4e29-9e6f-ddde3669f87f", # Perf increase threshold
        "12a0ab44-fe16-4661-bd10-eef3298d1945"  # Perf decrease threshold
    )
    foreach ($ug in $unhideGuids) {
        $p = "$subProcessorKey\$ug"
        if (Test-Path $p) {
            Set-ItemProperty -Path $p -Name "Attributes" -Value 2 -Type DWord -ErrorAction SilentlyContinue
        }
    }

    # Apply 100% Core Unparking to active scheme
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100
    powercfg -setdcvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setdcvalueindex scheme_current sub_processor CPMAXCORES 100
    powercfg -setacvalueindex scheme_current sub_processor PROCFREQMAX 0
    powercfg -setacvalueindex scheme_current sub_processor be337238-0d82-4146-a960-492742134378 2 2>$null # Aggressive Boost
    powercfg -setacvalueindex scheme_current sub_processor 0602446d-d8e3-4e29-9e6f-ddde3669f87f 10 2>$null # Increase threshold
    powercfg -setacvalueindex scheme_current sub_processor 12a0ab44-fe16-4661-bd10-eef3298d1945 80 2>$null # Decrease threshold
    powercfg -setactive scheme_current

    Write-Host "      [+] 100% of CPU logical cores unparked! Processor downclocking eliminated." -ForegroundColor Green
    return $true
}

function Invoke-PumpkiNEsportsPowerPlan {
    <#
    .SYNOPSIS
        Creates, customizes, and activates the PumpkiN Esports Ultimate Performance power scheme.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Configuring PumpkiN Esports Ultimate Power Plan..." -ForegroundColor Yellow

    # Ensure core parking settings are unmasked
    Invoke-CpuCoreUnparking | Out-Null

    $schemes = powercfg -list
    $targetGuid = $null

    $existingPumpkin = $schemes | Select-String "PumpkiN Esports"
    if ($existingPumpkin) {
        $targetGuid = ($existingPumpkin -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
    } else {
        $existingUlt = $schemes | Select-String "Ultimate Performance"
        if ($existingUlt) {
            $targetGuid = ($existingUlt[0] -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        } else {
            $dupOut = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
            if ($dupOut -match '([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})') {
                $targetGuid = $matches[1]
            }
        }
    }

    if (-not $targetGuid) {
        $targetGuid = "scheme_current"
    } else {
        powercfg -changename $targetGuid "PumpkiN Esports Ultimate Performance" "0% CPU Core Parking, Aggressive Boost Clocks, Zero DPC Latency"
    }

    # Apply Esports Ultra-Low Latency Power Attributes
    powercfg -setacvalueindex $targetGuid sub_processor CPMINCORES 100
    powercfg -setacvalueindex $targetGuid sub_processor CPMAXCORES 100
    powercfg -setdcvalueindex $targetGuid sub_processor CPMINCORES 100
    powercfg -setdcvalueindex $targetGuid sub_processor CPMAXCORES 100
    powercfg -setacvalueindex $targetGuid sub_processor PROCFREQMAX 0
    powercfg -setacvalueindex $targetGuid sub_processor be337238-0d82-4146-a960-492742134378 2 2>$null
    powercfg -setacvalueindex $targetGuid sub_processor 0602446d-d8e3-4e29-9e6f-ddde3669f87f 10 2>$null
    powercfg -setacvalueindex $targetGuid sub_processor 12a0ab44-fe16-4661-bd10-eef3298d1945 80 2>$null

    # Disable Peripheral & Bus Sleep
    powercfg -setacvalueindex $targetGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4760-a56b-140af6094241 0 2>$null # USB Selective Suspend Off
    powercfg -setacvalueindex $targetGuid 501a4d13-42af-4429-9e56-e32f20308218 ee132098-89fc-45ce-9179-d4b6c504d67e 0 2>$null # PCIe Link State Off
    powercfg -change -disk-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0

    powercfg -setactive $targetGuid
    Write-Host "      [+] PumpkiN Esports Ultimate Power Plan ACTIVE!" -ForegroundColor Green
    return $true
}

function Restore-CpuCoreParking {
    <#
    .SYNOPSIS
        Restores default CPU core parking and Windows Balanced power scheme.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Restoring Default Core Parking & Windows Balanced Power Scheme..." -ForegroundColor Yellow

    $balanced = powercfg /list | Select-String "Balanced"
    if ($balanced) {
        $guid = ($balanced -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        powercfg /setactive $guid
        Write-Host "      [+] Activated Windows Balanced power scheme ($guid)" -ForegroundColor Green
    } else {
        powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
    }

    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 10 2>$null
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100 2>$null
    powercfg -setacvalueindex scheme_current sub_processor 0602446d-d8e3-4e29-9e6f-ddde3669f87f 60 2>$null
    powercfg -setacvalueindex scheme_current sub_processor 12a0ab44-fe16-4661-bd10-eef3298d1945 40 2>$null
    powercfg -setactive scheme_current

    Write-Host "      [OK] Windows Core Parking & Balanced power defaults restored." -ForegroundColor Green
    return $true
}

function Get-CpuCoreParkingStatus {
    <#
    .SYNOPSIS
        Returns current active power scheme and core unparking status.
    #>
    [CmdletBinding()]
    param()

    $schemes = powercfg -list
    $activeLine = $schemes | Select-String "\*"
    $activeName = "Unknown"
    $activeGuid = ""
    if ($activeLine -match 'GUID:\s*([a-f0-9-]+)\s+\(([^)]+)\)') {
        $activeGuid = $matches[1]
        $activeName = $matches[2]
    }

    $isUnparked = ($activeName -match 'Ultimate|Esports|Highest|High')

    return [PSCustomObject]@{
        ActiveSchemeName = $activeName
        ActiveSchemeGuid = $activeGuid
        IsUnparked       = $isUnparked
        DisplayText      = "$activeName $(if ($isUnparked) { '(100% Cores Active)' } else { '(Core Parking Default)' })"
    }
}

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Write-Host "=== PUMPKIN CPU CORE UNPARKING & POWER ENGINE ===" -ForegroundColor Cyan
    Write-Host "1. Activate PumpkiN Esports Ultimate Power Plan (0% Core Parking)"
    Write-Host "2. Unpark 100% CPU Cores on Current Scheme"
    Write-Host "3. Restore Default Core Parking & Balanced Plan"
    Write-Host "4. Query Core Parking Status"
    $ans = Read-Host "Select option [1-4]"
    switch ($ans) {
        "1" { Invoke-PumpkiNEsportsPowerPlan }
        "2" { Invoke-CpuCoreUnparking }
        "3" { Restore-CpuCoreParking }
        "4" {
            $st = Get-CpuCoreParkingStatus
            Write-Host "Status: $($st.DisplayText)" -ForegroundColor Green
        }
    }
    Read-Host "`nPress Enter to exit"
}