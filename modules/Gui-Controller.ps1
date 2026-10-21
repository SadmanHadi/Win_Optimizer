<#
================================================================================
  PumpkiN's Modular Suite: Desktop WPF GUI Event Controller & Async Engine
  Version 5.6.0 - Windows 11 Fluent + Cyberpunk Architecture
================================================================================
#>

function Start-PumpkiNGui {
    [CmdletBinding()]
    param()

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase

    $targetXaml = if ($script:xamlContent) { $script:xamlContent } else { $xamlContent }
    $stringReader = New-Object System.IO.StringReader($targetXaml)
    $xmlReader = [System.Xml.XmlReader]::Create($stringReader)
    $window = [System.Windows.Markup.XamlReader]::Load($xmlReader)

    # 1. Load Application Brand Logo (.ico / .png)
    $imgLogo = $window.FindName("ImgAppLogo")
    $projectRoot = $null
    if ($Global:OptimizerProjectRoot -and (Test-Path $Global:OptimizerProjectRoot)) {
        $projectRoot = $Global:OptimizerProjectRoot
    } elseif ($PSScriptRoot -and (Test-Path (Split-Path $PSScriptRoot -Parent))) {
        $projectRoot = Split-Path $PSScriptRoot -Parent
    } elseif (Test-Path "E:\Projects\Win_Optimizer") {
        $projectRoot = "E:\Projects\Win_Optimizer"
    } else {
        $projectRoot = (Get-Location).Path
    }

    $logoCandidates = [System.Collections.Generic.List[string]]::new()
    $logoCandidates.Add((Join-Path $projectRoot "LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.ico"))
    $logoCandidates.Add("E:\Projects\Win_Optimizer\LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.ico")
    $logoCandidates.Add((Join-Path (Get-Location) "LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.ico"))
    $logoCandidates.Add((Join-Path $projectRoot "LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.png"))

    $logoLoaded = $false
    foreach ($cand in $logoCandidates) {
        if ($cand -and (Test-Path $cand)) {
            try {
                $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
                $bitmap.BeginInit()
                $bitmap.UriSource = New-Object System.Uri($cand, [System.UriKind]::Absolute)
                $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
                $bitmap.EndInit()
                if ($imgLogo) { $imgLogo.Source = $bitmap }
                $window.Icon = $bitmap
                $logoLoaded = $true
                break
            } catch {}
        }
    }

    # 2. Controls Resolution
    # Top Bar
    $txtSearch           = $window.FindName("TxtSearch")
    $btnClearSearch      = $window.FindName("BtnClearSearch")
    $btnBeastMode        = $window.FindName("BtnBeastMode")
    $btnRestorePointTop  = $window.FindName("BtnRestorePointTop")
    $btnMasActivateTop   = $window.FindName("BtnMasActivateTop")
    $btnExitTop          = $window.FindName("BtnExitTop")

    # Navigation Rail
    $navDashboard        = $window.FindName("NavDashboard")
    $navGaming           = $window.FindName("NavGaming")
    $navPrivacy          = $window.FindName("NavPrivacy")
    $navSystem           = $window.FindName("NavSystem")
    $navSoftware         = $window.FindName("NavSoftware")
    $navDevice           = $window.FindName("NavDevice")

    # Page Containers
    $pageDashboard       = $window.FindName("PageDashboard")
    $pageGaming          = $window.FindName("PageGaming")
    $pagePrivacy         = $window.FindName("PagePrivacy")
    $pageSystem          = $window.FindName("PageSystem")
    $pageSoftware        = $window.FindName("PageSoftware")
    $pageDevice          = $window.FindName("PageDevice")

    # Top Bar Controls
    $btnRestorePointTop        = $window.FindName("BtnRestorePointTop")
    $btnMasActivateTop         = $window.FindName("BtnMasActivateTop")
    $btnBeastMode              = $window.FindName("BtnBeastMode")
    $btnExitTop                = $window.FindName("BtnExitTop")

    # Tweak Scrollable Panels
    $panelGamingTweaks   = $window.FindName("PanelGamingTweaks")
    $panelPrivacyTweaks  = $window.FindName("PanelPrivacyTweaks")
    $panelSystemTweaks   = $window.FindName("PanelSystemTweaks")

    # Dashboard Controls
    $borderScoreGauge          = $window.FindName("BorderScoreGauge")
    $txtScorePercent           = $window.FindName("TxtScorePercent")
    $txtScoreGrade             = $window.FindName("TxtScoreGrade")
    $txtActiveTweakRatio       = $window.FindName("TxtActiveTweakRatio")
    $txtScoreSubtitle          = $window.FindName("TxtScoreSubtitle")
    $btnScanSystemStateBanner  = $window.FindName("BtnScanSystemStateBanner")
    $btnRevertDefaults         = $window.FindName("BtnRevertDefaults")
    $txtLiveCpu                = $window.FindName("TxtLiveCpu")
    $txtLiveRam                = $window.FindName("TxtLiveRam")
    $txtLivePing               = $window.FindName("TxtLivePing")
    $txtLiveBooster            = $window.FindName("TxtLiveBooster")
    $btnStartGameBooster       = $window.FindName("BtnStartGameBooster")
    $btnPurgeStandby           = $window.FindName("BtnPurgeStandby")
    $txtActiveGamingCount      = $window.FindName("TxtActiveGamingCount")
    $txtActivePrivacyCount     = $window.FindName("TxtActivePrivacyCount")
    $txtActiveSystemCount      = $window.FindName("TxtActiveSystemCount")
    $btnViewActiveTweaks       = $window.FindName("BtnViewActiveTweaks")
    $btnApplyUnappliedDashboard = $window.FindName("BtnApplyUnappliedDashboard")
    $btnApplyProfileEsports    = $window.FindName("BtnApplyProfileEsports")
    $btnApplyProfileRecommended = $window.FindName("BtnApplyProfileRecommended")
    $btnApplyProfilePrivacy    = $window.FindName("BtnApplyProfilePrivacy")

    # Gaming Page Master Controls & Tools
    $chipGamingAll           = $window.FindName("ChipGamingAll")
    $chipGamingRecommended   = $window.FindName("ChipGamingRecommended")
    $chipGamingEsports       = $window.FindName("ChipGamingEsports")
    $chipGamingActive        = $window.FindName("ChipGamingActive")
    $btnGamingApplyAll       = $window.FindName("BtnGamingApplyAll")
    $btnGamingRollbackAll    = $window.FindName("BtnGamingRollbackAll")
    $cmbCursorSchemes        = $window.FindName("CmbCursorSchemes")
    $txtActiveCursorScheme   = $window.FindName("TxtActiveCursorScheme")
    $btnInstallCursor        = $window.FindName("BtnInstallCursor")
    $btnRestoreCursor        = $window.FindName("BtnRestoreCursor")
    $btnBenchmarkDns         = $window.FindName("BtnBenchmarkDns")
    $btnResetDns             = $window.FindName("BtnResetDns")

    # Privacy Page Master Controls
    $chipPrivacyAll          = $window.FindName("ChipPrivacyAll")
    $chipPrivacyActive       = $window.FindName("ChipPrivacyActive")
    $btnPrivacyApplyAll      = $window.FindName("BtnPrivacyApplyAll")
    $btnPrivacyRollbackAll   = $window.FindName("BtnPrivacyRollbackAll")

    # System Page Master Controls & Diagnostics
    $chipSystemAll           = $window.FindName("ChipSystemAll")
    $chipSystemActive        = $window.FindName("ChipSystemActive")
    $btnSystemApplyAll       = $window.FindName("BtnSystemApplyAll")
    $btnSystemRollbackAll    = $window.FindName("BtnSystemRollbackAll")
    $btnRunDiagnostics       = $window.FindName("BtnRunDiagnostics")
    $btnClearUpdateCache     = $window.FindName("BtnClearUpdateCache")
    $btnClearDeepCacheBar    = $window.FindName("BtnClearDeepCacheBar")
    $btnReport_Interrupts    = $window.FindName("BtnReport_Interrupts")

    # Device Page Header Controls
    $txtDev_CompName         = $window.FindName("TxtDev_CompName")
    $txtDev_SubTitle         = $window.FindName("TxtDev_SubTitle")
    $btnRefreshDeviceSpecs   = $window.FindName("BtnRefreshDeviceSpecs")
    $btnCopyAllDeviceSpecs   = $window.FindName("BtnCopyAllDeviceSpecs")

    # Software Downloader Controls
    $wrapPackages            = $window.FindName("WrapPackages")
    $btnInstallSelected      = $window.FindName("BtnInstallSelected")
    $btnUninstallSelected    = $window.FindName("BtnUninstallSelected")
    $btnUpgradeAll           = $window.FindName("BtnUpgradeAll")
    $btnSelectAll            = $window.FindName("BtnSelectAll")
    $btnClearAll             = $window.FindName("BtnClearAll")
    $txtSelectedCount        = $window.FindName("TxtSelectedCount")
    $btnInstallEquicord      = $window.FindName("BtnInstallEquicord")
    $btnOpenEquicordSite     = $window.FindName("BtnOpenEquicordSite")

    # Bottom Activity / Drawer Controls
    $btnToggleLogDrawer      = $window.FindName("BtnToggleLogDrawer")
    $panelLogDrawer          = $window.FindName("PanelLogDrawer")
    $txtConsole              = $window.FindName("TxtConsole")
    $txtStatus               = $window.FindName("TxtStatus")
    $progressBar             = $window.FindName("MainProgressBar")
    $btnClearConsole         = $window.FindName("BtnClearConsole")

    # Thread-Safe UI Pumping and Logging
    $script:DoEvents = {
        $frame = New-Object System.Windows.Threading.DispatcherFrame
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
            [System.Windows.Threading.DispatcherPriority]::Background,
            [Action[System.Windows.Threading.DispatcherFrame]]{ param($f) $f.Continue = $false },
            $frame
        ) | Out-Null
        [System.Windows.Threading.Dispatcher]::PushFrame($frame)
    }

    $script:LogToGui = {
        param([string]$Message, [string]$Level = "INFO")
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $line = "[$timestamp] $Message`r`n"
        $window.Dispatcher.Invoke([Action]{
            if ($txtConsole) {
                $txtConsole.AppendText($line)
                $txtConsole.ScrollToEnd()
            }
            if ($txtStatus) {
                $txtStatus.Text = $Message
            }
        })
        & $script:DoEvents
    }

    $script:SetProgress = {
        param([int]$Percent)
        $window.Dispatcher.Invoke([Action]{
            if ($progressBar) {
                $progressBar.Value = $Percent
            }
        })
        & $script:DoEvents
    }

    if ($btnClearConsole) {
        $btnClearConsole.Add_Click({
            if ($txtConsole) { $txtConsole.Clear() }
            if ($txtStatus) { $txtStatus.Text = "Log cleared" }
        })
    }

    # 3. Collapsible Log Drawer Toggle Handler
    $script:ExpandLogDrawer = {
        if ($panelLogDrawer -and $panelLogDrawer.Visibility -ne [System.Windows.Visibility]::Visible) {
            $panelLogDrawer.Visibility = [System.Windows.Visibility]::Visible
            if ($btnToggleLogDrawer) { $btnToggleLogDrawer.Content = "v Hide Console" }
        }
    }

    if ($btnToggleLogDrawer) {
        $btnToggleLogDrawer.Add_Click({
            if ($panelLogDrawer.Visibility -eq [System.Windows.Visibility]::Visible) {
                $panelLogDrawer.Visibility = [System.Windows.Visibility]::Collapsed
                $btnToggleLogDrawer.Content = "^ Show Console"
            } else {
                $panelLogDrawer.Visibility = [System.Windows.Visibility]::Visible
                $btnToggleLogDrawer.Content = "v Hide Console"
            }
        })
    }

    # 4. Master Navigation Switching
    $pages = @($pageDashboard, $pageGaming, $pagePrivacy, $pageSystem, $pageSoftware, $pageDevice)
    $script:SwitchPage = {
        param([System.Windows.Controls.Grid]$TargetPage)
        foreach ($p in $pages) {
            if ($p) {
                $p.Visibility = if ($p -eq $TargetPage) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
            }
        }
    }

    if ($navDashboard) { $navDashboard.Add_Checked({ & $script:SwitchPage $pageDashboard }) }
    if ($navGaming)    { $navGaming.Add_Checked({ & $script:SwitchPage $pageGaming }) }
    if ($navPrivacy)   { $navPrivacy.Add_Checked({ & $script:SwitchPage $pagePrivacy }) }
    if ($navSystem)    { $navSystem.Add_Checked({ & $script:SwitchPage $pageSystem }) }
    if ($navSoftware)  { $navSoftware.Add_Checked({ & $script:SwitchPage $pageSoftware }) }
    if ($navDevice)    { $navDevice.Add_Checked({ & $script:SwitchPage $pageDevice }) }

    # 5. Master Tweak Definitions Registry (Unified Schema for all 82 Tweaks)
    $script:TweakDefinitions = @(
        # --- GAMING & HARDWARE PERFORMANCE ---
        @{ Key="GpuAuto"; Title="GPU Driver Auto-Tuning"; Category="Gaming"; Tier="Recommended"; Description="Auto-optimizes NVIDIA and AMD display driver registry settings for maximum sustained frame rates."; Apply={ Optimize-GpuAuto }; Rollback={ Restore-GpuAuto } },
        @{ Key="HardwareMsi"; Title="Hardware MSI Mode"; Category="Gaming"; Tier="Recommended"; Description="Switches GPU, USB, and network adapters to Message Signaled Interrupts (MSI) for lowest DPC latency."; Apply={ Optimize-HardwareMsiMode }; Rollback={ Restore-HardwareMsiMode } },
        @{ Key="DisablePowerSaving"; Title="Disable USB Power Savings"; Category="Gaming"; Tier="Safe"; Description="Prevents Windows from suspending USB root hubs and network controllers during competitive gaming."; Apply={ Disable-DevicePowerSaving }; Rollback={ Restore-DevicePowerSaving } },
        @{ Key="Mpo"; Title="Disable Multiplane Overlay (MPO)"; Category="Gaming"; Tier="Recommended"; Description="Disables Desktop Window Manager MPO to permanently eliminate micro-stuttering and black screens."; Apply={ Disable-MultiplaneOverlay }; Rollback={ Restore-MultiplaneOverlay } },
        @{ Key="MouseCurve"; Title="1:1 Raw Mouse Linear Curve"; Category="Gaming"; Tier="Recommended"; Description="Enforces perfectly linear 1:1 hardware mouse sensitivity with zero angle snapping or smoothing."; Apply={ Set-MouseLinearCurve }; Rollback={ Restore-MouseLinearCurve } },
        @{ Key="InputLatency"; Title="8000Hz USB Keyboard Response"; Category="Gaming"; Tier="Esports"; Description="Optimizes USB polling buffers and keyboard response rate to lowest possible physical latency."; Apply={ Optimize-LatencyAndInput }; Rollback={ Restore-AudioDpcAndUsbLatency } },
        @{ Key="CsrssPriority"; Title="CSRSS Realtime I/O Priority"; Category="Gaming"; Tier="Esports"; Description="Elevates Client Server Runtime Subsystem to High/Realtime priority for instant input processing."; Apply={ Optimize-CsrssPriority }; Rollback={ Restore-CsrssPriority } },
        @{ Key="CpuSystem"; Title="Win32PrioritySeparation Quantum (0x26)"; Category="Gaming"; Tier="Recommended"; Description="Sets kernel scheduler quantum to 0x26, granting active foreground games priority CPU slices."; Apply={ Optimize-CpuAndSystem }; Rollback={ Restore-CpuAndSystem } },
        @{ Key="SvcHost"; Title="SvcHost RAM Thread Splitting"; Category="Gaming"; Tier="Recommended"; Description="Isolates background service hosts to prevent shared memory contention and micro-stutter."; Apply={ Optimize-SvcHostSplitting }; Rollback={ Restore-SvcHostSplitting } },
        @{ Key="Network"; Title="TCP/IP Low-Latency Anti-Lag Stack"; Category="Gaming"; Tier="Recommended"; Description="Optimizes TCP autotuning, non-best-effort QoS limits, and disables Nagle latency batching."; Apply={ Optimize-Network }; Rollback={ Restore-Network } },
        @{ Key="WifiScan"; Title="Wi-Fi 0ms Roaming Ping Shield"; Category="Gaming"; Tier="Esports"; Description="Freezes Windows background 60s Wi-Fi network roaming scans to eliminate ping spikes."; Apply={ Toggle-WifiAutoconfig }; Rollback={ Toggle-WifiAutoconfig } },
        @{ Key="StartupDns"; Title="Gaming DNS & Fast Startup Tuning"; Category="Gaming"; Tier="Safe"; Description="Prioritizes local DNS resolver threads and optimizes network startup negotiation."; Apply={ Optimize-StartupAndDns }; Rollback={ Reset-DnsToAutomatic } },
        @{ Key="GameHooks"; Title="Esports Process Priority Hooks"; Category="Gaming"; Tier="Esports"; Description="Configures High CPU Priority and MMIO execution for CS2, Valorant, Apex, and Fortnite."; Apply={ Apply-GameHooks }; Rollback={ Restore-GameHooks } },
        @{ Key="UltimatePower"; Title="PumpkiN Ultimate Power Plan"; Category="Gaming"; Tier="Recommended"; Description="Unlocks and activates the Ultimate Performance energy scheme with zero CPU clock throttling."; Apply={ Invoke-PumpkiNEsportsPowerPlan }; Rollback={ Restore-BalancedPowerPlan } },
        @{ Key="CoreUnpark"; Title="100% CPU Core Unparking"; Category="Gaming"; Tier="Recommended"; Description="Unparks all physical and logical CPU cores so all threads respond immediately to game loads."; Apply={ Invoke-CpuCoreUnparking }; Rollback={ Restore-CpuCoreParking } },
        @{ Key="StripVisual"; Title="Strip Desktop Visual Animations"; Category="Gaming"; Tier="Safe"; Description="Disables unnecessary window drop shadows, fade animations, and cursor effects for peak responsiveness."; Apply={ Strip-VisualEffects }; Rollback={ Restore-VisualEffects } },
        @{ Key="EndTask"; Title="Taskbar 'End Task' Right-Click"; Category="Gaming"; Tier="Recommended"; Description="Enables instant process termination directly from the Windows taskbar context menu."; Apply={ Enable-EndTaskRightClick }; Rollback={ Restore-EndTaskRightClick } },
        @{ Key="StickyKeys"; Title="Disable Sticky Keys Prompt"; Category="Gaming"; Tier="Safe"; Description="Suppresses the Windows accessibility dialog when pressing Shift 5 times in rapid succession."; Apply={ Disable-StickyKeysPrompt }; Rollback={ Restore-StickyKeysPrompt } },
        @{ Key="CompactMetrics"; Title="Compact Window Metrics"; Category="Gaming"; Tier="Safe"; Description="Narrows desktop window padding and title bars for a modern, sleek desktop aesthetic."; Apply={ Set-CompactWindowMetrics }; Rollback={ Restore-CompactWindowMetrics } },
        @{ Key="DebloatServices"; Title="Debloat Background Services"; Category="Gaming"; Tier="Recommended"; Description="Gracefully disables non-essential background services (Diagnostics, Fax, Maps, Retail Demo)."; Apply={ Debloat-BackgroundServices }; Rollback={ Restore-BackgroundServices } },
        @{ Key="DiskIo"; Title="Optimize Disk I/O & NTFS"; Category="Gaming"; Tier="Recommended"; Description="Disables 8.3 short filename generation and last-access timestamps for faster disk read/write."; Apply={ Optimize-DiskIO }; Rollback={ Restore-DiskIO } },
        @{ Key="CompactOs"; Title="CompactOS System Compression"; Category="Gaming"; Tier="Safe"; Description="Compresses core OS binaries via native XPRESS/LZX to free up 10-25 GB of NVMe/SSD space."; Apply={ Enable-CompactOS }; Rollback={ Disable-CompactOS } },
        @{ Key="TakeOwnership"; Title="'Take Ownership' Context Menu"; Category="Gaming"; Tier="Safe"; Description="Adds a 1-click Take Ownership menu item to easily manage restricted system files."; Apply={ Enable-TakeOwnershipMenu }; Rollback={ Disable-TakeOwnershipMenu } },
        @{ Key="JunkTasks"; Title="Disable Scheduled Junk Tasks"; Category="Gaming"; Tier="Recommended"; Description="Disables Customer Experience Improvement, CEIP, and background telemetry collection tasks."; Apply={ Disable-ScheduledJunkTasks }; Rollback={ Restore-ScheduledJunkTasks } },
        @{ Key="Privacy"; Title="Harden Core Windows Telemetry"; Category="Gaming"; Tier="Recommended"; Description="Sets AllowTelemetry policy to 0 (Security) and suppresses diagnostic data reporting."; Apply={ Harden-PrivacyTelemetry }; Rollback={ Restore-PrivacyTelemetry } },
        @{ Key="AudioDpc"; Title="Audio DPC & Anti-Popping"; Category="Gaming"; Tier="Recommended"; Description="Elevates Multimedia Class Scheduler (MMCSS) audio thread priority to prevent popping."; Apply={ Optimize-AudioDpcLatency }; Rollback={ Restore-AudioDpcAndUsbLatency } },
        @{ Key="UsbxHci"; Title="USB xHCI Realtime Thread Priority"; Category="Gaming"; Tier="Esports"; Description="Configures USB host controller thread priority to Realtime (31) for zero mouse click latency."; Apply={ Optimize-UsbLatencyAndBuffers }; Rollback={ Restore-AudioDpcAndUsbLatency } },
        @{ Key="DeviceManager"; Title="Device Manager Latency Tuning"; Category="Gaming"; Tier="Recommended"; Description="Disables high-latency legacy devices (HPET, SMBus, System Speaker, Timers) safely."; Apply={ Optimize-DeviceManager }; Rollback={ Restore-DeviceManager } },

        # --- SYSTEM, SHELL & HARDENING ---
        @{ Key="BlockWpbt"; Title="Block UEFI WPBT Execution"; Category="System"; Tier="Safe"; Description="Blocks manufacturer-injected rootkit bloatware from executing out of motherboard ACPI tables."; Apply={ Block-WpbtExecution }; Rollback={ Restore-WpbtExecution } },
        @{ Key="BlockPeripheral"; Title="Block Peripheral Software Bloat"; Category="System"; Tier="Safe"; Description="Prevents Windows from automatically downloading OEM bloatware apps when connecting hardware."; Apply={ Block-PeripheralBloat }; Rollback={ Restore-PeripheralBloat } },
        @{ Key="RemoveAi"; Title="Purge Windows AI & Recall"; Category="System"; Tier="Recommended"; Description="Removes Copilot, Recall snapshots, and background AI telemetry processors."; Apply={ Remove-WindowsAI }; Rollback={ Restore-WindowsAI } },
        @{ Key="SecurityUpdatesOnly"; Title="Security-Only Update Policy"; Category="System"; Tier="Safe"; Description="Configures Windows Update to only deliver essential security patches without unwanted feature rollouts."; Apply={ Set-SecurityUpdatesOnly }; Rollback={ Restore-SecurityUpdatesOnly } },
        @{ Key="ClassicContext"; Title="Classic Windows 10 Context Menu"; Category="System"; Tier="Recommended"; Description="Restores the fast full-featured right-click context menu on Windows 11 without 'Show more options'."; Apply={ Enable-ClassicContextMenu }; Rollback={ Restore-ClassicContextMenu } },
        @{ Key="DisableBing"; Title="Disable Start Menu Web Search"; Category="System"; Tier="Recommended"; Description="Prevents Start Menu searches from querying Bing and displaying web advertisements."; Apply={ Disable-StartMenuBing }; Rollback={ Restore-StartMenuBing } },
        @{ Key="DisableAutoDiscovery"; Title="Disable Network Auto-Discovery"; Category="System"; Tier="Safe"; Description="Stops Explorer from constantly scanning local network subnets for devices, speeding up folder loads."; Apply={ Disable-ExplorerAutoDiscovery }; Rollback={ Restore-ExplorerAutoDiscovery } },
        @{ Key="ShowExtensions"; Title="Show File Extensions & Hidden Files"; Category="System"; Tier="Recommended"; Description="Configures File Explorer to always show file extensions and hidden items for security."; Apply={ Set-ShowFileExtensionsAndHidden }; Rollback={ Restore-ShowFileExtensionsAndHidden } },
        @{ Key="DisableAds"; Title="Disable Windows Desktop Ads"; Category="System"; Tier="Recommended"; Description="Removes suggested apps, tip notifications, and promotional banners across the shell."; Apply={ Disable-WindowsAds }; Rollback={ Enable-WindowsAds } },
        @{ Key="NoShortcutArrows"; Title="Remove Shortcut Arrow Overlays"; Category="System"; Tier="Safe"; Description="Removes the default arrow icon overlay from desktop application shortcuts."; Apply={ Disable-ShortcutArrow }; Rollback={ Restore-ShortcutArrow } },
        @{ Key="EnableLongPaths"; Title="Enable Win32 Long Paths (MAX_PATH)"; Category="System"; Tier="Recommended"; Description="Removes the 260-character path limit for file paths, preventing filesystem errors."; Apply={ Enable-LongPaths }; Rollback={ Restore-LongPaths } },
        @{ Key="DisableLockScreen"; Title="Disable Windows Lock Screen"; Category="System"; Tier="Safe"; Description="Bypasses the swipe-up lock screen image and displays the password prompt immediately."; Apply={ Disable-LockScreen }; Rollback={ Restore-LockScreen } },
        @{ Key="BsodVerbose"; Title="Verbose Crash Screen (BSOD)"; Category="System"; Tier="Safe"; Description="Configures Windows to display detailed stop codes and faulting driver names on crash."; Apply={ Enable-BsodVerbose }; Rollback={ Restore-BsodVerbose } },
        @{ Key="DisableReservedStorage"; Title="Reclaim 7GB Reserved Storage"; Category="System"; Tier="Recommended"; Description="Disables Windows Reserved Storage partition, instantly freeing 7 GB on the C: drive."; Apply={ Disable-ReservedStorage }; Rollback={ Restore-ReservedStorage } },
        @{ Key="BitLocker"; Title="Turn Off BitLocker Encryption"; Category="System"; Tier="Esports"; Description="Permanently disables BitLocker drive encryption for maximum NVMe disk I/O throughput."; Apply={ Disable-BitLockerPermanently }; Rollback={ Restore-BitLockerDefaults } },
        @{ Key="VbsSecurity"; Title="Disable VBS / HVCI Security"; Category="System"; Tier="Esports"; Description="Disables Virtualization-Based Security (VBS) and Memory Integrity for 5-15% higher gaming FPS."; Apply={ Disable-VbsSecurity }; Rollback={ Restore-VbsSecurity } },
        @{ Key="TaskbarLeft"; Title="Align Taskbar to Left"; Category="System"; Tier="Safe"; Description="Aligns the Windows 11 taskbar icons to the bottom-left corner like classic Windows."; Apply={ Set-TaskbarLeftAlign }; Rollback={ Restore-TaskbarAlignmentCenter } },
        @{ Key="RecommendedStart"; Title="Hide Start Menu 'Recommended'"; Category="System"; Tier="Recommended"; Description="Hides the recommended files section from the Windows 11 Start menu for a cleaner layout."; Apply={ Disable-RecommendedStartSection }; Rollback={ Restore-StartMenuRecommended } },
        @{ Key="TaskbarChat"; Title="Disable Taskbar Chat / Teams"; Category="System"; Tier="Recommended"; Description="Removes the Microsoft Teams Chat widget from the Windows 11 taskbar."; Apply={ Disable-TaskbarChat }; Rollback={ Restore-TaskbarChat } },
        @{ Key="FilesCompact"; Title="File Explorer Compact Mode"; Category="System"; Tier="Safe"; Description="Reduces row padding in File Explorer to show more files per folder view."; Apply={ Enable-FilesCompactMode }; Rollback={ Restore-FilesCompactMode } },
        @{ Key="SnapAssist"; Title="Disable Snap Assist Suggestion"; Category="System"; Tier="Safe"; Description="Suppresses auto-suggested candidate windows when snapping an application to the screen edge."; Apply={ Disable-SnapAssist }; Rollback={ Restore-SnapAssist } },
        @{ Key="WindowsStickers"; Title="Disable Desktop Stickers"; Category="System"; Tier="Safe"; Description="Disables the Windows 11 desktop sticker drawing integration."; Apply={ Disable-DesktopStickers }; Rollback={ Restore-WindowsStickers } },
        @{ Key="EdgeDiscover"; Title="Disable Edge Discover Bing Bar"; Category="System"; Tier="Recommended"; Description="Removes the Bing Discover sidebar button from Microsoft Edge."; Apply={ Disable-EdgeDiscoverBar }; Rollback={ Restore-EdgeDiscoverBar } },
        @{ Key="CopyMoveMenu"; Title="Add 'Copy To' & 'Move To' to Menu"; Category="System"; Tier="Safe"; Description="Adds convenient Copy To Folder and Move To Folder options to Explorer right-click."; Apply={ Enable-CopyMoveToContextMenu }; Rollback={ Restore-CopyMoveContextMenu } },
        @{ Key="WindowShake"; Title="Disable Aero Shake Window Minimizing"; Category="System"; Tier="Safe"; Description="Prevents shaking a window title bar from minimizing all other open background windows."; Apply={ Disable-WindowShake }; Rollback={ Restore-WindowShake } },
        @{ Key="SystemDarkMode"; Title="System-Wide Dark Mode"; Category="System"; Tier="Recommended"; Description="Enforces sleek dark mode across Windows shell, system dialogs, and applications."; Apply={ Enable-SystemDarkMode }; Rollback={ Restore-WindowsLightMode } },
        @{ Key="VerboseLogon"; Title="Enable Verbose Startup Messages"; Category="System"; Tier="Safe"; Description="Displays step-by-step diagnostic messages (Applying policies, Loading services) during boot."; Apply={ Enable-VerboseLogon }; Rollback={ Restore-VerboseLogon } },
        @{ Key="QuickAccessHistory"; Title="Disable Quick Access Recent Files"; Category="System"; Tier="Safe"; Description="Stops File Explorer from recording and displaying recently opened files and frequent folders."; Apply={ Disable-QuickAccessHistory }; Rollback={ Restore-QuickAccessHistory } },
        @{ Key="MyPeople"; Title="Disable My People Taskbar Band"; Category="System"; Tier="Safe"; Description="Removes the legacy My People contacts integration from the Windows taskbar."; Apply={ Disable-MyPeople }; Rollback={ Restore-MyPeople } },
        @{ Key="WindowsInk"; Title="Disable Windows Ink Workspace"; Category="System"; Tier="Safe"; Description="Disables stylus and pen workspace overlays to conserve background system memory."; Apply={ Disable-WindowsInk }; Rollback={ Restore-WindowsInk } },
        @{ Key="CastToDevice"; Title="Disable 'Cast to Device' Menu"; Category="System"; Tier="Safe"; Description="Removes Cast to Device from the right-click menu of media files."; Apply={ Disable-CastToDevice }; Rollback={ Restore-CastToDevice } },

        # --- PRIVACY & TELEMETRY ---
        @{ Key="AppTelemetry"; Title="Disable 3rd-Party App Telemetry"; Category="Privacy"; Tier="Recommended"; Description="Suppresses telemetry daemons for Chrome, Firefox, Edge, Visual Studio, and NVIDIA drivers."; Apply={ Disable-ThirdPartyAppTelemetry }; Rollback={ Restore-AppTelemetry } },
        @{ Key="BluetoothAdvertising"; Title="Disable Bluetooth Advertising"; Category="Privacy"; Tier="Recommended"; Description="Blocks Windows from broadcasting Bluetooth discovery beacons to nearby receivers."; Apply={ Disable-BluetoothAdvertising }; Rollback={ Restore-BluetoothAdvertising } },
        @{ Key="CloudContent"; Title="Disable Cloud Optimized Content"; Category="Privacy"; Tier="Recommended"; Description="Prevents Windows from fetching dynamic cloud content and recommendations from Microsoft."; Apply={ Disable-CloudOptimizedContent }; Rollback={ Restore-CloudOptimizedContent } },
        @{ Key="CdpServices"; Title="Disable CDP Connected Devices Service"; Category="Privacy"; Tier="Recommended"; Description="Disables Connected Devices Platform User Service to prevent cross-device activity syncing."; Apply={ Disable-CdpUserServices }; Rollback={ Restore-CdpServices } },
        @{ Key="DiagnosticsToasts"; Title="Disable Feedback & Survey Toasts"; Category="Privacy"; Tier="Recommended"; Description="Stops Windows from displaying feedback surveys and diagnostic pop-up prompts."; Apply={ Disable-DiagnosticsToasts }; Rollback={ Restore-DiagnosticsToasts } },
        @{ Key="OnlineSpeech"; Title="Disable Online Speech Recognition"; Category="Privacy"; Tier="Recommended"; Description="Prevents voice recordings from being transmitted to Microsoft cloud servers for analysis."; Apply={ Disable-OnlineSpeechPrivacy }; Rollback={ Restore-OnlineSpeechPrivacy } },
        @{ Key="Arso"; Title="Disable Auto-Restart Apps on Reboot"; Category="Privacy"; Tier="Safe"; Description="Prevents open desktop applications from automatically launching and logging in after reboot."; Apply={ Disable-RestartAppsAfterReboot }; Rollback={ Restore-AutomaticRestartSignOn } },
        @{ Key="TextInputCollection"; Title="Disable Inking & Typing Collection"; Category="Privacy"; Tier="Recommended"; Description="Prevents Windows from recording keystrokes and handwriting to build a dictionary profile."; Apply={ Disable-HandwritingTypingCollection }; Rollback={ Restore-TextInputCollection } },
        @{ Key="ClipboardSync"; Title="Disable Clipboard Cloud Sync"; Category="Privacy"; Tier="Safe"; Description="Prevents copied text, tokens, and passwords from synchronizing across devices via cloud."; Apply={ Disable-ClipboardCloudSync }; Rollback={ Restore-ClipboardSync } },
        @{ Key="SettingsMessageSync"; Title="Disable Settings & Message Sync"; Category="Privacy"; Tier="Safe"; Description="Suppresses automatic synchronization of Windows preferences and account metadata."; Apply={ Disable-SettingsAndMessageSync }; Rollback={ Restore-SettingsAndMessageSync } },
        @{ Key="FindMyDevice"; Title="Disable 'Find My Device' Tracking"; Category="Privacy"; Tier="Safe"; Description="Disables periodic background GPS location beacons sent to Microsoft account servers."; Apply={ Disable-FindMyDevice }; Rollback={ Restore-FindMyDevice } },
        @{ Key="SafeSearch"; Title="Disable SafeSearch Filtering Telemetry"; Category="Privacy"; Tier="Safe"; Description="Disables Windows search query telemetry filtering through Microsoft servers."; Apply={ Disable-SafeSearchFiltering }; Rollback={ Restore-SafeSearchMode } },
        @{ Key="RemoteAssistanceRegistry"; Title="Disable Remote Assistance & Registry"; Category="Privacy"; Tier="Recommended"; Description="Blocks unsolicited incoming Remote Assistance connections and Remote Registry service."; Apply={ Disable-RemoteAssistanceAndRegistry }; Rollback={ Restore-RemoteAssistanceAndRegistry } },
        @{ Key="DriverUpdatesExcluded"; Title="Exclude Drivers in Windows Update"; Category="Privacy"; Tier="Safe"; Description="Prevents Windows Update from overwriting custom or tuned GPU and audio drivers."; Apply={ Exclude-DriverUpdatesInWindowsUpdate }; Rollback={ Restore-DriverUpdatesFromWindowsUpdate } },
        @{ Key="StoreAutoUpdates"; Title="Disable Store App Auto-Updates"; Category="Privacy"; Tier="Safe"; Description="Stops Microsoft Store apps from downloading bandwidth-heavy background updates during games."; Apply={ Disable-WindowsStoreAutoUpdates }; Rollback={ Restore-StoreAutoUpdates } },
        @{ Key="SmartScreen"; Title="Disable SmartScreen Telemetry Filter"; Category="Privacy"; Tier="Safe"; Description="Prevents hash reporting of downloaded executables back to Microsoft verification servers."; Apply={ Disable-SmartScreenProtection }; Rollback={ Restore-SmartScreenFilter } },
        @{ Key="CrashDumps"; Title="Disable System Crash Dumps"; Category="Privacy"; Tier="Safe"; Description="Suppresses generation of large memory crash dump files on disk after system errors."; Apply={ Disable-SystemCrashDumps }; Rollback={ Restore-CrashDumps } },
        @{ Key="SystemTimeouts"; Title="Optimize Service Shutdown Timeouts"; Category="Privacy"; Tier="Recommended"; Description="Reduces WaitToKillServiceTimeout from 5000ms to 2000ms for near-instant system shutdown."; Apply={ Optimize-SystemTimeouts }; Rollback={ Restore-SystemTimeouts } }
    )

    # 6. Dynamic Card Factory & Fast Object Builders
    $toggleStyle = $window.FindResource("FluentToggleSwitch")
    $brushCardBg     = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#121824")
    $brushCardBorder = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1F293D")
    $brushWhite      = [System.Windows.Media.Brushes]::White
    $brushTextDim    = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
    $brushBadgeBg    = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#182233")
    $brushBadgeBdr   = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2C3B52")
    $brushTierRec    = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88")
    $brushTierEsp    = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FF7700")
    $brushTierSafe   = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00D2FF")

    function New-TweakCardElement {
        param(
            [hashtable]$Tweak,
            [hashtable]$AuditState
        )

        $card = [System.Windows.Controls.Border]::new()
        $card.Background = $brushCardBg
        $card.BorderBrush = $brushCardBorder
        $card.BorderThickness = [System.Windows.Thickness]::new(1)
        $card.CornerRadius = [System.Windows.CornerRadius]::new(6)
        $card.Padding = [System.Windows.Thickness]::new(14, 10, 14, 10)
        $card.Margin = [System.Windows.Thickness]::new(0, 0, 0, 6)
        $card.Tag = $Tweak

        $grid = [System.Windows.Controls.Grid]::new()
        $col0 = [System.Windows.Controls.ColumnDefinition]::new()
        $col0.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
        $col1 = [System.Windows.Controls.ColumnDefinition]::new()
        $col1.Width = [System.Windows.GridLength]::Auto
        [void]$grid.ColumnDefinitions.Add($col0)
        [void]$grid.ColumnDefinitions.Add($col1)

        # Left Details Column
        $sp = [System.Windows.Controls.StackPanel]::new()
        $sp.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $sp.Margin = [System.Windows.Thickness]::new(0, 0, 14, 0)

        $headerSp = [System.Windows.Controls.StackPanel]::new()
        $headerSp.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        $txtTitle = [System.Windows.Controls.TextBlock]::new()
        $txtTitle.Text = $Tweak.Title
        $txtTitle.FontSize = 12
        $txtTitle.FontWeight = [System.Windows.FontWeights]::SemiBold
        $txtTitle.Foreground = $brushWhite
        [void]$headerSp.Children.Add($txtTitle)

        # Tier Pill Badge
        $tier = if ($Tweak.Tier) { $Tweak.Tier } else { "Safe" }
        $badgeBorder = [System.Windows.Controls.Border]::new()
        $badgeBorder.Background = $brushBadgeBg
        $badgeBorder.BorderBrush = $brushBadgeBdr
        $badgeBorder.BorderThickness = [System.Windows.Thickness]::new(1)
        $badgeBorder.CornerRadius = [System.Windows.CornerRadius]::new(3)
        $badgeBorder.Padding = [System.Windows.Thickness]::new(6, 1, 6, 1)
        $badgeBorder.Margin = [System.Windows.Thickness]::new(8, 0, 0, 0)
        $badgeBorder.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

        $txtTier = [System.Windows.Controls.TextBlock]::new()
        $txtTier.Text = $tier
        $txtTier.FontSize = 9
        $txtTier.FontWeight = [System.Windows.FontWeights]::Bold
        $txtTier.Foreground = if ($tier -eq "Esports") { $brushTierEsp } elseif ($tier -eq "Recommended") { $brushTierRec } else { $brushTierSafe }
        $badgeBorder.Child = $txtTier
        [void]$headerSp.Children.Add($badgeBorder)
        [void]$sp.Children.Add($headerSp)

        $txtDesc = [System.Windows.Controls.TextBlock]::new()
        $txtDesc.Text = if ($Tweak.Description) { $Tweak.Description } else { "Optimizes Windows system parameters." }
        $txtDesc.FontSize = 11
        $txtDesc.Foreground = $brushTextDim
        $txtDesc.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $txtDesc.Margin = [System.Windows.Thickness]::new(0, 3, 0, 0)
        [void]$sp.Children.Add($txtDesc)

        [System.Windows.Controls.Grid]::SetColumn($sp, 0)
        [void]$grid.Children.Add($sp)

        # Right Column: Fluent Toggle Switch
        $toggle = [System.Windows.Controls.Primitives.ToggleButton]::new()
        if ($toggleStyle) { $toggle.Style = $toggleStyle }
        $toggle.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $toggle.Tag = $Tweak
        $isApplied = ($AuditState.State[$Tweak.Key] -eq $true)
        $toggle.IsChecked = $isApplied

        $Tweak.Toggle = $toggle
        $Tweak.Card   = $card

        # Wire Single-Tweak Toggle Event Handler
        $toggle.Add_Click({
            $tw = $this.Tag
            $shouldApply = ($this.IsChecked -eq $true)
            if ($shouldApply) {
                & $script:LogToGui "[*] Activating $($tw.Title)..."
                try {
                    & $tw.Apply
                    & $script:LogToGui "[+] $($tw.Title) activated successfully."
                    if ($script:UpdateGuiAuditStatus) {
                        & $script:UpdateGuiAuditStatus -ExcludeKey $tw.Key
                    }
                } catch {
                    $this.IsChecked = $false
                    & $script:LogToGui "[-] Failed to activate $($tw.Title): $($_.Exception.Message)" "ERROR"
                }
            } else {
                & $script:LogToGui "[*] Restoring $($tw.Title) to Windows defaults..."
                try {
                    & $tw.Rollback
                    & $script:LogToGui "[+] $($tw.Title) restored to Windows defaults."
                    if ($script:UpdateGuiAuditStatus) {
                        & $script:UpdateGuiAuditStatus -ExcludeKey $tw.Key
                    }
                } catch {
                    $this.IsChecked = $true
                    & $script:LogToGui "[-] Failed to restore $($tw.Title): $($_.Exception.Message)" "ERROR"
                }
            }
        })

        [System.Windows.Controls.Grid]::SetColumn($toggle, 1)
        [void]$grid.Children.Add($toggle)

        $card.Child = $grid
        return $card
    }

    # Initial Live Audit Probe
    $auditInitial = Get-SystemAuditState

    # Build and Inject Cards Dynamically into Categories
    foreach ($tw in $script:TweakDefinitions) {
        $card = New-TweakCardElement -Tweak $tw -AuditState $auditInitial
        if ($tw.Category -eq "Gaming" -and $panelGamingTweaks) {
            [void]$panelGamingTweaks.Children.Add($card)
        } elseif ($tw.Category -eq "Privacy" -and $panelPrivacyTweaks) {
            [void]$panelPrivacyTweaks.Children.Add($card)
        } elseif ($tw.Category -eq "System" -and $panelSystemTweaks) {
            [void]$panelSystemTweaks.Children.Add($card)
        }
    }

    # 7. Live Audit & Score Gauge Synchronizer
    $script:UpdateGuiAuditStatus = {
        param(
            [string]$ExcludeKey = $null,
            [switch]$LogDetails
        )
        try {
            $audit = Get-SystemAuditState
            $scorePct = [int]$audit.ScorePercent
            $scorePctText = "$scorePct%"
            $gradeText    = "$($audit.ScoreGrade)"
            $ratioText    = "Active: $($audit.ScoreApplied) / $($audit.ScoreTotal)"

            $brushGauge = if ($scorePct -ge 80) { [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88") } elseif ($scorePct -ge 50) { [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00D2FF") } else { [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FF7700") }

            if ($txtScorePercent) {
                $txtScorePercent.Text = $scorePctText
                $txtScorePercent.Foreground = $brushGauge
            }
            if ($txtScoreGrade)       { $txtScoreGrade.Text = $gradeText }
            if ($txtActiveTweakRatio) { $txtActiveTweakRatio.Text = $ratioText }
            if ($borderScoreGauge)    { $borderScoreGauge.BorderBrush = $brushGauge }
            if ($progressBar)         { $progressBar.Value = $scorePct }
            if ($txtStatus)           { $txtStatus.Text = "System Audit: $($audit.ScoreApplied)/$($audit.ScoreTotal) Tweaks Active ($scorePctText)" }

            # Calculate active tweaks per category
            $gamingTweaks  = @($script:TweakDefinitions | Where-Object { $_.Category -eq "Gaming" })
            $privacyTweaks = @($script:TweakDefinitions | Where-Object { $_.Category -eq "Privacy" })
            $systemTweaks  = @($script:TweakDefinitions | Where-Object { $_.Category -eq "System" })

            $activeGaming  = @($gamingTweaks  | Where-Object { $audit.State[$_.Key] -eq $true })
            $activePrivacy = @($privacyTweaks | Where-Object { $audit.State[$_.Key] -eq $true })
            $activeSystem  = @($systemTweaks  | Where-Object { $audit.State[$_.Key] -eq $true })

            if ($txtActiveGamingCount)  { $txtActiveGamingCount.Text  = "$($activeGaming.Count) / $($gamingTweaks.Count) Active" }
            if ($txtActivePrivacyCount) { $txtActivePrivacyCount.Text = "$($activePrivacy.Count) / $($privacyTweaks.Count) Active" }
            if ($txtActiveSystemCount)  { $txtActiveSystemCount.Text  = "$($activeSystem.Count) / $($systemTweaks.Count) Active" }

            if ($txtScoreSubtitle) {
                $txtScoreSubtitle.Text = "Active: Gaming ($($activeGaming.Count)/$($gamingTweaks.Count)) | Privacy ($($activePrivacy.Count)/$($privacyTweaks.Count)) | System ($($activeSystem.Count)/$($systemTweaks.Count))  [Score: $scorePctText]"
            }

            foreach ($tw in $script:TweakDefinitions) {
                if ($tw.Toggle) {
                    if ($ExcludeKey -and $tw.Key -eq $ExcludeKey) {
                        continue
                    }
                    $isApplied = ($audit.State[$tw.Key] -eq $true)
                    $tw.Toggle.IsChecked = $isApplied
                }
            }

            if ($LogDetails) {
                & $script:ExpandLogDrawer
                & $script:LogToGui "================================================================================"
                & $script:LogToGui "  [AUDIT] SYSTEM SCAN RESULTS: $($audit.ScoreApplied) / $($audit.ScoreTotal) TWEAKS ACTIVE ($gradeText)"
                & $script:LogToGui "================================================================================"
                & $script:LogToGui "  >>> ACTIVE GAMING & LATENCY TWEAKS ($($activeGaming.Count)/$($gamingTweaks.Count)): "
                foreach ($tw in $activeGaming) {
                    & $script:LogToGui "      [+] $($tw.Title)  --  $($tw.Description)"
                }
                & $script:LogToGui "  >>> ACTIVE PRIVACY & TELEMETRY TWEAKS ($($activePrivacy.Count)/$($privacyTweaks.Count)): "
                foreach ($tw in $activePrivacy) {
                    & $script:LogToGui "      [+] $($tw.Title)  --  $($tw.Description)"
                }
                & $script:LogToGui "  >>> ACTIVE SYSTEM & USABILITY TWEAKS ($($activeSystem.Count)/$($systemTweaks.Count)): "
                foreach ($tw in $activeSystem) {
                    & $script:LogToGui "      [+] $($tw.Title)  --  $($tw.Description)"
                }
                $unapplied = @($script:TweakDefinitions | Where-Object { $audit.State[$_.Key] -ne $true })
                if ($unapplied.Count -gt 0) {
                    & $script:LogToGui "  >>> UNAPPLIED / NEEDED TWEAKS ($($unapplied.Count) Remaining): "
                    foreach ($tw in $unapplied) {
                        & $script:LogToGui "      [-] $($tw.Title) ($($tw.Category))" "WARN"
                    }
                }
                & $script:LogToGui "================================================================================"
            }
        } catch {
            & $script:LogToGui "[-] Audit sync error: $($_.Exception.Message)" "ERROR"
        }
    }

    # Re-Scan Audit Button Handler
    if ($btnScanSystemStateBanner) {
        $btnScanSystemStateBanner.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Re-scanning live Windows registry, policies, and service state..."
            & $script:UpdateGuiAuditStatus -LogDetails
            & $script:LogToGui "[+] System audit re-scan complete."
        })
    }

    # View Active Tweaks Button Handler
    if ($btnViewActiveTweaks) {
        $btnViewActiveTweaks.Add_Click({
            & $script:ExpandLogDrawer
            & $script:UpdateGuiAuditStatus -LogDetails
        })
    }

    # Apply Unapplied on Dashboard
    if ($btnApplyUnappliedDashboard) {
        $btnApplyUnappliedDashboard.Add_Click({
            $audit = Get-SystemAuditState
            $unappliedTweaks = @($script:TweakDefinitions | Where-Object { $audit.State[$_.Key] -ne $true })
            if ($unappliedTweaks.Count -eq 0) {
                & $script:LogToGui "[OK] All tweaks are already active! Optimization score is at 100%."
                return
            }
            & $script:InvokeSequentialTweakAction -Tweaks $unappliedTweaks -Action "Apply"
        })
    }

    # 8. Sequential Step-by-Step Execution Engine
    $script:InvokeSequentialTweakAction = {
        param(
            [array]$Tweaks,
            [string]$Action # "Apply" or "Rollback"
        )

        & $script:ExpandLogDrawer
        $total = $Tweaks.Count
        if ($total -eq 0) {
            & $script:LogToGui "[!] No tweaks selected for this action."
            return
        }

        & $script:LogToGui "=== STARTING SEQUENTIAL $($Action.ToUpper()) ACTION ($total Tweaks) ==="
        for ($i = 0; $i -lt $total; $i++) {
            $tw = $Tweaks[$i]
            $pct = [int]((($i + 1) / $total) * 100)
            & $script:SetProgress $pct

            if ($Action -eq "Apply") {
                & $script:LogToGui "[$($i+1)/$total] Applying $($tw.Title)..."
                try {
                    & $tw.Apply
                    if ($tw.Toggle) { $tw.Toggle.IsChecked = $true }
                    & $script:LogToGui "  [+] $($tw.Title): OK"
                } catch {
                    if ($tw.Toggle) { $tw.Toggle.IsChecked = $false }
                    & $script:LogToGui "  [-] $($tw.Title) FAILED: $($_.Exception.Message)" "ERROR"
                }
            } else {
                & $script:LogToGui "[$($i+1)/$total] Restoring $($tw.Title) to defaults..."
                try {
                    & $tw.Rollback
                    if ($tw.Toggle) { $tw.Toggle.IsChecked = $false }
                    & $script:LogToGui "  [+] $($tw.Title): Restored"
                } catch {
                    if ($tw.Toggle) { $tw.Toggle.IsChecked = $true }
                    & $script:LogToGui "  [-] $($tw.Title) FAILED: $($_.Exception.Message)" "ERROR"
                }
            }
            Start-Sleep -Milliseconds 40
        }

        & $script:SetProgress 100
        Start-Sleep -Milliseconds 200
        & $script:SetProgress 0
        if ($script:UpdateGuiAuditStatus) { & $script:UpdateGuiAuditStatus }
        & $script:LogToGui "=== SEQUENTIAL $($Action.ToUpper()) ACTION COMPLETED! ==="
    }

    # 9. Master Controls & Profile Handlers
    # Profile Buttons on Dashboard
    if ($btnApplyProfileEsports) {
        $btnApplyProfileEsports.Add_Click({
            $esportsTweaks = $script:TweakDefinitions | Where-Object { $_.Tier -eq "Esports" -or ($_.Category -eq "Gaming" -and $_.Tier -eq "Recommended") }
            & $script:InvokeSequentialTweakAction -Tweaks $esportsTweaks -Action "Apply"
        })
    }

    if ($btnApplyProfileRecommended) {
        $btnApplyProfileRecommended.Add_Click({
            $recTweaks = $script:TweakDefinitions | Where-Object { $_.Tier -eq "Recommended" }
            & $script:InvokeSequentialTweakAction -Tweaks $recTweaks -Action "Apply"
        })
    }

    if ($btnApplyProfilePrivacy) {
        $btnApplyProfilePrivacy.Add_Click({
            $privTweaks = $script:TweakDefinitions | Where-Object { $_.Category -eq "Privacy" }
            & $script:InvokeSequentialTweakAction -Tweaks $privTweaks -Action "Apply"
        })
    }

    if ($btnRevertDefaults) {
        $btnRevertDefaults.Add_Click({
            $result = [System.Windows.MessageBox]::Show(
                "Are you sure you want to restore ALL settings to default Windows values?",
                "Confirm Rollback",
                [System.Windows.MessageBoxButton]::YesNo,
                [System.Windows.MessageBoxImage]::Warning
            )
            if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
                & $script:InvokeSequentialTweakAction -Tweaks $script:TweakDefinitions -Action "Rollback"
            }
        })
    }

    # Gaming Category Master Buttons
    if ($btnGamingApplyAll) {
        $btnGamingApplyAll.Add_Click({
            $gamingTweaks = $script:TweakDefinitions | Where-Object { $_.Category -eq "Gaming" }
            & $script:InvokeSequentialTweakAction -Tweaks $gamingTweaks -Action "Apply"
        })
    }
    if ($btnGamingRollbackAll) {
        $btnGamingRollbackAll.Add_Click({
            $gamingTweaks = $script:TweakDefinitions | Where-Object { $_.Category -eq "Gaming" }
            & $script:InvokeSequentialTweakAction -Tweaks $gamingTweaks -Action "Rollback"
        })
    }

    # Privacy Category Master Buttons
    if ($btnPrivacyApplyAll) {
        $btnPrivacyApplyAll.Add_Click({
            $privacyTweaks = $script:TweakDefinitions | Where-Object { $_.Category -eq "Privacy" }
            & $script:InvokeSequentialTweakAction -Tweaks $privacyTweaks -Action "Apply"
        })
    }
    if ($btnPrivacyRollbackAll) {
        $btnPrivacyRollbackAll.Add_Click({
            $privacyTweaks = $script:TweakDefinitions | Where-Object { $_.Category -eq "Privacy" }
            & $script:InvokeSequentialTweakAction -Tweaks $privacyTweaks -Action "Rollback"
        })
    }

    # System Category Master Buttons
    if ($btnSystemApplyAll) {
        $btnSystemApplyAll.Add_Click({
            $systemTweaks = $script:TweakDefinitions | Where-Object { $_.Category -eq "System" }
            & $script:InvokeSequentialTweakAction -Tweaks $systemTweaks -Action "Apply"
        })
    }
    if ($btnSystemRollbackAll) {
        $btnSystemRollbackAll.Add_Click({
            $systemTweaks = $script:TweakDefinitions | Where-Object { $_.Category -eq "System" }
            & $script:InvokeSequentialTweakAction -Tweaks $systemTweaks -Action "Rollback"
        })
    }

    # 10. Filter Chips Handlers
    $script:FilterCards = {
        param([string]$Category, [string]$TierFilter, [switch]$ActiveOnly)
        $audit = Get-SystemAuditState
        foreach ($tw in $script:TweakDefinitions) {
            if ($tw.Category -eq $Category -and $tw.Card) {
                $isMatch = $true
                if ($TierFilter -and $TierFilter -ne "All") {
                    if ($tw.Tier -ne $TierFilter) { $isMatch = $false }
                }
                if ($ActiveOnly) {
                    if ($audit.State[$tw.Key] -ne $true) { $isMatch = $false }
                }
                $tw.Card.Visibility = if ($isMatch) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
            }
        }
    }

    # Gaming Chips
    if ($chipGamingAll)         { $chipGamingAll.Add_Click({ & $script:FilterCards "Gaming" "All" }) }
    if ($chipGamingRecommended) { $chipGamingRecommended.Add_Click({ & $script:FilterCards "Gaming" "Recommended" }) }
    if ($chipGamingEsports)     { $chipGamingEsports.Add_Click({ & $script:FilterCards "Gaming" "Esports" }) }
    if ($chipGamingActive)      { $chipGamingActive.Add_Click({ & $script:FilterCards "Gaming" "" -ActiveOnly }) }

    # Privacy Chips
    if ($chipPrivacyAll)    { $chipPrivacyAll.Add_Click({ & $script:FilterCards "Privacy" "All" }) }
    if ($chipPrivacyActive) { $chipPrivacyActive.Add_Click({ & $script:FilterCards "Privacy" "" -ActiveOnly }) }

    # System Chips
    if ($chipSystemAll)    { $chipSystemAll.Add_Click({ & $script:FilterCards "System" "All" }) }
    if ($chipSystemActive) { $chipSystemActive.Add_Click({ & $script:FilterCards "System" "" -ActiveOnly }) }

    # 11. Universal Instant Search Filter
    if ($txtSearch) {
        $txtSearch.Add_TextChanged({
            $q = $txtSearch.Text.Trim().ToLower()
            # Filter Tweak Cards
            foreach ($tw in $script:TweakDefinitions) {
                if ($tw.Card) {
                    if ([string]::IsNullOrWhiteSpace($q)) {
                        $tw.Card.Visibility = [System.Windows.Visibility]::Visible
                    } else {
                        $titleMatch = ($tw.Title -and $tw.Title.ToLower().Contains($q))
                        $descMatch  = ($tw.Description -and $tw.Description.ToLower().Contains($q))
                        $tw.Card.Visibility = if ($titleMatch -or $descMatch) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
                    }
                }
            }

            # Filter App Cards if in Software Downloader
            if ($script:AllAppCards) {
                foreach ($item in $script:AllAppCards) {
                    if ($item.Border) {
                        if ([string]::IsNullOrWhiteSpace($q)) {
                            $item.Border.Visibility = [System.Windows.Visibility]::Visible
                        } else {
                            $match = ($item.Name.ToLower().Contains($q) -or $item.Desc.ToLower().Contains($q))
                            $item.Border.Visibility = if ($match) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
                        }
                    }
                }
            }
        })
    }

    if ($btnClearSearch) {
        $btnClearSearch.Add_Click({
            if ($txtSearch) { $txtSearch.Text = "" }
        })
    }

    # 12. Top Action Buttons (Beast Mode, Restore Point, MAS)
    if ($btnBeastMode) {
        $btnBeastMode.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "=== ENGAGING MAXIMUM BEAST MODE (LOW LATENCY + ANTI-LAG) ==="
            & $script:SetProgress 20
            try { Optimize-KernelAndCpu } catch {}
            & $script:SetProgress 40
            try { Optimize-InputLatency } catch {}
            & $script:SetProgress 60
            try { Optimize-Network } catch {}
            & $script:SetProgress 80
            try { Optimize-GpuAuto } catch {}
            & $script:SetProgress 100
            Start-Sleep -Milliseconds 200
            & $script:SetProgress 0
            if ($script:UpdateGuiAuditStatus) { & $script:UpdateGuiAuditStatus }
            & $script:LogToGui "[+] BEAST MODE ENGAGED: Max FPS, lowest DPC latency & flat ping active!"
        })
    }

    $masAction = {
        & $script:LogToGui "[*] Launching Microsoft Activation Scripts (MAS) in elevated terminal..."
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
    }
    if ($btnMasActivateTop) { $btnMasActivateTop.Add_Click($masAction) }

    $restoreAction = {
        & $script:LogToGui "[*] Creating Windows System Restore Point..."
        try {
            New-SystemRestorePointSafe
            & $script:LogToGui "[+] Windows System Restore Point created successfully."
        } catch {
            & $script:LogToGui "[-] Restore point creation failed: $($_.Exception.Message)" "ERROR"
        }
    }
    if ($btnRestorePointTop) { $btnRestorePointTop.Add_Click($restoreAction) }

    # Smart Game Booster & Memory Purger
    if ($btnPurgeStandby) {
        $btnPurgeStandby.Add_Click({
            & $script:LogToGui "[*] Purging Windows memory standby list cache..."
            try {
                Invoke-MatchBooster
                & $script:LogToGui "[+] Standby memory list purged successfully!"
            } catch {
                & $script:LogToGui "[-] Memory purge failed: $($_.Exception.Message)" "ERROR"
            }
        })
    }

    if ($btnStartGameBooster) {
        $btnStartGameBooster.Add_Click({
            & $script:LogToGui "[*] Starting Smart Game Booster Daemon..."
            try {
                $ok = Start-SmartGameBoosterDaemon
                if ($ok) {
                    & $script:LogToGui "[+] Smart Game Booster Daemon is ACTIVE: Monitoring 20+ competitive games!"
                }
            } catch {}
        })
    }

    # 13. Dynamic WinGet Software Catalog Construction
    $script:AllAppCards = [System.Collections.Generic.List[PSCustomObject]]::new()
    $brushNormalBg     = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#121824")
    $brushHoverBg      = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1A2234")
    $brushNormalBorder = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1F293D")
    $brushHoverBorder  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00D2FF")
    $brushCyan         = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00D2FF")
    $thick1  = [System.Windows.Thickness]::new(1)
    $thick5  = [System.Windows.Thickness]::new(5)
    $thick10 = [System.Windows.Thickness]::new(10)
    $corn6   = [System.Windows.CornerRadius]::new(6)
    $starGrid = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
    $autoGrid = [System.Windows.GridLength]::Auto

    if (Get-Command Get-AppCatalog -ErrorAction SilentlyContinue) {
        $catalog = Get-AppCatalog
        foreach ($app in $catalog) {
            $card = [System.Windows.Controls.Border]::new()
            $card.Width = 275
            $card.Height = 110
            $card.Background = $brushNormalBg
            $card.BorderBrush = $brushNormalBorder
            $card.BorderThickness = $thick1
            $card.CornerRadius = $corn6
            $card.Margin = $thick5
            $card.Padding = $thick10
            $card.Cursor = [System.Windows.Input.Cursors]::Hand

            $grid = [System.Windows.Controls.Grid]::new()
            $col0 = [System.Windows.Controls.ColumnDefinition]::new(); $col0.Width = $autoGrid
            $col1 = [System.Windows.Controls.ColumnDefinition]::new(); $col1.Width = $starGrid
            [void]$grid.ColumnDefinitions.Add($col0)
            [void]$grid.ColumnDefinitions.Add($col1)

            $chk = [System.Windows.Controls.CheckBox]::new()
            $chk.Margin = [System.Windows.Thickness]::new(0, 4, 10, 0)
            $chk.Tag = $app.Id
            $chk.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
            [System.Windows.Controls.Grid]::SetColumn($chk, 0)
            [void]$grid.Children.Add($chk)

            $sp = [System.Windows.Controls.StackPanel]::new()
            [System.Windows.Controls.Grid]::SetColumn($sp, 1)

            $topRow = [System.Windows.Controls.Grid]::new()
            $trCol0 = [System.Windows.Controls.ColumnDefinition]::new(); $trCol0.Width = $starGrid
            $trCol1 = [System.Windows.Controls.ColumnDefinition]::new(); $trCol1.Width = $autoGrid
            [void]$topRow.ColumnDefinitions.Add($trCol0)
            [void]$topRow.ColumnDefinitions.Add($trCol1)

            $txtTitle = [System.Windows.Controls.TextBlock]::new()
            $txtTitle.Text = $app.Name
            $txtTitle.FontWeight = [System.Windows.FontWeights]::Bold
            $txtTitle.FontSize = 12
            $txtTitle.Foreground = [System.Windows.Media.Brushes]::White
            $txtTitle.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
            [System.Windows.Controls.Grid]::SetColumn($txtTitle, 0)
            [void]$topRow.Children.Add($txtTitle)

            $badge = [System.Windows.Controls.Border]::new()
            $badge.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#182233")
            $badge.CornerRadius = [System.Windows.CornerRadius]::new(3)
            $badge.Padding = [System.Windows.Thickness]::new(4, 1, 4, 1)
            $badge.Margin = [System.Windows.Thickness]::new(4, 0, 0, 0)
            $txtBadge = [System.Windows.Controls.TextBlock]::new()
            $txtBadge.Text = $app.Category
            $txtBadge.FontSize = 9
            $txtBadge.Foreground = $brushCyan
            $badge.Child = $txtBadge
            [System.Windows.Controls.Grid]::SetColumn($badge, 1)
            [void]$topRow.Children.Add($badge)

            [void]$sp.Children.Add($topRow)

            $txtDesc = [System.Windows.Controls.TextBlock]::new()
            $txtDesc.Text = $app.Description
            $txtDesc.FontSize = 10
            $txtDesc.Foreground = $brushTextDim
            $txtDesc.TextWrapping = [System.Windows.TextWrapping]::Wrap
            $txtDesc.Margin = [System.Windows.Thickness]::new(0, 3, 0, 0)
            $txtDesc.MaxHeight = 42
            $txtDesc.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
            [void]$sp.Children.Add($txtDesc)

            [void]$grid.Children.Add($sp)
            $card.Child = $grid

            $card.Add_MouseEnter({
                $this.Background = $brushHoverBg
                $this.BorderBrush = $brushHoverBorder
            })
            $card.Add_MouseLeave({
                $this.Background = $brushNormalBg
                $this.BorderBrush = $brushNormalBorder
            })

            $card.Add_MouseLeftButtonUp({
                param($s, $e)
                if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
                    $c = $s.Child.Children[0]
                    $c.IsChecked = -not $c.IsChecked
                }
                & $script:UpdateSelectedCount
            })

            $chk.Add_Checked({ & $script:UpdateSelectedCount })
            $chk.Add_Unchecked({ & $script:UpdateSelectedCount })

            if ($wrapPackages) { [void]$wrapPackages.Children.Add($card) }

            $script:AllAppCards.Add([PSCustomObject]@{
                Border   = $card
                CheckBox = $chk
                Category = $app.Category
                Name     = $app.Name
                Desc     = $app.Description
                Id       = $app.Id
            })
        }
    }

    $script:UpdateSelectedCount = {
        $count = ($script:AllAppCards | Where-Object { $_.CheckBox.IsChecked -eq $true }).Count
        if ($txtSelectedCount) {
            $txtSelectedCount.Text = "$count apps selected"
        }
    }

    if ($btnSelectAll) {
        $btnSelectAll.Add_Click({
            foreach ($card in $script:AllAppCards) {
                if ($card.Border.Visibility -eq [System.Windows.Visibility]::Visible) {
                    $card.CheckBox.IsChecked = $true
                }
            }
            & $script:UpdateSelectedCount
        })
    }

    if ($btnClearAll) {
        $btnClearAll.Add_Click({
            foreach ($card in $script:AllAppCards) {
                $card.CheckBox.IsChecked = $false
            }
            & $script:UpdateSelectedCount
        })
    }

    if ($btnInstallSelected) {
        $btnInstallSelected.Add_Click({
            $selected = @($script:AllAppCards | Where-Object { $_.CheckBox.IsChecked -eq $true })
            if ($selected.Count -eq 0) {
                & $script:LogToGui "[-] No applications selected to install. Check packages in the grid first." "WARN"
                return
            }
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Starting installation batch for $($selected.Count) application(s)..."
            $idx = 0
            foreach ($item in $selected) {
                $idx++
                $pct = [int](($idx / $selected.Count) * 100)
                & $script:SetProgress $pct
                & $script:LogToGui "[$idx/$($selected.Count)] Installing $($item.Name) ($($item.Id))..."
                Install-WinGetPackage -PackageId $item.Id -LogCallback { param($m) & $script:LogToGui $m }
            }
            & $script:SetProgress 0
            & $script:LogToGui "[+] WinGet installation batch complete!"
        })
    }

    if ($btnUninstallSelected) {
        $btnUninstallSelected.Add_Click({
            $selected = @($script:AllAppCards | Where-Object { $_.CheckBox.IsChecked -eq $true })
            if ($selected.Count -eq 0) {
                & $script:LogToGui "[-] No applications selected to uninstall." "WARN"
                return
            }
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Uninstalling $($selected.Count) selected application(s)..."
            $idx = 0
            foreach ($item in $selected) {
                $idx++
                $pct = [int](($idx / $selected.Count) * 100)
                & $script:SetProgress $pct
                Uninstall-WinGetPackage -PackageId $item.Id -LogCallback { param($m) & $script:LogToGui $m }
            }
            & $script:SetProgress 0
            & $script:LogToGui "[+] WinGet uninstall batch complete!"
        })
    }

    if ($btnUpgradeAll) {
        $btnUpgradeAll.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Starting WinGet system-wide upgrade for all installed packages..."
            & $script:SetProgress 30
            Upgrade-AllWinGetPackages -LogCallback { param($m) & $script:LogToGui $m }
            & $script:SetProgress 100
            Start-Sleep -Milliseconds 200
            & $script:SetProgress 0
            & $script:LogToGui "[+] WinGet upgrade complete!"
        })
    }

    # Software Category Filter Chips
    $categoryMap = @{
        "ChipCatAll"      = "All"
        "ChipCatBrowsers" = "Browsers"
        "ChipCatComms"    = "Communication"
        "ChipCatDev"      = "Dev & Tools"
        "ChipCatDoc"      = "Productivity"
        "ChipCatGames"    = "Gaming"
        "ChipCatMs"       = "Utilities & System"
        "ChipCatMedia"    = "Media & Creative"
        "ChipCatPro"      = "Security & Privacy"
        "ChipCatSelf"     = "Runtimes & Drivers"
        "ChipCatUtil"     = "Emulators & Gaming Tools"
    }

    foreach ($chipName in $categoryMap.Keys) {
        $btnChip = $window.FindName($chipName)
        if ($btnChip) {
            $catFilter = $categoryMap[$chipName]
            $btnChip.Add_Click({
                param($s, $e)
                $selectedCat = $s.Tag
                foreach ($appCard in $script:AllAppCards) {
                    if ($selectedCat -eq "All" -or $appCard.Category -like "*$selectedCat*") {
                        $appCard.Border.Visibility = [System.Windows.Visibility]::Visible
                    } else {
                        $appCard.Border.Visibility = [System.Windows.Visibility]::Collapsed
                    }
                }
            })
            $btnChip.Tag = $catFilter
        }
    }

    # Equicord Installers
    if ($btnInstallEquicord) {
        $btnInstallEquicord.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Starting Equicord / Equilotl automated installation..."
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/Equicord/Equilotl/main/install.ps1 | iex`"" -Verb RunAs
        })
    }
    if ($btnOpenEquicordSite) {
        $btnOpenEquicordSite.Add_Click({
            Start-Process "https://equicord.org"
        })
    }

    # 14. Device Hardware Specs Populator
    $script:UpdateDeviceSpecsView = {
        try {
            $hw = Get-HardwareProfile
            if (-not $hw) { return }

            $t = $window.FindName("TxtDev_CpuName"); if ($t) { $t.Text = $hw.CpuName }
            $t = $window.FindName("TxtDev_CpuCores"); if ($t) { $t.Text = "$($hw.CpuCores) Cores / $($hw.CpuThreads) Threads" }
            $t = $window.FindName("TxtDev_CpuClock"); if ($t) { $t.Text = "$($hw.CpuBaseClock) GHz" }

            $t = $window.FindName("TxtDev_GpuName"); if ($t) { $t.Text = $hw.GpuPrimary }
            $t = $window.FindName("TxtDev_GpuDriver"); if ($t) { $t.Text = $hw.GpuDriverVersion }
            $t = $window.FindName("TxtDev_GpuRam"); if ($t) { $t.Text = "$($hw.GpuMemoryGb) GB" }

            $t = $window.FindName("TxtDev_RamTotal"); if ($t) { $t.Text = "$($hw.TotalRamGb) GB" }
            $t = $window.FindName("TxtDev_RamSpeed"); if ($t) { $t.Text = "$($hw.RamSpeedMhz) MHz" }

            $t = $window.FindName("TxtDev_OsName"); if ($t) { $t.Text = $hw.OsName }
            $t = $window.FindName("TxtDev_OsBuild"); if ($t) { $t.Text = $hw.OsBuild }

            $t = $window.FindName("TxtDev_NetName"); if ($t) { $t.Text = $hw.ActiveAdapterName }
            $t = $window.FindName("TxtDev_NetSpeed"); if ($t) { $t.Text = $hw.ActiveAdapterSpeed }
        } catch {}
    }

    # Device spec copy buttons
    $copyBtnMap = @{
        "BtnCopy_DevCpu" = "TxtDev_CpuName"
        "BtnCopy_DevGpu" = "TxtDev_GpuName"
        "BtnCopy_DevRam" = "TxtDev_RamTotal"
        "BtnCopy_DevOs"  = "TxtDev_OsName"
        "BtnCopy_DevNet" = "TxtDev_NetName"
    }
    foreach ($btnName in $copyBtnMap.Keys) {
        $b = $window.FindName($btnName)
        if ($b) {
            $txtElName = $copyBtnMap[$btnName]
            $b.Add_Click({
                param($s, $e)
                $txtEl = $window.FindName($s.Tag)
                if ($txtEl -and $txtEl.Text) {
                    [System.Windows.Clipboard]::SetText($txtEl.Text)
                    & $script:LogToGui "[+] Copied: $($txtEl.Text)"
                    $s.Content = "Copied!"
                    $timer = [System.Windows.Threading.DispatcherTimer]::new()
                    $timer.Interval = [TimeSpan]::FromMilliseconds(1200)
                    $timer.Add_Tick({ param($ts, $te) $s.Content = "Copy"; $ts.Stop() })
                    $timer.Start()
                }
            })
            $b.Tag = $txtElName
        }
    }

    # Expand/collapse for device spec cards
    $devCats = @('Cpu', 'Gpu', 'Ram', 'Os', 'Net')
    foreach ($cat in $devCats) {
        $btnToggle = $window.FindName("BtnToggle_Dev$cat")
        $panel     = $window.FindName("Panel_Dev$cat")
        if ($btnToggle -and $panel) {
            $btnToggle.Tag = $panel
            $btnToggle.Add_Click({
                param($s, $e)
                $target = $s.Tag
                if ($target.Visibility -eq [System.Windows.Visibility]::Visible) {
                    $target.Visibility = [System.Windows.Visibility]::Collapsed
                    $s.Content = "v"
                } else {
                    $target.Visibility = [System.Windows.Visibility]::Visible
                    $s.Content = "^"
                }
            })
        }
    }

    # Custom Gaming Cursors (23 Packs) Manager
    if ($cmbCursorSchemes) {
        try {
            $schemes = Get-AvailableCursorSchemes
            $cmbCursorSchemes.ItemsSource = $schemes
            $cmbCursorSchemes.DisplayMemberPath = "Name"
            if ($schemes -and $schemes.Count -gt 0) { $cmbCursorSchemes.SelectedIndex = 0 }
        } catch {}
    }

    if ($btnInstallCursor) {
        $btnInstallCursor.Add_Click({
            $selected = $cmbCursorSchemes.SelectedItem
            if (-not $selected) {
                & $script:LogToGui "[-] Please select a cursor scheme from the dropdown." "WARN"
                return
            }
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Installing custom cursor scheme: $($selected.Name)..."
            try {
                $ok = Install-CursorScheme -SchemeName $selected.Name
                if ($ok) {
                    if ($txtActiveCursorScheme) { $txtActiveCursorScheme.Text = $selected.Name }
                    & $script:LogToGui "[+] Cursor scheme '$($selected.Name)' installed and live-reloaded successfully!"
                } else {
                    & $script:LogToGui "[-] Failed to apply cursor scheme: $($selected.Name)" "ERROR"
                }
            } catch {
                & $script:LogToGui "[-] Cursor install error: $($_.Exception.Message)" "ERROR"
            }
        })
    }

    if ($btnRestoreCursor) {
        $btnRestoreCursor.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Restoring Windows default cursor scheme..."
            try {
                Restore-DefaultCursors
                if ($txtActiveCursorScheme) { $txtActiveCursorScheme.Text = "Windows Default" }
                & $script:LogToGui "[+] Windows default cursors restored successfully!"
            } catch {
                & $script:LogToGui "[-] Cursor restore error: $($_.Exception.Message)" "ERROR"
            }
        })
    }

    $btnRestoreDefaultCursors = $window.FindName("BtnRestoreDefaultCursors")
    if ($btnRestoreDefaultCursors) {
        $btnRestoreDefaultCursors.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Restoring default Windows cursor schemes..."
            try {
                Restore-DefaultCursors
                if ($txtActiveCursorScheme) { $txtActiveCursorScheme.Text = "Windows Default" }
                & $script:LogToGui "[+] Default Windows cursors restored successfully!"
            } catch {
                & $script:LogToGui "[-] Cursor restore failed: $($_.Exception.Message)" "ERROR"
            }
        })
    }

    # Gaming DNS Benchmark & Fast Switcher
    if ($btnBenchmarkDns) {
        $btnBenchmarkDns.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Starting Gaming DNS latency benchmark (Cloudflare, Google, Quad9, OpenDNS)..."
            try {
                Optimize-StartupAndDns
                & $script:LogToGui "[+] Fastest gaming DNS successfully applied to active network adapter!"
                if ($script:UpdateGuiAuditStatus) { & $script:UpdateGuiAuditStatus }
            } catch {
                & $script:LogToGui "[-] DNS benchmark failed: $($_.Exception.Message)" "ERROR"
            }
        })
    }
    if ($btnResetDns) {
        $btnResetDns.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Resetting DNS servers to router automatic DHCP..."
            try {
                Reset-DnsToAutomatic
                & $script:LogToGui "[+] DNS servers reset to automatic DHCP!"
                if ($script:UpdateGuiAuditStatus) { & $script:UpdateGuiAuditStatus }
            } catch {
                & $script:LogToGui "[-] DNS reset error: $($_.Exception.Message)" "ERROR"
            }
        })
    }

    # System Health, Diagnostics & Cleaners
    if ($btnRunDiagnostics) {
        $btnRunDiagnostics.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Launching Windows System File Checker (SFC) and DISM health repair..."
            try {
                Repair-SystemHealth
                & $script:LogToGui "[+] System health repair routine completed!"
            } catch {
                & $script:LogToGui "[-] Repair failed: $($_.Exception.Message)" "ERROR"
            }
        })
    }
    if ($btnClearUpdateCache) {
        $btnClearUpdateCache.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Purging corrupted Windows Update download cache..."
            try {
                Clear-WindowsUpdateCache
                & $script:LogToGui "[+] Windows Update cache cleared successfully!"
            } catch {
                & $script:LogToGui "[-] Failed to clear WU cache: $($_.Exception.Message)" "ERROR"
            }
        })
    }
    if ($btnClearDeepCacheBar) {
        $btnClearDeepCacheBar.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Running Deep Junk & Shader Temp Cache Cleaner..."
            try {
                Invoke-DeepCacheCleaner
                & $script:LogToGui "[+] Deep Cache Cleaner finished!"
            } catch {
                & $script:LogToGui "[-] Cache cleaner failed: $($_.Exception.Message)" "ERROR"
            }
        })
    }
    if ($btnReport_Interrupts) {
        $btnReport_Interrupts.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Checking DPC Interrupt Latency and Device Manager state..."
            try {
                $status = Get-DeviceManagerOptimizationStatus
                & $script:LogToGui "[+] Device Manager optimization status: $status (HPET/SMBus/Timers)"
            } catch {}
        })
    }

    # Top Bar Actions
    if ($btnRestorePointTop) {
        $btnRestorePointTop.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Creating safe Windows System Restore Point..."
            try {
                New-SystemRestorePointSafe -Description "PumpkiN Optimizer Pre-Tune Point"
                & $script:LogToGui "[+] System Restore Point created successfully!"
            } catch {
                & $script:LogToGui "[-] Restore point failed: $($_.Exception.Message)" "ERROR"
            }
        })
    }
    if ($btnMasActivateTop) {
        $btnMasActivateTop.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Launching Microsoft Activation Scripts (MAS)..."
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
        })
    }
    if ($btnBeastMode) {
        $btnBeastMode.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "=== ENGAGING FULL BEAST MODE (Applying all recommended tweaks) ==="
            $safeTweaks = @($script:TweakDefinitions | Where-Object { $_.Tier -ne "Esports" })
            & $script:InvokeSequentialTweakAction -Tweaks $safeTweaks -Action "Apply"
        })
    }

    # Match Booster & Standby Purge
    if ($btnStartGameBooster) {
        $btnStartGameBooster.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Starting PumpkiN Match Booster Daemon..."
            try {
                Invoke-MatchBooster
                & $script:LogToGui "[+] Match Booster active: gaming processes prioritized, standby memory purged!"
            } catch {
                & $script:LogToGui "[-] Match Booster error: $($_.Exception.Message)" "ERROR"
            }
        })
    }
    if ($btnPurgeStandby) {
        $btnPurgeStandby.Add_Click({
            & $script:LogToGui "[*] Purging Windows standby memory cache via EmptyStandbyList..."
            try {
                $exe = Join-Path (Split-Path $PSScriptRoot -Parent) "EmptyStandbyList.exe"
                if (Test-Path $exe) {
                    Start-Process -FilePath $exe -ArgumentList "workingsets standby" -NoNewWindow -Wait
                    & $script:LogToGui "[+] Standby memory list purged successfully!"
                } else {
                    & $script:LogToGui "[-] EmptyStandbyList.exe not found in root directory." "WARN"
                }
            } catch {
                & $script:LogToGui "[-] Standby purge error: $($_.Exception.Message)" "ERROR"
            }
        })
    }

    # Device Page Actions
    if ($btnRefreshDeviceSpecs) {
        $btnRefreshDeviceSpecs.Add_Click({
            & $script:LogToGui "[*] Refreshing live device hardware specifications..."
            & $script:UpdateDeviceSpecsView
            & $script:LogToGui "[+] Hardware profile refreshed."
        })
    }
    if ($btnCopyAllDeviceSpecs) {
        $btnCopyAllDeviceSpecs.Add_Click({
            try {
                $hw = Get-HardwareProfile
                $specsText = @"
PumpkiN Windows Optimizer - Hardware Specifications Report
----------------------------------------------------------
Computer Name:  $($env:COMPUTERNAME)
CPU:            $($hw.CpuName) ($($hw.CpuCores) Cores / $($hw.CpuThreads) Threads @ $($hw.CpuBaseClock) GHz)
GPU:            $($hw.GpuPrimary) (Driver: $($hw.GpuDriverVersion), VRAM: $($hw.GpuMemoryGb) GB)
RAM:            $($hw.TotalRamGb) GB ($($hw.RamSpeedMhz) MHz)
OS:             $($hw.OsName) (Build $($hw.OsBuild))
Network:        $($hw.ActiveAdapterName) ($($hw.ActiveAdapterSpeed))
"@
                [System.Windows.Clipboard]::SetText($specsText)
                & $script:LogToGui "[+] Full system hardware specifications copied to clipboard!"
            } catch {
                & $script:LogToGui "[-] Failed to copy specs: $($_.Exception.Message)" "ERROR"
            }
        })
    }

    # TrafficMonitor Buttons
    $btnInstallTrafficMonitor = $window.FindName("BtnInstallTrafficMonitor")
    $btnInstallMiSansFonts    = $window.FindName("BtnInstallMiSansFonts")
    $btnLaunchTrafficMonitor  = $window.FindName("BtnLaunchTrafficMonitor")
    if ($btnInstallTrafficMonitor) {
        $btnInstallTrafficMonitor.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Downloading and installing TrafficMonitor..."
            try { Install-TrafficMonitorLatest -LogCallback $script:LogToGui } catch {}
        })
    }
    if ($btnInstallMiSansFonts) {
        $btnInstallMiSansFonts.Add_Click({
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Installing MiSans fonts..."
            try { Install-MiSansFonts -LogCallback $script:LogToGui } catch {}
        })
    }
    if ($btnLaunchTrafficMonitor) {
        $btnLaunchTrafficMonitor.Add_Click({
            try { Start-TrafficMonitorApp -LogCallback $script:LogToGui } catch {}
        })
    }

    # 15. Initial Load & Telemetry Loop
    & $script:UpdateDeviceSpecsView
    & $script:UpdateGuiAuditStatus

    & $script:LogToGui "PumpkiN Ultimate Windows Optimizer v5.6.0 initialized."
    & $script:LogToGui "Live audit complete. Use toggle switches to control individual optimizations."

    # Live Hardware Telemetry DispatcherTimer
    $telemetryTimer = [System.Windows.Threading.DispatcherTimer]::new()
    $telemetryTimer.Interval = [TimeSpan]::FromSeconds(2.5)
    $updateTelemetryAction = {
        try {
            $t = Get-LiveHardwareTelemetry
            if ($txtLiveCpu)  { $txtLiveCpu.Text = "$($t.CpuLoad)%" }
            if ($txtLiveRam)  { $txtLiveRam.Text = "$($t.UsedRamGb)/$($t.TotalRamGb) GB ($($t.RamPercent)%)" }
            if ($txtLivePing) { $txtLivePing.Text = if ($t.PingMs -ge 0) { "$($t.PingMs) ms" } else { "--" } }
            if ($txtLiveBooster) {
                $txtLiveBooster.Text = $t.BoosterStatus
                $txtLiveBooster.Foreground = if ($t.BoosterStatus -like "BOOST*") { [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88") } elseif ($t.BoosterStatus -like "ACTIVE*") { [System.Windows.Media.BrushConverter]::new().ConvertFromString("#A855F7") } else { [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8") }
            }
        } catch {}
    }
    $telemetryTimer.Add_Tick($updateTelemetryAction)
    $telemetryTimer.Start()
    & $updateTelemetryAction

    # Exit Handler
    $script:ExitOptimizer = {
        try { if ($telemetryTimer) { $telemetryTimer.Stop() } } catch {}
        try { Stop-SmartGameBoosterDaemon } catch {}
        try { Get-Process -Name "EmptyStandbyList" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue } catch {}
        try { if ([System.Windows.Application]::Current) { [System.Windows.Application]::Current.Shutdown(0) } } catch {}
        try { if ($window -and $window.IsVisible) { $window.Close() } } catch {}
        try { [System.Diagnostics.Process]::GetCurrentProcess().Kill() } catch { Stop-Process -Id $PID -Force }
    }

    if ($btnExitTop) { $btnExitTop.Add_Click({ & $script:ExitOptimizer }) }
    $window.Add_Closing({ try { if ($telemetryTimer) { $telemetryTimer.Stop() }; Stop-SmartGameBoosterDaemon } catch {} })
    $window.Add_Closed({ & $script:ExitOptimizer })

    # Launch GUI Window
    [void]$window.ShowDialog()
    & $script:ExitOptimizer
}