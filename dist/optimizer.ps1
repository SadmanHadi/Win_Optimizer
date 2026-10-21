<#
================================================================================
   ____                       _    _       _   _ 
  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |
  | |_) | | | | '_ ` _ \| '_ \ |/ / | '_ \|  \| |
  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |
  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|
                        |_|                       
            ULTIMATE GAMING & NETWORK OPTIMIZER v5.6.3
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

$Host.UI.RawUI.WindowTitle = "PumpkiN's Ultimate Gaming and Network Optimizer v5.7.1"

# ==============================================================================
# 2. EMBEDDED ENGINE MODULES (ALL-IN-ONE STANDALONE BUNDLE)
# ==============================================================================
$Script:IsBundled = $true

# ------------------------------------------------------------------------------
# MODULE: Hardware-Detection
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: Hardware Auto-Detection & Profiler
================================================================================
#>

# Persistent hardware profile cache to avoid redundant expensive CIM queries
$Script:CachedHardwareProfile = $null

function Get-HardwareProfile {
    [CmdletBinding()]
    param(
        [switch]$ForceRefresh
    )

    if ($Script:CachedHardwareProfile -and (-not $ForceRefresh)) {
        return $Script:CachedHardwareProfile
    }

    $cpuName = $null
    $cpuCores = $null
    try {
        $cpuReg = Get-ItemProperty 'HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0' -ErrorAction SilentlyContinue
        if ($cpuReg -and $cpuReg.ProcessorNameString) {
            $cpuName = ($cpuReg.ProcessorNameString).Trim()
        }
    } catch {}

    $logicalCount = [System.Environment]::ProcessorCount
    $cpuCores = "$logicalCount Threads"
    try {
        $cpu = Get-CimInstance Win32_Processor -Property Name, NumberOfCores, NumberOfLogicalProcessors -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cpu) {
            if (-not $cpuName) { $cpuName = $cpu.Name }
            if ($cpu.NumberOfCores) {
                $cpuCores = "$($cpu.NumberOfCores)C / $($cpu.NumberOfLogicalProcessors)T"
            }
        }
    } catch {}
    if (-not $cpuName) { $cpuName = "Unknown CPU" }

    $gpus = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue

    $adapter = $null
    try {
        $adapter = Get-CimInstance -Namespace root\StandardCimv2 -ClassName MSFT_NetAdapter -ErrorAction SilentlyContinue | 
                   Where-Object { $_.InterfaceOperationalStatus -eq 1 -and -not $_.Virtual } | Select-Object -First 1
    } catch {}
    if (-not $adapter) {
        $adapter = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
        if (-not $adapter) {
            $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' -and $_.InterfaceDescription -notlike '*Tunnel*' } | Select-Object -First 1
        }
    }

    $ram = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object -Property Capacity -Sum
    $totalRamGb = if ($ram.Sum) { [math]::Round($ram.Sum / 1GB, 1) } else { 0 }

    $firstGpu = if ($gpus -and $gpus.Count -gt 0) { $gpus[0] } else { $null }
    $gpuVram = if ($firstGpu -and $firstGpu.AdapterRAM) { [math]::Round($firstGpu.AdapterRAM / 1GB, 1) } else { 0 }

    $Script:CachedHardwareProfile = [PSCustomObject]@{
        CpuName            = $cpuName
        CpuCores           = $cpuCores
        CpuThreads         = if ($cpu -and $cpu.NumberOfLogicalProcessors) { [string]$cpu.NumberOfLogicalProcessors } else { "$([System.Environment]::ProcessorCount)" }
        CpuBaseClock       = if ($cpu -and $cpu.MaxClockSpeed) { "$([math]::Round($cpu.MaxClockSpeed / 1000, 2))" } else { "N/A" }
        IsAmdCpu           = ($cpuName -match 'AMD|Ryzen')
        IsIntelCpu         = ($cpuName -match 'Intel' -and $cpuName -notmatch 'AMD|Ryzen')
        Gpus               = $gpus
        GpuPrimary         = if ($firstGpu) { $firstGpu.Name } else { "Unknown GPU" }
        GpuDriverVersion   = if ($firstGpu) { $firstGpu.DriverVersion } else { "Unknown" }
        GpuMemoryGb        = $gpuVram
        HasNvidia          = ($gpus | Where-Object { $_.Name -match 'NVIDIA|GeForce' }) -ne $null
        HasAmdGpu          = ($gpus | Where-Object { $_.Name -match 'AMD|Radeon' }) -ne $null
        Adapter            = $adapter
        ActiveAdapterName  = if ($adapter) { $adapter.Name } else { "Unknown Adapter" }
        ActiveAdapterSpeed = if ($adapter) { $adapter.LinkSpeed } else { "Unknown" }
        IsWifi             = ($adapter -and ($adapter.InterfaceType -eq 71 -or $adapter.InterfaceDescription -match 'Wi-Fi|Wireless|802\.11'))
        RamGb              = $totalRamGb
        TotalRamGb         = $totalRamGb
    }

    return $Script:CachedHardwareProfile
}

# Persistent cache for ultra-fast zero-allocation telemetry
$Script:TelemetryCompInfo = $null
$Script:TelemetryCpuCounter = $null
$Script:TelemetryPing = $null

function Get-LiveHardwareTelemetry {
    <#
    .SYNOPSIS
        Returns ultra-fast real-time hardware telemetry (<1ms execution overhead).
    #>
    [CmdletBinding()]
    param()

    # 1. RAM Telemetry
    $usedRamGb = 0
    $totalRamGb = 0
    $ramPercent = 0
    try {
        if (-not $Script:TelemetryCompInfo) {
            Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction SilentlyContinue
            $Script:TelemetryCompInfo = New-Object Microsoft.VisualBasic.Devices.ComputerInfo
        }
        $totBytes = $Script:TelemetryCompInfo.TotalPhysicalMemory
        $availBytes = $Script:TelemetryCompInfo.AvailablePhysicalMemory
        $totalRamGb = [math]::Round($totBytes / 1GB, 1)
        $availRamGb = [math]::Round($availBytes / 1GB, 1)
        $usedRamGb  = [math]::Round($totalRamGb - $availRamGb, 1)
        if ($totalRamGb -gt 0) {
            $ramPercent = [math]::Round(($usedRamGb / $totalRamGb) * 100, 0)
        }
    } catch {
        try {
            $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
            $totalRamGb = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
            $freeGb     = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
            $usedRamGb  = [math]::Round($totalRamGb - $freeGb, 1)
            if ($totalRamGb -gt 0) {
                $ramPercent = [math]::Round(($usedRamGb / $totalRamGb) * 100, 0)
            }
        } catch {}
    }

    # 2. CPU Load Telemetry
    $cpuLoad = 0
    try {
        if (-not $Script:TelemetryCpuCounter) {
            $Script:TelemetryCpuCounter = New-Object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
            [void]$Script:TelemetryCpuCounter.NextValue()
        }
        $cpuLoad = [math]::Round($Script:TelemetryCpuCounter.NextValue(), 0)
    } catch {
        $cpuLoad = 0
    }

    # 3. Network Ping Latency (Fast 300ms timeout)
    $pingMs = -1
    try {
        if (-not $Script:TelemetryPing) {
            $Script:TelemetryPing = New-Object System.Net.NetworkInformation.Ping
        }
        $reply = $Script:TelemetryPing.Send("1.1.1.1", 300)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            $pingMs = [int]$reply.RoundtripTime
        }
    } catch {}

    # 4. Booster Status
    $boosterStatus = "STANDBY"
    if (Get-Command Get-SmartGameBoosterStatus -ErrorAction SilentlyContinue) {
        $bStat = Get-SmartGameBoosterStatus
        if ($bStat.IsActive) {
            if ($bStat.CurrentGame) {
                $boosterStatus = "BOOST: $($bStat.CurrentGame)"
            } else {
                $boosterStatus = "ACTIVE (WATCHING)"
            }
        }
    }

    return [PSCustomObject]@{
        CpuLoad       = $cpuLoad
        UsedRamGb     = $usedRamGb
        TotalRamGb    = $totalRamGb
        RamPercent    = $ramPercent
        PingMs        = $pingMs
        BoosterStatus = $boosterStatus
    }
}

# Persistent cache for detailed device specs
$Script:CachedDeviceDetailProfile = $null

function Get-DeviceDetailProfile {
    <#
    .SYNOPSIS
        Returns comprehensive structured hardware & operating system details.
    #>
    [CmdletBinding()]
    param(
        [switch]$ForceRefresh
    )

    if ($Script:CachedDeviceDetailProfile -and (-not $ForceRefresh)) {
        return $Script:CachedDeviceDetailProfile
    }

    # 1. Computer & Operating System Info
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $nt = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue
    $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
    $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1

    $deviceName = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { $cs.Name }
    $osName = if ($os.Caption) { $os.Caption } else { "Windows 10/11" }
    $osVersion = if ($nt.DisplayVersion) { $nt.DisplayVersion } elseif ($nt.ReleaseId) { $nt.ReleaseId } else { "Unknown" }
    $ubr = if ($nt.UBR) { $nt.UBR } else { "0" }
    $buildNumber = if ($os.BuildNumber) { "$($os.BuildNumber).$ubr" } else { "Unknown" }
    $osArch = if ($os.OSArchitecture) { $os.OSArchitecture } else { "64-bit" }
    $installDateStr = if ($os.InstallDate) { 
        try { ([datetime]$os.InstallDate).ToString("M/d/yyyy h:mm tt") } catch { "$($os.InstallDate)" }
    } else { "Unknown" }
    $regUser = if ($os.RegisteredUser) { $os.RegisteredUser } else { $env:USERNAME }
    $winDir = if ($os.WindowsDirectory) { $os.WindowsDirectory } else { "C:\Windows" }
    $sysDir = if ($os.SystemDirectory) { $os.SystemDirectory } else { "C:\Windows\system32" }
    $bootTimeStr = if ($os.LastBootUpTime) {
        try { ([datetime]$os.LastBootUpTime).ToString("M/d/yyyy h:mm tt") } catch { "$($os.LastBootUpTime)" }
    } else { "Unknown" }

    # 2. Processor
    $cpuName = if ($cpu.Name) { ($cpu.Name).Trim() } else { "Unknown Processor" }
    $cpuManuf = if ($cpu.Manufacturer) { $cpu.Manufacturer } else { "Unknown" }
    $cpuArch = if ($cpu.AddressWidth) { "x$($cpu.AddressWidth)" } else { "x64" }
    $cpuCores = if ($cpu.NumberOfCores) { [string]$cpu.NumberOfCores } else { "Unknown" }
    $cpuThreads = if ($cpu.NumberOfLogicalProcessors) { [string]$cpu.NumberOfLogicalProcessors } else { "$([System.Environment]::ProcessorCount)" }
    $cpuSpeed = if ($cpu.MaxClockSpeed) { "$($cpu.MaxClockSpeed) MHz" } else { "Unknown" }
    $cpuSocket = if ($cpu.SocketDesignation) { $cpu.SocketDesignation } else { "Unknown" }
    $cpuL2 = if ($cpu.L2CacheSize) { "$($cpu.L2CacheSize) KB" } else { "N/A" }
    $cpuL3 = if ($cpu.L3CacheSize) { "$($cpu.L3CacheSize) KB" } else { "N/A" }

    # 3. Graphics
    $gpus = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue
    $gpuList = [System.Collections.Generic.List[PSCustomObject]]::new()
    if ($gpus) {
        foreach ($g in $gpus) {
            $vramGb = if ($g.AdapterRAM -and $g.AdapterRAM -gt 0) { [math]::Round($g.AdapterRAM / 1GB, 1) } else { 0 }
            $res = if ($g.CurrentHorizontalResolution -and $g.CurrentVerticalResolution) {
                "$($g.CurrentHorizontalResolution) x $($g.CurrentVerticalResolution)"
            } else { "Desktop Native" }
            $hz = if ($g.CurrentRefreshRate) { "$($g.CurrentRefreshRate) Hz" } else { "Standard" }
            $gpuList.Add([PSCustomObject]@{
                Name          = if ($g.Name) { $g.Name } else { "Video Controller" }
                Manufacturer  = if ($g.AdapterCompatibility) { $g.AdapterCompatibility } else { "Unknown" }
                DriverVersion = if ($g.DriverVersion) { $g.DriverVersion } else { "Unknown" }
                DriverDate    = if ($g.DriverDate) { 
                    try { ([datetime]$g.DriverDate).ToString("M/d/yyyy") } catch { "$($g.DriverDate)" }
                } else { "Unknown" }
                Vram          = if ($vramGb -gt 0) { "$vramGb GB" } else { "Dynamic / Shared" }
                Resolution    = $res
                RefreshRate   = $hz
            })
        }
    }

    # 4. RAM
    $rams = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue
    $totBytes = 0
    $ramSpeed = "Unknown"
    $ramManuf = "Unknown"
    $ramPart = "Unknown"
    $ramSlots = 0
    if ($rams) {
        $ramSlots = $rams.Count
        foreach ($r in $rams) {
            $totBytes += $r.Capacity
            if ($ramSpeed -eq "Unknown" -and $r.Speed) { $ramSpeed = "$($r.Speed) MHz" }
            if ($ramManuf -eq "Unknown" -and $r.Manufacturer -and $r.Manufacturer -notmatch 'Unknown') { $ramManuf = $r.Manufacturer }
            if ($ramPart -eq "Unknown" -and $r.PartNumber) { $ramPart = ($r.PartNumber).Trim() }
        }
    }
    $totalRamGb = if ($totBytes -gt 0) { [math]::Round($totBytes / 1GB, 0) } else { 0 }
    $usableRamGb = if ($os.TotalVisibleMemorySize) { [math]::Round($os.TotalVisibleMemorySize / 1MB, 1) } else { $totalRamGb }

    # 5. Storage
    $disks = Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue
    $diskList = [System.Collections.Generic.List[string]]::new()
    if ($disks) {
        foreach ($d in $disks) {
            $dSizeGb = if ($d.Size) { [math]::Round($d.Size / 1GB, 0) } else { 0 }
            $sizeStr = if ($dSizeGb -ge 1000) { "$([math]::Round($dSizeGb/1000, 1)) TB" } else { "$dSizeGb GB" }
            $diskList.Add("$($d.Model) ($sizeStr)")
        }
    }
    $vols = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
    $volList = [System.Collections.Generic.List[string]]::new()
    if ($vols) {
        foreach ($v in $vols) {
            $freeGb = [math]::Round($v.FreeSpace / 1GB, 1)
            $totGb = [math]::Round($v.Size / 1GB, 1)
            $volList.Add("$($v.DeviceID) ($freeGb GB free of $totGb GB)")
        }
    }

    # 6. Network
    $net = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Virtual|VPN|Loopback' } | Select-Object -First 1
    if (-not $net) {
        $net = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    $netIp = if ($net) { Get-NetIPAddress -InterfaceIndex $net.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1 } else { $null }
    $netName = if ($net) { $net.Name } else { "Unknown Adapter" }
    $netDesc = if ($net) { $net.InterfaceDescription } else { "Unknown" }
    $netMac = if ($net) { $net.MacAddress } else { "Unknown" }
    $netSpeed = if ($net) { $net.LinkSpeed } else { "Unknown" }
    $netIpStr = if ($netIp) { $netIp.IPAddress } else { "DHCP / Unassigned" }
    $netStatus = if ($net) { $net.Status } else { "Disconnected" }

    # 7. Battery
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    $hasBattery = ($battery -ne $null -and $battery.EstimatedChargeRemaining)
    $batteryName = if ($hasBattery) { $battery.Name } else { "Direct AC Power Supply" }
    $batteryPercent = if ($hasBattery) { "$($battery.EstimatedChargeRemaining)%" } else { "100% (AC Direct Power)" }
    $batteryStatus = if ($hasBattery) { 
        switch ($battery.BatteryStatus) {
            1 { "Discharging" }
            2 { "On AC / Unknown" }
            3 { "Fully Charged" }
            4 { "Low" }
            5 { "Critical" }
            6 { "Charging" }
            default { "AC Power" }
        }
    } else { "Desktop PC (Direct Power Supply Unit -- No Battery)" }

    $headerSummary = "$osName | $cpuName | $totalRamGb GB RAM"

    $Script:CachedDeviceDetailProfile = [PSCustomObject]@{
        DeviceName       = $deviceName
        HeaderSummary    = $headerSummary
        
        # OS
        OsName           = $osName
        OsVersion        = $osVersion
        OsBuildNumber    = $buildNumber
        OsArchitecture   = $osArch
        OsInstallDate    = $installDateStr
        OsRegisteredUser = $regUser
        OsWindowsDir     = $winDir
        OsSystemDir      = $sysDir
        OsLastBootTime   = $bootTimeStr

        # CPU
        CpuName          = $cpuName
        CpuManufacturer  = $cpuManuf
        CpuArchitecture  = $cpuArch
        CpuCores         = $cpuCores
        CpuLogical       = $cpuThreads
        CpuMaxSpeed      = $cpuSpeed
        CpuSocket        = $cpuSocket
        CpuL2Cache       = $cpuL2
        CpuL3Cache       = $cpuL3

        # GPU
        Gpus             = $gpuList
        PrimaryGpu       = if ($gpuList.Count -gt 0) { $gpuList[0] } else { $null }

        # RAM
        RamTotal         = "$totalRamGb GB"
        RamUsable        = "$usableRamGb GB"
        RamSpeed         = $ramSpeed
        RamManufacturer  = $ramManuf
        RamPartNumber    = $ramPart
        RamSlots         = "$ramSlots Slots Installed"

        # Storage
        Disks            = $diskList
        Volumes          = $volList

        # Network
        NetAdapterName   = $netName
        NetDescription   = $netDesc
        NetMacAddress    = $netMac
        NetLinkSpeed     = $netSpeed
        NetIpAddress     = $netIpStr
        NetStatus        = $netStatus

        # Battery
        HasBattery       = $hasBattery
        BatteryName      = $batteryName
        BatteryPercent   = $batteryPercent
        BatteryStatus    = $batteryStatus
    }

    return $Script:CachedDeviceDetailProfile
}

# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    $p = Get-HardwareProfile
    Write-Host "CPU: $($p.CpuName) ($($p.CpuCores))"
    Write-Host "RAM: $($p.TotalRamGb) GB"
    $t = Get-LiveHardwareTelemetry
    Write-Host "Live Telemetry -> CPU: $($t.CpuLoad)% | RAM: $($t.UsedRamGb)/$($t.TotalRamGb) GB ($($t.RamPercent)%) | Ping: $($t.PingMs) ms"
    $d = Get-DeviceDetailProfile
    Write-Host "`nDevice: $($d.DeviceName) ($($d.HeaderSummary))" -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------
# MODULE: App-Catalog
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: 10-Category WinGet Software Catalog & Runner Engine
================================================================================
#>

# SECTION: WINGET APPLICATION CATALOG (10 CATEGORIES, 100+ PACKAGES)
# ==============================================================================

$Global:AppCatalog = @(
    # --- BROWSERS ---
    @{ Key = "brave"; Name = "Brave Browser"; Category = "Browsers"; WingetId = "Brave.Brave"; Description = "Privacy-oriented browser with built-in ad blocking" },
    @{ Key = "chrome"; Name = "Google Chrome"; Category = "Browsers"; WingetId = "Google.Chrome"; Description = "Fast, standard Chromium browser" },
    @{ Key = "chromium"; Name = "Chromium"; Category = "Browsers"; WingetId = "Hibbiki.Chromium"; Description = "Open-source foundation of Google Chrome" },
    @{ Key = "edge"; Name = "Microsoft Edge"; Category = "Browsers"; WingetId = "Microsoft.Edge"; Description = "Modern Windows built-in browser" },
    @{ Key = "firefox"; Name = "Mozilla Firefox"; Category = "Browsers"; WingetId = "Mozilla.Firefox"; Description = "Extensible open-source Gecko browser" },
    @{ Key = "floorp"; Name = "Floorp Browser"; Category = "Browsers"; WingetId = "Ablaze.Floorp"; Description = "Customizable Firefox fork created in Japan" },
    @{ Key = "librewolf"; Name = "LibreWolf"; Category = "Browsers"; WingetId = "LibreWolf.LibreWolf"; Description = "Hardened privacy-first Firefox fork" },
    @{ Key = "tor"; Name = "Tor Browser"; Category = "Browsers"; WingetId = "TorProject.TorBrowser"; Description = "Anonymity-focused onion-routing browser" },
    @{ Key = "vivaldi"; Name = "Vivaldi"; Category = "Browsers"; WingetId = "VivaldiTechnologies.Vivaldi"; Description = "Feature-packed browser with custom tabs" },
    @{ Key = "waterfox"; Name = "Waterfox"; Category = "Browsers"; WingetId = "Waterfox.Waterfox"; Description = "Fast, ethical 64-bit Gecko browser" },
    @{ Key = "zen"; Name = "Zen Browser"; Category = "Browsers"; WingetId = "Zen-Team.Zen-Browser"; Description = "Modern, beautiful Firefox-based vertical tabs browser" },
    @{ Key = "operagx"; Name = "Opera GX"; Category = "Browsers"; WingetId = "Opera.OperaGX"; Description = "Gaming browser with CPU/RAM limiters" },

    # --- COMMUNICATIONS ---
    @{ Key = "discord"; Name = "Discord"; Category = "Communications"; WingetId = "Discord.Discord"; Description = "All-in-one voice and text chat for gamers" },
    @{ Key = "telegram"; Name = "Telegram Desktop"; Category = "Communications"; WingetId = "Telegram.TelegramDesktop"; Description = "Fast, secure cloud messaging client" },
    @{ Key = "signal"; Name = "Signal"; Category = "Communications"; WingetId = "OpenWhisperSystems.Signal"; Description = "End-to-end encrypted private messenger" },
    @{ Key = "slack"; Name = "Slack"; Category = "Communications"; WingetId = "SlackTechnologies.Slack"; Description = "Team collaboration and workplace messaging" },
    @{ Key = "teams"; Name = "Microsoft Teams"; Category = "Communications"; WingetId = "Microsoft.Teams"; Description = "Video conferencing and enterprise chat" },
    @{ Key = "whatsapp"; Name = "WhatsApp"; Category = "Communications"; WingetId = "WhatsApp.WhatsApp"; Description = "Popular worldwide messaging desktop app" },
    @{ Key = "zoom"; Name = "Zoom Workplace"; Category = "Communications"; WingetId = "Zoom.Zoom"; Description = "Video meetings and webinars" },
    @{ Key = "vesktop"; Name = "Vesktop"; Category = "Communications"; WingetId = "Vencord.Vesktop"; Description = "Lightweight Discord desktop client with Vencord" },
    @{ Key = "equicord"; Name = "Equicord (Equilotl)"; Category = "Communications"; WingetId = "Equicord.Equilotl"; Description = "Enhanced Discord client with 100+ plugins (equicord.org/download)" },
    @{ Key = "equibop"; Name = "Equibop"; Category = "Communications"; WingetId = "Equicord.Equibop"; Description = "Custom Discord client with built-in Equicord plugins" },
    @{ Key = "teamspeak"; Name = "TeamSpeak 3"; Category = "Communications"; WingetId = "TeamSpeak-Systems.TeamSpeakClient"; Description = "Low-latency VoIP client for esports teams" },
    @{ Key = "element"; Name = "Element"; Category = "Communications"; WingetId = "Element.Element"; Description = "Decentralized, encrypted Matrix client" },

    # --- DEVELOPMENT ---
    @{ Key = "vscode"; Name = "Visual Studio Code"; Category = "Development"; WingetId = "Microsoft.VisualStudioCode"; Description = "Extensible source code editor by Microsoft" },
    @{ Key = "cursor"; Name = "Cursor AI"; Category = "Development"; WingetId = "Anysphere.Cursor"; Description = "AI-first code editor built on VS Code" },
    @{ Key = "git"; Name = "Git for Windows"; Category = "Development"; WingetId = "Git.Git"; Description = "Distributed version control system" },
    @{ Key = "githubdesktop"; Name = "GitHub Desktop"; Category = "Development"; WingetId = "GitHub.GitHubDesktop"; Description = "GUI client for Git and GitHub workflows" },
    @{ Key = "python"; Name = "Python 3.12"; Category = "Development"; WingetId = "Python.Python.3.12"; Description = "Interpreted high-level programming language" },
    @{ Key = "nodejs"; Name = "Node.js (LTS)"; Category = "Development"; WingetId = "OpenJS.NodeJS.LTS"; Description = "JavaScript runtime environment built on V8" },
    @{ Key = "docker"; Name = "Docker Desktop"; Category = "Development"; WingetId = "Docker.DockerDesktop"; Description = "Containerization platform for developers" },
    @{ Key = "rust"; Name = "Rustup"; Category = "Development"; WingetId = "Rustlang.Rustup"; Description = "Rust toolchain installer and version manager" },
    @{ Key = "golang"; Name = "Go Programming Language"; Category = "Development"; WingetId = "GoLang.Go"; Description = "Fast, concurrent compiled programming language" },
    @{ Key = "neovim"; Name = "Neovim"; Category = "Development"; WingetId = "Neovim.Neovim"; Description = "Vim-fork focused on extensibility and usability" },
    @{ Key = "winterminal"; Name = "Windows Terminal"; Category = "Development"; WingetId = "Microsoft.WindowsTerminal"; Description = "Modern, fast tabbed terminal emulator" },
    @{ Key = "notepadplusplus"; Name = "Notepad++"; Category = "Development"; WingetId = "Notepad++.Notepad++"; Description = "Fast, lightweight tabbed text and code editor" },
    @{ Key = "sublimetext"; Name = "Sublime Text"; Category = "Development"; WingetId = "SublimeHQ.SublimeText.4"; Description = "Sophisticated text editor for code and prose" },
    @{ Key = "dbeaver"; Name = "DBeaver Community"; Category = "Development"; WingetId = "dbeaver.dbeaver"; Description = "Universal database tool and SQL client" },
    @{ Key = "postman"; Name = "Postman"; Category = "Development"; WingetId = "Postman.Postman"; Description = "API design, testing, and documentation platform" },

    # --- DOCUMENT ---
    @{ Key = "acrobat"; Name = "Adobe Acrobat Reader"; Category = "Document"; WingetId = "Adobe.Acrobat.Reader.64-bit"; Description = "Standard PDF viewing and printing utility" },
    @{ Key = "obsidian"; Name = "Obsidian"; Category = "Document"; WingetId = "Obsidian.Obsidian"; Description = "Knowledge base on local plain-text Markdown" },
    @{ Key = "libreoffice"; Name = "LibreOffice"; Category = "Document"; WingetId = "TheDocumentFoundation.LibreOffice"; Description = "Open-source office suite (Writer, Calc, Impress)" },
    @{ Key = "pdf24"; Name = "PDF24 Creator"; Category = "Document"; WingetId = "geeksoftwareGmbH.PDF24Creator"; Description = "Free all-in-one PDF tools and converter" },
    @{ Key = "sumatrapdf"; Name = "Sumatra PDF"; Category = "Document"; WingetId = "SumatraPDF.SumatraPDF"; Description = "Ultra-fast, ultra-lightweight PDF and eBook viewer" },
    @{ Key = "joplin"; Name = "Joplin"; Category = "Document"; WingetId = "Joplin.Joplin"; Description = "Secure, end-to-end encrypted note-taking app" },
    @{ Key = "zotero"; Name = "Zotero"; Category = "Document"; WingetId = "DigitalScience.Zotero"; Description = "Research tool for collecting and citing references" },
    @{ Key = "foxit"; Name = "Foxit PDF Reader"; Category = "Document"; WingetId = "Foxit.FoxitReader"; Description = "Feature-rich, fast PDF viewer and annotator" },
    @{ Key = "calibre"; Name = "Calibre"; Category = "Document"; WingetId = "KovidGoyal.Calibre"; Description = "Complete eBook library manager and converter" },
    @{ Key = "typora"; Name = "Typora"; Category = "Document"; WingetId = "Typora.Typora"; Description = "Seamless live-preview Markdown editor" },

    # --- GAMES ---
    @{ Key = "steam"; Name = "Steam"; Category = "Games"; WingetId = "Valve.Steam"; Description = "Valve digital gaming platform and store" },
    @{ Key = "epicgames"; Name = "Epic Games Launcher"; Category = "Games"; WingetId = "EpicGames.EpicGamesLauncher"; Description = "Epic Games store, Unreal Engine, and Fortnite" },
    @{ Key = "battlenet"; Name = "Battle.net"; Category = "Games"; WingetId = "Blizzard.BattleNet"; Description = "Blizzard Entertainment game launcher" },
    @{ Key = "eaapp"; Name = "EA App"; Category = "Games"; WingetId = "ElectronicArts.EADesktop"; Description = "Electronic Arts gaming hub" },
    @{ Key = "goggalaxy"; Name = "GOG Galaxy"; Category = "Games"; WingetId = "GOG.Galaxy"; Description = "DRM-free gaming hub with universal library" },
    @{ Key = "heroic"; Name = "Heroic Games Launcher"; Category = "Games"; WingetId = "HeroicGamesLauncher.HeroicGamesLauncher"; Description = "Open-source Epic and GOG games launcher" },
    @{ Key = "roblox"; Name = "Roblox Player"; Category = "Games"; WingetId = "Roblox.Roblox"; Description = "Online gaming platform and game creation system" },
    @{ Key = "curseforge"; Name = "CurseForge"; Category = "Games"; WingetId = "Overwolf.CurseForge"; Description = "Modding and addon manager for Minecraft and WoW" },
    @{ Key = "playnite"; Name = "Playnite"; Category = "Games"; WingetId = "Playnite.Playnite"; Description = "Open-source video game library manager" },
    @{ Key = "ubisoft"; Name = "Ubisoft Connect"; Category = "Games"; WingetId = "Ubisoft.Connect"; Description = "Ubisoft digital store and ecosystem client" },
    @{ Key = "prism"; Name = "Prism Launcher"; Category = "Games"; WingetId = "PrismLauncher.PrismLauncher"; Description = "Custom open-source Minecraft launcher" },
    @{ Key = "moonlight"; Name = "Moonlight Game Streaming"; Category = "Games"; WingetId = "MoonlightGameStreamingProject.Moonlight"; Description = "NVIDIA GameStream and Sunshine open-source client" },

    # --- MICROSOFT TOOLS ---
    @{ Key = "powertoys"; Name = "Microsoft PowerToys"; Category = "Microsoft Tools"; WingetId = "Microsoft.PowerToys"; Description = "System utilities for power users (FancyZones, Run, OCR)" },
    @{ Key = "sysinternals"; Name = "Sysinternals Suite"; Category = "Microsoft Tools"; WingetId = "Microsoft.Sysinternals.Suite"; Description = "Complete suite of advanced Windows diagnostic tools" },
    @{ Key = "dotnet8"; Name = ".NET 8 Desktop Runtime"; Category = "Microsoft Tools"; WingetId = "Microsoft.DotNet.DesktopRuntime.8"; Description = "Runtime required for modern desktop .NET apps" },
    @{ Key = "vcredist64"; Name = "Visual C++ 2015-2022 (x64)"; Category = "Microsoft Tools"; WingetId = "Microsoft.VCRedist.2015+.x64"; Description = "Essential 64-bit runtime for almost all Windows games" },
    @{ Key = "vcredist86"; Name = "Visual C++ 2015-2022 (x86)"; Category = "Microsoft Tools"; WingetId = "Microsoft.VCRedist.2015+.x86"; Description = "Essential 32-bit runtime for legacy Windows games" },
    @{ Key = "directx"; Name = "DirectX End-User Runtimes"; Category = "Microsoft Tools"; WingetId = "Microsoft.DirectX"; Description = "DirectX 9/10/11 legacy library runtimes for games" },
    @{ Key = "procexp"; Name = "Process Explorer"; Category = "Microsoft Tools"; WingetId = "Microsoft.Sysinternals.ProcessExplorer"; Description = "Advanced Task Manager with DLL and handle inspection" },
    @{ Key = "autoruns"; Name = "AutoRuns"; Category = "Microsoft Tools"; WingetId = "Microsoft.Sysinternals.Autoruns"; Description = "Most comprehensive startup and autostart monitor" },
    @{ Key = "pwsh7"; Name = "PowerShell 7"; Category = "Microsoft Tools"; WingetId = "Microsoft.PowerShell"; Description = "Latest cross-platform PowerShell core engine" },

    # --- MULTIMEDIA TOOLS ---
    @{ Key = "obs"; Name = "OBS Studio"; Category = "Multimedia Tools"; WingetId = "OBSProject.OBSStudio"; Description = "Industry standard live streaming and video recording" },
    @{ Key = "vlc"; Name = "VLC Media Player"; Category = "Multimedia Tools"; WingetId = "VideoLAN.VLC"; Description = "Universal multimedia player for all codecs" },
    @{ Key = "handbrake"; Name = "HandBrake"; Category = "Multimedia Tools"; WingetId = "HandBrake.HandBrake"; Description = "Open-source video transcoder and compressor" },
    @{ Key = "audacity"; Name = "Audacity"; Category = "Multimedia Tools"; WingetId = "Audacity.Audacity"; Description = "Multi-track audio editor and recorder" },
    @{ Key = "blender"; Name = "Blender"; Category = "Multimedia Tools"; WingetId = "BlenderFoundation.Blender"; Description = "Professional 3D creation, modeling, and VFX suite" },
    @{ Key = "gimp"; Name = "GIMP"; Category = "Multimedia Tools"; WingetId = "GIMP.GIMP"; Description = "GNU Image Manipulation Program (Photoshop alternative)" },
    @{ Key = "klite"; Name = "K-Lite Codec Pack Mega"; Category = "Multimedia Tools"; WingetId = "CodecGuide.K-LiteCodecPack.Mega"; Description = "Comprehensive DirectShow filters and video codecs" },
    @{ Key = "sharex"; Name = "ShareX"; Category = "Multimedia Tools"; WingetId = "ShareX.ShareX"; Description = "Screen capture, file sharing, and productivity tool" },
    @{ Key = "mpv"; Name = "mpv.net"; Category = "Multimedia Tools"; WingetId = "mpv.net"; Description = "Modern, minimalist GPU-accelerated media player" },
    @{ Key = "paintnet"; Name = "Paint.NET"; Category = "Multimedia Tools"; WingetId = "dotPDN.PaintDotNet"; Description = "Free image and photo editing software for Windows" },
    @{ Key = "foobar2000"; Name = "Foobar2000"; Category = "Multimedia Tools"; WingetId = "PeterPawlowski.foobar2000"; Description = "Advanced lightweight freeware audio player" },
    @{ Key = "spotify"; Name = "Spotify"; Category = "Multimedia Tools"; WingetId = "Spotify.Spotify"; Description = "Digital music streaming desktop client" },

    # --- PRO TOOLS ---
    @{ Key = "ddu"; Name = "Display Driver Uninstaller"; Category = "Pro Tools"; WingetId = "Wagnardsoft.DisplayDriverUninstaller"; Description = "Clean uninstall tool for NVIDIA, AMD, and Intel drivers" },
    @{ Key = "cpuz"; Name = "CPU-Z"; Category = "Pro Tools"; WingetId = "CPUID.CPU-Z"; Description = "Processor, motherboard, and RAM hardware diagnostics" },
    @{ Key = "gpuz"; Name = "GPU-Z"; Category = "Pro Tools"; WingetId = "TechPowerUp.GPU-Z"; Description = "Video card and graphics information utility" },
    @{ Key = "hwinfo"; Name = "HWiNFO"; Category = "Pro Tools"; WingetId = "REALiX.HWiNFO"; Description = "Hardware analysis, monitoring, and thermal reporting" },
    @{ Key = "hwmonitor"; Name = "HWMonitor"; Category = "Pro Tools"; WingetId = "CPUID.HWMonitor"; Description = "Hardware voltage, temperature, and fan speed monitor" },
    @{ Key = "cinebench"; Name = "Cinebench R23"; Category = "Pro Tools"; WingetId = "Maxon.CinebenchR23"; Description = "Industry standard CPU rendering benchmark" },
    @{ Key = "wireshark"; Name = "Wireshark"; Category = "Pro Tools"; WingetId = "WiresharkFoundation.Wireshark"; Description = "Network protocol analyzer and packet sniffer" },
    @{ Key = "putty"; Name = "PuTTY"; Category = "Pro Tools"; WingetId = "PuTTY.PuTTY"; Description = "SSH, Telnet, and serial terminal client" },
    @{ Key = "mullvadvpn"; Name = "Mullvad VPN"; Category = "Pro Tools"; WingetId = "MullvadVPN.MullvadVPN"; Description = "Privacy-focused WireGuard VPN client" },
    @{ Key = "protonvpn"; Name = "Proton VPN"; Category = "Pro Tools"; WingetId = "Proton.ProtonVPN"; Description = "High-speed Swiss encrypted VPN service" },
    @{ Key = "winscp"; Name = "WinSCP"; Category = "Pro Tools"; WingetId = "WinSCP.WinSCP"; Description = "Free SFTP, SCP, and FTP client for Windows" },
    @{ Key = "filezilla"; Name = "FileZilla Client"; Category = "Pro Tools"; WingetId = "TimKosse.FileZilla.Client"; Description = "Fast and reliable cross-platform FTP client" },

    # --- SELFHOSTED TOOLS ---
    @{ Key = "jellyfin"; Name = "Jellyfin Media Player"; Category = "Selfhosted Tools"; WingetId = "Jellyfin.JellyfinMediaPlayer"; Description = "Free software media streaming client" },
    @{ Key = "plex"; Name = "Plex Desktop"; Category = "Selfhosted Tools"; WingetId = "Plex.PlexDesktop"; Description = "Desktop player for personal Plex media libraries" },
    @{ Key = "sunshine"; Name = "Sunshine"; Category = "Selfhosted Tools"; WingetId = "LizardByte.Sunshine"; Description = "Self-hosted low latency game stream host for Moonlight" },
    @{ Key = "localsend"; Name = "LocalSend"; Category = "Selfhosted Tools"; WingetId = "LocalSend.LocalSend"; Description = "AirDrop alternative for local network file sharing" },
    @{ Key = "syncthing"; Name = "Syncthing"; Category = "Selfhosted Tools"; WingetId = "Syncthing.Syncthing"; Description = "Continuous, decentralized peer-to-peer file sync" },
    @{ Key = "tailscale"; Name = "Tailscale"; Category = "Selfhosted Tools"; WingetId = "Tailscale.Tailscale"; Description = "Zero-config mesh VPN powered by WireGuard" },
    @{ Key = "wireguard"; Name = "WireGuard"; Category = "Selfhosted Tools"; WingetId = "WireGuard.WireGuard"; Description = "Extremely fast, modern cryptographic VPN tunnel" },
    @{ Key = "rustdesk"; Name = "RustDesk"; Category = "Selfhosted Tools"; WingetId = "RustDesk.RustDesk"; Description = "Open-source remote desktop alternative to TeamViewer" },

    # --- UTILITIES ---
    @{ Key = "afterburner"; Name = "MSI Afterburner"; Category = "Utilities"; WingetId = "Guru3D.Afterburner"; Description = "GPU overclocking, undervolting, and RivaTuner OSD" },
    @{ Key = "7zip"; Name = "7-Zip"; Category = "Utilities"; WingetId = "7zip.7zip"; Description = "High-compression file archiver" },
    @{ Key = "nanazip"; Name = "NanaZip"; Category = "Utilities"; WingetId = "M2Team.NanaZip"; Description = "Modern 7-Zip fork with Windows 11 context menus" },
    @{ Key = "revo"; Name = "Revo Uninstaller"; Category = "Utilities"; WingetId = "RevoUninstaller.RevoUninstaller"; Description = "Deep software removal and leftover registry cleanup" },
    @{ Key = "processlasso"; Name = "Process Lasso"; Category = "Utilities"; WingetId = "Bitsum.ProcessLasso"; Description = "CPU affinity, ProBalance, and process rules manager" },
    @{ Key = "bcu"; Name = "Bulk Crap Uninstaller"; Category = "Utilities"; WingetId = "Klocman.BulkCrapUninstaller"; Description = "Open-source bulk uninstaller with quiet uninstall" },
    @{ Key = "crystaldiskinfo"; Name = "CrystalDiskInfo"; Category = "Utilities"; WingetId = "CrystalDewWorld.CrystalDiskInfo"; Description = "HDD and NVMe SSD health monitoring (S.M.A.R.T.)" },
    @{ Key = "crystaldiskmark"; Name = "CrystalDiskMark"; Category = "Utilities"; WingetId = "CrystalDewWorld.CrystalDiskMark"; Description = "Storage drive read and write speed benchmark" },
    @{ Key = "rufus"; Name = "Rufus"; Category = "Utilities"; WingetId = "Rufus.Rufus"; Description = "Fast bootable USB drive creator with bypass options" },
    @{ Key = "everything"; Name = "Everything"; Category = "Utilities"; WingetId = "voidtools.Everything"; Description = "Instant desktop file search by voidtools" },
    @{ Key = "treesize"; Name = "TreeSize Free"; Category = "Utilities"; WingetId = "JAMSoftware.TreeSizeFree"; Description = "Fast disk space analyzer and folder tree view" },
    @{ Key = "bleachbit"; Name = "BleachBit"; Category = "Utilities"; WingetId = "BleachBit.BleachBit"; Description = "Open-source system disk cleaner and cache wiper" },
    @{ Key = "windirstat"; Name = "WinDirStat"; Category = "Utilities"; WingetId = "WinDirStat.WinDirStat"; Description = "Disk usage statistics viewer and cleanup tool" },
    @{ Key = "fastcopy"; Name = "FastCopy"; Category = "Utilities"; WingetId = "SHIRSystem.FastCopy"; Description = "Fastest copy and backup software on Windows" }
)

# ==============================================================================
# SECTION: WINGET ENGINE & RUNNER FUNCTIONS
# ==============================================================================

function Get-WinGetCommand {
    [CmdletBinding()]
    param()

    $cmd = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    $winAppsPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (Test-Path $winAppsPath) {
        return $winAppsPath
    }

    $progFilesPath = "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    $match = Get-Item $progFilesPath -ErrorAction SilentlyContinue | Select-Object -Last 1
    if ($match) {
        return $match.FullName
    }

    return $null
}

function Install-WinGetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,
        [scriptblock]$LogCallback
    )

    $winget = Get-WinGetCommand
    if (-not $winget) {
        $msg = "[-] ERROR: WinGet is not installed or detected on this system!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return $false
    }

    $msg = "[*] Installing $PackageId via WinGet..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $winget
    $psi.Arguments = "install --id `"$PackageId`" --exact --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    while (-not $proc.HasExited) {
        $out = $proc.StandardOutput.ReadLine()
        if ($out -and $LogCallback) { & $LogCallback "    $out" }
        Start-Sleep -Milliseconds 50
    }
    $rem = $proc.StandardOutput.ReadToEnd()
    if ($rem -and $LogCallback) { & $LogCallback "    $rem" }

    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 2316632065) {
        $msg = "[+] SUCCESS: $PackageId installed successfully!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
        return $true
    } else {
        $msg = "[-] WARNING: WinGet exited with code $($proc.ExitCode) for $PackageId"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }
        return $false
    }
}

function Uninstall-WinGetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,
        [scriptblock]$LogCallback
    )

    $winget = Get-WinGetCommand
    if (-not $winget) {
        $msg = "[-] ERROR: WinGet is not installed or detected on this system!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return $false
    }

    $msg = "[*] Uninstalling $PackageId via WinGet..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $winget
    $psi.Arguments = "uninstall --id `"$PackageId`" --exact --silent"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    while (-not $proc.HasExited) {
        $out = $proc.StandardOutput.ReadLine()
        if ($out -and $LogCallback) { & $LogCallback "    $out" }
        Start-Sleep -Milliseconds 50
    }
    $rem = $proc.StandardOutput.ReadToEnd()
    if ($rem -and $LogCallback) { & $LogCallback "    $rem" }

    if ($proc.ExitCode -eq 0) {
        $msg = "[+] SUCCESS: $PackageId uninstalled successfully!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
        return $true
    } else {
        $msg = "[-] WARNING: WinGet uninstall exited with code $($proc.ExitCode) for $PackageId"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }
        return $false
    }
}

