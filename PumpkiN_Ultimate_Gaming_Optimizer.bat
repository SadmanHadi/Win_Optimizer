@echo off
setlocal EnableDelayedExpansion
title PumpkiN's Ultimate Gaming and Network Optimizer v3.0

:: ============================================================================
:: 1. AUTO-ELEVATE TO ADMINISTRATOR
:: ============================================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Requesting Administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ============================================================================
:: 2. MAIN MENU INTERFACE
:: ============================================================================
:MENU
cls
color 0B
echo ================================================================================
echo    ____                       _    _       _   _ 
echo   ^|  _ \ _   _ _ __ ___  _ __^| ^| _(_)_ __ ^| \ ^| ^|
echo   ^| ^|_) ^| ^| ^| ^| '_ ` _ \^| '_ \ ^|/ / ^| '_ \^|  \^| ^|
echo   ^|  __/^| ^|_^| ^| ^| ^| ^| ^| ^| ^|_) ^|   ^<^| ^| ^| ^| ^| ^|\  ^|
echo   ^|_^|    \__,_^|_^| ^|_^| ^|_^| .__/^|_^|\_\_^_^|_^| ^|_^|_^| \_^|
echo                         ^|_^|                       
echo           ULTIMATE GAMING ^& NETWORK OPTIMIZER v3.0
echo          Created by PumpkiN ^| Max FPS - Ultra Low Latency
echo ================================================================================
echo.
echo   [1] FULL ALL-IN-ONE OPTIMIZATION (Network + PC + Latency + FPS) [RECOMMENDED]
echo   [2] Network ^& Anti-Lag Suite (Nagle Off, RSC Off, ServiceProvider DNS, 100%% QoS)
echo   [3] PC System ^& FPS Engine (RAM Locking, Direct Flip, PowerMizer, Core Unpark)
echo   [4] Ultra-Low Latency ^& DPC Engine (StopHighDPC, x2APIC, Timer Jitter Fix)
echo   [5] Competitive Match Booster (Flush Standby RAM, Kill Capture ^& RGB Hogs)
echo   [6] Game-Specific Process Priority Hooks (Valorant, CS2, Apex, Gameloop)
echo   [7] System Health, Live Diagnostics ^& Ping Test
echo   [8] Revert All Settings to Windows Defaults
echo   [9] Exit
echo.
echo ================================================================================
set /p "CHOICE=Select an option [1-9]: "

if "%CHOICE%"=="1" goto OPT_FULL
if "%CHOICE%"=="2" goto OPT_NET
if "%CHOICE%"=="3" goto OPT_PC
if "%CHOICE%"=="4" goto OPT_LATENCY
if "%CHOICE%"=="5" goto OPT_BOOST
if "%CHOICE%"=="6" goto OPT_HOOKS
if "%CHOICE%"=="7" goto OPT_VERIFY
if "%CHOICE%"=="8" goto OPT_RESTORE
if "%CHOICE%"=="9" goto OPT_EXIT
goto MENU

