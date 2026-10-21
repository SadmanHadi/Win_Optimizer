<#
================================================================================
   ____                       _    _       _   _ 
  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |
  | |_) | | | | '_ ` _ \| '_ \ |/ / | '_ \|  \| |
  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |
  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|
                        |_|                       
            ULTIMATE GAMING & NETWORK OPTIMIZER v5.6.1
            Created by PumpkiN | Max FPS - Ultra Low Latency
================================================================================
One-line run:
irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex
================================================================================
#>
param(
    [switch]$CLI
)

$Global:OptimizerProjectRoot = if ($PSScriptRoot) { $PSScriptRoot } elseif (Test-Path "E:\Projects\Win_Optimizer") { "E:\Projects\Win_Optimizer" } else { (Get-Location).Path }

# 1. Administrator Elevation Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    $cliArg = if ($CLI) { " -CLI" } else { "" }
    if ($PSCommandPath) {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"$cliArg" -WorkingDirectory "$Global:OptimizerProjectRoot" -Verb RunAs
    } else {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex`"$cliArg" -WorkingDirectory "$Global:OptimizerProjectRoot" -Verb RunAs
    }
    exit
}

$Host.UI.RawUI.WindowTitle = "PumpkiN's Ultimate Gaming and Network Optimizer v5.6.1"

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
    "Optimize-Windows11AndShell",
    "Optimize-PrivacyAndTelemetry",
    "Install-CustomCursors",
    "System-DiagnosticsAndRestore"
)

$moduleBaseDir = if ($PSScriptRoot) { Join-Path $PSScriptRoot "modules" } else { Join-Path (Get-Location) "modules" }
$rawGithubBase = "https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/modules"
$rawBundleUrl  = "https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/dist/optimizer.ps1"

# Fast single-request remote execution: stream pre-compiled bundle if modules not local
$hasLocalModules = Test-Path (Join-Path $moduleBaseDir "Hardware-Detection.ps1")
if (-not $hasLocalModules) {
    try {
        Write-Host "[*] Streaming all-in-one optimizer bundle from GitHub..." -ForegroundColor Cyan
        $wc = New-Object System.Net.WebClient
        $bundleCode = $wc.DownloadString($rawBundleUrl)
        $sb = [scriptblock]::Create($bundleCode)
        if ($CLI) {
            & $sb -CLI
        } else {
            & $sb
        }
        exit
    } catch {
        Write-Warning "Bundle stream failed ($($_.Exception.Message)). Falling back to individual modules..."
    }
}

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
    Write-Host "           ULTIMATE GAMING & NETWORK OPTIMIZER v5.6.1"
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
    try {
        $audit = Get-SystemAuditState
        $scCol = if ($audit.ScorePercent -ge 80) { 'Green' } elseif ($audit.ScorePercent -ge 50) { 'Yellow' } else { 'Cyan' }
        Write-Host "  [SCORE] System Tuning Score: $($audit.ScoreGrade) ($($audit.ScoreApplied)/$($audit.ScoreTotal) Active)" -ForegroundColor $scCol
    } catch {}
    Write-Host "--------------------------------------------------------------------------------"
    Write-Host "  [1]  FULL ALL-IN-ONE OPTIMIZATION (Hardware Auto-Detect + All Tweaks) [BEST]" -ForegroundColor Green
    Write-Host "  [2]  Auto-Detect & Optimize Active GPU (NVIDIA / AMD Radeon)"
    Write-Host "  [3]  AMD Radeon GPU Dedicated Suite (Disable ULPS, Shader Cache, Anti-Lag)" -ForegroundColor Magenta
    Write-Host "  [4]  NVIDIA GeForce Dedicated Suite (PowerMizer P0, Max Performance, Cache)" -ForegroundColor Green
    Write-Host "  [5]  Network & Anti-Lag Suite (Nagle Off, 100% QoS, NDU Leak Fix, DNS)"
    Write-Host "  [6]  Wi-Fi Ping Spike Mitigator (Toggle Background Scan for 0ms Spikes)"
    Write-Host "  [7]  CPU, Kernel & Quantum Engine (Win32Priority 0x26, FTH Off, Core Unpark)"
    Write-Host "  [8]  Ultra-Low Latency, DPC & 8000Hz Input (StopHighDPC, Raw Mouse Curve)"
    Write-Host "  [9]  Competitive Match Booster (One-Time Purge & Background Auto-Scheduler)" -ForegroundColor Cyan
    Write-Host "  [10] Game-Specific High Priority Hooks (Valorant, CS2, Apex, PUBG, Fortnite, COD)"
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
    Write-Host "  [33] Pop Cat Recycle Bin Icons (One-Click Pop Cat Empty & Full Desktop Icons)" -ForegroundColor Green
    Write-Host "  [34] Restore Default Windows Recycle Bin Icons" -ForegroundColor DarkYellow
    Write-Host "  [35] GPU Shader, Discord & Browser Cache Cleaner (DirectX, NVIDIA, AMD, Chrome)" -ForegroundColor Yellow
    Write-Host "  [36] Gaming DNS Benchmark & 1-Click Fast Switcher (Cloudflare, Google, Quad9, etc.)" -ForegroundColor Cyan
    Write-Host "  [37] Reset DNS to Automatic (DHCP Defaults)" -ForegroundColor DarkYellow
    Write-Host "  [38] Start/Stop Smart Game Booster Daemon (Realtime Process Watcher)" -ForegroundColor Cyan
    Write-Host "  [39] View Live Hardware Telemetry Monitor (Live CPU, RAM, Ping)" -ForegroundColor Green
    Write-Host "  [40] Activate PumpkiN Esports Ultimate Power Plan (0% Core Parking, Zero Latency)" -ForegroundColor Green
    Write-Host "  [41] Unpark 100% CPU Cores on Current Scheme & Unhide Power Settings" -ForegroundColor Cyan
    Write-Host "  [42] Low-Latency Audio & Anti-Popping (MMCSS Audio High Priority & MSI Mode)" -ForegroundColor Magenta
    Write-Host "  [43] USB xHCI Thread Priority & 8000Hz Buffers (ThreadPriority 31)" -ForegroundColor Yellow
    Write-Host "  [44] Inspect Hardware MSI & Interrupt Audit Report (GPU, USB, Audio, Net, NVMe)" -ForegroundColor Cyan
    Write-Host "  [45] TrafficMonitor Suite (Latest x64 Release, MiSans Fonts, Custom Config)" -ForegroundColor Magenta
    Write-Host "  [46] Compact Window Metrics (8px Scrollbars, 1px Border, 0 Padding, Compact Title Bar)" -ForegroundColor Cyan
    Write-Host "  [47] Disable All Windows Ads (Lock Screen, Start, Explorer, Settings, Search)" -ForegroundColor Green
    Write-Host "  [48] Remove Shortcut Arrow Overlays (Clean No-Arrow Desktop Icons)" -ForegroundColor Yellow
    Write-Host "  [49] Restore Window Metrics, Windows Ads & Shortcut Arrows to Defaults" -ForegroundColor DarkYellow
    Write-Host "  [50] Apply Unapplied Tweaks Only (Fast Catch-up to 100% Score)" -ForegroundColor Green
    Write-Host "  [51] Windows 11 Exclusives & Shell Usability Suite" -ForegroundColor Cyan
    Write-Host "  [52] Advanced Privacy & Third-Party App Telemetry Suite" -ForegroundColor Magenta
    Write-Host "  [53] Device Manager Tuning (Disable HPET, SMBus, System Speaker & Legacy Timers)" -ForegroundColor Yellow
    Write-Host "  [54] Turn Off BitLocker Permanently (Disable Encryption, BDESVC & Decrypt Drives)" -ForegroundColor Red
    Write-Host "  [55] Custom Gaming Cursors Manager (23 Packs - 1-Click Install & Rollback)" -ForegroundColor Magenta
    Write-Host "  [56] Re-Scan System Audit (Categorized Breakdown of Active & Unapplied Tweaks)" -ForegroundColor Cyan
    Write-Host "  [0]  Exit" -ForegroundColor Red
    Write-Host "================================================================================"
}

function Show-ConsoleMenu {
    do {
        Show-PumpkiNBanner
        $choice = Read-Host "Select an option [0-56]"
        switch ($choice) {
            "1" {
                Optimize-Network
                Optimize-GpuAuto
                Optimize-CpuAndSystem
                Optimize-LatencyAndInput
                Optimize-AudioDpcLatency
                Optimize-UsbLatencyAndBuffers
                Apply-GameHooks
                Debloat-BackgroundServices
                Invoke-PumpkiNEsportsPowerPlan
                Invoke-CpuCoreUnparking
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
                Optimize-DeviceManager
                Disable-BitLockerPermanently
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
                Write-Host "`n=== COMPETITIVE MATCH BOOSTER & STANDBY CLEANER ===" -ForegroundColor Cyan
                $stat = Get-StandbyListScheduledTaskStatus
                Write-Host "Current Schedule Status: $($stat.DisplayText)" -ForegroundColor Yellow
                Write-Host "  [1] Purge Standby Memory Now (One-Time Run)"
                Write-Host "  [2] Set Background Task Schedule: Every 5 Minutes (Esports Default)"
                Write-Host "  [3] Set Background Task Schedule: Every 10 Minutes (Balanced)"
                Write-Host "  [4] Set Background Task Schedule: Every 15 Minutes (Low Overhead)"
                Write-Host "  [5] Set Background Task Schedule: Custom Minutes"
                Write-Host "  [6] Disable / Remove Background Task Schedule"
                $mbChoice = Read-Host "Select option [1-6]"
                switch ($mbChoice) {
                    "1" { Invoke-EmptyStandbyListOneTime }
                    "2" { Set-StandbyListScheduledTask -IntervalMinutes 5 }
                    "3" { Set-StandbyListScheduledTask -IntervalMinutes 10 }
                    "4" { Set-StandbyListScheduledTask -IntervalMinutes 15 }
                    "5" {
                        $cust = Read-Host "Enter interval in minutes (e.g. 5, 10, 15, 30)"
                        if ($cust -as [int] -and [int]$cust -gt 0) {
                            Set-StandbyListScheduledTask -IntervalMinutes ([int]$cust)
                        } else {
                            Write-Host "[!] Invalid minute interval." -ForegroundColor Red
                        }
                    }
                    "6" { Remove-StandbyListScheduledTask }
                }
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
            "33" {
                Set-RecycleBinCustomIcon
                Read-Host "`nPress Enter to return to menu"
            }
            "34" {
                Restore-RecycleBinDefaultIcon
                Read-Host "`nPress Enter to return to menu"
            }
            "35" {
                Invoke-ShaderAndBrowserCacheCleaner
                Read-Host "`nPress Enter to return to menu"
            }
            "36" {
                $results = Test-GamingDnsBenchmark
                if ($results -and $results.Count -gt 0) {
                    $applyChoice = Read-Host "`nDo you want to apply the fastest provider ($($results[0].Name)) to your active adapters? (Y/N)"
                    if ($applyChoice -eq 'Y' -or $applyChoice -eq 'y') {
                        Set-GamingDnsProvider -PrimaryDns $results[0].Primary -SecondaryDns $results[0].Secondary -ProviderName $results[0].Name
                    }
                }
                Read-Host "`nPress Enter to return to menu"
            }
            "37" {
                Reset-DnsToAutomatic
                Read-Host "`nPress Enter to return to menu"
            }
            "38" {
                $stat = Get-SmartGameBoosterStatus
                Write-Host "`n=== SMART GAME BOOSTER DAEMON ===" -ForegroundColor Cyan
                Write-Host "Current Status: $($stat.DisplayText)" -ForegroundColor Yellow
                Write-Host "  [1] Start Daemon (Auto-detects 20+ competitive games in background)"
                Write-Host "  [2] Stop Daemon"
                $dChoice = Read-Host "Select option [1-2]"
                if ($dChoice -eq "1") {
                    Start-SmartGameBoosterDaemon
                } elseif ($dChoice -eq "2") {
                    Stop-SmartGameBoosterDaemon
                }
                Read-Host "`nPress Enter to return to menu"
            }
            "39" {
                Write-Host "`n=== LIVE HARDWARE TELEMETRY MONITOR ===" -ForegroundColor Cyan
                Write-Host "Monitoring telemetry (press Enter when done)...`n" -ForegroundColor Yellow
                for ($iter = 0; $iter -lt 15; $iter++) {
                    $t = Get-LiveHardwareTelemetry
                    $timeStr = (Get-Date).ToString("HH:mm:ss")
                    $pingStr = if ($t.PingMs -ge 0) { "$($t.PingMs) ms" } else { "TIMEOUT" }
                    Write-Host "[$timeStr] CPU: $($t.CpuLoad)% | RAM: $($t.UsedRamGb)/$($t.TotalRamGb) GB ($($t.RamPercent)%) | Ping: $pingStr | Booster: $($t.BoosterStatus)" -ForegroundColor Cyan
                    Start-Sleep -Seconds 2
                }
                Read-Host "`nPress Enter to return to menu"
            }
            "40" {
                Invoke-PumpkiNEsportsPowerPlan
                Read-Host "`nPress Enter to return to menu"
            }
            "41" {
                Invoke-CpuCoreUnparking
                Read-Host "`nPress Enter to return to menu"
            }
            "42" {
                Optimize-AudioDpcLatency
                Read-Host "`nPress Enter to return to menu"
            }
            "43" {
                Optimize-UsbLatencyAndBuffers
                Read-Host "`nPress Enter to return to menu"
            }
            "44" {
                Write-Host "`n=== HARDWARE MSI & INTERRUPT AUDIT REPORT ===" -ForegroundColor Cyan
                $report = Get-HardwareInterruptReport
                $report | Format-Table -AutoSize | Out-Host
                Write-Host "[OK] Audited $($report.Count) total hardware controllers." -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "45" {
                Write-Host "`n=== TRAFFICMONITOR SUITE & TELEMETRY SETUP ===" -ForegroundColor Magenta
                Write-Host "  [1] Download & Install Latest Release (x64 from GitHub)"
                Write-Host "  [2] Install MiSans Fonts (All 10 Weights)"
                Write-Host "  [3] Apply Custom config.ini"
                Write-Host "  [4] Full All-in-One Setup (Download + Fonts + Config + Launch)" -ForegroundColor Green
                Write-Host "  [5] Launch TrafficMonitor" -ForegroundColor Cyan
                Write-Host "  [0] Back to Main Menu"
                $tmChoice = Read-Host "`nSelect option [0-5]"
                switch ($tmChoice) {
                    "1" { [void](Install-TrafficMonitorLatest) }
                    "2" { [void](Install-MiSansFonts) }
                    "3" { [void](Apply-TrafficMonitorConfig) }
                    "4" { [void](Install-TrafficMonitorSuite) }
                    "5" { [void](Start-TrafficMonitorApp) }
                }
                Read-Host "`nPress Enter to return to menu"
            }
            "46" {
                Set-CompactWindowMetrics
                Read-Host "`nPress Enter to return to menu"
            }
            "47" {
                Disable-WindowsAds
                Read-Host "`nPress Enter to return to menu"
            }
            "48" {
                Disable-ShortcutArrow
                Read-Host "`nPress Enter to return to menu"
            }
            "49" {
                Write-Host "`n=== RESTORE VISUALS & SYSTEM DEFAULTS ===" -ForegroundColor Yellow
                Restore-CompactWindowMetrics
                Enable-WindowsAds
                Restore-ShortcutArrow
                Read-Host "`nPress Enter to return to menu"
            }
            "50" {
                Write-Host "`n=== APPLYING UNAPPLIED TWEAKS ONLY ===" -ForegroundColor Yellow
                $audit = Get-SystemAuditState
                Write-Host "Current Score: $($audit.ScoreGrade) ($($audit.ScoreApplied)/$($audit.ScoreTotal) Active)" -ForegroundColor Cyan
                if (-not $audit.State['VbsSecurity']) { Disable-VbsSecurity }
                if (-not $audit.State['TaskbarLeft']) { Set-TaskbarLeftAlign }
                if (-not $audit.State['RecommendedStart']) { Disable-RecommendedStartSection }
                if (-not $audit.State['AppTelemetry']) { Disable-ThirdPartyAppTelemetry }
                if (-not $audit.State['BluetoothAdvertising']) { Disable-BluetoothAdvertising }
                if (-not $audit.State['CloudContent']) { Disable-CloudOptimizedContent }
                if (-not $audit.State['CdpServices']) { Disable-CdpUserServices }
                if (-not $audit.State['OnlineSpeech']) { Disable-OnlineSpeechPrivacy }
                if (-not $audit.State['Arso']) { Disable-RestartAppsAfterReboot }
                if (-not $audit.State['TextInputCollection']) { Disable-HandwritingTypingCollection }
                if (-not $audit.State['ClipboardSync']) { Disable-ClipboardCloudSync }
                if (-not $audit.State['SettingsMessageSync']) { Disable-SettingsAndMessageSync }
                if (-not $audit.State['FindMyDevice']) { Disable-FindMyDevice }
                if (-not $audit.State['SafeSearch']) { Disable-SafeSearchFiltering }
                if (-not $audit.State['RemoteAssistanceRegistry']) { Disable-RemoteAssistanceAndRegistry }
                if (-not $audit.State['DriverUpdatesExcluded']) { Exclude-DriverUpdatesInWindowsUpdate }
                if (-not $audit.State['StoreAutoUpdates']) { Disable-WindowsStoreAutoUpdates }
                if (-not $audit.State['SmartScreen']) { Disable-SmartScreenProtection }
                if (-not $audit.State['CrashDumps']) { Disable-SystemCrashDumps }
                if (-not $audit.State['SystemTimeouts']) { Optimize-SystemTimeouts }
                if (-not $audit.State['Mpo']) { Disable-MultiplaneOverlay }
                if (-not $audit.State['MouseCurve']) { Set-MouseLinearCurve }
                if (-not $audit.State['CsrssPriority']) { Optimize-CsrssPriority }
                if (-not $audit.State['CpuSystem']) { Optimize-CpuAndSystem }
                if (-not $audit.State['AudioDpc']) { Optimize-AudioDpcLatency }
                if (-not $audit.State['UsbxHci']) { Optimize-UsbLatencyAndBuffers }
                if (-not $audit.State['Network']) { Optimize-Network }
                if (-not $audit.State['UltimatePower']) { Invoke-PumpkiNEsportsPowerPlan }
                if (-not $audit.State['CoreUnpark']) { Invoke-CpuCoreUnparking }
                if (-not $audit.State['StripVisual']) { Strip-VisualEffects }
                if (-not $audit.State['EndTask']) { Enable-EndTaskRightClick }
                if (-not $audit.State['StickyKeys']) { Disable-StickyKeysPrompt }
                if (-not $audit.State['DebloatServices']) { Debloat-BackgroundServices }
                if (-not $audit.State['DiskIo']) { Optimize-DiskIO }
                if (-not $audit.State['JunkTasks']) { Disable-ScheduledJunkTasks }
                if (-not $audit.State['Privacy']) { Harden-PrivacyTelemetry }
                if (-not $audit.State['BlockWpbt']) { Block-WpbtExecution }
                if (-not $audit.State['BlockPeripheral']) { Block-PeripheralBloat }
                if (-not $audit.State['RemoveAi']) { Remove-WindowsAI }
                if (-not $audit.State['SecurityUpdatesOnly']) { Set-SecurityUpdatesOnly }
                if (-not $audit.State['ClassicContext']) { Enable-ClassicContextMenu }
                if (-not $audit.State['DisableBing']) { Disable-StartMenuBing }
                if (-not $audit.State['DisableAutoDiscovery']) { Disable-ExplorerAutoDiscovery }
                if (-not $audit.State['ShowExtensions']) { Set-ShowFileExtensionsAndHidden }
                if (-not $audit.State['DisableAds']) { Disable-WindowsAds }
                if (-not $audit.State['EnableLongPaths']) { Enable-LongPaths }
                if (-not $audit.State['DisableLockScreen']) { Disable-LockScreen }
                if (-not $audit.State['BsodVerbose']) { Enable-BsodVerbose }
                if (-not $audit.State['DisableReservedStorage']) { Disable-ReservedStorage }
                if (-not $audit.State['DeviceManager']) { Optimize-DeviceManager }
                if (-not $audit.State['BitLocker']) { Disable-BitLockerPermanently }
                $newAudit = Get-SystemAuditState
                Write-Host "`n[OK] Unapplied tweaks executed! New Score: $($newAudit.ScoreGrade) ($($newAudit.ScoreApplied)/$($newAudit.ScoreTotal) Active)" -ForegroundColor Green
                Read-Host "`nPress Enter to return to menu"
            }
            "51" {
                Optimize-Windows11AndShell
                Read-Host "`nPress Enter to return to menu"
            }
            "52" {
                Optimize-PrivacyAndTelemetry
                Read-Host "`nPress Enter to return to menu"
            }
            "53" {
                Optimize-DeviceManager
                Read-Host "`nPress Enter to return to menu"
            }
            "54" {
                Disable-BitLockerPermanently
                Read-Host "`nPress Enter to return to menu"
            }
            "55" {
                Write-Host "`n=== Custom Gaming Cursors Manager ===" -ForegroundColor Magenta
                $schemes = Get-AvailableCursorSchemes
                if ($schemes.Count -eq 0) {
                    Write-Host "[-] No cursor schemes found in Cursors folder." -ForegroundColor Yellow
                } else {
                    Write-Host "[*] Found $($schemes.Count) available cursor packs:" -ForegroundColor Cyan
                    for ($i = 0; $i -lt $schemes.Count; $i++) {
                        Write-Host "  [$($i+1)] $($schemes[$i].Name)"
                    }
                    Write-Host "  [R] Restore Windows Default Cursors" -ForegroundColor Yellow
                    Write-Host "  [0] Back to Menu" -ForegroundColor Gray
                    $cChoice = Read-Host "Select cursor pack [1-$($schemes.Count), R, 0]"
                    if ($cChoice -eq "R" -or $cChoice -eq "r") {
                        Restore-DefaultCursors
                    } elseif ($cChoice -match '^\d+$' -and [int]$cChoice -ge 1 -and [int]$cChoice -le $schemes.Count) {
                        $selected = $schemes[[int]$cChoice - 1]
                        Install-CursorScheme -SchemeName $selected.Name
                    }
                }
                Read-Host "`nPress Enter to return to menu"
            }
            "56" {
                Show-SystemAuditReport
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
    try {
        Show-ConsoleMenu
    } finally {
        try { Stop-SmartGameBoosterDaemon } catch {}
        try {
            Get-Process -Name "EmptyStandbyList" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        } catch {}
        [System.Diagnostics.Process]::GetCurrentProcess().Kill()
    }
} else {
    try {
        Start-PumpkiNGui
    } catch {
        Write-Host "[-] GUI could not be initialized: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "[*] Launching interactive CLI menu instead..." -ForegroundColor Yellow
        Show-ConsoleMenu
    } finally {
        try { Stop-SmartGameBoosterDaemon } catch {}
        try {
            Get-Process -Name "EmptyStandbyList" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        } catch {}
        [System.Diagnostics.Process]::GetCurrentProcess().Kill()
    }
}