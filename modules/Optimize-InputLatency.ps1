<#
================================================================================
  PumpkiN's Modular Suite: 8000Hz Input, Audio DPC & Hardware Interrupt Suite
================================================================================
#>

function Optimize-LatencyAndInput {
    Write-Host "`n[*] Forcing Zero DPC Latency Tolerance & 8000Hz Input Buffer..." -ForegroundColor Yellow
    # StopHighDPC & Latency Tolerance
    $pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatencyCheckEnabled' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'Latency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceFSVP' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyTolerancePerfOverride' -Value 1 -Type DWord

    # Dynamic Tick Jitter Elimination & x2APIC
    bcdedit /set disabledynamictick yes | Out-Null
    bcdedit /set x2apicpolicy Enable | Out-Null
    bcdedit /deletevalue useplatformclock 2>$null | Out-Null
    Write-Host "      [+] StopHighDPC active + x2APIC enabled + dynamic tick jitter eliminated" -ForegroundColor Green

    # Input Queues for High-Polling Gaming Mice (Up to 8000Hz)
    $mouKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters'
    if (Test-Path $mouKey) { Set-ItemProperty -Path $mouKey -Name 'MouseDataQueueSize' -Value 200 -Type DWord }
    $kbdKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters'
    if (Test-Path $kbdKey) { Set-ItemProperty -Path $kbdKey -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord }

    # USB Selective Suspend Disabled
    $usbKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
    if (-not (Test-Path $usbKey)) { New-Item -Path $usbKey -Force | Out-Null }
    Set-ItemProperty -Path $usbKey -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord

    # MarkC 1:1 Raw Mouse Acceleration Curve
    $mouseKey = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mouseKey -Name 'MouseSpeed' -Value '0' -Type String
    Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold1' -Value '0' -Type String
    Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold2' -Value '0' -Type String
    [byte[]]$smoothX = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x29,0xdc,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00
    [byte[]]$smoothY = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xa8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xe0,0x00,0x00,0x00,0x00,0x00
    Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseXCurve' -Value $smoothX -Type Binary
    Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseYCurve' -Value $smoothY -Type Binary
    Write-Host "      [+] 8000Hz Mouse Buffer tuned + 100% Raw 1:1 Mouse Input Curve applied" -ForegroundColor Green

    # CSRSS Realtime & Max I/O Priority
    Optimize-CsrssPriority

    # Disable USB & Device Power Saving (Always Full Power)
    if (Get-Command Disable-DevicePowerSaving -ErrorAction SilentlyContinue) {
        Disable-DevicePowerSaving
    }
}

function Optimize-CsrssPriority {
    Write-Host "`n[*] Setting CSRSS to Realtime CPU Priority & Maximum I/O Priority..." -ForegroundColor Yellow
    $csrssKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions'
    if (-not (Test-Path $csrssKey)) { New-Item -Path $csrssKey -Force | Out-Null }
    Set-ItemProperty -Path $csrssKey -Name 'CpuPriorityClass' -Value 4 -Type DWord
    Set-ItemProperty -Path $csrssKey -Name 'IoPriority' -Value 4 -Type DWord
    Write-Host "      [+] CSRSS Hooked -> Realtime CPU Priority (4) & Max I/O Priority (4)" -ForegroundColor Green
}