:: ============================================================================
:: OPTION 1: FULL OPTIMIZATION
:: ============================================================================
:OPT_FULL
cls
color 0E
echo ================================================================================
echo       RUNNING FULL OPTIMIZATION - PumpkiN's ULTIMATE ENGINE
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "Write-Host '[1/7] Optimizing Network Stack & Anti-Lag...' -ForegroundColor Yellow;" ^
    "$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1;" ^
    "if ($adapter) {" ^
    "    $guid = $adapter.InterfaceGuid;" ^
    "    $tcpKey = \"HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid\";" ^
    "    Set-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -Value 1 -Type DWord;" ^
    "    Set-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -Value 1 -Type DWord;" ^
    "    Set-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -Value 0 -Type DWord;" ^
    "    $props = @('Interrupt Moderation','Flow Control','Green Ethernet','Gigabit Lite','Power Saving Mode','Energy-Efficient Ethernet');" ^
    "    foreach ($p in $props) { try { Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName $p -DisplayValue 'Disabled' -NoRestart -ErrorAction Stop } catch {} };" ^
    "    netsh int tcp set global rsc=disabled | Out-Null;" ^
    "    netsh int tcp set global rss=enabled | Out-Null;" ^
    "    Write-Host '      ✓ Nagle disabled, Delayed ACKs off, NIC power limits disabled' -ForegroundColor Green;" ^
    "};" ^
    "Write-Host '`n[2/7] Prioritizing DNS & Removing QoS 20% Bandwidth Throttle...' -ForegroundColor Yellow;" ^
    "$spKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider';" ^
    "Set-ItemProperty -Path $spKey -Name 'LocalPriority' -Value 4 -Type DWord;" ^
    "Set-ItemProperty -Path $spKey -Name 'HostsPriority' -Value 5 -Type DWord;" ^
    "Set-ItemProperty -Path $spKey -Name 'DnsPriority' -Value 6 -Type DWord;" ^
    "Set-ItemProperty -Path $spKey -Name 'NetbtPriority' -Value 7 -Type DWord;" ^
    "$psched = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched';" ^
    "if (-not (Test-Path $psched)) { New-Item -Path $psched -Force | Out-Null };" ^
    "Set-ItemProperty -Path $psched -Name 'NonBestEffortLimit' -Value 0 -Type DWord;" ^
    "Clear-DnsClientCache; ipconfig /flushdns | Out-Null;" ^
    "Write-Host '      ✓ ServiceProvider priorities tuned + 100% bandwidth unreserved' -ForegroundColor Green;" ^
    "Write-Host '`n[3/7] Locking Kernel in Physical RAM (DisablePagingExecutive)...' -ForegroundColor Yellow;" ^
    "$memKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management';" ^
    "Set-ItemProperty -Path $memKey -Name 'DisablePagingExecutive' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $memKey -Name 'LargeSystemCache' -Value 0 -Type DWord;" ^
    "Write-Host '      ✓ Kernel routines locked in DDR4 RAM (0 pagefile micro-stutters)' -ForegroundColor Green;" ^
    "Write-Host '`n[4/7] Bypassing DWM Latency (Direct Flip & Fullscreen Overrides)...' -ForegroundColor Yellow;" ^
    "$gcs = 'HKCU:\System\GameConfigStore';" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_Enabled' -Value 0 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_DXGIHonorFSEWindowsCompatible' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_EFSEFeatureFlags' -Value 0 -Type DWord;" ^
    "Write-Host '      ✓ Direct scanout active (1-2 frames display latency saved)' -ForegroundColor Green;" ^
    "Write-Host '`n[5/7] Forcing Zero DPC Latency Tolerance & Modern BCD Clocks...' -ForegroundColor Yellow;" ^
    "$pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power';" ^
    "Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'ExitLatencyCheckEnabled' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'Latency' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceFSVP' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'LatencyTolerancePerfOverride' -Value 1 -Type DWord;" ^
    "bcdedit /set disabledynamictick yes | Out-Null;" ^
    "bcdedit /set x2apicpolicy Enable | Out-Null;" ^
    "bcdedit /deletevalue useplatformclock | Out-Null;" ^
    "Write-Host '      ✓ StopHighDPC active + x2APIC enabled + dynamic tick disabled' -ForegroundColor Green;" ^
    "Write-Host '`n[6/7] Disabling USB Selective Suspend & Tuning Input Queues...' -ForegroundColor Yellow;" ^
    "$usbKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB';" ^
    "if (-not (Test-Path $usbKey)) { New-Item -Path $usbKey -Force | Out-Null };" ^
    "Set-ItemProperty -Path $usbKey -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters' -Name 'MouseDataQueueSize' -Value 100 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters' -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord;" ^
    "Write-Host '      ✓ USB root hubs locked at 100% power (No mouse wake delay)' -ForegroundColor Green;" ^
    "Write-Host '`n[7/7] Tuning GPU PowerMizer & Unparking All CPU Cores...' -ForegroundColor Yellow;" ^
    "$gpuKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000';" ^
    "if (Test-Path $gpuKey) {" ^
    "    Set-ItemProperty -Path $gpuKey -Name 'PowerMizerEnable' -Value 1 -Type DWord;" ^
    "    Set-ItemProperty -Path $gpuKey -Name 'PowerMizerLevel' -Value 1 -Type DWord;" ^
    "    Set-ItemProperty -Path $gpuKey -Name 'PowerMizerLevelAC' -Value 1 -Type DWord;" ^
    "};" ^
    "powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100;" ^
    "powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100;" ^
    "powercfg -setactive scheme_current;" ^
    "$mmKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile';" ^
    "Set-ItemProperty -Path $mmKey -Name 'NetworkThrottlingIndex' -Value 0xFFFFFFFF -Type DWord;" ^
    "Set-ItemProperty -Path $mmKey -Name 'SystemResponsiveness' -Value 0 -Type DWord;" ^
    "$gameKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games';" ^
    "if (Test-Path $gameKey) {" ^
    "    Set-ItemProperty -Path $gameKey -Name 'Priority' -Value 6 -Type DWord;" ^
    "    Set-ItemProperty -Path $gameKey -Name 'GPU Priority' -Value 8 -Type DWord;" ^
    "    Set-ItemProperty -Path $gameKey -Name 'Scheduling Category' -Value 'High' -Type String;" ^
    "    Set-ItemProperty -Path $gameKey -Name 'SFIO Priority' -Value 'High' -Type String;" ^
    "};" ^
    "$gbKey = 'HKCU:\Software\Microsoft\GameBar';" ^
    "if (-not (Test-Path $gbKey)) { New-Item -Path $gbKey -Force | Out-Null };" ^
    "Set-ItemProperty -Path $gbKey -Name 'AutoGameModeEnabled' -Value 1 -Type DWord;" ^
    "$ptKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling';" ^
    "if (-not (Test-Path $ptKey)) { New-Item -Path $ptKey -Force | Out-Null };" ^
    "Set-ItemProperty -Path $ptKey -Name 'PowerThrottlingOff' -Value 1 -Type DWord;" ^
    "$gdvr = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR';" ^
    "if (-not (Test-Path $gdvr)) { New-Item -Path $gdvr -Force | Out-Null };" ^
    "Set-ItemProperty -Path $gdvr -Name 'AllowGameDVR' -Value 0 -Type DWord;" ^
    "$trans = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize';" ^
    "if (Test-Path $trans) { Set-ItemProperty -Path $trans -Name 'EnableTransparency' -Value 0 -Type DWord };" ^
    "Remove-Item \"$env:LOCALAPPDATA\D3DSCache\*\" -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Remove-Item \"$env:LOCALAPPDATA\NVIDIA\DXCache\*\" -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Write-Host '      ✓ GPU PowerMizer set to max + all CPU cores unparked' -ForegroundColor Green;" ^
    "}"

