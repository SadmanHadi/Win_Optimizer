<#
================================================================================
   ____                       _    _       _   _ 
  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |
  | |_) | | | | '_ ` _ \| '_ \ |/ / | '_ \|  \| |
  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |
  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|
                        |_|                       
           ULTIMATE GAMING & NETWORK OPTIMIZER v5.0
          Created by PumpkiN | Max FPS - Ultra Low Latency
================================================================================
One-line run:
irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex
================================================================================
#>
param(
    [switch]$CLI
)

# 1. Administrator Elevation Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    $cliArg = if ($CLI) { " -CLI" } else { "" }
    if ($PSCommandPath) {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"$cliArg" -Verb RunAs
    } else {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex`"$cliArg" -Verb RunAs
    }
    return
}

$Host.UI.RawUI.WindowTitle = "PumpkiN's Ultimate Gaming and Network Optimizer v5.0"

# ==============================================================================
# 2. MODULAR LOADER ENGINE (LOCAL + REMOTE GITHUB FALLBACK)
# ==============================================================================

$ModuleList = @(
    "Hardware-Detection",
    "App-Catalog",
    "Gui-Markup",
    "Gui-Controller",
    "Optimize-AmdGpu",
    "Optimize-NvidiaGpu",
    "Optimize-GpuAuto",
    "Optimize-Network",
    "Toggle-WifiScan",
    "Optimize-KernelAndCpu",
    "Optimize-InputLatency",
    "Match-Booster",
    "Optimize-Hardening",
    "Optimize-SystemAndDebloat",
    "System-DiagnosticsAndRestore"
)

$moduleBaseDir = if ($PSScriptRoot) { Join-Path $PSScriptRoot "modules" } else { Join-Path (Get-Location) "modules" }
$rawGithubBase = "https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/modules"

foreach ($modName in $ModuleList) {
    $localPath = Join-Path $moduleBaseDir "$modName.ps1"
    if (Test-Path $localPath) {
        . $localPath
    } else {
        try {
            $webCode = (New-Object System.Net.WebClient).DownloadString("$rawGithubBase/$modName.ps1")
            $sb = [scriptblock]::Create($webCode)
            . $sb
        } catch {
            Write-Warning "Could not load module $modName : $($_.Exception.Message)"
        }
    }
}

# ==============================================================================
# 3. CONSOLE BANNER & INTERACTIVE CLI MENU
# ==============================================================================

function Show-PumpkiNBanner {
    Clear-Host
    $Host.UI.RawUI.ForegroundColor = 'Cyan'
    Write-Host "================================================================================"
    Write-Host "   ____                       _    _       _   _ "
    Write-Host "  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |"
    Write-Host "  | |_) | | | | '_ \ _ \| '_ \ |/ / | '_ \|  \| |"
    Write-Host "  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |"
    Write-Host "  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|"
    Write-Host "                        |_|                       "
    Write-Host "           ULTIMATE GAMING & NETWORK OPTIMIZER v5.0"
    Write-Host "          Created by PumpkiN | Max FPS - Ultra Low Latency"
    Write-Host "================================================================================"
    $Host.UI.RawUI.ForegroundColor = 'Gray'
    
    $hw = Get-HardwareProfile
    Write-Host "  [CPU] $($hw.CpuName) ($($hw.CpuCores))" -ForegroundColor DarkCyan
    foreach ($g in $hw.Gpus) {
        Write-Host "  [GPU] $($g.Name) (Driver: $($g.DriverVersion))" -ForegroundColor DarkCyan
    }
    if ($hw.Adapter) {
        $netType = if ($hw.IsWifi) { "Wi-Fi (Wireless)" } else { "Ethernet (Wired)" }
        Write-Host "  [NET] $($hw.Adapter.Name) [$netType]" -ForegroundColor DarkCyan
    }
    Write-Host "--------------------------------------------------------------------------------"
    Write-Host "  [1]  FULL ALL-IN-ONE OPTIMIZATION (Hardware Auto-Detect + All Tweaks) [BEST]" -ForegroundColor Green
    Write-Host "  [2]  Auto-Detect & Optimize Active GPU (NVIDIA / AMD Radeon)"
    Write-Host "  [3]  AMD Radeon GPU Dedicated Suite (Disable ULPS, Shader Cache, Anti-Lag)" -ForegroundColor Magenta
    Write-Host "  [4]  NVIDIA GeForce Dedicated Suite (PowerMizer P0, Max Performance, Cache)" -ForegroundColor Green
    Write-Host "  [5]  Network & Anti-Lag Suite (Nagle Off, 100% QoS, NDU Leak Fix, DNS)"
    Write-Host "  [6]  Wi-Fi Ping Spike Mitigator (Toggle Background Scan for 0ms Spikes)"
    Write-Host "  [7]  CPU, Kernel & Quantum Engine (Win32Priority 0x26, FTH Off, Core Unpark)"
    Write-Host "  [8]  Ultra-Low Latency, DPC & 8000Hz Input (StopHighDPC, Raw Mouse Curve)"
    Write-Host "  [9]  Competitive Match Booster (Immediate RAM Flush + 5-Min Background Auto-Purge)" -ForegroundColor Cyan
    Write-Host "  [10] Game-Specific High Priority Hooks (Valorant, CS2, Apex, Fortnite, COD)"
    Write-Host "  [11] System Health, Live Diagnostics & Hardware Spec Sheet"
    Write-Host "  [12] Create Windows System Restore Point (Safety Backup)" -ForegroundColor Cyan
    Write-Host "  [13] Revert All Settings to Windows Defaults" -ForegroundColor DarkYellow
    Write-Host "  [14] Activate Windows (Microsoft Activation Scripts - MAS)" -ForegroundColor Yellow
    Write-Host "  ---- BEAST MODE OPTIMIZATIONS ------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "  [15] Debloat & Disable Background Services (SysMain, Telemetry, Xbox, Cortana)"
    Write-Host "  [16] Ultimate Performance Power Plan + HPET/Timer Optimization" -ForegroundColor Green
    Write-Host "  [17] Strip All Visual Effects & Animations (Pure Performance Mode)"
    Write-Host "  [18] Privacy & Telemetry Hardening (Kill All Tracking & Ads)" -ForegroundColor Magenta
    Write-Host "  [19] Disk I/O & Storage Optimization (NTFS Tweaks + Temp Cleanup)"
    Write-Host "  [20] Disable Junk Scheduled Tasks (Compatibility, Defrag, Diagnostics)"
    Write-Host "  [21] Startup Bloat Cleanup & Gaming DNS (Cloudflare 1.1.1.1)" -ForegroundColor Cyan
    Write-Host "  ---- PRO TOOLS & HARDENING ---------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "  [22] WinUtil Tweaks (MPO Fix, Mouse Curve, SvcHost Splitting, End Task)" -ForegroundColor Green
    Write-Host "  [23] WinGet Software Manager (Install, Update, or Search 100+ Applications)" -ForegroundColor Cyan
    Write-Host "  [24] Block Peripheral & UEFI Bloatware (Razer, Armoury Crate icacls deny)" -ForegroundColor Yellow
    Write-Host "  [25] Purge Windows AI Bloatware (Recall, Copilot, CoreAI)" -ForegroundColor Magenta
    Write-Host "  [26] Security-Only Updates (Defer Feature Builds 2 Years, Keep Quality Updates)" -ForegroundColor Green
    Write-Host "  [27] Restore Windows 10 Classic Right-Click Menu & File Visibility" -ForegroundColor Cyan
    Write-Host "  [28] CompactOS LZX Compression (Reclaim 3-6GB on SSD/NVMe)" -ForegroundColor Green
    Write-Host "  [29] Add 'Take Ownership' to Explorer Right-Click Menu" -ForegroundColor Cyan
    Write-Host "  [30] Purge Windows Update & Delivery Optimization Cache" -ForegroundColor Yellow
    Write-Host "  [31] Download & Install DirectX + Visual C++ AIO (Direct from Sites)" -ForegroundColor Magenta
    Write-Host "  [32] Deep Cache & Event Cleaner (Temp, Prefetch, Spooler, Wipes Event Logs)" -ForegroundColor Yellow
    Write-Host "  [0]  Exit" -ForegroundColor Red
    Write-Host "================================================================================"
}

function Show-ConsoleMenu {
    do {
        Show-PumpkiNBanner
        $choice = Read-Host "Select an option [0-32]"
        switch ($choice) {
            "1" {
                Optimize-Network
                Optimize-GpuAuto
                Optimize-CpuAndSystem
                Optimize-LatencyAndInput
                Apply-GameHooks
                Debloat-BackgroundServices
                Enable-UltimatePerformancePlan
                Strip-VisualEffects
                Harden-PrivacyTelemetry
                Optimize-DiskIO
                Disable-ScheduledJunkTasks
                Optimize-StartupAndDns
                Disable-MultiplaneOverlay
                Set-MouseLinearCurve
                Optimize-SvcHostSplitting
                Enable-EndTaskRightClick
                Disable-StickyKeysPrompt
                Enable-TakeOwnershipMenu
                Clear-WindowsUpdateCache
                Invoke-DeepCacheCleaner
                Write-Host "`n================================================================================" -ForegroundColor Green
                Write-Host "  [OK] ALL OPTIMIZATIONS APPLIED SUCCESSFULLY  --  FULL BEAST MODE ENGAGED!" -ForegroundColor Green
                Write-Host "================================================================================" -ForegroundColor Green
                Write-Host "  A system RESTART is recommended for all changes to take full effect." -ForegroundColor Yellow
                Read-Host "`nPress Enter to return to menu"
            }
            "2" {
                Optimize-GpuAuto
                Write-Host "`n[OK] GPU Auto-Optimization complete!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "3" {
                Optimize-AmdGpu
                Write-Host "`n[OK] AMD Radeon GPU optimization complete!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "4" {
                Optimize-NvidiaGpu
                Write-Host "`n[OK] NVIDIA GeForce GPU optimization complete!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "5" {
                Optimize-Network
                Write-Host "`n[OK] Network optimizations applied!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "6" {
                Toggle-WifiAutoconfig
                Read-Host "`nPress Enter to return to menu"
            }
            "7" {
                Optimize-CpuAndSystem
                Write-Host "`n[OK] CPU & System optimizations applied!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "8" {
                Optimize-LatencyAndInput
                Write-Host "`n[OK] Ultra-low latency & 8000Hz input tweaks applied!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "9" {
                Boost-CompetitiveMatch
                Write-Host "`n[OK] Competitive Match Booster applied!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "10" {
                Apply-GameHooks
                Write-Host "`n[OK] Esports Game Priority Hooks installed!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "11" {
                Run-Diagnostics
                Read-Host "`nPress Enter to return to menu"
            }
            "12" {
                Create-RestorePoint
                Read-Host "`nPress Enter to return to menu"
            }
            "13" {
                Restore-Defaults
                Write-Host "`n[OK] Default settings restored!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "14" {
                Write-Host "`n[*] Launching Microsoft Activation Scripts (MAS)..." -ForegroundColor Yellow
                Write-Host "      A new PowerShell window will open with the MAS interface." -ForegroundColor Cyan
                Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
                Read-Host "`nPress Enter to return to menu"
            }
            "15" {
                Debloat-BackgroundServices
                Write-Host "`n[OK] Background services debloated!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "16" {
                Enable-UltimatePerformancePlan
                Write-Host "`n[OK] Ultimate Performance Power Plan activated!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "17" {
                Strip-VisualEffects
                Write-Host "`n[OK] All visual effects stripped for maximum performance!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "18" {
                Harden-PrivacyTelemetry
                Write-Host "`n[OK] Privacy hardened and telemetry disabled!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "19" {
                Optimize-DiskIO
                Write-Host "`n[OK] Disk I/O and storage optimized!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "20" {
                Disable-ScheduledJunkTasks
                Write-Host "`n[OK] Junk scheduled tasks disabled!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "21" {
                Optimize-StartupAndDns
                Write-Host "`n[OK] Startup cleaned and DNS optimized!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "22" {
                Disable-MultiplaneOverlay
                Set-MouseLinearCurve
                Optimize-SvcHostSplitting
                Enable-EndTaskRightClick
                Disable-StickyKeysPrompt
                Write-Host "`n[OK] WinUtil core gaming tweaks applied!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "23" {
                Write-Host "`n=== WINGET SOFTWARE MANAGER ===" -ForegroundColor Cyan
                Write-Host "  [1] Upgrade All Installed Apps"
                Write-Host "  [2] Install Recommended Gaming Apps (Steam, Discord, OBS, Afterburner)"
                Write-Host "  [3] Custom WinGet Install by ID"
                $wChoice = Read-Host "Select option [1-3]"
                switch ($wChoice) {
                    "1" { Upgrade-AllWinGetPackages }
                    "2" {
                        Install-WinGetPackage -PackageId "Valve.Steam"
                        Install-WinGetPackage -PackageId "Discord.Discord"
                        Install-WinGetPackage -PackageId "OBSProject.OBSStudio"
                        Install-WinGetPackage -PackageId "Guru3D.Afterburner"
                    }
                    "3" {
                        $pId = Read-Host "Enter WinGet Package ID (e.g. Brave.Brave)"
                        if ($pId) { Install-WinGetPackage -PackageId $pId }
                    }
                }
                Read-Host "`nPress Enter to return to menu"
            }
            "24" {
                Block-WpbtExecution
                Block-PeripheralBloat
                Write-Host "`n[OK] Peripheral & UEFI bloatware execution blocked!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "25" {
                Remove-WindowsAI
                Write-Host "`n[OK] Windows AI bloatware (Recall, Copilot, CoreAI) purged!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "26" {
                Set-SecurityUpdatesOnly
                Write-Host "`n[OK] Windows Update configured for security patches only (Feature builds deferred 2 years)!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "27" {
                Enable-ClassicContextMenu
                Set-ShowFileExtensionsAndHidden
                Write-Host "`n[OK] Windows 10 classic context menu and file visibility restored!" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "28" {
                Enable-CompactOS
                Read-Host "`nPress Enter to return to menu"
            }
            "29" {
                Enable-TakeOwnershipMenu
                Read-Host "`nPress Enter to return to menu"
            }
            "30" {
                Clear-WindowsUpdateCache
                Read-Host "`nPress Enter to return to menu"
            }
            "31" {
                Install-DirectXDirect
                Install-VcRedistAioDirect
                Read-Host "`nPress Enter to return to menu"
            }
            "32" {
                Invoke-DeepCacheCleaner
                Read-Host "`nPress Enter to return to menu"
            }
            "0" {
                Write-Host "`nThank you for using PumpkiN's Ultimate Gaming Optimizer!" -ForegroundColor Cyan
                Start-Sleep -Seconds 1
                return
            }
        }
    } while ($choice -ne "0")
}

# ==============================================================================
# 4. DISPATCHER ENTRY POINT
# ==============================================================================

if ($CLI) {
    Show-ConsoleMenu
} else {
    try {
        Start-PumpkiNGui
    } catch {
        Write-Host "[-] GUI could not be initialized: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "[*] Launching interactive CLI menu instead..." -ForegroundColor Yellow
        Show-ConsoleMenu
    }
}