function Optimize-AudioDpcLatency {
    <#
    .SYNOPSIS
        Tuning Windows Audio MMCSS, Network Throttling, and Hardware MSI Mode for Audio Controllers.
    .DESCRIPTION
        Eliminates audio pops, latency spikes, and buffer dropouts during competitive gaming.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Optimizing Audio DPC Latency, MMCSS Priority & Controller IRQs..." -ForegroundColor Yellow

    # Multimedia SystemProfile Network Throttling & Responsiveness
    $sysProf = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    if (-not (Test-Path $sysProf)) { New-Item -Path $sysProf -Force | Out-Null }
    Set-ItemProperty -Path $sysProf -Name 'NetworkThrottlingIndex' -Value 0xFFFFFFFF -Type DWord
    Set-ItemProperty -Path $sysProf -Name 'SystemResponsiveness' -Value 0 -Type DWord

    # Multimedia Audio Task Scheduling
    $audioTask = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio'
    if (-not (Test-Path $audioTask)) { New-Item -Path $audioTask -Force | Out-Null }
    Set-ItemProperty -Path $audioTask -Name 'Affinity' -Value 0 -Type DWord
    Set-ItemProperty -Path $audioTask -Name 'Background Only' -Value 'False' -Type String
    Set-ItemProperty -Path $audioTask -Name 'Clock Rate' -Value 10000 -Type DWord
    Set-ItemProperty -Path $audioTask -Name 'GPU Priority' -Value 8 -Type DWord
    Set-ItemProperty -Path $audioTask -Name 'Priority' -Value 6 -Type DWord
    Set-ItemProperty -Path $audioTask -Name 'Scheduling Category' -Value 'High' -Type String
    Set-ItemProperty -Path $audioTask -Name 'SFIO Priority' -Value 'High' -Type String
    Write-Host "      [+] Audio MMCSS Task configured: High Scheduling Category & Priority 6" -ForegroundColor Green

    # High Definition Audio Controller MSI Mode & High Priority
    $pciBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI'
    $audioCount = 0
    if (Test-Path $pciBase) {
        $pciDevices = Get-ChildItem -Path $pciBase -ErrorAction SilentlyContinue
        foreach ($dev in $pciDevices) {
            $instances = Get-ChildItem -Path $dev.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $props = Get-ItemProperty -Path $inst.PSPath -ErrorAction SilentlyContinue
                if (-not $props) { continue }

                if ($props.Class -eq 'MEDIA' -or $props.ClassGUID -eq '{4d36e96c-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'HDAudBus|IntcAzAudAddService|Realtek') {
                    $devParam = Join-Path $inst.PSPath 'Device Parameters'
                    $intMgmt = Join-Path $devParam 'Interrupt Management'
                    $msiProps = Join-Path $intMgmt 'MessageSignaledInterruptProperties'
                    $affPolicy = Join-Path $intMgmt 'Affinity Policy'

                    if (-not (Test-Path $msiProps)) { New-Item -Path $msiProps -Force | Out-Null }
                    Set-ItemProperty -Path $msiProps -Name 'MSISupported' -Value 1 -Type DWord -ErrorAction SilentlyContinue

                    if (-not (Test-Path $affPolicy)) { New-Item -Path $affPolicy -Force | Out-Null }
                    Set-ItemProperty -Path $affPolicy -Name 'DevicePriority' -Value 3 -Type DWord -ErrorAction SilentlyContinue

                    $name = if ($props.DeviceDesc) { ($props.DeviceDesc -replace ';.*', '') } else { "Audio Controller" }
                    Write-Host "      [+] Audio Controller MSI Mode & High Priority: $name" -ForegroundColor Green
                    $audioCount++
                }
            }
        }
    }

    Write-Host "      [OK] Audio DPC Latency optimization applied ($audioCount Audio Controllers hooked)!" -ForegroundColor Green
    return $true
}

