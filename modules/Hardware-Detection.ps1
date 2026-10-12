<#
================================================================================
  PumpkiN's Modular Suite: Hardware Auto-Detection & Profiler
================================================================================
#>

function Get-HardwareProfile {
    [CmdletBinding()]
    param()

    $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
    $gpus = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue
    $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1
    $ram = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object -Property Capacity -Sum
    $totalRamGb = [math]::Round($ram.Sum / 1GB, 1)

    return [PSCustomObject]@{
        CpuName     = $cpu.Name
        CpuCores    = "$($cpu.NumberOfCores)C / $($cpu.NumberOfLogicalProcessors)T"
        IsAmdCpu    = ($cpu.Name -match 'AMD|Ryzen')
        IsIntelCpu  = ($cpu.Name -match 'Intel|Core')
        Gpus        = $gpus
        HasNvidia   = ($gpus | Where-Object { $_.Name -match 'NVIDIA|GeForce' }) -ne $null
        HasAmdGpu   = ($gpus | Where-Object { $_.Name -match 'AMD|Radeon' }) -ne $null
        Adapter     = $adapter
        IsWifi      = ($adapter -and ($adapter.InterfaceType -eq 71 -or $adapter.InterfaceDescription -match 'Wi-Fi|Wireless|802\.11'))
        RamGb       = $totalRamGb
        TotalRamGb  = $totalRamGb
    }
}