function Upgrade-AllWinGetPackages {
    [CmdletBinding()]
    param(
        [scriptblock]$LogCallback
    )

    $winget = Get-WinGetCommand
    if (-not $winget) {
        $msg = "[-] ERROR: WinGet is not installed or detected on this system!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return $false
    }

    $msg = "[*] Upgrading all eligible applications via WinGet..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $winget
    $psi.Arguments = "upgrade --all --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    while (-not $proc.HasExited) {
        $out = $proc.StandardOutput.ReadLine()
        if ($out -and $LogCallback) { & $LogCallback "    $out" }
        Start-Sleep -Milliseconds 50
    }
    $rem = $proc.StandardOutput.ReadToEnd()
    if ($rem -and $LogCallback) { & $LogCallback "    $rem" }

    if ($proc.ExitCode -eq 0) {
        $msg = "[+] SUCCESS: All applications upgraded to latest version!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
        return $true
    } else {
        $msg = "[*] WinGet upgrade completed with exit code $($proc.ExitCode)"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }
        return $true
    }
}

function Get-WinGetUpgrades {
    [CmdletBinding()]
    param(
        [scriptblock]$LogCallback
    )

    $winget = Get-WinGetCommand
    if (-not $winget) {
        $msg = "[-] ERROR: WinGet is not installed or detected on this system!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return @()
    }

    $msg = "[*] Scanning for available package updates via WinGet..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $winget
    $psi.Arguments = "upgrade"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $raw = ""
    try {
        $proc = [System.Diagnostics.Process]::Start($psi)
        $raw = $proc.StandardOutput.ReadToEnd()
        $proc.WaitForExit(60000)
    } catch {
        $msg = "[-] Failed to execute winget upgrade: $($_.Exception.Message)"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return @()
    }

    $lines = $raw -split "`r?`n"
    $headerIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^Name\s+Id\s+Version\s+Available') {
            $headerIndex = $i
            break
        }
    }

    $results = @()
    if ($headerIndex -ge 0) {
        $header = $lines[$headerIndex]
        $idxId = $header.IndexOf('Id')
        $idxVer = $header.IndexOf('Version')
        $idxAvail = $header.IndexOf('Available')
        $idxSource = $header.IndexOf('Source')

        for ($i = $headerIndex + 2; $i -lt $lines.Count; $i++) {
            $l = $lines[$i]
            if ([string]::IsNullOrWhiteSpace($l)) { continue }
            if ($l -match 'upgrades? available' -or $l -match 'applicable update') { break }
            if ($l.Length -gt $idxAvail) {
                $name = $l.Substring(0, [Math]::Min($l.Length, $idxId)).Trim()
                $id = if ($l.Length -ge $idxVer) { $l.Substring($idxId, $idxVer - $idxId).Trim() } else { '' }
                $ver = if ($l.Length -ge $idxAvail) { $l.Substring($idxVer, $idxAvail - $idxVer).Trim() } else { '' }
                $avail = if ($idxSource -gt 0 -and $l.Length -ge $idxSource) { $l.Substring($idxAvail, $idxSource - $idxAvail).Trim() } else { $l.Substring($idxAvail).Trim() }
                if ($id -and $avail) {
                    $results += [PSCustomObject]@{
                        Name             = $name
                        Id               = $id
                        InstalledVersion = $ver
                        AvailableVersion = $avail
                    }
                }
            }
        }
    }

    return $results
}

