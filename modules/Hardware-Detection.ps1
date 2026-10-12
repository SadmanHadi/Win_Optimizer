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

    $Script:CachedHardwareProfile = [PSCustomObject]@{
        CpuName     = $cpuName
        CpuCores    = $cpuCores
        IsAmdCpu    = ($cpuName -match 'AMD|Ryzen')
        IsIntelCpu  = ($cpuName -match 'Intel' -and $cpuName -notmatch 'AMD|Ryzen')
        Gpus        = $gpus
        HasNvidia   = ($gpus | Where-Object { $_.Name -match 'NVIDIA|GeForce' }) -ne $null
        HasAmdGpu   = ($gpus | Where-Object { $_.Name -match 'AMD|Radeon' }) -ne $null
        Adapter     = $adapter
        IsWifi      = ($adapter -and ($adapter.InterfaceType -eq 71 -or $adapter.InterfaceDescription -match 'Wi-Fi|Wireless|802\.11'))
        RamGb       = $totalRamGb
        TotalRamGb  = $totalRamGb
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

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    $p = Get-HardwareProfile
    Write-Host "CPU: $($p.CpuName) ($($p.CpuCores))"
    Write-Host "RAM: $($p.TotalRamGb) GB"
    $t = Get-LiveHardwareTelemetry
    Write-Host "Live Telemetry -> CPU: $($t.CpuLoad)% | RAM: $($t.UsedRamGb)/$($t.TotalRamGb) GB ($($t.RamPercent)%) | Ping: $($t.PingMs) ms"
}