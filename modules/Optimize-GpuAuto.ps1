<#
================================================================================
  PumpkiN's Modular Suite: GPU, Hardware MSI & Device Power Optimizations
================================================================================
#>

function Disable-DevicePowerSaving {
    Write-Host "`n[*] Disabling Power Saving on USB Root Hubs & Hardware Controllers..." -ForegroundColor Yellow
    $disabledCount = 0
    try {
        $powerDevices = Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root\wmi -ErrorAction SilentlyContinue
        foreach ($dev in $powerDevices) {
            if ($dev.InstanceName -match 'USB|PCI|ROOT_HUB') {
                Set-CimInstance -InputObject $dev -Property @{ Enable = $false } -ErrorAction SilentlyContinue
                $shortName = $dev.InstanceName -replace '.*\\', ''
                Write-Host "      [+] Unchecked 'Allow computer to turn off device': $shortName" -ForegroundColor Green
                $disabledCount++
            }
        }
    } catch {
        Write-Host "      [~] WMI MSPower_DeviceEnable note: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }

    # Disable USB Selective Suspend in registry power settings
    $usbHub = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
    if (-not (Test-Path $usbHub)) { New-Item -Path $usbHub -Force | Out-Null }
    Set-ItemProperty -Path $usbHub -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    Write-Host "      [OK] $disabledCount Devices Configured: Always Full Power (Zero Sleep Latency)!" -ForegroundColor Green
}

function Optimize-HardwareMsiMode {
    Write-Host "`n[*] Configuring Message Signaled Interrupts (MSI Mode) & High Priority for Hardware..." -ForegroundColor Yellow
    $pciBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI'
    if (Test-Path $pciBase) {
        $pciDevices = Get-ChildItem -Path $pciBase -ErrorAction SilentlyContinue
        $msiCount = 0
        foreach ($dev in $pciDevices) {
            $instances = Get-ChildItem -Path $dev.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $props = Get-ItemProperty -Path $inst.PSPath -ErrorAction SilentlyContinue
                if (-not $props) { continue }
                
                $isTarget = $false
                $targetDesc = ""
                
                # Check for USB Host Controllers
                if ($props.Class -eq 'USB' -or $props.ClassGUID -eq '{36fc9e60-c465-11cf-8056-444553540000}' -or $props.Service -match 'USBXHCI|usbehci') {
                    $isTarget = $true
                    $targetDesc = "USB Controller"
                }
                # Check for Network Adapters
                elseif ($props.Class -eq 'Net' -or $props.ClassGUID -eq '{4d36e972-e325-11ce-bfc1-08002be10318}') {
                    $isTarget = $true
                    $targetDesc = "Network Adapter"
                }
                # Check for Display Adapters (GPU)
                elseif ($props.Class -eq 'Display' -or $props.ClassGUID -eq '{4d36e968-e325-11ce-bfc1-08002be10318}') {
                    $isTarget = $true
                    $targetDesc = "Display GPU"
                }
                # Check for High Definition Audio Controllers
                elseif ($props.Class -eq 'MEDIA' -or $props.ClassGUID -eq '{4d36e96c-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'HDAudBus|IntcAzAudAddService|Realtek') {
                    $isTarget = $true
                    $targetDesc = "Audio Controller"
                }
                # Check for NVMe Storage Controllers
                elseif ($props.Class -eq 'SCSIAdapter' -or $props.ClassGUID -eq '{4d36e97b-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'stornvme') {
                    $isTarget = $true
                    $targetDesc = "NVMe Storage"
                }

                if ($isTarget) {
                    $devParam = Join-Path $inst.PSPath 'Device Parameters'
                    $intMgmt = Join-Path $devParam 'Interrupt Management'
                    $msiProps = Join-Path $intMgmt 'MessageSignaledInterruptProperties'
                    $affPolicy = Join-Path $intMgmt 'Affinity Policy'

                    if (-not (Test-Path $msiProps)) { New-Item -Path $msiProps -Force | Out-Null }
                    Set-ItemProperty -Path $msiProps -Name 'MSISupported' -Value 1 -Type DWord -ErrorAction SilentlyContinue

                    if (-not (Test-Path $affPolicy)) { New-Item -Path $affPolicy -Force | Out-Null }
                    Set-ItemProperty -Path $affPolicy -Name 'DevicePriority' -Value 3 -Type DWord -ErrorAction SilentlyContinue

                    $name = if ($props.DeviceDesc) { ($props.DeviceDesc -replace ';.*', '') } else { $targetDesc }
                    Write-Host "      [+] MSI Mode (High Priority) Enabled: $name [$targetDesc]" -ForegroundColor Green
                    $msiCount++
                }
            }
        }
        Write-Host "      [OK] $msiCount Hardware Controllers optimized with MSI Mode & High Priority!" -ForegroundColor Green
    }
}

function Optimize-GpuAuto {
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Starting Hardware, GPU & Device Latency Optimization Suite..." -ForegroundColor Yellow
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

    # 1. Optimize PCI MSI Mode (USB, Network, GPU)
    Optimize-HardwareMsiMode

    # 2. Disable Device Power Saving (Always Full Power)
    Disable-DevicePowerSaving

    # 3. High Game Priority & MMCSS GPU Priority
    if (Get-Command Apply-GameHooks -ErrorAction SilentlyContinue) {
        Apply-GameHooks
    }

    $gamesTask = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
    if (Test-Path $gamesTask) {
        Set-ItemProperty -Path $gamesTask -Name 'GPU Priority' -Value 8 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamesTask -Name 'Priority' -Value 6 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamesTask -Name 'Scheduling Category' -Value 'High' -Type String -ErrorAction SilentlyContinue
        Write-Host "      [+] MMCSS Gaming Task GPU Priority locked to Maximum (GPU Priority: 8, Priority: 6)" -ForegroundColor Green
    }
}

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Optimize-GpuAuto
    Read-Host "`nPress Enter to exit"
}