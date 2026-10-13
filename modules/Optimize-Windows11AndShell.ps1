<#
================================================================================
  PumpkiN's Modular Suite: Windows 11 Exclusives & Shell Usability Optimizations
================================================================================
#>

# 1. Virtualization-Based Security (VBS) Toggle
function Disable-VbsSecurity {
    Write-Host "`n[*] Disabling Virtualization-Based Security (VBS / HVCI)..." -ForegroundColor Yellow
    try {
        bcdedit /set hypervisorlaunchtype off 2>$null | Out-Null
        $dgPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'
        if (-not (Test-Path $dgPath)) { New-Item -Path $dgPath -Force | Out-Null }
        Set-ItemProperty -Path $dgPath -Name 'EnableVirtualizationBasedSecurity' -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $dgPath -Name 'RequirePlatformSecurityFeatures' -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Write-Host "      [+] VBS / Hypervisor disabled -- Gaming CPU frame latency improved!" -ForegroundColor Green
    } catch {
        Write-Host "      [!] Failed to disable VBS: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Restore-VbsSecurity {
    Write-Host "`n[*] Restoring Virtualization-Based Security (VBS) Default State..." -ForegroundColor Yellow
    try {
        bcdedit /set hypervisorlaunchtype auto 2>$null | Out-Null
        $dgPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'
        if (Test-Path $dgPath) {
            Set-ItemProperty -Path $dgPath -Name 'EnableVirtualizationBasedSecurity' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        }
        Write-Host "      [+] VBS restored to Windows default (Auto)." -ForegroundColor Green
    } catch {}
}

# 2. Windows 11 Taskbar Alignment (Left vs Center)
function Set-TaskbarAlignmentLeft {
    Write-Host "`n[*] Aligning Windows 11 Taskbar to the Left..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (-not (Test-Path $advPath)) { New-Item -Path $advPath -Force | Out-Null }
    Set-ItemProperty -Path $advPath -Name 'TaskbarAl' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Taskbar aligned to Left (Classic Windows Layout)." -ForegroundColor Green
}

function Restore-TaskbarAlignmentCenter {
    Write-Host "`n[*] Restoring Windows 11 Taskbar Alignment to Center..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (Test-Path $advPath) {
        Set-ItemProperty -Path $advPath -Name 'TaskbarAl' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Taskbar restored to Center." -ForegroundColor Green
}

# 3. Disable Recommended Section in Windows 11 Start Menu
function Disable-StartMenuRecommended {
    Write-Host "`n[*] Disabling Recommended Section in Start Menu..." -ForegroundColor Yellow
    $polPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
    if (-not (Test-Path $polPath)) { New-Item -Path $polPath -Force | Out-Null }
    Set-ItemProperty -Path $polPath -Name 'HideRecommendedSection' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (-not (Test-Path $advPath)) { New-Item -Path $advPath -Force | Out-Null }
    Set-ItemProperty -Path $advPath -Name 'Start_IrisRecommendations' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Start Menu Recommended section disabled -- Clean start layout!" -ForegroundColor Green
}

function Restore-StartMenuRecommended {
    Write-Host "`n[*] Restoring Start Menu Recommended Section..." -ForegroundColor Yellow
    $polPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
    if (Test-Path $polPath) {
        Remove-ItemProperty -Path $polPath -Name 'HideRecommendedSection' -ErrorAction SilentlyContinue
    }
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (Test-Path $advPath) {
        Set-ItemProperty -Path $advPath -Name 'Start_IrisRecommendations' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Start Menu Recommended section restored." -ForegroundColor Green
}

# 4. Disable Windows 11 Taskbar Chat (Teams Integration)
function Disable-TaskbarChat {
    Write-Host "`n[*] Disabling Taskbar Chat (Teams Icon)..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (-not (Test-Path $advPath)) { New-Item -Path $advPath -Force | Out-Null }
    Set-ItemProperty -Path $advPath -Name 'TaskbarMn' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    $chatPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat'
    if (-not (Test-Path $chatPol)) { New-Item -Path $chatPol -Force | Out-Null }
    Set-ItemProperty -Path $chatPol -Name 'ChatIcon' -Value 3 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Taskbar Chat icon hidden and disabled." -ForegroundColor Green
}

function Restore-TaskbarChat {
    Write-Host "`n[*] Restoring Taskbar Chat Icon..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (Test-Path $advPath) {
        Set-ItemProperty -Path $advPath -Name 'TaskbarMn' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    $chatPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat'
    if (Test-Path $chatPol) {
        Remove-ItemProperty -Path $chatPol -Name 'ChatIcon' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Taskbar Chat restored." -ForegroundColor Green
}

# 5. Enable Files Compact Mode in Windows Explorer
function Enable-FilesCompactMode {
    Write-Host "`n[*] Enabling Files Explorer Compact Mode (Decreased Item Padding)..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (-not (Test-Path $advPath)) { New-Item -Path $advPath -Force | Out-Null }
    Set-ItemProperty -Path $advPath -Name 'UseCompactMode' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] File Explorer Compact View enabled." -ForegroundColor Green
}

function Restore-FilesCompactMode {
    Write-Host "`n[*] Restoring File Explorer Standard Spacing..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (Test-Path $advPath) {
        Set-ItemProperty -Path $advPath -Name 'UseCompactMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] File Explorer Compact View disabled." -ForegroundColor Green
}

# 6. Disable Snap Assist & Automatic Window Arranging
function Disable-SnapAssist {
    Write-Host "`n[*] Disabling Snap Assist & Auto Window Suggestions..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (-not (Test-Path $advPath)) { New-Item -Path $advPath -Force | Out-Null }
    Set-ItemProperty -Path $advPath -Name 'SnapAssist' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $advPath -Name 'JointResize' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Snap Assist disabled -- Manual window positioning only." -ForegroundColor Green
}

function Restore-SnapAssist {
    Write-Host "`n[*] Restoring Windows Snap Assist..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (Test-Path $advPath) {
        Set-ItemProperty -Path $advPath -Name 'SnapAssist' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $advPath -Name 'JointResize' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Snap Assist restored." -ForegroundColor Green
}

# 7. Disable Windows 11 Desktop Stickers
function Disable-WindowsStickers {
    Write-Host "`n[*] Disabling Windows 11 Desktop Stickers..." -ForegroundColor Yellow
    $stkPath = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Stickers'
    if (-not (Test-Path $stkPath)) { New-Item -Path $stkPath -Force | Out-Null }
    Set-ItemProperty -Path $stkPath -Name 'EnableStickers' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Windows 11 Desktop Stickers disabled." -ForegroundColor Green
}

function Restore-WindowsStickers {
    Write-Host "`n[*] Restoring Windows 11 Desktop Stickers..." -ForegroundColor Yellow
    $stkPath = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Stickers'
    if (Test-Path $stkPath) {
        Remove-ItemProperty -Path $stkPath -Name 'EnableStickers' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Desktop Stickers setting restored." -ForegroundColor Green
}

# 8. Disable Microsoft Edge Discover Bar & Bing Button
function Disable-EdgeDiscoverBar {
    Write-Host "`n[*] Disabling Microsoft Edge Discover Bar & Copilot Button..." -ForegroundColor Yellow
    $edgePol = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
    if (-not (Test-Path $edgePol)) { New-Item -Path $edgePol -Force | Out-Null }
    Set-ItemProperty -Path $edgePol -Name 'HubsSidebarEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $edgePol -Name 'ShowCopilotButton' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Edge Discover bar and Copilot button disabled." -ForegroundColor Green
}

function Restore-EdgeDiscoverBar {
    Write-Host "`n[*] Restoring Microsoft Edge Discover Bar..." -ForegroundColor Yellow
    $edgePol = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
    if (Test-Path $edgePol) {
        Remove-ItemProperty -Path $edgePol -Name 'HubsSidebarEnabled' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $edgePol -Name 'ShowCopilotButton' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Edge Discover Bar restored." -ForegroundColor Green
}

# 9. Add 'Copy To' and 'Move To' Folder to Explorer Context Menu
function Enable-CopyMoveContextMenu {
    Write-Host "`n[*] Adding 'Copy To' & 'Move To' Folder to Right-Click Context Menu..." -ForegroundColor Yellow
    $copyKey = 'HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To'
    $moveKey = 'HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To'
    if (-not (Test-Path $copyKey)) { New-Item -Path $copyKey -Force | Out-Null }
    if (-not (Test-Path $moveKey)) { New-Item -Path $moveKey -Force | Out-Null }
    Set-ItemProperty -Path $copyKey -Name '(Default)' -Value '{C2FBB630-2971-11D1-A18C-00C04FD75D13}' -Force
    Set-ItemProperty -Path $moveKey -Name '(Default)' -Value '{C2FBB631-2971-11D1-A18C-00C04FD75D13}' -Force
    Write-Host "      [+] 'Copy To folder' & 'Move To folder' context menus added!" -ForegroundColor Green
}

function Restore-CopyMoveContextMenu {
    Write-Host "`n[*] Removing 'Copy To' & 'Move To' Folder from Context Menu..." -ForegroundColor Yellow
    Remove-Item -Path 'HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path 'HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To' -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] 'Copy To' & 'Move To' context menus removed." -ForegroundColor Green
}

# 10. Disable Window Shake (Aero Shake)
function Disable-WindowShake {
    Write-Host "`n[*] Disabling Windows Window Shake (Aero Shake Minimization)..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (-not (Test-Path $advPath)) { New-Item -Path $advPath -Force | Out-Null }
    Set-ItemProperty -Path $advPath -Name 'DisallowShaking' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $polPath = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
    if (-not (Test-Path $polPath)) { New-Item -Path $polPath -Force | Out-Null }
    Set-ItemProperty -Path $polPath -Name 'DisallowShaking' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Window Shake disabled -- Shaking active window will not minimize others." -ForegroundColor Green
}

function Restore-WindowShake {
    Write-Host "`n[*] Restoring Window Shake (Aero Shake)..." -ForegroundColor Yellow
    $advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (Test-Path $advPath) {
        Set-ItemProperty -Path $advPath -Name 'DisallowShaking' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    $polPath = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
    if (Test-Path $polPath) {
        Remove-ItemProperty -Path $polPath -Name 'DisallowShaking' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Window Shake restored." -ForegroundColor Green
}

# 11. Windows System Dark Mode
function Set-WindowsDarkMode {
    Write-Host "`n[*] Enabling Windows System & Apps Dark Mode..." -ForegroundColor Yellow
    $persPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    if (-not (Test-Path $persPath)) { New-Item -Path $persPath -Force | Out-Null }
    Set-ItemProperty -Path $persPath -Name 'AppsUseLightTheme' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $persPath -Name 'SystemUsesLightTheme' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] System and application Dark Mode enabled (Activation not required)." -ForegroundColor Green
}

function Restore-WindowsLightMode {
    Write-Host "`n[*] Restoring Windows Light Mode..." -ForegroundColor Yellow
    $persPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    if (Test-Path $persPath) {
        Set-ItemProperty -Path $persPath -Name 'AppsUseLightTheme' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $persPath -Name 'SystemUsesLightTheme' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Standard Light Mode restored." -ForegroundColor Green
}

# 12. Enable Verbose Logon Messages
function Enable-VerboseLogon {
    Write-Host "`n[*] Enabling Verbose Logon / Logoff Status Messages..." -ForegroundColor Yellow
    $sysPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    if (-not (Test-Path $sysPath)) { New-Item -Path $sysPath -Force | Out-Null }
    Set-ItemProperty -Path $sysPath -Name 'VerboseStatus' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Verbose Logon enabled -- Detailed boot and profile diagnostics shown." -ForegroundColor Green
}

function Restore-VerboseLogon {
    Write-Host "`n[*] Restoring Standard Logon Messages..." -ForegroundColor Yellow
    $sysPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    if (Test-Path $sysPath) {
        Remove-ItemProperty -Path $sysPath -Name 'VerboseStatus' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Standard Logon messages restored." -ForegroundColor Green
}

# 13. Disable Quick Access Recent & Frequent History
function Disable-QuickAccessHistory {
    Write-Host "`n[*] Disabling Quick Access Recent Files & Frequent Folders..." -ForegroundColor Yellow
    $expPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
    if (-not (Test-Path $expPath)) { New-Item -Path $expPath -Force | Out-Null }
    Set-ItemProperty -Path $expPath -Name 'ShowRecent' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $expPath -Name 'ShowFrequent' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Quick Access recent files and frequent folders disabled." -ForegroundColor Green
}

function Restore-QuickAccessHistory {
    Write-Host "`n[*] Restoring Quick Access History..." -ForegroundColor Yellow
    $expPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
    if (Test-Path $expPath) {
        Set-ItemProperty -Path $expPath -Name 'ShowRecent' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $expPath -Name 'ShowFrequent' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Quick Access history restored." -ForegroundColor Green
}

# 14. Disable My People Taskbar Integration
function Disable-MyPeople {
    Write-Host "`n[*] Disabling My People Taskbar Feature..." -ForegroundColor Yellow
    $pplPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
    if (-not (Test-Path $pplPath)) { New-Item -Path $pplPath -Force | Out-Null }
    Set-ItemProperty -Path $pplPath -Name 'PeopleBand' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] My People taskbar icon disabled." -ForegroundColor Green
}

function Restore-MyPeople {
    Write-Host "`n[*] Restoring My People Feature..." -ForegroundColor Yellow
    $pplPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
    if (Test-Path $pplPath) {
        Set-ItemProperty -Path $pplPath -Name 'PeopleBand' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] My People restored." -ForegroundColor Green
}

# 15. Disable Windows Ink Workspace
function Disable-WindowsInk {
    Write-Host "`n[*] Disabling Windows Ink Workspace..." -ForegroundColor Yellow
    $inkPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsInkWorkspace'
    if (-not (Test-Path $inkPath)) { New-Item -Path $inkPath -Force | Out-Null }
    Set-ItemProperty -Path $inkPath -Name 'AllowWindowsInkWorkspace' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Windows Ink Workspace disabled." -ForegroundColor Green
}

function Restore-WindowsInk {
    Write-Host "`n[*] Restoring Windows Ink Workspace..." -ForegroundColor Yellow
    $inkPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsInkWorkspace'
    if (Test-Path $inkPath) {
        Remove-ItemProperty -Path $inkPath -Name 'AllowWindowsInkWorkspace' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Windows Ink Workspace restored." -ForegroundColor Green
}

# 16. Disable Cast to Device (PlayTo)
function Disable-CastToDevice {
    Write-Host "`n[*] Disabling Cast to Device (PlayTo Service)..." -ForegroundColor Yellow
    $playPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PlayTo'
    if (-not (Test-Path $playPath)) { New-Item -Path $playPath -Force | Out-Null }
    Set-ItemProperty -Path $playPath -Name 'NoPlayTo' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Cast to Device disabled." -ForegroundColor Green
}

function Restore-CastToDevice {
    Write-Host "`n[*] Restoring Cast to Device..." -ForegroundColor Yellow
    $playPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PlayTo'
    if (Test-Path $playPath) {
        Remove-ItemProperty -Path $playPath -Name 'NoPlayTo' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Cast to Device restored." -ForegroundColor Green
}

# 17. Enable Legacy Boot Menu
function Enable-LegacyBootMenu {
    Write-Host "`n[*] Enabling Legacy Boot Menu (F8 Safe Mode Menu)..." -ForegroundColor Yellow
    try {
        bcdedit /set "{default}" bootmenupolicy legacy 2>$null | Out-Null
        Write-Host "      [+] Legacy F8 Boot Menu enabled." -ForegroundColor Green
    } catch {}
}

function Restore-LegacyBootMenu {
    Write-Host "`n[*] Restoring Standard Modern Boot Menu..." -ForegroundColor Yellow
    try {
        bcdedit /set "{default}" bootmenupolicy standard 2>$null | Out-Null
        Write-Host "      [+] Standard Boot Menu restored." -ForegroundColor Green
    } catch {}
}

# Compatibility Aliases for GUI & CLI Dispatchers
function Set-TaskbarLeftAlign { Set-TaskbarAlignmentLeft }
function Disable-RecommendedStartSection { Disable-StartMenuRecommended }
function Disable-DesktopStickers { Disable-WindowsStickers }
function Enable-CopyMoveToContextMenu { Enable-CopyMoveContextMenu }
function Enable-SystemDarkMode { Set-WindowsDarkMode }

# Standalone execution check
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Disable-VbsSecurity
    Set-TaskbarAlignmentLeft
    Disable-StartMenuRecommended
    Disable-TaskbarChat
    Enable-FilesCompactMode
    Enable-CopyMoveContextMenu
    Disable-WindowShake
    Set-WindowsDarkMode
    Read-Host "`nPress Enter to exit"
}
