<#
================================================================================
  PumpkiN's Modular Suite: Desktop WPF GUI Event Controller & Async Engine
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

    # Load 3D Pumpkin Brand Logo
    $imgLogo = $window.FindName("ImgAppLogo")
    $logoCandidates = @(
        (Join-Path (Split-Path $PSScriptRoot -Parent) "LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.png"),
        (Join-Path (Get-Location) "LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.png"),
        "e:\Projects\Win_Optimizer\LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.png"
    )
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
                break
            } catch {}
        }
    }

    # Core Controls
    $wrapPackages       = $window.FindName("WrapPackages")
    $txtSearch          = $window.FindName("TxtSearch")
    $btnClearSearch     = $window.FindName("BtnClearSearch")
    $btnInstallSelected = $window.FindName("BtnInstallSelected")
    $btnUninstallSelected = $window.FindName("BtnUninstallSelected")
    $btnUpgradeAll      = $window.FindName("BtnUpgradeAll")
    $btnSelectAll       = $window.FindName("BtnSelectAll")
    $btnClearAll        = $window.FindName("BtnClearAll")
    $txtSelectedCount   = $window.FindName("TxtSelectedCount")

    $btnRunAllTweaks    = $window.FindName("BtnRunAllTweaks")
    $btnRevertDefaults  = $window.FindName("BtnRevertDefaults")
    $btnClearDeepCacheBar = $window.FindName("BtnClearDeepCacheBar")
    $btnClearUpdateCache = $window.FindName("BtnClearUpdateCache")
    $btnInstallDirectXDirect = $window.FindName("BtnInstallDirectXDirect")
    $btnInstallVcRedistAio = $window.FindName("BtnInstallVcRedistAio")
    $btnBeastMode       = $window.FindName("BtnBeastMode")

    $btnPurgeStandby         = $window.FindName("BtnPurgeStandby")
    $cmbStandbyInterval      = $window.FindName("CmbStandbyInterval")
    $btnSetStandbySchedule   = $window.FindName("BtnSetStandbySchedule")
    $btnRemoveStandbySchedule = $window.FindName("BtnRemoveStandbySchedule")
    $txtStandbyTaskStatus    = $window.FindName("TxtStandbyTaskStatus")
    $btnToggleWifiScan       = $window.FindName("BtnToggleWifiScan")
        $btnApplyGameHooks       = $window.FindName("BtnApplyGameHooks")
    $txtLiveCpu              = $window.FindName("TxtLiveCpu")
    $txtLiveRam              = $window.FindName("TxtLiveRam")
    $txtLivePing             = $window.FindName("TxtLivePing")
    $txtLiveBooster          = $window.FindName("TxtLiveBooster")
    $txtDaemonStatus         = $window.FindName("TxtDaemonStatus")
    $btnStartGameBooster     = $window.FindName("BtnStartGameBooster")
    $btnStopGameBooster      = $window.FindName("BtnStopGameBooster")

    $btnMasActivate     = $window.FindName("BtnMasActivate")
    $btnMasActivateTop  = $window.FindName("BtnMasActivateTop")
    $btnRestorePoint    = $window.FindName("BtnRestorePoint")
    $btnRestorePointTop = $window.FindName("BtnRestorePointTop")
    $btnApplyHardening  = $window.FindName("BtnApplyHardening")
    $btnRunDiagnostics  = $window.FindName("BtnRunDiagnostics")

    $txtConsole         = $window.FindName("TxtConsole")
    $txtStatus          = $window.FindName("TxtStatus")
    $progressBar        = $window.FindName("MainProgressBar")
    $btnClearConsole    = $window.FindName("BtnClearConsole")

    # Tab 2 Checkboxes
    $chkGpuAuto         = $window.FindName("ChkGpuAuto")
    $chkHardwareMsi     = $window.FindName("ChkHardwareMsi")
    $chkDisablePowerSaving = $window.FindName("ChkDisablePowerSaving")
    $chkMpo             = $window.FindName("ChkMpo")
    $chkMouseCurve      = $window.FindName("ChkMouseCurve")
    $chkInputLatency    = $window.FindName("ChkInputLatency")
    $chkCsrssPriority   = $window.FindName("ChkCsrssPriority")
    $chkCpuSystem       = $window.FindName("ChkCpuSystem")
    $chkSvcHost         = $window.FindName("ChkSvcHost")
    $chkNetwork         = $window.FindName("ChkNetwork")
    $chkWifiScan        = $window.FindName("ChkWifiScan")
    $chkUltimatePower   = $window.FindName("ChkUltimatePower")
    $chkStripVisual     = $window.FindName("ChkStripVisual")
    $chkEndTask         = $window.FindName("ChkEndTask")
    $chkStickyKeys      = $window.FindName("ChkStickyKeys")
    $chkDebloatServices = $window.FindName("ChkDebloatServices")
    $chkDiskIo          = $window.FindName("ChkDiskIo")
    $chkCompactOs       = $window.FindName("ChkCompactOs")
    $chkTakeOwnership   = $window.FindName("ChkTakeOwnership")
    $chkJunkTasks       = $window.FindName("ChkJunkTasks")
    $chkPrivacy         = $window.FindName("ChkPrivacy")

    # Tab 4 Checkboxes
    $chkBlockWpbt       = $window.FindName("ChkBlockWpbt")
    $chkBlockPeripheral = $window.FindName("ChkBlockPeripheral")
    $chkRemoveAi        = $window.FindName("ChkRemoveAi")
    $chkSecurityUpdatesOnly = $window.FindName("ChkSecurityUpdatesOnly")
    $chkClassicContext  = $window.FindName("ChkClassicContext")
    $chkDisableBing     = $window.FindName("ChkDisableBing")
    $chkDisableAutoDiscovery = $window.FindName("ChkDisableAutoDiscovery")
    $chkShowExtensions  = $window.FindName("ChkShowExtensions")
    $chkEnableLongPaths = $window.FindName("ChkEnableLongPaths")
    $chkDisableLockScreen = $window.FindName("ChkDisableLockScreen")
    $chkBsodVerbose     = $window.FindName("ChkBsodVerbose")
    $chkDisableReservedStorage = $window.FindName("ChkDisableReservedStorage")

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
            $txtConsole.AppendText($line)
            $txtConsole.ScrollToEnd()
            $txtStatus.Text = $Message
        })
        & $script:DoEvents
    }

    $script:SetProgress = {
        param([int]$Percent)
        $window.Dispatcher.Invoke([Action]{
            $progressBar.Value = $Percent
        })
        & $script:DoEvents
    }

    $btnClearConsole.Add_Click({
        $txtConsole.Clear()
        $txtStatus.Text = "Log cleared"
    })

    # Build Application Cards Dynamically
    $script:AllAppCards = [System.Collections.Generic.List[PSCustomObject]]::new()
    $brushNormalBg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#161E2B")
    $brushHoverBg  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
    $brushNormalBorder = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#26354A")
    $brushHoverBorder  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00D2FF")
    $brushCyan = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00D2FF")
    $brushTextDim = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
    $brushTextSub = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#64748B")

    foreach ($app in $Global:AppCatalog) {
        $card = New-Object System.Windows.Controls.Border
        $card.Width = 275
        $card.Height = 110
        $card.Background = $brushNormalBg
        $card.BorderBrush = $brushNormalBorder
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
        $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $card.Margin = New-Object System.Windows.Thickness(5)
        $card.Padding = New-Object System.Windows.Thickness(10)
        $card.Cursor = [System.Windows.Input.Cursors]::Hand

        $grid = New-Object System.Windows.Controls.Grid
        $col0 = New-Object System.Windows.Controls.ColumnDefinition
        $col0.Width = [System.Windows.GridLength]::Auto
        $col1 = New-Object System.Windows.Controls.ColumnDefinition
        $col1.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
        [void]$grid.ColumnDefinitions.Add($col0)
        [void]$grid.ColumnDefinitions.Add($col1)

        $chk = New-Object System.Windows.Controls.CheckBox
        $chk.Margin = New-Object System.Windows.Thickness(0, 4, 10, 0)
        $chk.Tag = $app.WingetId
        $chk.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
        [System.Windows.Controls.Grid]::SetColumn($chk, 0)
        [void]$grid.Children.Add($chk)

        $sp = New-Object System.Windows.Controls.StackPanel
        [System.Windows.Controls.Grid]::SetColumn($sp, 1)

        $topRow = New-Object System.Windows.Controls.Grid
        $trCol0 = New-Object System.Windows.Controls.ColumnDefinition
        $trCol0.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
        $trCol1 = New-Object System.Windows.Controls.ColumnDefinition
        $trCol1.Width = [System.Windows.GridLength]::Auto
        [void]$topRow.ColumnDefinitions.Add($trCol0)
        [void]$topRow.ColumnDefinitions.Add($trCol1)

        $titleBlock = New-Object System.Windows.Controls.TextBlock
        $titleBlock.Text = $app.Name
        $titleBlock.FontWeight = [System.Windows.FontWeights]::SemiBold
        $titleBlock.FontSize = 12
        $titleBlock.Foreground = [System.Windows.Media.Brushes]::White
        $titleBlock.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
        [System.Windows.Controls.Grid]::SetColumn($titleBlock, 0)
        [void]$topRow.Children.Add($titleBlock)

        $catBadge = New-Object System.Windows.Controls.Border
        $catBadge.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0F141C")
        $catBadge.BorderBrush = $brushCyan
        $catBadge.BorderThickness = New-Object System.Windows.Thickness(1)
        $catBadge.CornerRadius = New-Object System.Windows.CornerRadius(3)
        $catBadge.Padding = New-Object System.Windows.Thickness(4, 1, 4, 1)
        $catBadge.Margin = New-Object System.Windows.Thickness(4, 0, 0, 0)
        $catText = New-Object System.Windows.Controls.TextBlock
        $catText.Text = $app.Category
        $catText.FontSize = 9
        $catText.Foreground = $brushCyan
        $catBadge.Child = $catText
        [System.Windows.Controls.Grid]::SetColumn($catBadge, 1)
        [void]$topRow.Children.Add($catBadge)

        [void]$sp.Children.Add($topRow)

        $descBlock = New-Object System.Windows.Controls.TextBlock
        $descBlock.Text = $app.Description
        $descBlock.Foreground = $brushTextDim
        $descBlock.FontSize = 10
        $descBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $descBlock.MaxHeight = 32
        $descBlock.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
        $descBlock.Margin = New-Object System.Windows.Thickness(0, 3, 0, 0)
        [void]$sp.Children.Add($descBlock)

        $idBlock = New-Object System.Windows.Controls.TextBlock
        $idBlock.Text = $app.WingetId
        $idBlock.Foreground = $brushTextSub
        $idBlock.FontSize = 9
        $idBlock.Margin = New-Object System.Windows.Thickness(0, 3, 0, 0)
        [void]$sp.Children.Add($idBlock)

        [void]$grid.Children.Add($sp)
        $card.Child = $grid

        # Card Interaction
        $card.Add_MouseEnter({ $this.BorderBrush = $brushHoverBorder; $this.Background = $brushHoverBg })
        $card.Add_MouseLeave({ $this.BorderBrush = $brushNormalBorder; $this.Background = $brushNormalBg })
        $card.Add_MouseLeftButtonUp({
            $targetChk = $this.Child.Children[0]
            $targetChk.IsChecked = (-not $targetChk.IsChecked)
            & $script:UpdateSelectionCount
        })
        $chk.Add_Click({ & $script:UpdateSelectionCount })

        [void]$wrapPackages.Children.Add($card)
        [void]$script:AllAppCards.Add([PSCustomObject]@{
            App = $app
            Border = $card
            CheckBox = $chk
        })
    }

    $script:CurrentCategory = "All Apps (100+)"

    $script:UpdateSelectionCount = {
        $count = ($script:AllAppCards | Where-Object { $_.CheckBox.IsChecked -eq $true }).Count
        $txtSelectedCount.Text = "$count apps selected"
    }

    $script:FilterCards = {
        $query = $txtSearch.Text.Trim().ToLower()
        $curCat = $script:CurrentCategory
        foreach ($item in $script:AllAppCards) {
            $matchQ = ($query -eq "") -or ($item.App.Name.ToLower().Contains($query)) -or ($item.App.Description.ToLower().Contains($query)) -or ($item.App.WingetId.ToLower().Contains($query))
            $matchC = ($curCat -eq "All Apps (100+)") -or ($item.App.Category -eq $curCat)
            if ($matchQ -and $matchC) {
                $item.Border.Visibility = [System.Windows.Visibility]::Visible
            } else {
                $item.Border.Visibility = [System.Windows.Visibility]::Collapsed
            }
        }
    }

    $txtSearch.Add_TextChanged({ & $script:FilterCards })
    $btnClearSearch.Add_Click({ $txtSearch.Clear(); & $script:FilterCards })

    # Category Chips Map
    $chipsMap = @{
        "ChipCatAll"      = "All Apps (100+)"
        "ChipCatBrowsers" = "Browsers"
        "ChipCatComms"    = "Communications"
        "ChipCatDev"      = "Development"
        "ChipCatDoc"      = "Document"
        "ChipCatGames"    = "Games"
        "ChipCatMs"       = "Microsoft Tools"
        "ChipCatMedia"    = "Multimedia Tools"
        "ChipCatPro"      = "Pro Tools"
        "ChipCatSelf"     = "Selfhosted Tools"
        "ChipCatUtil"     = "Utilities"
    }
    foreach ($entry in $chipsMap.GetEnumerator()) {
        $cBtn = $window.FindName($entry.Key)
        if ($cBtn) {
            $targetCategory = $entry.Value
            $cBtn.Add_Click({
                $script:CurrentCategory = $targetCategory
                & $script:FilterCards
                & $script:LogToGui "Displaying category: $targetCategory"
            }.GetNewClosure())
        }
    }

    $btnSelectAll.Add_Click({
        foreach ($item in $script:AllAppCards) {
            if ($item.Border.Visibility -eq [System.Windows.Visibility]::Visible) {
                $item.CheckBox.IsChecked = $true
            }
        }
        & $script:UpdateSelectionCount
    })

    $btnClearAll.Add_Click({
        foreach ($item in $script:AllAppCards) {
            $item.CheckBox.IsChecked = $false
        }
        & $script:UpdateSelectionCount
    })

    # WinGet Install / Uninstall / Upgrade Handlers
    $btnInstallSelected.Add_Click({
        $selected = $script:AllAppCards | Where-Object { $_.CheckBox.IsChecked -eq $true }
        if ($selected.Count -eq 0) {
            & $script:LogToGui "[-] No applications selected to install. Check desired app cards first!" "WARN"
            return
        }

        & $script:LogToGui "[*] Preparing to install $($selected.Count) selected application(s)..."
        $idx = 0
        foreach ($item in $selected) {
            $idx++
            $pct = [int](($idx / $selected.Count) * 100)
            & $script:SetProgress $pct
            & $script:LogToGui "[$idx/$($selected.Count)] Processing: $($item.App.Name) ($($item.App.WingetId))"
            Install-WinGetPackage -PackageId $item.App.WingetId -LogCallback { param($m) & $script:LogToGui $m }
        }
        & $script:SetProgress 0
        & $script:LogToGui "[+] Installation batch complete!"
    })

    $btnUninstallSelected.Add_Click({
        $selected = $script:AllAppCards | Where-Object { $_.CheckBox.IsChecked -eq $true }
        if ($selected.Count -eq 0) {
            & $script:LogToGui "[-] No applications selected to uninstall." "WARN"
            return
        }

        & $script:LogToGui "[*] Uninstalling $($selected.Count) selected application(s)..."
        $idx = 0
        foreach ($item in $selected) {
            $idx++
            $pct = [int](($idx / $selected.Count) * 100)
            & $script:SetProgress $pct
            Uninstall-WinGetPackage -PackageId $item.App.WingetId -LogCallback { param($m) & $script:LogToGui $m }
        }
        & $script:SetProgress 0
        & $script:LogToGui "[+] Uninstall batch complete!"
    })

    $btnUpgradeAll.Add_Click({
        & $script:LogToGui "[*] Starting WinGet system-wide upgrade..."
        & $script:SetProgress 50
        Upgrade-AllWinGetPackages -LogCallback { param($m) & $script:LogToGui $m }
        & $script:SetProgress 0
        & $script:LogToGui "[+] WinGet upgrade complete!"
    })

    # Tab 2: Tweaks Handlers
    $btnRunAllTweaks.Add_Click({
        & $script:LogToGui "=== APPLYING ALL 23 GAMING OPTIMIZATIONS ==="
        & $script:SetProgress 10
        Optimize-Network
        & $script:SetProgress 20
        Optimize-GpuAuto
        & $script:SetProgress 35
        Optimize-HardwareMsiMode
        Disable-DevicePowerSaving
        Disable-MultiplaneOverlay
        Set-MouseLinearCurve
        & $script:SetProgress 50
        Optimize-LatencyAndInput
        Optimize-CsrssPriority
        Optimize-CpuAndSystem
        Optimize-SvcHostSplitting
        & $script:SetProgress 65
        Optimize-StartupAndDns
        Apply-GameHooks
        & $script:SetProgress 80
        Enable-UltimatePerformancePlan
        Strip-VisualEffects
        Enable-EndTaskRightClick
        Disable-StickyKeysPrompt
        & $script:SetProgress 90
        Debloat-BackgroundServices
        Optimize-DiskIO
        Enable-CompactOS
        Enable-TakeOwnershipMenu
        Disable-ScheduledJunkTasks
        Harden-PrivacyTelemetry
        & $script:SetProgress 100
        & $script:LogToGui "[+] ALL 23 GAMING OPTIMIZATIONS APPLIED SUCCESSFULLY!"
        Start-Sleep -Milliseconds 300
        & $script:SetProgress 0
    })

    $btnRevertDefaults.Add_Click({
        & $script:LogToGui "[*] Reverting all settings to Windows defaults..."
        & $script:SetProgress 50
        Restore-Defaults
        & $script:SetProgress 100
        & $script:LogToGui "[+] Windows default settings restored successfully!"
        Start-Sleep -Milliseconds 300
        & $script:SetProgress 0
    })

    if ($btnClearDeepCacheBar) {
        $btnClearDeepCacheBar.Add_Click({
            & $script:LogToGui "[*] Starting Deep Cache, Prefetch & Windows Event Log Cleaner..."
            & $script:SetProgress 40
            Invoke-DeepCacheCleaner
            & $script:SetProgress 100
            & $script:LogToGui "[+] Deep Cache & Event Cleaner completed successfully!"
            Start-Sleep -Milliseconds 300
            & $script:SetProgress 0
        })
    }

    if ($btnClearUpdateCache) {
        $btnClearUpdateCache.Add_Click({
            & $script:LogToGui "[*] Purging Windows Update & Delivery Optimization cache..."
            & $script:SetProgress 40
            Clear-WindowsUpdateCache
            & $script:SetProgress 100
            Start-Sleep -Milliseconds 300
            & $script:SetProgress 0
        })
    }

    if ($btnInstallDirectXDirect) {
        $btnInstallDirectXDirect.Add_Click({
            & $script:LogToGui "[*] Starting direct download and installation of DirectX Runtimes..."
            & $script:SetProgress 20
            Install-DirectXDirect -LogCallback $script:LogToGui
            & $script:SetProgress 100
            Start-Sleep -Milliseconds 300
            & $script:SetProgress 0
        })
    }

    if ($btnInstallVcRedistAio) {
        $btnInstallVcRedistAio.Add_Click({
            & $script:LogToGui "[*] Starting direct download and installation of Visual C++ Redistributables..."
            & $script:SetProgress 20
            Install-VcRedistAioDirect -LogCallback $script:LogToGui
            & $script:SetProgress 100
            Start-Sleep -Milliseconds 300
            & $script:SetProgress 0
        })
    }

    $btnBeastMode.Add_Click({
        & $script:LogToGui "[*] ENGAGING FULL BEAST MODE SUITE..."
        & $script:SetProgress 15
        Optimize-Network
        & $script:SetProgress 30
        Optimize-GpuAuto
        & $script:SetProgress 45
        Optimize-CpuAndSystem
        & $script:SetProgress 60
        Optimize-LatencyAndInput
        & $script:SetProgress 75
        Apply-GameHooks
        & $script:SetProgress 85
        Debloat-BackgroundServices
        Enable-UltimatePerformancePlan
        Harden-PrivacyTelemetry
        Optimize-DiskIO
        Disable-ScheduledJunkTasks
        Optimize-StartupAndDns
        Disable-MultiplaneOverlay
        Set-MouseLinearCurve
        Optimize-SvcHostSplitting
        Enable-EndTaskRightClick
        Disable-StickyKeysPrompt
        & $script:SetProgress 100
        & $script:LogToGui "================================================================================"
        & $script:LogToGui "[OK] FULL BEAST MODE ENGAGED  --  ALL COMPETITIVE TWEAKS ACTIVE!"
        & $script:LogToGui "================================================================================"
        Start-Sleep -Milliseconds 300
        & $script:SetProgress 0
    })

    # Tab 3: Match Booster Handlers
    $updateStandbyStatus = {
        if ($txtStandbyTaskStatus) {
            $st = Get-StandbyListScheduledTaskStatus
            $txtStandbyTaskStatus.Text = "Status: $($st.DisplayText)"
            if ($st.IsActive) {
                $txtStandbyTaskStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88")
            } else {
                $txtStandbyTaskStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
            }
        }
    }

    $btnPurgeStandby.Add_Click({
        & $script:LogToGui "[*] Running One-Time Purge of Windows Standby List Cache..."
        Invoke-EmptyStandbyListOneTime
        & $script:LogToGui "[+] Standby memory purged successfully! Memory returned to free pool."
    })

    if ($btnSetStandbySchedule) {
        $btnSetStandbySchedule.Add_Click({
            $mins = 5
            if ($cmbStandbyInterval -and $cmbStandbyInterval.SelectedItem -and $cmbStandbyInterval.SelectedItem.Tag) {
                $mins = [int]$cmbStandbyInterval.SelectedItem.Tag
            }
            & $script:LogToGui "[*] Setting Background Auto-Cleaner schedule (Every $mins minutes)..."
            $ok = Set-StandbyListScheduledTask -IntervalMinutes $mins
            & $updateStandbyStatus
            if ($ok) {
                & $script:LogToGui "[+] PumpkiN_AutoEmptyStandbyList scheduled to run every $mins minutes!"
            } else {
                & $script:LogToGui "[!] Failed to configure scheduled task. Ensure running as Administrator."
            }
        })
    }

    if ($btnRemoveStandbySchedule) {
        $btnRemoveStandbySchedule.Add_Click({
            & $script:LogToGui "[*] Disabling Background Auto-Cleaner schedule..."
            Remove-StandbyListScheduledTask
            & $updateStandbyStatus
            & $script:LogToGui "[+] Background Auto-Cleaner schedule removed/disabled."
        })
    }

    $btnToggleWifiScan.Add_Click({
        Toggle-WifiAutoconfig
        & $script:LogToGui "[+] Wi-Fi AutoConfig state toggled."
    })

    $btnApplyGameHooks.Add_Click({
        & $script:LogToGui "[*] Installing IFEO High-Priority Hooks for esports titles..."
        Apply-GameHooks
        & $script:LogToGui "[+] Esports Priority Hooks installed for CS2, Valorant, Apex, Fortnite, COD!"
    })

    # Smart Game Booster Daemon Handlers
    $updateDaemonStatusUI = {
        if ($txtDaemonStatus) {
            $dStat = Get-SmartGameBoosterStatus
            $txtDaemonStatus.Text = "Status: $($dStat.DisplayText)"
            if ($dStat.IsActive) {
                $txtDaemonStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88")
            } else {
                $txtDaemonStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
            }
        }
    }

    if ($btnStartGameBooster) {
        $btnStartGameBooster.Add_Click({
            & $script:LogToGui "[*] Starting Smart Game Booster Daemon (Auto-Detection Engine)..."
            $ok = Start-SmartGameBoosterDaemon
            & $updateDaemonStatusUI
            if ($ok) {
                & $script:LogToGui "[+] Smart Game Booster Daemon is ACTIVE: Monitoring 20+ competitive games!"
            }
        })
    }

    if ($btnStopGameBooster) {
        $btnStopGameBooster.Add_Click({
            & $script:LogToGui "[*] Stopping Smart Game Booster Daemon..."
            $ok = Stop-SmartGameBoosterDaemon
            & $updateDaemonStatusUI
            & $script:LogToGui "[+] Smart Game Booster Daemon stopped. Normal settings restored."
        })
    }

    # Tab 4: System & Hardening Handlers
    $btnApplyHardening.Add_Click({
        & $script:LogToGui "=== APPLYING ALL SYSTEM & HARDENING TWEAKS ==="
        & $script:SetProgress 20
        Block-WpbtExecution
        Block-PeripheralBloat
        Remove-WindowsAI
        Set-SecurityUpdatesOnly
        & $script:SetProgress 50
        Enable-ClassicContextMenu
        Disable-StartMenuBing
        Disable-ExplorerAutoDiscovery
        Set-ShowFileExtensionsAndHidden
        & $script:SetProgress 75
        Enable-LongPaths
        Disable-LockScreen
        Enable-BsodVerbose
        Disable-ReservedStorage
        & $script:SetProgress 100
        & $script:LogToGui "[+] All hardening tweaks applied successfully!"
        Start-Sleep -Milliseconds 300
        & $script:SetProgress 0
    })

    # Individual 1-Click Tweak Action Helper
    function Register-QuickTweakButton($btnName, $tweakName, [scriptblock]$action) {
        $btn = $window.FindName($btnName)
        if ($btn) {
            $btn.Add_Click({
                & $script:LogToGui "[*] Applying $tweakName..."
                & $script:SetProgress 40
                & $action
                & $script:SetProgress 100
                & $script:LogToGui "[+] $tweakName applied successfully!"
                Start-Sleep -Milliseconds 200
                & $script:SetProgress 0
            })
        }
    }

    # 1-Click Tweak Activators: Gaming Tweaks
    Register-QuickTweakButton "BtnApply_GpuAuto" "GPU Auto-Tuning" { Optimize-GpuAuto }
    Register-QuickTweakButton "BtnApply_HardwareMsi" "Hardware MSI Mode" { Optimize-HardwareMsiMode }
    Register-QuickTweakButton "BtnApply_DisablePowerSaving" "Disable USB Sleep" { Disable-DevicePowerSaving }
    Register-QuickTweakButton "BtnApply_Mpo" "Disable MPO" { Disable-MultiplaneOverlay }
    Register-QuickTweakButton "BtnApply_MouseCurve" "Raw Mouse Input" { Set-MouseLinearCurve }
    Register-QuickTweakButton "BtnApply_InputLatency" "8000Hz Input Tuning" { Optimize-LatencyAndInput }
    Register-QuickTweakButton "BtnApply_CsrssPriority" "CSRSS Realtime I/O" { Optimize-CsrssPriority }
    Register-QuickTweakButton "BtnApply_CpuSystem" "CPU Gaming Quantum" { Optimize-CpuAndSystem }
    Register-QuickTweakButton "BtnApply_SvcHost" "SvcHost RAM Splitting" { Optimize-SvcHostSplitting }
    Register-QuickTweakButton "BtnApply_Network" "TCP/IP Gaming Stack" { Optimize-Network }
    Register-QuickTweakButton "BtnApply_WifiScan" "Wi-Fi Ping Shield" { Toggle-WifiAutoconfig }
    Register-QuickTweakButton "BtnApply_StartupDns" "Gaming DNS & Startup Tuning" { Optimize-StartupAndDns }
    Register-QuickTweakButton "BtnApply_GameHooks" "Esports Game Priority Hooks" { Apply-GameHooks }
    Register-QuickTweakButton "BtnApply_UltimatePower" "PumpkiN Esports Power Plan" { Invoke-PumpkiNEsportsPowerPlan }
    Register-QuickTweakButton "BtnApply_CoreUnpark" "100% CPU Core Unparking" { Invoke-CpuCoreUnparking }
    Register-QuickTweakButton "BtnApply_StripVisual" "Strip Visual Animations" { Strip-VisualEffects }
    Register-QuickTweakButton "BtnApply_EndTask" "Taskbar End Task" { Enable-EndTaskRightClick }
    Register-QuickTweakButton "BtnApply_StickyKeys" "Disable Sticky Keys" { Disable-StickyKeysPrompt }
    Register-QuickTweakButton "BtnApply_DebloatServices" "Debloat Services" { Debloat-BackgroundServices }
    Register-QuickTweakButton "BtnApply_DiskIo" "Optimize Disk I/O" { Optimize-DiskIO }
    Register-QuickTweakButton "BtnApply_CompactOs" "CompactOS Compression" { Enable-CompactOS }
    Register-QuickTweakButton "BtnApply_TakeOwnership" "Take Ownership Menu" { Enable-TakeOwnershipMenu }
    Register-QuickTweakButton "BtnApply_JunkTasks" "Disable Junk Tasks" { Disable-ScheduledJunkTasks }
    Register-QuickTweakButton "BtnApply_Privacy" "Disable Telemetry" { Harden-PrivacyTelemetry }
    Register-QuickTweakButton "BtnApply_DeepCache" "Deep Cache & Event Cleaner" { Invoke-DeepCacheCleaner }
    Register-QuickTweakButton "BtnApply_ShaderCache" "GPU Shader & Browser Cache Purge" { Invoke-ShaderAndBrowserCacheCleaner }
    Register-QuickTweakButton "BtnApply_AudioDpc" "Audio DPC & Anti-Popping" { Optimize-AudioDpcLatency }
    Register-QuickTweakButton "BtnApply_UsbxHci" "USB xHCI Realtime Thread" { Optimize-UsbLatencyAndBuffers }
    Register-QuickTweakButton "BtnResetDns" "Reset DNS to DHCP Defaults" { Reset-DnsToAutomatic }

    # Hardware MSI & Interrupt Audit Report
    $btnReportInterrupts = $window.FindName("BtnReport_Interrupts")
    if ($btnReportInterrupts) {
        $btnReportInterrupts.Add_Click({
            & $script:LogToGui "`n=== HARDWARE MSI & INTERRUPT AUDIT REPORT ==="
            try {
                $report = Get-HardwareInterruptReport
                & $script:LogToGui ("{0,-12} | {1,-5} | {2,-10} | {3}" -f "CATEGORY", "MSI", "PRIORITY", "CONTROLLER")
                & $script:LogToGui ("----------------------------------------------------------------------")
                foreach ($r in $report) {
                    $msiStr = if ($r.MSISupported) { "YES" } else { "NO" }
                    & $script:LogToGui ("{0,-12} | {1,-5} | {2,-10} | {3}" -f $r.Category, $msiStr, $r.Priority, $r.DeviceName)
                }
                & $script:LogToGui ("======================================================================")
                & $script:LogToGui "[OK] Hardware interrupt audit complete. Total controllers inspected: $($report.Count)"
            } catch {
                & $script:LogToGui "[!] Interrupt report error: $($_.Exception.Message)"
            }
        })
    }

    # Gaming DNS Benchmark & Auto-Apply Winner
    $btnBenchmarkDns = $window.FindName("BtnBenchmarkDns")
    if ($btnBenchmarkDns) {
        $btnBenchmarkDns.Add_Click({
            $btnBenchmarkDns.IsEnabled = $false
            & $script:LogToGui "[*] Starting Gaming DNS Benchmark across top providers..."
            & $script:SetProgress 20
            [System.Threading.ThreadPool]::QueueUserWorkItem({
                try {
                    $results = Test-GamingDnsBenchmark
                    $window.Dispatcher.Invoke([action]{
                        & $script:SetProgress 70
                        if ($results -and $results.Count -gt 0) {
                            $fastest = $results[0]
                            & $script:LogToGui "`n--- DNS BENCHMARK LEADERBOARD ---"
                            foreach ($r in $results) {
                                $pingStr = if ($r.AvgPingMs -lt 999) { "$($r.AvgPingMs) ms" } else { "TIMEOUT" }
                                & $script:LogToGui "  $($r.Name.PadRight(12)): $pingStr ($($r.Primary))"
                            }
                            & $script:LogToGui "[+] Fastest Provider: $($fastest.Name) ($($fastest.AvgPingMs) ms)"
                            & $script:LogToGui "[*] Auto-applying $($fastest.Name) DNS to active network adapters..."
                            Set-GamingDnsProvider -PrimaryDns $fastest.Primary -SecondaryDns $fastest.Secondary -ProviderName $fastest.Name
                            & $script:LogToGui "[+] Gaming DNS successfully configured to $($fastest.Name)!"
                        } else {
                            & $script:LogToGui "[!] No DNS ping responses received. Keeping current settings."
                        }
                        & $script:SetProgress 100
                        Start-Sleep -Milliseconds 200
                        & $script:SetProgress 0
                        $btnBenchmarkDns.IsEnabled = $true
                    })
                } catch {
                    $exMsg = $_.Exception.Message
                    $window.Dispatcher.Invoke([action]{
                        & $script:LogToGui "[!] DNS benchmark error: $exMsg"
                        & $script:SetProgress 0
                        $btnBenchmarkDns.IsEnabled = $true
                    })
                }
            })
        })
    }

    # 1-Click Tweak Activators: System & Hardening
    Register-QuickTweakButton "BtnApply_BlockWpbt" "Block WPBT Bloat" { Block-WpbtExecution }
    Register-QuickTweakButton "BtnApply_BlockPeripheral" "Block Peripheral Bloat" { Block-PeripheralBloat }
    Register-QuickTweakButton "BtnApply_RemoveAi" "Purge Windows AI" { Remove-WindowsAI }
    Register-QuickTweakButton "BtnApply_SecurityUpdatesOnly" "Security-Only Updates" { Set-SecurityUpdatesOnly }
    Register-QuickTweakButton "BtnApply_ClassicContext" "Classic Right-Click" { Enable-ClassicContextMenu }
    Register-QuickTweakButton "BtnApply_DisableBing" "Disable Web Search" { Disable-StartMenuBing }
    Register-QuickTweakButton "BtnApply_DisableAutoDiscovery" "Disable Auto-Discovery" { Disable-ExplorerAutoDiscovery }
    Register-QuickTweakButton "BtnApply_ShowExtensions" "Show File Extensions" { Set-ShowFileExtensionsAndHidden }
    Register-QuickTweakButton "BtnApply_RecycleBinIcon" "Pop Cat Recycle Bin" { Set-RecycleBinCustomIcon }
    Register-QuickTweakButton "BtnReset_RecycleBinIcon" "Default Recycle Bin" { Restore-RecycleBinDefaultIcon }
    Register-QuickTweakButton "BtnApply_EnableLongPaths" "Enable Long Paths" { Enable-LongPaths }
    Register-QuickTweakButton "BtnApply_DisableLockScreen" "Disable Lock Screen" { Disable-LockScreen }
    Register-QuickTweakButton "BtnApply_BsodVerbose" "Verbose BSOD" { Enable-BsodVerbose }
    Register-QuickTweakButton "BtnApply_DisableReservedStorage" "Reclaim Reserved Storage" { Disable-ReservedStorage }

    $masAction = {
        & $script:LogToGui "[*] Launching Microsoft Activation Scripts (MAS) in elevated terminal..."
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
    }
    $btnMasActivate.Add_Click($masAction)
    $btnMasActivateTop.Add_Click($masAction)

    $restoreAction = {
        & $script:LogToGui "[*] Creating Windows System Restore Point..."
        Create-RestorePoint
        & $script:LogToGui "[+] Restore point creation process completed."
    }
    $btnRestorePoint.Add_Click($restoreAction)
    $btnRestorePointTop.Add_Click($restoreAction)

    $btnRunDiagnostics.Add_Click({
        & $script:LogToGui "[*] Running System Diagnostics..."
        Run-Diagnostics
    })

    # Initial Log Greeting & Status
    & $updateStandbyStatus
    $hw = Get-HardwareProfile
    & $script:LogToGui "PumpkiN Ultimate Gaming Optimizer & Software Suite v2.5.0 initialized."
    & $script:LogToGui "Hardware detected: $($hw.CpuName) | RAM: $($hw.TotalRamGb) GB"
    & $script:LogToGui "Select tweaks or software to install, then click the action button."

    # Live Hardware Telemetry DispatcherTimer
    $telemetryTimer = New-Object System.Windows.Threading.DispatcherTimer
    $telemetryTimer.Interval = [TimeSpan]::FromSeconds(2.5)
    $updateTelemetryAction = {
        try {
            $t = Get-LiveHardwareTelemetry
            if ($txtLiveCpu) { $txtLiveCpu.Text = "$($t.CpuLoad)%" }
            if ($txtLiveRam) { $txtLiveRam.Text = "$($t.UsedRamGb)/$($t.TotalRamGb) GB ($($t.RamPercent)%)" }
            if ($txtLivePing) {
                $txtLivePing.Text = if ($t.PingMs -ge 0) { "$($t.PingMs) ms" } else { "--" }
            }
            if ($txtLiveBooster) {
                $txtLiveBooster.Text = $t.BoosterStatus
                if ($t.BoosterStatus -like "BOOST*") {
                    $txtLiveBooster.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88")
                } elseif ($t.BoosterStatus -like "ACTIVE*") {
                    $txtLiveBooster.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#A855F7")
                } else {
                    $txtLiveBooster.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
                }
            }
            & $updateDaemonStatusUI
        } catch {}
    }
    $telemetryTimer.Add_Tick($updateTelemetryAction)
    $telemetryTimer.Start()
    & $updateTelemetryAction

    # Clean shutdown on window close
    $window.Add_Closing({
        try {
            if ($telemetryTimer) { $telemetryTimer.Stop() }
            Stop-SmartGameBoosterDaemon
        } catch {}
    })

    # Launch GUI Window
    [void]$window.ShowDialog()
}

# ==============================================================================