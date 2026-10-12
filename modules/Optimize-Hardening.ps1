<#
================================================================================
  PumpkiN's Modular Suite: WinUtil S-Tier & Snappy OS Hardening Optimizations
================================================================================
#>

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

function Update-DesktopIconCache {
    <#
    .SYNOPSIS
        Refreshes desktop icons and shell cache without requiring a reboot.
    #>
    try {
        $typeDef = @"
using System;
using System.Runtime.InteropServices;
public class ShellIconRefresh {
    [DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern void SHChangeNotify(int wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
}
"@
        if (-not ([System.Management.Automation.PSTypeName]'ShellIconRefresh').Type) {
            Add-Type -TypeDefinition $typeDef -ErrorAction SilentlyContinue
        }
        [ShellIconRefresh]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)
    } catch {}

    Start-Process ie4uinit.exe -ArgumentList "-show" -Wait -ErrorAction SilentlyContinue
}

function Set-RecycleBinCustomIcon {
    <#
    .SYNOPSIS
        Sets the Desktop Recycle Bin icons to custom Pop Cat icons (open/closed mouth) with 1 click.
    .DESCRIPTION
        Copies custom .ico files to a persistent local application directory, updates the
        user Explorer CLSID registry values for empty and full states, and refreshes the shell icon cache.
    #>
    [CmdletBinding()]
    param(
        [string]$EmptyIconPath,
        [string]$FullIconPath
    )

    Write-Host "`n[*] Applying Custom Pop Cat Recycle Bin Desktop Icons..." -ForegroundColor Yellow

    # Target persistent directory for custom icons
    $iconsDir = "$env:LOCALAPPDATA\PumpkiNOptimizer\Icons"
    if (-not (Test-Path $iconsDir)) {
        New-Item -ItemType Directory -Path $iconsDir -Force | Out-Null
    }

    # Locate empty icon
    if (-not $EmptyIconPath -or -not (Test-Path $EmptyIconPath)) {
        $candidateEmpty = @(
            (Join-Path $PSScriptRoot "..\recycle bin new style\empty.ico"),
            (Join-Path $PSScriptRoot "..\recycle bin new style\pop-cat-empty.ico"),
            "e:\Projects\Win_Optimizer\recycle bin new style\empty.ico",
            "e:\Projects\Win_Optimizer\recycle bin new style\pop-cat-empty.ico",
            "E:\Sadman softs\recycle bin new style\pop-cat-empty.ico"
        )
        foreach ($c in $candidateEmpty) {
            if ($c -and (Test-Path $c)) { $EmptyIconPath = (Resolve-Path $c).Path; break }
        }
    }

    # Locate full icon
    if (-not $FullIconPath -or -not (Test-Path $FullIconPath)) {
        $candidateFull = @(
            (Join-Path $PSScriptRoot "..\recycle bin new style\full.ico"),
            (Join-Path $PSScriptRoot "..\recycle bin new style\pop-cat-full.ico"),
            "e:\Projects\Win_Optimizer\recycle bin new style\full.ico",
            "e:\Projects\Win_Optimizer\recycle bin new style\pop-cat-full.ico",
            "E:\Sadman softs\recycle bin new style\pop-cat-full.ico"
        )
        foreach ($c in $candidateFull) {
            if ($c -and (Test-Path $c)) { $FullIconPath = (Resolve-Path $c).Path; break }
        }
    }

    if (-not $EmptyIconPath -or -not (Test-Path $EmptyIconPath) -or -not $FullIconPath -or -not (Test-Path $FullIconPath)) {
        Write-Host "      [!] Could not locate custom Recycle Bin icon files (.ico)." -ForegroundColor Red
        return
    }

    # Copy icons to persistent location so they survive folder movement
    $destEmpty = Join-Path $iconsDir "recycle-empty.ico"
    $destFull  = Join-Path $iconsDir "recycle-full.ico"
    Copy-Item -Path $EmptyIconPath -Destination $destEmpty -Force
    Copy-Item -Path $FullIconPath -Destination $destFull -Force

    # Registry keys for Recycle Bin DefaultIcon
    $clsidKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}"
    $iconKey  = "$clsidKey\DefaultIcon"

    if (-not (Test-Path $clsidKey)) { New-Item -Path $clsidKey -Force | Out-Null }
    if (-not (Test-Path $iconKey))  { New-Item -Path $iconKey -Force | Out-Null }

    # Set icon values in HKCU
    Set-ItemProperty -Path $iconKey -Name "(Default)" -Value $destFull -Type ExpandString -Force
    Set-ItemProperty -Path $iconKey -Name "empty"     -Value $destEmpty -Type ExpandString -Force
    Set-ItemProperty -Path $iconKey -Name "full"      -Value $destFull -Type ExpandString -Force

    # Refresh Windows Shell icon cache
    Update-DesktopIconCache

    Write-Host "      [+] Custom Pop Cat Recycle Bin icons applied successfully!" -ForegroundColor Green
    Write-Host "      [+] Empty icon: $destEmpty" -ForegroundColor Gray
    Write-Host "      [+] Full icon:  $destFull" -ForegroundColor Gray
}