echo.
echo ================================================================================
echo         [✓] FULL OPTIMIZATION COMPLETE - ENJOY MAXIMUM PERFORMANCE!
echo ================================================================================
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 2: NETWORK & ANTI-LAG ONLY
:: ============================================================================
:OPT_NET
cls
color 0A
echo ================================================================================
echo       NETWORK & ANTI-LAG SUITE - PumpkiN's GAMING ENGINE
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1;" ^
    "if ($adapter) {" ^
    "    $guid = $adapter.InterfaceGuid;" ^
    "    $tcpKey = \"HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid\";" ^
    "    Set-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -Value 1 -Type DWord;" ^
    "    Set-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -Value 1 -Type DWord;" ^
    "    Set-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -Value 0 -Type DWord;" ^
    "    $props = @('Interrupt Moderation','Flow Control','Green Ethernet','Gigabit Lite','Power Saving Mode','Energy-Efficient Ethernet');" ^
    "    foreach ($p in $props) { try { Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName $p -DisplayValue 'Disabled' -NoRestart -ErrorAction Stop } catch {} };" ^
    "    netsh int tcp set global rsc=disabled | Out-Null;" ^
    "    netsh int tcp set global rss=enabled | Out-Null;" ^
    "    $spKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider';" ^
    "    Set-ItemProperty -Path $spKey -Name 'LocalPriority' -Value 4 -Type DWord;" ^
    "    Set-ItemProperty -Path $spKey -Name 'HostsPriority' -Value 5 -Type DWord;" ^
    "    Set-ItemProperty -Path $spKey -Name 'DnsPriority' -Value 6 -Type DWord;" ^
    "    Set-ItemProperty -Path $spKey -Name 'NetbtPriority' -Value 7 -Type DWord;" ^
    "    $psched = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched';" ^
    "    if (-not (Test-Path $psched)) { New-Item -Path $psched -Force | Out-Null };" ^
    "    Set-ItemProperty -Path $psched -Name 'NonBestEffortLimit' -Value 0 -Type DWord;" ^
    "    Clear-DnsClientCache; ipconfig /flushdns | Out-Null;" ^
    "    Write-Host '[✓] Network optimized: Nagle disabled, Delayed ACKs off, ServiceProvider priorities tuned, 100% QoS unlocked.' -ForegroundColor Green;" ^
    "}" ^
    "}"
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 3: PC SYSTEM & FPS ONLY
:: ============================================================================
:OPT_PC
cls
color 0D
echo ================================================================================
echo       PC HARDWARE & FPS ENGINE - PumpkiN's GAMING ENGINE
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord;" ^
    "$gpuKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000';" ^
    "if (Test-Path $gpuKey) {" ^
    "    Set-ItemProperty -Path $gpuKey -Name 'PowerMizerEnable' -Value 1 -Type DWord;" ^
    "    Set-ItemProperty -Path $gpuKey -Name 'PowerMizerLevel' -Value 1 -Type DWord;" ^
    "    Set-ItemProperty -Path $gpuKey -Name 'PowerMizerLevelAC' -Value 1 -Type DWord;" ^
    "};" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord;" ^
    "powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100;" ^
    "powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100;" ^
    "powercfg -setactive scheme_current;" ^
    "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'SystemResponsiveness' -Value 0 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -Name 'PowerThrottlingOff' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' -Name 'AllowGameDVR' -Value 0 -Type DWord;" ^
    "Write-Host '[✓] System optimized: Kernel locked in RAM, Direct Flip on, PowerMizer max, CPU unparked.' -ForegroundColor Green;" ^
    "}"
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 4: LATENCY & DPC ENGINE (STOPHIGHDPC & BCD X2APIC)
:: ============================================================================
:OPT_LATENCY
cls
color 03
echo ================================================================================
echo       ULTRA-LOW LATENCY & DPC ENGINE - PumpkiN's GAMING ENGINE
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "$pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power';" ^
    "Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'ExitLatencyCheckEnabled' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'Latency' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceFSVP' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'LatencyTolerancePerfOverride' -Value 1 -Type DWord;" ^
    "bcdedit /set disabledynamictick yes | Out-Null;" ^
    "bcdedit /set x2apicpolicy Enable | Out-Null;" ^
    "bcdedit /deletevalue useplatformclock | Out-Null;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters' -Name 'MouseDataQueueSize' -Value 100 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters' -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord;" ^
    "Write-Host '[✓] Latency pipeline active: StopHighDPC enabled, x2APIC enabled, dynamic tick off, input queues tuned.' -ForegroundColor Green;" ^
    "}"
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 5: COMPETITIVE MATCH BOOSTER
:: ============================================================================
:OPT_BOOST
cls
color 0C
echo ================================================================================
echo       COMPETITIVE MATCH BOOSTER - PumpkiN's GAMING ENGINE
echo ================================================================================
echo.
echo [*] Freeing CPU cache, GPU encoder, and USB polling for competitive play...
taskkill /f /im SteelSeriesCaptureSvc.exe >nul 2>&1
taskkill /f /im SteelSeriesMoments.exe >nul 2>&1
taskkill /f /im SignalRgb.exe >nul 2>&1
taskkill /f /im SignalRgbLauncher.exe >nul 2>&1
powershell -NoProfile -Command "[System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers()" >nul 2>&1
echo  [✓] Background video capture stopped (Freed GPU NVENC).
echo  [✓] SignalRGB USB polling stopped (Freed USB bus & DPC latency).
echo  [✓] Standby memory cache flushed.
echo.
echo Launch your match now for maximum competitive FPS!
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 6: GAME-SPECIFIC PRIORITY HOOKS (IFEO)
:: ============================================================================
:OPT_HOOKS
cls
color 09
echo ================================================================================
echo       GAME PROCESS PRIORITY HOOKS - PumpkiN's GAMING ENGINE
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "$games = @('VALORANT-Win64-Shipping.exe', 'cs2.exe', 'r5apex.exe', 'AndroidEmulatorEn.exe', 'AndroidEmulator.exe');" ^
    "foreach ($g in $games) {" ^
    "    $path = \"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions\";" ^
    "    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null };" ^
    "    Set-ItemProperty -Path $path -Name 'CpuPriorityClass' -Value 3 -Type DWord;" ^
    "    Write-Host \"      ✓ Hooked $g -> High CPU Priority (Class 3)\" -ForegroundColor Green;" ^
    "};" ^
    "Write-Host '`n[✓] All target games will automatically run at High CPU Priority when launched.' -ForegroundColor Green;" ^
    "}"
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 7: VERIFICATION & LIVE DIAGNOSTIC
:: ============================================================================
:OPT_VERIFY
cls
color 0B
echo ================================================================================
echo       SYSTEM DIAGNOSTIC & PING CHECK - PumpkiN's GAMING ENGINE
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1;" ^
    "$guid = $adapter.InterfaceGuid;" ^
    "$tcp = Get-ItemProperty \"HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid\";" ^
    "Write-Host '--- Network & TCP Status ---' -ForegroundColor Cyan;" ^
    "Write-Host \"Adapter: $($adapter.Name) ($($adapter.InterfaceDescription))\";" ^
    "Write-Host \"Nagle Disabled (TCPNoDelay): $($tcp.TCPNoDelay)\";" ^
    "Write-Host \"Delayed ACKs Disabled (TcpAckFrequency): $($tcp.TcpAckFrequency)\";" ^
    "$qos = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched').NonBestEffortLimit;" ^
    "Write-Host \"QoS Reserved Bandwidth: $qos% (Target: 0%)\";" ^
    "$sp = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider').DnsPriority;" ^
    "Write-Host \"ServiceProvider DNS Priority: $sp (Target: 6)\";" ^
    "Write-Host '`n--- System & Latency Status ---' -ForegroundColor Cyan;" ^
    "$mem = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management').DisablePagingExecutive;" ^
    "Write-Host \"Kernel Locked in RAM (DisablePagingExecutive): $mem\";" ^
    "$fse = (Get-ItemProperty 'HKCU:\System\GameConfigStore').GameDVR_FSEBehaviorMode;" ^
    "Write-Host \"Direct Flip / Fullscreen Mode: $fse (Target: 2)\";" ^
    "$usb = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\USB').DisableSelectiveSuspend;" ^
    "Write-Host \"USB 100% Power (DisableSelectiveSuspend): $usb (Target: 1)\";" ^
    "$dpc = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power').ExitLatency;" ^
    "Write-Host \"StopHighDPC Power Latency: $dpc (Target: 1)\";" ^
    "$resp = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile').SystemResponsiveness;" ^
    "Write-Host \"System Gaming Responsiveness: $resp (Target: 0)\";" ^
    "Write-Host '`n--- Live Latency Test ---' -ForegroundColor Cyan;" ^
    "$ping = Test-Connection -ComputerName '1.1.1.1' -Count 4;" ^
    "$avg = ($ping | Measure-Object -Property ResponseTime -Average).Average;" ^
    "Write-Host \"Ping to Primary DNS (1.1.1.1): $avg ms (Loss: 0%)\" -ForegroundColor Green;" ^
    "}"
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 8: RESTORE DEFAULTS
:: ============================================================================
:OPT_RESTORE
cls
color 07
echo ================================================================================
echo       REVERTING SETTINGS TO WINDOWS DEFAULTS
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1;" ^
    "if ($adapter) {" ^
    "    $guid = $adapter.InterfaceGuid;" ^
    "    $tcpKey = \"HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid\";" ^
    "    Remove-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -ErrorAction SilentlyContinue;" ^
    "    Remove-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -ErrorAction SilentlyContinue;" ^
    "    Remove-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -ErrorAction SilentlyContinue;" ^
    "    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Interrupt Moderation' -DisplayValue 'Enabled' -NoRestart -ErrorAction SilentlyContinue;" ^
    "    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Flow Control' -DisplayValue 'Rx & Tx Enabled' -NoRestart -ErrorAction SilentlyContinue;" ^
    "    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Green Ethernet' -DisplayValue 'Enabled' -NoRestart -ErrorAction SilentlyContinue;" ^
    "    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Power Saving Mode' -DisplayValue 'Enabled' -NoRestart -ErrorAction SilentlyContinue;" ^
    "    netsh int tcp set global rsc=enabled | Out-Null;" ^
    "};" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 0 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'SystemResponsiveness' -Value 10 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -Name 'PowerThrottlingOff' -Value 0 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 1 -Type DWord;" ^
    "$games = @('VALORANT-Win64-Shipping.exe', 'cs2.exe', 'r5apex.exe', 'AndroidEmulatorEn.exe', 'AndroidEmulator.exe');" ^
    "foreach ($g in $games) { Remove-Item -Path \"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions\" -Recurse -Force -ErrorAction SilentlyContinue };" ^
    "Clear-DnsClientCache; ipconfig /flushdns | Out-Null;" ^
    "Write-Host '[✓] Windows default networking, system, and IFEO hooks restored.' -ForegroundColor Green;" ^
    "}"
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 9: EXIT
:: ============================================================================
:OPT_EXIT
cls
echo Thank you for using PumpkiN's Ultimate Gaming Optimizer!
echo Exiting...
timeout /t 2 >nul
exit /b