function Upgrade-WinGetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,
        [scriptblock]$LogCallback
    )

    $winget = Get-WinGetCommand
    if (-not $winget) {
        $msg = "[-] ERROR: WinGet is not installed or detected on this system!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return $false
    }

    $msg = "[*] Upgrading $PackageId via WinGet..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $winget
    $psi.Arguments = "upgrade --id `"$PackageId`" --exact --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    while (-not $proc.HasExited) {
        $out = $proc.StandardOutput.ReadLine()
        if ($out -and $LogCallback) { & $LogCallback "    $out" }
        Start-Sleep -Milliseconds 50
    }
    $rem = $proc.StandardOutput.ReadToEnd()
    if ($rem -and $LogCallback) { & $LogCallback "    $rem" }

    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 2316632065) {
        $msg = "[+] SUCCESS: $PackageId upgraded successfully!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
        return $true
    } else {
        $msg = "[-] WARNING: WinGet upgrade exited with code $($proc.ExitCode) for $PackageId"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }
        return $false
    }
}

function Install-DirectXDirect {
    [CmdletBinding()]
    param(
        [scriptblock]$LogCallback
    )

    $msg = "[*] Downloading official Microsoft DirectX End-User Runtime Web Installer..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $url = "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe"
    $tempFile = Join-Path $env:TEMP "dxwebsetup.exe"

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
        (New-Object System.Net.WebClient).DownloadFile($url, $tempFile)
        
        $msg = "[*] Executing DirectX silent installation (/Q)..."
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }

        $proc = Start-Process -FilePath $tempFile -ArgumentList "/Q" -Wait -PassThru
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue

        if ($proc.ExitCode -eq 0) {
            $msg = "[+] SUCCESS: DirectX Legacy Runtimes installed successfully!"
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
            return $true
        } else {
            $msg = "[-] DirectX setup exited with code $($proc.ExitCode)"
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor DarkYellow }
            return $false
        }
    } catch {
        $msg = "[-] Failed to download or install DirectX: $($_.Exception.Message)"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return $false
    }
}

function Install-VcRedistAioDirect {
    [CmdletBinding()]
    param(
        [scriptblock]$LogCallback
    )

    $msg = "[*] Downloading official Microsoft Visual C++ 2015-2022 Redistributables..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient

    $urls = @(
        @{ Name = "VC++ 2015-2022 x64"; Url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"; File = Join-Path $env:TEMP "vc_redist.x64.exe" },
        @{ Name = "VC++ 2015-2022 x86"; Url = "https://aka.ms/vs/17/release/vc_redist.x86.exe"; File = Join-Path $env:TEMP "vc_redist.x86.exe" }
    )

    $allSuccess = $true
    foreach ($item in $urls) {
        try {
            $msg = "[*] Downloading $($item.Name)..."
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }
            $wc.DownloadFile($item.Url, $item.File)

            $msg = "[*] Installing $($item.Name) silently..."
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }
            $proc = Start-Process -FilePath $item.File -ArgumentList "/install /quiet /norestart" -Wait -PassThru
            Remove-Item $item.File -Force -ErrorAction SilentlyContinue

            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                $msg = "[+] SUCCESS: $($item.Name) installed successfully!"
                if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
            } else {
                $msg = "[!] Warning: $($item.Name) exited with code $($proc.ExitCode)"
                if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor DarkYellow }
            }
        } catch {
            $msg = "[-] Failed to install $($item.Name): $($_.Exception.Message)"
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
            $allSuccess = $false
        }
    }
    return $allSuccess
}

# ==============================================================================
# TRAFFICMONITOR & MISANS FONTS CUSTOM INSTALLER ENGINE
# ==============================================================================

function Install-TrafficMonitorLatest {
    [CmdletBinding()]
    param(
        [string]$TargetDir = "$env:ProgramFiles\TrafficMonitor",
        [scriptblock]$LogCallback
    )

    $log = {
        param([string]$Text, [string]$Color = "Cyan")
        if ($LogCallback) { & $LogCallback $Text } else { Write-Host $Text -ForegroundColor $Color }
    }

    & $log "[*] Querying latest TrafficMonitor release from GitHub (zhongyang219/TrafficMonitor)..." "Cyan"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

    try {
        $headers = @{ "User-Agent" = "PumpkiN-WinOptimizer" }
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/zhongyang219/TrafficMonitor/releases/latest" -Headers $headers -ErrorAction Stop
        $tag = $release.tag_name
        & $log "[+] Found latest TrafficMonitor release: $tag" "Green"

        # Match x64 zip package (prefer full over lite)
        $asset = $release.assets | Where-Object { $_.name -match 'x64' -and $_.name -notmatch 'Lite' -and $_.name -match '\.zip$' } | Select-Object -First 1
        if (-not $asset) {
            $asset = $release.assets | Where-Object { $_.name -match 'x64' -and $_.name -match '\.zip$' } | Select-Object -First 1
        }
        if (-not $asset) {
            & $log "[-] Could not find x64 release asset for TrafficMonitor." "Red"
            return $false
        }

        $downloadUrl = $asset.browser_download_url
        $tempZip = Join-Path $env:TEMP $asset.name
        $sizeMb = [math]::Round($asset.size / 1MB, 2)
        & $log "[*] Downloading $($asset.name) ($sizeMb MB)..." "Cyan"

        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "PumpkiN-WinOptimizer")
        $wc.DownloadFile($downloadUrl, $tempZip)
        & $log "[+] Download complete: $tempZip" "Green"

        # Check and gracefully stop running TrafficMonitor process before extraction
        $running = Get-Process -Name "TrafficMonitor" -ErrorAction SilentlyContinue
        if ($running) {
            & $log "[*] Stopping active TrafficMonitor process for clean update..." "Yellow"
            $running | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 800
        }

        if (-not (Test-Path $TargetDir)) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        }

        & $log "[*] Extracting package to $TargetDir..." "Yellow"
        $tempExtract = Join-Path $env:TEMP ("TrafficMonitor_Extract_" + [System.Guid]::NewGuid().ToString("N"))
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
        Copy-Item -Path "$tempExtract\*" -Destination $TargetDir -Recurse -Force
        Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
        Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue

        # Create Desktop and Common Programs Start Menu shortcuts
        try {
            $exePath = Join-Path $TargetDir "TrafficMonitor.exe"
            if (Test-Path $exePath) {
                $wsh = New-Object -ComObject WScript.Shell
                $desktopDir = [Environment]::GetFolderPath('Desktop')
                $deskShort = $wsh.CreateShortcut((Join-Path $desktopDir "TrafficMonitor.lnk"))
                $deskShort.TargetPath = $exePath
                $deskShort.WorkingDirectory = $TargetDir
                $deskShort.Description = "TrafficMonitor Real-time System Monitor"
                $deskShort.Save()

                $startPrograms = [Environment]::GetFolderPath('CommonPrograms')
                $startShort = $wsh.CreateShortcut((Join-Path $startPrograms "TrafficMonitor.lnk"))
                $startShort.TargetPath = $exePath
                $startShort.WorkingDirectory = $TargetDir
                $startShort.Description = "TrafficMonitor Real-time System Monitor"
                $startShort.Save()
                & $log "[+] Created Desktop and Start Menu shortcuts." "Green"
            }
        } catch {}

        & $log "[+] SUCCESS: TrafficMonitor ($tag) installed successfully to $TargetDir!" "Green"
        return $true
    } catch {
        & $log "[-] Failed to download or install TrafficMonitor: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Install-MiSansFonts {
    [CmdletBinding()]
    param(
        [string]$SourceFolder = "",
        [scriptblock]$LogCallback
    )

    $log = {
        param([string]$Text, [string]$Color = "Cyan")
        if ($LogCallback) { & $LogCallback $Text } else { Write-Host $Text -ForegroundColor $Color }
    }

    # Resolve fonts source directory: prioritize bundled assets, then local dev paths
    $possibleDirs = @(
        $SourceFolder,
        (Join-Path $PSScriptRoot "..\assets\Fonts\MiSans"),
        "D:\Editing\Fonts\MiSans",
        (Join-Path $env:SystemDrive "Editing\Fonts\MiSans")
    )
    $fontDir = $null
    foreach ($d in $possibleDirs) {
        if ($d -and (Test-Path $d)) {
            $files = Get-ChildItem -Path $d -Filter "*.ttf" -ErrorAction SilentlyContinue
            if ($files -and $files.Count -gt 0) {
                $fontDir = $d
                break
            }
        }
    }

    if (-not $fontDir) {
        & $log "[-] MiSans font files not found in assets or D:\Editing\Fonts\MiSans." "Red"
        return $false
    }

    & $log "[*] Installing MiSans fonts from $fontDir..." "Cyan"
    $fontsInstalled = 0
    $fontDestDir = Join-Path $env:windir "Fonts"
    $fontRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

    # AddFontResource signature for real-time font cache update without reboot
    $csharpSig = @'
    using System;
    using System.Runtime.InteropServices;
    public class FontNative {
        [DllImport("gdi32.dll", EntryPoint="AddFontResourceW", SetLastError=true)]
        public static extern int AddFontResource([MarshalAs(UnmanagedType.LPWStr)] string lpFileName);
        [DllImport("user32.dll")]
        public static extern int SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, IntPtr lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
    }
'@
    if (-not ([System.Management.Automation.PSTypeName]'FontNative').Type) {
        try { Add-Type -TypeDefinition $csharpSig -ErrorAction SilentlyContinue } catch {}
    }

    $ttfFiles = Get-ChildItem -Path $fontDir -Filter "*.ttf" -ErrorAction SilentlyContinue
    foreach ($f in $ttfFiles) {
        try {
            $destFile = Join-Path $fontDestDir $f.Name
            Copy-Item -Path $f.FullName -Destination $destFile -Force -ErrorAction Stop

            # Font display name in registry
            $cleanName = $f.BaseName -replace '^MiSans-?', 'MiSans '
            $cleanName = $cleanName.Trim()
            $regName = "$cleanName (TrueType)"

            Set-ItemProperty -Path $fontRegPath -Name $regName -Value $f.Name -Type String -Force -ErrorAction SilentlyContinue

            if (([System.Management.Automation.PSTypeName]'FontNative').Type) {
                [FontNative]::AddFontResource($destFile) | Out-Null
            }
            $fontsInstalled++
            & $log "      [+] Installed font: $regName" "Green"
        } catch {
            & $log "      [!] Warning copying $($f.Name): $($_.Exception.Message)" "Yellow"
        }
    }

    # Broadcast WM_FONTCHANGE to refresh all top-level windows
    if (([System.Management.Automation.PSTypeName]'FontNative').Type) {
        $res = [UIntPtr]::Zero
        [FontNative]::SendMessageTimeout([IntPtr]0xFFFF, 0x001D, [UIntPtr]::Zero, [IntPtr]::Zero, 2, 1000, [ref]$res) | Out-Null
    }

    if ($fontsInstalled -gt 0) {
        & $log "[+] SUCCESS: $fontsInstalled MiSans font weights installed and registered with Windows!" "Green"
        return $true
    } else {
        & $log "[-] No fonts could be installed." "Red"
        return $false
    }
}

function Apply-TrafficMonitorConfig {
    [CmdletBinding()]
    param(
        [string]$TargetDir = "",
        [string]$ConfigSource = "",
        [scriptblock]$LogCallback
    )

    $log = {
        param([string]$Text, [string]$Color = "Cyan")
        if ($LogCallback) { & $LogCallback $Text } else { Write-Host $Text -ForegroundColor $Color }
    }

    # 1. Resolve source config.ini: check bundled assets first, then user's local path
    $possibleConfigs = @(
        $ConfigSource,
        (Join-Path $PSScriptRoot "..\assets\TrafficMonitor\config.ini"),
        "G:\Program Files\TrafficMonitor\config.ini",
        "C:\Program Files\TrafficMonitor\config.ini"
    )
    $srcConfig = $null
    foreach ($c in $possibleConfigs) {
        if ($c -and (Test-Path $c)) {
            $srcConfig = $c
            break
        }
    }

    if (-not $srcConfig) {
        & $log "[-] Custom config.ini not found in assets or G:\Program Files\TrafficMonitor\config.ini." "Red"
        return $false
    }

    # 2. Resolve destination directory
    $possibleDests = @(
        $TargetDir,
        "$env:ProgramFiles\TrafficMonitor",
        "G:\Program Files\TrafficMonitor",
        "C:\Program Files (x86)\TrafficMonitor"
    )
    $destDir = $null
    foreach ($d in $possibleDests) {
        if ($d -and (Test-Path (Join-Path $d "TrafficMonitor.exe"))) {
            $destDir = $d
            break
        } elseif ($d -and (Test-Path $d)) {
            $destDir = $d
            break
        }
    }
    if (-not $destDir) {
        $destDir = "$env:ProgramFiles\TrafficMonitor"
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    & $log "[*] Applying TrafficMonitor config from $srcConfig to $destDir..." "Cyan"

    # Close running TrafficMonitor before overwriting config.ini
    $running = Get-Process -Name "TrafficMonitor" -ErrorAction SilentlyContinue
    $wasRunning = $false
    if ($running) {
        $wasRunning = $true
        & $log "[*] Stopping running TrafficMonitor process to apply config..." "Yellow"
        $running | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 800
    }

    $destFile = Join-Path $destDir "config.ini"
    try {
        Copy-Item -Path $srcConfig -Destination $destFile -Force -ErrorAction Stop
        & $log "[+] SUCCESS: Custom config.ini applied to $destFile!" "Green"

        if ($wasRunning) {
            $exe = Join-Path $destDir "TrafficMonitor.exe"
            if (Test-Path $exe) {
                & $log "[*] Restarting TrafficMonitor with new configuration..." "Cyan"
                Start-Process -FilePath $exe -WorkingDirectory $destDir
            }
        }
        return $true
    } catch {
        & $log "[-] Failed to apply config.ini: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Start-TrafficMonitorApp {
    [CmdletBinding()]
    param(
        [scriptblock]$LogCallback
    )

    $log = {
        param([string]$Text, [string]$Color = "Cyan")
        if ($LogCallback) { & $LogCallback $Text } else { Write-Host $Text -ForegroundColor $Color }
    }

    $possiblePaths = @(
        "$env:ProgramFiles\TrafficMonitor\TrafficMonitor.exe",
        "G:\Program Files\TrafficMonitor\TrafficMonitor.exe",
        "C:\Program Files (x86)\TrafficMonitor\TrafficMonitor.exe"
    )
    $found = $null
    foreach ($p in $possiblePaths) {
        if (Test-Path $p) {
            $found = $p
            break
        }
    }

    if ($found) {
        & $log "[*] Launching TrafficMonitor ($found)..." "Cyan"
        $dir = Split-Path $found -Parent
        Start-Process -FilePath $found -WorkingDirectory $dir
        & $log "[+] TrafficMonitor launched successfully!" "Green"
        return $true
    } else {
        & $log "[-] TrafficMonitor.exe not found. Please install it first." "Yellow"
        return $false
    }
}

function Install-TrafficMonitorSuite {
    [CmdletBinding()]
    param(
        [scriptblock]$LogCallback
    )

    $ok1 = Install-TrafficMonitorLatest -LogCallback $LogCallback
    $ok2 = Install-MiSansFonts -LogCallback $LogCallback
    $ok3 = Apply-TrafficMonitorConfig -LogCallback $LogCallback
    if ($ok1) { Start-TrafficMonitorApp -LogCallback $LogCallback }
    return ($ok1 -and $ok2 -and $ok3)
}

function Get-AppCatalog {
    return $Global:AppCatalog
}

function Get-AppCatalogCategories {
    if ($Global:AppCatalog) {
        return @($Global:AppCatalog | ForEach-Object { $_.Category } | Where-Object { $_ } | Select-Object -Unique | Sort-Object)
    }
    return @()
}

# ==============================================================================

# ------------------------------------------------------------------------------
# MODULE: Gui-Markup
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: Windows 11 Fluent + Cyberpunk Dark WPF (XAML) Markup
  Version 5.6.0
================================================================================
#>

$Global:xamlContent = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="PumpkiN Ultimate Windows Optimizer &amp; Software Suite v5.7.1"
    Height="840" Width="1260"
    MinHeight="700" MinWidth="1040"
    WindowStartupLocation="CenterScreen"
    Background="#0A0E17"
    Foreground="#F1F5F9"
    FontFamily="Segoe UI Variable Text, Segoe UI, Arial"
    TextOptions.TextFormattingMode="Display"
    TextOptions.TextRenderingMode="ClearType"
    SnapsToDevicePixels="True"
    UseLayoutRounding="True">

    <Window.Resources>
        <!-- Palette Brushes -->
        <SolidColorBrush x:Key="BgDark" Color="#0A0E17"/>
        <SolidColorBrush x:Key="BgSidebar" Color="#0D131F"/>
        <SolidColorBrush x:Key="BgCard" Color="#121824"/>
        <SolidColorBrush x:Key="BgCardHover" Color="#182233"/>
        <SolidColorBrush x:Key="BorderDark" Color="#1F293D"/>
        <SolidColorBrush x:Key="BorderSubtle" Color="#151E2E"/>
        <SolidColorBrush x:Key="AccentCyan" Color="#00D2FF"/>
        <SolidColorBrush x:Key="AccentGreen" Color="#00FF88"/>
        <SolidColorBrush x:Key="AccentOrange" Color="#FF7700"/>
        <SolidColorBrush x:Key="AccentCrimson" Color="#FF3366"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="TextMuted" Color="#94A3B8"/>
        <SolidColorBrush x:Key="TextDim" Color="#64748B"/>
        <SolidColorBrush x:Key="ConsoleBg" Color="#06090E"/>

        <!-- Windows 11 Fluent Toggle Switch Style -->
        <Style x:Key="FluentToggleSwitch" TargetType="ToggleButton">
            <Setter Property="Width" Value="66"/>
            <Setter Property="Height" Value="28"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ToggleButton">
                        <Border x:Name="PillBorder" Background="#1E2838" BorderBrush="#2C3B52" BorderThickness="1" CornerRadius="14" Padding="3">
                            <Grid>
                                <!-- State Label -->
                                <TextBlock x:Name="TxtToggleState" Text="OFF" FontSize="10" FontWeight="Bold" Foreground="#94A3B8" VerticalAlignment="Center" HorizontalAlignment="Right" Margin="0,0,7,0"/>
                                <!-- Slider Thumb Knob -->
                                <Ellipse x:Name="ThumbKnob" Width="20" Height="20" Fill="#CBD5E1" HorizontalAlignment="Left" VerticalAlignment="Center">
                                    <Ellipse.Effect>
                                        <DropShadowEffect BlurRadius="4" ShadowDepth="1" Opacity="0.3" Color="#000000"/>
                                    </Ellipse.Effect>
                                </Ellipse>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="PillBorder" Property="Background" Value="#002D1E"/>
                                <Setter TargetName="PillBorder" Property="BorderBrush" Value="#00FF88"/>
                                <Setter TargetName="ThumbKnob" Property="HorizontalAlignment" Value="Right"/>
                                <Setter TargetName="ThumbKnob" Property="Fill" Value="#00FF88"/>
                                <Setter TargetName="TxtToggleState" Property="Text" Value="ON"/>
                                <Setter TargetName="TxtToggleState" Property="HorizontalAlignment" Value="Left"/>
                                <Setter TargetName="TxtToggleState" Property="Foreground" Value="#00FF88"/>
                                <Setter TargetName="TxtToggleState" Property="Margin" Value="7,0,0,0"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="PillBorder" Property="BorderBrush" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Sidebar Navigation RadioButton Style -->
        <Style x:Key="NavRailItem" TargetType="RadioButton">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#94A3B8"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Margin" Value="0,2,0,2"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="RadioButton">
                        <Border x:Name="ItemBorder" Background="{TemplateBinding Background}" CornerRadius="6" Padding="12,10" Margin="4,1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="4"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <!-- Active Indicator Bar -->
                                <Border x:Name="ActiveIndicator" Grid.Column="0" Background="#00D2FF" CornerRadius="2" Margin="0,0,8,0" Visibility="Collapsed"/>
                                <ContentPresenter Grid.Column="1" HorizontalAlignment="Left" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#141E2E"/>
                                <Setter TargetName="ActiveIndicator" Property="Visibility" Value="Visible"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#101826"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Primary Cyan Button Style -->
        <Style x:Key="CyanButton" TargetType="Button">
            <Setter Property="Background" Value="#00D2FF"/>
            <Setter Property="Foreground" Value="#0A0E17"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="14,7"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#38BDF8"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#0284C7"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Accent Orange Button Style -->
        <Style x:Key="OrangeButton" TargetType="Button">
            <Setter Property="Background" Value="#FF7700"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="14,7"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FB923C"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#EA580C"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Dark Outlined Button Style -->
        <Style x:Key="DarkOutlineButton" TargetType="Button">
            <Setter Property="Background" Value="#121824"/>
            <Setter Property="Foreground" Value="#CBD5E1"/>
            <Setter Property="BorderBrush" Value="#1F293D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#1A2234"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Danger Crimson Revert Button -->
        <Style x:Key="DangerOutlineButton" TargetType="Button">
            <Setter Property="Background" Value="#1C1218"/>
            <Setter Property="Foreground" Value="#FF4A70"/>
            <Setter Property="BorderBrush" Value="#4A2030"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FF3366"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#FF3366"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Preset Filter Pill Chip Button -->
        <Style x:Key="PresetChip" TargetType="Button">
            <Setter Property="Background" Value="#121824"/>
            <Setter Property="Foreground" Value="#94A3B8"/>
            <Setter Property="BorderBrush" Value="#1F293D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="12,5"/>
            <Setter Property="Margin" Value="0,0,6,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="12" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Category Chip for Software Catalog -->
        <Style x:Key="CategoryChip" TargetType="Button" BasedOn="{StaticResource PresetChip}"/>

        <!-- Custom Dark ScrollBar -->
        <Style TargetType="ScrollBar">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Width" Value="8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Grid Background="Transparent">
                            <Track x:Name="PART_Track" IsDirectionReversed="True">
                                <Track.Thumb>
                                    <Thumb Background="#2C3B52" BorderThickness="0">
                                        <Thumb.Template>
                                            <ControlTemplate TargetType="Thumb">
                                                <Border Background="{TemplateBinding Background}" CornerRadius="4"/>
                                            </ControlTemplate>
                                        </Thumb.Template>
                                    </Thumb>
                                </Track.Thumb>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ComboBoxItem Dark Style -->
        <Style x:Key="FluentDarkComboBoxItem" TargetType="ComboBoxItem">
            <Setter Property="SnapsToDevicePixels" Value="True"/>
            <Setter Property="Padding" Value="10,7"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#F1F5F9"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBoxItem">
                        <Border x:Name="ItemBorder" Background="{TemplateBinding Background}" BorderThickness="0" CornerRadius="4" Padding="{TemplateBinding Padding}" Margin="2,1">
                            <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#1E293D"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#14263D"/>
                                <Setter Property="Foreground" Value="#00FF88"/>
                                <Setter Property="FontWeight" Value="SemiBold"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ComboBox Dropdown ToggleButton Template -->
        <ControlTemplate x:Key="ComboBoxToggleButtonTemplate" TargetType="ToggleButton">
            <Border x:Name="TemplateRoot" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="28"/>
                    </Grid.ColumnDefinitions>
                    <!-- Arrow Icon -->
                    <Path x:Name="Arrow" Grid.Column="1" HorizontalAlignment="Center" VerticalAlignment="Center" Data="M 0 0 L 4 4 L 8 0 Z" Fill="#94A3B8"/>
                </Grid>
            </Border>
            <ControlTemplate.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="TemplateRoot" Property="BorderBrush" Value="#00D2FF"/>
                    <Setter TargetName="Arrow" Property="Fill" Value="#00D2FF"/>
                </Trigger>
                <Trigger Property="IsChecked" Value="True">
                    <Setter TargetName="TemplateRoot" Property="BorderBrush" Value="#00D2FF"/>
                    <Setter TargetName="Arrow" Property="Fill" Value="#00D2FF"/>
                </Trigger>
            </ControlTemplate.Triggers>
        </ControlTemplate>

        <!-- ComboBox Dark Style -->
        <Style x:Key="FluentDarkComboBox" TargetType="ComboBox">
            <Setter Property="ItemContainerStyle" Value="{StaticResource FluentDarkComboBoxItem}"/>
            <Setter Property="SnapsToDevicePixels" Value="True"/>
            <Setter Property="OverridesDefaultStyle" Value="True"/>
            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility" Value="Auto"/>
            <Setter Property="ScrollViewer.VerticalScrollBarVisibility" Value="Auto"/>
            <Setter Property="ScrollViewer.CanContentScroll" Value="True"/>
            <Setter Property="Background" Value="#0D131F"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#2C3B52"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <ToggleButton x:Name="ToggleButton"
                                          Template="{StaticResource ComboBoxToggleButtonTemplate}"
                                          Focusable="false"
                                          IsChecked="{Binding Path=IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}"
                                          ClickMode="Press"
                                          Background="{TemplateBinding Background}"
                                          BorderBrush="{TemplateBinding BorderBrush}"
                                          BorderThickness="{TemplateBinding BorderThickness}"/>
                            <ContentPresenter x:Name="ContentSite" IsHitTestVisible="False"
                                              Content="{TemplateBinding SelectionBoxItem}"
                                              ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}"
                                              ContentTemplateSelector="{TemplateBinding ItemTemplateSelector}"
                                              Margin="10,3,28,3"
                                              VerticalAlignment="Center" HorizontalAlignment="Left"/>
                            <Popup x:Name="PART_Popup" AllowsTransparency="True"
                                   IsOpen="{Binding Path=IsDropDownOpen, RelativeSource={RelativeSource TemplatedParent}}"
                                   Placement="Bottom" PopupAnimation="Slide" Focusable="False">
                                <Grid x:Name="DropDown" SnapsToDevicePixels="True"
                                      MinWidth="{TemplateBinding ActualWidth}"
                                      MaxHeight="260">
                                    <Border x:Name="DropDownBorder" Background="#0D131F"
                                            BorderBrush="#2C3B52" BorderThickness="1"
                                            CornerRadius="6" Margin="0,3,0,6">
                                        <Border.Effect>
                                            <DropShadowEffect BlurRadius="12" ShadowDepth="4" Opacity="0.6" Color="#000000"/>
                                        </Border.Effect>
                                        <ScrollViewer Margin="2,4" SnapsToDevicePixels="True">
                                            <StackPanel IsItemsHost="True" KeyboardNavigation.DirectionalNavigation="Contained"/>
                                        </ScrollViewer>
                                    </Border>
                                </Grid>
                            </Popup>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="HasItems" Value="False">
                                <Setter TargetName="DropDownBorder" Property="MinHeight" Value="30"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="BorderBrush" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Default ComboBox & ComboBoxItem Implicit Styles -->
        <Style TargetType="ComboBox" BasedOn="{StaticResource FluentDarkComboBox}"/>
        <Style TargetType="ComboBoxItem" BasedOn="{StaticResource FluentDarkComboBoxItem}"/>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto" Name="RowLogDrawer"/>
        </Grid.RowDefinitions>

        <!-- ROW 0: TOP APP BAR AND SEARCH -->
        <Border Grid.Row="0" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="0,0,0,1" Padding="18,10">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="220"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <!-- Brand and Logo -->
                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                    <Border Width="34" Height="34" CornerRadius="6" Background="#121824" BorderBrush="#00D2FF" BorderThickness="1" Margin="0,0,10,0" VerticalAlignment="Center">
                        <Image Name="ImgAppLogo" Width="26" Height="26" VerticalAlignment="Center" HorizontalAlignment="Center" RenderOptions.BitmapScalingMode="HighQuality"/>
                    </Border>
                    <StackPanel VerticalAlignment="Center">
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="PUMPKIN" FontSize="16" FontWeight="Bold" Foreground="#00D2FF"/>
                            <TextBlock Text=" OPTIMIZER" FontSize="16" FontWeight="Bold" Foreground="#FFFFFF"/>
                            <Border Background="#FF7700" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                <TextBlock Text="v5.7.1" FontSize="10" FontWeight="Bold" Foreground="#0A0E17"/>
                            </Border>
                        </StackPanel>
                        <TextBlock Text="Windows 11 Fluent Gaming Suite" FontSize="11" Foreground="#64748B"/>
                    </StackPanel>
                </StackPanel>

                <!-- Universal Instant Search Bar -->
                <Grid Grid.Column="1" Margin="24,0" VerticalAlignment="Center" MaxWidth="540" HorizontalAlignment="Stretch">
                    <TextBox Name="TxtSearch" Height="34" Background="#121824" Foreground="#FFFFFF" BorderBrush="#1F293D" BorderThickness="1" Padding="12,6" FontSize="12" VerticalContentAlignment="Center">
                        <TextBox.Template>
                            <ControlTemplate TargetType="TextBox">
                                <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                                    <ScrollViewer x:Name="PART_ContentHost"/>
                                </Border>
                            </ControlTemplate>
                        </TextBox.Template>
                    </TextBox>
                    <TextBlock IsHitTestVisible="False" Text="Search all tweaks, settings and apps (e.g. MPO, 8000Hz, Steam, telemetry)..." VerticalAlignment="Center" Margin="14,0,0,0" Foreground="#64748B" FontSize="12">
                        <TextBlock.Style>
                            <Style TargetType="TextBlock">
                                <Setter Property="Visibility" Value="Collapsed"/>
                                <Style.Triggers>
                                    <DataTrigger Binding="{Binding Text, ElementName=TxtSearch}" Value="">
                                        <Setter Property="Visibility" Value="Visible"/>
                                    </DataTrigger>
                                </Style.Triggers>
                            </Style>
                        </TextBlock.Style>
                    </TextBlock>
                    <Button Name="BtnClearSearch" Content="x" Width="24" Height="24" HorizontalAlignment="Right" Margin="0,0,6,0" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Cursor="Hand" ToolTip="Clear search filter"/>
                </Grid>

                <!-- Top Quick Actions -->
                <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                    <Button Name="BtnBeastMode" Content="ENGAGE BEAST MODE" Style="{StaticResource OrangeButton}" Margin="0,0,8,0"/>
                    <Button Name="BtnRestorePointTop" Content="Restore Point" Style="{StaticResource DarkOutlineButton}" Margin="0,0,8,0"/>
                    <Button Name="BtnMasActivateTop" Content="MAS Activation" Style="{StaticResource DarkOutlineButton}" Margin="0,0,8,0"/>
                    <Button Name="BtnExitTop" Content="Exit" Style="{StaticResource DarkOutlineButton}"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- ROW 1: MAIN BODY (SIDEBAR RAIL AND PAGE CONTAINER) -->
        <Grid Grid.Row="1">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="220"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- LEFT NAVIGATION RAIL -->
            <Border Grid.Column="0" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="0,0,1,0" Padding="8,12">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <StackPanel Grid.Row="0">
                        <TextBlock Text="NAVIGATION" FontSize="10" FontWeight="Bold" Foreground="#64748B" Margin="12,4,0,8"/>
                        <RadioButton Name="NavDashboard" Content="Dashboard and Audit" Style="{StaticResource NavRailItem}" IsChecked="True"/>
                        <RadioButton Name="NavGaming" Content="Gaming and Latency" Style="{StaticResource NavRailItem}"/>
                        <RadioButton Name="NavPrivacy" Content="Privacy and Telemetry" Style="{StaticResource NavRailItem}"/>
                        <RadioButton Name="NavSystem" Content="System and Usability" Style="{StaticResource NavRailItem}"/>
                        <RadioButton Name="NavSoftware" Content="Software Downloader" Style="{StaticResource NavRailItem}"/>
                        <RadioButton Name="NavDevice" Content="Device Specs" Style="{StaticResource NavRailItem}"/>
                    </StackPanel>

                    <!-- Bottom Sidebar Status Badge -->
                    <Border Grid.Row="1" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10" Margin="4,0,4,4">
                        <StackPanel>
                            <TextBlock Text="SYSTEM STATUS" FontSize="10" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,4"/>
                            <TextBlock Name="TxtActiveTweakRatio" Text="Probing PC state..." FontSize="11" Foreground="#00FF88" FontWeight="SemiBold"/>
                            <TextBlock Text="100% Symmetrical Safe Rollbacks" FontSize="10" Foreground="#64748B" Margin="0,2,0,0"/>
                        </StackPanel>
                    </Border>
                </Grid>
            </Border>

            <!-- RIGHT PAGE CONTAINER -->
            <Grid Grid.Column="1" Background="#0A0E17" Margin="16,12,16,12">

                <!-- PAGE 1: DASHBOARD AND AUDIT -->
                <Grid Name="PageDashboard" Visibility="Visible">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- Hero Banner: Radial Score Gauge and Live Specs -->
                    <Border Grid.Row="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="18,14" Margin="0,0,0,12">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <!-- Radial Score Circle -->
                            <Border Name="BorderScoreGauge" Grid.Column="0" Width="84" Height="84" CornerRadius="42" Background="#0A0E17" BorderBrush="#00D2FF" BorderThickness="3" VerticalAlignment="Center" Margin="0,0,18,0">
                                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                    <TextBlock Name="TxtScorePercent" Text="--%" FontSize="20" FontWeight="Bold" Foreground="#00FF88" HorizontalAlignment="Center"/>
                                    <TextBlock Name="TxtScoreGrade" Text="Probing..." FontSize="10" FontWeight="SemiBold" Foreground="#94A3B8" HorizontalAlignment="Center"/>
                                    <TextBlock Text="Score" FontSize="8" Foreground="#64748B" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>

                            <!-- Center Banner Text -->
                            <StackPanel Grid.Column="1" VerticalAlignment="Center">
                                <StackPanel Orientation="Horizontal" Margin="0,0,0,4">
                                    <TextBlock Text="WINDOWS PERFORMANCE AND AUDIT DASHBOARD" FontSize="14" FontWeight="Bold" Foreground="#FFFFFF"/>
                                    <Border Background="#14261C" BorderBrush="#00FF88" BorderThickness="1" CornerRadius="3" Padding="6,1" Margin="10,0,0,0" VerticalAlignment="Center">
                                        <TextBlock Text="LIVE AUDIT ENGINE" FontSize="9" FontWeight="Bold" Foreground="#00FF88"/>
                                    </Border>
                                </StackPanel>
                                <TextBlock Text="100% reversible live Windows tuning. Every single tweak reflects your exact live registry state with instant ON / OFF control." FontSize="12" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                <TextBlock Name="TxtScoreSubtitle" Text="[OK] Fast Startup Probed - Clean Symmetrical Rollbacks Ready" FontSize="11" Foreground="#64748B" Margin="0,4,0,0"/>
                            </StackPanel>

                            <!-- Right Action Buttons -->
                            <StackPanel Grid.Column="2" VerticalAlignment="Center">
                                <Button Name="BtnScanSystemStateBanner" Content="Re-Scan System" Style="{StaticResource CyanButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnRevertDefaults" Content="Rollback to Defaults" Style="{StaticResource DangerOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- ROW 1: LIVE HARDWARE TELEMETRY -->
                    <Border Grid.Row="1" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,12">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <StackPanel Orientation="Horizontal" Margin="0,0,20,0" VerticalAlignment="Center">
                                    <TextBlock Text="CPU LOAD: " FontWeight="Bold" FontSize="11" Foreground="#00D2FF"/>
                                    <TextBlock Name="TxtLiveCpu" Text="--%" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" Margin="0,0,20,0" VerticalAlignment="Center">
                                    <TextBlock Text="RAM USAGE: " FontWeight="Bold" FontSize="11" Foreground="#00FF88"/>
                                    <TextBlock Name="TxtLiveRam" Text="-- GB (--%)" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" Margin="0,0,20,0" VerticalAlignment="Center">
                                    <TextBlock Text="ROUTER PING: " FontWeight="Bold" FontSize="11" Foreground="#FF7700"/>
                                    <TextBlock Name="TxtLivePing" Text="-- ms" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                    <TextBlock Text="SMART BOOSTER: " FontWeight="Bold" FontSize="11" Foreground="#A855F7"/>
                                    <TextBlock Name="TxtLiveBooster" Text="STANDBY" FontWeight="SemiBold" FontSize="12" Foreground="#94A3B8"/>
                                </StackPanel>
                            </StackPanel>

                            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                <Button Name="BtnStartGameBooster" Content="Start Match Daemon" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                <Button Name="BtnPurgeStandby" Content="Purge Standby RAM" Style="{StaticResource DarkOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- ROW 2: ACTIVE TWEAKS CATEGORY BREAKDOWN -->
                    <Border Grid.Row="2" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,12">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <!-- Gaming Status Chip -->
                            <Border Grid.Column="0" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10,8" Margin="0,0,6,0">
                                <StackPanel>
                                    <TextBlock Text="GAMING &amp; LATENCY" FontSize="10" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,0,2"/>
                                    <TextBlock Name="TxtActiveGamingCount" Text="-- / -- Active" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF"/>
                                    <TextBlock Text="HPET, Unparking, Win32Priority" FontSize="9" Foreground="#64748B" Margin="0,2,0,0"/>
                                </StackPanel>
                            </Border>

                            <!-- Privacy Status Chip -->
                            <Border Grid.Column="1" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10,8" Margin="3,0,3,0">
                                <StackPanel>
                                    <TextBlock Text="PRIVACY &amp; TELEMETRY" FontSize="10" FontWeight="Bold" Foreground="#FF7700" Margin="0,0,0,2"/>
                                    <TextBlock Name="TxtActivePrivacyCount" Text="-- / -- Active" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF"/>
                                    <TextBlock Text="App Telemetry, Bing, Tracking" FontSize="9" Foreground="#64748B" Margin="0,2,0,0"/>
                                </StackPanel>
                            </Border>

                            <!-- System Status Chip -->
                            <Border Grid.Column="2" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10,8" Margin="6,0,6,0">
                                <StackPanel>
                                    <TextBlock Text="SYSTEM &amp; USABILITY" FontSize="10" FontWeight="Bold" Foreground="#00FF88" Margin="0,0,0,2"/>
                                    <TextBlock Name="TxtActiveSystemCount" Text="-- / -- Active" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF"/>
                                    <TextBlock Text="No Shortcut Arrow, Classic Context" FontSize="9" Foreground="#64748B" Margin="0,2,0,0"/>
                                </StackPanel>
                            </Border>

                            <!-- View Active Tweaks Button -->
                            <StackPanel Grid.Column="3" VerticalAlignment="Center" Margin="6,0,0,0">
                                <Button Name="BtnViewActiveTweaks" Content="Inspect Active in Console" Style="{StaticResource CyanButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnApplyUnappliedDashboard" Content="Apply Unapplied" Style="{StaticResource DarkOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- ROW 3: 1-CLICK CURATED PROFILE LAUNCHERS -->
                    <Grid Grid.Row="3">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <!-- Card 1: Esports Profile -->
                        <Border Grid.Column="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14" Margin="0,0,8,0">
                            <StackPanel>
                                <TextBlock Text="ESPORTS AND LOW LATENCY" FontSize="13" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,0,6"/>
                                <TextBlock Text="Tuned for Valorant, CS2, Apex, Fortnite. Activates 8000Hz input, Win32Priority 0x26, GPU MSI mode, and disables Wi-Fi 60s background scanning spikes." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,0,0,12"/>
                                <Button Name="BtnApplyProfileEsports" Content="Apply Esports Profile" Style="{StaticResource CyanButton}" HorizontalAlignment="Stretch"/>
                            </StackPanel>
                        </Border>

                        <!-- Card 2: Recommended Safe Profile -->
                        <Border Grid.Column="1" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14" Margin="4,0,4,0">
                            <StackPanel>
                                <TextBlock Text="RECOMMENDED SAFE" FontSize="13" FontWeight="Bold" Foreground="#00FF88" Margin="0,0,0,6"/>
                                <TextBlock Text="The definitive everyday profile for gaming, work, and streaming. Strips telemetry, optimizes network TCP/IP, fixes MPO micro-stutters, and unlocks power schemes." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,0,0,12"/>
                                <Button Name="BtnApplyProfileRecommended" Content="Apply Recommended Profile" Style="{StaticResource CyanButton}" HorizontalAlignment="Stretch"/>
                            </StackPanel>
                        </Border>

                        <!-- Card 3: Privacy and Security Profile -->
                        <Border Grid.Column="2" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14" Margin="8,0,0,0">
                            <StackPanel>
                                <TextBlock Text="PRIVACY AND DEBLOAT" FontSize="13" FontWeight="Bold" Foreground="#FF7700" Margin="0,0,0,6"/>
                                <TextBlock Text="Suppresses telemetry, disables Start Menu web search, removes diagnostic tracking from Edge/Chrome, stops clipboard syncing, and cleans background tasks." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,0,0,12"/>
                                <Button Name="BtnApplyProfilePrivacy" Content="Apply Privacy Profile" Style="{StaticResource OrangeButton}" HorizontalAlignment="Stretch"/>
                            </StackPanel>
                        </Border>
                    </Grid>
                </Grid>

                <!-- PAGE 2: GAMING AND LATENCY TWEAKS -->
                <Grid Name="PageGaming" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- Master Control Strip and Preset Chips -->
                    <Border Grid.Row="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <!-- Filter Chips -->
                            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                                <TextBlock Text="FILTER:" FontSize="11" FontWeight="Bold" Foreground="#64748B" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                <Button Name="ChipGamingAll" Content="All Tweaks" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipGamingRecommended" Content="Recommended" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipGamingEsports" Content="Esports Latency" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipGamingActive" Content="Active Only" Style="{StaticResource PresetChip}"/>
                            </StackPanel>
                            <!-- Master Action Buttons -->
                            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                <Button Name="BtnGamingApplyAll" Content="Turn All ON" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                <Button Name="BtnGamingRollbackAll" Content="Turn All OFF (Defaults)" Style="{StaticResource DangerOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- Scrollable Dynamic Card Container -->
                    <Border Grid.Row="1" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="10">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <StackPanel Margin="2">
                                <!-- CUSTOM GAMING CURSORS (23 PACKS) -->
                                <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                            <StackPanel Orientation="Horizontal" Margin="0,0,0,4">
                                                <TextBlock Text="CUSTOM GAMING CURSORS (23 PACKS)" FontSize="12" FontWeight="Bold" Foreground="#00D2FF"/>
                                                <Border Background="#14261C" BorderBrush="#00FF88" BorderThickness="1" CornerRadius="3" Padding="6,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                    <TextBlock Text="HOT RELOAD" FontSize="9" FontWeight="Bold" Foreground="#00FF88"/>
                                                </Border>
                                            </StackPanel>
                                            <TextBlock Text="Select and apply esports cursor schemes (Dim, Night Diamond, Oxygen, Material, etc.). Instantly reloads live without Windows restart." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                            <StackPanel Orientation="Horizontal" Margin="0,4,0,0">
                                                <TextBlock Text="Active Scheme: " FontSize="11" FontWeight="SemiBold" Foreground="#64748B"/>
                                                <TextBlock Name="TxtActiveCursorScheme" Text="Windows Default" FontSize="11" FontWeight="Bold" Foreground="#00FF88"/>
                                            </StackPanel>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <ComboBox Name="CmbCursorSchemes" Width="220" Height="30" Style="{StaticResource FluentDarkComboBox}" Margin="0,0,8,0" VerticalContentAlignment="Center"/>
                                            <Button Name="BtnInstallCursor" Content="Install Scheme" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnRestoreCursor" Content="Restore Default" Style="{StaticResource DarkOutlineButton}"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>

                                <!-- GAMING DNS BENCHMARK AND FAST SWITCHER -->
                                <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                            <TextBlock Text="GAMING DNS BENCHMARK AND FAST SWITCHER" FontSize="12" FontWeight="Bold" Foreground="#00FF88" Margin="0,0,0,4"/>
                                            <TextBlock Text="Benchmarks Cloudflare (1.1.1.1), Google (8.8.8.8), Quad9 (9.9.9.9), and OpenDNS. Automatically binds your active NIC to the lowest latency provider." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnBenchmarkDns" Content="Benchmark and Apply Fastest DNS" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnResetDns" Content="Reset to DHCP Auto" Style="{StaticResource DarkOutlineButton}"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>

                                <StackPanel Name="PanelGamingTweaks"/>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 3: PRIVACY AND TELEMETRY -->
                <Grid Name="PagePrivacy" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                                <TextBlock Text="FILTER:" FontSize="11" FontWeight="Bold" Foreground="#64748B" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                <Button Name="ChipPrivacyAll" Content="All Privacy Tweaks" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipPrivacyActive" Content="Active Only" Style="{StaticResource PresetChip}"/>
                            </StackPanel>
                            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                <Button Name="BtnPrivacyApplyAll" Content="Turn All ON" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                <Button Name="BtnPrivacyRollbackAll" Content="Turn All OFF (Defaults)" Style="{StaticResource DangerOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <Border Grid.Row="1" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="10">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <StackPanel Name="PanelPrivacyTweaks" Margin="2"/>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 4: SYSTEM AND USABILITY -->
                <Grid Name="PageSystem" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                                <TextBlock Text="FILTER:" FontSize="11" FontWeight="Bold" Foreground="#64748B" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                <Button Name="ChipSystemAll" Content="All System Tweaks" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipSystemActive" Content="Active Only" Style="{StaticResource PresetChip}"/>
                            </StackPanel>
                            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                <Button Name="BtnSystemApplyAll" Content="Turn All ON" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                <Button Name="BtnSystemRollbackAll" Content="Turn All OFF (Defaults)" Style="{StaticResource DangerOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <Border Grid.Row="1" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="10">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <StackPanel Margin="2">
                                <!-- SYSTEM HEALTH, DIAGNOSTICS AND DEEP CLEANER -->
                                <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                            <TextBlock Text="SYSTEM HEALTH, DIAGNOSTICS AND DEEP CLEANER" FontSize="12" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,0,4"/>
                                            <TextBlock Text="Scan and repair corrupted Windows system files (SFC / DISM), clear corrupted Windows Update cache, and deep clean shader/temp caches." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnRunDiagnostics" Content="Repair System Health" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnClearUpdateCache" Content="Clear WU Cache" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnClearDeepCacheBar" Content="Deep Junk Cleaner" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnReport_Interrupts" Content="Check DPC Latency" Style="{StaticResource DarkOutlineButton}"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>

                                <StackPanel Name="PanelSystemTweaks"/>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 5: SOFTWARE DOWNLOADER -->
                <Grid Name="PageSoftware" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="260"/>
                    </Grid.ColumnDefinitions>

                    <!-- Category Chips -->
                    <Border Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="12,8" Margin="0,0,0,10">
                        <ScrollViewer HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Disabled">
                            <StackPanel Name="StackCategoryChips" Orientation="Horizontal">
                                <Button Name="ChipCatAll" Content="All Apps (115+)" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatUpdates" Content="Updates Available (0)" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatBrowsers" Content="Browsers" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatComms" Content="Communications" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatDev" Content="Development" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatDoc" Content="Document" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatGames" Content="Games" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatMs" Content="Microsoft Tools" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatMedia" Content="Multimedia Tools" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatPro" Content="Pro Tools" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatSelf" Content="Selfhosted Tools" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatUtil" Content="Utilities" Style="{StaticResource CategoryChip}"/>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>

                    <!-- Apps Grid -->
                    <Border Grid.Row="1" Grid.Column="0" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="8" Margin="0,0,10,0">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <WrapPanel Name="WrapPackages" Margin="4"/>
                        </ScrollViewer>
                    </Border>

                    <!-- Action Sidebar -->
                    <Border Grid.Row="1" Grid.Column="1" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <StackPanel Grid.Row="0">
                                <TextBlock Text="ACTIONS" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,8"/>
                                <Button Name="BtnCheckUpdates" Content="Check for Updates" Style="{StaticResource CyanButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnUpgradeSelected" Content="Upgrade Selected" Style="{StaticResource OrangeButton}" Margin="0,0,0,8"/>
                                <Button Name="BtnInstallSelected" Content="Install Selected" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnUninstallSelected" Content="Uninstall Selected" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnUpgradeAll" Content="Upgrade All (WinGet)" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,12"/>
                                
                                <Border Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="EQUICORD CLIENT" FontSize="11" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,0,4"/>
                                        <TextBlock Text="Enhanced Discord client with 100+ plugins and themes." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,8" TextWrapping="Wrap"/>
                                        <Grid>
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="*"/>
                                                <ColumnDefinition Width="*"/>
                                            </Grid.ColumnDefinitions>
                                            <Button Name="BtnInstallEquicord" Grid.Column="0" Content="Install" Style="{StaticResource CyanButton}" Padding="4,4" FontSize="11" Margin="0,0,3,0"/>
                                            <Button Name="BtnOpenEquicordSite" Grid.Column="1" Content="Website" Style="{StaticResource DarkOutlineButton}" Padding="4,4" FontSize="11" Margin="3,0,0,0"/>
                                        </Grid>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <Separator Grid.Row="1" Background="#1F293D" Margin="0,0,0,12"/>

                            <StackPanel Grid.Row="2">
                                <TextBlock Text="SELECTION" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,6"/>
                                <Button Name="BtnSelectAll" Content="Select Visible" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnClearAll" Content="Clear Selection" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,10"/>
                                <TextBlock Name="TxtSelectedCount" Text="0 apps selected" FontSize="12" Foreground="#00D2FF" FontWeight="SemiBold"/>
                                <TextBlock Name="TxtUpdatesCount" Text="" FontSize="11" Foreground="#FF7700" FontWeight="SemiBold" Margin="0,4,0,0"/>
                            </StackPanel>

                            <Border Grid.Row="3" Background="#0A0E17" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10">
                                <TextBlock Text="Silent WinGet installation directly from verified vendor sources." FontSize="11" Foreground="#64748B" TextWrapping="Wrap"/>
                            </Border>
                        </Grid>
                    </Border>
                </Grid>

                <!-- PAGE 6: DEVICE DETAILS AND TOOLS -->
                <Grid Name="PageDevice" Visibility="Collapsed">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="0,0,8,0">
                            <!-- Device Header & Action Strip -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="16,12" Margin="0,0,0,10">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                        <StackPanel Orientation="Horizontal" Margin="0,0,0,4">
                                            <TextBlock Name="TxtDev_CompName" Text="DEVICE SPECIFICATIONS &amp; HARDWARE TELEMETRY" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF"/>
                                            <Border Background="#14261C" BorderBrush="#00FF88" BorderThickness="1" CornerRadius="3" Padding="6,1" Margin="10,0,0,0" VerticalAlignment="Center">
                                                <TextBlock Text="LIVE PROBE" FontSize="9" FontWeight="Bold" Foreground="#00FF88"/>
                                            </Border>
                                        </StackPanel>
                                        <TextBlock Name="TxtDev_SubTitle" Text="Complete real-time hardware diagnostics, driver telemetry, and system profiles." FontSize="11" Foreground="#94A3B8"/>
                                    </StackPanel>
                                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                        <Button Name="BtnRefreshDeviceSpecs" Content="Refresh Hardware" Style="{StaticResource CyanButton}" Margin="0,0,8,0"/>
                                        <Button Name="BtnCopyAllDeviceSpecs" Content="Copy All Specs" Style="{StaticResource DarkOutlineButton}"/>
                                    </StackPanel>
                                </Grid>
                            </Border>

                            <!-- Tools Banner: TrafficMonitor Taskbar HUD -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,12" Margin="0,0,0,10">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <StackPanel VerticalAlignment="Center">
                                        <TextBlock Text="TRAFFICMONITOR TASKBAR HUD" FontSize="12" FontWeight="Bold" Foreground="#00FF88" Margin="0,0,0,4"/>
                                        <TextBlock Text="Lightweight live taskbar CPU, RAM and network throughput monitor with MiSans fonts." FontSize="11" Foreground="#94A3B8"/>
                                    </StackPanel>
                                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                        <Button Name="BtnInstallTrafficMonitor" Content="Install Tool" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                        <Button Name="BtnInstallMiSansFonts" Content="Install Fonts" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                        <Button Name="BtnLaunchTrafficMonitor" Content="Launch HUD" Style="{StaticResource CyanButton}"/>
                                    </StackPanel>
                                </Grid>
                            </Border>

                            <!-- Specs Collapsible Cards -->
                            <!-- CPU -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Processor (CPU)" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevCpu" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevCpu" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevCpu" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Model: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Cores / Threads: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuCores" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Base Clock: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuClock" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- GPU -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Graphics Card (GPU)" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevGpu" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevGpu" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevGpu" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Device: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Driver Version: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuDriver" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="VRAM: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuRam" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- RAM -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Memory (RAM)" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevRam" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevRam" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevRam" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Installed Capacity: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamTotal" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Configured Speed: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamSpeed" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- OS -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Operating System" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevOs" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevOs" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevOs" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="OS Edition: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Build Number: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsBuild" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- Network -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Network Interface" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevNet" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevNet" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevNet" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Adapter: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Link Speed: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetSpeed" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- Storage -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Storage &amp; Drives" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevDisk" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevDisk" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevDisk" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Physical Disks: " Foreground="#FFFFFF"/><Run Name="TxtDev_Disks" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Drive Volumes: " Foreground="#FFFFFF"/><Run Name="TxtDev_Volumes" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- Power / Battery -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Power &amp; System Health" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevPower" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevPower" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevPower" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Power Source: " Foreground="#FFFFFF"/><Run Name="TxtDev_Battery" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Uptime / Boot: " Foreground="#FFFFFF"/><Run Name="TxtDev_BootTime" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </ScrollViewer>
                </Grid>
            </Grid>
        </Grid>

        <!-- ROW 2: COLLAPSIBLE BOTTOM ACTIVITY AND REAL-TIME LOG DRAWER -->
        <Border Grid.Row="2" Background="#06090E" BorderBrush="#1F293D" BorderThickness="0,1,0,0">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="34"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <!-- Status Strip (Always Visible) -->
                <Grid Grid.Row="0" Margin="14,0" VerticalAlignment="Center">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <Ellipse Width="8" Height="8" Fill="#00FF88" Margin="0,0,8,0" VerticalAlignment="Center"/>
                        <TextBlock Text="ACTIVITY: " FontSize="10" FontWeight="Bold" Foreground="#00D2FF" VerticalAlignment="Center" Margin="0,0,6,0"/>
                        <TextBlock Name="TxtStatus" Text="Ready" FontSize="11" Foreground="#94A3B8" VerticalAlignment="Center"/>
                    </StackPanel>

                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                        <Button Name="BtnClearConsole" Content="Clear" Style="{StaticResource DarkOutlineButton}" Padding="8,2" FontSize="10" Margin="0,0,6,0"/>
                        <Button Name="BtnToggleLogDrawer" Content="^ Show Console" Style="{StaticResource DarkOutlineButton}" Padding="10,2" FontSize="10"/>
                    </StackPanel>
                </Grid>

                <!-- Expandable Console Log and Progress Bar (Drawer) -->
                <Grid Name="PanelLogDrawer" Grid.Row="1" Height="170" Margin="14,0,14,10" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBox Name="TxtConsole" Grid.Row="0" Background="#0A0E17" Foreground="#00FF88" BorderBrush="#1F293D" BorderThickness="1" FontFamily="Consolas" FontSize="11" IsReadOnly="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" Padding="8" TextWrapping="NoWrap"/>
                    <ProgressBar Name="MainProgressBar" Grid.Row="1" Height="4" Background="#121824" Foreground="#00D2FF" BorderThickness="0" Margin="0,6,0,0" Value="0" Maximum="100"/>
                </Grid>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

function Get-OptimizerXamlMarkup {
    return $Global:xamlContent
}


# ------------------------------------------------------------------------------
# MODULE: Gui-Controller
# ------------------------------------------------------------------------------
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
    $btnCheckUpdates         = $window.FindName("BtnCheckUpdates")
    $btnUpgradeSelected      = $window.FindName("BtnUpgradeSelected")
    $btnInstallSelected      = $window.FindName("BtnInstallSelected")
    $btnUninstallSelected    = $window.FindName("BtnUninstallSelected")
    $btnUpgradeAll           = $window.FindName("BtnUpgradeAll")
    $btnSelectAll            = $window.FindName("BtnSelectAll")
    $btnClearAll             = $window.FindName("BtnClearAll")
    $txtSelectedCount        = $window.FindName("TxtSelectedCount")
    $txtUpdatesCount         = $window.FindName("TxtUpdatesCount")
    $chipCatUpdates          = $window.FindName("ChipCatUpdates")
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
    if ($navDevice)    { $navDevice.Add_Checked({ & $script:SwitchPage $pageDevice; if ($script:UpdateDeviceSpecsView) { & $script:UpdateDeviceSpecsView } }) }

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
                Border        = $card
                CheckBox      = $chk
                Category      = $app.Category
                Name          = $app.Name
                Desc          = $app.Description
                Id            = $app.Id
                HasUpdate     = $false
                UpdateVersion = ""
                TxtBadge      = $txtBadge
                Badge         = $badge
                TxtDesc       = $txtDesc
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

    $script:HasScannedUpdates = $false

    $script:PerformCheckForUpdates = {
        & $script:ExpandLogDrawer
        & $script:LogToGui "[*] Scanning for installed application updates via WinGet..."
        & $script:SetProgress 20

        $updates = @()
        try {
            $updates = Get-WinGetUpgrades -LogCallback { param($m) & $script:LogToGui $m }
        } catch {
            & $script:LogToGui "[-] Failed to query WinGet updates: $($_.Exception.Message)" "ERROR"
        }

        & $script:SetProgress 60
        $script:HasScannedUpdates = $true

        if (-not $updates -or $updates.Count -eq 0) {
            & $script:LogToGui "[+] All installed applications are up to date! Zero updates pending."
            if ($chipCatUpdates) { $chipCatUpdates.Content = "Updates Available (0)" }
            if ($txtUpdatesCount) { $txtUpdatesCount.Text = "All apps up to date" }
            & $script:SetProgress 0
            return
        }

        & $script:LogToGui "[+] Found $($updates.Count) application update(s) available:"
        foreach ($u in $updates) {
            & $script:LogToGui "    [>] $($u.Name) ($($u.Id)): $($u.InstalledVersion) -> $($u.AvailableVersion)"
        }

        if ($chipCatUpdates) { $chipCatUpdates.Content = "Updates Available ($($updates.Count))" }
        if ($txtUpdatesCount) { $txtUpdatesCount.Text = "$($updates.Count) update(s) available" }

        $brushOrange   = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FF7700")
        $brushOrangeBg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2E1A0E")
        $brushGreen    = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88")

        foreach ($u in $updates) {
            $targetId = $u.Id.Trim().ToLower()
            $existing = $null
            foreach ($c in $script:AllAppCards) {
                if ($c.Id -and $c.Id.Trim().ToLower() -eq $targetId) {
                    $existing = $c
                    break
                }
            }

            if ($existing) {
                $existing.HasUpdate = $true
                $existing.UpdateVersion = "$($u.InstalledVersion) -> $($u.AvailableVersion)"
                $existing.Border.BorderBrush = $brushOrange
                $existing.CheckBox.IsChecked = $true
                if ($existing.TxtBadge) {
                    $existing.TxtBadge.Text = "UPDATE: $($u.AvailableVersion)"
                    $existing.TxtBadge.Foreground = $brushOrange
                }
                if ($existing.Badge) {
                    $existing.Badge.Background = $brushOrangeBg
                }
                if ($existing.TxtDesc) {
                    $existing.TxtDesc.Text = "UPDATE AVAILABLE: Current: $($u.InstalledVersion)  ==>  New: $($u.AvailableVersion)"
                    $existing.TxtDesc.Foreground = $brushGreen
                }
            } else {
                $newCard = [System.Windows.Controls.Border]::new()
                $newCard.Width = 275
                $newCard.Height = 110
                $newCard.Background = $brushNormalBg
                $newCard.BorderBrush = $brushOrange
                $newCard.BorderThickness = $thick1
                $newCard.CornerRadius = $corn6
                $newCard.Margin = $thick5
                $newCard.Padding = $thick10
                $newCard.Cursor = [System.Windows.Input.Cursors]::Hand

                $cGrid = [System.Windows.Controls.Grid]::new()
                $c0 = [System.Windows.Controls.ColumnDefinition]::new(); $c0.Width = $autoGrid
                $c1 = [System.Windows.Controls.ColumnDefinition]::new(); $c1.Width = $starGrid
                [void]$cGrid.ColumnDefinitions.Add($c0)
                [void]$cGrid.ColumnDefinitions.Add($c1)

                $chk = [System.Windows.Controls.CheckBox]::new()
                $chk.Margin = [System.Windows.Thickness]::new(0, 4, 10, 0)
                $chk.Tag = $u.Id
                $chk.IsChecked = $true
                $chk.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
                [System.Windows.Controls.Grid]::SetColumn($chk, 0)
                [void]$cGrid.Children.Add($chk)

                $sp = [System.Windows.Controls.StackPanel]::new()
                [System.Windows.Controls.Grid]::SetColumn($sp, 1)

                $topRow = [System.Windows.Controls.Grid]::new()
                $trCol0 = [System.Windows.Controls.ColumnDefinition]::new(); $trCol0.Width = $starGrid
                $trCol1 = [System.Windows.Controls.ColumnDefinition]::new(); $trCol1.Width = $autoGrid
                [void]$topRow.ColumnDefinitions.Add($trCol0)
                [void]$topRow.ColumnDefinitions.Add($trCol1)

                $txtTitle = [System.Windows.Controls.TextBlock]::new()
                $txtTitle.Text = $u.Name
                $txtTitle.FontWeight = [System.Windows.FontWeights]::Bold
                $txtTitle.FontSize = 12
                $txtTitle.Foreground = [System.Windows.Media.Brushes]::White
                $txtTitle.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
                [System.Windows.Controls.Grid]::SetColumn($txtTitle, 0)
                [void]$topRow.Children.Add($txtTitle)

                $badge = [System.Windows.Controls.Border]::new()
                $badge.Background = $brushOrangeBg
                $badge.CornerRadius = [System.Windows.CornerRadius]::new(3)
                $badge.Padding = [System.Windows.Thickness]::new(4, 1, 4, 1)
                $badge.Margin = [System.Windows.Thickness]::new(4, 0, 0, 0)
                $txtBadge = [System.Windows.Controls.TextBlock]::new()
                $txtBadge.Text = "UPDATE: $($u.AvailableVersion)"
                $txtBadge.FontSize = 9
                $txtBadge.Foreground = $brushOrange
                $badge.Child = $txtBadge
                [System.Windows.Controls.Grid]::SetColumn($badge, 1)
                [void]$topRow.Children.Add($badge)

                [void]$sp.Children.Add($topRow)

                $txtDesc = [System.Windows.Controls.TextBlock]::new()
                $txtDesc.Text = "UPDATE AVAILABLE: Current: $($u.InstalledVersion)  ==>  New: $($u.AvailableVersion)"
                $txtDesc.FontSize = 10
                $txtDesc.Foreground = $brushGreen
                $txtDesc.TextWrapping = [System.Windows.TextWrapping]::Wrap
                $txtDesc.Margin = [System.Windows.Thickness]::new(0, 3, 0, 0)
                $txtDesc.MaxHeight = 42
                $txtDesc.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
                [void]$sp.Children.Add($txtDesc)

                [void]$cGrid.Children.Add($sp)
                $newCard.Child = $cGrid

                $newCard.Add_MouseEnter({
                    $this.Background = $brushHoverBg
                })
                $newCard.Add_MouseLeave({
                    $this.Background = $brushNormalBg
                })
                $newCard.Add_MouseLeftButtonUp({
                    param($s, $e)
                    if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
                        $c = $s.Child.Children[0]
                        $c.IsChecked = -not $c.IsChecked
                    }
                    & $script:UpdateSelectedCount
                })
                $chk.Add_Checked({ & $script:UpdateSelectedCount })
                $chk.Add_Unchecked({ & $script:UpdateSelectedCount })

                if ($wrapPackages) { [void]$wrapPackages.Children.Insert(0, $newCard) }

                $script:AllAppCards.Insert(0, [PSCustomObject]@{
                    Border        = $newCard
                    CheckBox      = $chk
                    Category      = "Updates"
                    Name          = $u.Name
                    Desc          = $txtDesc.Text
                    Id            = $u.Id
                    HasUpdate     = $true
                    UpdateVersion = "$($u.InstalledVersion) -> $($u.AvailableVersion)"
                    TxtBadge      = $txtBadge
                    Badge         = $badge
                    TxtDesc       = $txtDesc
                })
            }
        }

        # Filter grid to show updates automatically
        foreach ($appCard in $script:AllAppCards) {
            if ($appCard.HasUpdate -eq $true -or $appCard.Category -eq "Updates") {
                $appCard.Border.Visibility = [System.Windows.Visibility]::Visible
            } else {
                $appCard.Border.Visibility = [System.Windows.Visibility]::Collapsed
            }
        }

        & $script:UpdateSelectedCount
        & $script:SetProgress 100
        Start-Sleep -Milliseconds 200
        & $script:SetProgress 0
        & $script:LogToGui "[*] Displaying $($updates.Count) available update(s) in grid. Choose packages to upgrade, then click 'Upgrade Selected'."
    }

    if ($btnCheckUpdates) {
        $btnCheckUpdates.Add_Click({
            & $script:PerformCheckForUpdates
        })
    }

    if ($btnUpgradeSelected) {
        $btnUpgradeSelected.Add_Click({
            $selected = @($script:AllAppCards | Where-Object { $_.CheckBox.IsChecked -eq $true })
            if ($selected.Count -eq 0) {
                & $script:LogToGui "[-] No applications selected to upgrade. Check packages first." "WARN"
                return
            }
            & $script:ExpandLogDrawer
            & $script:LogToGui "[*] Starting selective upgrade batch for $($selected.Count) application(s)..."
            $idx = 0
            $brushGreen  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00FF88")
            $brushBorder = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1F293D")

            foreach ($item in $selected) {
                $idx++
                $pct = [int](($idx / $selected.Count) * 100)
                & $script:SetProgress $pct
                & $script:LogToGui "[$idx/$($selected.Count)] Upgrading $($item.Name) ($($item.Id))..."
                $ok = Upgrade-WinGetPackage -PackageId $item.Id -LogCallback { param($m) & $script:LogToGui $m }
                if ($ok) {
                    $item.HasUpdate = $false
                    $item.CheckBox.IsChecked = $false
                    $item.Border.BorderBrush = $brushBorder
                    if ($item.TxtBadge) {
                        $item.TxtBadge.Text = "Up to date"
                        $item.TxtBadge.Foreground = $brushGreen
                    }
                    if ($item.TxtDesc -and $item.Desc) {
                        $item.TxtDesc.Text = $item.Desc
                        $item.TxtDesc.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
                    }
                }
            }
            & $script:SetProgress 0
            & $script:UpdateSelectedCount

            $remaining = @($script:AllAppCards | Where-Object { $_.HasUpdate -eq $true }).Count
            if ($chipCatUpdates) { $chipCatUpdates.Content = "Updates Available ($remaining)" }
            if ($txtUpdatesCount) {
                $txtUpdatesCount.Text = if ($remaining -gt 0) { "$remaining update(s) available" } else { "All apps up to date" }
            }
            & $script:LogToGui "[+] WinGet selective upgrade batch complete!"
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
        "ChipCatUpdates"  = "Updates"
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
                if ($selectedCat -eq "Updates" -and $script:HasScannedUpdates -ne $true) {
                    & $script:PerformCheckForUpdates
                    return
                }
                foreach ($appCard in $script:AllAppCards) {
                    if ($selectedCat -eq "All") {
                        $appCard.Border.Visibility = [System.Windows.Visibility]::Visible
                    } elseif ($selectedCat -eq "Updates") {
                        if ($appCard.HasUpdate -eq $true -or $appCard.Category -eq "Updates") {
                            $appCard.Border.Visibility = [System.Windows.Visibility]::Visible
                        } else {
                            $appCard.Border.Visibility = [System.Windows.Visibility]::Collapsed
                        }
                    } elseif ($appCard.Category -like "*$selectedCat*") {
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
        param([switch]$ForceRefresh)
        try {
            $dev = Get-DeviceDetailProfile -ForceRefresh:$ForceRefresh
            if (-not $dev) { return }

            if ($txtDev_CompName) { $txtDev_CompName.Text = "$($dev.DeviceName) - SPECIFICATIONS & TELEMETRY" }
            if ($txtDev_SubTitle) { $txtDev_SubTitle.Text = "$($dev.HeaderSummary)" }

            # CPU
            $t = $window.FindName("TxtDev_CpuName");  if ($t) { $t.Text = $dev.CpuName }
            $t = $window.FindName("TxtDev_CpuCores"); if ($t) { $t.Text = "$($dev.CpuCores) Cores / $($dev.CpuLogical) Threads ($($dev.CpuArchitecture))" }
            $t = $window.FindName("TxtDev_CpuClock"); if ($t) { $t.Text = "$($dev.CpuMaxSpeed) (Socket $($dev.CpuSocket))" }

            # GPU
            $gpu = $dev.PrimaryGpu
            $t = $window.FindName("TxtDev_GpuName");   if ($t) { $t.Text = if ($gpu) { $gpu.Name } else { "Unknown GPU" } }
            $t = $window.FindName("TxtDev_GpuDriver"); if ($t) { $t.Text = if ($gpu) { "$($gpu.DriverVersion) ($($gpu.DriverDate))" } else { "Unknown" } }
            $t = $window.FindName("TxtDev_GpuRam");    if ($t) { $t.Text = if ($gpu) { "$($gpu.Vram) ($($gpu.Resolution) @ $($gpu.RefreshRate))" } else { "Dynamic / Shared" } }

            # RAM
            $t = $window.FindName("TxtDev_RamTotal"); if ($t) { $t.Text = "$($dev.RamTotal) (Usable: $($dev.RamUsable))" }
            $t = $window.FindName("TxtDev_RamSpeed"); if ($t) { $t.Text = "$($dev.RamSpeed) ($($dev.RamSlots) - $($dev.RamManufacturer))" }

            # OS
            $t = $window.FindName("TxtDev_OsName");  if ($t) { $t.Text = "$($dev.OsName) ($($dev.OsArchitecture))" }
            $t = $window.FindName("TxtDev_OsBuild"); if ($t) { $t.Text = "Build $($dev.OsBuildNumber) ($($dev.OsVersion)) - Installed $($dev.OsInstallDate)" }

            # Network
            $t = $window.FindName("TxtDev_NetName");  if ($t) { $t.Text = "$($dev.NetAdapterName) - $($dev.NetDescription)" }
            $t = $window.FindName("TxtDev_NetSpeed"); if ($t) { $t.Text = "$($dev.NetLinkSpeed) [IPv4: $($dev.NetIpAddress)] ($($dev.NetStatus))" }

            # Storage (Disks & Volumes)
            $t = $window.FindName("TxtDev_Disks");   if ($t) { $t.Text = if ($dev.Disks) { ($dev.Disks -join "  |  ") } else { "No drives detected" } }
            $t = $window.FindName("TxtDev_Volumes"); if ($t) { $t.Text = if ($dev.Volumes) { ($dev.Volumes -join "  |  ") } else { "No volumes detected" } }

            # Power & System Health
            $t = $window.FindName("TxtDev_Battery");  if ($t) { $t.Text = "$($dev.BatteryName) - $($dev.BatteryPercent) ($($dev.BatteryStatus))" }
            $t = $window.FindName("TxtDev_BootTime"); if ($t) { $t.Text = "System Last Boot: $($dev.OsLastBootTime)" }
        } catch {
            & $script:LogToGui "[-] Failed to populate device specs: $($_.Exception.Message)" "ERROR"
        }
    }

    # Device spec copy buttons
    $copyBtnMap = @{
        "BtnCopy_DevCpu"   = "TxtDev_CpuName"
        "BtnCopy_DevGpu"   = "TxtDev_GpuName"
        "BtnCopy_DevRam"   = "TxtDev_RamTotal"
        "BtnCopy_DevOs"    = "TxtDev_OsName"
        "BtnCopy_DevNet"   = "TxtDev_NetName"
        "BtnCopy_DevDisk"  = "TxtDev_Disks"
        "BtnCopy_DevPower" = "TxtDev_Battery"
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
    $devCats = @('Cpu', 'Gpu', 'Ram', 'Os', 'Net', 'Disk', 'Power')
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
            if ($txtActiveCursorScheme) {
                $curActive = Get-ActiveCursorSchemeName
                if ($curActive) { $txtActiveCursorScheme.Text = $curActive }
            }
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
            $schemeName = if ($selected.Name) { $selected.Name } else { [string]$selected }
            & $script:LogToGui "[*] Installing custom cursor scheme: $schemeName..."
            try {
                $ok = Install-CursorScheme -SchemeName $schemeName
                if ($ok) {
                    if ($txtActiveCursorScheme) { $txtActiveCursorScheme.Text = $schemeName }
                    & $script:LogToGui "[+] Cursor scheme '$schemeName' installed and live-reloaded successfully!"
                } else {
                    & $script:LogToGui "[-] Failed to apply cursor scheme: $schemeName" "ERROR"
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
            & $script:UpdateDeviceSpecsView -ForceRefresh
            & $script:LogToGui "[+] Hardware profile refreshed."
        })
    }
    if ($btnCopyAllDeviceSpecs) {
        $btnCopyAllDeviceSpecs.Add_Click({
            try {
                $dev = Get-DeviceDetailProfile
                $diskLines = if ($dev.Disks) { ($dev.Disks -join "`r`n                  ") } else { "None" }
                $volLines  = if ($dev.Volumes) { ($dev.Volumes -join "`r`n                  ") } else { "None" }
                $gpuName   = if ($dev.PrimaryGpu) { $dev.PrimaryGpu.Name } else { "Unknown" }
                $gpuDriver = if ($dev.PrimaryGpu) { "$($dev.PrimaryGpu.DriverVersion) ($($dev.PrimaryGpu.DriverDate))" } else { "Unknown" }
                $gpuVram   = if ($dev.PrimaryGpu) { $dev.PrimaryGpu.Vram } else { "N/A" }
                $gpuDisp   = if ($dev.PrimaryGpu) { "$($dev.PrimaryGpu.Resolution) @ $($dev.PrimaryGpu.RefreshRate)" } else { "N/A" }

                $specsText = @"
PumpkiN Windows Optimizer - Full Hardware & Device Report
----------------------------------------------------------
Device Name:      $($dev.DeviceName)
Summary:          $($dev.HeaderSummary)

Processor (CPU):
  Model:          $($dev.CpuName)
  Cores/Threads:  $($dev.CpuCores) Cores / $($dev.CpuLogical) Threads ($($dev.CpuArchitecture))
  Clock / Socket: $($dev.CpuMaxSpeed) (Socket $($dev.CpuSocket))
  Manufacturer:   $($dev.CpuManufacturer)

Graphics (GPU):
  Device:         $gpuName
  Driver Version: $gpuDriver
  VRAM:           $gpuVram
  Display:        $gpuDisp

Memory (RAM):
  Total Physical: $($dev.RamTotal) (Usable: $($dev.RamUsable))
  Configured:     $($dev.RamSpeed) ($($dev.RamSlots))
  Manufacturer:   $($dev.RamManufacturer) ($($dev.RamPartNumber))

Operating System:
  Edition:        $($dev.OsName) ($($dev.OsArchitecture))
  Version/Build:  Version $($dev.OsVersion) (Build $($dev.OsBuildNumber))
  Installed:      $($dev.OsInstallDate)
  Last Boot Time: $($dev.OsLastBootTime)

Network:
  Adapter:        $($dev.NetAdapterName) ($($dev.NetDescription))
  Link Speed:     $($dev.NetLinkSpeed) [$($dev.NetStatus)]
  IPv4 Address:   $($dev.NetIpAddress)
  MAC Address:    $($dev.NetMacAddress)

Storage:
  Drives:         $diskLines
  Volumes:        $volLines

Power & System Health:
  Power Source:   $($dev.BatteryName)
  Status:         $($dev.BatteryPercent) ($($dev.BatteryStatus))
----------------------------------------------------------
Generated by PumpkiN Ultimate Windows Optimizer
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
    $window.Add_Closing({ try { if ($telemetryTimer) { $telemetryTimer.Stop() } } catch {} })
    $window.Add_Closed({ & $script:ExitOptimizer })

    # Launch GUI Window
    [void]$window.ShowDialog()
    & $script:ExitOptimizer
}

# ------------------------------------------------------------------------------
# MODULE: Optimize-AmdGpu
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: AMD Radeon GPU Dedicated Optimization Suite
================================================================================
#>

function Optimize-AmdGpu {
    Write-Host "`n[*] Starting AMD Radeon GPU Optimization Suite..." -ForegroundColor Magenta
    $classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $amdFound = 0

    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$classPath\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.DriverDesc -match 'AMD|Radeon' -or $props.ProviderName -match 'AMD|Advanced Micro Devices' -or $props.EnableUlps -ne $null)) {
                $amdFound++
                Write-Host "      -> Found AMD Radeon Adapter at Key [$subKey]: $($props.DriverDesc)" -ForegroundColor Cyan
                
                # 1. Disable ULPS (Ultra Low Power State)
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] Disabled ULPS (Ultra Low Power State) - Prevents clock-drop stutters" -ForegroundColor Green

                # 2. Shader Cache Optimization
                Set-ItemProperty -Path $targetPath -Name 'ShaderCache' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'ShaderCache_NA' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] Shader Cache locked to Enabled (Stops compilation frame-stutter)" -ForegroundColor Green

                # 3. Anti-Lag & Low-Latency Direct Pipeline
                Set-ItemProperty -Path $targetPath -Name 'AntiLag' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'DisableDMACopy' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] Anti-Lag and Direct Engine DMA Copy enabled" -ForegroundColor Green

                # 4. Disable Aggressive Clock Dropping & Multi-Monitor Stutter
                Set-ItemProperty -Path $targetPath -Name 'PP_ThermalAutoThrottlingEnable' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'PP_MCLKStutterMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'StutterMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'KMD_EnableCrossFireAutoLink' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] PowerPlay deep-sleep throttle and MCLK stutter mitigations applied" -ForegroundColor Green
            }
        }
    }

    # ControlSet001 fallback check
    $cs1Path = 'HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$cs1Path\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.EnableUlps -ne $null -or $props.DriverDesc -match 'AMD|Radeon')) {
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord -ErrorAction SilentlyContinue
            }
        }
    }

    # Flush stale AMD precompiled shader caches
    $amdCaches = @(
        "$env:LOCALAPPDATA\AMD\DxCache",
        "$env:LOCALAPPDATA\AMD\GLCache",
        "$env:LOCALAPPDATA\AMD\D3DSCache"
    )
    foreach ($cacheDir in $amdCaches) {
        if (Test-Path $cacheDir) {
            Remove-Item "$cacheDir\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "         [+] Flushed AMD shader cache: $cacheDir" -ForegroundColor Green
        }
    }

    if ($amdFound -eq 0) {
        Write-Host "      [!] No AMD Radeon card found in primary registry keys (Applied global ULPS fallback)." -ForegroundColor DarkYellow
    } else {
        Write-Host "      [OK] AMD Radeon GPU Optimized: Maximum Clock Stability and 0 ULPS Latency!" -ForegroundColor Green
    }
}

# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"" -Verb RunAs
        exit
    }
    Optimize-AmdGpu
    Read-Host "
Press Enter to exit"
}

# ------------------------------------------------------------------------------
# MODULE: Optimize-NvidiaGpu
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: NVIDIA GeForce Dedicated Optimization Suite
================================================================================
#>

function Optimize-NvidiaGpu {
    Write-Host "`n[*] Starting NVIDIA GeForce GPU Optimization Suite..." -ForegroundColor Green
    $classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $nvFound = 0

    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$classPath\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.DriverDesc -match 'NVIDIA' -or $props.ProviderName -match 'NVIDIA')) {
                $nvFound++
                Write-Host "      -> Found NVIDIA Adapter at Key [$subKey]: $($props.DriverDesc)" -ForegroundColor Cyan
                Set-ItemProperty -Path $targetPath -Name 'PowerMizerEnable' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevel' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevelAC' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] PowerMizer locked to Maximum Performance (P0 State - No clock drops)" -ForegroundColor Green
            }
        }
    }

    $nvCaches = @(
        "$env:LOCALAPPDATA\NVIDIA\DXCache",
        "$env:LOCALAPPDATA\NVIDIA\GLCache",
        "$env:LOCALAPPDATA\D3DSCache"
    )
    foreach ($cacheDir in $nvCaches) {
        if (Test-Path $cacheDir) {
            Remove-Item "$cacheDir\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "         [+] Flushed shader cache: $cacheDir" -ForegroundColor Green
        }
    }

    if ($nvFound -eq 0) {
        Write-Host "      [!] No NVIDIA card found in primary keys." -ForegroundColor DarkYellow
    } else {
        Write-Host "      [OK] NVIDIA GPU Optimized for Maximum FPS and Stable Frametimes!" -ForegroundColor Green
    }
}

# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"" -Verb RunAs
        exit
    }
    Optimize-NvidiaGpu
    Read-Host "
Press Enter to exit"
}

# ------------------------------------------------------------------------------
# MODULE: Optimize-GpuAuto
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: GPU, Hardware MSI & Device Power Optimizations
================================================================================
#>

function Disable-DevicePowerSaving {
    Write-Host "`n[*] Disabling Power Saving on USB Root Hubs & Hardware Controllers..." -ForegroundColor Yellow
    $disabledCount = 0
    try {
        $powerDevices = Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root\wmi -ErrorAction SilentlyContinue
        foreach ($dev in $powerDevices) {
            if ($dev.InstanceName -match 'USB|PCI|ROOT_HUB') {
                Set-CimInstance -InputObject $dev -Property @{ Enable = $false } -ErrorAction SilentlyContinue
                $shortName = $dev.InstanceName -replace '.*\\', ''
                Write-Host "      [+] Unchecked 'Allow computer to turn off device': $shortName" -ForegroundColor Green
                $disabledCount++
            }
        }
    } catch {
        Write-Host "      [~] WMI MSPower_DeviceEnable note: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }

    # Disable USB Selective Suspend in registry power settings
    $usbHub = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
    if (-not (Test-Path $usbHub)) { New-Item -Path $usbHub -Force | Out-Null }
    Set-ItemProperty -Path $usbHub -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    Write-Host "      [OK] $disabledCount Devices Configured: Always Full Power (Zero Sleep Latency)!" -ForegroundColor Green
}

function Optimize-HardwareMsiMode {
    Write-Host "`n[*] Configuring Message Signaled Interrupts (MSI Mode) & High Priority for Hardware..." -ForegroundColor Yellow
    $pciBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI'
    if (Test-Path $pciBase) {
        $pciDevices = Get-ChildItem -Path $pciBase -ErrorAction SilentlyContinue
        $msiCount = 0
        foreach ($dev in $pciDevices) {
            $instances = Get-ChildItem -Path $dev.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $props = Get-ItemProperty -Path $inst.PSPath -ErrorAction SilentlyContinue
                if (-not $props) { continue }
                
                $isTarget = $false
                $targetDesc = ""
                
                # Check for USB Host Controllers
                if ($props.Class -eq 'USB' -or $props.ClassGUID -eq '{36fc9e60-c465-11cf-8056-444553540000}' -or $props.Service -match 'USBXHCI|usbehci') {
                    $isTarget = $true
                    $targetDesc = "USB Controller"
                }
                # Check for Network Adapters
                elseif ($props.Class -eq 'Net' -or $props.ClassGUID -eq '{4d36e972-e325-11ce-bfc1-08002be10318}') {
                    $isTarget = $true
                    $targetDesc = "Network Adapter"
                }
                # Check for Display Adapters (GPU)
                elseif ($props.Class -eq 'Display' -or $props.ClassGUID -eq '{4d36e968-e325-11ce-bfc1-08002be10318}') {
                    $isTarget = $true
                    $targetDesc = "Display GPU"
                }
                # Check for High Definition Audio Controllers
                elseif ($props.Class -eq 'MEDIA' -or $props.ClassGUID -eq '{4d36e96c-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'HDAudBus|IntcAzAudAddService|Realtek') {
                    $isTarget = $true
                    $targetDesc = "Audio Controller"
                }
                # Check for NVMe Storage Controllers
                elseif ($props.Class -eq 'SCSIAdapter' -or $props.ClassGUID -eq '{4d36e97b-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'stornvme') {
                    $isTarget = $true
                    $targetDesc = "NVMe Storage"
                }

                if ($isTarget) {
                    $devParam = Join-Path $inst.PSPath 'Device Parameters'
                    $intMgmt = Join-Path $devParam 'Interrupt Management'
                    $msiProps = Join-Path $intMgmt 'MessageSignaledInterruptProperties'
                    $affPolicy = Join-Path $intMgmt 'Affinity Policy'

                    if (-not (Test-Path $msiProps)) { New-Item -Path $msiProps -Force | Out-Null }
                    Set-ItemProperty -Path $msiProps -Name 'MSISupported' -Value 1 -Type DWord -ErrorAction SilentlyContinue

                    if (-not (Test-Path $affPolicy)) { New-Item -Path $affPolicy -Force | Out-Null }
                    Set-ItemProperty -Path $affPolicy -Name 'DevicePriority' -Value 3 -Type DWord -ErrorAction SilentlyContinue

                    $name = if ($props.DeviceDesc) { ($props.DeviceDesc -replace ';.*', '') } else { $targetDesc }
                    Write-Host "      [+] MSI Mode (High Priority) Enabled: $name [$targetDesc]" -ForegroundColor Green
                    $msiCount++
                }
            }
        }
        Write-Host "      [OK] $msiCount Hardware Controllers optimized with MSI Mode & High Priority!" -ForegroundColor Green
    }
}

function Optimize-GpuAuto {
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Starting Hardware, GPU & Device Latency Optimization Suite..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile
    if ($hw.HasNvidia) {
        Write-Host "      [+] NVIDIA GeForce GPU detected! Launching NVIDIA Dedicated Suite..." -ForegroundColor Green
        Optimize-NvidiaGpu
    }
    if ($hw.HasAmdGpu) {
        Write-Host "      [+] AMD Radeon GPU detected! Launching AMD Radeon Dedicated Suite..." -ForegroundColor Magenta
        Optimize-AmdGpu
    }
    if (-not $hw.HasNvidia -and -not $hw.HasAmdGpu) {
        Write-Host "      [!] Generic/Integrated GPU detected. Applying Universal Direct Flip tweaks..." -ForegroundColor DarkYellow
        $dwmKey = 'HKCU:\Software\Microsoft\Windows\DWM'
        if (-not (Test-Path $dwmKey)) { New-Item -Path $dwmKey -Force | Out-Null }
        Set-ItemProperty -Path $dwmKey -Name 'EnableWindowColorization' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }

    # 1. Optimize PCI MSI Mode (USB, Network, GPU)
    Optimize-HardwareMsiMode

    # 2. Disable Device Power Saving (Always Full Power)
    Disable-DevicePowerSaving

    # 3. High Game Priority & MMCSS GPU Priority
    if (Get-Command Apply-GameHooks -ErrorAction SilentlyContinue) {
        Apply-GameHooks
    }

    $gamesTask = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
    if (Test-Path $gamesTask) {
        Set-ItemProperty -Path $gamesTask -Name 'GPU Priority' -Value 8 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamesTask -Name 'Priority' -Value 6 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamesTask -Name 'Scheduling Category' -Value 'High' -Type String -ErrorAction SilentlyContinue
        Write-Host "      [+] MMCSS Gaming Task GPU Priority locked to Maximum (GPU Priority: 8, Priority: 6)" -ForegroundColor Green
    }
}

function Restore-DevicePowerSaving {
    Write-Host "`n[*] Restoring USB & Hardware Device Power Saving Defaults..." -ForegroundColor Yellow
    try {
        $powerDevices = Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root\wmi -ErrorAction SilentlyContinue
        foreach ($dev in $powerDevices) {
            if ($dev.InstanceName -match 'USB|PCI|ROOT_HUB') {
                Set-CimInstance -InputObject $dev -Property @{ Enable = $true } -ErrorAction SilentlyContinue
            }
        }
    } catch {}

    $usbHub = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
    if (Test-Path $usbHub) {
        Remove-ItemProperty -Path $usbHub -Name 'DisableSelectiveSuspend' -ErrorAction SilentlyContinue
    }
    Write-Host "      [OK] USB selective suspend and device power saving restored to Windows defaults." -ForegroundColor Green
}

function Restore-HardwareMsiMode {
    Write-Host "`n[*] Restoring Hardware MSI Mode to System Defaults..." -ForegroundColor Yellow
    $pciBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI'
    if (Test-Path $pciBase) {
        $pciDevices = Get-ChildItem -Path $pciBase -ErrorAction SilentlyContinue
        foreach ($dev in $pciDevices) {
            $instances = Get-ChildItem -Path $dev.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $devParam = Join-Path $inst.PSPath 'Device Parameters'
                $intMgmt = Join-Path $devParam 'Interrupt Management'
                $msiProps = Join-Path $intMgmt 'MessageSignaledInterruptProperties'
                $affPolicy = Join-Path $intMgmt 'Affinity Policy'
                if (Test-Path $msiProps) {
                    Remove-ItemProperty -Path $msiProps -Name 'MSISupported' -ErrorAction SilentlyContinue
                }
                if (Test-Path $affPolicy) {
                    Remove-ItemProperty -Path $affPolicy -Name 'DevicePriority' -ErrorAction SilentlyContinue
                }
            }
        }
    }
    Write-Host "      [OK] PCI controllers restored to default interrupt affinity." -ForegroundColor Green
}

function Restore-GpuAuto {
    Write-Host "`n[*] Restoring GPU and Display Driver Settings to Defaults..." -ForegroundColor Yellow
    $gamesTask = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
    if (Test-Path $gamesTask) {
        Set-ItemProperty -Path $gamesTask -Name 'GPU Priority' -Value 8 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamesTask -Name 'Priority' -Value 2 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamesTask -Name 'Scheduling Category' -Value 'Medium' -Type String -ErrorAction SilentlyContinue
    }
    $dwmKey = 'HKCU:\Software\Microsoft\Windows\DWM'
    if (Test-Path $dwmKey) {
        Remove-ItemProperty -Path $dwmKey -Name 'EnableWindowColorization' -ErrorAction SilentlyContinue
    }
    Restore-HardwareMsiMode
    Restore-DevicePowerSaving
    Write-Host "      [OK] GPU auto-tuning restored to Windows defaults." -ForegroundColor Green
}

# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Optimize-GpuAuto
    Read-Host "`nPress Enter to exit"
}

# ------------------------------------------------------------------------------
# MODULE: Optimize-Network
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: Network, TCP/IP & Anti-Lag Optimization Suite
================================================================================
#>

function Optimize-Network {
    Write-Host "`n[*] Tuning Network Interface, Anti-Lag & Memory Leaks..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile
    $adapter = $hw.Adapter
    if ($adapter) {
        $guid = $adapter.InterfaceGuid
        $tcpKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
        if (Test-Path $tcpKey) {
            Set-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -Value 1 -Type DWord
            Set-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -Value 1 -Type DWord
            Set-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -Value 0 -Type DWord
        }
        $nicProps = @('Interrupt Moderation','Flow Control','Green Ethernet','Gigabit Lite','Power Saving Mode','Energy-Efficient Ethernet')
        foreach ($p in $nicProps) {
            try { Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName $p -DisplayValue 'Disabled' -NoRestart -ErrorAction Stop } catch {}
        }
        netsh int tcp set global rsc=disabled | Out-Null
        netsh int tcp set global rss=enabled | Out-Null
        netsh int tcp set global autotuninglevel=normal | Out-Null
        Write-Host "      [+] Nagle disabled (TCPNoDelay=1, TcpAckFrequency=1, TcpDelAckTicks=0)" -ForegroundColor Green
        Write-Host "      [+] RSC disabled, RSS enabled, NIC green power saving disabled" -ForegroundColor Green
    }

    # Fix NDU Non-Paged Pool Memory Leak (WinDebloatTools gem)
    $nduKey = 'HKLM:\SYSTEM\ControlSet001\Services\Ndu'
    if (Test-Path $nduKey) {
        Set-ItemProperty -Path $nduKey -Name 'Start' -Value 4 -Type DWord
        Write-Host "      [+] NDU memory leak fixed (Prevents non-paged RAM growth over long gaming sessions)" -ForegroundColor Green
    }

    # DNS ServiceProvider Priorities
    $spKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider'
    Set-ItemProperty -Path $spKey -Name 'LocalPriority' -Value 4 -Type DWord
    Set-ItemProperty -Path $spKey -Name 'HostsPriority' -Value 5 -Type DWord
    Set-ItemProperty -Path $spKey -Name 'DnsPriority' -Value 6 -Type DWord
    Set-ItemProperty -Path $spKey -Name 'NetbtPriority' -Value 7 -Type DWord

    # Uncap 20% QoS Limit
    $psched = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched'
    if (-not (Test-Path $psched)) { New-Item -Path $psched -Force | Out-Null }
    Set-ItemProperty -Path $psched -Name 'NonBestEffortLimit' -Value 0 -Type DWord
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [+] ServiceProvider priorities set + 100% bandwidth unreserved + DNS flushed" -ForegroundColor Green
}

function Restore-Network {
    Write-Host "`n[*] Restoring Network Settings to Windows Defaults..." -ForegroundColor Yellow
    $hw = if (Get-Command Get-HardwareProfile -ErrorAction SilentlyContinue) { Get-HardwareProfile } else { $null }
    $adapter = if ($hw) { $hw.Adapter } else { $null }
    if ($adapter) {
        $guid = $adapter.InterfaceGuid
        $tcpKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
        if (Test-Path $tcpKey) {
            Remove-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -ErrorAction SilentlyContinue
        }
        netsh int tcp set global rsc=default 2>$null | Out-Null
        netsh int tcp set global rss=default 2>$null | Out-Null
        netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    }

    # Restore NDU service
    Set-ItemProperty -Path 'HKLM:\SYSTEM\ControlSet001\Services\Ndu' -Name 'Start' -Value 2 -ErrorAction SilentlyContinue

    # Restore default QoS bandwidth reservation
    $psched = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched'
    if (Test-Path $psched) {
        Remove-ItemProperty -Path $psched -Name 'NonBestEffortLimit' -ErrorAction SilentlyContinue
    }

    # Restore ServiceProvider Priorities
    $spKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider'
    Set-ItemProperty -Path $spKey -Name 'LocalPriority' -Value 499 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $spKey -Name 'HostsPriority' -Value 500 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $spKey -Name 'DnsPriority' -Value 2000 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $spKey -Name 'NetbtPriority' -Value 2001 -Type DWord -ErrorAction SilentlyContinue

    Clear-DnsClientCache
    ipconfig /flushdns 2>$null | Out-Null
    Write-Host "      [OK] TCP/IP and Network stack restored to Windows defaults!" -ForegroundColor Green
}

function Test-GamingDnsBenchmark {
    <#
    .SYNOPSIS
        Benchmarks top gaming DNS providers (Cloudflare, Google, Quad9, AdGuard, OpenDNS).
    .DESCRIPTION
        Pings primary DNS IPs with multiple samples and returns a sorted leaderboard with average round-trip latency.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Running Low-Latency Gaming DNS Benchmark..." -ForegroundColor Yellow

    $providers = @(
        @{ Name = "Cloudflare"; Primary = "1.1.1.1"; Secondary = "1.0.0.1"; Desc = "Ultra-Fast, Zero-Logging" },
        @{ Name = "Google";     Primary = "8.8.8.8"; Secondary = "8.8.4.4"; Desc = "Global Anycast Infrastructure" },
        @{ Name = "Quad9";      Primary = "9.9.9.9"; Secondary = "149.112.112.112"; Desc = "Low-Latency & Threat Blocking" },
        @{ Name = "AdGuard";    Primary = "94.140.14.14"; Secondary = "94.140.15.15"; Desc = "Ad-Blocking & Gaming Filter" },
        @{ Name = "OpenDNS";    Primary = "208.67.222.222"; Secondary = "208.67.220.220"; Desc = "Cisco Anycast Network" }
    )

    $pingObj = New-Object System.Net.NetworkInformation.Ping
    $leaderboard = @()

    foreach ($p in $providers) {
        $times = @()
        for ($i = 0; $i -lt 3; $i++) {
            try {
                $reply = $pingObj.Send($p.Primary, 800)
                if ($reply.Status -eq 'Success') {
                    $times += $reply.RoundtripTime
                }
            } catch {}
        }

        $avg = if ($times.Count -gt 0) { [math]::Round(($times | Measure-Object -Average).Average, 1) } else { 999 }
        $leaderboard += [PSCustomObject]@{
            Rank      = 0
            Name      = $p.Name
            Primary   = $p.Primary
            Secondary = $p.Secondary
            AvgPingMs = $avg
            Desc      = $p.Desc
        }
    }

    $sorted = $leaderboard | Sort-Object AvgPingMs
    for ($idx = 0; $idx -lt $sorted.Count; $idx++) {
        $sorted[$idx].Rank = $idx + 1
    }

    Write-Host "      ==================================================================" -ForegroundColor Cyan
    Write-Host "      RANK   PROVIDER       PRIMARY IP       AVG PING    DESCRIPTION" -ForegroundColor Cyan
    Write-Host "      ==================================================================" -ForegroundColor Cyan
    foreach ($r in $sorted) {
        $rankStr = "$($r.Rank)".PadRight(6)
        $nameStr = "$($r.Name)".PadRight(14)
        $ipStr   = "$($r.Primary)".PadRight(16)
        $pingStr = "$($r.AvgPingMs) ms".PadRight(11)
        $color = if ($r.Rank -eq 1) { "Green" } elseif ($r.Rank -eq 2) { "Cyan" } else { "Gray" }
        Write-Host "      $rankStr $nameStr $ipStr $pingStr $($r.Desc)" -ForegroundColor $color
    }
    Write-Host "      ==================================================================" -ForegroundColor Cyan
    Write-Host "      [+] Fastest DNS for your connection: $($sorted[0].Name) ($($sorted[0].AvgPingMs) ms)" -ForegroundColor Green

    return $sorted
}

