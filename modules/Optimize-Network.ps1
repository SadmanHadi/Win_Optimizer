<#
================================================================================
 PumpkiN's Modular Suite: Network & Anti-Lag Optimizer
 - Disables Nagle's algorithm (TCPNoDelay = 1)
 - Disables delayed ACKs (TcpAckFrequency = 1, TcpDelAckTicks = 0)
 - Removes 20% QoS bandwidth reservation
 - Prioritizes local DNS and hosts cache
 - Disables NIC power saving and interrupt moderation
================================================================================
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "             NETWORK & ANTI-LAG SUITE (0ms BUFFERBLOAT)                         " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1
if ($adapter) {
    Write-Host "Tuning Active Adapter: $($adapter.Name) ($($adapter.InterfaceDescription))" -ForegroundColor Yellow
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
    Write-Host "  [+] Nagle disabled (TCPNoDelay=1, TcpAckFrequency=1, TcpDelAckTicks=0)" -ForegroundColor Green
    Write-Host "  [+] NIC green power saving and interrupt moderation disabled" -ForegroundColor Green
}

$spKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider'
Set-ItemProperty -Path $spKey -Name 'LocalPriority' -Value 4 -Type DWord
Set-ItemProperty -Path $spKey -Name 'HostsPriority' -Value 5 -Type DWord
Set-ItemProperty -Path $spKey -Name 'DnsPriority' -Value 6 -Type DWord
Set-ItemProperty -Path $spKey -Name 'NetbtPriority' -Value 7 -Type DWord

$psched = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched'
if (-not (Test-Path $psched)) { New-Item -Path $psched -Force | Out-Null }
Set-ItemProperty -Path $psched -Name 'NonBestEffortLimit' -Value 0 -Type DWord
Clear-DnsClientCache
ipconfig /flushdns | Out-Null
Write-Host "  [+] DNS ServiceProvider priorities tuned + 100% bandwidth unreserved" -ForegroundColor Green
Write-Host "`n[OK] Network optimizations applied successfully!" -ForegroundColor Green

Read-Host "`nPress Enter to exit"
