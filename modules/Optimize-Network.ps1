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
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Optimize-Network
    Read-Host "`nPress Enter to exit"
}