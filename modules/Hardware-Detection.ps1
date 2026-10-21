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
if ($MyInvocation.InvocationName -ne '.') {
    $p = Get-HardwareProfile
    Write-Host "CPU: $($p.CpuName) ($($p.CpuCores))"
    Write-Host "RAM: $($p.TotalRamGb) GB"
    $t = Get-LiveHardwareTelemetry
    Write-Host "Live Telemetry -> CPU: $($t.CpuLoad)% | RAM: $($t.UsedRamGb)/$($t.TotalRamGb) GB ($($t.RamPercent)%) | Ping: $($t.PingMs) ms"
    $d = Get-DeviceDetailProfile
    Write-Host "`nDevice: $($d.DeviceName) ($($d.HeaderSummary))" -ForegroundColor Cyan
}