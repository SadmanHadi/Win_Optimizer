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

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Invoke-EmptyStandbyListOneTime
    Read-Host "`nPress Enter to exit"
}