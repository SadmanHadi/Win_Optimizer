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

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
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