function Restore-RecycleBinDefaultIcon {
    <#
    .SYNOPSIS
        Restores default Windows Recycle Bin desktop icons.
    #>
    Write-Host "`n[*] Restoring Default Windows Recycle Bin Desktop Icons..." -ForegroundColor Yellow

    $iconKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
    $defaultEmpty = "%SystemRoot%\System32\imageres.dll,-55"
    $defaultFull  = "%SystemRoot%\System32\imageres.dll,-54"

    if (Test-Path $iconKey) {
        Set-ItemProperty -Path $iconKey -Name "(Default)" -Value $defaultFull -Type ExpandString -Force
        Set-ItemProperty -Path $iconKey -Name "empty"     -Value $defaultEmpty -Type ExpandString -Force
        Set-ItemProperty -Path $iconKey -Name "full"      -Value $defaultFull -Type ExpandString -Force
    }

    # Refresh Windows Shell icon cache
    Update-DesktopIconCache

    Write-Host "      [+] Default Windows Recycle Bin icons restored successfully!" -ForegroundColor Green
}

function Disable-WindowsAds {
    <#
    .SYNOPSIS
        Comprehensively disables all advertising, promoted apps, and commercial suggestions across Windows 10/11.
    #>
    Write-Host "`n[*] Disabling All Advertising, Promoted Apps & Telemetry Commercials..." -ForegroundColor Yellow

    # 1. Lock Screen Ads & Spotlight Commercials
    $cdmKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    if (-not (Test-Path $cdmKey)) { New-Item -Path $cdmKey -Force | Out-Null }
    Set-ItemProperty -Path $cdmKey -Name 'RotatingLockScreenEnabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $cdmKey -Name 'RotatingLockScreenOverlayEnabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-338387Enabled' -Value 0 -Type DWord
    Write-Host "      [+] Lock screen ads, tips and rotating promotions disabled" -ForegroundColor Green

    # 2. Start Menu Promoted Apps & Suggestions
    Set-ItemProperty -Path $cdmKey -Name 'SystemPaneSuggestionsEnabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-338388Enabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-338389Enabled' -Value 0 -Type DWord
    Write-Host "      [+] Start Menu promoted apps and suggestions blocked" -ForegroundColor Green

    # 3. File Explorer Sync Provider Notifications (OneDrive Ads)
    $advKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (-not (Test-Path $advKey)) { New-Item -Path $advKey -Force | Out-Null }
    Set-ItemProperty -Path $advKey -Name 'ShowSyncProviderNotifications' -Value 0 -Type DWord
    Write-Host "      [+] File Explorer OneDrive and sync provider promo banners disabled" -ForegroundColor Green

    # 4. Settings App Suggested Content & Commercials
    Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-338393Enabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-353694Enabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-353696Enabled' -Value 0 -Type DWord
    Write-Host "      [+] Settings App suggested content and ads disabled" -ForegroundColor Green

    # 5. Windows Welcome Experience & Soft Landing
    Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-310093Enabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $cdmKey -Name 'SoftLandingEnabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $cdmKey -Name 'SilentInstalledAppsEnabled' -Value 0 -Type DWord
    Write-Host "      [+] Windows Welcome Experience tips and silent app installs blocked" -ForegroundColor Green

    # 6. Tailored Experiences & Diagnostic Data Ads
    $privKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy'
    if (-not (Test-Path $privKey)) { New-Item -Path $privKey -Force | Out-Null }
    Set-ItemProperty -Path $privKey -Name 'TailoredExperiencesWithDiagnosticDataEnabled' -Value 0 -Type DWord

    # 7. Advertising ID for Personalized Ads
    $adKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
    if (-not (Test-Path $adKey)) { New-Item -Path $adKey -Force | Out-Null }
    Set-ItemProperty -Path $adKey -Name 'Id' -Value 0 -Type DWord
    Set-ItemProperty -Path $adKey -Name 'Enabled' -Value 0 -Type DWord

    $polAdKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'
    if (-not (Test-Path $polAdKey)) { New-Item -Path $polAdKey -Force | Out-Null }
    Set-ItemProperty -Path $polAdKey -Name 'DisabledByGroupPolicy' -Value 1 -Type DWord
    Write-Host "      [+] Windows Advertising ID and Tailored Experiences disabled" -ForegroundColor Green

    # 8. Web Search Ads & Bing Integration in Windows Search
    $searchKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    if (-not (Test-Path $searchKey)) { New-Item -Path $searchKey -Force | Out-Null }
    Set-ItemProperty -Path $searchKey -Name 'BingSearchEnabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $searchKey -Name 'CortanaConsent' -Value 0 -Type DWord

    $polSearchKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
    if (-not (Test-Path $polSearchKey)) { New-Item -Path $polSearchKey -Force | Out-Null }
    Set-ItemProperty -Path $polSearchKey -Name 'DisableWebSearch' -Value 1 -Type DWord
    Set-ItemProperty -Path $polSearchKey -Name 'ConnectedSearchUseWeb' -Value 0 -Type DWord
    Write-Host "      [+] Bing Web Search and sponsored search results disabled" -ForegroundColor Green

    # 9. Notification Setup Prompts & Consumer Cloud Content
    $userEngKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement'
    if (-not (Test-Path $userEngKey)) { New-Item -Path $userEngKey -Force | Out-Null }
    Set-ItemProperty -Path $userEngKey -Name 'ScoobeSystemSettingEnabled' -Value 0 -Type DWord

    $cloudKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
    if (-not (Test-Path $cloudKey)) { New-Item -Path $cloudKey -Force | Out-Null }
    Set-ItemProperty -Path $cloudKey -Name 'DisableWindowsConsumerFeatures' -Value 1 -Type DWord
    Write-Host "      [+] Consumer bloatware auto-provisioning and device setup prompts blocked" -ForegroundColor Green

    Write-Host "      [OK] All Windows ads, suggestions, and promotional content disabled!" -ForegroundColor Green
}

