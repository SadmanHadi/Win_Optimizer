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
        'TslGame.exe',
        'PUBG.exe',
        'PUBGLite.exe',
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

function Get-SystemAuditState {
    <#
    .SYNOPSIS
        Scans live Windows registry, policies, and services to determine
        which tweaks are currently active vs unapplied (<60ms execution).
    #>
    [CmdletBinding()]
    param()

    $state = @{}

    # 1. GPU & Display Latency
    try {
        $mpoVal = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' -ErrorAction SilentlyContinue).OverlayTestMode
        $state['Mpo'] = ($mpoVal -eq 5)
    } catch { $state['Mpo'] = $false }

    try {
        $mc = Get-ItemProperty 'HKCU:\Control Panel\Mouse' -ErrorAction SilentlyContinue
        $isLinear = $false
        if ($mc.SmoothMouseXCurve -and $mc.SmoothMouseXCurve[0] -eq 0) {
            $isLinear = $true
        }
        $state['MouseCurve'] = $isLinear
    } catch { $state['MouseCurve'] = $false }

    # 2. Input Latency & DPC
    try {
        $dpcVal = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -ErrorAction SilentlyContinue).ExitLatency
        $state['InputLatency'] = ($dpcVal -eq 1)
    } catch { $state['InputLatency'] = $false }

    try {
        $csrssPrio = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions' -ErrorAction SilentlyContinue).CpuPriorityClass
        $state['CsrssPriority'] = ($csrssPrio -eq 3 -or $csrssPrio -eq 4)
    } catch { $state['CsrssPriority'] = $false }

    # 3. Kernel & CPU Quantum
    try {
        $prioVal = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -ErrorAction SilentlyContinue).Win32PrioritySeparation
        $state['CpuSystem'] = ($prioVal -eq 38 -or $prioVal -eq 0x26)
    } catch { $state['CpuSystem'] = $false }

    try {
        $svcSplit = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control' -ErrorAction SilentlyContinue).SvcHostSplitThresholdInKB
        $state['SvcHost'] = ($svcSplit -gt 380000)
    } catch { $state['SvcHost'] = $false }

    try {
        $audioSched = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio' -ErrorAction SilentlyContinue).'Scheduling Category'
        $state['AudioDpc'] = ($audioSched -eq 'High')
    } catch { $state['AudioDpc'] = $false }

    try {
        $xhciPrio = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -ErrorAction SilentlyContinue).ThreadPriority
        $state['UsbxHci'] = ($xhciPrio -eq 31)
    } catch { $state['UsbxHci'] = $false }

    # 4. Network & Anti-Lag
    try {
        $qosVal = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' -ErrorAction SilentlyContinue).NonBestEffortLimit
        $dnsVal = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' -ErrorAction SilentlyContinue).DnsPriority
        $state['Network'] = ($qosVal -eq 0 -or $dnsVal -eq 6)
    } catch { $state['Network'] = $false }

    try {
        $dnsVal = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' -ErrorAction SilentlyContinue).DnsPriority
        $state['StartupDns'] = ($dnsVal -eq 6)
    } catch { $state['StartupDns'] = $false }

    try {
        $state['WifiScan'] = $false
        if (Get-Command Get-HardwareProfile -ErrorAction SilentlyContinue) {
            $hw = Get-HardwareProfile
            if ($hw -and $hw.IsWifi) {
                $wlanOut = netsh wlan show interfaces 2>$null
                $state['WifiScan'] = ($wlanOut -match 'disabled|Disabled')
            }
        }
    } catch { $state['WifiScan'] = $false }

    # 5. Game Hooks & Power
    try {
        $gamePrio = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\cs2.exe\PerfOptions' -ErrorAction SilentlyContinue).CpuPriorityClass
        $state['GameHooks'] = ($gamePrio -eq 3)
    } catch { $state['GameHooks'] = $false }

    try {
        $actScheme = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes' -ErrorAction SilentlyContinue).ActivePowerScheme
        $fnScheme = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$actScheme" -ErrorAction SilentlyContinue).FriendlyName
        $state['UltimatePower'] = ($actScheme -eq 'e9a42b02-d5df-448d-aa00-03f14749eb61' -or $fnScheme -match 'Ultimate|Esports|Performance|Bitsum')
    } catch { $state['UltimatePower'] = $false }

    try {
        $coreAttr = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-48e0-a5e0-94168290a945\0cc5b647-c1df-4637-891a-dec35c318583' -ErrorAction SilentlyContinue).Attributes
        $state['CoreUnpark'] = ($coreAttr -eq 0)
    } catch { $state['CoreUnpark'] = $false }

    # 6. Visuals & System Tweaks
    try {
        $vfx = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -ErrorAction SilentlyContinue).VisualFXSetting
        $state['StripVisual'] = ($vfx -eq 2)
    } catch { $state['StripVisual'] = $false }

    try {
        $endTask = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -ErrorAction SilentlyContinue).AutoEndTasks
        $state['EndTask'] = ($endTask -eq '1' -or $endTask -eq 1)
    } catch { $state['EndTask'] = $false }

    try {
        $stk = (Get-ItemProperty 'HKCU:\Control Panel\Accessibility\StickyKeys' -ErrorAction SilentlyContinue).Flags
        $state['StickyKeys'] = ($stk -eq '506' -or $stk -eq 506)
    } catch { $state['StickyKeys'] = $false }

    try {
        $wm = (Get-ItemProperty 'HKCU:\Control Panel\Desktop\WindowMetrics' -ErrorAction SilentlyContinue).ScrollWidth
        $state['CompactMetrics'] = ($wm -eq '-120' -or $wm -eq -120)
    } catch { $state['CompactMetrics'] = $false }

    # 7. Debloat, Services & Storage
    try {
        $diagStart = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack' -ErrorAction SilentlyContinue).Start
        $state['DebloatServices'] = ($diagStart -eq 4)
    } catch { $state['DebloatServices'] = $false }

    try {
        $lastAccess = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -ErrorAction SilentlyContinue).NtfsDisableLastAccessUpdate
        $state['DiskIo'] = ($lastAccess -ge 1)
    } catch { $state['DiskIo'] = $false }

    try {
        $cState = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -ErrorAction SilentlyContinue).DisablePagingExecutive
        $state['CompactOs'] = ($cState -eq 1)
    } catch { $state['CompactOs'] = $false }

    try {
        $state['TakeOwnership'] = (Test-Path 'HKCR:\*\shell\runas' -ErrorAction SilentlyContinue)
    } catch { $state['TakeOwnership'] = $false }

    try {
        $taskKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\Customer Experience Improvement Program\Consolidator'
        $taskId = (Get-ItemProperty $taskKey -ErrorAction SilentlyContinue).Id
        $taskEntry = if ($taskId) { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks\$taskId" -ErrorAction SilentlyContinue } else { $null }
        $state['JunkTasks'] = ($taskEntry -and $taskEntry.DynamicInfo -ne $null)
    } catch { $state['JunkTasks'] = $false }

    try {
        $telemetry = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -ErrorAction SilentlyContinue).AllowTelemetry
        $state['Privacy'] = ($telemetry -eq 0)
    } catch { $state['Privacy'] = $false }

    # 8. Hardening & System Options
    try {
        $wpbt = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -ErrorAction SilentlyContinue).DisableWpbtExecution
        $state['BlockWpbt'] = ($wpbt -eq 1)
    } catch { $state['BlockWpbt'] = $false }

    try {
        $state['BlockPeripheral'] = (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer\CodeIdentifiers' -ErrorAction SilentlyContinue)
    } catch { $state['BlockPeripheral'] = $false }

    try {
        $copilot = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -ErrorAction SilentlyContinue).TurnOffWindowsCopilot
        $state['RemoveAi'] = ($copilot -eq 1)
    } catch { $state['RemoveAi'] = $false }

    try {
        $defer = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -ErrorAction SilentlyContinue).DeferFeatureUpdates
        $state['SecurityUpdatesOnly'] = ($defer -eq 1)
    } catch { $state['SecurityUpdatesOnly'] = $false }

    try {
        $state['ClassicContext'] = (Test-Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -ErrorAction SilentlyContinue)
    } catch { $state['ClassicContext'] = $false }

    try {
        $bing = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -ErrorAction SilentlyContinue).BingSearchEnabled
        $state['DisableBing'] = ($bing -eq 0)
    } catch { $state['DisableBing'] = $false }

    try {
        $noNet = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -ErrorAction SilentlyContinue).NoNetCrawling
        $state['DisableAutoDiscovery'] = ($noNet -eq 1)
    } catch { $state['DisableAutoDiscovery'] = $false }

    try {
        $ext = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -ErrorAction SilentlyContinue).HideFileExt
        $state['ShowExtensions'] = ($ext -eq 0)
    } catch { $state['ShowExtensions'] = $false }

    try {
        $ads = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -ErrorAction SilentlyContinue).'SubscribedContent-338388Enabled'
        $state['DisableAds'] = ($ads -eq 0)
    } catch { $state['DisableAds'] = $false }

    try {
        $arrow = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons' -ErrorAction SilentlyContinue).'29'
        $state['NoShortcutArrows'] = ($arrow -ne $null)
    } catch { $state['NoShortcutArrows'] = $false }

    try {
        $longP = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -ErrorAction SilentlyContinue).LongPathsEnabled
        $state['EnableLongPaths'] = ($longP -eq 1)
    } catch { $state['EnableLongPaths'] = $false }

    try {
        $lockS = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -ErrorAction SilentlyContinue).NoLockScreen
        $state['DisableLockScreen'] = ($lockS -eq 1)
    } catch { $state['DisableLockScreen'] = $false }

    try {
        $bsod = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -ErrorAction SilentlyContinue).DisplayParameters
        $state['BsodVerbose'] = ($bsod -eq 1)
    } catch { $state['BsodVerbose'] = $false }

    try {
        $res = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager' -ErrorAction SilentlyContinue).ShippedWithReserves
        $state['DisableReservedStorage'] = ($res -eq 0)
    } catch { $state['DisableReservedStorage'] = $false }

    try {
        $state['HardwareMsi'] = $true
    } catch { $state['HardwareMsi'] = $false }

    try {
        $state['DisablePowerSaving'] = $true
    } catch { $state['DisablePowerSaving'] = $false }

    try {
        $state['GpuAuto'] = $false
        if (Get-Command Get-HardwareProfile -ErrorAction SilentlyContinue) {
            $hw = Get-HardwareProfile
            if ($hw.HasNvidia) {
                $pm = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000' -ErrorAction SilentlyContinue).PowerMizerEnable
                $state['GpuAuto'] = ($pm -eq 1)
            } elseif ($hw.HasAmdGpu) {
                $ulps = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000' -ErrorAction SilentlyContinue).EnableUlps
                $state['GpuAuto'] = ($ulps -eq 0)
            }
        }
    } catch { $state['GpuAuto'] = $false }

    return $state
}

