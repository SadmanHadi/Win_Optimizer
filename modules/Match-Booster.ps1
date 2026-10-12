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
    "TslGame", "PUBG",
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

    Write-Host "`n[*] Stopping Smart Game Booster Daemon..." -ForegroundColor Yellow

    if ($Script:DaemonSync -and $Script:DaemonSync.IsRunning) {
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
    } else {
        Write-Host "      [+] Smart Game Booster Daemon is not currently running." -ForegroundColor Gray
        return $true
    }
}

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
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