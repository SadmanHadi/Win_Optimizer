<#
================================================================================
  PumpkiN's Modular Suite: Competitive Match Standby Memory Purger & Booster
================================================================================
#>

function Boost-CompetitiveMatch {
    Write-Host "`n[*] Purging Kernel Standby Memory & Idle Working Sets..." -ForegroundColor Yellow

    $exeCandidates = @(
        "$PSScriptRoot\EmptyStandbyList.exe",
        "$PSScriptRoot\..\EmptyStandbyList.exe",
        "$env:SystemRoot\System32\EmptyStandbyList.exe",
        "e:\Projects\Win_Optimizer\EmptyStandbyList.exe"
    )
    $emptyListExe = $exeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

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

        # Verify / Activate 5-minute background Task Scheduler job
        $TaskName = "PumpkiN_AutoEmptyStandbyList"
        $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existing) {
            $info = Get-ScheduledTaskInfo -TaskName $TaskName
            Write-Host "      [+] 5-Minute Background Auto-Cleaner: ACTIVE (Next run: $($info.NextRunTime))" -ForegroundColor Green
        } else {
            try {
                $action = New-ScheduledTaskAction -Execute $emptyListExe -Argument "standbylist"
                $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
                $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
                $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -Priority 4
                Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
                Start-ScheduledTask -TaskName $TaskName
                Write-Host "      [+] 5-Minute Background Auto-Cleaner registered and active in Task Scheduler!" -ForegroundColor Green
            } catch {
                Write-Host "      [!] Task Scheduler note: $($_.Exception.Message)" -ForegroundColor DarkYellow
            }
        }
    } else {
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Write-Host "      [+] CLR Garbage collector executed (EmptyStandbyList.exe optional fallback)" -ForegroundColor Yellow
    }
}

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"" -Verb RunAs
        exit
    }
    Boost-CompetitiveMatch
    Read-Host "
Press Enter to exit"
}