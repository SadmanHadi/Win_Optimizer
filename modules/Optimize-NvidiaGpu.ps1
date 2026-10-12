<#
================================================================================
 PumpkiN's Modular Suite: NVIDIA GeForce GPU Optimizer
 - Locks PowerMizer into Maximum Performance state (P0 State)
 - Prevents dynamic downclocking in CPU-bound esports titles
 - Flushes stale DirectX and OpenGL shader caches
================================================================================
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "================================================================================" -ForegroundColor Green
Write-Host "             NVIDIA GEFORCE DEDICATED OPTIMIZATION (POWERMIZER P0)              " -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""

$classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
$nvFound = 0

foreach ($sub in 0..9) {
    $subKey = "{0:D4}" -f $sub
    $targetPath = "$classPath\$subKey"
    if (Test-Path $targetPath) {
        $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
        if ($props -and ($props.DriverDesc -match 'NVIDIA' -or $props.ProviderName -match 'NVIDIA')) {
            $nvFound++
            Write-Host "Found NVIDIA Adapter at Key [$subKey]: $($props.DriverDesc)" -ForegroundColor Cyan
            Set-ItemProperty -Path $targetPath -Name 'PowerMizerEnable' -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevel' -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevelAC' -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Write-Host "  [+] PowerMizer locked to Maximum Performance (P0 State - No clock drops)" -ForegroundColor Green
        }
    }
}

$nvCaches = @(
    "$env:LOCALAPPDATA\NVIDIA\DXCache",
    "$env:LOCALAPPDATA\NVIDIA\GLCache",
    "$env:LOCALAPPDATA\D3DSCache"
)
foreach ($cacheDir in $nvCaches) {
    if (Test-Path $cacheDir) {
        Remove-Item "$cacheDir\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  [+] Flushed shader cache: $cacheDir" -ForegroundColor Green
    }
}

if ($nvFound -eq 0) {
    Write-Host "`n[!] No active NVIDIA card found." -ForegroundColor DarkYellow
} else {
    Write-Host "`n[OK] NVIDIA GPU Optimized successfully!" -ForegroundColor Green
}

Read-Host "`nPress Enter to exit"