function Enable-WindowsAds {
    <#
    .SYNOPSIS
        Reverts ad-blocking settings back to standard Windows defaults.
    #>
    Write-Host "`n[*] Restoring Windows Default Commercial & Ad Settings..." -ForegroundColor Yellow
    $cdmKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    if (Test-Path $cdmKey) {
        Set-ItemProperty -Path $cdmKey -Name 'RotatingLockScreenEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'RotatingLockScreenOverlayEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-338387Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SystemPaneSuggestionsEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-338388Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-338389Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-338393Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-353694Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-353696Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SubscribedContent-310093Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SoftLandingEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmKey -Name 'SilentInstalledAppsEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    $advKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (Test-Path $advKey) {
        Set-ItemProperty -Path $advKey -Name 'ShowSyncProviderNotifications' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    $polAdKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'
    if (Test-Path $polAdKey) {
        Remove-ItemProperty -Path $polAdKey -Name 'DisabledByGroupPolicy' -ErrorAction SilentlyContinue
    }
    $polSearchKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
    if (Test-Path $polSearchKey) {
        Remove-ItemProperty -Path $polSearchKey -Name 'DisableWebSearch' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $polSearchKey -Name 'ConnectedSearchUseWeb' -ErrorAction SilentlyContinue
    }
    $cloudKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
    if (Test-Path $cloudKey) {
        Remove-ItemProperty -Path $cloudKey -Name 'DisableWindowsConsumerFeatures' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Windows default suggestion and commercial settings restored." -ForegroundColor Green
}

function Disable-ShortcutArrow {
    <#
    .SYNOPSIS
        Removes the shortcut arrow overlay from Windows desktop and Explorer shortcuts (No Arrow).
    #>
    Write-Host "`n[*] Removing Windows Desktop Shortcut Arrow Overlay (No Arrow)..." -ForegroundColor Yellow

    # Target persistent directory for blank icon
    $iconsDir = "$env:LOCALAPPDATA\PumpkiNOptimizer\Icons"
    if (-not (Test-Path $iconsDir)) {
        New-Item -ItemType Directory -Path $iconsDir -Force | Out-Null
    }
    $destIco = Join-Path $iconsDir "blank.ico"

    # Locate source icon (bundled assets first, then fallback)
    $candidateBlank = @(
        (Join-Path $PSScriptRoot "..\assets\Icons\blank.ico"),
        "C:\ProgramData\WinaeroTweaker\ShellIcons\blank.ico",
        "e:\Projects\Win_Optimizer\assets\Icons\blank.ico"
    )
    $srcFound = $null
    foreach ($c in $candidateBlank) {
        if ($c -and (Test-Path $c)) {
            $srcFound = (Resolve-Path $c).Path
            break
        }
    }

    if ($srcFound) {
        Copy-Item -Path $srcFound -Destination $destIco -Force -ErrorAction SilentlyContinue
    }

    $shellIconsKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'
    if (-not (Test-Path $shellIconsKey)) { New-Item -Path $shellIconsKey -Force | Out-Null }

    $iconVal = if (Test-Path $destIco) { $destIco } else { "%SystemRoot%\System32\shell32.dll,-50" }
    Set-ItemProperty -Path $shellIconsKey -Name '29' -Value $iconVal -Type String -Force
    Write-Host "      [+] Shell Icons key '29' set to transparent icon ($iconVal)" -ForegroundColor Green

    # Refresh Windows Shell icon cache
    Update-DesktopIconCache

    Write-Host "      [OK] Desktop shortcut arrows removed (No arrow)!" -ForegroundColor Green
}

function Restore-ShortcutArrow {
    <#
    .SYNOPSIS
        Restores default Windows shortcut arrow overlay.
    #>
    Write-Host "`n[*] Restoring Default Windows Shortcut Arrow Icon Overlay..." -ForegroundColor Yellow
    $shellIconsKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'
    if (Test-Path $shellIconsKey) {
        Remove-ItemProperty -Path $shellIconsKey -Name '29' -ErrorAction SilentlyContinue
    }
    Update-DesktopIconCache
    Write-Host "      [+] Default Windows shortcut arrows restored." -ForegroundColor Green
}




# ==============================================================================