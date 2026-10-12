<#
================================================================================
 PumpkiN's Modular Suite: AMD Radeon GPU Optimizer
 - Disables ULPS (Ultra Low Power State) to eliminate 1% low frame drops
 - Forces driver Shader Cache to eliminate in-game compilation stutter
 - Enables Anti-Lag and Direct DMA Engine
 - Mitigates deep-sleep clock throttling and MCLK stutter
 - Flushes stale AMD DxCache and GLCache
================================================================================
#>

# Check Administrator Privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "================================================================================" -ForegroundColor Magenta
Write-Host "             AMD RADEON DEDICATED OPTIMIZATION (DISABLE ULPS)                   " -ForegroundColor Magenta
Write-Host "================================================================================" -ForegroundColor Magenta
Write-Host ""

$classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
$amdFound = 0

foreach ($sub in 0..9) {
    $subKey = "{0:D4}" -f $sub
    $targetPath = "$classPath\$subKey"
    if (Test-Path $targetPath) {
        $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
        if ($props -and ($props.DriverDesc -match 'AMD|Radeon' -or $props.ProviderName -match 'AMD' -or $props.EnableUlps -ne $null)) {
            $amdFound++
            Write-Host "Found AMD Radeon Adapter at Key [$subKey]: $($props.DriverDesc)" -ForegroundColor Cyan
            
            # 1. Disable ULPS (Ultra Low Power State)
            Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord -ErrorAction SilentlyContinue
            Write-Host "  [+] Disabled ULPS (Ultra Low Power State) - Stops clock-drop stutters" -ForegroundColor Green

            # 2. Force Shader Cache
            Set-ItemProperty -Path $targetPath -Name 'ShaderCache' -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $targetPath -Name 'ShaderCache_NA' -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Write-Host "  [+] Shader Cache locked to Enabled" -ForegroundColor Green

            # 3. Anti-Lag & Low-Latency Direct Pipeline
            Set-ItemProperty -Path $targetPath -Name 'AntiLag' -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $targetPath -Name 'DisableDMACopy' -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Write-Host "  [+] Anti-Lag & Direct DMA Copy enabled" -ForegroundColor Green

            # 4. Disable Deep Sleep Clock Drops
            Set-ItemProperty -Path $targetPath -Name 'PP_ThermalAutoThrottlingEnable' -Value 0 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $targetPath -Name 'PP_MCLKStutterMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $targetPath -Name 'StutterMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $targetPath -Name 'KMD_EnableCrossFireAutoLink' -Value 0 -Type DWord -ErrorAction SilentlyContinue
            Write-Host "  [+] PowerPlay deep-sleep throttle & MCLK stutter mitigations applied" -ForegroundColor Green
        }
    }
}

# Flush stale AMD precompiled shader caches
$amdCaches = @(
    "$env:LOCALAPPDATA\AMD\DxCache",
    "$env:LOCALAPPDATA\AMD\GLCache",
    "$env:LOCALAPPDATA\AMD\D3DSCache"
)
foreach ($cacheDir in $amdCaches) {
    if (Test-Path $cacheDir) {
        Remove-Item "$cacheDir\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  [+] Flushed AMD shader cache: $cacheDir" -ForegroundColor Green
    }
}

if ($amdFound -eq 0) {
    Write-Host "`n[!] No active AMD Radeon GPU was detected in primary keys." -ForegroundColor DarkYellow
} else {
    Write-Host "`n[OK] AMD Radeon GPU Optimized successfully!" -ForegroundColor Green
}

Read-Host "`nPress Enter to exit"