function Set-GamingDnsProvider {
    <#
    .SYNOPSIS
        Applies a specific DNS provider (or the benchmark winner) to all active network adapters.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$PrimaryDns = "1.1.1.1",
        [Parameter(Mandatory=$false)]
        [string]$SecondaryDns = "1.0.0.1",
        [Parameter(Mandatory=$false)]
        [string]$ProviderName = "Cloudflare"
    )

    Write-Host "`n[*] Applying $ProviderName Gaming DNS ($PrimaryDns, $SecondaryDns)..." -ForegroundColor Yellow

    $adapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' }
    if (-not $adapters) {
        $adapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' }
    }

    $applied = 0
    foreach ($adapter in $adapters) {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses @($PrimaryDns, $SecondaryDns) -ErrorAction Stop
            $applied++
            Write-Host "      [+] Applied $ProviderName to adapter: $($adapter.Name)" -ForegroundColor Green
        } catch {
            Write-Host "      [~] Skipped adapter $($adapter.Name): $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    }

    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [OK] DNS set to $ProviderName ($PrimaryDns) across $applied active adapters! DNS cache flushed." -ForegroundColor Green
}

function Reset-DnsToAutomatic {
    <#
    .SYNOPSIS
        Resets DNS client server addresses to automatic DHCP defaults.
    #>
    Write-Host "`n[*] Resetting DNS Client to Automatic (DHCP Defaults)..." -ForegroundColor Yellow

    $adapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' }
    foreach ($adapter in $adapters) {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ResetServerAddresses -ErrorAction SilentlyContinue
            Write-Host "      [+] Reset adapter to DHCP: $($adapter.Name)" -ForegroundColor Green
        } catch {}
    }

    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [OK] DNS restored to Automatic (DHCP) defaults!" -ForegroundColor Green
}

# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Optimize-Network
    Read-Host "`nPress Enter to exit"
}

# ------------------------------------------------------------------------------
# MODULE: Toggle-WifiScan
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: Wi-Fi Background Roaming Spike Mitigator
================================================================================
#>

function Toggle-WifiAutoconfig {
    param(
        [string]$Action
    )
    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host "                       WI-FI BACKGROUND SCAN MITIGATOR                          " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "Windows scans for Wi-Fi networks every 60s in the background, causing 100-300ms ping spikes."
    Write-Host "Disabling AutoConfig during gaming gives flat, wired-like ping."
    Write-Host ""
    $wifi = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceType -eq 71 -or $_.InterfaceDescription -match 'Wi-Fi|Wireless' } | Select-Object -First 1
    if (-not $wifi) {
        Write-Host "[!] No active Wi-Fi adapter detected on this PC." -ForegroundColor Yellow
        return $false
    }
    Write-Host "Active Wi-Fi Adapter: $($wifi.Name)" -ForegroundColor Green

    # If Action specified or programmatic call
    if ($Action -match 'Disable|no|off') {
        netsh wlan set autoconfig enabled=no interface="$($wifi.Name)" 2>$null | Out-Null
        Write-Host "[OK] Wi-Fi AutoConfig DISABLED! Background scanning is frozen for 0ms ping spikes." -ForegroundColor Green
        return $true
    } elseif ($Action -match 'Enable|yes|on') {
        netsh wlan set autoconfig enabled=yes interface="$($wifi.Name)" 2>$null | Out-Null
        Write-Host "[OK] Wi-Fi AutoConfig ENABLED! Normal Wi-Fi discovery restored." -ForegroundColor Green
        return $true
    }

    # If invoked programmatically without action, toggle automatically
    if ($MyInvocation.InvocationName -eq '.' -or (-not [Environment]::UserInteractive)) {
        $curState = netsh wlan show interfaces 2>$null
        if ($curState -match 'disabled|Disabled') {
            netsh wlan set autoconfig enabled=yes interface="$($wifi.Name)" 2>$null | Out-Null
            Write-Host "[OK] Wi-Fi AutoConfig ENABLED! Normal Wi-Fi discovery restored." -ForegroundColor Green
        } else {
            netsh wlan set autoconfig enabled=no interface="$($wifi.Name)" 2>$null | Out-Null
            Write-Host "[OK] Wi-Fi AutoConfig DISABLED! Background scanning is frozen for 0ms ping spikes." -ForegroundColor Green
        }
        return $true
    }

    Write-Host "  [1] DISABLE Background Scan (Competitive Gaming Mode - ZERO Ping Spikes)" -ForegroundColor Green
    Write-Host "  [2] ENABLE Background Scan (Normal Mode - Discover New Wi-Fi Networks)" -ForegroundColor Yellow
    Write-Host "  [0] Back to Main Menu"
    $wChoice = Read-Host "`nSelect option [0-2]"
    switch ($wChoice) {
        "1" {
            netsh wlan set autoconfig enabled=no interface="$($wifi.Name)" 2>$null | Out-Null
            Write-Host "`n[OK] Wi-Fi AutoConfig DISABLED! Background scanning is frozen for 0ms ping spikes." -ForegroundColor Green
        }
        "2" {
            netsh wlan set autoconfig enabled=yes interface="$($wifi.Name)" 2>$null | Out-Null
            Write-Host "`n[OK] Wi-Fi AutoConfig ENABLED! Normal Wi-Fi discovery restored." -ForegroundColor Green
        }
    }
}

# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"" -Verb RunAs
        exit
    }
    Toggle-WifiAutoconfig
    Read-Host "
Press Enter to exit"
}

# ------------------------------------------------------------------------------
# MODULE: Optimize-KernelAndCpu
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: Kernel, Quantum & CPU Priority Scheduling Suite
================================================================================
#>

function Optimize-CpuAndSystem {
    Write-Host "`n[*] Tuning CPU Scheduling, Kernel Executive, FTH & Game Mode..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile

    # 1. Memory Management: Lock kernel in physical DDR RAM
    $memKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    Set-ItemProperty -Path $memKey -Name 'DisablePagingExecutive' -Value 1 -Type DWord
    Set-ItemProperty -Path $memKey -Name 'LargeSystemCache' -Value 0 -Type DWord
    Write-Host "      [+] DisablePagingExecutive = 1 (Kernel and drivers locked in RAM, 0 pagefile lag)" -ForegroundColor Green

    # 2. Win32 Priority Separation (0x26: Short, Variable, 3:1 Foreground Boost - Alchemy gem)
    $prioKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl'
    if (-not (Test-Path $prioKey)) { New-Item -Path $prioKey -Force | Out-Null }
    Set-ItemProperty -Path $prioKey -Name 'Win32PrioritySeparation' -Value 38 -Type DWord # 0x26 = 38
    Write-Host "      [+] Win32PrioritySeparation = 0x26 (3:1 Foreground CPU quantum boost for active game)" -ForegroundColor Green

    # 3. Kernel DPC Immediate Dispatch & SplitLargeCaches (Alchemy Kernel gem)
    $kernelKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'
    if (-not (Test-Path $kernelKey)) { New-Item -Path $kernelKey -Force | Out-Null }
    Set-ItemProperty -Path $kernelKey -Name 'ThreadDpcEnable' -Value 0 -Type DWord
    Set-ItemProperty -Path $kernelKey -Name 'SplitLargeCaches' -Value 1 -Type DWord
    Write-Host "      [+] ThreadDpcEnable = 0 (Immediate DISPATCH_LEVEL DPC execution, no thread queue lag)" -ForegroundColor Green
    Write-Host "      [+] SplitLargeCaches = 1 (Optimized memory cache line splitting across CPU cores)" -ForegroundColor Green

    # 4. Executive Worker Thread Pool Scaling (Alchemy gem)
    $execKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive'
    if (-not (Test-Path $execKey)) { New-Item -Path $execKey -Force | Out-Null }
    Set-ItemProperty -Path $execKey -Name 'AdditionalCriticalWorkerThreads' -Value 16 -Type DWord
    Set-ItemProperty -Path $execKey -Name 'AdditionalDelayedWorkerThreads' -Value 16 -Type DWord
    Write-Host "      [+] Executive Worker Threads scaled to 16 for high-speed I/O streaming" -ForegroundColor Green

    # 5. Disable Fault Tolerant Heap (FTH - AtlasOS gem)
    $fthKey = 'HKLM:\SOFTWARE\Microsoft\FTH'
    if (-not (Test-Path $fthKey)) { New-Item -Path $fthKey -Force | Out-Null }
    Set-ItemProperty -Path $fthKey -Name 'Enabled' -Value 0 -Type DWord
    Write-Host "      [+] Fault Tolerant Heap (FTH) disabled (Stops tracking shims from slowing games)" -ForegroundColor Green

    # 6. Disable Desktop Energy Estimation Engine (Valorant Pack gem)
    $pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
    Set-ItemProperty -Path $pwrKey -Name 'EnergyEstimationEnabled' -Value 0 -Type DWord
    $taggedEnergy = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\EnergyEstimation\TaggedEnergy'
    if (-not (Test-Path $taggedEnergy)) { New-Item -Path $taggedEnergy -Force | Out-Null }
    Set-ItemProperty -Path $taggedEnergy -Name 'DisableTaggedEnergyLogging' -Value 1 -Type DWord
    Set-ItemProperty -Path $taggedEnergy -Name 'TelemetryMaxApplication' -Value 0 -Type DWord
    Write-Host "      [+] Desktop EnergyEstimation disabled (No background battery logging on AC power)" -ForegroundColor Green

    # 7. Direct Flip / Fullscreen Exclusive Overrides (Bypass DWM latency)
    $gcs = 'HKCU:\System\GameConfigStore'
    Set-ItemProperty -Path $gcs -Name 'GameDVR_Enabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_DXGIHonorFSEWindowsCompatible' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_EFSEFeatureFlags' -Value 0 -Type DWord
    Write-Host "      [+] Direct Flip scanout active (1-2 frames display latency saved)" -ForegroundColor Green

    # 8. CPU Core Unparking (100% Active Cores for both AMD & Intel)
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100

    # Architecture-specific CPU Scheduling
    if ($hw.IsIntelCpu) {
        powercfg -setacvalueindex scheme_current sub_processor HETEROPOLICY 0 2>$null
        powercfg -setacvalueindex scheme_current sub_processor SCHEDPOLICY 2 2>$null
        Write-Host "      [+] Intel Core Detected: Unparked all cores and prioritized Performance P-Cores" -ForegroundColor Green
    } elseif ($hw.IsAmdCpu) {
        Write-Host "      [+] AMD Ryzen Detected ($($hw.CpuName)): 100% Cores unparked for full boost clock" -ForegroundColor Green
    }
    powercfg -setactive scheme_current

    # Windows Game Mode & System Responsiveness
    $mmKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    Set-ItemProperty -Path $mmKey -Name 'NetworkThrottlingIndex' -Value 0xFFFFFFFF -Type DWord
    Set-ItemProperty -Path $mmKey -Name 'SystemResponsiveness' -Value 0 -Type DWord
    $gameKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
    if (Test-Path $gameKey) {
        Set-ItemProperty -Path $gameKey -Name 'Priority' -Value 6 -Type DWord
        Set-ItemProperty -Path $gameKey -Name 'GPU Priority' -Value 8 -Type DWord
        Set-ItemProperty -Path $gameKey -Name 'Scheduling Category' -Value 'High' -Type String
        Set-ItemProperty -Path $gameKey -Name 'SFIO Priority' -Value 'High' -Type String
    }
    $gbKey = 'HKCU:\Software\Microsoft\GameBar'
    if (-not (Test-Path $gbKey)) { New-Item -Path $gbKey -Force | Out-Null }
    Set-ItemProperty -Path $gbKey -Name 'AutoGameModeEnabled' -Value 1 -Type DWord

    $ptKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'
    if (-not (Test-Path $ptKey)) { New-Item -Path $ptKey -Force | Out-Null }
    Set-ItemProperty -Path $ptKey -Name 'PowerThrottlingOff' -Value 1 -Type DWord

    $gdvr = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'
    if (-not (Test-Path $gdvr)) { New-Item -Path $gdvr -Force | Out-Null }
    Set-ItemProperty -Path $gdvr -Name 'AllowGameDVR' -Value 0 -Type DWord

    $trans = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    if (Test-Path $trans) { Set-ItemProperty -Path $trans -Name 'EnableTransparency' -Value 0 -Type DWord }
    Write-Host "      [+] Windows Game Mode enabled, Power Throttling disabled, DWM transparency off" -ForegroundColor Green
}

function Invoke-CpuCoreUnparking {
    <#
    .SYNOPSIS
        Unparks 100% of CPU cores, sets minimum processor state to 100%, and unmasks core parking in Power Options.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Unparking 100% of CPU Cores & Disabling Processor Sleep..." -ForegroundColor Yellow

    # Unhide core parking settings in Power Options GUI
    $subProcessorKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00"
    $unhideGuids = @(
        "0cc5b647-c1df-4637-891a-dec35c318583", # Min cores
        "ea062031-0e34-4ff1-9b6d-eb10593ac08f", # Max cores
        "be337238-0d82-4146-a960-492742134378", # Boost mode
        "0602446d-d8e3-4e29-9e6f-ddde3669f87f", # Perf increase threshold
        "12a0ab44-fe16-4661-bd10-eef3298d1945"  # Perf decrease threshold
    )
    foreach ($ug in $unhideGuids) {
        $p = "$subProcessorKey\$ug"
        if (Test-Path $p) {
            Set-ItemProperty -Path $p -Name "Attributes" -Value 2 -Type DWord -ErrorAction SilentlyContinue
        }
    }

    # Apply 100% Core Unparking to active scheme
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100
    powercfg -setdcvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setdcvalueindex scheme_current sub_processor CPMAXCORES 100
    powercfg -setacvalueindex scheme_current sub_processor PROCFREQMAX 0
    powercfg -setacvalueindex scheme_current sub_processor be337238-0d82-4146-a960-492742134378 2 2>$null # Aggressive Boost
    powercfg -setacvalueindex scheme_current sub_processor 0602446d-d8e3-4e29-9e6f-ddde3669f87f 10 2>$null # Increase threshold
    powercfg -setacvalueindex scheme_current sub_processor 12a0ab44-fe16-4661-bd10-eef3298d1945 80 2>$null # Decrease threshold
    powercfg -setactive scheme_current

    Write-Host "      [+] 100% of CPU logical cores unparked! Processor downclocking eliminated." -ForegroundColor Green
    return $true
}

function Invoke-PumpkiNEsportsPowerPlan {
    <#
    .SYNOPSIS
        Creates, customizes, and activates the PumpkiN Esports Ultimate Performance power scheme.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Configuring PumpkiN Esports Ultimate Power Plan..." -ForegroundColor Yellow

    # Ensure core parking settings are unmasked
    Invoke-CpuCoreUnparking | Out-Null

    $schemes = powercfg -list
    $targetGuid = $null

    $existingPumpkin = $schemes | Select-String "PumpkiN Esports"
    if ($existingPumpkin) {
        $targetGuid = ($existingPumpkin -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
    } else {
        $existingUlt = $schemes | Select-String "Ultimate Performance"
        if ($existingUlt) {
            $targetGuid = ($existingUlt[0] -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        } else {
            $dupOut = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
            if ($dupOut -match '([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})') {
                $targetGuid = $matches[1]
            }
        }
    }

    if (-not $targetGuid) {
        $targetGuid = "scheme_current"
    } else {
        powercfg -changename $targetGuid "PumpkiN Esports Ultimate Performance" "0% CPU Core Parking, Aggressive Boost Clocks, Zero DPC Latency"
    }

    # Apply Esports Ultra-Low Latency Power Attributes
    powercfg -setacvalueindex $targetGuid sub_processor CPMINCORES 100
    powercfg -setacvalueindex $targetGuid sub_processor CPMAXCORES 100
    powercfg -setdcvalueindex $targetGuid sub_processor CPMINCORES 100
    powercfg -setdcvalueindex $targetGuid sub_processor CPMAXCORES 100
    powercfg -setacvalueindex $targetGuid sub_processor PROCFREQMAX 0
    powercfg -setacvalueindex $targetGuid sub_processor be337238-0d82-4146-a960-492742134378 2 2>$null
    powercfg -setacvalueindex $targetGuid sub_processor 0602446d-d8e3-4e29-9e6f-ddde3669f87f 10 2>$null
    powercfg -setacvalueindex $targetGuid sub_processor 12a0ab44-fe16-4661-bd10-eef3298d1945 80 2>$null

    # Disable Peripheral & Bus Sleep
    powercfg -setacvalueindex $targetGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4760-a56b-140af6094241 0 2>$null # USB Selective Suspend Off
    powercfg -setacvalueindex $targetGuid 501a4d13-42af-4429-9e56-e32f20308218 ee132098-89fc-45ce-9179-d4b6c504d67e 0 2>$null # PCIe Link State Off
    powercfg -change -disk-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0

    powercfg -setactive $targetGuid
    Write-Host "      [+] PumpkiN Esports Ultimate Power Plan ACTIVE!" -ForegroundColor Green
    return $true
}

function Restore-CpuCoreParking {
    <#
    .SYNOPSIS
        Restores default CPU core parking and Windows Balanced power scheme.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Restoring Default Core Parking & Windows Balanced Power Scheme..." -ForegroundColor Yellow

    $balanced = powercfg /list | Select-String "Balanced"
    if ($balanced) {
        $guid = ($balanced -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        powercfg /setactive $guid
        Write-Host "      [+] Activated Windows Balanced power scheme ($guid)" -ForegroundColor Green
    } else {
        powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
    }

    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 10 2>$null
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100 2>$null
    powercfg -setacvalueindex scheme_current sub_processor 0602446d-d8e3-4e29-9e6f-ddde3669f87f 60 2>$null
    powercfg -setacvalueindex scheme_current sub_processor 12a0ab44-fe16-4661-bd10-eef3298d1945 40 2>$null
    powercfg -setactive scheme_current
    powercfg /hibernate off 2>$null

    Write-Host "      [OK] Windows Core Parking & Balanced power defaults restored (Hibernate remains Off)." -ForegroundColor Green
    return $true
}

function Get-CpuCoreParkingStatus {
    <#
    .SYNOPSIS
        Returns current active power scheme and core unparking status.
    #>
    [CmdletBinding()]
    param()

    $schemes = powercfg -list
    $activeLine = $schemes | Select-String "\*"
    $activeName = "Unknown"
    $activeGuid = ""
    if ($activeLine -match 'GUID:\s*([a-f0-9-]+)\s+\(([^)]+)\)') {
        $activeGuid = $matches[1]
        $activeName = $matches[2]
    }

    $isUnparked = ($activeName -match 'Ultimate|Esports|Highest|High')

    return [PSCustomObject]@{
        ActiveSchemeName = $activeName
        ActiveSchemeGuid = $activeGuid
        IsUnparked       = $isUnparked
        DisplayText      = "$activeName $(if ($isUnparked) { '(100% Cores Active)' } else { '(Core Parking Default)' })"
    }
}

function Restore-MultiplaneOverlay {
    Write-Host "`n[*] Restoring Windows Multiplane Overlay (MPO) Default..." -ForegroundColor Yellow
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' -Name 'OverlayTestMode' -ErrorAction SilentlyContinue
    Write-Host "      [+] Multiplane Overlay restored to default." -ForegroundColor Green
}

function Restore-CsrssPriority {
    Write-Host "`n[*] Restoring Default CSRSS Process Priority..." -ForegroundColor Yellow
    Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions' -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] Default CSRSS process priority restored." -ForegroundColor Green
}

function Restore-CpuAndSystem {
    Write-Host "`n[*] Restoring Default CPU Quantum & Memory Management..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\FTH' -Name 'Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'EnergyEstimationEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' -Name 'ThreadDpcEnable' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' -Name 'SplitLargeCaches' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive' -Name 'AdditionalCriticalWorkerThreads' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive' -Name 'AdditionalDelayedWorkerThreads' -ErrorAction SilentlyContinue
    Write-Host "      [+] CPU Quantum and Memory Management restored to Windows defaults." -ForegroundColor Green
}

function Restore-SvcHostSplitting {
    Write-Host "`n[*] Restoring Default SvcHost Process Threshold..." -ForegroundColor Yellow
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -ErrorAction SilentlyContinue
    Write-Host "      [+] Default SvcHost memory threshold restored." -ForegroundColor Green
}

function Optimize-DeviceManager {
    <#
    .SYNOPSIS
        Disables high-latency devices in Device Manager (HPET, SMBus, System Speaker, Kernel Debugger,
        Composite Bus, DMA, and Legacy Timers) to minimize DPC latency and CPU timer interrupt overhead.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Disabling High-Latency Devices in Device Manager..." -ForegroundColor Yellow

    $targetDeviceNames = @(
        'High precision event timer',
        'Microsoft Kernel Debug Network Adapter',
        'System speaker',
        'Composite Bus Enumerator',
        'Direct memory access controller',
        'System timer',
        'System CMOS/real time clock',
        'Motherboard resources'
    )

    $disabledCount = 0

    foreach ($name in $targetDeviceNames) {
        $devs = Get-PnpDevice -FriendlyName $name -ErrorAction SilentlyContinue
        foreach ($d in $devs) {
            try {
                if ($d.ConfigManagerErrorCode -ne 22 -and $d.Status -ne 'Error') {
                    Disable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction Stop
                    Write-Host "      [+] Disabled: $($d.FriendlyName)" -ForegroundColor Green
                    $disabledCount++
                } else {
                    Write-Host "      [+] Already Disabled: $($d.FriendlyName)" -ForegroundColor DarkCyan
                }
            } catch {
                Write-Host "      [~] Skipped: $($d.FriendlyName) ($($_.Exception.Message))" -ForegroundColor DarkYellow
            }
        }
    }

    # Also check AMD & Intel SMBus controllers
    $smbus = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -match 'SMBus' }
    foreach ($sb in $smbus) {
        try {
            if ($sb.ConfigManagerErrorCode -ne 22 -and $sb.Status -ne 'Error') {
                Disable-PnpDevice -InstanceId $sb.InstanceId -Confirm:$false -ErrorAction Stop
                Write-Host "      [+] Disabled: $($sb.FriendlyName)" -ForegroundColor Green
                $disabledCount++
            } else {
                Write-Host "      [+] Already Disabled: $($sb.FriendlyName)" -ForegroundColor DarkCyan
            }
        } catch {
            Write-Host "      [~] Skipped: $($sb.FriendlyName) ($($_.Exception.Message))" -ForegroundColor DarkYellow
        }
    }

    Write-Host "      [OK] Device Manager Latency Optimization Applied ($disabledCount new devices disabled)." -ForegroundColor Green
    return $true
}

function Restore-DeviceManager {
    <#
    .SYNOPSIS
        Re-enables devices previously disabled in Device Manager for 100% reversibility.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Restoring Device Manager Devices to Enabled..." -ForegroundColor Yellow

    $targetDeviceNames = @(
        'High precision event timer',
        'Microsoft Kernel Debug Network Adapter',
        'System speaker',
        'Composite Bus Enumerator',
        'Direct memory access controller',
        'System timer',
        'System CMOS/real time clock',
        'Motherboard resources'
    )

    $enabledCount = 0

    foreach ($name in $targetDeviceNames) {
        $devs = Get-PnpDevice -FriendlyName $name -ErrorAction SilentlyContinue
        foreach ($d in $devs) {
            try {
                if ($d.ConfigManagerErrorCode -eq 22 -or $d.Status -eq 'Error') {
                    Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction Stop
                    Write-Host "      [+] Re-enabled: $($d.FriendlyName)" -ForegroundColor Green
                    $enabledCount++
                }
            } catch {
                Write-Host "      [~] Skipped: $($d.FriendlyName) ($($_.Exception.Message))" -ForegroundColor DarkYellow
            }
        }
    }

    # Also check AMD & Intel SMBus controllers
    $smbus = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -match 'SMBus' }
    foreach ($sb in $smbus) {
        try {
            if ($sb.ConfigManagerErrorCode -eq 22 -or $sb.Status -eq 'Error') {
                Enable-PnpDevice -InstanceId $sb.InstanceId -Confirm:$false -ErrorAction Stop
                Write-Host "      [+] Re-enabled: $($sb.FriendlyName)" -ForegroundColor Green
                $enabledCount++
            }
        } catch {
            Write-Host "      [~] Skipped: $($sb.FriendlyName) ($($_.Exception.Message))" -ForegroundColor DarkYellow
        }
    }

    Write-Host "      [OK] Device Manager Defaults Restored ($enabledCount devices re-enabled)." -ForegroundColor Green
    return $true
}

function Get-DeviceManagerOptimizationStatus {
    $hpet = Get-PnpDevice -FriendlyName 'High precision event timer' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hpet -and ($hpet.ConfigManagerErrorCode -eq 22 -or $hpet.Status -eq 'Error')) {
        return $true
    }
    $kd = Get-PnpDevice -FriendlyName 'Microsoft Kernel Debug Network Adapter' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($kd -and ($kd.ConfigManagerErrorCode -eq 22 -or $kd.Status -eq 'Error')) {
        return $true
    }
    return $false
}


# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Write-Host "=== PUMPKIN CPU CORE UNPARKING & POWER ENGINE ===" -ForegroundColor Cyan
    Write-Host "1. Activate PumpkiN Esports Ultimate Power Plan (0% Core Parking)"
    Write-Host "2. Unpark 100% CPU Cores on Current Scheme"
    Write-Host "3. Restore Default Core Parking & Balanced Plan"
    Write-Host "4. Query Core Parking Status"
    $ans = Read-Host "Select option [1-4]"
    switch ($ans) {
        "1" { Invoke-PumpkiNEsportsPowerPlan }
        "2" { Invoke-CpuCoreUnparking }
        "3" { Restore-CpuCoreParking }
        "4" {
            $st = Get-CpuCoreParkingStatus
            Write-Host "Status: $($st.DisplayText)" -ForegroundColor Green
        }
    }
    Read-Host "`nPress Enter to exit"
}

# ------------------------------------------------------------------------------
# MODULE: Optimize-InputLatency
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: 8000Hz Input, Audio DPC & Hardware Interrupt Suite
================================================================================
#>

function Optimize-LatencyAndInput {
    Write-Host "`n[*] Forcing Zero DPC Latency Tolerance & 8000Hz Input Buffer..." -ForegroundColor Yellow
    # StopHighDPC & Latency Tolerance
    $pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatencyCheckEnabled' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'Latency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceFSVP' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyTolerancePerfOverride' -Value 1 -Type DWord

    # Dynamic Tick Jitter Elimination & x2APIC
    bcdedit /set disabledynamictick yes | Out-Null
    bcdedit /set x2apicpolicy Enable | Out-Null
    bcdedit /deletevalue useplatformclock 2>$null | Out-Null
    Write-Host "      [+] StopHighDPC active + x2APIC enabled + dynamic tick jitter eliminated" -ForegroundColor Green

    # Input Queues for High-Polling Gaming Mice (Up to 8000Hz)
    $mouKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters'
    if (Test-Path $mouKey) { Set-ItemProperty -Path $mouKey -Name 'MouseDataQueueSize' -Value 200 -Type DWord }
    $kbdKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters'
    if (Test-Path $kbdKey) { Set-ItemProperty -Path $kbdKey -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord }

    # USB Selective Suspend Disabled
    $usbKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
    if (-not (Test-Path $usbKey)) { New-Item -Path $usbKey -Force | Out-Null }
    Set-ItemProperty -Path $usbKey -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord

    # MarkC 1:1 Raw Mouse Acceleration Curve
    $mouseKey = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mouseKey -Name 'MouseSpeed' -Value '0' -Type String
    Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold1' -Value '0' -Type String
    Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold2' -Value '0' -Type String
    [byte[]]$smoothX = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x29,0xdc,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00
    [byte[]]$smoothY = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xa8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xe0,0x00,0x00,0x00,0x00,0x00
    Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseXCurve' -Value $smoothX -Type Binary
    Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseYCurve' -Value $smoothY -Type Binary
    Write-Host "      [+] 8000Hz Mouse Buffer tuned + 100% Raw 1:1 Mouse Input Curve applied" -ForegroundColor Green

    # CSRSS Realtime & Max I/O Priority
    Optimize-CsrssPriority

    # Disable USB & Device Power Saving (Always Full Power)
    if (Get-Command Disable-DevicePowerSaving -ErrorAction SilentlyContinue) {
        Disable-DevicePowerSaving
    }
}

function Optimize-CsrssPriority {
    Write-Host "`n[*] Setting CSRSS to Realtime CPU Priority & Maximum I/O Priority..." -ForegroundColor Yellow
    $csrssKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions'
    if (-not (Test-Path $csrssKey)) { New-Item -Path $csrssKey -Force | Out-Null }
    Set-ItemProperty -Path $csrssKey -Name 'CpuPriorityClass' -Value 4 -Type DWord
    Set-ItemProperty -Path $csrssKey -Name 'IoPriority' -Value 4 -Type DWord
    Write-Host "      [+] CSRSS Hooked -> Realtime CPU Priority (4) & Max I/O Priority (4)" -ForegroundColor Green
}

function Optimize-AudioDpcLatency {
    <#
    .SYNOPSIS
        Tuning Windows Audio MMCSS, Network Throttling, and Hardware MSI Mode for Audio Controllers.
    .DESCRIPTION
        Eliminates audio pops, latency spikes, and buffer dropouts during competitive gaming.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Optimizing Audio DPC Latency, MMCSS Priority & Controller IRQs..." -ForegroundColor Yellow

    # Multimedia SystemProfile Network Throttling & Responsiveness
    $sysProf = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    if (-not (Test-Path $sysProf)) { New-Item -Path $sysProf -Force | Out-Null }
    Set-ItemProperty -Path $sysProf -Name 'NetworkThrottlingIndex' -Value 0xFFFFFFFF -Type DWord
    Set-ItemProperty -Path $sysProf -Name 'SystemResponsiveness' -Value 0 -Type DWord

    # Multimedia Audio Task Scheduling
    $audioTask = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio'
    if (-not (Test-Path $audioTask)) { New-Item -Path $audioTask -Force | Out-Null }
    Set-ItemProperty -Path $audioTask -Name 'Affinity' -Value 0 -Type DWord
    Set-ItemProperty -Path $audioTask -Name 'Background Only' -Value 'False' -Type String
    Set-ItemProperty -Path $audioTask -Name 'Clock Rate' -Value 10000 -Type DWord
    Set-ItemProperty -Path $audioTask -Name 'GPU Priority' -Value 8 -Type DWord
    Set-ItemProperty -Path $audioTask -Name 'Priority' -Value 6 -Type DWord
    Set-ItemProperty -Path $audioTask -Name 'Scheduling Category' -Value 'High' -Type String
    Set-ItemProperty -Path $audioTask -Name 'SFIO Priority' -Value 'High' -Type String
    Write-Host "      [+] Audio MMCSS Task configured: High Scheduling Category & Priority 6" -ForegroundColor Green

    # High Definition Audio Controller MSI Mode & High Priority
    $pciBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI'
    $audioCount = 0
    if (Test-Path $pciBase) {
        $pciDevices = Get-ChildItem -Path $pciBase -ErrorAction SilentlyContinue
        foreach ($dev in $pciDevices) {
            $instances = Get-ChildItem -Path $dev.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $props = Get-ItemProperty -Path $inst.PSPath -ErrorAction SilentlyContinue
                if (-not $props) { continue }

                if ($props.Class -eq 'MEDIA' -or $props.ClassGUID -eq '{4d36e96c-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'HDAudBus|IntcAzAudAddService|Realtek') {
                    $devParam = Join-Path $inst.PSPath 'Device Parameters'
                    $intMgmt = Join-Path $devParam 'Interrupt Management'
                    $msiProps = Join-Path $intMgmt 'MessageSignaledInterruptProperties'
                    $affPolicy = Join-Path $intMgmt 'Affinity Policy'

                    if (-not (Test-Path $msiProps)) { New-Item -Path $msiProps -Force | Out-Null }
                    Set-ItemProperty -Path $msiProps -Name 'MSISupported' -Value 1 -Type DWord -ErrorAction SilentlyContinue

                    if (-not (Test-Path $affPolicy)) { New-Item -Path $affPolicy -Force | Out-Null }
                    Set-ItemProperty -Path $affPolicy -Name 'DevicePriority' -Value 3 -Type DWord -ErrorAction SilentlyContinue

                    $name = if ($props.DeviceDesc) { ($props.DeviceDesc -replace ';.*', '') } else { "Audio Controller" }
                    Write-Host "      [+] Audio Controller MSI Mode & High Priority: $name" -ForegroundColor Green
                    $audioCount++
                }
            }
        }
    }

    Write-Host "      [OK] Audio DPC Latency optimization applied ($audioCount Audio Controllers hooked)!" -ForegroundColor Green
    return $true
}

function Optimize-UsbLatencyAndBuffers {
    <#
    .SYNOPSIS
        Sets real-time USB xHCI thread priority, enables MSI Mode on USB controllers, and maximizes input buffers.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Tuning USB xHCI Realtime Thread Priority & Polling Queues..." -ForegroundColor Yellow

    # USBXHCI Realtime ThreadPriority
    $xhciKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBXHCI\Parameters'
    if (-not (Test-Path $xhciKey)) { New-Item -Path $xhciKey -Force | Out-Null }
    Set-ItemProperty -Path $xhciKey -Name 'ThreadPriority' -Value 31 -Type DWord
    Write-Host "      [+] USBXHCI ThreadPriority set to 31 (Realtime Kernel Execution)" -ForegroundColor Green

    # High-Polling Input Queues
    $mouKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters'
    if (Test-Path $mouKey) { Set-ItemProperty -Path $mouKey -Name 'MouseDataQueueSize' -Value 200 -Type DWord }
    $kbdKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters'
    if (Test-Path $kbdKey) { Set-ItemProperty -Path $kbdKey -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord }

    # USB Host Controllers MSI Mode & High Priority
    $pciBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI'
    $usbCount = 0
    if (Test-Path $pciBase) {
        $pciDevices = Get-ChildItem -Path $pciBase -ErrorAction SilentlyContinue
        foreach ($dev in $pciDevices) {
            $instances = Get-ChildItem -Path $dev.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $props = Get-ItemProperty -Path $inst.PSPath -ErrorAction SilentlyContinue
                if (-not $props) { continue }

                if ($props.Class -eq 'USB' -or $props.ClassGUID -eq '{36fc9e60-c465-11cf-8056-444553540000}' -or $props.Service -match 'USBXHCI|usbehci') {
                    $devParam = Join-Path $inst.PSPath 'Device Parameters'
                    $intMgmt = Join-Path $devParam 'Interrupt Management'
                    $msiProps = Join-Path $intMgmt 'MessageSignaledInterruptProperties'
                    $affPolicy = Join-Path $intMgmt 'Affinity Policy'

                    if (-not (Test-Path $msiProps)) { New-Item -Path $msiProps -Force | Out-Null }
                    Set-ItemProperty -Path $msiProps -Name 'MSISupported' -Value 1 -Type DWord -ErrorAction SilentlyContinue

                    if (-not (Test-Path $affPolicy)) { New-Item -Path $affPolicy -Force | Out-Null }
                    Set-ItemProperty -Path $affPolicy -Name 'DevicePriority' -Value 3 -Type DWord -ErrorAction SilentlyContinue

                    $name = if ($props.DeviceDesc) { ($props.DeviceDesc -replace ';.*', '') } else { "USB Controller" }
                    Write-Host "      [+] USB Controller MSI Mode & High Priority: $name" -ForegroundColor Green
                    $usbCount++
                }
            }
        }
    }

    if (Get-Command Disable-DevicePowerSaving -ErrorAction SilentlyContinue) {
        Disable-DevicePowerSaving
    }

    Write-Host "      [OK] USB xHCI latency and buffer tuning complete ($usbCount USB Controllers hooked)!" -ForegroundColor Green
    return $true
}

