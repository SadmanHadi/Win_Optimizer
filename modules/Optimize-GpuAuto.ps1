<#
================================================================================
  PumpkiN's Modular Suite: GPU Auto-Detection & Routing
================================================================================
#>

function Optimize-GpuAuto {
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Detecting active GPU for dedicated optimization suite..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile
    if ($hw.HasNvidia) {
        Write-Host "      [+] NVIDIA GeForce GPU detected! Launching NVIDIA Dedicated Suite..." -ForegroundColor Green
        Optimize-NvidiaGpu
    }
    if ($hw.HasAmdGpu) {
        Write-Host "      [+] AMD Radeon GPU detected! Launching AMD Radeon Dedicated Suite..." -ForegroundColor Magenta
        Optimize-AmdGpu
    }
    if (-not $hw.HasNvidia -and -not $hw.HasAmdGpu) {
        Write-Host "      [!] Generic/Integrated GPU detected. Applying Universal Direct Flip tweaks..." -ForegroundColor DarkYellow
        $dwmKey = 'HKCU:\Software\Microsoft\Windows\DWM'
        if (-not (Test-Path $dwmKey)) { New-Item -Path $dwmKey -Force | Out-Null }
        Set-ItemProperty -Path $dwmKey -Name 'EnableWindowColorization' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
}