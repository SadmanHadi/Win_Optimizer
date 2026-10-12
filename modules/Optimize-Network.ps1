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

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"" -Verb RunAs
        exit
    }
    Optimize-Network
    Read-Host "
Press Enter to exit"
}