function Optimize-UsbLatencyAndBuffers {
    <#
    .SYNOPSIS
        Sets real-time USB xHCI thread priority, enables MSI Mode on USB controllers, and maximizes input buffers.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Tuning USB xHCI Realtime Thread Priority & Polling Queues..." -ForegroundColor Yellow

    # USBXHCI Realtime ThreadPriority
    $xhciKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBXHCI\Parameters'
    if (-not (Test-Path $xhciKey)) { New-Item -Path $xhciKey -Force | Out-Null }
    Set-ItemProperty -Path $xhciKey -Name 'ThreadPriority' -Value 31 -Type DWord
    Write-Host "      [+] USBXHCI ThreadPriority set to 31 (Realtime Kernel Execution)" -ForegroundColor Green

    # High-Polling Input Queues
    $mouKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters'
    if (Test-Path $mouKey) { Set-ItemProperty -Path $mouKey -Name 'MouseDataQueueSize' -Value 200 -Type DWord }
    $kbdKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters'
    if (Test-Path $kbdKey) { Set-ItemProperty -Path $kbdKey -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord }

    # USB Host Controllers MSI Mode & High Priority
    $pciBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI'
    $usbCount = 0
    if (Test-Path $pciBase) {
        $pciDevices = Get-ChildItem -Path $pciBase -ErrorAction SilentlyContinue
        foreach ($dev in $pciDevices) {
            $instances = Get-ChildItem -Path $dev.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $props = Get-ItemProperty -Path $inst.PSPath -ErrorAction SilentlyContinue
                if (-not $props) { continue }

                if ($props.Class -eq 'USB' -or $props.ClassGUID -eq '{36fc9e60-c465-11cf-8056-444553540000}' -or $props.Service -match 'USBXHCI|usbehci') {
                    $devParam = Join-Path $inst.PSPath 'Device Parameters'
                    $intMgmt = Join-Path $devParam 'Interrupt Management'
                    $msiProps = Join-Path $intMgmt 'MessageSignaledInterruptProperties'
                    $affPolicy = Join-Path $intMgmt 'Affinity Policy'

                    if (-not (Test-Path $msiProps)) { New-Item -Path $msiProps -Force | Out-Null }
                    Set-ItemProperty -Path $msiProps -Name 'MSISupported' -Value 1 -Type DWord -ErrorAction SilentlyContinue

                    if (-not (Test-Path $affPolicy)) { New-Item -Path $affPolicy -Force | Out-Null }
                    Set-ItemProperty -Path $affPolicy -Name 'DevicePriority' -Value 3 -Type DWord -ErrorAction SilentlyContinue

                    $name = if ($props.DeviceDesc) { ($props.DeviceDesc -replace ';.*', '') } else { "USB Controller" }
                    Write-Host "      [+] USB Controller MSI Mode & High Priority: $name" -ForegroundColor Green
                    $usbCount++
                }
            }
        }
    }

    if (Get-Command Disable-DevicePowerSaving -ErrorAction SilentlyContinue) {
        Disable-DevicePowerSaving
    }

    Write-Host "      [OK] USB xHCI latency and buffer tuning complete ($usbCount USB Controllers hooked)!" -ForegroundColor Green
    return $true
}

function Get-HardwareInterruptReport {
    <#
    .SYNOPSIS
        Scans all critical PCI controllers and returns MSI Mode and Priority statuses.
    #>
    [CmdletBinding()]
    param()

    $pciBase = 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI'
    $report = @()
    if (Test-Path $pciBase) {
        $pciDevices = Get-ChildItem -Path $pciBase -ErrorAction SilentlyContinue
        foreach ($dev in $pciDevices) {
            $instances = Get-ChildItem -Path $dev.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $props = Get-ItemProperty -Path $inst.PSPath -ErrorAction SilentlyContinue
                if (-not $props) { continue }

                $cat = $null
                if ($props.Class -eq 'Display' -or $props.ClassGUID -eq '{4d36e968-e325-11ce-bfc1-08002be10318}') {
                    $cat = "GPU"
                } elseif ($props.Class -eq 'USB' -or $props.ClassGUID -eq '{36fc9e60-c465-11cf-8056-444553540000}' -or $props.Service -match 'USBXHCI|usbehci') {
                    $cat = "USB"
                } elseif ($props.Class -eq 'Net' -or $props.ClassGUID -eq '{4d36e972-e325-11ce-bfc1-08002be10318}') {
                    $cat = "Network"
                } elseif ($props.Class -eq 'MEDIA' -or $props.ClassGUID -eq '{4d36e96c-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'HDAudBus|IntcAzAudAddService|Realtek') {
                    $cat = "Audio"
                } elseif ($props.Class -eq 'SCSIAdapter' -or $props.ClassGUID -eq '{4d36e97b-e325-11ce-bfc1-08002be10318}' -or $props.Service -match 'stornvme') {
                    $cat = "NVMe"
                }

                if ($cat) {
                    $devParam = Join-Path $inst.PSPath 'Device Parameters'
                    $intMgmt = Join-Path $devParam 'Interrupt Management'
                    $msiProps = Join-Path $intMgmt 'MessageSignaledInterruptProperties'
                    $affPolicy = Join-Path $intMgmt 'Affinity Policy'

                    $msiVal = 0
                    if (Test-Path $msiProps) {
                        $m = Get-ItemProperty -Path $msiProps -ErrorAction SilentlyContinue
                        if ($m -and $m.MSISupported -ne $null) { $msiVal = $m.MSISupported }
                    }

                    $prioVal = 0
                    if (Test-Path $affPolicy) {
                        $p = Get-ItemProperty -Path $affPolicy -ErrorAction SilentlyContinue
                        if ($p -and $p.DevicePriority -ne $null) { $prioVal = $p.DevicePriority }
                    }

                    $prioText = switch ($prioVal) {
                        3 { "High" }
                        2 { "Normal" }
                        1 { "Low" }
                        default { "Undefined" }
                    }

                    $desc = if ($props.DeviceDesc) { ($props.DeviceDesc -replace ';.*', '') } else { $cat }
                    $report += [PSCustomObject]@{
                        Category     = $cat
                        DeviceName   = $desc
                        MSISupported = ($msiVal -eq 1)
                        Priority     = $prioText
                        PriorityVal  = $prioVal
                    }
                }
            }
        }
    }
    return $report
}

