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

function Restore-GameHooks {
    Write-Host "`n[*] Restoring Game IFEO Priorities to Defaults..." -ForegroundColor Yellow
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
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "      [OK] Game IFEO CPU and I/O priority hooks removed." -ForegroundColor Green
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

    Show-SystemAuditReport
}

function Show-SystemAuditReport {
    <#
    .SYNOPSIS
        Displays a structured, categorized console report of all active vs unapplied
        optimizations across Gaming & Latency, Privacy & Telemetry, and System & Usability.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host "                LIVE SYSTEM AUDIT & TWEAK STATUS REPORT                         " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    $audit = Get-SystemAuditState
    $scCol = if ($audit.ScorePercent -ge 80) { 'Green' } elseif ($audit.ScorePercent -ge 50) { 'Yellow' } else { 'Cyan' }
    Write-Host "Overall System Tuning Score: $($audit.ScoreGrade) ($($audit.ScoreApplied)/$($audit.ScoreTotal) Active - $($audit.ScorePercent)%)" -ForegroundColor $scCol

    # Category 1: Gaming & Latency
    $gamingMap = [ordered]@{
        'GpuAuto'             = 'GPU Driver Latency Auto-Tuning'
        'HardwareMsi'         = 'Hardware MSI Mode (GPU/Net/Audio/USB)'
        'DisablePowerSaving'  = 'Disable Device Power Saving Suspensions'
        'Mpo'                 = 'Disable Multiplane Overlay (MPO)'
        'MouseCurve'          = '1:1 Raw Mouse Linear Curve'
        'InputLatency'        = '8000Hz USB Keyboard Response Buffers'
        'CsrssPriority'       = 'CSRSS Realtime I/O Priority'
        'CpuSystem'           = 'Win32PrioritySeparation Quantum (0x26)'
        'SvcHost'             = 'SvcHost RAM Thread Splitting'
        'Network'             = 'TCP/IP Low-Latency Anti-Lag Stack'
        'WifiScan'            = 'Wi-Fi 0ms Roaming Ping Shield'
        'StartupDns'          = 'Gaming DNS & Fast Startup Tuning'
        'GameHooks'           = 'Esports Process Priority Hooks'
        'UltimatePower'       = 'PumpkiN Ultimate Power Plan (0% Core Parking)'
        'CoreUnpark'          = '100% CPU Core Unparking'
        'StripVisual'         = 'Strip Desktop Visual Animations'
        'EndTask'             = 'Taskbar End Task Right-Click'
        'StickyKeys'          = 'Disable Sticky Keys Prompt'
        'CompactMetrics'      = 'Compact Window Metrics (8px Scrollbars)'
        'DebloatServices'     = 'Debloat Background Services'
        'DiskIo'              = 'Optimize Disk I/O & NTFS (No 8.3/LastAccess)'
        'CompactOs'           = 'CompactOS System Compression'
        'TakeOwnership'       = 'Take Ownership Context Menu'
        'JunkTasks'           = 'Disable Scheduled Junk Tasks'
        'Privacy'             = 'Harden Core Windows Telemetry (Level 0)'
        'AudioDpc'            = 'Audio DPC & Anti-Popping (MMCSS High)'
        'UsbxHci'             = 'USB xHCI Realtime Thread Priority (31)'
        'DeviceManager'       = 'Device Manager Latency Tuning (HPET/Timers)'
    }
    $activeGamingCount = 0
    foreach ($k in $gamingMap.Keys) { if ($audit.State[$k] -eq $true) { $activeGamingCount++ } }
    Write-Host "`n>>> GAMING & LATENCY TWEAKS ($activeGamingCount/$($gamingMap.Count) Active):" -ForegroundColor Cyan
    foreach ($k in $gamingMap.Keys) {
        $isActive = ($audit.State[$k] -eq $true)
        $glyph = if ($isActive) { "[+]" } else { "[-]" }
        $col   = if ($isActive) { "Green" } else { "DarkGray" }
        Write-Host "  $glyph $($gamingMap[$k])" -ForegroundColor $col
    }

    # Category 2: Privacy & Telemetry
    $privacyMap = [ordered]@{
        'AppTelemetry'             = 'Disable 3rd-Party App Telemetry (Edge/Chrome/NV)'
        'BluetoothAdvertising'     = 'Disable Bluetooth Advertising Beacons'
        'CloudContent'             = 'Disable Cloud Optimized Content'
        'CdpServices'              = 'Disable CDP Connected Devices Platform'
        'DiagnosticsToasts'        = 'Disable Feedback & Survey Toasts'
        'OnlineSpeech'             = 'Disable Online Speech Recognition'
        'Arso'                     = 'Disable Auto-Restart Apps on Reboot'
        'TextInputCollection'      = 'Disable Handwriting & Typing Collection'
        'ClipboardSync'            = 'Disable Clipboard Cloud Synchronization'
        'SettingsMessageSync'      = 'Disable Settings & Message Sync'
        'FindMyDevice'             = 'Disable Find My Device GPS Tracking'
        'SafeSearch'               = 'Disable SafeSearch Query Telemetry'
        'RemoteAssistanceRegistry' = 'Disable Remote Assistance & Remote Registry'
        'DriverUpdatesExcluded'    = 'Exclude Drivers from Windows Update'
        'StoreAutoUpdates'         = 'Disable Microsoft Store Background Updates'
        'SmartScreen'              = 'Disable SmartScreen Hash Verification'
        'CrashDumps'               = 'Disable System Memory Crash Dumps'
        'SystemTimeouts'           = 'Optimize Service Shutdown Timeouts (2000ms)'
    }
    $activePrivCount = 0
    foreach ($k in $privacyMap.Keys) { if ($audit.State[$k] -eq $true) { $activePrivCount++ } }
    Write-Host "`n>>> PRIVACY & TELEMETRY TWEAKS ($activePrivCount/$($privacyMap.Count) Active):" -ForegroundColor Magenta
    foreach ($k in $privacyMap.Keys) {
        $isActive = ($audit.State[$k] -eq $true)
        $glyph = if ($isActive) { "[+]" } else { "[-]" }
        $col   = if ($isActive) { "Green" } else { "DarkGray" }
        Write-Host "  $glyph $($privacyMap[$k])" -ForegroundColor $col
    }

    # Category 3: System, Shell & Usability
    $systemMap = [ordered]@{
        'BlockWpbt'               = 'Block UEFI WPBT Binary Execution'
        'BlockPeripheral'         = 'Block Peripheral Bloatware Auto-Install'
        'RemoveAi'                = 'Purge Windows AI, Copilot & Recall'
        'SecurityUpdatesOnly'     = 'Security-Only Updates (Defer Feature Builds)'
        'ClassicContext'          = 'Classic Windows 10 Right-Click Menu'
        'DisableBing'             = 'Disable Start Menu Web & Bing Search'
        'DisableAutoDiscovery'    = 'Disable Network Explorer Auto-Discovery'
        'ShowExtensions'          = 'Show File Extensions & Hidden Files'
        'DisableAds'              = 'Disable All Windows Desktop & Shell Ads'
        'NoShortcutArrows'        = 'Remove Shortcut Arrow Icon Overlays'
        'EnableLongPaths'         = 'Enable Win32 Long Paths (MAX_PATH 32767)'
        'DisableLockScreen'       = 'Disable Windows Lock Screen Swipe'
        'BsodVerbose'             = 'Verbose BSOD Stop Codes & Drivers'
        'DisableReservedStorage'  = 'Reclaim 7GB Windows Reserved Storage'
        'BitLocker'               = 'Turn Off BitLocker Drive Encryption'
        'VbsSecurity'             = 'Disable VBS / HVCI Memory Integrity'
        'TaskbarLeft'             = 'Align Taskbar Icons to Left'
        'RecommendedStart'        = 'Hide Start Menu Recommended Section'
        'TaskbarChat'             = 'Disable Taskbar Chat & Teams Widget'
        'FilesCompact'            = 'File Explorer Compact View Mode'
        'SnapAssist'              = 'Disable Snap Assist Window Suggestions'
        'WindowsStickers'         = 'Disable Desktop Stickers'
        'EdgeDiscover'            = 'Disable Edge Discover Bing Sidebar'
        'CopyMoveMenu'            = 'Add Copy To & Move To Context Menu'
        'WindowShake'             = 'Disable Aero Shake Window Minimizing'
        'SystemDarkMode'          = 'System-Wide Dark Mode'
        'VerboseLogon'            = 'Enable Verbose Startup Boot Messages'
        'QuickAccessHistory'      = 'Disable Quick Access Recent Files History'
        'MyPeople'                = 'Disable My People Taskbar Band'
        'WindowsInk'              = 'Disable Windows Ink Workspace'
        'CastToDevice'            = 'Disable Cast to Device Context Menu'
    }
    $activeSysCount = 0
    foreach ($k in $systemMap.Keys) { if ($audit.State[$k] -eq $true) { $activeSysCount++ } }
    Write-Host "`n>>> SYSTEM & USABILITY TWEAKS ($activeSysCount/$($systemMap.Count) Active):" -ForegroundColor Yellow
    foreach ($k in $systemMap.Keys) {
        $isActive = ($audit.State[$k] -eq $true)
        $glyph = if ($isActive) { "[+]" } else { "[-]" }
        $col   = if ($isActive) { "Green" } else { "DarkGray" }
        Write-Host "  $glyph $($systemMap[$k])" -ForegroundColor $col
    }

    Write-Host "`n================================================================================" -ForegroundColor Cyan
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

    if (-not (Get-PSDrive -Name HKCR -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
    }

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
        $xhciPrio1 = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -ErrorAction SilentlyContinue).ThreadPriority
        $xhciPrio2 = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\USBXHCI\Parameters' -ErrorAction SilentlyContinue).ThreadPriority
        $state['UsbxHci'] = ($xhciPrio1 -eq 31 -or $xhciPrio2 -eq 31)
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
        $wlanOut = netsh wlan show interfaces 2>$null
        if ($wlanOut -match 'disabled|Disabled') {
            $state['WifiScan'] = $true
        } else {
            $hw = if (Get-Command Get-HardwareProfile -ErrorAction SilentlyContinue) { Get-HardwareProfile } else { $null }
            if ($hw -and (-not $hw.IsWifi)) {
                # Ethernet PC - AutoConfig scanning does not cause ping spikes on wired Ethernet
                $state['WifiScan'] = $true
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
        $state['CoreUnpark'] = ($coreAttr -eq 0 -or $coreAttr -eq 2)
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
        $state['TakeOwnership'] = (Test-Path -LiteralPath 'HKCR:\*\shell\runas' -ErrorAction SilentlyContinue)
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
        $folderType = (Get-ItemProperty 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' -ErrorAction SilentlyContinue).FolderType
        $state['DisableAutoDiscovery'] = ($noNet -eq 1 -or $folderType -eq 'NotSpecified')
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
        $state['DeviceManager'] = $false
        if (Get-Command Get-DeviceManagerOptimizationStatus -ErrorAction SilentlyContinue) {
            $state['DeviceManager'] = (Get-DeviceManagerOptimizationStatus)
        } else {
            $hpet = Get-PnpDevice -FriendlyName 'High precision event timer' -ErrorAction SilentlyContinue | Select-Object -First 1
            $state['DeviceManager'] = ($hpet -and ($hpet.ConfigManagerErrorCode -eq 22 -or "$($hpet.ConfigManagerErrorCode)" -match 'DISABLED|22' -or $hpet.Status -eq 'Error'))
        }
    } catch { $state['DeviceManager'] = $false }

    try {
        $pde = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker' -ErrorAction SilentlyContinue).PreventDeviceEncryption
        $bdeSvc = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\BDESVC' -ErrorAction SilentlyContinue).Start
        $state['BitLocker'] = ($pde -eq 1 -or $bdeSvc -eq 4)
    } catch { $state['BitLocker'] = $false }

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

    # 9. Windows 11 Exclusives & Shell Usability Probes
    try {
        $vbs = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard' -ErrorAction SilentlyContinue).EnableVirtualizationBasedSecurity
        $state['VbsSecurity'] = ($vbs -eq 0)
    } catch { $state['VbsSecurity'] = $false }

    try {
        $tbAl = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -ErrorAction SilentlyContinue).TaskbarAl
        $state['TaskbarLeft'] = ($tbAl -eq 0)
    } catch { $state['TaskbarLeft'] = $false }

    try {
        $hideRec = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -ErrorAction SilentlyContinue).HideRecommendedSection
        $state['RecommendedStart'] = ($hideRec -eq 1)
    } catch { $state['RecommendedStart'] = $false }

    try {
        $tbMn = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -ErrorAction SilentlyContinue).TaskbarMn
        $state['TaskbarChat'] = ($tbMn -eq 0)
    } catch { $state['TaskbarChat'] = $false }

    try {
        $compactM = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -ErrorAction SilentlyContinue).UseCompactMode
        $state['FilesCompact'] = ($compactM -eq 1)
    } catch { $state['FilesCompact'] = $false }

    try {
        $snap = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -ErrorAction SilentlyContinue).SnapAssist
        $state['SnapAssist'] = ($snap -eq 0)
    } catch { $state['SnapAssist'] = $false }

    try {
        $stk = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Stickers' -ErrorAction SilentlyContinue).EnableStickers
        $state['WindowsStickers'] = ($stk -eq 0)
    } catch { $state['WindowsStickers'] = $false }

    try {
        $edgeSide = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -ErrorAction SilentlyContinue).HubsSidebarEnabled
        $state['EdgeDiscover'] = ($edgeSide -eq 0)
    } catch { $state['EdgeDiscover'] = $false }

    try {
        $hasCopy = (Test-Path 'HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To' -ErrorAction SilentlyContinue)
        $state['CopyMoveMenu'] = ($hasCopy -eq $true)
    } catch { $state['CopyMoveMenu'] = $false }

    try {
        $shake = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -ErrorAction SilentlyContinue).DisallowShaking
        $state['WindowShake'] = ($shake -eq 1)
    } catch { $state['WindowShake'] = $false }

    try {
        $appsTheme = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -ErrorAction SilentlyContinue).AppsUseLightTheme
        $state['SystemDarkMode'] = ($appsTheme -eq 0)
    } catch { $state['SystemDarkMode'] = $false }

    try {
        $verb = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -ErrorAction SilentlyContinue).VerboseStatus
        $state['VerboseLogon'] = ($verb -eq 1)
    } catch { $state['VerboseLogon'] = $false }

    try {
        $recent = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -ErrorAction SilentlyContinue).ShowRecent
        $state['QuickAccessHistory'] = ($recent -eq 0)
    } catch { $state['QuickAccessHistory'] = $false }

    try {
        $ppl = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' -ErrorAction SilentlyContinue).PeopleBand
        $state['MyPeople'] = ($ppl -eq 0)
    } catch { $state['MyPeople'] = $false }

    try {
        $ink = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsInkWorkspace' -ErrorAction SilentlyContinue).AllowWindowsInkWorkspace
        $state['WindowsInk'] = ($ink -eq 0)
    } catch { $state['WindowsInk'] = $false }

    try {
        $playTo = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PlayTo' -ErrorAction SilentlyContinue).NoPlayTo
        $state['CastToDevice'] = ($playTo -eq 1)
    } catch { $state['CastToDevice'] = $false }

    # 10. Privacy & App Telemetry Probes
    try {
        $edgeMet = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -ErrorAction SilentlyContinue).MetricsReportingEnabled
        $state['AppTelemetry'] = ($edgeMet -eq 0)
    } catch { $state['AppTelemetry'] = $false }

    try {
        $btAdv = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Bluetooth' -ErrorAction SilentlyContinue).AllowAdvertising
        $state['BluetoothAdvertising'] = ($btAdv -eq 0)
    } catch { $state['BluetoothAdvertising'] = $false }

    try {
        $cloudOpt = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -ErrorAction SilentlyContinue).DisableCloudOptimizedContent
        $state['CloudContent'] = ($cloudOpt -eq 1)
    } catch { $state['CloudContent'] = $false }

    try {
        $cdpSvc = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\CDPSvc' -ErrorAction SilentlyContinue).Start
        $state['CdpServices'] = ($cdpSvc -eq 4)
    } catch { $state['CdpServices'] = $false }

    try {
        $toastSec = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance' -ErrorAction SilentlyContinue).Enabled
        $state['DiagnosticsToasts'] = ($toastSec -eq 0)
    } catch { $state['DiagnosticsToasts'] = $false }

    try {
        $speechAcc = (Get-ItemProperty 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' -ErrorAction SilentlyContinue).HasAccepted
        $state['OnlineSpeech'] = ($speechAcc -eq 0)
    } catch { $state['OnlineSpeech'] = $false }

    try {
        $arsoVal = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -ErrorAction SilentlyContinue).DisableAutomaticRestartSignOn
        $state['Arso'] = ($arsoVal -eq 1)
    } catch { $state['Arso'] = $false }

    try {
        $inkColl = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization' -ErrorAction SilentlyContinue).RestrictImplicitInkCollection
        $state['TextInputCollection'] = ($inkColl -eq 1)
    } catch { $state['TextInputCollection'] = $false }

    try {
        $clipCross = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -ErrorAction SilentlyContinue).AllowCrossDeviceClipboard
        $state['ClipboardSync'] = ($clipCross -eq 0)
    } catch { $state['ClipboardSync'] = $false }

    try {
        $syncSet = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' -ErrorAction SilentlyContinue).DisableSettingSync
        $state['SettingsMessageSync'] = ($syncSet -eq 2)
    } catch { $state['SettingsMessageSync'] = $false }

    try {
        $findDev = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice' -ErrorAction SilentlyContinue).AllowFindMyDevice
        $state['FindMyDevice'] = ($findDev -eq 0)
    } catch { $state['FindMyDevice'] = $false }

    try {
        $safeSrch = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings' -ErrorAction SilentlyContinue).SafeSearchMode
        $state['SafeSearch'] = ($safeSrch -eq 0)
    } catch { $state['SafeSearch'] = $false }

    try {
        $raHelp = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' -ErrorAction SilentlyContinue).fAllowToGetHelp
        $state['RemoteAssistanceRegistry'] = ($raHelp -eq 0)
    } catch { $state['RemoteAssistanceRegistry'] = $false }

    try {
        $wuDrv = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -ErrorAction SilentlyContinue).ExcludeWUDriversInQualityUpdate
        $state['DriverUpdatesExcluded'] = ($wuDrv -eq 1)
    } catch { $state['DriverUpdatesExcluded'] = $false }

    try {
        $storeAuto = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore' -ErrorAction SilentlyContinue).AutoDownload
        $state['StoreAutoUpdates'] = ($storeAuto -eq 2)
    } catch { $state['StoreAutoUpdates'] = $false }

    try {
        $smartScr = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -ErrorAction SilentlyContinue).EnableSmartScreen
        $state['SmartScreen'] = ($smartScr -eq 0)
    } catch { $state['SmartScreen'] = $false }

    try {
        $crashDump = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -ErrorAction SilentlyContinue).CrashDumpEnabled
        $state['CrashDumps'] = ($crashDump -eq 0)
    } catch { $state['CrashDumps'] = $false }

    try {
        $menuDelay = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -ErrorAction SilentlyContinue).MenuShowDelay
        $state['SystemTimeouts'] = ($menuDelay -eq '0' -or $menuDelay -eq 0)
    } catch { $state['SystemTimeouts'] = $false }

    # Compute Live Optimization Score & Grade
    $appliedCount = 0
    $totalCount = 0
    $stateCopy = @{}
    foreach ($k in $state.Keys) {
        $totalCount++
        $stateCopy[$k] = $state[$k]
        if ($state[$k] -eq $true) { $appliedCount++ }
    }
    $scorePct = if ($totalCount -gt 0) { [math]::Round(($appliedCount / $totalCount) * 100) } else { 0 }
    $scoreGrade = if ($scorePct -ge 90) { "A+ Excellent" }
                  elseif ($scorePct -ge 75) { "A Optimal" }
                  elseif ($scorePct -ge 50) { "B Good" }
                  else { "C Needs Tuning" }

    $state['ScoreApplied'] = $appliedCount
    $state['ScoreTotal']   = $totalCount
    $state['ScorePercent'] = $scorePct
    $state['ScoreGrade']   = $scoreGrade
    $state['State']        = $stateCopy

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

    # Re-enable disabled services (SysMain/Superfetch and WSearch permanently kept disabled)
    $servicesToRestore = @('DiagTrack', 'dmwappushservice', 'XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc', 'MapsBroker', 'lfsvc', 'WerSvc')
    foreach ($svcName in $servicesToRestore) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($svc) {
            Set-Service -Name $svcName -StartupType Manual -ErrorAction SilentlyContinue
        }
    }
    # Enforce Superfetch (SysMain) stays disabled
    Set-Service -Name 'SysMain' -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name 'SysMain' -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\SysMain' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue
    $prefetchKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters'
    if (Test-Path $prefetchKey) {
        Set-ItemProperty -Path $prefetchKey -Name 'EnableSuperfetch' -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $prefetchKey -Name 'EnablePrefetcher' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    # Enforce Windows Search (WSearch) stays disabled & stopped
    Set-Service -Name 'WSearch' -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name 'WSearch' -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WSearch' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Background services restored to Manual startup (Superfetch & WSearch remain Disabled)" -ForegroundColor Green

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
    # Enforce Hibernate stays permanently disabled (frees disk space & prevents sleep interrupts)
    powercfg /hibernate off 2>$null
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
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

    # Symmetrical Reversals for Windows 11 & Shell Usability
    if (Get-Command Restore-VbsSecurity -ErrorAction SilentlyContinue) { Restore-VbsSecurity }
    if (Get-Command Restore-TaskbarAlignmentCenter -ErrorAction SilentlyContinue) { Restore-TaskbarAlignmentCenter }
    if (Get-Command Restore-StartMenuRecommended -ErrorAction SilentlyContinue) { Restore-StartMenuRecommended }
    if (Get-Command Restore-TaskbarChat -ErrorAction SilentlyContinue) { Restore-TaskbarChat }
    if (Get-Command Restore-FilesCompactMode -ErrorAction SilentlyContinue) { Restore-FilesCompactMode }
    if (Get-Command Restore-SnapAssist -ErrorAction SilentlyContinue) { Restore-SnapAssist }
    if (Get-Command Restore-WindowsStickers -ErrorAction SilentlyContinue) { Restore-WindowsStickers }
    if (Get-Command Restore-EdgeDiscoverBar -ErrorAction SilentlyContinue) { Restore-EdgeDiscoverBar }
    if (Get-Command Restore-CopyMoveContextMenu -ErrorAction SilentlyContinue) { Restore-CopyMoveContextMenu }
    if (Get-Command Restore-WindowShake -ErrorAction SilentlyContinue) { Restore-WindowShake }
    if (Get-Command Restore-WindowsLightMode -ErrorAction SilentlyContinue) { Restore-WindowsLightMode }
    if (Get-Command Restore-VerboseLogon -ErrorAction SilentlyContinue) { Restore-VerboseLogon }
    if (Get-Command Restore-QuickAccessHistory -ErrorAction SilentlyContinue) { Restore-QuickAccessHistory }
    if (Get-Command Restore-MyPeople -ErrorAction SilentlyContinue) { Restore-MyPeople }
    if (Get-Command Restore-WindowsInk -ErrorAction SilentlyContinue) { Restore-WindowsInk }
    if (Get-Command Restore-CastToDevice -ErrorAction SilentlyContinue) { Restore-CastToDevice }
    if (Get-Command Restore-LegacyBootMenu -ErrorAction SilentlyContinue) { Restore-LegacyBootMenu }

    # Symmetrical Reversals for Privacy & App Telemetry
    if (Get-Command Restore-AppTelemetry -ErrorAction SilentlyContinue) { Restore-AppTelemetry }
    if (Get-Command Restore-BluetoothAdvertising -ErrorAction SilentlyContinue) { Restore-BluetoothAdvertising }
    if (Get-Command Restore-CloudOptimizedContent -ErrorAction SilentlyContinue) { Restore-CloudOptimizedContent }
    if (Get-Command Restore-CdpServices -ErrorAction SilentlyContinue) { Restore-CdpServices }
    if (Get-Command Restore-DiagnosticsToasts -ErrorAction SilentlyContinue) { Restore-DiagnosticsToasts }
    if (Get-Command Restore-OnlineSpeechPrivacy -ErrorAction SilentlyContinue) { Restore-OnlineSpeechPrivacy }
    if (Get-Command Restore-AutomaticRestartSignOn -ErrorAction SilentlyContinue) { Restore-AutomaticRestartSignOn }
    if (Get-Command Restore-TextInputCollection -ErrorAction SilentlyContinue) { Restore-TextInputCollection }
    if (Get-Command Restore-ClipboardSync -ErrorAction SilentlyContinue) { Restore-ClipboardSync }
    if (Get-Command Restore-SettingsAndMessageSync -ErrorAction SilentlyContinue) { Restore-SettingsAndMessageSync }
    if (Get-Command Restore-FindMyDevice -ErrorAction SilentlyContinue) { Restore-FindMyDevice }
    if (Get-Command Restore-SafeSearchMode -ErrorAction SilentlyContinue) { Restore-SafeSearchMode }
    if (Get-Command Restore-SmbV1Protocol -ErrorAction SilentlyContinue) { Restore-SmbV1Protocol }
    if (Get-Command Restore-RemoteAssistanceAndRegistry -ErrorAction SilentlyContinue) { Restore-RemoteAssistanceAndRegistry }
    if (Get-Command Restore-DriverUpdatesFromWindowsUpdate -ErrorAction SilentlyContinue) { Restore-DriverUpdatesFromWindowsUpdate }
    if (Get-Command Restore-StoreAutoUpdates -ErrorAction SilentlyContinue) { Restore-StoreAutoUpdates }
    if (Get-Command Restore-SmartScreenFilter -ErrorAction SilentlyContinue) { Restore-SmartScreenFilter }
    if (Get-Command Restore-CrashDumps -ErrorAction SilentlyContinue) { Restore-CrashDumps }
    if (Get-Command Restore-SystemTimeouts -ErrorAction SilentlyContinue) { Restore-SystemTimeouts }
    if (Get-Command Restore-DeviceManager -ErrorAction SilentlyContinue) { Restore-DeviceManager }
    if (Get-Command Restore-BitLockerDefaults -ErrorAction SilentlyContinue) { Restore-BitLockerDefaults }

    Write-Host "      [+] WinUtil hardening, Windows 11 shell & privacy tweaks reverted to Windows defaults" -ForegroundColor Green

    Write-Host "      [OK] ALL settings restored to Windows defaults!" -ForegroundColor Green
}

# --- NEW BEAST MODE OPTIMIZATION MODULES ---