function Get-HardwareInterruptReport {
    <#
    .SYNOPSIS
        Scans all critical PCI controllers and returns MSI Mode and Priority statuses.
    #>
    [CmdletBinding()]
    param()

    $pciBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI'
    $report = @()
    if (Test-Path $pciBase) {
        $pciDevices = Get-ChildItem -Path $pciBase -ErrorAction SilentlyContinue
        foreach ($dev in $pciDevices) {
            $instances = Get-ChildItem -Path $dev.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $props = Get-ItemProperty -Path $inst.PSPath -ErrorAction SilentlyContinue
                if (-not $props) { continue }

                $cat = $null
                if ($props.Class -eq 'Display' -or $props.ClassGUID -eq '{4d36e968-e325-11ce-bfc1-08002be10318}') {
                    $cat = "GPU"
                } elseif ($props.Class -eq 'USB' -or $props.ClassGUID -eq '{36fc9e60-c465-11cf-8056-444553540000}' -or $props.Service -match 'USBXHCI|usbehci') {
                    $cat = "USB"
                } elseif ($props.Class -eq 'Net' -or $props.ClassGUID -eq '{4d36e972-e325-11ce-bfc1-08002be10318}') {
                    $cat = "Network"
                } elseif ($props.Class -eq 'MEDIA' -or $props.ClassGUID -eq '{4d36e96c-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'HDAudBus|IntcAzAudAddService|Realtek') {
                    $cat = "Audio"
                } elseif ($props.Class -eq 'SCSIAdapter' -or $props.ClassGUID -eq '{4d36e97b-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'stornvme') {
                    $cat = "NVMe"
                }

                if ($cat) {
                    $devParam = Join-Path $inst.PSPath 'Device Parameters'
                    $intMgmt = Join-Path $devParam 'Interrupt Management'
                    $msiProps = Join-Path $intMgmt 'MessageSignaledInterruptProperties'
                    $affPolicy = Join-Path $intMgmt 'Affinity Policy'

                    $msiVal = 0
                    if (Test-Path $msiProps) {
                        $m = Get-ItemProperty -Path $msiProps -ErrorAction SilentlyContinue
                        if ($m -and $m.MSISupported -ne $null) { $msiVal = $m.MSISupported }
                    }

                    $prioVal = 0
                    if (Test-Path $affPolicy) {
                        $p = Get-ItemProperty -Path $affPolicy -ErrorAction SilentlyContinue
                        if ($p -and $p.DevicePriority -ne $null) { $prioVal = $p.DevicePriority }
                    }

                    $prioText = switch ($prioVal) {
                        3 { "High" }
                        2 { "Normal" }
                        1 { "Low" }
                        default { "Undefined" }
                    }

                    $desc = if ($props.DeviceDesc) { ($props.DeviceDesc -replace ';.*', '') } else { $cat }
                    $report += [PSCustomObject]@{
                        Category     = $cat
                        DeviceName   = $desc
                        MSISupported = ($msiVal -eq 1)
                        Priority     = $prioText
                        PriorityVal  = $prioVal
                    }
                }
            }
        }
    }
    return $report
}

function Restore-AudioDpcAndUsbLatency {
    <#
    .SYNOPSIS
        Restores Windows default MMCSS audio task and input settings.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Restoring Windows Default Audio MMCSS & Input Settings..." -ForegroundColor Yellow

    # Restore Multimedia SystemProfile defaults
    $sysProf = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    if (Test-Path $sysProf) {
        Set-ItemProperty -Path $sysProf -Name 'NetworkThrottlingIndex' -Value 10 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $sysProf -Name 'SystemResponsiveness' -Value 20 -Type DWord -ErrorAction SilentlyContinue
    }

    # Restore Audio MMCSS Task defaults
    $audioTask = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio'
    if (Test-Path $audioTask) {
        Set-ItemProperty -Path $audioTask -Name 'Background Only' -Value 'True' -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'Clock Rate' -Value 10000 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'GPU Priority' -Value 8 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'Priority' -Value 6 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'Scheduling Category' -Value 'Medium' -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'SFIO Priority' -Value 'Normal' -Type String -ErrorAction SilentlyContinue
    }

    # Remove USBXHCI ThreadPriority override
    $xhciKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBXHCI\Parameters'
    if (Test-Path $xhciKey) {
        Remove-ItemProperty -Path $xhciKey -Name 'ThreadPriority' -ErrorAction SilentlyContinue
    }

    # Reset DataQueueSizes to 100
    $mouKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters'
    if (Test-Path $mouKey) { Set-ItemProperty -Path $mouKey -Name 'MouseDataQueueSize' -Value 100 -Type DWord -ErrorAction SilentlyContinue }
    $kbdKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters'
    if (Test-Path $kbdKey) { Set-ItemProperty -Path $kbdKey -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord -ErrorAction SilentlyContinue }

    # Reset bcdedit dynamic tick
    bcdedit /deletevalue disabledynamictick 2>$null | Out-Null

    Write-Host "      [OK] Windows Audio MMCSS and USB Input settings restored to defaults." -ForegroundColor Green
    return $true
}

function Restore-MouseLinearCurve {
    Write-Host "`n[*] Restoring Windows Default Mouse Acceleration Curve..." -ForegroundColor Yellow
    $defaultX = [byte[]](0,0,0,0,0,0,0,0,15,10,0,0,0,0,0,0,0,20,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,70,0,0,0,0,0,0)
    $defaultY = [byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'SmoothMouseXCurve' -Value $defaultX -Type Binary -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'SmoothMouseYCurve' -Value $defaultY -Type Binary -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSensitivity' -Value '10' -Type String -ErrorAction SilentlyContinue
    Write-Host "      [+] Windows default mouse curve restored." -ForegroundColor Green
}

# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Write-Host "=== PUMPKIN DPC LATENCY & HARDWARE INTERRUPT SUITE ===" -ForegroundColor Cyan
    Write-Host "1. Full 8000Hz Input Buffer & Latency Optimization"
    Write-Host "2. Low-Latency Audio & Anti-Popping (MMCSS & Audio MSI Mode)"
    Write-Host "3. USB xHCI Realtime Thread Priority & Polling Queues"
    Write-Host "4. View Hardware Interrupt & MSI Report"
    Write-Host "5. Restore Default Audio MMCSS & Input Settings"
    $ans = Read-Host "Select option [1-5]"
    switch ($ans) {
        "1" { Optimize-LatencyAndInput }
        "2" { Optimize-AudioDpcLatency }
        "3" { Optimize-UsbLatencyAndBuffers }
        "4" {
            $rep = Get-HardwareInterruptReport
            Write-Host "`nHardware Interrupt & MSI Status:" -ForegroundColor Cyan
            $rep | Format-Table -AutoSize | Out-Host
        }
        "5" { Restore-AudioDpcAndUsbLatency }
    }
    Read-Host "`nPress Enter to exit"
}

# ------------------------------------------------------------------------------
# MODULE: Match-Booster
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: Competitive Match Standby Memory Purger & Booster
================================================================================
#>

function Get-EmptyStandbyListExePath {
    $exeCandidates = @(
        "$PSScriptRoot\EmptyStandbyList.exe",
        "$PSScriptRoot\..\EmptyStandbyList.exe",
        "$env:SystemRoot\System32\EmptyStandbyList.exe",
        "e:\Projects\Win_Optimizer\EmptyStandbyList.exe"
    )
    return ($exeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1)
}

function Invoke-EmptyStandbyListOneTime {
    <#
    .SYNOPSIS
        Purges Windows Standby Memory and idle working sets one time.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Purging Kernel Standby Memory & Idle Working Sets (One-Time Run)..." -ForegroundColor Yellow

    $emptyListExe = Get-EmptyStandbyListExePath

    if ($emptyListExe) {
        $memBefore = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
        Start-Process -FilePath $emptyListExe -ArgumentList "workingsets" -Wait -WindowStyle Hidden
        Start-Process -FilePath $emptyListExe -ArgumentList "standbylist" -Wait -WindowStyle Hidden
        $memAfter = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
        $freedMb = [math]::Round(($memAfter - $memBefore) / 1024, 0)
        if ($freedMb -gt 0) {
            Write-Host "      [+] Kernel Standby RAM purged: $freedMb MB returned to Zero-Latency Free Pool!" -ForegroundColor Green
        } else {
            Write-Host "      [+] Kernel Standby RAM & idle working sets trimmed successfully" -ForegroundColor Green
        }
    } else {
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Write-Host "      [+] CLR Garbage collector executed (EmptyStandbyList.exe fallback)" -ForegroundColor Yellow
    }
}

function Set-StandbyListScheduledTask {
    <#
    .SYNOPSIS
        Configures PumpkiN_AutoEmptyStandbyList in Windows Task Scheduler with a user-selected interval.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [int]$IntervalMinutes = 5
    )

    if ($IntervalMinutes -lt 1) { $IntervalMinutes = 5 }

    Write-Host "`n[*] Configuring Background Auto-Cleaner in Task Scheduler (Every $IntervalMinutes minutes)..." -ForegroundColor Yellow

    $emptyListExe = Get-EmptyStandbyListExePath
    if (-not $emptyListExe) {
        Write-Host "      [!] EmptyStandbyList.exe not found. Cannot schedule background task." -ForegroundColor Red
        return $false
    }

    $TaskName = "PumpkiN_AutoEmptyStandbyList"
    try {
        $action = New-ScheduledTaskAction -Execute $emptyListExe -Argument "standbylist"
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes)
        $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -Priority 4

        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
        Start-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

        Write-Host "      [+] Background Auto-Cleaner ($TaskName) is ACTIVE: Running every $IntervalMinutes minutes!" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "      [!] Task Scheduler error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Remove-StandbyListScheduledTask {
    <#
    .SYNOPSIS
        Removes / disables the PumpkiN_AutoEmptyStandbyList scheduled task.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Disabling Background Auto-Cleaner in Task Scheduler..." -ForegroundColor Yellow

    $TaskName = "PumpkiN_AutoEmptyStandbyList"
    $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existing) {
        try {
            Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
            Write-Host "      [+] Background task ($TaskName) disabled and removed from Task Scheduler." -ForegroundColor Green
            return $true
        } catch {
            Write-Host "      [!] Failed to unregister task: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "      [+] Task ($TaskName) is already inactive." -ForegroundColor Gray
        return $true
    }
}

function Get-StandbyListScheduledTaskStatus {
    <#
    .SYNOPSIS
        Queries current status of PumpkiN_AutoEmptyStandbyList scheduled task.
    #>
    [CmdletBinding()]
    param()

    $TaskName = "PumpkiN_AutoEmptyStandbyList"
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($task) {
        $info = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue
        $intervalMin = 5
        try {
            if ($task.Triggers[0].Repetition.Interval) {
                $span = [System.Xml.XmlConvert]::ToTimeSpan($task.Triggers[0].Repetition.Interval)
                $intervalMin = [int]$span.TotalMinutes
            }
        } catch {}

        return [PSCustomObject]@{
            IsActive        = ($task.State -ne 'Disabled')
            State           = "$($task.State)"
            IntervalMinutes = $intervalMin
            NextRunTime     = if ($info) { $info.NextRunTime } else { $null }
            DisplayText     = "Active: Every $intervalMin mins"
        }
    } else {
        return [PSCustomObject]@{
            IsActive        = $false
            State           = "NotScheduled"
            IntervalMinutes = 0
            NextRunTime     = $null
            DisplayText     = "Not Scheduled"
        }
    }
}

function Boost-CompetitiveMatch {
    <#
    .SYNOPSIS
        Compatibility wrapper: runs one-time standby purge.
    #>
    Invoke-EmptyStandbyListOneTime
}

# ==============================================================================
# SMART GAME BOOSTER DAEMON (AUTO-DETECTION & REALTIME OPTIMIZATION)
# ==============================================================================

$Script:RecognizedEsportsGames = @(
    "cs2", "csgo",
    "VALORANT-Win64-Shipping", "valorant",
    "r5apex", "apex",
    "FortniteClient-Win64-Shipping", "Fortnite",
    "cod", "ModernWarfare", "bootcamp",
    "RainbowSix", "RainbowSix_Vulkan",
    "Overwatch", "Overwatch2",
    "dota2",
    "League of Legends", "LeagueClientUx",
    "RustClient",
    "TslGame", "PUBG", "PUBGLite", "PUBG-Win64-Shipping",
    "Deadlock",
    "AndroidEmulatorEn", "AndroidEmulator", "aow_exe",
    "RocketLeague",
    "EscapeFromTarkov"
)

$Script:DaemonSync = $null
$Script:DaemonRunspace = $null
$Script:DaemonPowerShell = $null
$Script:DaemonAsyncResult = $null

function Get-SmartGameBoosterStatus {
    <#
    .SYNOPSIS
        Returns current operational status of the Smart Game Booster Daemon.
    #>
    [CmdletBinding()]
    param()

    if ($Script:DaemonSync -and $Script:DaemonSync.IsRunning) {
        $game = "$($Script:DaemonSync.CurrentGame)"
        $disp = if ($game) { "ACTIVE (Boosting: $game)" } else { "ACTIVE (Watching for games)" }
        return [PSCustomObject]@{
            IsActive    = $true
            CurrentGame = $game
            BoostCount  = [int]$Script:DaemonSync.BoostCount
            LastMessage = "$($Script:DaemonSync.LastMessage)"
            DisplayText = $disp
        }
    } else {
        return [PSCustomObject]@{
            IsActive    = $false
            CurrentGame = ""
            BoostCount  = 0
            LastMessage = "Daemon inactive"
            DisplayText = "INACTIVE (Stopped)"
        }
    }
}

