<#
================================================================================
  PumpkiN's Modular Suite: Esports Game Hooks, Diagnostics & Restore Engine
================================================================================
#>

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
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Restore Device Power Saving & USB Settings
    try {
        $powerDevices = Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root\wmi -ErrorAction SilentlyContinue
        foreach ($dev in $powerDevices) {
            if ($dev.InstanceName -match 'USB|PCI|ROOT_HUB') {
                Set-CimInstance -InputObject $dev -Property @{ Enable = $true } -ErrorAction SilentlyContinue
            }
        }
        Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -Name 'DisableSelectiveSuspend' -ErrorAction SilentlyContinue
    } catch {}

    # Restore MMCSS Games Task Defaults
    $gamesTask = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
    if (Test-Path $gamesTask) {
        Set-ItemProperty -Path $gamesTask -Name 'GPU Priority' -Value 8 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamesTask -Name 'Priority' -Value 2 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamesTask -Name 'Scheduling Category' -Value 'Medium' -Type String -ErrorAction SilentlyContinue
    }

    # Revert CompactOS & Context Menus
    if (Get-Command Disable-CompactOS -ErrorAction SilentlyContinue) { Disable-CompactOS }
    if (Get-Command Disable-TakeOwnershipMenu -ErrorAction SilentlyContinue) { Disable-TakeOwnershipMenu }
    
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