function Restore-AudioDpcAndUsbLatency {
    <#
    .SYNOPSIS
        Restores Windows default MMCSS audio task and input settings.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Restoring Windows Default Audio MMCSS & Input Settings..." -ForegroundColor Yellow

    # Restore Multimedia SystemProfile defaults
    $sysProf = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    if (Test-Path $sysProf) {
        Set-ItemProperty -Path $sysProf -Name 'NetworkThrottlingIndex' -Value 10 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $sysProf -Name 'SystemResponsiveness' -Value 20 -Type DWord -ErrorAction SilentlyContinue
    }

    # Restore Audio MMCSS Task defaults
    $audioTask = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio'
    if (Test-Path $audioTask) {
        Set-ItemProperty -Path $audioTask -Name 'Background Only' -Value 'True' -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'Clock Rate' -Value 10000 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'GPU Priority' -Value 8 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'Priority' -Value 6 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'Scheduling Category' -Value 'Medium' -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $audioTask -Name 'SFIO Priority' -Value 'Normal' -Type String -ErrorAction SilentlyContinue
    }

    # Remove USBXHCI ThreadPriority override
    $xhciKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBXHCI\Parameters'
    if (Test-Path $xhciKey) {
        Remove-ItemProperty -Path $xhciKey -Name 'ThreadPriority' -ErrorAction SilentlyContinue
    }

    # Reset DataQueueSizes to 100
    $mouKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters'
    if (Test-Path $mouKey) { Set-ItemProperty -Path $mouKey -Name 'MouseDataQueueSize' -Value 100 -Type DWord -ErrorAction SilentlyContinue }
    $kbdKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters'
    if (Test-Path $kbdKey) { Set-ItemProperty -Path $kbdKey -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord -ErrorAction SilentlyContinue }

    # Reset bcdedit dynamic tick
    bcdedit /deletevalue disabledynamictick 2>$null | Out-Null

    Write-Host "      [OK] Windows Audio MMCSS and USB Input settings restored to defaults." -ForegroundColor Green
    return $true
}

function Restore-MouseLinearCurve {
    Write-Host "`n[*] Restoring Windows Default Mouse Acceleration Curve..." -ForegroundColor Yellow
    $defaultX = [byte[]](0,0,0,0,0,0,0,0,15,10,0,0,0,0,0,0,0,20,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,70,0,0,0,0,0,0)
    $defaultY = [byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'SmoothMouseXCurve' -Value $defaultX -Type Binary -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'SmoothMouseYCurve' -Value $defaultY -Type Binary -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSensitivity' -Value '10' -Type String -ErrorAction SilentlyContinue
    Write-Host "      [+] Windows default mouse curve restored." -ForegroundColor Green
}

# If run directly as standalone script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Write-Host "=== PUMPKIN DPC LATENCY & HARDWARE INTERRUPT SUITE ===" -ForegroundColor Cyan
    Write-Host "1. Full 8000Hz Input Buffer & Latency Optimization"
    Write-Host "2. Low-Latency Audio & Anti-Popping (MMCSS & Audio MSI Mode)"
    Write-Host "3. USB xHCI Realtime Thread Priority & Polling Queues"
    Write-Host "4. View Hardware Interrupt & MSI Report"
    Write-Host "5. Restore Default Audio MMCSS & Input Settings"
    $ans = Read-Host "Select option [1-5]"
    switch ($ans) {
        "1" { Optimize-LatencyAndInput }
        "2" { Optimize-AudioDpcLatency }
        "3" { Optimize-UsbLatencyAndBuffers }
        "4" {
            $rep = Get-HardwareInterruptReport
            Write-Host "`nHardware Interrupt & MSI Status:" -ForegroundColor Cyan
            $rep | Format-Table -AutoSize | Out-Host
        }
        "5" { Restore-AudioDpcAndUsbLatency }
    }
    Read-Host "`nPress Enter to exit"
}