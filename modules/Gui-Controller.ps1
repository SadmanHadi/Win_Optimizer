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
    $btnBeastMode       = $window.FindName("BtnBeastMode")

    $btnPurgeStandby    = $window.FindName("BtnPurgeStandby")
    $btnToggleWifiScan  = $window.FindName("BtnToggleWifiScan")
    $btnApplyGameHooks  = $window.FindName("BtnApplyGameHooks")

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
    $chkMpo             = $window.FindName("ChkMpo")
    $chkMouseCurve      = $window.FindName("ChkMouseCurve")
    $chkInputLatency    = $window.FindName("ChkInputLatency")
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
        & $script:LogToGui "=== APPLYING SELECTED GAMING OPTIMIZATIONS ==="
        & $script:SetProgress 10

        if ($chkGpuAuto.IsChecked) { & $script:LogToGui "[*] Running GPU Auto-Optimization..."; Optimize-GpuAuto }
        if ($chkMpo.IsChecked) { & $script:LogToGui "[*] Disabling Multiplane Overlay (MPO)..."; Disable-MultiplaneOverlay }
        if ($chkMouseCurve.IsChecked) { & $script:LogToGui "[*] Setting 1:1 Linear Mouse Curve..."; Set-MouseLinearCurve }
        & $script:SetProgress 30

        if ($chkInputLatency.IsChecked) { & $script:LogToGui "[*] Optimizing 8000Hz Input & Timers..."; Optimize-LatencyAndInput }
        if ($chkCpuSystem.IsChecked) { & $script:LogToGui "[*] Optimizing CPU Scheduling & Quantum..."; Optimize-CpuAndSystem }
        if ($chkSvcHost.IsChecked) { & $script:LogToGui "[*] Tuning SvcHost Process Splitting..."; Optimize-SvcHostSplitting }
        & $script:SetProgress 55

        if ($chkNetwork.IsChecked) { & $script:LogToGui "[*] Optimizing TCP/IP Network Stack..."; Optimize-Network }
        if ($chkWifiScan.IsChecked) { & $script:LogToGui "[*] Disabling Wi-Fi Background Scanning..."; Toggle-WifiAutoconfig }
        & $script:SetProgress 70

        if ($chkUltimatePower.IsChecked) { & $script:LogToGui "[*] Activating Ultimate Performance Power Plan..."; Enable-UltimatePerformancePlan }
        if ($chkStripVisual.IsChecked) { & $script:LogToGui "[*] Stripping Visual Effects..."; Strip-VisualEffects }
        if ($chkEndTask.IsChecked) { & $script:LogToGui "[*] Enabling Taskbar End Task..."; Enable-EndTaskRightClick }
        if ($chkStickyKeys.IsChecked) { & $script:LogToGui "[*] Disabling Sticky Keys Popups..."; Disable-StickyKeysPrompt }
        & $script:SetProgress 85

        if ($chkDebloatServices.IsChecked) { & $script:LogToGui "[*] Debloating Background Services..."; Debloat-BackgroundServices }
        if ($chkDiskIo.IsChecked) { & $script:LogToGui "[*] Optimizing Disk I/O..."; Optimize-DiskIO }
        if ($chkJunkTasks.IsChecked) { & $script:LogToGui "[*] Disabling Junk Scheduled Tasks..."; Disable-ScheduledJunkTasks }
        if ($chkPrivacy.IsChecked) { & $script:LogToGui "[*] Hardening Privacy & Disabling Telemetry..."; Harden-PrivacyTelemetry }

        & $script:SetProgress 100
        & $script:LogToGui "[+] ALL SELECTED GAMING OPTIMIZATIONS APPLIED SUCCESSFULLY!"
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

    $btnBeastMode.Add_Click({
        & $script:LogToGui "ðŸ”¥ ENGAGING FULL BEAST MODE SUITE..."
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
        & $script:LogToGui "ðŸ”¥ [OK] FULL BEAST MODE ENGAGED  --  ALL COMPETITIVE TWEAKS ACTIVE!"
        & $script:LogToGui "================================================================================"
        Start-Sleep -Milliseconds 300
        & $script:SetProgress 0
    })

    # Tab 3: Match Booster Handlers
    $btnPurgeStandby.Add_Click({
        & $script:LogToGui "[*] Purging Windows Standby List Cache..."
        Boost-CompetitiveMatch
        & $script:LogToGui "[+] Standby memory purged successfully! Memory freed for game."
    })

    $btnToggleWifiScan.Add_Click({
        Toggle-WifiAutoconfig
        & $script:LogToGui "[+] Wi-Fi AutoConfig state toggled."
    })

    $btnApplyGameHooks.Add_Click({
        & $script:LogToGui "[*] Installing IFEO High-Priority Hooks for esports titles..."
        Apply-GameHooks
        & $script:LogToGui "[+] Esports Priority Hooks installed for CS2, Valorant, Apex, Fortnite, COD!"
    })

    # Tab 4: System & Hardening Handlers
    $btnApplyHardening.Add_Click({
        & $script:LogToGui "=== APPLYING SYSTEM & HARDENING TWEAKS ==="
        if ($chkBlockWpbt.IsChecked) { Block-WpbtExecution }
        if ($chkBlockPeripheral.IsChecked) { Block-PeripheralBloat }
        if ($chkRemoveAi.IsChecked) { Remove-WindowsAI }
        if ($chkSecurityUpdatesOnly.IsChecked) { Set-SecurityUpdatesOnly }
        if ($chkClassicContext.IsChecked) { Enable-ClassicContextMenu }
        if ($chkDisableBing.IsChecked) { Disable-StartMenuBing }
        if ($chkDisableAutoDiscovery.IsChecked) { Disable-ExplorerAutoDiscovery }
        if ($chkShowExtensions.IsChecked) { Set-ShowFileExtensionsAndHidden }
        if ($chkEnableLongPaths.IsChecked) { Enable-LongPaths }
        if ($chkDisableLockScreen.IsChecked) { Disable-LockScreen }
        if ($chkBsodVerbose.IsChecked) { Enable-BsodVerbose }
        if ($chkDisableReservedStorage.IsChecked) { Disable-ReservedStorage }
        & $script:LogToGui "[+] Selected hardening tweaks applied successfully!"
    })

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

    # Initial Log Greeting
    $hw = Get-HardwareProfile
    & $script:LogToGui "PumpkiN Ultimate Gaming Optimizer & Software Suite v2.5.0 initialized."
    & $script:LogToGui "Hardware detected: $($hw.CpuName) | RAM: $($hw.TotalRamGb) GB"
    & $script:LogToGui "Select tweaks or software to install, then click the action button."

    # Launch GUI Window
    [void]$window.ShowDialog()
}

# ==============================================================================