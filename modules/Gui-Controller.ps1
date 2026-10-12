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

    # Load 3D Pumpkin Brand Logo & Window Icon (.ico / .png)
    $imgLogo = $window.FindName("ImgAppLogo")
    $baseDir = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { Get-Location }
    $logoCandidates = [System.Collections.Generic.List[string]]::new()
    $logoCandidates.Add((Join-Path $baseDir "LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.ico"))
    $logoCandidates.Add((Join-Path (Get-Location) "LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.ico"))
    $logoCandidates.Add((Join-Path $baseDir "LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.png"))
    $logoCandidates.Add((Join-Path (Get-Location) "LOGO\7a0eb4c4-5e6f-4be3-9554-29661ef7f4ff.png"))

    # Dynamic search in LOGO directories for any .ico or .png
    $logoDirs = @((Join-Path $baseDir "LOGO"), (Join-Path (Get-Location) "LOGO"))
    foreach ($ld in $logoDirs) {
        if ($ld -and (Test-Path $ld)) {
            $discovered = Get-ChildItem -Path $ld -Filter "*.ico" -ErrorAction SilentlyContinue
            if (-not $discovered) {
                $discovered = Get-ChildItem -Path $ld -Filter "*.png" -ErrorAction SilentlyContinue
            }
            if ($discovered) {
                foreach ($df in $discovered) {
                    if (-not $logoCandidates.Contains($df.FullName)) {
                        $logoCandidates.Add($df.FullName)
                    }
                }
            }
        }
    }

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
            } catch {
                try {
                    $frame = [System.Windows.Media.Imaging.BitmapFrame]::Create((New-Object System.Uri($cand, [System.UriKind]::Absolute)))
                    if ($imgLogo) { $imgLogo.Source = $frame }
                    $window.Icon = $frame
                    break
                } catch {}
            }
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
    $btnExitTop         = $window.FindName("BtnExitTop")

    $btnInstallTrafficMonitor       = $window.FindName("BtnInstallTrafficMonitor")
    $btnInstallMiSansFonts          = $window.FindName("BtnInstallMiSansFonts")
    $btnApplyTrafficMonitorConfig   = $window.FindName("BtnApplyTrafficMonitorConfig")
    $btnLaunchTrafficMonitor        = $window.FindName("BtnLaunchTrafficMonitor")

    $txtConsole         = $window.FindName("TxtConsole")
    $txtStatus          = $window.FindName("TxtStatus")
    $progressBar        = $window.FindName("MainProgressBar")
    $btnClearConsole    = $window.FindName("BtnClearConsole")

    # Optimization Score & Audit Dashboard Controls
    $txtScorePercent          = $window.FindName("TxtScorePercent")
    $txtScoreGrade            = $window.FindName("TxtScoreGrade")
    $txtActiveTweakRatio      = $window.FindName("TxtActiveTweakRatio")
    $txtScorePercentTab4      = $window.FindName("TxtScorePercentTab4")
    $txtScoreGradeTab4        = $window.FindName("TxtScoreGradeTab4")
    $txtActiveTweakRatioTab4  = $window.FindName("TxtActiveTweakRatioTab4")
    $btnScanSystemStateBanner = $window.FindName("BtnScanSystemStateBanner")
    $btnScanSystemStateTab4Banner = $window.FindName("BtnScanSystemStateTab4Banner")
    $btnScanSystemStateTab4   = $window.FindName("BtnScanSystemStateTab4")
    $btnApplyUnappliedBanner  = $window.FindName("BtnApplyUnappliedBanner")
    $btnApplyUnappliedTab2    = $window.FindName("BtnApplyUnappliedTab2")
    $btnApplyUnappliedHardening = $window.FindName("BtnApplyUnappliedHardening")
    $btnApplyUnappliedHardeningBanner = $window.FindName("BtnApplyUnappliedHardeningBanner")
    $btnRevertDefaultsBanner  = $window.FindName("BtnRevertDefaultsBanner")
    $btnRevertDefaultsTab4    = $window.FindName("BtnRevertDefaultsTab4")

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

    # Build Application Cards Dynamically with Fast [Type]::new() Constructors
    $script:AllAppCards = [System.Collections.Generic.List[PSCustomObject]]::new()
    $brushNormalBg     = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#161E2B")
    $brushHoverBg      = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
    $brushNormalBorder = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#26354A")
    $brushHoverBorder  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00D2FF")
    $brushCyan         = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00D2FF")
    $brushTextDim      = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
    $brushTextSub      = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#64748B")
    $badgeBg           = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0F141C")
    $whiteBrush        = [System.Windows.Media.Brushes]::White
    $handCursor        = [System.Windows.Input.Cursors]::Hand

    # Reusable layout metrics to eliminate redundant object allocations
    $thick1      = [System.Windows.Thickness]::new(1)
    $thick4      = [System.Windows.Thickness]::new(4, 1, 4, 1)
    $thick5      = [System.Windows.Thickness]::new(5)
    $thick10     = [System.Windows.Thickness]::new(10)
    $thickChk    = [System.Windows.Thickness]::new(0, 4, 10, 0)
    $thickDesc   = [System.Windows.Thickness]::new(0, 3, 0, 0)
    $thickBadge  = [System.Windows.Thickness]::new(4, 0, 0, 0)
    $corn6       = [System.Windows.CornerRadius]::new(6)
    $corn3       = [System.Windows.CornerRadius]::new(3)
    $starGrid    = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
    $autoGrid    = [System.Windows.GridLength]::Auto

    foreach ($app in $Global:AppCatalog) {
        $card = [System.Windows.Controls.Border]::new()
        $card.Width = 275
        $card.Height = 110
        $card.Background = $brushNormalBg
        $card.BorderBrush = $brushNormalBorder
        $card.BorderThickness = $thick1
        $card.CornerRadius = $corn6
        $card.Margin = $thick5
        $card.Padding = $thick10
        $card.Cursor = $handCursor

        $grid = [System.Windows.Controls.Grid]::new()
        $col0 = [System.Windows.Controls.ColumnDefinition]::new(); $col0.Width = $autoGrid
        $col1 = [System.Windows.Controls.ColumnDefinition]::new(); $col1.Width = $starGrid
        [void]$grid.ColumnDefinitions.Add($col0)
        [void]$grid.ColumnDefinitions.Add($col1)

        $chk = [System.Windows.Controls.CheckBox]::new()
        $chk.Margin = $thickChk
        $chk.Tag = $app.WingetId
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

        $titleBlock = [System.Windows.Controls.TextBlock]::new()
        $titleBlock.Text = $app.Name
        $titleBlock.FontWeight = [System.Windows.FontWeights]::SemiBold
        $titleBlock.FontSize = 12
        $titleBlock.Foreground = $whiteBrush
        $titleBlock.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
        [System.Windows.Controls.Grid]::SetColumn($titleBlock, 0)
        [void]$topRow.Children.Add($titleBlock)

        $catBadge = [System.Windows.Controls.Border]::new()
        $catBadge.Background = $badgeBg
        $catBadge.BorderBrush = $brushCyan
        $catBadge.BorderThickness = $thick1
        $catBadge.CornerRadius = $corn3
        $catBadge.Padding = $thick4
        $catBadge.Margin = $thickBadge
        $catText = [System.Windows.Controls.TextBlock]::new()
        $catText.Text = $app.Category
        $catText.FontSize = 9
        $catText.Foreground = $brushCyan
        $catBadge.Child = $catText
        [System.Windows.Controls.Grid]::SetColumn($catBadge, 1)
        [void]$topRow.Children.Add($catBadge)

        [void]$sp.Children.Add($topRow)

        $descBlock = [System.Windows.Controls.TextBlock]::new()
        $descBlock.Text = $app.Description
        $descBlock.Foreground = $brushTextDim
        $descBlock.FontSize = 10
        $descBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $descBlock.MaxHeight = 32
        $descBlock.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
        $descBlock.Margin = $thickDesc
        [void]$sp.Children.Add($descBlock)

        $idBlock = [System.Windows.Controls.TextBlock]::new()
        $idBlock.Text = $app.WingetId
        $idBlock.Foreground = $brushTextSub
        $idBlock.FontSize = 9
        $idBlock.Margin = $thickDesc
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
        Optimize-DeviceManager
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
        if ($script:UpdateGuiAuditStatus) { & $script:UpdateGuiAuditStatus }
        & $script:LogToGui "[+] ALL 23 GAMING OPTIMIZATIONS APPLIED SUCCESSFULLY!"
        Start-Sleep -Milliseconds 300
        & $script:SetProgress 0
    })

    $btnRevertDefaults.Add_Click({
        & $script:LogToGui "[*] Reverting all settings to Windows defaults..."
        & $script:SetProgress 50
        Restore-Defaults
        & $script:SetProgress 100
        if ($script:UpdateGuiAuditStatus) { & $script:UpdateGuiAuditStatus }
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

    if ($btnBeastMode) {
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
            if ($script:UpdateGuiAuditStatus) { & $script:UpdateGuiAuditStatus }
            & $script:LogToGui "================================================================================"
            & $script:LogToGui "[OK] FULL BEAST MODE ENGAGED  --  ALL COMPETITIVE TWEAKS ACTIVE!"
            & $script:LogToGui "================================================================================"
            Start-Sleep -Milliseconds 300
            & $script:SetProgress 0
        })
    }

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
        & $script:LogToGui "[+] Esports Priority Hooks installed for CS2, Valorant, Apex, PUBG, Fortnite, COD!"
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
        if ($script:UpdateGuiAuditStatus) { & $script:UpdateGuiAuditStatus }
        & $script:LogToGui "[+] All hardening tweaks applied successfully!"
        Start-Sleep -Milliseconds 300
        & $script:SetProgress 0
    })

    # Master Brushes for Audit Status Badges
    $brushOptimalBg     = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#002D1E")
    $brushOptimalBorder = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88")
    $brushOptimalText   = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88")
    $brushNeededBg      = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0F141C")
    $brushNeededBorder  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#26354A")
    $brushNeededText    = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00D2FF")

    # Master Tweak Registry: Schema maps Audit Keys to Apply, Rollback, Badges and Buttons
    $script:TweakDefinitions = @(
        # 1. Gaming & Hardware Performance
        @{ Key="GpuAuto"; Title="GPU Auto-Tuning"; Category="Gaming"; Apply={ Optimize-GpuAuto }; Rollback={ Restore-Defaults }; ApplyBtn="BtnApply_GpuAuto"; RollbackBtn="BtnRollback_GpuAuto"; Badge="Badge_GpuAuto"; TxtBadge="TxtBadge_GpuAuto" },
        @{ Key="HardwareMsi"; Title="Hardware MSI Mode"; Category="Gaming"; Apply={ Optimize-HardwareMsiMode }; Rollback={ Restore-Defaults }; ApplyBtn="BtnApply_HardwareMsi"; RollbackBtn="BtnRollback_HardwareMsi"; Badge="Badge_HardwareMsi"; TxtBadge="TxtBadge_HardwareMsi" },
        @{ Key="DisablePowerSaving"; Title="Disable USB Sleep"; Category="Gaming"; Apply={ Disable-DevicePowerSaving }; Rollback={ Restore-Defaults }; ApplyBtn="BtnApply_DisablePowerSaving"; RollbackBtn="BtnRollback_DisablePowerSaving"; Badge="Badge_DisablePowerSaving"; TxtBadge="TxtBadge_DisablePowerSaving" },
        @{ Key="Mpo"; Title="Disable MPO"; Category="Gaming"; Apply={ Disable-MultiplaneOverlay }; Rollback={ Restore-MultiplaneOverlay }; ApplyBtn="BtnApply_Mpo"; RollbackBtn="BtnRollback_Mpo"; Badge="Badge_Mpo"; TxtBadge="TxtBadge_Mpo" },
        @{ Key="MouseCurve"; Title="Raw Mouse Input"; Category="Gaming"; Apply={ Set-MouseLinearCurve }; Rollback={ Restore-MouseLinearCurve }; ApplyBtn="BtnApply_MouseCurve"; RollbackBtn="BtnRollback_MouseCurve"; Badge="Badge_MouseCurve"; TxtBadge="TxtBadge_MouseCurve" },
        @{ Key="InputLatency"; Title="8000Hz Input Tuning"; Category="Gaming"; Apply={ Optimize-LatencyAndInput }; Rollback={ Restore-AudioDpcAndUsbLatency }; ApplyBtn="BtnApply_InputLatency"; RollbackBtn="BtnRollback_InputLatency"; Badge="Badge_InputLatency"; TxtBadge="TxtBadge_InputLatency" },
        @{ Key="CsrssPriority"; Title="CSRSS Realtime I/O"; Category="Gaming"; Apply={ Optimize-CsrssPriority }; Rollback={ Restore-CsrssPriority }; ApplyBtn="BtnApply_CsrssPriority"; RollbackBtn="BtnRollback_CsrssPriority"; Badge="Badge_CsrssPriority"; TxtBadge="TxtBadge_CsrssPriority" },
        @{ Key="CpuSystem"; Title="CPU Gaming Quantum"; Category="Gaming"; Apply={ Optimize-CpuAndSystem }; Rollback={ Restore-CpuAndSystem }; ApplyBtn="BtnApply_CpuSystem"; RollbackBtn="BtnRollback_CpuSystem"; Badge="Badge_CpuSystem"; TxtBadge="TxtBadge_CpuSystem" },
        @{ Key="SvcHost"; Title="SvcHost RAM Splitting"; Category="Gaming"; Apply={ Optimize-SvcHostSplitting }; Rollback={ Restore-SvcHostSplitting }; ApplyBtn="BtnApply_SvcHost"; RollbackBtn="BtnRollback_SvcHost"; Badge="Badge_SvcHost"; TxtBadge="TxtBadge_SvcHost" },
        @{ Key="Network"; Title="TCP/IP Gaming Stack"; Category="Gaming"; Apply={ Optimize-Network }; Rollback={ Restore-Defaults }; ApplyBtn="BtnApply_Network"; RollbackBtn="BtnRollback_Network"; Badge="Badge_Network"; TxtBadge="TxtBadge_Network" },
        @{ Key="WifiScan"; Title="Wi-Fi Ping Shield"; Category="Gaming"; Apply={ Toggle-WifiAutoconfig }; Rollback={ Toggle-WifiAutoconfig }; ApplyBtn="BtnApply_WifiScan"; RollbackBtn="BtnRollback_WifiScan"; Badge="Badge_WifiScan"; TxtBadge="TxtBadge_WifiScan" },
        @{ Key="StartupDns"; Title="Gaming DNS & Startup Tuning"; Category="Gaming"; Apply={ Optimize-StartupAndDns }; Rollback={ Reset-DnsToAutomatic }; ApplyBtn="BtnApply_StartupDns"; RollbackBtn="BtnRollback_StartupDns"; Badge="Badge_StartupDns"; TxtBadge="TxtBadge_StartupDns" },
        @{ Key="GameHooks"; Title="Esports Game Priority Hooks"; Category="Gaming"; Apply={ Apply-GameHooks }; Rollback={ Restore-Defaults }; ApplyBtn="BtnApply_GameHooks"; RollbackBtn="BtnRollback_GameHooks"; Badge="Badge_GameHooks"; TxtBadge="TxtBadge_GameHooks" },
        @{ Key="UltimatePower"; Title="PumpkiN Esports Power Plan"; Category="Gaming"; Apply={ Invoke-PumpkiNEsportsPowerPlan }; Rollback={ Restore-BalancedPowerPlan }; ApplyBtn="BtnApply_UltimatePower"; RollbackBtn="BtnRollback_UltimatePower"; Badge="Badge_UltimatePower"; TxtBadge="TxtBadge_UltimatePower" },
        @{ Key="CoreUnpark"; Title="100% CPU Core Unparking"; Category="Gaming"; Apply={ Invoke-CpuCoreUnparking }; Rollback={ Restore-CpuCoreParking }; ApplyBtn="BtnApply_CoreUnpark"; RollbackBtn="BtnRollback_CoreUnpark"; Badge="Badge_CoreUnpark"; TxtBadge="TxtBadge_CoreUnpark" },
        @{ Key="StripVisual"; Title="Strip Visual Animations"; Category="Gaming"; Apply={ Strip-VisualEffects }; Rollback={ Restore-VisualEffects }; ApplyBtn="BtnApply_StripVisual"; RollbackBtn="BtnRollback_StripVisual"; Badge="Badge_StripVisual"; TxtBadge="TxtBadge_StripVisual" },
        @{ Key="EndTask"; Title="Taskbar End Task"; Category="Gaming"; Apply={ Enable-EndTaskRightClick }; Rollback={ Restore-EndTaskRightClick }; ApplyBtn="BtnApply_EndTask"; RollbackBtn="BtnRollback_EndTask"; Badge="Badge_EndTask"; TxtBadge="TxtBadge_EndTask" },
        @{ Key="StickyKeys"; Title="Disable Sticky Keys"; Category="Gaming"; Apply={ Disable-StickyKeysPrompt }; Rollback={ Restore-StickyKeysPrompt }; ApplyBtn="BtnApply_StickyKeys"; RollbackBtn="BtnRollback_StickyKeys"; Badge="Badge_StickyKeys"; TxtBadge="TxtBadge_StickyKeys" },
        @{ Key="CompactMetrics"; Title="Compact Window Metrics"; Category="Gaming"; Apply={ Set-CompactWindowMetrics }; Rollback={ Restore-CompactWindowMetrics }; ApplyBtn="BtnApply_CompactMetrics"; RollbackBtn="BtnReset_CompactMetrics"; Badge="Badge_CompactMetrics"; TxtBadge="TxtBadge_CompactMetrics" },
        @{ Key="DebloatServices"; Title="Debloat Services"; Category="Gaming"; Apply={ Debloat-BackgroundServices }; Rollback={ Restore-BackgroundServices }; ApplyBtn="BtnApply_DebloatServices"; RollbackBtn="BtnRollback_DebloatServices"; Badge="Badge_DebloatServices"; TxtBadge="TxtBadge_DebloatServices" },
        @{ Key="DiskIo"; Title="Optimize Disk I/O"; Category="Gaming"; Apply={ Optimize-DiskIO }; Rollback={ Restore-DiskIO }; ApplyBtn="BtnApply_DiskIo"; RollbackBtn="BtnRollback_DiskIo"; Badge="Badge_DiskIo"; TxtBadge="TxtBadge_DiskIo" },
        @{ Key="CompactOs"; Title="CompactOS Compression"; Category="Gaming"; Apply={ Enable-CompactOS }; Rollback={ Disable-CompactOS }; ApplyBtn="BtnApply_CompactOs"; RollbackBtn="BtnRollback_CompactOs"; Badge="Badge_CompactOs"; TxtBadge="TxtBadge_CompactOs" },
        @{ Key="TakeOwnership"; Title="Take Ownership Menu"; Category="Gaming"; Apply={ Enable-TakeOwnershipMenu }; Rollback={ Disable-TakeOwnershipMenu }; ApplyBtn="BtnApply_TakeOwnership"; RollbackBtn="BtnRollback_TakeOwnership"; Badge="Badge_TakeOwnership"; TxtBadge="TxtBadge_TakeOwnership" },
        @{ Key="JunkTasks"; Title="Disable Junk Tasks"; Category="Gaming"; Apply={ Disable-ScheduledJunkTasks }; Rollback={ Restore-ScheduledJunkTasks }; ApplyBtn="BtnApply_JunkTasks"; RollbackBtn="BtnRollback_JunkTasks"; Badge="Badge_JunkTasks"; TxtBadge="TxtBadge_JunkTasks" },
        @{ Key="Privacy"; Title="Disable Telemetry"; Category="Gaming"; Apply={ Harden-PrivacyTelemetry }; Rollback={ Restore-PrivacyTelemetry }; ApplyBtn="BtnApply_Privacy"; RollbackBtn="BtnRollback_Privacy"; Badge="Badge_Privacy"; TxtBadge="TxtBadge_Privacy" },
        @{ Key="AudioDpc"; Title="Audio DPC & Anti-Popping"; Category="Gaming"; Apply={ Optimize-AudioDpcLatency }; Rollback={ Restore-AudioDpcAndUsbLatency }; ApplyBtn="BtnApply_AudioDpc"; RollbackBtn="BtnRollback_AudioDpc"; Badge="Badge_AudioDpc"; TxtBadge="TxtBadge_AudioDpc" },
        @{ Key="UsbxHci"; Title="USB xHCI Realtime Thread"; Category="Gaming"; Apply={ Optimize-UsbLatencyAndBuffers }; Rollback={ Restore-AudioDpcAndUsbLatency }; ApplyBtn="BtnApply_UsbxHci"; RollbackBtn="BtnRollback_UsbxHci"; Badge="Badge_UsbxHci"; TxtBadge="TxtBadge_UsbxHci" },
        @{ Key="DeviceManager"; Title="Device Manager Tuning"; Category="Gaming"; Apply={ Optimize-DeviceManager }; Rollback={ Restore-DeviceManager }; ApplyBtn="BtnApply_DeviceManager"; RollbackBtn="BtnRollback_DeviceManager"; Badge="Badge_DeviceManager"; TxtBadge="TxtBadge_DeviceManager" },

        # 2. Hardening & Security Tweaks
        @{ Key="BlockWpbt"; Title="Block WPBT Bloat"; Category="Hardening"; Apply={ Block-WpbtExecution }; Rollback={ Restore-WpbtExecution }; ApplyBtn="BtnApply_BlockWpbt"; RollbackBtn="BtnRollback_BlockWpbt"; Badge="Badge_BlockWpbt"; TxtBadge="TxtBadge_BlockWpbt" },
        @{ Key="BlockPeripheral"; Title="Block Peripheral Bloat"; Category="Hardening"; Apply={ Block-PeripheralBloat }; Rollback={ Restore-PeripheralBloat }; ApplyBtn="BtnApply_BlockPeripheral"; RollbackBtn="BtnRollback_BlockPeripheral"; Badge="Badge_BlockPeripheral"; TxtBadge="TxtBadge_BlockPeripheral" },
        @{ Key="RemoveAi"; Title="Purge Windows AI"; Category="Hardening"; Apply={ Remove-WindowsAI }; Rollback={ Restore-WindowsAI }; ApplyBtn="BtnApply_RemoveAi"; RollbackBtn="BtnRollback_RemoveAi"; Badge="Badge_RemoveAi"; TxtBadge="TxtBadge_RemoveAi" },
        @{ Key="SecurityUpdatesOnly"; Title="Security-Only Updates"; Category="Hardening"; Apply={ Set-SecurityUpdatesOnly }; Rollback={ Restore-SecurityUpdatesOnly }; ApplyBtn="BtnApply_SecurityUpdatesOnly"; RollbackBtn="BtnRollback_SecurityUpdatesOnly"; Badge="Badge_SecurityUpdatesOnly"; TxtBadge="TxtBadge_SecurityUpdatesOnly" },
        @{ Key="ClassicContext"; Title="Classic Right-Click"; Category="Hardening"; Apply={ Enable-ClassicContextMenu }; Rollback={ Restore-ClassicContextMenu }; ApplyBtn="BtnApply_ClassicContext"; RollbackBtn="BtnRollback_ClassicContext"; Badge="Badge_ClassicContext"; TxtBadge="TxtBadge_ClassicContext" },
        @{ Key="DisableBing"; Title="Disable Web Search"; Category="Hardening"; Apply={ Disable-StartMenuBing }; Rollback={ Restore-StartMenuBing }; ApplyBtn="BtnApply_DisableBing"; RollbackBtn="BtnRollback_DisableBing"; Badge="Badge_DisableBing"; TxtBadge="TxtBadge_DisableBing" },
        @{ Key="DisableAutoDiscovery"; Title="Disable Auto-Discovery"; Category="Hardening"; Apply={ Disable-ExplorerAutoDiscovery }; Rollback={ Restore-ExplorerAutoDiscovery }; ApplyBtn="BtnApply_DisableAutoDiscovery"; RollbackBtn="BtnRollback_DisableAutoDiscovery"; Badge="Badge_DisableAutoDiscovery"; TxtBadge="TxtBadge_DisableAutoDiscovery" },
        @{ Key="ShowExtensions"; Title="Show File Extensions"; Category="Hardening"; Apply={ Set-ShowFileExtensionsAndHidden }; Rollback={ Restore-ShowFileExtensionsAndHidden }; ApplyBtn="BtnApply_ShowExtensions"; RollbackBtn="BtnRollback_ShowExtensions"; Badge="Badge_ShowExtensions"; TxtBadge="TxtBadge_ShowExtensions" },
        @{ Key="DisableAds"; Title="Disable Windows Ads"; Category="Hardening"; Apply={ Disable-WindowsAds }; Rollback={ Enable-WindowsAds }; ApplyBtn="BtnApply_DisableAds"; RollbackBtn="BtnReset_DisableAds"; Badge="Badge_DisableAds"; TxtBadge="TxtBadge_DisableAds" },
        @{ Key="NoShortcutArrows"; Title="Remove Shortcut Arrows"; Category="Hardening"; Apply={ Disable-ShortcutArrow }; Rollback={ Restore-ShortcutArrow }; ApplyBtn="BtnApply_NoShortcutArrows"; RollbackBtn="BtnReset_ShortcutArrows"; Badge="Badge_NoShortcutArrows"; TxtBadge="TxtBadge_NoShortcutArrows" },
        @{ Key="EnableLongPaths"; Title="Enable Long Paths"; Category="Hardening"; Apply={ Enable-LongPaths }; Rollback={ Restore-LongPaths }; ApplyBtn="BtnApply_EnableLongPaths"; RollbackBtn="BtnRollback_EnableLongPaths"; Badge="Badge_EnableLongPaths"; TxtBadge="TxtBadge_EnableLongPaths" },
        @{ Key="DisableLockScreen"; Title="Disable Lock Screen"; Category="Hardening"; Apply={ Disable-LockScreen }; Rollback={ Restore-LockScreen }; ApplyBtn="BtnApply_DisableLockScreen"; RollbackBtn="BtnRollback_DisableLockScreen"; Badge="Badge_DisableLockScreen"; TxtBadge="TxtBadge_DisableLockScreen" },
        @{ Key="BsodVerbose"; Title="Verbose BSOD"; Category="Hardening"; Apply={ Enable-BsodVerbose }; Rollback={ Restore-BsodVerbose }; ApplyBtn="BtnApply_BsodVerbose"; RollbackBtn="BtnRollback_BsodVerbose"; Badge="Badge_BsodVerbose"; TxtBadge="TxtBadge_BsodVerbose" },
        @{ Key="DisableReservedStorage"; Title="Reclaim Reserved Storage"; Category="Hardening"; Apply={ Disable-ReservedStorage }; Rollback={ Restore-ReservedStorage }; ApplyBtn="BtnApply_DisableReservedStorage"; RollbackBtn="BtnRollback_DisableReservedStorage"; Badge="Badge_DisableReservedStorage"; TxtBadge="TxtBadge_DisableReservedStorage" },
        @{ Key="BitLocker"; Title="Turn Off BitLocker"; Category="Hardening"; Apply={ Disable-BitLockerPermanently }; Rollback={ Restore-BitLockerDefaults }; ApplyBtn="BtnApply_BitLocker"; RollbackBtn="BtnRollback_BitLocker"; Badge="Badge_BitLocker"; TxtBadge="TxtBadge_BitLocker" },

        # 3. Windows 11 Exclusives & Shell Usability
        @{ Key="VbsSecurity"; Title="Disable VBS Security"; Category="Shell"; Apply={ Disable-VbsSecurity }; Rollback={ Restore-VbsSecurity }; ApplyBtn="BtnApply_VbsSecurity"; RollbackBtn="BtnRollback_VbsSecurity"; Badge="Badge_VbsSecurity"; TxtBadge="TxtBadge_VbsSecurity" },
        @{ Key="TaskbarLeft"; Title="Align Taskbar to Left"; Category="Shell"; Apply={ Set-TaskbarLeftAlign }; Rollback={ Restore-TaskbarAlignmentCenter }; ApplyBtn="BtnApply_TaskbarLeft"; RollbackBtn="BtnRollback_TaskbarLeft"; Badge="Badge_TaskbarLeft"; TxtBadge="TxtBadge_TaskbarLeft" },
        @{ Key="RecommendedStart"; Title="Hide Start Recommended"; Category="Shell"; Apply={ Disable-RecommendedStartSection }; Rollback={ Restore-StartMenuRecommended }; ApplyBtn="BtnApply_RecommendedStart"; RollbackBtn="BtnRollback_RecommendedStart"; Badge="Badge_RecommendedStart"; TxtBadge="TxtBadge_RecommendedStart" },
        @{ Key="TaskbarChat"; Title="Disable Taskbar Chat"; Category="Shell"; Apply={ Disable-TaskbarChat }; Rollback={ Restore-TaskbarChat }; ApplyBtn="BtnApply_TaskbarChat"; RollbackBtn="BtnRollback_TaskbarChat"; Badge="Badge_TaskbarChat"; TxtBadge="TxtBadge_TaskbarChat" },
        @{ Key="FilesCompact"; Title="Files Compact View"; Category="Shell"; Apply={ Enable-FilesCompactMode }; Rollback={ Restore-FilesCompactMode }; ApplyBtn="BtnApply_FilesCompact"; RollbackBtn="BtnRollback_FilesCompact"; Badge="Badge_FilesCompact"; TxtBadge="TxtBadge_FilesCompact" },
        @{ Key="SnapAssist"; Title="Disable Snap Assist"; Category="Shell"; Apply={ Disable-SnapAssist }; Rollback={ Restore-SnapAssist }; ApplyBtn="BtnApply_SnapAssist"; RollbackBtn="BtnRollback_SnapAssist"; Badge="Badge_SnapAssist"; TxtBadge="TxtBadge_SnapAssist" },
        @{ Key="WindowsStickers"; Title="Disable Desktop Stickers"; Category="Shell"; Apply={ Disable-DesktopStickers }; Rollback={ Restore-WindowsStickers }; ApplyBtn="BtnApply_WindowsStickers"; RollbackBtn="BtnRollback_WindowsStickers"; Badge="Badge_WindowsStickers"; TxtBadge="TxtBadge_WindowsStickers" },
        @{ Key="EdgeDiscover"; Title="Disable Edge Discover Bar"; Category="Shell"; Apply={ Disable-EdgeDiscoverBar }; Rollback={ Restore-EdgeDiscoverBar }; ApplyBtn="BtnApply_EdgeDiscover"; RollbackBtn="BtnRollback_EdgeDiscover"; Badge="Badge_EdgeDiscover"; TxtBadge="TxtBadge_EdgeDiscover" },
        @{ Key="CopyMoveMenu"; Title="Add Copy/Move to Menu"; Category="Shell"; Apply={ Enable-CopyMoveToContextMenu }; Rollback={ Restore-CopyMoveContextMenu }; ApplyBtn="BtnApply_CopyMoveMenu"; RollbackBtn="BtnRollback_CopyMoveMenu"; Badge="Badge_CopyMoveMenu"; TxtBadge="TxtBadge_CopyMoveMenu" },
        @{ Key="WindowShake"; Title="Disable Window Shake"; Category="Shell"; Apply={ Disable-WindowShake }; Rollback={ Restore-WindowShake }; ApplyBtn="BtnApply_WindowShake"; RollbackBtn="BtnRollback_WindowShake"; Badge="Badge_WindowShake"; TxtBadge="TxtBadge_WindowShake" },
        @{ Key="SystemDarkMode"; Title="System Dark Mode"; Category="Shell"; Apply={ Enable-SystemDarkMode }; Rollback={ Restore-WindowsLightMode }; ApplyBtn="BtnApply_SystemDarkMode"; RollbackBtn="BtnRollback_SystemDarkMode"; Badge="Badge_SystemDarkMode"; TxtBadge="TxtBadge_SystemDarkMode" },
        @{ Key="VerboseLogon"; Title="Enable Verbose Logon"; Category="Shell"; Apply={ Enable-VerboseLogon }; Rollback={ Restore-VerboseLogon }; ApplyBtn="BtnApply_VerboseLogon"; RollbackBtn="BtnRollback_VerboseLogon"; Badge="Badge_VerboseLogon"; TxtBadge="TxtBadge_VerboseLogon" },
        @{ Key="QuickAccessHistory"; Title="Disable Quick Access History"; Category="Shell"; Apply={ Disable-QuickAccessHistory }; Rollback={ Restore-QuickAccessHistory }; ApplyBtn="BtnApply_QuickAccessHistory"; RollbackBtn="BtnRollback_QuickAccessHistory"; Badge="Badge_QuickAccessHistory"; TxtBadge="TxtBadge_QuickAccessHistory" },
        @{ Key="MyPeople"; Title="Disable My People Band"; Category="Shell"; Apply={ Disable-MyPeople }; Rollback={ Restore-MyPeople }; ApplyBtn="BtnApply_MyPeople"; RollbackBtn="BtnRollback_MyPeople"; Badge="Badge_MyPeople"; TxtBadge="TxtBadge_MyPeople" },
        @{ Key="WindowsInk"; Title="Disable Windows Ink"; Category="Shell"; Apply={ Disable-WindowsInk }; Rollback={ Restore-WindowsInk }; ApplyBtn="BtnApply_WindowsInk"; RollbackBtn="BtnRollback_WindowsInk"; Badge="Badge_WindowsInk"; TxtBadge="TxtBadge_WindowsInk" },
        @{ Key="CastToDevice"; Title="Disable Cast to Device"; Category="Shell"; Apply={ Disable-CastToDevice }; Rollback={ Restore-CastToDevice }; ApplyBtn="BtnApply_CastToDevice"; RollbackBtn="BtnRollback_CastToDevice"; Badge="Badge_CastToDevice"; TxtBadge="TxtBadge_CastToDevice" },

        # 4. Privacy & App Telemetry
        @{ Key="AppTelemetry"; Title="Disable App Telemetry"; Category="Privacy"; Apply={ Disable-ThirdPartyAppTelemetry }; Rollback={ Restore-AppTelemetry }; ApplyBtn="BtnApply_AppTelemetry"; RollbackBtn="BtnRollback_AppTelemetry"; Badge="Badge_AppTelemetry"; TxtBadge="TxtBadge_AppTelemetry" },
        @{ Key="BluetoothAdvertising"; Title="Disable Bluetooth Advertising"; Category="Privacy"; Apply={ Disable-BluetoothAdvertising }; Rollback={ Restore-BluetoothAdvertising }; ApplyBtn="BtnApply_BluetoothAdvertising"; RollbackBtn="BtnRollback_BluetoothAdvertising"; Badge="Badge_BluetoothAdvertising"; TxtBadge="TxtBadge_BluetoothAdvertising" },
        @{ Key="CloudContent"; Title="Disable Cloud Content"; Category="Privacy"; Apply={ Disable-CloudOptimizedContent }; Rollback={ Restore-CloudOptimizedContent }; ApplyBtn="BtnApply_CloudContent"; RollbackBtn="BtnRollback_CloudContent"; Badge="Badge_CloudContent"; TxtBadge="TxtBadge_CloudContent" },
        @{ Key="CdpServices"; Title="Disable CDP Services"; Category="Privacy"; Apply={ Disable-CdpUserServices }; Rollback={ Restore-CdpServices }; ApplyBtn="BtnApply_CdpServices"; RollbackBtn="BtnRollback_CdpServices"; Badge="Badge_CdpServices"; TxtBadge="TxtBadge_CdpServices" },
        @{ Key="DiagnosticsToasts"; Title="Disable Diagnostics Toasts"; Category="Privacy"; Apply={ Disable-DiagnosticsToasts }; Rollback={ Restore-DiagnosticsToasts }; ApplyBtn="BtnApply_DiagnosticsToasts"; RollbackBtn="BtnRollback_DiagnosticsToasts"; Badge="Badge_DiagnosticsToasts"; TxtBadge="TxtBadge_DiagnosticsToasts" },
        @{ Key="OnlineSpeech"; Title="Disable Online Speech Privacy"; Category="Privacy"; Apply={ Disable-OnlineSpeechPrivacy }; Rollback={ Restore-OnlineSpeechPrivacy }; ApplyBtn="BtnApply_OnlineSpeech"; RollbackBtn="BtnRollback_OnlineSpeech"; Badge="Badge_OnlineSpeech"; TxtBadge="TxtBadge_OnlineSpeech" },
        @{ Key="Arso"; Title="Disable Restart Apps On Reboot"; Category="Privacy"; Apply={ Disable-RestartAppsAfterReboot }; Rollback={ Restore-AutomaticRestartSignOn }; ApplyBtn="BtnApply_Arso"; RollbackBtn="BtnRollback_Arso"; Badge="Badge_Arso"; TxtBadge="TxtBadge_Arso" },
        @{ Key="TextInputCollection"; Title="Disable Inking & Typing Collection"; Category="Privacy"; Apply={ Disable-HandwritingTypingCollection }; Rollback={ Restore-TextInputCollection }; ApplyBtn="BtnApply_TextInputCollection"; RollbackBtn="BtnRollback_TextInputCollection"; Badge="Badge_TextInputCollection"; TxtBadge="TxtBadge_TextInputCollection" },
        @{ Key="ClipboardSync"; Title="Disable Clipboard Cloud Sync"; Category="Privacy"; Apply={ Disable-ClipboardCloudSync }; Rollback={ Restore-ClipboardSync }; ApplyBtn="BtnApply_ClipboardSync"; RollbackBtn="BtnRollback_ClipboardSync"; Badge="Badge_ClipboardSync"; TxtBadge="TxtBadge_ClipboardSync" },
        @{ Key="SettingsMessageSync"; Title="Disable Settings & Message Sync"; Category="Privacy"; Apply={ Disable-SettingsAndMessageSync }; Rollback={ Restore-SettingsAndMessageSync }; ApplyBtn="BtnApply_SettingsMessageSync"; RollbackBtn="BtnRollback_SettingsMessageSync"; Badge="Badge_SettingsMessageSync"; TxtBadge="TxtBadge_SettingsMessageSync" },
        @{ Key="FindMyDevice"; Title="Disable Find My Device"; Category="Privacy"; Apply={ Disable-FindMyDevice }; Rollback={ Restore-FindMyDevice }; ApplyBtn="BtnApply_FindMyDevice"; RollbackBtn="BtnRollback_FindMyDevice"; Badge="Badge_FindMyDevice"; TxtBadge="TxtBadge_FindMyDevice" },
        @{ Key="SafeSearch"; Title="Disable SafeSearch"; Category="Privacy"; Apply={ Disable-SafeSearchFiltering }; Rollback={ Restore-SafeSearchMode }; ApplyBtn="BtnApply_SafeSearch"; RollbackBtn="BtnRollback_SafeSearch"; Badge="Badge_SafeSearch"; TxtBadge="TxtBadge_SafeSearch" },
        @{ Key="RemoteAssistanceRegistry"; Title="Disable Remote Assistance & Reg"; Category="Privacy"; Apply={ Disable-RemoteAssistanceAndRegistry }; Rollback={ Restore-RemoteAssistanceAndRegistry }; ApplyBtn="BtnApply_RemoteAssistanceRegistry"; RollbackBtn="BtnRollback_RemoteAssistanceRegistry"; Badge="Badge_RemoteAssistanceRegistry"; TxtBadge="TxtBadge_RemoteAssistanceRegistry" },
        @{ Key="DriverUpdatesExcluded"; Title="Exclude Drivers in Windows Update"; Category="Privacy"; Apply={ Exclude-DriverUpdatesInWindowsUpdate }; Rollback={ Restore-DriverUpdatesFromWindowsUpdate }; ApplyBtn="BtnApply_DriverUpdatesExcluded"; RollbackBtn="BtnRollback_DriverUpdatesExcluded"; Badge="Badge_DriverUpdatesExcluded"; TxtBadge="TxtBadge_DriverUpdatesExcluded" },
        @{ Key="StoreAutoUpdates"; Title="Disable Store Auto-Updates"; Category="Privacy"; Apply={ Disable-WindowsStoreAutoUpdates }; Rollback={ Restore-StoreAutoUpdates }; ApplyBtn="BtnApply_StoreAutoUpdates"; RollbackBtn="BtnRollback_StoreAutoUpdates"; Badge="Badge_StoreAutoUpdates"; TxtBadge="TxtBadge_StoreAutoUpdates" },
        @{ Key="SmartScreen"; Title="Disable SmartScreen Filter"; Category="Privacy"; Apply={ Disable-SmartScreenProtection }; Rollback={ Restore-SmartScreenFilter }; ApplyBtn="BtnApply_SmartScreen"; RollbackBtn="BtnRollback_SmartScreen"; Badge="Badge_SmartScreen"; TxtBadge="TxtBadge_SmartScreen" },
        @{ Key="CrashDumps"; Title="Disable Crash Dumps"; Category="Privacy"; Apply={ Disable-SystemCrashDumps }; Rollback={ Restore-CrashDumps }; ApplyBtn="BtnApply_CrashDumps"; RollbackBtn="BtnRollback_CrashDumps"; Badge="Badge_CrashDumps"; TxtBadge="TxtBadge_CrashDumps" },
        @{ Key="SystemTimeouts"; Title="Optimize System Timeouts"; Category="Privacy"; Apply={ Optimize-SystemTimeouts }; Rollback={ Restore-SystemTimeouts }; ApplyBtn="BtnApply_SystemTimeouts"; RollbackBtn="BtnRollback_SystemTimeouts"; Badge="Badge_SystemTimeouts"; TxtBadge="TxtBadge_SystemTimeouts" }
    )

    # Thread-Safe Live Audit & Score Gauge Updater
    $script:UpdateGuiAuditStatus = {
        try {
            $audit = Get-SystemAuditState
            $scorePctText = "$($audit.ScorePercent)%"
            $gradeText    = "$($audit.ScoreGrade)"
            $ratioText    = "[Active: $($audit.ScoreApplied) / $($audit.ScoreTotal)]"

            if ($txtScorePercent) { $txtScorePercent.Text = $scorePctText }
            if ($txtScoreGrade)   { $txtScoreGrade.Text   = $gradeText }
            if ($txtActiveTweakRatio) { $txtActiveTweakRatio.Text = $ratioText }

            if ($txtScorePercentTab4) { $txtScorePercentTab4.Text = $scorePctText }
            if ($txtScoreGradeTab4)   { $txtScoreGradeTab4.Text   = $gradeText }
            if ($txtActiveTweakRatioTab4) { $txtActiveTweakRatioTab4.Text = $ratioText }

            foreach ($tw in $script:TweakDefinitions) {
                $isApplied = ($audit.State[$tw.Key] -eq $true)
                if ($tw.Badge) {
                    $b = $window.FindName($tw.Badge)
                    $tb = $window.FindName($tw.TxtBadge)
                    if ($b -and $tb) {
                        if ($isApplied) {
                            $b.Background = $brushOptimalBg
                            $b.BorderBrush = $brushOptimalBorder
                            $tb.Text = "Optimal [v]"
                            $tb.Foreground = $brushOptimalText
                        } else {
                            $b.Background = $brushNeededBg
                            $b.BorderBrush = $brushNeededBorder
                            $tb.Text = "Needed"
                            $tb.Foreground = $brushNeededText
                        }
                    }
                }
            }
        } catch {
            Write-Verbose "Audit UI update failed: $($_.Exception.Message)"
        }
    }

    # Register individual Apply and Rollback buttons dynamically
    foreach ($tw in $script:TweakDefinitions) {
        $def = $tw
        if ($def.ApplyBtn) {
            $btnApp = $window.FindName($def.ApplyBtn)
            if ($btnApp) {
                $btnApp.Add_Click({
                    & $script:LogToGui "[*] Applying $($def.Title)..."
                    & $script:SetProgress 40
                    & $def.Apply
                    & $script:SetProgress 100
                    & $script:UpdateGuiAuditStatus
                    & $script:LogToGui "[+] $($def.Title) applied successfully!"
                    Start-Sleep -Milliseconds 150
                    & $script:SetProgress 0
                })
            }
        }
        if ($def.RollbackBtn) {
            $btnRoll = $window.FindName($def.RollbackBtn)
            if ($btnRoll) {
                $btnRoll.Add_Click({
                    & $script:LogToGui "[*] Rolling back $($def.Title) to Windows default..."
                    & $script:SetProgress 40
                    & $def.Rollback
                    & $script:SetProgress 100
                    & $script:UpdateGuiAuditStatus
                    & $script:LogToGui "[+] $($def.Title) rolled back successfully!"
                    Start-Sleep -Milliseconds 150
                    & $script:SetProgress 0
                })
            }
        }
    }

    # Standalone Special Tool Buttons
    $btnApplyDeepCache = $window.FindName("BtnApply_DeepCache")
    if ($btnApplyDeepCache) {
        $btnApplyDeepCache.Add_Click({
            & $script:LogToGui "[*] Running Deep Cache, Prefetch & Event Cleaner..."
            & $script:SetProgress 40
            Invoke-DeepCacheCleaner
            & $script:SetProgress 100
            & $script:LogToGui "[+] Deep Cache & Event Cleaner completed successfully!"
            Start-Sleep -Milliseconds 200
            & $script:SetProgress 0
        })
    }

    $btnApplyShaderCache = $window.FindName("BtnApply_ShaderCache")
    if ($btnApplyShaderCache) {
        $btnApplyShaderCache.Add_Click({
            & $script:LogToGui "[*] Purging GPU Shader & Browser Caches..."
            & $script:SetProgress 40
            Invoke-ShaderAndBrowserCacheCleaner
            & $script:SetProgress 100
            & $script:LogToGui "[+] Shader & Browser Cache purge completed!"
            Start-Sleep -Milliseconds 200
            & $script:SetProgress 0
        })
    }

    $btnResetDns = $window.FindName("BtnResetDns")
    if ($btnResetDns) {
        $btnResetDns.Add_Click({
            & $script:LogToGui "[*] Resetting DNS servers to automatic DHCP..."
            Reset-DnsToAutomatic
            & $script:LogToGui "[+] Network DNS restored to DHCP defaults."
        })
    }

    $btnApplyRecycle = $window.FindName("BtnApply_RecycleBinIcon")
    if ($btnApplyRecycle) {
        $btnApplyRecycle.Add_Click({
            & $script:LogToGui "[*] Applying Pop Cat Recycle Bin custom icon..."
            Set-RecycleBinCustomIcon
            & $script:LogToGui "[+] Pop Cat Recycle Bin active!"
        })
    }

    $btnResetRecycle = $window.FindName("BtnReset_RecycleBinIcon")
    if ($btnResetRecycle) {
        $btnResetRecycle.Add_Click({
            & $script:LogToGui "[*] Restoring default Windows Recycle Bin icon..."
            Restore-RecycleBinDefaultIcon
            & $script:LogToGui "[+] Default Recycle Bin icon restored."
        })
    }

    # Action Dashboard Banners: Live Audit Scanner
    $scanAction = {
        & $script:LogToGui "[*] Scanning system optimization state across all 75+ parameters..."
        & $script:SetProgress 30
        & $script:UpdateGuiAuditStatus
        $audit = Get-SystemAuditState
        & $script:SetProgress 100
        & $script:LogToGui "[+] System Audit Complete: $($audit.ScoreApplied)/$($audit.ScoreTotal) tweaks active (Score: $($audit.ScoreGrade))"
        Start-Sleep -Milliseconds 200
        & $script:SetProgress 0
    }
    if ($btnScanSystemStateBanner) { $btnScanSystemStateBanner.Add_Click($scanAction) }
    if ($btnScanSystemStateTab4Banner) { $btnScanSystemStateTab4Banner.Add_Click($scanAction) }
    if ($btnScanSystemStateTab4) { $btnScanSystemStateTab4.Add_Click($scanAction) }

    # Action Dashboard Banners: Apply Unapplied Gaming Tweaks
    $applyUnappliedGaming = {
        & $script:LogToGui "=== APPLYING ALL UNAPPLIED GAMING TWEAKS ==="
        $audit = Get-SystemAuditState
        $unapplied = $script:TweakDefinitions | Where-Object { $_.Category -eq "Gaming" -and (-not $audit.State[$_.Key]) }
        $total = $unapplied.Count
        if ($total -eq 0) {
            & $script:LogToGui "[+] All gaming tweaks are already active and optimal!"
            return
        }
        $i = 0
        foreach ($tw in $unapplied) {
            $i++
            $pct = [math]::Round(($i / $total) * 100)
            & $script:SetProgress $pct
            & $script:LogToGui "[$i/$total] Applying $($tw.Title)..."
            & $tw.Apply
        }
        & $script:UpdateGuiAuditStatus
        & $script:LogToGui "[OK] All unapplied gaming tweaks successfully applied!"
        Start-Sleep -Milliseconds 200
        & $script:SetProgress 0
    }
    if ($btnApplyUnappliedBanner) { $btnApplyUnappliedBanner.Add_Click($applyUnappliedGaming) }
    if ($btnApplyUnappliedTab2)   { $btnApplyUnappliedTab2.Add_Click($applyUnappliedGaming) }

    # Action Dashboard Banners: Apply Unapplied Hardening & Privacy Tweaks
    $applyUnappliedHardening = {
        & $script:LogToGui "=== APPLYING ALL UNAPPLIED HARDENING & PRIVACY TWEAKS ==="
        $audit = Get-SystemAuditState
        $unapplied = $script:TweakDefinitions | Where-Object { ($_.Category -in "Shell","Hardening","Privacy") -and (-not $audit.State[$_.Key]) }
        $total = $unapplied.Count
        if ($total -eq 0) {
            & $script:LogToGui "[+] All hardening and privacy tweaks are already active and optimal!"
            return
        }
        $i = 0
        foreach ($tw in $unapplied) {
            $i++
            $pct = [math]::Round(($i / $total) * 100)
            & $script:SetProgress $pct
            & $script:LogToGui "[$i/$total] Applying $($tw.Title)..."
            & $tw.Apply
        }
        & $script:UpdateGuiAuditStatus
        & $script:LogToGui "[OK] All unapplied hardening and privacy tweaks successfully applied!"
        Start-Sleep -Milliseconds 200
        & $script:SetProgress 0
    }
    if ($btnApplyUnappliedHardening) { $btnApplyUnappliedHardening.Add_Click($applyUnappliedHardening) }
    if ($btnApplyUnappliedHardeningBanner) { $btnApplyUnappliedHardeningBanner.Add_Click($applyUnappliedHardening) }

    # Action Dashboard Banners: Revert All Tweaks to Defaults
    $revertAllAction = {
        & $script:LogToGui "[*] Reverting all system tweaks to Windows defaults..."
        & $script:SetProgress 30
        Restore-Defaults
        & $script:SetProgress 90
        & $script:UpdateGuiAuditStatus
        & $script:SetProgress 100
        & $script:LogToGui "[+] Windows default parameters restored. System audit refreshed."
        Start-Sleep -Milliseconds 200
        & $script:SetProgress 0
    }
    if ($btnRevertDefaultsBanner) { $btnRevertDefaultsBanner.Add_Click($revertAllAction) }
    if ($btnRevertDefaultsTab4)   { $btnRevertDefaultsTab4.Add_Click($revertAllAction) }

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

    if ($btnInstallTrafficMonitor) {
        $btnInstallTrafficMonitor.Add_Click({
            & $script:LogToGui "[*] Starting TrafficMonitor (Latest x64) Download & Installation..."
            & $script:SetProgress 20
            [void](Install-TrafficMonitorLatest -LogCallback $script:LogToGui)
            & $script:SetProgress 100
            Start-Sleep -Milliseconds 300
            & $script:SetProgress 0
        })
    }

    if ($btnInstallMiSansFonts) {
        $btnInstallMiSansFonts.Add_Click({
            & $script:LogToGui "[*] Starting MiSans Fonts Installation..."
            & $script:SetProgress 20
            [void](Install-MiSansFonts -LogCallback $script:LogToGui)
            & $script:SetProgress 100
            Start-Sleep -Milliseconds 300
            & $script:SetProgress 0
        })
    }

    if ($btnApplyTrafficMonitorConfig) {
        $btnApplyTrafficMonitorConfig.Add_Click({
            & $script:LogToGui "[*] Applying Custom TrafficMonitor config.ini..."
            & $script:SetProgress 20
            [void](Apply-TrafficMonitorConfig -LogCallback $script:LogToGui)
            & $script:SetProgress 100
            Start-Sleep -Milliseconds 300
            & $script:SetProgress 0
        })
    }

    if ($btnLaunchTrafficMonitor) {
        $btnLaunchTrafficMonitor.Add_Click({
            [void](Start-TrafficMonitorApp -LogCallback $script:LogToGui)
        })
    }

    # --------------------------------------------------------------------------
    # TAB 5: DEVICE SPECIFICATIONS & COPY ACTIONS
    # --------------------------------------------------------------------------
    $script:UpdateDeviceSpecsView = {
        param([switch]$Force)
        try {
            $p = Get-DeviceDetailProfile -ForceRefresh:$Force
            if (-not $p) { return }

            $txtDevCompName = $window.FindName("TxtDev_CompName")
            $txtDevSubTitle = $window.FindName("TxtDev_SubTitle")
            if ($txtDevCompName) { $txtDevCompName.Text = $p.DeviceName }
            if ($txtDevSubTitle) { $txtDevSubTitle.Text = $p.HeaderSummary }

            # OS
            $t = $window.FindName("TxtDev_OsName"); if ($t) { $t.Text = $p.OsName }
            $t = $window.FindName("TxtDev_OsVersion"); if ($t) { $t.Text = $p.OsVersion }
            $t = $window.FindName("TxtDev_OsBuild"); if ($t) { $t.Text = $p.OsBuildNumber }
            $t = $window.FindName("TxtDev_OsArch"); if ($t) { $t.Text = $p.OsArchitecture }
            $t = $window.FindName("TxtDev_OsInstallDate"); if ($t) { $t.Text = $p.OsInstallDate }
            $t = $window.FindName("TxtDev_OsUser"); if ($t) { $t.Text = $p.OsRegisteredUser }
            $t = $window.FindName("TxtDev_OsWinDir"); if ($t) { $t.Text = $p.OsWindowsDir }
            $t = $window.FindName("TxtDev_OsSysDir"); if ($t) { $t.Text = $p.OsSystemDir }
            $t = $window.FindName("TxtDev_OsBootTime"); if ($t) { $t.Text = $p.OsLastBootTime }

            # CPU
            $t = $window.FindName("TxtDev_CpuName"); if ($t) { $t.Text = $p.CpuName }
            $t = $window.FindName("TxtDev_CpuManufacturer"); if ($t) { $t.Text = $p.CpuManufacturer }
            $t = $window.FindName("TxtDev_CpuArchitecture"); if ($t) { $t.Text = $p.CpuArchitecture }
            $t = $window.FindName("TxtDev_CpuCores"); if ($t) { $t.Text = $p.CpuCores }
            $t = $window.FindName("TxtDev_CpuLogical"); if ($t) { $t.Text = $p.CpuLogical }
            $t = $window.FindName("TxtDev_CpuMaxSpeed"); if ($t) { $t.Text = $p.CpuMaxSpeed }
            $t = $window.FindName("TxtDev_CpuSocket"); if ($t) { $t.Text = $p.CpuSocket }
            $t = $window.FindName("TxtDev_CpuL2"); if ($t) { $t.Text = $p.CpuL2Cache }
            $t = $window.FindName("TxtDev_CpuL3"); if ($t) { $t.Text = $p.CpuL3Cache }

            # GPU
            if ($p.PrimaryGpu) {
                $t = $window.FindName("TxtDev_GpuName"); if ($t) { $t.Text = $p.PrimaryGpu.Name }
                $t = $window.FindName("TxtDev_GpuManufacturer"); if ($t) { $t.Text = $p.PrimaryGpu.Manufacturer }
                $t = $window.FindName("TxtDev_GpuDriverVersion"); if ($t) { $t.Text = $p.PrimaryGpu.DriverVersion }
                $t = $window.FindName("TxtDev_GpuDriverDate"); if ($t) { $t.Text = $p.PrimaryGpu.DriverDate }
                $t = $window.FindName("TxtDev_GpuVram"); if ($t) { $t.Text = $p.PrimaryGpu.Vram }
                $t = $window.FindName("TxtDev_GpuResolution"); if ($t) { $t.Text = $p.PrimaryGpu.Resolution }
                $t = $window.FindName("TxtDev_GpuRefreshRate"); if ($t) { $t.Text = $p.PrimaryGpu.RefreshRate }
            }

            # RAM
            $t = $window.FindName("TxtDev_RamTotal"); if ($t) { $t.Text = $p.RamTotal }
            $t = $window.FindName("TxtDev_RamUsable"); if ($t) { $t.Text = $p.RamUsable }
            $t = $window.FindName("TxtDev_RamSpeed"); if ($t) { $t.Text = $p.RamSpeed }
            $t = $window.FindName("TxtDev_RamManufacturer"); if ($t) { $t.Text = $p.RamManufacturer }
            $t = $window.FindName("TxtDev_RamPartNumber"); if ($t) { $t.Text = $p.RamPartNumber }
            $t = $window.FindName("TxtDev_RamSlots"); if ($t) { $t.Text = $p.RamSlots }

            # Storage
            $t = $window.FindName("TxtDev_StorageDisks"); if ($t) { $t.Text = ($p.Disks -join ' | ') }
            $t = $window.FindName("TxtDev_StorageVolumes"); if ($t) { $t.Text = ($p.Volumes -join ' | ') }

            # Network
            $t = $window.FindName("TxtDev_NetName"); if ($t) { $t.Text = $p.NetAdapterName }
            $t = $window.FindName("TxtDev_NetDesc"); if ($t) { $t.Text = $p.NetDescription }
            $t = $window.FindName("TxtDev_NetMac"); if ($t) { $t.Text = $p.NetMacAddress }
            $t = $window.FindName("TxtDev_NetSpeed"); if ($t) { $t.Text = $p.NetLinkSpeed }
            $t = $window.FindName("TxtDev_NetIp"); if ($t) { $t.Text = $p.NetIpAddress }
            $t = $window.FindName("TxtDev_NetStatus"); if ($t) { $t.Text = $p.NetStatus }

            # Battery
            $t = $window.FindName("TxtDev_BatteryStatus"); if ($t) { $t.Text = $p.BatteryStatus }
            $t = $window.FindName("TxtDev_BatteryName"); if ($t) { $t.Text = $p.BatteryName }
            $t = $window.FindName("TxtDev_BatteryPercent"); if ($t) { $t.Text = $p.BatteryPercent }
        } catch {}
    }

    # Wire expand/collapse toggles
    $categories = @('Os', 'Cpu', 'Gpu', 'Ram', 'Storage', 'Net', 'Battery')
    foreach ($cat in $categories) {
        $btnToggle = $window.FindName("BtnToggle_Dev$cat")
        $panel = $window.FindName("Panel_Dev$cat")
        if ($btnToggle -and $panel) {
            $btnToggle.Tag = $panel
            $btnToggle.Add_Click({
                param($s, $e)
                $targetPanel = $s.Tag
                if ($targetPanel.Visibility -eq [System.Windows.Visibility]::Visible) {
                    $targetPanel.Visibility = [System.Windows.Visibility]::Collapsed
                    $s.Content = "v"
                } else {
                    $targetPanel.Visibility = [System.Windows.Visibility]::Visible
                    $s.Content = "^"
                }
            })
        }
    }

    # Wire copy buttons for individual categories
    $copyActions = @{
        'BtnCopy_DevOs' = {
            $p = Get-DeviceDetailProfile
            $text = "Operating System`r`n  OS Name: $($p.OsName)`r`n  Version: $($p.OsVersion)`r`n  Build: $($p.OsBuildNumber)`r`n  Arch: $($p.OsArchitecture)`r`n  Install Date: $($p.OsInstallDate)`r`n  User: $($p.OsRegisteredUser)`r`n  WinDir: $($p.OsWindowsDir)`r`n  SysDir: $($p.OsSystemDir)`r`n  Last Boot: $($p.OsLastBootTime)"
            [System.Windows.Clipboard]::SetText($text)
            & $script:LogToGui "[+] Operating System details copied to clipboard."
        }
        'BtnCopy_DevCpu' = {
            $p = Get-DeviceDetailProfile
            $text = "Processor`r`n  Name: $($p.CpuName)`r`n  Manufacturer: $($p.CpuManufacturer)`r`n  Arch: $($p.CpuArchitecture)`r`n  Cores/Threads: $($p.CpuCores) / $($p.CpuLogical)`r`n  Max Speed: $($p.CpuMaxSpeed)`r`n  Socket: $($p.CpuSocket)`r`n  L2 Cache: $($p.CpuL2Cache)`r`n  L3 Cache: $($p.CpuL3Cache)"
            [System.Windows.Clipboard]::SetText($text)
            & $script:LogToGui "[+] Processor details copied to clipboard."
        }
        'BtnCopy_DevGpu' = {
            $p = Get-DeviceDetailProfile
            $text = "Graphics`r`n  Name: $($p.PrimaryGpu.Name)`r`n  Manufacturer: $($p.PrimaryGpu.Manufacturer)`r`n  Driver Version: $($p.PrimaryGpu.DriverVersion)`r`n  Driver Date: $($p.PrimaryGpu.DriverDate)`r`n  VRAM: $($p.PrimaryGpu.Vram)`r`n  Resolution: $($p.PrimaryGpu.Resolution) @ $($p.PrimaryGpu.RefreshRate)"
            [System.Windows.Clipboard]::SetText($text)
            & $script:LogToGui "[+] Graphics details copied to clipboard."
        }
        'BtnCopy_DevRam' = {
            $p = Get-DeviceDetailProfile
            $text = "RAM`r`n  Total Installed: $($p.RamTotal)`r`n  Usable: $($p.RamUsable)`r`n  Speed: $($p.RamSpeed)`r`n  Manufacturer: $($p.RamManufacturer)`r`n  Part Number: $($p.RamPartNumber)`r`n  Slots: $($p.RamSlots)"
            [System.Windows.Clipboard]::SetText($text)
            & $script:LogToGui "[+] RAM details copied to clipboard."
        }
        'BtnCopy_DevStorage' = {
            $p = Get-DeviceDetailProfile
            $text = "Storage`r`n  Physical Disks: $($p.Disks -join ' | ')`r`n  Volumes: $($p.Volumes -join ' | ')"
            [System.Windows.Clipboard]::SetText($text)
            & $script:LogToGui "[+] Storage details copied to clipboard."
        }
        'BtnCopy_DevNet' = {
            $p = Get-DeviceDetailProfile
            $text = "Network`r`n  Adapter: $($p.NetAdapterName)`r`n  Description: $($p.NetDescription)`r`n  MAC Address: $($p.NetMacAddress)`r`n  Speed: $($p.NetLinkSpeed)`r`n  IPv4: $($p.NetIpAddress)`r`n  Status: $($p.NetStatus)"
            [System.Windows.Clipboard]::SetText($text)
            & $script:LogToGui "[+] Network details copied to clipboard."
        }
        'BtnCopy_DevBattery' = {
            $p = Get-DeviceDetailProfile
            $text = "Battery / Power`r`n  Status: $($p.BatteryStatus)`r`n  Device: $($p.BatteryName)`r`n  Level: $($p.BatteryPercent)"
            [System.Windows.Clipboard]::SetText($text)
            & $script:LogToGui "[+] Battery / Power details copied to clipboard."
        }
    }

    foreach ($btnName in $copyActions.Keys) {
        $btn = $window.FindName($btnName)
        if ($btn) {
            $action = $copyActions[$btnName]
            $btn.Add_Click({
                param($s, $e)
                try {
                    & $action
                    $s.Content = "Copied!"
                    $timer = [System.Windows.Threading.DispatcherTimer]::new()
                    $timer.Interval = [TimeSpan]::FromMilliseconds(1500)
                    $timer.Add_Tick({
                        param($ts, $te)
                        $s.Content = "Copy"
                        $ts.Stop()
                    })
                    $timer.Start()
                } catch {}
            })
        }
    }

    # Wire Refresh and Copy All Specs
    $btnRefreshSpecs = $window.FindName("BtnRefreshDeviceSpecs")
    if ($btnRefreshSpecs) {
        $btnRefreshSpecs.Add_Click({
            & $script:UpdateDeviceSpecsView -Force
            & $script:LogToGui "[+] Device hardware specifications refreshed."
        })
    }

    $btnCopyAllSpecs = $window.FindName("BtnCopyAllDeviceSpecs")
    if ($btnCopyAllSpecs) {
        $btnCopyAllSpecs.Add_Click({
            param($s, $e)
            try {
                $p = Get-DeviceDetailProfile
                $sb = [System.Text.StringBuilder]::new()
                [void]$sb.AppendLine("================================================================================")
                [void]$sb.AppendLine("                    DEVICE HARDWARE & OPERATING SYSTEM REPORT                   ")
                [void]$sb.AppendLine("================================================================================")
                [void]$sb.AppendLine("Device Name:       $($p.DeviceName)")
                [void]$sb.AppendLine("System Summary:    $($p.HeaderSummary)")
                [void]$sb.AppendLine()
                [void]$sb.AppendLine("[Operating System]")
                [void]$sb.AppendLine("  OS Name:         $($p.OsName)")
                [void]$sb.AppendLine("  Version:         $($p.OsVersion)")
                [void]$sb.AppendLine("  Build Number:    $($p.OsBuildNumber)")
                [void]$sb.AppendLine("  Architecture:    $($p.OsArchitecture)")
                [void]$sb.AppendLine("  Install Date:    $($p.OsInstallDate)")
                [void]$sb.AppendLine("  Registered User: $($p.OsRegisteredUser)")
                [void]$sb.AppendLine("  Windows Dir:     $($p.OsWindowsDir)")
                [void]$sb.AppendLine("  System Dir:      $($p.OsSystemDir)")
                [void]$sb.AppendLine("  Last Boot Up:    $($p.OsLastBootTime)")
                [void]$sb.AppendLine()
                [void]$sb.AppendLine("[Processor]")
                [void]$sb.AppendLine("  Name:            $($p.CpuName)")
                [void]$sb.AppendLine("  Manufacturer:    $($p.CpuManufacturer)")
                [void]$sb.AppendLine("  Architecture:    $($p.CpuArchitecture)")
                [void]$sb.AppendLine("  Cores / Threads: $($p.CpuCores) Cores / $($p.CpuLogical) Logical Processors")
                [void]$sb.AppendLine("  Max Speed:       $($p.CpuMaxSpeed)")
                [void]$sb.AppendLine("  Socket:          $($p.CpuSocket)")
                [void]$sb.AppendLine("  L2 Cache:        $($p.CpuL2Cache)")
                [void]$sb.AppendLine("  L3 Cache:        $($p.CpuL3Cache)")
                [void]$sb.AppendLine()
                if ($p.PrimaryGpu) {
                    [void]$sb.AppendLine("[Graphics]")
                    [void]$sb.AppendLine("  Name:            $($p.PrimaryGpu.Name)")
                    [void]$sb.AppendLine("  Manufacturer:    $($p.PrimaryGpu.Manufacturer)")
                    [void]$sb.AppendLine("  Driver Version:  $($p.PrimaryGpu.DriverVersion)")
                    [void]$sb.AppendLine("  Driver Date:     $($p.PrimaryGpu.DriverDate)")
                    [void]$sb.AppendLine("  VRAM:            $($p.PrimaryGpu.Vram)")
                    [void]$sb.AppendLine("  Resolution:      $($p.PrimaryGpu.Resolution) @ $($p.PrimaryGpu.RefreshRate)")
                    [void]$sb.AppendLine()
                }
                [void]$sb.AppendLine("[RAM]")
                [void]$sb.AppendLine("  Total Installed: $($p.RamTotal) (Usable: $($p.RamUsable))")
                [void]$sb.AppendLine("  Speed:           $($p.RamSpeed)")
                [void]$sb.AppendLine("  Manufacturer:    $($p.RamManufacturer)")
                [void]$sb.AppendLine("  Part Number:     $($p.RamPartNumber)")
                [void]$sb.AppendLine("  Slots:           $($p.RamSlots)")
                [void]$sb.AppendLine()
                [void]$sb.AppendLine("[Storage]")
                [void]$sb.AppendLine("  Physical Disks:  $($p.Disks -join ' | ')")
                [void]$sb.AppendLine("  Volumes:         $($p.Volumes -join ' | ')")
                [void]$sb.AppendLine()
                [void]$sb.AppendLine("[Network]")
                [void]$sb.AppendLine("  Adapter Name:    $($p.NetAdapterName)")
                [void]$sb.AppendLine("  Description:     $($p.NetDescription)")
                [void]$sb.AppendLine("  MAC Address:     $($p.NetMacAddress)")
                [void]$sb.AppendLine("  Link Speed:      $($p.NetLinkSpeed)")
                [void]$sb.AppendLine("  IPv4 Address:    $($p.NetIpAddress)")
                [void]$sb.AppendLine("  Status:          $($p.NetStatus)")
                [void]$sb.AppendLine()
                [void]$sb.AppendLine("[Battery / Power]")
                [void]$sb.AppendLine("  Power Status:    $($p.BatteryStatus)")
                [void]$sb.AppendLine("  Battery Device:  $($p.BatteryName)")
                [void]$sb.AppendLine("  Charge Level:    $($p.BatteryPercent)")
                [void]$sb.AppendLine("================================================================================")
                [void]$sb.AppendLine("Generated by PumpkiN Ultimate Windows Optimizer v5.4.0")

                [System.Windows.Clipboard]::SetText($sb.ToString())
                & $script:LogToGui "[+] Complete Device Specifications report copied to clipboard!"
                $s.Content = "Copied!"
                $timer = [System.Windows.Threading.DispatcherTimer]::new()
                $timer.Interval = [TimeSpan]::FromMilliseconds(1500)
                $timer.Add_Tick({
                    param($ts, $te)
                    $s.Content = "Copy All Specs"
                    $ts.Stop()
                })
                $timer.Start()
            } catch {}
        })
    }

    # Trigger initial load of device specs
    & $script:UpdateDeviceSpecsView

    # Initial Log Greeting & Status
    & $updateStandbyStatus
    $hw = Get-HardwareProfile
    & $script:LogToGui "PumpkiN Ultimate Gaming Optimizer & Software Suite v5.4.0 initialized."
    & $script:LogToGui "Hardware detected: $($hw.CpuName) | RAM: $($hw.TotalRamGb) GB"
    & $script:LogToGui "Select tweaks or software to install, then click the action button."
    if ($script:UpdateGuiAuditStatus) { & $script:UpdateGuiAuditStatus }

    # Live Hardware Telemetry DispatcherTimer
    $telemetryTimer = [System.Windows.Threading.DispatcherTimer]::new()
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

    # Complete shutdown and force-close engine (releases 100% of RAM memory)
    $script:ExitOptimizer = {
        try {
            if ($telemetryTimer) { $telemetryTimer.Stop() }
        } catch {}
        try {
            Stop-SmartGameBoosterDaemon
        } catch {}
        try {
            Get-Process -Name "EmptyStandbyList" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        } catch {}
        try {
            if ([System.Windows.Application]::Current) {
                [System.Windows.Application]::Current.Shutdown(0)
            }
        } catch {}
        try {
            if ($window -and $window.IsVisible) {
                $window.Close()
            }
        } catch {}
        try {
            [System.Diagnostics.Process]::GetCurrentProcess().Kill()
        } catch {
            Stop-Process -Id $PID -Force
        }
    }

    if ($btnExitTop) {
        $btnExitTop.Add_Click({
            & $script:ExitOptimizer
        })
    }

    # Clean shutdown on window close
    $window.Add_Closing({
        try {
            if ($telemetryTimer) { $telemetryTimer.Stop() }
            Stop-SmartGameBoosterDaemon
        } catch {}
    })

    $window.Add_Closed({
        & $script:ExitOptimizer
    })

    # Launch GUI Window
    [void]$window.ShowDialog()

    # Guaranteed force-close fallback once window dialog exits
    & $script:ExitOptimizer
}

# ==============================================================================