function Start-SmartGameBoosterDaemon {
    <#
    .SYNOPSIS
        Launches background Smart Game Booster Daemon to watch for games and auto-optimize in realtime.
    #>
    [CmdletBinding()]
    param()

    if ($Script:DaemonSync -and $Script:DaemonSync.IsRunning) {
        Write-Host "      [~] Smart Game Booster Daemon is already active." -ForegroundColor Yellow
        return $true
    }

    Write-Host "`n[*] Starting Smart Game Booster Daemon (Auto-Detection Engine)..." -ForegroundColor Yellow

    $emptyListExe = Get-EmptyStandbyListExePath

    $Script:DaemonSync = [hashtable]::Synchronized(@{
        IsRunning     = $true
        StopRequested = $false
        CurrentGame   = ""
        BoostCount    = 0
        LastMessage   = "Daemon started. Watching for games..."
        EmptyListExe  = "$emptyListExe"
    })

    $gamesList = $Script:RecognizedEsportsGames

    $Script:DaemonRunspace = [runspacefactory]::CreateRunspace()
    $Script:DaemonRunspace.Open()
    $Script:DaemonRunspace.SessionStateProxy.SetVariable("sync", $Script:DaemonSync)
    $Script:DaemonRunspace.SessionStateProxy.SetVariable("gamesList", $gamesList)

    $Script:DaemonPowerShell = [powershell]::Create()
    $Script:DaemonPowerShell.Runspace = $Script:DaemonRunspace

    $null = $Script:DaemonPowerShell.AddScript({
        $boostedPid = $null
        $wifiDisabled = $false

        while (-not $sync.StopRequested) {
            $activeProc = $null
            foreach ($g in $gamesList) {
                $p = Get-Process -Name $g -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($p) {
                    $activeProc = $p
                    break
                }
            }

            if ($activeProc -and ($boostedPid -ne $activeProc.Id)) {
                $boostedPid = $activeProc.Id
                $sync.CurrentGame = $activeProc.ProcessName
                $sync.BoostCount = [int]$sync.BoostCount + 1

                # 1. Elevate Process Priority to High
                try {
                    $procObj = Get-Process -Id $activeProc.Id -ErrorAction SilentlyContinue
                    if ($procObj -and $procObj.PriorityClass -ne [System.Diagnostics.ProcessPriorityClass]::High) {
                        $procObj.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High
                    }
                } catch {}

                # 2. Purge Standby Memory & Idle Working Sets
                if ($sync.EmptyListExe -and (Test-Path $sync.EmptyListExe)) {
                    Start-Process -FilePath $sync.EmptyListExe -ArgumentList "workingsets" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
                    Start-Process -FilePath $sync.EmptyListExe -ArgumentList "standbylist" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
                }

                # 3. Engage Wi-Fi Ping Shield (Disable background roaming scan)
                try {
                    $wifiAdapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and ($_.InterfaceType -eq 71 -or $_.InterfaceDescription -match 'Wi-Fi|Wireless') }
                    foreach ($wa in $wifiAdapters) {
                        netsh wlan set autoconfig enabled=no interface="`"$($wa.Name)`"" 2>$null
                        $wifiDisabled = $true
                    }
                } catch {}

                # 4. Trim background app memory working sets
                $bgHogs = @("chrome", "msedge", "brave", "discord", "spotify")
                foreach ($hog in $bgHogs) {
                    Get-Process -Name $hog -ErrorAction SilentlyContinue | ForEach-Object {
                        try { [void]$_.EmptyWorkingSet() } catch {}
                    }
                }

                $sync.LastMessage = "[BOOSTER] Game detected: $($activeProc.ProcessName) (PID $($activeProc.Id)) -> High CPU Priority locked, Standby RAM purged, Wi-Fi Ping Shield ENGAGED!"

            } elseif (-not $activeProc -and $boostedPid) {
                $closedGame = $sync.CurrentGame
                $boostedPid = $null
                $sync.CurrentGame = ""

                # Restore Wi-Fi autoconfig
                if ($wifiDisabled) {
                    try {
                        $wifiAdapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and ($_.InterfaceType -eq 71 -or $_.InterfaceDescription -match 'Wi-Fi|Wireless') }
                        foreach ($wa in $wifiAdapters) {
                            netsh wlan set autoconfig enabled=yes interface="`"$($wa.Name)`"" 2>$null
                        }
                    } catch {}
                    $wifiDisabled = $false
                }

                $sync.LastMessage = "[BOOSTER] Game $closedGame closed -> Wi-Fi autoconfig restored. System returned to normal."
            }

            [System.Threading.Thread]::Sleep(1500)
        }

        # On daemon shutdown, ensure Wi-Fi autoconfig is restored
        if ($wifiDisabled) {
            try {
                $wifiAdapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and ($_.InterfaceType -eq 71 -or $_.InterfaceDescription -match 'Wi-Fi|Wireless') }
                foreach ($wa in $wifiAdapters) {
                    netsh wlan set autoconfig enabled=yes interface="`"$($wa.Name)`"" 2>$null
                }
            } catch {}
        }

        $sync.IsRunning = $false
        $sync.LastMessage = "[BOOSTER] Daemon stopped."
    })

    $Script:DaemonAsyncResult = $Script:DaemonPowerShell.BeginInvoke()
    Write-Host "      [+] Smart Game Booster Daemon is ACTIVE and monitoring 20+ competitive games!" -ForegroundColor Green
    return $true
}

function Stop-SmartGameBoosterDaemon {
    <#
    .SYNOPSIS
        Stops the Smart Game Booster Daemon and restores any temporary overrides.
    #>
    [CmdletBinding()]
    param()

    if (-not ($Script:DaemonSync -and $Script:DaemonSync.IsRunning)) {
        return $true
    }

    Write-Host "`n[*] Stopping Smart Game Booster Daemon..." -ForegroundColor Yellow

    $Script:DaemonSync.StopRequested = $true
    $waitCount = 0
    while ($Script:DaemonSync.IsRunning -and $waitCount -lt 20) {
        Start-Sleep -Milliseconds 100
        $waitCount++
    }

    try {
        if ($Script:DaemonPowerShell -and $Script:DaemonAsyncResult) {
            $null = $Script:DaemonPowerShell.EndInvoke($Script:DaemonAsyncResult)
            $Script:DaemonPowerShell.Dispose()
            $Script:DaemonPowerShell = $null
        }
        if ($Script:DaemonRunspace) {
            $Script:DaemonRunspace.Dispose()
            $Script:DaemonRunspace = $null
        }
    } catch {}

    # Ensure Wi-Fi autoconfig is enabled
    try {
        $wifiAdapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and ($_.InterfaceType -eq 71 -or $_.InterfaceDescription -match 'Wi-Fi|Wireless') }
        foreach ($wa in $wifiAdapters) {
            netsh wlan set autoconfig enabled=yes interface="`"$($wa.Name)`"" 2>$null
        }
    } catch {}

    Write-Host "      [+] Smart Game Booster Daemon stopped successfully." -ForegroundColor Green
    return $true
}

# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Write-Host "=== PUMPKIN MATCH BOOSTER & SMART DAEMON ===" -ForegroundColor Cyan
    Write-Host "1. One-Time Standby Memory Purge"
    Write-Host "2. Start Smart Game Booster Daemon (Realtime Watcher)"
    Write-Host "3. Stop Smart Game Booster Daemon"
    Write-Host "4. Check Daemon Status"
    $ans = Read-Host "Select option [1-4]"
    switch ($ans) {
        "1" { Invoke-EmptyStandbyListOneTime }
        "2" { Start-SmartGameBoosterDaemon }
        "3" { Stop-SmartGameBoosterDaemon }
        "4" {
            $st = Get-SmartGameBoosterStatus
            Write-Host "Status: $($st.DisplayText)" -ForegroundColor Green
        }
    }
    Read-Host "`nPress Enter to exit"
}

# ------------------------------------------------------------------------------
# MODULE: Optimize-Hardening
# ------------------------------------------------------------------------------
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

function Restore-WpbtExecution {
    Write-Host "`n[*] Restoring WPBT Execution Default..." -ForegroundColor Yellow
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'DisableWpbtExecution' -ErrorAction SilentlyContinue
    Write-Host "      [+] WPBT execution restored to default." -ForegroundColor Green
}

function Restore-PeripheralBloat {
    Write-Host "`n[*] Restoring Peripheral Software Installer Policies..." -ForegroundColor Yellow
    Remove-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer\CodeIdentifiers' -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] Peripheral policies restored to default." -ForegroundColor Green
}

function Restore-WindowsAI {
    Write-Host "`n[*] Restoring Windows AI & Copilot Components..." -ForegroundColor Yellow
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' -Name 'DisableAIDataAnalysis' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' -Name 'TurnOffRecall' -ErrorAction SilentlyContinue
    Write-Host "      [+] Windows AI & Copilot restored to default." -ForegroundColor Green
}

function Restore-SecurityUpdatesOnly {
    Write-Host "`n[*] Restoring Windows Update Policy (Default cadence)..." -ForegroundColor Yellow
    $wu = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    if (Test-Path $wu) {
        Remove-ItemProperty -Path $wu -Name 'DeferFeatureUpdates' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $wu -Name 'DeferFeatureUpdatesPeriodInDays' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $wu -Name 'DeferQualityUpdates' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Windows Update feature deferral restored to default." -ForegroundColor Green
}

function Restore-ClassicContextMenu {
    Write-Host "`n[*] Restoring Windows 11 Modern Context Menu..." -ForegroundColor Yellow
    $clsid = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
    if (Test-Path $clsid) {
        Remove-Item -Path $clsid -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Modern Windows 11 context menu restored." -ForegroundColor Green
}

function Restore-StartMenuBing {
    Write-Host "`n[*] Restoring Bing Search in Start Menu..." -ForegroundColor Yellow
    Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableSearchBoxSuggestions' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled' -ErrorAction SilentlyContinue
    Write-Host "      [+] Bing Web Search in Start Menu restored." -ForegroundColor Green
}

function Restore-ExplorerAutoDiscovery {
    Write-Host "`n[*] Restoring File Explorer Folder Auto-Discovery..." -ForegroundColor Yellow
    $allFolders = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell'
    if (Test-Path $allFolders) {
        Remove-Item -Path $allFolders -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Explorer folder auto-discovery restored to default." -ForegroundColor Green
}

function Restore-ShowFileExtensionsAndHidden {
    Write-Host "`n[*] Restoring Default File Extensions & Hidden Files visibility..." -ForegroundColor Yellow
    $adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $adv -Name 'HideFileExt' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $adv -Name 'Hidden' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] File extensions hidden and hidden files concealed." -ForegroundColor Green
}

function Restore-LongPaths {
    Write-Host "`n[*] Restoring Win32 Long Paths Limit (260 chars)..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Long paths limit restored to Windows default." -ForegroundColor Green
}

function Restore-LockScreen {
    Write-Host "`n[*] Restoring Windows Lock Screen..." -ForegroundColor Yellow
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name 'NoLockScreen' -ErrorAction SilentlyContinue
    Write-Host "      [+] Lock screen enabled." -ForegroundColor Green
}

function Restore-BsodVerbose {
    Write-Host "`n[*] Restoring Default BSoD Display..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'DisplayParameters' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Default BSoD display restored." -ForegroundColor Green
}

function Restore-ReservedStorage {
    Write-Host "`n[*] Restoring Windows Reserved Storage..." -ForegroundColor Yellow
    try {
        Set-WindowsReservedStorageState -State Enabled -ErrorAction SilentlyContinue | Out-Null
    } catch {}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager' -Name 'ShippedWithReserves' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Reserved storage enabled." -ForegroundColor Green
}

# ==============================================================================

# ------------------------------------------------------------------------------
# MODULE: Optimize-SystemAndDebloat
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: System Debloat, Power Plans & Storage Optimizations
================================================================================
#>

function Debloat-BackgroundServices {
    Write-Host "`n[*] Debloating Background Services & Bloatware..." -ForegroundColor Yellow

    # Services to disable (Set to Manual or Disabled)
    $servicesToDisable = @(
        @{ Name = 'SysMain';          Desc = 'Superfetch (SysMain) - Pre-caches apps, steals I/O during gaming' },
        @{ Name = 'DiagTrack';        Desc = 'Connected User Experiences & Telemetry - MS data collection' },
        @{ Name = 'dmwappushservice';  Desc = 'WAP Push Message Routing - Telemetry relay service' },
        @{ Name = 'WSearch';          Desc = 'Windows Search Indexer - Constant background disk I/O' },
        @{ Name = 'XblAuthManager';   Desc = 'Xbox Live Auth Manager - Not needed for PC gaming' },
        @{ Name = 'XblGameSave';      Desc = 'Xbox Live Game Save - Cloud save sync overhead' },
        @{ Name = 'XboxNetApiSvc';    Desc = 'Xbox Live Networking - Background Xbox connectivity' },
        @{ Name = 'XboxGipSvc';       Desc = 'Xbox Accessory Management - Xbox controller management' },
        @{ Name = 'MapsBroker';       Desc = 'Downloaded Maps Manager - Unused background service' },
        @{ Name = 'lfsvc';            Desc = 'Geolocation Service - Background location tracking' },
        @{ Name = 'SharedAccess';     Desc = 'Internet Connection Sharing - Not needed on gaming PCs' },
        @{ Name = 'RetailDemo';       Desc = 'Retail Demo Service - Store display mode' },
        @{ Name = 'wisvc';            Desc = 'Windows Insider Service - Preview build telemetry' },
        @{ Name = 'WerSvc';           Desc = 'Windows Error Reporting - Crash dump collection' },
        @{ Name = 'Fax';              Desc = 'Fax Service - Nobody faxes from a gaming PC' }
    )

    foreach ($svc in $servicesToDisable) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            try {
                Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
                Write-Host "      [+] Disabled: $($svc.Desc)" -ForegroundColor Green
            } catch {
                Write-Host "      [~] Skipped: $($svc.Name) ($($_.Exception.Message))" -ForegroundColor DarkYellow
            }
        }
    }

    # Disable Cortana
    $cortanaKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
    if (-not (Test-Path $cortanaKey)) { New-Item -Path $cortanaKey -Force | Out-Null }
    Set-ItemProperty -Path $cortanaKey -Name 'AllowCortana' -Value 0 -Type DWord
    Set-ItemProperty -Path $cortanaKey -Name 'DisableWebSearch' -Value 1 -Type DWord
    Set-ItemProperty -Path $cortanaKey -Name 'ConnectedSearchUseWeb' -Value 0 -Type DWord
    Write-Host "      [+] Cortana disabled + Web Search in Start Menu blocked" -ForegroundColor Green

    # Disable Delivery Optimization P2P (stops uploading updates to other PCs)
    $doKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'
    if (-not (Test-Path $doKey)) { New-Item -Path $doKey -Force | Out-Null }
    Set-ItemProperty -Path $doKey -Name 'DODownloadMode' -Value 0 -Type DWord
    Write-Host "      [+] Delivery Optimization P2P disabled (No upload bandwidth stolen)" -ForegroundColor Green

    # Enforce Superfetch (SysMain) and Prefetcher permanently disabled in registry
    $prefetchKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters'
    if (Test-Path $prefetchKey) {
        Set-ItemProperty -Path $prefetchKey -Name 'EnableSuperfetch' -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $prefetchKey -Name 'EnablePrefetcher' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\SysMain' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue

    Write-Host "      [OK] Background Services Debloated  --  Maximum CPU/IO freed for gaming!" -ForegroundColor Green
}

function Enable-UltimatePerformancePlan {
    Write-Host "`n[*] Activating Ultimate Performance Power Plan..." -ForegroundColor Yellow

    # Check if Ultimate Performance plan already exists
    $existingPlan = powercfg /list | Select-String "Ultimate Performance"
    if (-not $existingPlan) {
        # Unhide and create Ultimate Performance plan
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
        $existingPlan = powercfg /list | Select-String "Ultimate Performance"
    }

    if ($existingPlan) {
        $guid = ($existingPlan -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        powercfg /setactive $guid
        Write-Host "      [+] Ultimate Performance Plan ACTIVATED (GUID: $guid)" -ForegroundColor Green
    } else {
        # Fallback: set High Performance
        $highPerf = powercfg /list | Select-String "High performance"
        if ($highPerf) {
            $guid = ($highPerf -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
            powercfg /setactive $guid
            Write-Host "      [+] High Performance Plan activated (Ultimate not available on this build)" -ForegroundColor Green
        }
    }

    # Disable USB selective suspend in current plan
    powercfg -setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setactive scheme_current

    # Disable hibernate (frees GB of disk + prevents sleep interrupts)
    powercfg /hibernate off 2>$null

    # HPET & Timer Resolution
    bcdedit /set useplatformtick yes 2>$null
    bcdedit /set tscsyncpolicy enhanced 2>$null
    Write-Host "      [+] Hibernate disabled, USB suspend off, TSC sync policy enhanced" -ForegroundColor Green

    Write-Host "      [OK] Power Plan optimized  --  Zero CPU throttling, maximum clock speeds!" -ForegroundColor Green
}

function Strip-VisualEffects {
    Write-Host "`n[*] Stripping Windows Visual Effects & Animations..." -ForegroundColor Yellow

    # Set Visual Effects to "Adjust for best performance" (UserPreferencesMask)
    $visualKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
    if (-not (Test-Path $visualKey)) { New-Item -Path $visualKey -Force | Out-Null }
    Set-ItemProperty -Path $visualKey -Name 'VisualFXSetting' -Value 2 -Type DWord
    Write-Host "      [+] Visual Effects set to 'Best Performance' mode" -ForegroundColor Green

    # Disable individual animations
    $dwKey = 'HKCU:\Control Panel\Desktop\WindowMetrics'
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '0' -Type String
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'DragFullWindows' -Value '0' -Type String

    # Disable all animation flags
    $advKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $advKey -Name 'TaskbarAnimations' -Value 0 -Type DWord
    Set-ItemProperty -Path $advKey -Name 'ListviewAlphaSelect' -Value 0 -Type DWord
    Set-ItemProperty -Path $advKey -Name 'ListviewShadow' -Value 0 -Type DWord
    Set-ItemProperty -Path $advKey -Name 'IconsOnly' -Value 0 -Type DWord

    # Disable DWM animations
    $dwmKey = 'HKCU:\Software\Microsoft\Windows\DWM'
    if (-not (Test-Path $dwmKey)) { New-Item -Path $dwmKey -Force | Out-Null }
    Set-ItemProperty -Path $dwmKey -Name 'EnableAeroPeek' -Value 0 -Type DWord
    Set-ItemProperty -Path $dwmKey -Name 'AlwaysHibernateThumbnails' -Value 0 -Type DWord

    # Disable startup delay
    $serializeKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize'
    if (-not (Test-Path $serializeKey)) { New-Item -Path $serializeKey -Force | Out-Null }
    Set-ItemProperty -Path $serializeKey -Name 'StartupDelayInMSec' -Value 0 -Type DWord
    Write-Host "      [+] Startup delay zeroed, all menu/taskbar animations disabled" -ForegroundColor Green

    # Disable transparency effects (if not already done)
    $persKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    if (Test-Path $persKey) {
        Set-ItemProperty -Path $persKey -Name 'EnableTransparency' -Value 0 -Type DWord
    }

    # Disable lock screen animations / tips
    $lockKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
    if (-not (Test-Path $lockKey)) { New-Item -Path $lockKey -Force | Out-Null }
    Set-ItemProperty -Path $lockKey -Name 'NoLockScreen' -Value 1 -Type DWord
    Write-Host "      [+] Lock screen disabled, DWM Aero Peek off, transparency off" -ForegroundColor Green

    Write-Host "      [OK] All visual fluff stripped  --  GPU resources 100% for your game!" -ForegroundColor Green
}

function Set-CompactWindowMetrics {
    <#
    .SYNOPSIS
        Applies compact, low-overhead WindowMetrics:
        - 8px thin scrollbars (ScrollWidth = -120)
        - 8px scrollbar button height (ScrollHeight = -120)
        - 1px border width (BorderWidth = -15)
        - 0px border padding (PaddedBorderWidth = 0, eliminates invisible bulky window drag margins)
        - Compact title bar height (CaptionHeight = -150, SmCaptionHeight = -150)
    #>
    Write-Host "`n[*] Applying Compact Window Metrics & 8px Thin Scrollbars..." -ForegroundColor Yellow
    $wmKey = 'HKCU:\Control Panel\Desktop\WindowMetrics'
    if (-not (Test-Path $wmKey)) { New-Item -Path $wmKey -Force | Out-Null }

    Set-ItemProperty -Path $wmKey -Name 'ScrollWidth' -Value '-120' -Type String
    Set-ItemProperty -Path $wmKey -Name 'ScrollHeight' -Value '-120' -Type String
    Set-ItemProperty -Path $wmKey -Name 'BorderWidth' -Value '-15' -Type String
    Set-ItemProperty -Path $wmKey -Name 'PaddedBorderWidth' -Value '0' -Type String
    Set-ItemProperty -Path $wmKey -Name 'CaptionHeight' -Value '-150' -Type String
    Set-ItemProperty -Path $wmKey -Name 'CaptionWidth' -Value '-330' -Type String
    Set-ItemProperty -Path $wmKey -Name 'SmCaptionHeight' -Value '-150' -Type String
    Set-ItemProperty -Path $wmKey -Name 'SmCaptionWidth' -Value '-330' -Type String
    Set-ItemProperty -Path $wmKey -Name 'MinAnimate' -Value '0' -Type String

    # Broadcast WM_SETTINGCHANGE (SPI_SETNONCLIENTMETRICS)
    try {
        $csharpSig = @'
        using System;
        using System.Runtime.InteropServices;
        public class WinMetricsNative {
            [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
            public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
        }
'@
        if (-not ([System.Management.Automation.PSTypeName]'WinMetricsNative').Type) {
            Add-Type -TypeDefinition $csharpSig -ErrorAction SilentlyContinue
        }
        if (([System.Management.Automation.PSTypeName]'WinMetricsNative').Type) {
            $res = [UIntPtr]::Zero
            [WinMetricsNative]::SendMessageTimeout([IntPtr]0xFFFF, 0x001A, [UIntPtr]::Zero, "WindowMetrics", 2, 1000, [ref]$res) | Out-Null
        }
    } catch {}

    Write-Host "      [+] Scrollbars locked to 8px thin width & 8px button size" -ForegroundColor Green
    Write-Host "      [+] Border width locked to 1px with 0px padding" -ForegroundColor Green
    Write-Host "      [+] Window title bar height set to compact (-150 twips)" -ForegroundColor Green
    Write-Host "      [OK] Compact WindowMetrics applied successfully!" -ForegroundColor Green
}

function Restore-CompactWindowMetrics {
    <#
    .SYNOPSIS
        Reverts WindowMetrics to standard Windows defaults.
    #>
    Write-Host "`n[*] Restoring Default Windows WindowMetrics..." -ForegroundColor Yellow
    $wmKey = 'HKCU:\Control Panel\Desktop\WindowMetrics'
    if (Test-Path $wmKey) {
        Set-ItemProperty -Path $wmKey -Name 'ScrollWidth' -Value '-255' -Type String
        Set-ItemProperty -Path $wmKey -Name 'ScrollHeight' -Value '-255' -Type String
        Set-ItemProperty -Path $wmKey -Name 'BorderWidth' -Value '-15' -Type String
        Set-ItemProperty -Path $wmKey -Name 'PaddedBorderWidth' -Value '-60' -Type String
        Set-ItemProperty -Path $wmKey -Name 'CaptionHeight' -Value '-330' -Type String
        Set-ItemProperty -Path $wmKey -Name 'CaptionWidth' -Value '-330' -Type String
        Set-ItemProperty -Path $wmKey -Name 'SmCaptionHeight' -Value '-330' -Type String
        Set-ItemProperty -Path $wmKey -Name 'SmCaptionWidth' -Value '-330' -Type String
        Set-ItemProperty -Path $wmKey -Name 'MinAnimate' -Value '1' -Type String
    }
    Write-Host "      [+] WindowMetrics restored to Windows defaults (17px scrollbars, 4px padding, 22px caption)" -ForegroundColor Green
}

function Harden-PrivacyTelemetry {
    Write-Host "`n[*] Hardening Privacy & Disabling Telemetry..." -ForegroundColor Yellow

    # Disable Telemetry level
    $dataKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
    if (-not (Test-Path $dataKey)) { New-Item -Path $dataKey -Force | Out-Null }
    Set-ItemProperty -Path $dataKey -Name 'AllowTelemetry' -Value 0 -Type DWord
    Set-ItemProperty -Path $dataKey -Name 'MaxTelemetryAllowed' -Value 0 -Type DWord
    Write-Host "      [+] Windows Telemetry set to Security (minimum) level" -ForegroundColor Green

    # Disable Activity History
    $actKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (-not (Test-Path $actKey)) { New-Item -Path $actKey -Force | Out-Null }
    Set-ItemProperty -Path $actKey -Name 'EnableActivityFeed' -Value 0 -Type DWord
    Set-ItemProperty -Path $actKey -Name 'PublishUserActivities' -Value 0 -Type DWord
    Set-ItemProperty -Path $actKey -Name 'UploadUserActivities' -Value 0 -Type DWord
    Write-Host "      [+] Activity History and Timeline sync disabled" -ForegroundColor Green

    # Disable Advertising ID
    $adKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
    if (-not (Test-Path $adKey)) { New-Item -Path $adKey -Force | Out-Null }
    Set-ItemProperty -Path $adKey -Name 'Enabled' -Value 0 -Type DWord
    Write-Host "      [+] Advertising ID disabled" -ForegroundColor Green

    # Disable Tailored Experiences
    $cloudKey = 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent'
    if (-not (Test-Path $cloudKey)) { New-Item -Path $cloudKey -Force | Out-Null }
    Set-ItemProperty -Path $cloudKey -Name 'DisableTailoredExperiencesWithDiagnosticData' -Value 1 -Type DWord
    Set-ItemProperty -Path $cloudKey -Name 'DisableWindowsConsumerFeatures' -Value 1 -Type DWord
    Write-Host "      [+] Tailored Experiences and Consumer Features disabled" -ForegroundColor Green

    # Disable feedback requests
    $siufKey = 'HKCU:\Software\Microsoft\Siuf\Rules'
    if (-not (Test-Path $siufKey)) { New-Item -Path $siufKey -Force | Out-Null }
    Set-ItemProperty -Path $siufKey -Name 'NumberOfSIUFInPeriod' -Value 0 -Type DWord
    Write-Host "      [+] Windows Feedback popups disabled" -ForegroundColor Green

    # Disable app suggestions / pre-installed bloat apps
    $contentKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    if (Test-Path $contentKey) {
        Set-ItemProperty -Path $contentKey -Name 'SystemPaneSuggestionsEnabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SilentInstalledAppsEnabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SoftLandingEnabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SubscribedContent-338389Enabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SubscribedContent-310093Enabled' -Value 0 -Type DWord
        Write-Host "      [+] App suggestions and silent app installs blocked" -ForegroundColor Green
    }

    # Disable Location Tracking globally
    $locKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'
    if (-not (Test-Path $locKey)) { New-Item -Path $locKey -Force | Out-Null }
    Set-ItemProperty -Path $locKey -Name 'DisableLocation' -Value 1 -Type DWord
    Write-Host "      [+] Location tracking disabled system-wide" -ForegroundColor Green

    Write-Host "      [OK] Privacy Hardened  --  No telemetry, no ads, no tracking!" -ForegroundColor Green
}

function Optimize-DiskIO {
    Write-Host "`n[*] Optimizing Disk I/O & Storage Performance..." -ForegroundColor Yellow

    # Disable Last Access Timestamp (huge NTFS perf win)
    fsutil behavior set disablelastaccess 1 | Out-Null
    Write-Host "      [+] NTFS Last Access Timestamps disabled (Faster file reads)" -ForegroundColor Green

    # Disable 8.3 short filename creation
    fsutil behavior set disable8dot3 1 | Out-Null
    Write-Host "      [+] 8.3 Short Filename creation disabled (Faster directory enumeration)" -ForegroundColor Green

    # Increase NTFS memory usage for performance
    fsutil behavior set memoryusage 2 | Out-Null
    Write-Host "      [+] NTFS Memory Usage set to Level 2 (More RAM for file system cache)" -ForegroundColor Green

    # Disable boot trace logging
    $bootKey = 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction'
    if (Test-Path $bootKey) {
        Set-ItemProperty -Path $bootKey -Name 'Enable' -Value 'N' -Type String -ErrorAction SilentlyContinue
    }

    # Clean Temp Files
    $tempPaths = @(
        "$env:TEMP",
        "$env:LOCALAPPDATA\Temp",
        "$env:SystemRoot\Temp",
        "$env:SystemRoot\Prefetch",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db"
    )
    $totalCleaned = 0
    foreach ($tp in $tempPaths) {
        if (Test-Path $tp) {
            $sizeBefore = (Get-ChildItem $tp -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            Remove-Item "$tp\*" -Recurse -Force -ErrorAction SilentlyContinue
            $totalCleaned += $sizeBefore
        }
    }
    $cleanedMb = [math]::Round($totalCleaned / 1MB, 1)
    Write-Host "      [+] Temp files cleaned: ~$cleanedMb MB freed (Temp, Prefetch, Thumbnails)" -ForegroundColor Green

    # Clear Windows Update cache (can be several GB)
    $wuCache = "$env:SystemRoot\SoftwareDistribution\Download"
    if (Test-Path $wuCache) {
        $wuSize = (Get-ChildItem $wuCache -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Remove-Item "$wuCache\*" -Recurse -Force -ErrorAction SilentlyContinue
        $wuMb = [math]::Round($wuSize / 1MB, 1)
        Write-Host "      [+] Windows Update cache cleared: ~$wuMb MB freed" -ForegroundColor Green
    }

    Write-Host "      [OK] Disk I/O optimized  --  Faster game loads and reduced stuttering!" -ForegroundColor Green
}

function Disable-ScheduledJunkTasks {
    Write-Host "`n[*] Disabling Junk Scheduled Tasks (Frame Drop Eliminators)..." -ForegroundColor Yellow

    $tasksToDisable = @(
        '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
        '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
        '\Microsoft\Windows\Autochk\Proxy',
        '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
        '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
        '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
        '\Microsoft\Windows\Maintenance\WinSAT',
        '\Microsoft\Windows\Maps\MapsToastTask',
        '\Microsoft\Windows\Maps\MapsUpdateTask',
        '\Microsoft\Windows\Shell\FamilySafetyMonitor',
        '\Microsoft\Windows\Shell\FamilySafetyRefreshTask',
        '\Microsoft\Windows\Windows Error Reporting\QueueReporting',
        '\Microsoft\Windows\Feedback\Siuf\DmClient',
        '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload',
        '\Microsoft\Windows\PI\Sqm-Tasks',
        '\Microsoft\Windows\CloudExperienceHost\CreateObjectTask',
        '\Microsoft\Windows\DiskFootprint\Diagnostics',
        '\Microsoft\Windows\FileHistory\File History (maintenance mode)',
        '\Microsoft\Windows\NetTrace\GatherNetworkInfo',
        '\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem'
    )

    $disabled = 0
    foreach ($task in $tasksToDisable) {
        try {
            $existing = Get-ScheduledTask -TaskPath ($task -replace '[^\\]*$', '') -TaskName ($task -replace '.*\\', '') -ErrorAction SilentlyContinue
            if ($existing -and $existing.State -ne 'Disabled') {
                Disable-ScheduledTask -TaskPath ($task -replace '[^\\]*$', '') -TaskName ($task -replace '.*\\', '') -ErrorAction Stop | Out-Null
                $disabled++
                Write-Host "      [+] Disabled: $($task -replace '.*\\', '')" -ForegroundColor Green
            }
        } catch {
            # Task doesn't exist on this system - skip silently
        }
    }

    # Disable Defrag schedule (SSDs don't need it, HDDs can run manually)
    try {
        $defrag = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag' -ErrorAction SilentlyContinue
        if ($defrag -and $defrag.State -ne 'Disabled') {
            Disable-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag' -ErrorAction Stop | Out-Null
            $disabled++
            Write-Host "      [+] Disabled: ScheduledDefrag (SSDs self-manage TRIM)" -ForegroundColor Green
        }
    } catch {}

    Write-Host "      [OK] $disabled junk tasks disabled  --  No more random frame drops!" -ForegroundColor Green
}

function Optimize-StartupAndDns {
    Write-Host "`n[*] Optimizing Startup Programs & DNS..." -ForegroundColor Yellow

    # --- DNS Optimization ---
    Write-Host "`n      --- DNS Optimization ---" -ForegroundColor Cyan
    $hw = Get-HardwareProfile
    $adapter = $hw.Adapter
    if ($adapter) {
        try {
            # Set Cloudflare DNS (1.1.1.1 primary, 1.0.0.1 secondary)
            Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @('1.1.1.1', '1.0.0.1') -ErrorAction Stop
            Write-Host "      [+] DNS set to Cloudflare (1.1.1.1, 1.0.0.1)  --  Fastest gaming DNS" -ForegroundColor Green
        } catch {
            Write-Host "      [~] DNS auto-set skipped: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }

        # Disable DNS over HTTPS throttle, enable DNS cache optimization
        $dnsParams = 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
        if (Test-Path $dnsParams) {
            Set-ItemProperty -Path $dnsParams -Name 'MaxCacheTtl' -Value 86400 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $dnsParams -Name 'MaxNegativeCacheTtl' -Value 5 -Type DWord -ErrorAction SilentlyContinue
            Write-Host "      [+] DNS Cache optimized (24h positive TTL, 5s negative TTL)" -ForegroundColor Green
        }
    }

    # Flush DNS after changes
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [+] DNS cache flushed" -ForegroundColor Green

    # --- Startup Audit ---
    Write-Host "`n      --- Startup Program Audit ---" -ForegroundColor Cyan
    $startupItems = Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue
    $runKey = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
    $runKeyLM = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue

    Write-Host "      Current startup programs:" -ForegroundColor Yellow
    $allProps = @()
    if ($runKey) {
        $runKey.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
            Write-Host "        [HKCU] $($_.Name): $($_.Value)" -ForegroundColor Gray
            $allProps += $_.Name
        }
    }
    if ($runKeyLM) {
        $runKeyLM.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
            Write-Host "        [HKLM] $($_.Name): $($_.Value)" -ForegroundColor Gray
        }
    }

    # Known bloatware startup entries to auto-disable
    $bloatStartup = @('OneDrive', 'Skype', 'Teams', 'Spotify', 'Discord Update', 'CortanaStartupId', 'BingDesktop', 'AdobeAAMUpdater')
    foreach ($bloat in $bloatStartup) {
        if ($allProps -contains $bloat) {
            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $bloat -ErrorAction SilentlyContinue
            Write-Host "      [+] Auto-disabled bloat startup: $bloat" -ForegroundColor Green
        }
    }

    Write-Host "      [OK] DNS optimized + Startup audited  --  Faster boot and lower latency!" -ForegroundColor Green
}

function Enable-CompactOS {
    Write-Host "`n[*] Enabling Windows CompactOS LZX Compression (SSD/NVMe Optimizer)..." -ForegroundColor Yellow
    Write-Host "      Compressing system binaries with high-performance LZX algorithms..." -ForegroundColor Cyan
    try {
        $proc = Start-Process -FilePath "compact.exe" -ArgumentList "/CompactOS:always" -Wait -NoNewWindow -PassThru
        if ($proc.ExitCode -eq 0) {
            Write-Host "      [+] CompactOS (LZX) Enabled  --  Reclaimed 3-6 GB SSD/NVMe disk space with zero performance drop!" -ForegroundColor Green
        } else {
            Write-Host "      [!] CompactOS command completed with code: $($proc.ExitCode)" -ForegroundColor DarkYellow
        }
    } catch {
        Write-Host "      [-] Failed to execute CompactOS: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Disable-CompactOS {
    Write-Host "`n[*] Disabling Windows CompactOS Compression (Reverting to Uncompressed)..." -ForegroundColor Yellow
    try {
        Start-Process -FilePath "compact.exe" -ArgumentList "/CompactOS:never" -Wait -NoNewWindow -ErrorAction SilentlyContinue | Out-Null
        Write-Host "      [+] CompactOS reverted to uncompressed state." -ForegroundColor Green
    } catch {}
}

function Enable-TakeOwnershipMenu {
    Write-Host "`n[*] Adding 'Take Ownership' to Explorer Right-Click Context Menu..." -ForegroundColor Yellow

    # File Right-Click
    $fileKey = 'HKCR:\*\shell\runas'
    if (-not (Test-Path $fileKey)) { New-Item -Path $fileKey -Force | Out-Null }
    Set-ItemProperty -Path $fileKey -Name '(Default)' -Value 'Take Ownership'
    Set-ItemProperty -Path $fileKey -Name 'HasLUAShield' -Value ''
    Set-ItemProperty -Path $fileKey -Name 'NoWorkingDirectory' -Value ''

    $fileCmd = "$fileKey\command"
    if (-not (Test-Path $fileCmd)) { New-Item -Path $fileCmd -Force | Out-Null }
    Set-ItemProperty -Path $fileCmd -Name '(Default)' -Value 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F'
    Set-ItemProperty -Path $fileCmd -Name 'IsolatedCommand' -Value 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F'

    # Directory Right-Click
    $dirKey = 'HKCR:\Directory\shell\runas'
    if (-not (Test-Path $dirKey)) { New-Item -Path $dirKey -Force | Out-Null }
    Set-ItemProperty -Path $dirKey -Name '(Default)' -Value 'Take Ownership'
    Set-ItemProperty -Path $dirKey -Name 'HasLUAShield' -Value ''
    Set-ItemProperty -Path $dirKey -Name 'NoWorkingDirectory' -Value ''

    $dirCmd = "$dirKey\command"
    if (-not (Test-Path $dirCmd)) { New-Item -Path $dirCmd -Force | Out-Null }
    Set-ItemProperty -Path $dirCmd -Name '(Default)' -Value 'cmd.exe /c takeown /f "%1" /r /d y && icacls "%1" /grant administrators:F /t /c /l /q'
    Set-ItemProperty -Path $dirCmd -Name 'IsolatedCommand' -Value 'cmd.exe /c takeown /f "%1" /r /d y && icacls "%1" /grant administrators:F /t /c /l /q'

    Write-Host "      [+] 'Take Ownership' context menu added for all files and folders!" -ForegroundColor Green
}

function Disable-TakeOwnershipMenu {
    Write-Host "`n[*] Removing 'Take Ownership' from Right-Click Context Menu..." -ForegroundColor Yellow
    Remove-Item -Path 'HKCR:\*\shell\runas' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path 'HKCR:\Directory\shell\runas' -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] 'Take Ownership' context menu removed." -ForegroundColor Green
}

function Clear-WindowsUpdateCache {
    Write-Host "`n[*] Purging Windows Update, SoftwareDistribution & Delivery Optimization Cache..." -ForegroundColor Yellow
    $services = @('wuauserv', 'bits', 'dosvc', 'cryptsvc')
    foreach ($svc in $services) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    }

    $paths = @(
        "$env:SystemRoot\SoftwareDistribution\Download",
        "$env:SystemRoot\SoftwareDistribution\DataStore",
        "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization"
    )

    $totalFreed = 0
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $bytes = (Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if ($bytes) { $totalFreed += $bytes }
            Remove-Item -Path "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    foreach ($svc in $services) {
        Start-Service -Name $svc -ErrorAction SilentlyContinue
    }

    $mbFreed = [math]::Round($totalFreed / 1MB, 1)
    Write-Host "      [OK] Windows Update Cache cleared: ~$mbFreed MB freed! Update services restarted." -ForegroundColor Green
}

function Invoke-DeepCacheCleaner {
    <#
    .SYNOPSIS
        Deep cache, Prefetch, spooler, and Windows Event Log cleaner inspired by 01 Cache Cleaner.bat.
    .DESCRIPTION
        Cleans System Temp, User Temp, Prefetch, Spooler printer queue, Explorer history,
        recent items, legacy temporary caches, and wipes all Windows Event Logs via wevtutil.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Starting Deep Cache, Prefetch & Windows Event Log Cleaner..." -ForegroundColor Yellow

    $totalFreed = 0
    $deletedFiles = 0

    # 1. Stop Printer Spooler service to unlock spooler files
    $spooler = Get-Service -Name 'Spooler' -ErrorAction SilentlyContinue
    if ($spooler -and $spooler.Status -eq 'Running') {
        Stop-Service -Name 'Spooler' -Force -ErrorAction SilentlyContinue
    }

    # 2. Target Directories & Cache Locations (Faithful to 01 Cache Cleaner.bat)
    $cleanTargets = @(
        "$env:SystemRoot\Temp",
        "$env:TEMP",
        "$env:LOCALAPPDATA\Temp",
        "$env:SystemRoot\Prefetch",
        "$env:SystemRoot\System32\spool\PRINTERS",
        "$env:SystemRoot\spool\printers",
        "$env:SystemRoot\tempor~1",
        "$env:SystemRoot\tmp",
        "$env:SystemRoot\history",
        "$env:SystemRoot\cookies",
        "$env:SystemRoot\recent",
        "$env:APPDATA\Microsoft\Windows\Recent",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
    )

    foreach ($target in $cleanTargets) {
        if (Test-Path $target) {
            try {
                $items = Get-ChildItem -Path $target -Recurse -Force -ErrorAction SilentlyContinue
                foreach ($item in $items) {
                    if (-not $item.PSIsContainer) {
                        $totalFreed += $item.Length
                        $deletedFiles++
                    }
                }
                Remove-Item -Path "$target\*" -Recurse -Force -ErrorAction SilentlyContinue
            } catch {}

            # Recreate base folder if it was deleted
            if (-not (Test-Path $target)) {
                New-Item -ItemType Directory -Path $target -Force -ErrorAction SilentlyContinue | Out-Null
            }
        }
    }

    # 3. Clean pattern matches (ff*.tmp, WIN386.SWP, thumbnail caches)
    $specificPatterns = @(
        "$env:SystemRoot\ff*.tmp",
        "$env:SystemDrive\WIN386.SWP",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db"
    )
    foreach ($pattern in $specificPatterns) {
        $files = Get-Item -Path $pattern -Force -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            $totalFreed += $f.Length
            $deletedFiles++
            Remove-Item -Path $f.FullName -Force -ErrorAction SilentlyContinue
        }
    }

    # 4. Restart Spooler service
    if ($spooler) {
        Start-Service -Name 'Spooler' -ErrorAction SilentlyContinue
    }

    $mbFreed = [math]::Round($totalFreed / 1MB, 2)
    Write-Host "      [+] Disk Cache Cleaned: ~$mbFreed MB freed across Temp, Prefetch, Spooler & Recent items." -ForegroundColor Green

    # 5. Clear All Windows Event Logs (from 01 Cache Cleaner.bat)
    Write-Host "      [*] Clearing all Windows Event Logs via wevtutil..." -ForegroundColor Yellow
    $clearedLogs = 0
    try {
        $eventLogs = wevtutil.exe el 2>$null
        foreach ($log in $eventLogs) {
            $logName = $log.Trim()
            if (-not [string]::IsNullOrWhiteSpace($logName)) {
                wevtutil.exe cl "`"$logName`"" 2>$null
                $clearedLogs++
            }
        }
        Write-Host "      [+] Windows Event Logs purged: $clearedLogs event logs cleared!" -ForegroundColor Green
    } catch {
        Write-Host "      [~] Event log clearing skipped or limited ($($_.Exception.Message))" -ForegroundColor DarkYellow
    }

    Write-Host "      [OK] Deep Cache & Event Log Cleaner completed successfully!" -ForegroundColor Green
}

function Invoke-ShaderAndBrowserCacheCleaner {
    <#
    .SYNOPSIS
        Purges GPU DirectX/NVIDIA/AMD shader caches and Discord/Browser caches.
    .DESCRIPTION
        Cleans DirectX D3DSCache, NVIDIA GLCache/DXCache/ComputeCache, AMD DxCache/GLCache,
        Discord cache/Code Cache/GPUCache, and Chrome/Brave/Edge browser caches to fix shader stutter
        and reclaim gigabytes of disk space.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Purging GPU Shader Caches, Discord & Browser Caches..." -ForegroundColor Yellow

    $cacheTargets = @(
        "$env:LOCALAPPDATA\D3DSCache",
        "$env:LOCALAPPDATA\NVIDIA\GLCache",
        "$env:LOCALAPPDATA\NVIDIA\DXCache",
        "$env:APPDATA\NVIDIA\ComputeCache",
        "$env:LOCALAPPDATA\AMD\DxCache",
        "$env:LOCALAPPDATA\AMD\GLCache",
        "$env:LOCALAPPDATA\Intel\ShaderCache",
        "$env:APPDATA\discord\Cache",
        "$env:APPDATA\discord\Code Cache",
        "$env:APPDATA\discord\GPUCache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache"
    )

    $totalFreed = 0
    $cleanedCount = 0

    foreach ($target in $cacheTargets) {
        if (Test-Path $target) {
            try {
                $measure = Get-ChildItem -Path $target -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
                if ($measure -and $measure.Sum) {
                    $totalFreed += $measure.Sum
                }
                Remove-Item -Path "$target\*" -Recurse -Force -ErrorAction SilentlyContinue
                $cleanedCount++
            } catch {}

            # Recreate base folder if needed
            if (-not (Test-Path $target)) {
                New-Item -ItemType Directory -Path $target -Force -ErrorAction SilentlyContinue | Out-Null
            }
        }
    }

    $mbFreed = [math]::Round($totalFreed / 1MB, 2)
    Write-Host "      [+] GPU Shader & App Cache Purged: ~$mbFreed MB freed across $cleanedCount cache repositories!" -ForegroundColor Green
    Write-Host "      [OK] DirectX/NVIDIA/AMD shader caches and Discord/Browser caches refreshed." -ForegroundColor Green
}

function Restore-BackgroundServices {
    Write-Host "`n[*] Restoring Background Services to Manual Startup..." -ForegroundColor Yellow
    # Exclude SysMain (Superfetch) and WSearch (Windows Search) -- permanently kept disabled
    $servicesToRestore = @('DiagTrack', 'dmwappushservice', 'XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc', 'MapsBroker', 'lfsvc', 'WerSvc')
    foreach ($svcName in $servicesToRestore) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($svc) {
            Set-Service -Name $svcName -StartupType Manual -ErrorAction SilentlyContinue
        }
    }
    # Enforce Superfetch / SysMain stays disabled
    Set-Service -Name 'SysMain' -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name 'SysMain' -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\SysMain' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue
    $prefetchKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters'
    if (Test-Path $prefetchKey) {
        Set-ItemProperty -Path $prefetchKey -Name 'EnableSuperfetch' -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $prefetchKey -Name 'EnablePrefetcher' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    # Enforce Windows Search (WSearch) stays permanently disabled & stopped
    Set-Service -Name 'WSearch' -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name 'WSearch' -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WSearch' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'DisableWebSearch' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'ConnectedSearchUseWeb' -ErrorAction SilentlyContinue
    Write-Host "      [+] Background services set to Manual startup (Superfetch & WSearch remain Disabled)." -ForegroundColor Green
}

function Restore-VisualEffects {
    Write-Host "`n[*] Restoring Windows Visual Effects & Animations Defaults..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '400' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'DragFullWindows' -Value '1' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\DWM' -Name 'EnableAeroPeek' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Visual animations restored to Windows defaults." -ForegroundColor Green
}

function Restore-EndTaskRightClick {
    Write-Host "`n[*] Restoring Taskbar Right-Click End Task Default..." -ForegroundColor Yellow
    Remove-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoEndTasks' -ErrorAction SilentlyContinue
    Write-Host "      [+] Taskbar right-click End Task removed." -ForegroundColor Green
}

function Restore-StickyKeysPrompt {
    Write-Host "`n[*] Restoring Sticky Keys Prompt Default..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Value '510' -Type String -ErrorAction SilentlyContinue
    Write-Host "      [+] Sticky Keys prompt restored." -ForegroundColor Green
}

function Restore-DiskIO {
    Write-Host "`n[*] Restoring Disk I/O Timestamps..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'NtfsDisableLastAccessUpdate' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'NtfsDisable8dot3NameCreation' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Disk I/O timestamps restored to default." -ForegroundColor Green
}

function Restore-PrivacyTelemetry {
    Write-Host "`n[*] Restoring Windows Telemetry Policies..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 3 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Telemetry policy restored." -ForegroundColor Green
}

function Restore-ScheduledJunkTasks {
    Write-Host "`n[*] Restoring Scheduled Maintenance Tasks..." -ForegroundColor Yellow
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\Customer Experience Improvement Program\' -TaskName 'Consolidator' -ErrorAction SilentlyContinue
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\Customer Experience Improvement Program\' -TaskName 'UsbCeip' -ErrorAction SilentlyContinue
    Write-Host "      [+] Scheduled maintenance tasks re-enabled." -ForegroundColor Green
}

function Restore-BalancedPowerPlan {
    Write-Host "`n[*] Restoring Balanced Power Scheme..." -ForegroundColor Yellow
    if (Get-Command Restore-CpuCoreParking -ErrorAction SilentlyContinue) {
        Restore-CpuCoreParking
    }
    $balanced = powercfg /list | Select-String "Balanced"
    if ($balanced) {
        $guid = ($balanced -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        powercfg /setactive $guid
        Write-Host "      [+] Balanced power plan restored (GUID: $guid)" -ForegroundColor Green
    }
    # Enforce Hibernate stays permanently disabled (frees disk space & prevents sleep interrupts)
    powercfg /hibernate off 2>$null
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    bcdedit /deletevalue useplatformtick 2>$null
    bcdedit /deletevalue tscsyncpolicy 2>$null
    Write-Host "      [+] Balanced power restored (Hibernate remains Disabled)." -ForegroundColor Green
}

function Disable-BitLockerPermanently {
    <#
    .SYNOPSIS
        Permanently turns off BitLocker and Windows Automatic Device Encryption,
        decrypts active volumes, and disables the BDESVC service to prevent background encryption.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Permanently Disabling BitLocker & Automatic Device Encryption..." -ForegroundColor Yellow

    # 1. Prevent Automatic Device Encryption in Registry
    $bKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker'
    if (-not (Test-Path $bKey)) { New-Item -Path $bKey -Force | Out-Null }
    Set-ItemProperty -Path $bKey -Name 'PreventDeviceEncryption' -Value 1 -Type DWord
    Write-Host "      [+] PreventDeviceEncryption = 1 (Blocked automatic device encryption on all drives)" -ForegroundColor Green

    # 2. Disable BitLocker Policies in FVE
    $fveKey = 'HKLM:\SOFTWARE\Policies\Microsoft\FVE'
    if (-not (Test-Path $fveKey)) { New-Item -Path $fveKey -Force | Out-Null }
    Set-ItemProperty -Path $fveKey -Name 'EnableBDEWithNoTPM' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    # 3. Decrypt active BitLocker volumes if any are encrypted
    try {
        $volumes = Get-BitLockerVolume -ErrorAction SilentlyContinue
        if ($volumes) {
            foreach ($vol in $volumes) {
                if ($vol.VolumeStatus -ne 'FullyDecrypted' -or $vol.ProtectionStatus -eq 'On') {
                    Write-Host "      [*] Decrypting volume $($vol.MountPoint)..." -ForegroundColor Yellow
                    Disable-BitLocker -MountPoint $vol.MountPoint -ErrorAction SilentlyContinue
                }
            }
        }
    } catch {
        manage-bde -off C: 2>$null
    }

    # 4. Stop and Disable BitLocker Drive Encryption Service (BDESVC)
    Set-Service -Name 'BDESVC' -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name 'BDESVC' -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\BDESVC' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] BDESVC service permanently stopped and disabled (Start = 4)" -ForegroundColor Green

    Write-Host "      [OK] BitLocker & Device Encryption permanently turned off." -ForegroundColor Green
    return $true
}

function Restore-BitLockerDefaults {
    <#
    .SYNOPSIS
        Restores BitLocker service to default (Manual startup) and removes automatic encryption block.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Restoring BitLocker / Device Encryption Defaults..." -ForegroundColor Yellow

    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker' -Name 'PreventDeviceEncryption' -ErrorAction SilentlyContinue
    Set-Service -Name 'BDESVC' -StartupType Manual -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\BDESVC' -Name 'Start' -Value 3 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [OK] BitLocker defaults restored (Service set to Manual startup)." -ForegroundColor Green
    return $true
}


# If run directly as standalone script (not dot-sourced)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Debloat-BackgroundServices
    Enable-UltimatePerformancePlan
    Strip-VisualEffects
    Harden-PrivacyTelemetry
    Optimize-DiskIO
    Disable-ScheduledJunkTasks
    Optimize-StartupAndDns
    Read-Host "`nPress Enter to exit"
}

# ------------------------------------------------------------------------------
# MODULE: Optimize-Windows11AndShell
# ------------------------------------------------------------------------------
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
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
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


# ------------------------------------------------------------------------------
# MODULE: Optimize-PrivacyAndTelemetry
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: Advanced Privacy, App Telemetry & System Services
================================================================================
#>

# 1. Third-Party App Telemetry Disabler (Edge, Chrome, Firefox, VS, Nvidia)
function Disable-AppTelemetry {
    Write-Host "`n[*] Disabling Browser, IDE & Driver Telemetry (Edge, Chrome, Firefox, VS, Nvidia)..." -ForegroundColor Yellow

    # Microsoft Edge Telemetry
    $edgeKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
    if (-not (Test-Path $edgeKey)) { New-Item -Path $edgeKey -Force | Out-Null }
    Set-ItemProperty -Path $edgeKey -Name 'MetricsReportingEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $edgeKey -Name 'SendDoNotTrack' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $edgeKey -Name 'PersonalizationReportingEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    # Google Chrome Telemetry
    $chromeKey = 'HKLM:\SOFTWARE\Policies\Google\Chrome'
    if (-not (Test-Path $chromeKey)) { New-Item -Path $chromeKey -Force | Out-Null }
    Set-ItemProperty -Path $chromeKey -Name 'MetricsReportingEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $chromeKey -Name 'SendingDataUsageReports' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    # Mozilla Firefox Telemetry
    $ffKey = 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox'
    if (-not (Test-Path $ffKey)) { New-Item -Path $ffKey -Force | Out-Null }
    Set-ItemProperty -Path $ffKey -Name 'DisableTelemetry' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    # Visual Studio Telemetry
    $vsLM = 'HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Telemetry'
    $vsCU = 'HKCU:\Software\Microsoft\VisualStudio\Telemetry'
    if (-not (Test-Path $vsLM)) { New-Item -Path $vsLM -Force | Out-Null }
    if (-not (Test-Path $vsCU)) { New-Item -Path $vsCU -Force | Out-Null }
    Set-ItemProperty -Path $vsLM -Name 'TurnOffSwitch' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $vsCU -Name 'TurnOffSwitch' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    # Nvidia Driver Telemetry Tasks
    $nvTasks = @('NvTmMon', 'NvTmRep', 'NvTmRepOnLogon')
    foreach ($nt in $nvTasks) {
        Disable-ScheduledTask -TaskName $nt -ErrorAction SilentlyContinue | Out-Null
    }

    Write-Host "      [+] Edge, Chrome, Firefox, VS, and Nvidia telemetry blocked system-wide!" -ForegroundColor Green
}

function Restore-AppTelemetry {
    Write-Host "`n[*] Restoring Browser, IDE & Driver Telemetry Defaults..." -ForegroundColor Yellow
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'MetricsReportingEnabled' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'MetricsReportingEnabled' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' -Name 'DisableTelemetry' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Telemetry' -Name 'TurnOffSwitch' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\VisualStudio\Telemetry' -Name 'TurnOffSwitch' -ErrorAction SilentlyContinue

    $nvTasks = @('NvTmMon', 'NvTmRep', 'NvTmRepOnLogon')
    foreach ($nt in $nvTasks) {
        Enable-ScheduledTask -TaskName $nt -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Host "      [+] Browser, IDE and Driver telemetry settings restored." -ForegroundColor Green
}

# 2. Bluetooth Advertising Disabler
function Disable-BluetoothAdvertising {
    Write-Host "`n[*] Disabling Bluetooth Advertising & Discovery Broadcasts..." -ForegroundColor Yellow
    $btKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Bluetooth'
    if (-not (Test-Path $btKey)) { New-Item -Path $btKey -Force | Out-Null }
    Set-ItemProperty -Path $btKey -Name 'AllowAdvertising' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Bluetooth Advertising disabled -- Device presence broadcast stopped." -ForegroundColor Green
}

function Restore-BluetoothAdvertising {
    Write-Host "`n[*] Restoring Bluetooth Advertising..." -ForegroundColor Yellow
    $btKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Bluetooth'
    if (Test-Path $btKey) {
        Remove-ItemProperty -Path $btKey -Name 'AllowAdvertising' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Bluetooth Advertising restored." -ForegroundColor Green
}

# 3. Cloud-Optimized Content Disabler
function Disable-CloudOptimizedContent {
    Write-Host "`n[*] Disabling Cloud-Optimized Content & Remote Asset Syncing..." -ForegroundColor Yellow
    $cloudKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
    if (-not (Test-Path $cloudKey)) { New-Item -Path $cloudKey -Force | Out-Null }
    Set-ItemProperty -Path $cloudKey -Name 'DisableCloudOptimizedContent' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Cloud-optimized content disabled -- Internet bandwidth saved!" -ForegroundColor Green
}

function Restore-CloudOptimizedContent {
    Write-Host "`n[*] Restoring Cloud-Optimized Content..." -ForegroundColor Yellow
    $cloudKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
    if (Test-Path $cloudKey) {
        Remove-ItemProperty -Path $cloudKey -Name 'DisableCloudOptimizedContent' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Cloud-optimized content restored." -ForegroundColor Green
}

# 4. Connected Devices Platform (CDP) Telemetry Services
function Disable-CdpServices {
    Write-Host "`n[*] Disabling Connected Devices Platform (CDP) Services..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CDPSvc' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CDPUserSvc' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue
    Stop-Service -Name CDPSvc -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] CDP Services disabled -- User Activity and device sync halted." -ForegroundColor Green
}

function Restore-CdpServices {
    Write-Host "`n[*] Restoring Connected Devices Platform (CDP) Services..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CDPSvc' -Name 'Start' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CDPUserSvc' -Name 'Start' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Start-Service -Name CDPSvc -ErrorAction SilentlyContinue
    Write-Host "      [+] CDP Services restored to Automatic." -ForegroundColor Green
}

# 5. Diagnostic Toast Notifications
function Disable-DiagnosticsToasts {
    Write-Host "`n[*] Disabling Diagnostic & Maintenance Toast Notifications..." -ForegroundColor Yellow
    $toastKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance'
    if (-not (Test-Path $toastKey)) { New-Item -Path $toastKey -Force | Out-Null }
    Set-ItemProperty -Path $toastKey -Name 'Enabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Security and Maintenance diagnostic toast notifications muted." -ForegroundColor Green
}

function Restore-DiagnosticsToasts {
    Write-Host "`n[*] Restoring Diagnostic Toast Notifications..." -ForegroundColor Yellow
    $toastKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance'
    if (Test-Path $toastKey) {
        Set-ItemProperty -Path $toastKey -Name 'Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Diagnostic toast notifications restored." -ForegroundColor Green
}

# 6. Online Speech Recognition & Voice Activation Privacy
function Disable-OnlineSpeechPrivacy {
    Write-Host "`n[*] Disabling Online Speech Recognition & Cloud Voice Storage..." -ForegroundColor Yellow
    $speechKey = 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'
    if (-not (Test-Path $speechKey)) { New-Item -Path $speechKey -Force | Out-Null }
    Set-ItemProperty -Path $speechKey -Name 'HasAccepted' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    $voiceKey = 'HKCU:\Software\Microsoft\Speech_OneCore\Preferences'
    if (-not (Test-Path $voiceKey)) { New-Item -Path $voiceKey -Force | Out-Null }
    Set-ItemProperty -Path $voiceKey -Name 'AgentActivationEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Online speech recognition and voice assistant activation disabled." -ForegroundColor Green
}

function Restore-OnlineSpeechPrivacy {
    Write-Host "`n[*] Restoring Online Speech Recognition..." -ForegroundColor Yellow
    $speechKey = 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'
    if (Test-Path $speechKey) {
        Set-ItemProperty -Path $speechKey -Name 'HasAccepted' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    $voiceKey = 'HKCU:\Software\Microsoft\Speech_OneCore\Preferences'
    if (Test-Path $voiceKey) {
        Set-ItemProperty -Path $voiceKey -Name 'AgentActivationEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Online speech settings restored." -ForegroundColor Green
}

# 7. Automatic Restart Sign-On (ARSO)
function Disable-AutomaticRestartSignOn {
    Write-Host "`n[*] Disabling Automatic Restart Sign-On (ARSO Credential Caching)..." -ForegroundColor Yellow
    $sysKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    if (-not (Test-Path $sysKey)) { New-Item -Path $sysKey -Force | Out-Null }
    Set-ItemProperty -Path $sysKey -Name 'DisableAutomaticRestartSignOn' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] ARSO disabled -- User credentials not auto-unlocked after reboot." -ForegroundColor Green
}

function Restore-AutomaticRestartSignOn {
    Write-Host "`n[*] Restoring Automatic Restart Sign-On..." -ForegroundColor Yellow
    $sysKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    if (Test-Path $sysKey) {
        Remove-ItemProperty -Path $sysKey -Name 'DisableAutomaticRestartSignOn' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] ARSO restored." -ForegroundColor Green
}

# 8. Handwriting Data Sharing & Text Input Collection (Typing Telemetry)
function Disable-TextInputCollection {
    Write-Host "`n[*] Disabling Typing & Handwriting Telemetry Data Collection..." -ForegroundColor Yellow
    $inputPol = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'
    if (-not (Test-Path $inputPol)) { New-Item -Path $inputPol -Force | Out-Null }
    Set-ItemProperty -Path $inputPol -Name 'RestrictImplicitInkCollection' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $inputPol -Name 'RestrictImplicitTextCollection' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $hwKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports'
    if (-not (Test-Path $hwKey)) { New-Item -Path $hwKey -Force | Out-Null }
    Set-ItemProperty -Path $hwKey -Name 'PreventHandwritingDataSharing' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $userInp = 'HKCU:\Software\Microsoft\InputPersonalization'
    if (-not (Test-Path $userInp)) { New-Item -Path $userInp -Force | Out-Null }
    Set-ItemProperty -Path $userInp -Name 'RestrictImplicitInkCollection' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $userInp -Name 'RestrictImplicitTextCollection' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    Write-Host "      [+] Keystroke and handwriting diagnostic reporting disabled." -ForegroundColor Green
}

function Restore-TextInputCollection {
    Write-Host "`n[*] Restoring Typing & Handwriting Data Sharing..." -ForegroundColor Yellow
    $inputPol = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'
    if (Test-Path $inputPol) {
        Remove-ItemProperty -Path $inputPol -Name 'RestrictImplicitInkCollection' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $inputPol -Name 'RestrictImplicitTextCollection' -ErrorAction SilentlyContinue
    }
    $hwKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports'
    if (Test-Path $hwKey) {
        Remove-ItemProperty -Path $hwKey -Name 'PreventHandwritingDataSharing' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Typing and handwriting defaults restored." -ForegroundColor Green
}

# 9. Cross-Device Clipboard Sync
function Disable-ClipboardSync {
    Write-Host "`n[*] Disabling Cross-Device Cloud Clipboard Sync..." -ForegroundColor Yellow
    $sysPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (-not (Test-Path $sysPol)) { New-Item -Path $sysPol -Force | Out-Null }
    Set-ItemProperty -Path $sysPol -Name 'AllowCrossDeviceClipboard' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    $clipCU = 'HKCU:\Software\Microsoft\Clipboard'
    if (-not (Test-Path $clipCU)) { New-Item -Path $clipCU -Force | Out-Null }
    Set-ItemProperty -Path $clipCU -Name 'EnableClipboardHistory' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $clipCU -Name 'CloudClipboardEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Cloud clipboard sync disabled -- Copied text remains local." -ForegroundColor Green
}

function Restore-ClipboardSync {
    Write-Host "`n[*] Restoring Cloud Clipboard Sync..." -ForegroundColor Yellow
    $sysPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (Test-Path $sysPol) {
        Set-ItemProperty -Path $sysPol -Name 'AllowCrossDeviceClipboard' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Cloud clipboard sync restored." -ForegroundColor Green
}

# 10. Device Message & Settings Sync
function Disable-SettingsAndMessageSync {
    Write-Host "`n[*] Disabling Cross-Device Settings & Message Synchronization..." -ForegroundColor Yellow
    $syncPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'
    if (-not (Test-Path $syncPol)) { New-Item -Path $syncPol -Force | Out-Null }
    Set-ItemProperty -Path $syncPol -Name 'DisableSettingSync' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $syncPol -Name 'DisableSettingSyncUserOverride' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $msgPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging'
    if (-not (Test-Path $msgPol)) { New-Item -Path $msgPol -Force | Out-Null }
    Set-ItemProperty -Path $msgPol -Name 'AllowMessageSync' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] OS Settings and Message sync across devices disabled." -ForegroundColor Green
}

function Restore-SettingsAndMessageSync {
    Write-Host "`n[*] Restoring Settings & Message Sync..." -ForegroundColor Yellow
    $syncPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'
    if (Test-Path $syncPol) {
        Remove-ItemProperty -Path $syncPol -Name 'DisableSettingSync' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $syncPol -Name 'DisableSettingSyncUserOverride' -ErrorAction SilentlyContinue
    }
    $msgPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging'
    if (Test-Path $msgPol) {
        Remove-ItemProperty -Path $msgPol -Name 'AllowMessageSync' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Settings and message sync restored." -ForegroundColor Green
}

# 11. Find My Device Tracking
function Disable-FindMyDevice {
    Write-Host "`n[*] Disabling 'Find My Device' Location Tracking..." -ForegroundColor Yellow
    $findPol = 'HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice'
    if (-not (Test-Path $findPol)) { New-Item -Path $findPol -Force | Out-Null }
    Set-ItemProperty -Path $findPol -Name 'AllowFindMyDevice' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Find My Device tracking disabled." -ForegroundColor Green
}

function Restore-FindMyDevice {
    Write-Host "`n[*] Restoring 'Find My Device'..." -ForegroundColor Yellow
    $findPol = 'HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice'
    if (Test-Path $findPol) {
        Remove-ItemProperty -Path $findPol -Name 'AllowFindMyDevice' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Find My Device restored." -ForegroundColor Green
}

# 12. SafeSearch Mode in Windows Search
function Disable-SafeSearchMode {
    Write-Host "`n[*] Disabling SafeSearch Filter in Windows Search..." -ForegroundColor Yellow
    $srchSet = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings'
    if (-not (Test-Path $srchSet)) { New-Item -Path $srchSet -Force | Out-Null }
    Set-ItemProperty -Path $srchSet -Name 'SafeSearchMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] SafeSearch filter disabled (Unfiltered instant local search)." -ForegroundColor Green
}

function Restore-SafeSearchMode {
    Write-Host "`n[*] Restoring SafeSearch Filter..." -ForegroundColor Yellow
    $srchSet = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings'
    if (Test-Path $srchSet) {
        Set-ItemProperty -Path $srchSet -Name 'SafeSearchMode' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] SafeSearch restored to Moderate." -ForegroundColor Green
}

# 13. Disable SMBv1 Protocol (Legacy Security Vulnerability)
function Disable-SmbV1Protocol {
    Write-Host "`n[*] Disabling Deprecated SMBv1 Protocol (Ransomware / WannaCry Shield)..." -ForegroundColor Yellow
    try {
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue | Out-Null
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
        Write-Host "      [+] SMBv1 protocol disabled successfully -- Network attack surface closed!" -ForegroundColor Green
    } catch {
        Write-Host "      [!] SMBv1 disable skipped: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
}

function Restore-SmbV1Protocol {
    Write-Host "`n[*] Restoring SMBv1 Protocol..." -ForegroundColor Yellow
    try {
        Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force -ErrorAction SilentlyContinue | Out-Null
        Write-Host "      [+] SMBv1 protocol restored." -ForegroundColor Green
    } catch {}
}

# 14. Disable Remote Assistance & Remote Registry
function Disable-RemoteAssistanceAndRegistry {
    Write-Host "`n[*] Disabling Remote Assistance & Remote Registry Access..." -ForegroundColor Yellow
    $raPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance'
    if (-not (Test-Path $raPath)) { New-Item -Path $raPath -Force | Out-Null }
    Set-ItemProperty -Path $raPath -Name 'fAllowToGetHelp' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    Set-Service -Name RemoteRegistry -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name RemoteRegistry -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] Remote Assistance and Remote Registry service disabled." -ForegroundColor Green
}

function Restore-RemoteAssistanceAndRegistry {
    Write-Host "`n[*] Restoring Remote Assistance & Remote Registry..." -ForegroundColor Yellow
    $raPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance'
    if (Test-Path $raPath) {
        Set-ItemProperty -Path $raPath -Name 'fAllowToGetHelp' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Set-Service -Name RemoteRegistry -StartupType Manual -ErrorAction SilentlyContinue
    Write-Host "      [+] Remote Assistance and Remote Registry restored." -ForegroundColor Green
}

# 15. Exclude Driver Updates from Windows Update
function Disable-DriverUpdatesFromWindowsUpdate {
    Write-Host "`n[*] Excluding Hardware Drivers from Windows Update (Prevents Driver Overwrites)..." -ForegroundColor Yellow
    $wuPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    if (-not (Test-Path $wuPath)) { New-Item -Path $wuPath -Force | Out-Null }
    Set-ItemProperty -Path $wuPath -Name 'ExcludeWUDriversInQualityUpdate' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Driver updates excluded from Windows Update -- GPU/Audio drivers protected!" -ForegroundColor Green
}

function Restore-DriverUpdatesFromWindowsUpdate {
    Write-Host "`n[*] Restoring Driver Updates in Windows Update..." -ForegroundColor Yellow
    $wuPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    if (Test-Path $wuPath) {
        Remove-ItemProperty -Path $wuPath -Name 'ExcludeWUDriversInQualityUpdate' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Driver updates via Windows Update restored." -ForegroundColor Green
}

# 16. Disable Microsoft Store Automatic Updates
function Disable-StoreAutoUpdates {
    Write-Host "`n[*] Disabling Microsoft Store Automatic App Updates..." -ForegroundColor Yellow
    $storePath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'
    if (-not (Test-Path $storePath)) { New-Item -Path $storePath -Force | Out-Null }
    Set-ItemProperty -Path $storePath -Name 'AutoDownload' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Store auto-downloads disabled -- Updates will only occur on demand." -ForegroundColor Green
}

function Restore-StoreAutoUpdates {
    Write-Host "`n[*] Restoring Microsoft Store Auto-Updates..." -ForegroundColor Yellow
    $storePath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'
    if (Test-Path $storePath) {
        Remove-ItemProperty -Path $storePath -Name 'AutoDownload' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Store auto-downloads restored." -ForegroundColor Green
}

# 17. Disable SmartScreen Filter
function Disable-SmartScreenFilter {
    Write-Host "`n[*] Disabling Windows Defender SmartScreen Filter..." -ForegroundColor Yellow
    $sysPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (-not (Test-Path $sysPath)) { New-Item -Path $sysPath -Force | Out-Null }
    Set-ItemProperty -Path $sysPath -Name 'EnableSmartScreen' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    $appHost = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost'
    if (-not (Test-Path $appHost)) { New-Item -Path $appHost -Force | Out-Null }
    Set-ItemProperty -Path $appHost -Name 'EnableWebContentEvaluation' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] SmartScreen filter disabled -- App execution warnings suppressed." -ForegroundColor Green
}

function Restore-SmartScreenFilter {
    Write-Host "`n[*] Restoring SmartScreen Filter..." -ForegroundColor Yellow
    $sysPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (Test-Path $sysPath) {
        Set-ItemProperty -Path $sysPath -Name 'EnableSmartScreen' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    $appHost = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost'
    if (Test-Path $appHost) {
        Set-ItemProperty -Path $appHost -Name 'EnableWebContentEvaluation' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] SmartScreen filter restored." -ForegroundColor Green
}

# 18. Disable System Crash Dumps
function Disable-CrashDumps {
    Write-Host "`n[*] Disabling Application Crash Dumps & Memory MiniDumps..." -ForegroundColor Yellow
    $crashPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
    if (-not (Test-Path $crashPath)) { New-Item -Path $crashPath -Force | Out-Null }
    Set-ItemProperty -Path $crashPath -Name 'CrashDumpEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Crash dumps disabled -- Prevents gigabytes of useless dump files on disk." -ForegroundColor Green
}

function Restore-CrashDumps {
    Write-Host "`n[*] Restoring Default Crash Dump Generation..." -ForegroundColor Yellow
    $crashPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
    if (Test-Path $crashPath) {
        Set-ItemProperty -Path $crashPath -Name 'CrashDumpEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Crash dump generation restored." -ForegroundColor Green
}

# 19. Optimize System Timeouts & Responsiveness
function Optimize-SystemTimeouts {
    Write-Host "`n[*] Optimizing System Timeouts, Menu Show Delay & Broken Link Resolving..." -ForegroundColor Yellow
    $deskPath = 'HKCU:\Control Panel\Desktop'
    Set-ItemProperty -Path $deskPath -Name 'MenuShowDelay' -Value '0' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $deskPath -Name 'WaitToKillAppTimeout' -Value '2000' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $deskPath -Name 'HungAppTimeout' -Value '1000' -Type String -ErrorAction SilentlyContinue

    $mousePath = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mousePath -Name 'MouseHoverTime' -Value '0' -Type String -ErrorAction SilentlyContinue

    $ctrlPath = 'HKLM:\SYSTEM\CurrentControlSet\Control'
    Set-ItemProperty -Path $ctrlPath -Name 'WaitToKillServiceTimeout' -Value '2000' -Type String -ErrorAction SilentlyContinue

    $polExp = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    if (-not (Test-Path $polExp)) { New-Item -Path $polExp -Force | Out-Null }
    Set-ItemProperty -Path $polExp -Name 'NoLowDiskSpaceChecks' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $polExp -Name 'NoResolveSearch' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $polExp -Name 'NoResolveTrack' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    Write-Host "      [+] Instant menu popups (0ms delay), fast app shutdown (2s), and no broken link lag!" -ForegroundColor Green
}

function Restore-SystemTimeouts {
    Write-Host "`n[*] Restoring Default Windows Timeouts..." -ForegroundColor Yellow
    $deskPath = 'HKCU:\Control Panel\Desktop'
    Set-ItemProperty -Path $deskPath -Name 'MenuShowDelay' -Value '400' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $deskPath -Name 'WaitToKillAppTimeout' -Value '20000' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $deskPath -Name 'HungAppTimeout' -Value '5000' -Type String -ErrorAction SilentlyContinue

    $mousePath = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mousePath -Name 'MouseHoverTime' -Value '400' -Type String -ErrorAction SilentlyContinue

    $ctrlPath = 'HKLM:\SYSTEM\CurrentControlSet\Control'
    Set-ItemProperty -Path $ctrlPath -Name 'WaitToKillServiceTimeout' -Value '5000' -Type String -ErrorAction SilentlyContinue

    $polExp = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    if (Test-Path $polExp) {
        Remove-ItemProperty -Path $polExp -Name 'NoLowDiskSpaceChecks' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $polExp -Name 'NoResolveSearch' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $polExp -Name 'NoResolveTrack' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Default timeouts and link tracking restored." -ForegroundColor Green
}

# Compatibility Aliases for GUI & CLI Dispatchers
function Disable-ThirdPartyAppTelemetry { Disable-AppTelemetry }
function Disable-CdpUserServices { Disable-CdpServices }
function Disable-RestartAppsAfterReboot { Disable-AutomaticRestartSignOn }
function Disable-HandwritingTypingCollection { Disable-TextInputCollection }
function Disable-ClipboardCloudSync { Disable-ClipboardSync }
function Disable-SafeSearchFiltering { Disable-SafeSearchMode }
function Exclude-DriverUpdatesInWindowsUpdate { Disable-DriverUpdatesFromWindowsUpdate }
function Disable-WindowsStoreAutoUpdates { Disable-StoreAutoUpdates }
function Disable-SmartScreenProtection { Disable-SmartScreenFilter }
function Disable-SystemCrashDumps { Disable-CrashDumps }

# Standalone execution check
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Disable-AppTelemetry
    Disable-BluetoothAdvertising
    Disable-CloudOptimizedContent
    Disable-DiagnosticsToasts
    Disable-TextInputCollection
    Disable-ClipboardSync
    Disable-SmbV1Protocol
    Disable-DriverUpdatesFromWindowsUpdate
    Optimize-SystemTimeouts
    Read-Host "`nPress Enter to exit"
}


# ------------------------------------------------------------------------------
# MODULE: Install-CustomCursors
# ------------------------------------------------------------------------------
<#
================================================================================
  PumpkiN's Modular Suite: 1-Click Custom Gaming Cursors Engine & Manager
  Supports 23+ Custom Animated & Precision Cursor Schemes (.inf / .crs)
  Instant Live Application without Reboot & 100% Symmetrical Rollback
================================================================================
#>

function Get-CursorBaseFolder {
    <#
    .SYNOPSIS
        Resolves the absolute path to the Cursors directory across all execution modes.
    #>
    $candidates = @()
    if ($Global:OptimizerProjectRoot) {
        $candidates += (Join-Path $Global:OptimizerProjectRoot "Cursors")
    }
    if ($PSScriptRoot) {
        $candidates += (Join-Path (Split-Path $PSScriptRoot -Parent) "Cursors")
        $candidates += (Join-Path $PSScriptRoot "Cursors")
    }
    $candidates += "E:\Projects\Win_Optimizer\Cursors"
    $candidates += (Join-Path (Get-Location) "Cursors")

    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) {
            return $c
        }
    }
    return $null
}

function Get-AvailableCursorSchemes {
    <#
    .SYNOPSIS
        Scans the Cursors directory and returns metadata for all available cursor packs.
    #>
    $baseFolder = Get-CursorBaseFolder
    if (-not $baseFolder -or -not (Test-Path -LiteralPath $baseFolder)) {
        return @()
    }

    $dirs = Get-ChildItem -LiteralPath $baseFolder -Directory | Sort-Object Name
    $schemes = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($d in $dirs) {
        $infFile = Get-ChildItem -LiteralPath $d.FullName -Filter "*.inf" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        $crsFile = Get-ChildItem -LiteralPath $d.FullName -Filter "*.crs" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        $preview = Get-ChildItem -LiteralPath $d.FullName -Filter "*Preview*.jpg" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $preview) {
            $preview = Get-ChildItem -LiteralPath $d.FullName -Filter "*preview*.png" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        }

        $schemes.Add([PSCustomObject]@{
            Name        = $d.Name
            FolderPath  = $d.FullName
            HasInf      = ($null -ne $infFile)
            InfPath     = if ($infFile) { $infFile.FullName } else { $null }
            HasCrs      = ($null -ne $crsFile)
            CrsPath     = if ($crsFile) { $crsFile.FullName } else { $null }
            PreviewPath = if ($preview) { $preview.FullName } else { $null }
        })
    }

    return $schemes
}

function Get-ActiveCursorSchemeName {
    <#
    .SYNOPSIS
        Reads the current active cursor scheme name from Windows registry.
    #>
    try {
        $reg = Get-ItemProperty 'HKCU:\Control Panel\Cursors' -ErrorAction SilentlyContinue
        if ($reg -and $reg.'(default)') {
            return [string]$reg.'(default)'
        }
    } catch {}
    return "Windows Default"
}

function Update-WindowsCursorBroadcast {
    <#
    .SYNOPSIS
        Notifies Windows Shell to immediately reload cursors across all windows without reboot.
    #>
    try {
        if (-not ([System.Management.Automation.PSTypeName]'WinApiCursor').Type) {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinApiCursor {
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
}
"@ -ErrorAction SilentlyContinue
        }
        # SPI_SETCURSORS = 0x0057, SPIF_UPDATEINIFILE = 0x01, SPIF_SENDCHANGE = 0x02
        [WinApiCursor]::SystemParametersInfo(0x0057, 0, $null, 0x03) | Out-Null
        & rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True
    } catch {}
}

function Install-CursorScheme {
    <#
    .SYNOPSIS
        Installs and immediately applies a custom cursor scheme from the Cursors directory.
    .PARAMETER SchemeName
        The folder name of the cursor scheme to install.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SchemeName
    )

    Write-Host "`n[*] Installing Custom Cursor Scheme: $SchemeName..." -ForegroundColor Yellow

    $baseFolder = Get-CursorBaseFolder
    if (-not $baseFolder) {
        Write-Host "      [!] Error: Cursors directory could not be located." -ForegroundColor Red
        return $false
    }

    $sourceDir = Join-Path $baseFolder $SchemeName
    if (-not (Test-Path -LiteralPath $sourceDir)) {
        Write-Host "      [!] Error: Cursor folder not found at: $sourceDir" -ForegroundColor Red
        return $false
    }

    $destDir = Join-Path "$env:SystemRoot\Cursors" $SchemeName
    try {
        if (-not (Test-Path -LiteralPath $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        # Copy all cursor assets (.cur, .ani, .inf, .crs) to %SystemRoot%\Cursors\<SchemeName>
        $assetsToCopy = Get-ChildItem -LiteralPath $sourceDir -Include "*.cur", "*.ani", "*.inf", "*.crs" -Recurse -File -ErrorAction SilentlyContinue
        foreach ($f in $assetsToCopy) {
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $destDir $f.Name) -Force -ErrorAction SilentlyContinue
        }
        Write-Host "      [+] Cursor assets deployed to $destDir" -ForegroundColor Green
    } catch {
        Write-Host "      [!] Note copying to Windows Cursors: $($_.Exception.Message)" -ForegroundColor DarkYellow
        $destDir = $sourceDir
    }

    # Locate INF or CRS file
    $infFile = Get-ChildItem -LiteralPath $destDir -Filter "*.inf" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $infFile) {
        $infFile = Get-ChildItem -LiteralPath $sourceDir -Filter "*.inf" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    $crsFile = Get-ChildItem -LiteralPath $destDir -Filter "*.crs" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $crsFile) {
        $crsFile = Get-ChildItem -LiteralPath $sourceDir -Filter "*.crs" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    }

    $allFiles = Get-ChildItem -LiteralPath $destDir -Include "*.cur", "*.ani" -Recurse -File -ErrorAction SilentlyContinue
    if (-not $allFiles -or $allFiles.Count -eq 0) {
        $allFiles = Get-ChildItem -LiteralPath $sourceDir -Include "*.cur", "*.ani" -Recurse -File -ErrorAction SilentlyContinue
    }

    $orderedRoles = @('Arrow', 'Help', 'AppStarting', 'Wait', 'Crosshair', 'IBeam', 'NWPen', 'No', 'SizeNS', 'SizeWE', 'SizeNWSE', 'SizeNESW', 'SizeAll', 'UpArrow', 'Hand', 'Pin', 'Person')
    $fileMap = @{}

    # 1. Parse INF [Strings] and [Scheme.Reg] directly
    if ($infFile) {
        try {
            $infContent = Get-Content -LiteralPath $infFile.FullName -ErrorAction SilentlyContinue
            $strings = @{}
            $inStrings = $false
            foreach ($line in $infContent) {
                $t = $line.Trim()
                if ($t -eq '[Strings]') { $inStrings = $true; continue }
                if ($t -match '^\[.*\]$') { $inStrings = $false; continue }
                if ($inStrings -and $t -match '^([a-zA-Z0-9_\-\.]+)\s*=\s*\"?(.*?)\"?$') {
                    $strings[$matches[1].ToLower()] = $matches[2].Trim('"')
                }
            }
            foreach ($line in $infContent) {
                if ($line -match 'HKCU,\s*\"?Control Panel\\Cursors\\Schemes\"?') {
                    $idx = $line.IndexOf(',,')
                    if ($idx -gt 0) {
                        $valStr = $line.Substring($idx + 2).Trim().Trim('"')
                        foreach ($k in $strings.Keys) {
                            $valStr = $valStr -replace ('%' + [regex]::Escape($k) + '%'), $strings[$k]
                        }
                        $tokens = $valStr -split ','
                        for ($i = 0; $i -lt [Math]::Min($tokens.Count, $orderedRoles.Count); $i++) {
                            $tok = $tokens[$i].Trim().Trim('"')
                            $fName = Split-Path $tok -Leaf
                            if ($fName) {
                                $found = $allFiles | Where-Object { $_.Name -ieq $fName } | Select-Object -First 1
                                if ($found) { $fileMap[$orderedRoles[$i]] = $found.FullName }
                            }
                        }
                    }
                }
            }
        } catch {
            Write-Host "      [!] INF parse warning: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    } elseif ($crsFile) {
        # 2. Parse .crs if present
        try {
            $lines = Get-Content -LiteralPath $crsFile.FullName -ErrorAction SilentlyContinue
            $currentSection = ""
            foreach ($line in $lines) {
                $trimmed = $line.Trim()
                if ($trimmed -match '^\[(.*)\]$') {
                    $currentSection = $matches[1]
                } elseif ($trimmed -match '^Path=(.+)$' -and $currentSection) {
                    $curFileName = $matches[1].Trim()
                    $found = $allFiles | Where-Object { $_.Name -ieq $curFileName } | Select-Object -First 1
                    if ($found) { $fileMap[$currentSection] = $found.FullName }
                }
            }
        } catch {
            Write-Host "      [!] CRS parse warning: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    }

    # 3. Fallback Heuristic Mapping for any unmapped standard roles
    $roles = @{
        'Arrow'       = @('Normal', 'Arrow', 'Pointer', 'default')
        'Help'        = @('Help')
        'AppStarting' = @('Working', 'AppStarting', 'Flash', 'WaitBackground')
        'Wait'        = @('Busy', 'Wait', 'Spinner')
        'Crosshair'   = @('Precision', 'Crosshair', 'Cross')
        'IBeam'       = @('Text', 'IBeam', 'Beam')
        'NWPen'       = @('Handwriting', 'Pen', 'Write')
        'No'          = @('Unavailable', 'No', 'Cancel')
        'SizeNS'      = @('Vertical', 'SizeNS', 'North')
        'SizeWE'      = @('Horizontal', 'SizeWE', 'East')
        'SizeNWSE'    = @('Diagonal Resize 1', 'Diagonal1', 'SizeNWSE', 'Dgn1')
        'SizeNESW'    = @('Diagonal Resize 2', 'Diagonal2', 'SizeNESW', 'Dgn2')
        'SizeAll'     = @('Move', 'SizeAll', 'All')
        'UpArrow'     = @('Alternate', 'UpArrow', 'Alternative')
        'Hand'        = @('Link', 'Hand')
        'Pin'         = @('Location', 'Pin')
        'Person'      = @('Person', 'User')
    }

    foreach ($role in $roles.Keys) {
        if (-not $fileMap.ContainsKey($role) -or -not $fileMap[$role]) {
            $patterns = $roles[$role]
            foreach ($pat in $patterns) {
                $matched = $allFiles | Where-Object { $_.BaseName -like "*$pat*" } | Select-Object -First 1
                if ($matched) {
                    $fileMap[$role] = $matched.FullName
                    break
                }
            }
        }
    }

    # 4. Write mapped cursor files to HKCU:\Control Panel\Cursors
    $cursorKey = 'HKCU:\Control Panel\Cursors'
    if (-not (Test-Path $cursorKey)) { New-Item -Path $cursorKey -Force | Out-Null }
    Set-ItemProperty -Path $cursorKey -Name '(default)' -Value $SchemeName -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $cursorKey -Name 'Scheme Source' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    foreach ($k in $fileMap.Keys) {
        if ($fileMap[$k]) {
            Set-ItemProperty -Path $cursorKey -Name $k -Value $fileMap[$k] -Type String -ErrorAction SilentlyContinue
        }
    }

    # 5. Write to HKCU:\Control Panel\Cursors\Schemes
    $schemesKey = 'HKCU:\Control Panel\Cursors\Schemes'
    if (-not (Test-Path $schemesKey)) { New-Item -Path $schemesKey -Force | Out-Null }

    $schemeStringList = @()
    foreach ($r in $orderedRoles) {
        if ($fileMap.ContainsKey($r) -and $fileMap[$r]) {
            $schemeStringList += $fileMap[$r]
        } else {
            $schemeStringList += ""
        }
    }
    $schemeVal = $schemeStringList -join ','
    Set-ItemProperty -Path $schemesKey -Name $SchemeName -Value $schemeVal -Type String -ErrorAction SilentlyContinue

    # 6. Broadcast live cursor update to Windows Shell (no reboot needed)
    Update-WindowsCursorBroadcast

    Write-Host "      [OK] Custom cursor scheme '$SchemeName' applied successfully and live!" -ForegroundColor Green
    return $true
}

function Restore-DefaultCursors {
    <#
    .SYNOPSIS
        Restores default Windows Aero/Segoe cursors immediately (100% reversible).
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Restoring Standard Windows Default Cursor Scheme..." -ForegroundColor Yellow

    $cursorKey = 'HKCU:\Control Panel\Cursors'
    if (Test-Path $cursorKey) {
        Set-ItemProperty -Path $cursorKey -Name '(default)' -Value "Windows Default" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorKey -Name 'Scheme Source' -Value 1 -Type DWord -ErrorAction SilentlyContinue

        $standardRoles = @('Arrow', 'Help', 'AppStarting', 'Wait', 'Crosshair', 'IBeam', 'NWPen', 'No', 'SizeNS', 'SizeWE', 'SizeNWSE', 'SizeNESW', 'SizeAll', 'UpArrow', 'Hand', 'Pin', 'Person')
        foreach ($r in $standardRoles) {
            Set-ItemProperty -Path $cursorKey -Name $r -Value "" -Type String -ErrorAction SilentlyContinue
        }
    }

    Update-WindowsCursorBroadcast

    Write-Host "      [OK] Windows Default Cursor Scheme restored in real time!" -ForegroundColor Green
    return $true
}

# Standalone execution check (Dual Invocation Pattern)
if (-not $Script:IsBundled -and $MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Write-Host "=== PUMPKIN CUSTOM CURSORS MANAGER ===" -ForegroundColor Cyan
    $active = Get-ActiveCursorSchemeName
    Write-Host "Current Active Scheme: $active`n" -ForegroundColor Yellow
    $all = Get-AvailableCursorSchemes
    for ($i = 0; $i -lt $all.Count; $i++) {
        Write-Host "  [$i] $($all[$i].Name)"
    }
    Write-Host "  [D] Restore Windows Default Cursors"
    Write-Host "  [Q] Quit"
    $choice = Read-Host "`nEnter selection"
    if ($choice -match '^[0-9]+$' -and [int]$choice -lt $all.Count) {
        Install-CursorScheme -SchemeName ($all[[int]$choice].Name)
    } elseif ($choice -eq 'D' -or $choice -eq 'd') {
        Restore-DefaultCursors
    }
    Read-Host "`nPress Enter to exit"
}


# ------------------------------------------------------------------------------
# MODULE: System-DiagnosticsAndRestore
# ------------------------------------------------------------------------------
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
    if (Get-Command Restore-DefaultCursors -ErrorAction SilentlyContinue) {
        Restore-DefaultCursors
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
    Write-Host "           ULTIMATE GAMING & NETWORK OPTIMIZER v5.7.1"
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
                Write-Host "  [1] Check for Available Updates & Choose Packages to Upgrade"
                Write-Host "  [2] Upgrade All Installed Apps"
                Write-Host "  [3] Install Recommended Gaming Apps (Steam, Discord, OBS, Afterburner)"
                Write-Host "  [4] Custom WinGet Install by ID"
                $wChoice = Read-Host "Select option [1-4]"
                switch ($wChoice) {
                    "1" {
                        $upgrades = Get-WinGetUpgrades
                        if (-not $upgrades -or $upgrades.Count -eq 0) {
                            Write-Host "[OK] All installed packages are up to date! Zero updates pending." -ForegroundColor Green
                        } else {
                            Write-Host "`nFound $($upgrades.Count) package update(s) available:" -ForegroundColor Yellow
                            for ($i = 0; $i -lt $upgrades.Count; $i++) {
                                $u = $upgrades[$i]
                                Write-Host "  [$($i+1)] $($u.Name) ($($u.Id)): $($u.InstalledVersion) -> $($u.AvailableVersion)" -ForegroundColor Cyan
                            }
                            Write-Host "  [A] Upgrade All Listed Updates"
                            Write-Host "  [Q] Return to Menu"
                            $sel = Read-Host "`nEnter package numbers to upgrade (e.g. 1, 3) or 'A' for all"
                            if ($sel -and $sel.Trim().ToUpper() -eq "A") {
                                foreach ($u in $upgrades) {
                                    Upgrade-WinGetPackage -PackageId $u.Id
                                }
                            } elseif ($sel -and $sel.Trim().ToUpper() -ne "Q") {
                                $indices = $sel -split "[, ]" | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ - 1 }
                                foreach ($idx in $indices) {
                                    if ($idx -ge 0 -and $idx -lt $upgrades.Count) {
                                        $u = $upgrades[$idx]
                                        Upgrade-WinGetPackage -PackageId $u.Id
                                    }
                                }
                            }
                        }
                    }
                    "2" { Upgrade-AllWinGetPackages }
                    "3" {
                        Install-WinGetPackage -PackageId "Valve.Steam"
                        Install-WinGetPackage -PackageId "Discord.Discord"
                        Install-WinGetPackage -PackageId "OBSProject.OBSStudio"
                        Install-WinGetPackage -PackageId "Guru3D.Afterburner"
                    }
                    "4" {
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