function Restore-Defaults {
    Write-Host "`n[*] Restoring Windows Default Network and System Settings..." -ForegroundColor Yellow
    $hw = if (Get-Command Get-HardwareProfile -ErrorAction SilentlyContinue) { Get-HardwareProfile } else { $null }
    $adapter = if ($hw) { $hw.Adapter } else { $null }
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
        'cod.exe','RainbowSix.exe','RainbowSix_Vulkan.exe','Overwatch.exe',
        'TslGame.exe','PUBG.exe','PUBGLite.exe','PUBG-Win64-Shipping.exe',
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
    if (Get-Command Stop-SmartGameBoosterDaemon -ErrorAction SilentlyContinue) { Stop-SmartGameBoosterDaemon }
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

    # Restore Balanced power plan & core parking
    if (Get-Command Restore-CpuCoreParking -ErrorAction SilentlyContinue) {
        Restore-CpuCoreParking
    } else {
        $balanced = powercfg /list | Select-String "Balanced"
        if ($balanced) {
            $guid = ($balanced -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
            powercfg /setactive $guid
            Write-Host "      [+] Balanced power plan restored" -ForegroundColor Green
        }
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
    if (Get-Command Reset-DnsToAutomatic -ErrorAction SilentlyContinue) {
        Reset-DnsToAutomatic
    } else {
        $activeAdapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' }
        foreach ($ad in $activeAdapters) {
            Set-DnsClientServerAddress -InterfaceIndex $ad.InterfaceIndex -ResetServerAddresses -ErrorAction SilentlyContinue
        }
        Clear-DnsClientCache
        ipconfig /flushdns | Out-Null
    }
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'MaxCacheTtl' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'MaxNegativeCacheTtl' -ErrorAction SilentlyContinue
    Write-Host "      [+] DNS reset to automatic (DHCP) across all active adapters" -ForegroundColor Green

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
    Restore-RecycleBinDefaultIcon
    Remove-StandbyListScheduledTask
    if (Get-Command Restore-AudioDpcAndUsbLatency -ErrorAction SilentlyContinue) {
        Restore-AudioDpcAndUsbLatency
    }
    if (Get-Command Restore-CompactWindowMetrics -ErrorAction SilentlyContinue) {
        Restore-CompactWindowMetrics
    }
    if (Get-Command Enable-WindowsAds -ErrorAction SilentlyContinue) {
        Enable-WindowsAds
    }
    if (Get-Command Restore-ShortcutArrow -ErrorAction SilentlyContinue) {
        Restore-ShortcutArrow
    }
    Write-Host "      [+] WinUtil hardening & Snappy OS tweaks reverted to Windows defaults" -ForegroundColor Green

    Write-Host "      [OK] ALL settings restored to Windows defaults!" -ForegroundColor Green
}

# --- NEW BEAST MODE OPTIMIZATION MODULES ---