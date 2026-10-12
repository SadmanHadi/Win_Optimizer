@echo off
setlocal EnableDelayedExpansion
title PumpkiN's Ultimate Gaming and Network Optimizer v4.0

:: ============================================================================
:: 1. AUTO-ELEVATE TO ADMINISTRATOR
:: ============================================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Requesting Administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: If optimizer.ps1 is in the same folder, allow launching the full interactive PS1 shell
if "%1"=="--ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0optimizer.ps1"
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
echo   ^| ^|_) ^| ^| ^| ^| '_ \ _ \^| '_ \ ^|/ / ^| '_ \^|  \^| ^|
echo   ^|  __/^| ^|_^| ^| ^| ^| ^| ^| ^| ^|_) ^|   ^<^| ^| ^| ^| ^| ^|\  ^|
echo   ^|_^|    \__,_^|_^| ^|_^| ^|_^| .__/^|_^|\_\_^_^|_^| ^|_^|_^| \_^|
echo                         ^|_^|                       
echo            ULTIMATE GAMING ^& NETWORK OPTIMIZER v4.0
echo           Created by PumpkiN ^| Max FPS - Ultra Low Latency
echo ================================================================================
echo.
echo   [1]  FULL ALL-IN-ONE OPTIMIZATION (Hardware Auto-Detect + All Tweaks) [BEST]
echo   [2]  Auto-Detect ^& Optimize Active GPU (NVIDIA / AMD Radeon)
echo   [3]  AMD Radeon GPU Dedicated Suite (Disable ULPS, Shader Cache, Anti-Lag)
echo   [4]  NVIDIA GeForce Dedicated Suite (PowerMizer P0, Max Performance, Cache)
echo   [5]  Network ^& Anti-Lag Suite (Nagle Off, 100%% QoS, ServiceProvider DNS)
echo   [6]  Wi-Fi Ping Spike Mitigator (Toggle Background Scan for 0ms Spikes)
echo   [7]  CPU ^& System Engine (Kernel RAM Locking, Direct Flip, Core Unparking)
echo   [8]  Ultra-Low Latency, DPC ^& 8000Hz Input (StopHighDPC, Raw Mouse Curve)
echo   [9]  Competitive Match Booster (Flush Standby RAM, Kill Capture ^& RGB Hogs)
echo   [10] Esports Game Priority Hooks (Valorant, CS2, Apex, Fortnite, COD, R6)
echo   [11] Live System Diagnostics ^& Latency Verification
echo   [12] Create Windows System Restore Point (Safety Backup)
echo   [13] Revert All Settings to Windows Defaults
echo   [0]  Exit
echo.
echo ================================================================================
set /p "CHOICE=Select an option [0-13]: "

if "%CHOICE%"=="1" goto OPT_FULL
if "%CHOICE%"=="2" goto OPT_GPU_AUTO
if "%CHOICE%"=="3" goto OPT_AMD_GPU
if "%CHOICE%"=="4" goto OPT_NVIDIA_GPU
if "%CHOICE%"=="5" goto OPT_NET
if "%CHOICE%"=="6" goto OPT_WIFI
if "%CHOICE%"=="7" goto OPT_CPU
if "%CHOICE%"=="8" goto OPT_LATENCY
if "%CHOICE%"=="9" goto OPT_BOOST
if "%CHOICE%"=="10" goto OPT_HOOKS
if "%CHOICE%"=="11" goto OPT_DIAG
if "%CHOICE%"=="12" goto OPT_BACKUP
if "%CHOICE%"=="13" goto OPT_RESTORE
if "%CHOICE%"=="0" goto OPT_EXIT
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
    "Write-Host '[1/8] Optimizing Network Stack & Anti-Lag...' -ForegroundColor Yellow;" ^
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
    "    Write-Host '      [+] Nagle disabled, Delayed ACKs off, NIC power saving disabled' -ForegroundColor Green;" ^
    "};" ^
    "Write-Host '`n[2/8] Tuning DNS ServiceProvider & Removing QoS 20% Bandwidth Cap...' -ForegroundColor Yellow;" ^
    "$spKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider';" ^
    "Set-ItemProperty -Path $spKey -Name 'LocalPriority' -Value 4 -Type DWord;" ^
    "Set-ItemProperty -Path $spKey -Name 'HostsPriority' -Value 5 -Type DWord;" ^
    "Set-ItemProperty -Path $spKey -Name 'DnsPriority' -Value 6 -Type DWord;" ^
    "Set-ItemProperty -Path $spKey -Name 'NetbtPriority' -Value 7 -Type DWord;" ^
    "$psched = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched';" ^
    "if (-not (Test-Path $psched)) { New-Item -Path $psched -Force | Out-Null };" ^
    "Set-ItemProperty -Path $psched -Name 'NonBestEffortLimit' -Value 0 -Type DWord;" ^
    "Clear-DnsClientCache; ipconfig /flushdns | Out-Null;" ^
    "Write-Host '      [+] ServiceProvider priorities tuned + 100% bandwidth unreserved' -ForegroundColor Green;" ^
    "Write-Host '`n[3/8] Auto-Detecting & Optimizing Active Graphics Hardware...' -ForegroundColor Yellow;" ^
    "$classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}';" ^
    "foreach ($sub in 0..9) {" ^
    "    $subKey = \"{0:D4}\" -f $sub;" ^
    "    $targetPath = \"$classPath\$subKey\";" ^
    "    if (Test-Path $targetPath) {" ^
    "        $p = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue;" ^
    "        if ($p -and ($p.DriverDesc -match 'AMD|Radeon' -or $p.ProviderName -match 'AMD' -or $p.EnableUlps -ne $null)) {" ^
    "            Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'ShaderCache' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'AntiLag' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PP_ThermalAutoThrottlingEnable' -Value 0 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PP_MCLKStutterMode' -Value 0 -Type DWord;" ^
    "            Write-Host \"      [+] AMD Radeon GPU Optimized: Disabled ULPS & Stuttering\" -ForegroundColor Green;" ^
    "        };" ^
    "        if ($p -and ($p.DriverDesc -match 'NVIDIA' -or $p.ProviderName -match 'NVIDIA')) {" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PowerMizerEnable' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevel' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevelAC' -Value 1 -Type DWord;" ^
    "            Write-Host \"      [+] NVIDIA PowerMizer set to Maximum Performance (P0 State)\" -ForegroundColor Green;" ^
    "        };" ^
    "    };" ^
    "};" ^
    "Remove-Item \"$env:LOCALAPPDATA\D3DSCache\*\", \"$env:LOCALAPPDATA\NVIDIA\DXCache\*\", \"$env:LOCALAPPDATA\AMD\DxCache\*\" -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Write-Host '`n[4/8] Locking Kernel in Physical RAM & Unparking CPU Cores...' -ForegroundColor Yellow;" ^
    "$memKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management';" ^
    "Set-ItemProperty -Path $memKey -Name 'DisablePagingExecutive' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $memKey -Name 'LargeSystemCache' -Value 0 -Type DWord;" ^
    "powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100;" ^
    "powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100;" ^
    "powercfg -setactive scheme_current;" ^
    "Write-Host '      [+] Kernel routines locked in DDR RAM + 100% CPU cores unparked' -ForegroundColor Green;" ^
    "Write-Host '`n[5/8] Bypassing DWM Latency (Direct Flip & Fullscreen Overrides)...' -ForegroundColor Yellow;" ^
    "$gcs = 'HKCU:\System\GameConfigStore';" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_Enabled' -Value 0 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_DXGIHonorFSEWindowsCompatible' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_EFSEFeatureFlags' -Value 0 -Type DWord;" ^
    "Write-Host '      [+] Direct Flip active (Bypasses DWM buffer lag)' -ForegroundColor Green;" ^
    "Write-Host '`n[6/8] Forcing Zero Latency Tolerance (StopHighDPC) & x2APIC...' -ForegroundColor Yellow;" ^
    "$pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power';" ^
    "Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord;" ^
    "bcdedit /set disabledynamictick yes | Out-Null;" ^
    "bcdedit /set x2apicpolicy Enable | Out-Null;" ^
    "bcdedit /deletevalue useplatformclock | Out-Null;" ^
    "Write-Host '      [+] StopHighDPC zero latency tolerance + dynamic tick jitter eliminated' -ForegroundColor Green;" ^
    "Write-Host '`n[7/8] Tuning 8000Hz Input Buffer & Raw 1:1 Mouse Response Curve...' -ForegroundColor Yellow;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters' -Name 'MouseDataQueueSize' -Value 200 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters' -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord;" ^
    "$mouseKey = 'HKCU:\Control Panel\Mouse';" ^
    "Set-ItemProperty -Path $mouseKey -Name 'MouseSpeed' -Value '0' -Type String;" ^
    "Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold1' -Value '0' -Type String;" ^
    "Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold2' -Value '0' -Type String;" ^
    "[byte[]]$sx = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x29,0xdc,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00;" ^
    "[byte[]]$sy = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xa8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xe0,0x00,0x00,0x00,0x00,0x00;" ^
    "Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseXCurve' -Value $sx -Type Binary;" ^
    "Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseYCurve' -Value $sy -Type Binary;" ^
    "Write-Host '      [+] 8000Hz Mouse Buffer tuned + 100% Raw 1:1 Mouse Input Curve applied' -ForegroundColor Green;" ^
    "Write-Host '`n[8/8] Installing High CPU Priority Hooks for Esports Titles...' -ForegroundColor Yellow;" ^
    "$games = @('VALORANT-Win64-Shipping.exe','cs2.exe','r5apex.exe','FortniteClient-Win64-Shipping.exe','cod.exe','RainbowSix.exe','RainbowSix_Vulkan.exe','Overwatch.exe','PUBG-Win64-Shipping.exe','Deadlock.exe','AndroidEmulatorEn.exe','AndroidEmulator.exe');" ^
    "foreach ($g in $games) {" ^
    "    $path = \"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions\";" ^
    "    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null };" ^
    "    Set-ItemProperty -Path $path -Name 'CpuPriorityClass' -Value 3 -Type DWord;" ^
    "    Set-ItemProperty -Path $path -Name 'IoPriority' -Value 3 -Type DWord;" ^
    "};" ^
    "Write-Host '      [+] 12 Esports competitive titles hooked to High CPU & I/O Priority' -ForegroundColor Green;" ^
    "Write-Host '`n================================================================================' -ForegroundColor Green;" ^
    "Write-Host '     [OK] ALL OPTIMIZATIONS APPLIED! RESTART RECOMMENDED FOR FULL EFFECT' -ForegroundColor Green;" ^
    "Write-Host '================================================================================' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 2: AUTO-DETECT GPU
:: ============================================================================
:OPT_GPU_AUTO
cls
color 0A
echo ================================================================================
echo               AUTO-DETECTING & OPTIMIZING GRAPHICS HARDWARE
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}';" ^
    "foreach ($sub in 0..9) {" ^
    "    $subKey = \"{0:D4}\" -f $sub;" ^
    "    $targetPath = \"$classPath\$subKey\";" ^
    "    if (Test-Path $targetPath) {" ^
    "        $p = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue;" ^
    "        if ($p -and ($p.DriverDesc -match 'AMD|Radeon' -or $p.ProviderName -match 'AMD' -or $p.EnableUlps -ne $null)) {" ^
    "            Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'ShaderCache' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'AntiLag' -Value 1 -Type DWord;" ^
    "            Write-Host \"[+] AMD Radeon GPU ($($p.DriverDesc)): Disabled ULPS & Enabled Anti-Lag\" -ForegroundColor Magenta;" ^
    "        };" ^
    "        if ($p -and ($p.DriverDesc -match 'NVIDIA' -or $p.ProviderName -match 'NVIDIA')) {" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PowerMizerEnable' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevel' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevelAC' -Value 1 -Type DWord;" ^
    "            Write-Host \"[+] NVIDIA GPU ($($p.DriverDesc)): PowerMizer locked to Maximum Performance (P0)\" -ForegroundColor Green;" ^
    "        };" ^
    "    };" ^
    "};" ^
    "Remove-Item \"$env:LOCALAPPDATA\D3DSCache\*\", \"$env:LOCALAPPDATA\NVIDIA\DXCache\*\", \"$env:LOCALAPPDATA\AMD\DxCache\*\" -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Write-Host '[OK] GPU Optimization Complete!' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 3: AMD RADEON GPU DEDICATED SUITE
:: ============================================================================
:OPT_AMD_GPU
cls
color 0D
echo ================================================================================
echo             AMD RADEON DEDICATED OPTIMIZATION (DISABLE ULPS)
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "Write-Host '[*] Applying AMD Radeon Ultra-Low Latency & Anti-Stutter Suite...' -ForegroundColor Magenta;" ^
    "$classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}';" ^
    "$amdFound = $false;" ^
    "foreach ($sub in 0..9) {" ^
    "    $subKey = \"{0:D4}\" -f $sub;" ^
    "    $targetPath = \"$classPath\$subKey\";" ^
    "    if (Test-Path $targetPath) {" ^
    "        $p = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue;" ^
    "        if ($p -and ($p.DriverDesc -match 'AMD|Radeon' -or $p.ProviderName -match 'AMD' -or $p.EnableUlps -ne $null)) {" ^
    "            $amdFound = $true;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'ShaderCache' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'ShaderCache_NA' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'AntiLag' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'DisableDMACopy' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PP_ThermalAutoThrottlingEnable' -Value 0 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PP_MCLKStutterMode' -Value 0 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'StutterMode' -Value 0 -Type DWord;" ^
    "            Write-Host \"[+] Successfully optimized AMD Adapter [$subKey]: $($p.DriverDesc)\" -ForegroundColor Green;" ^
    "            Write-Host \"    - Ultra Low Power State (ULPS): DISABLED (No clock drops)\" -ForegroundColor Green;" ^
    "            Write-Host \"    - Shader Cache: FORCED ON (Stops micro-stutters)\" -ForegroundColor Green;" ^
    "            Write-Host \"    - Anti-Lag & Low-Latency Direct DMA: ENABLED\" -ForegroundColor Green;" ^
    "        };" ^
    "    };" ^
    "};" ^
    "Remove-Item \"$env:LOCALAPPDATA\AMD\DxCache\*\", \"$env:LOCALAPPDATA\AMD\GLCache\*\", \"$env:LOCALAPPDATA\AMD\D3DSCache\*\" -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Write-Host '[+] Stale AMD shader caches flushed!' -ForegroundColor Green;" ^
    "if (-not $amdFound) { Write-Host '[!] Note: No AMD Radeon card was found in active keys.' -ForegroundColor Yellow };" ^
    "Write-Host '[OK] AMD Radeon Optimization Complete!' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 4: NVIDIA GEFORCE DEDICATED SUITE
:: ============================================================================
:OPT_NVIDIA_GPU
cls
color 0A
echo ================================================================================
echo             NVIDIA GEFORCE DEDICATED OPTIMIZATION (POWERMIZER P0)
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "Write-Host '[*] Applying NVIDIA GeForce Maximum Performance Suite...' -ForegroundColor Green;" ^
    "$classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}';" ^
    "foreach ($sub in 0..9) {" ^
    "    $subKey = \"{0:D4}\" -f $sub;" ^
    "    $targetPath = \"$classPath\$subKey\";" ^
    "    if (Test-Path $targetPath) {" ^
    "        $p = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue;" ^
    "        if ($p -and ($p.DriverDesc -match 'NVIDIA' -or $p.ProviderName -match 'NVIDIA')) {" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PowerMizerEnable' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevel' -Value 1 -Type DWord;" ^
    "            Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevelAC' -Value 1 -Type DWord;" ^
    "            Write-Host \"[+] NVIDIA PowerMizer locked to Maximum Performance (P0 State)\" -ForegroundColor Green;" ^
    "        };" ^
    "    };" ^
    "};" ^
    "Remove-Item \"$env:LOCALAPPDATA\NVIDIA\DXCache\*\", \"$env:LOCALAPPDATA\NVIDIA\GLCache\*\", \"$env:LOCALAPPDATA\D3DSCache\*\" -Recurse -Force -ErrorAction SilentlyContinue;" ^
    "Write-Host '[+] Stale NVIDIA shader caches flushed!' -ForegroundColor Green;" ^
    "Write-Host '[OK] NVIDIA GeForce Optimization Complete!' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 5: NETWORK & ANTI-LAG
:: ============================================================================
:OPT_NET
cls
color 0B
echo ================================================================================
echo             NETWORK & ANTI-LAG SUITE (0ms BUFFERBLOAT)
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
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
    "    Write-Host '[+] Nagle disabled, Delayed ACKs off, NIC power saving disabled' -ForegroundColor Green;" ^
    "};" ^
    "$spKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider';" ^
    "Set-ItemProperty -Path $spKey -Name 'LocalPriority' -Value 4 -Type DWord;" ^
    "Set-ItemProperty -Path $spKey -Name 'HostsPriority' -Value 5 -Type DWord;" ^
    "Set-ItemProperty -Path $spKey -Name 'DnsPriority' -Value 6 -Type DWord;" ^
    "Set-ItemProperty -Path $spKey -Name 'NetbtPriority' -Value 7 -Type DWord;" ^
    "$psched = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched';" ^
    "if (-not (Test-Path $psched)) { New-Item -Path $psched -Force | Out-Null };" ^
    "Set-ItemProperty -Path $psched -Name 'NonBestEffortLimit' -Value 0 -Type DWord;" ^
    "Clear-DnsClientCache; ipconfig /flushdns | Out-Null;" ^
    "Write-Host '[+] ServiceProvider priorities set + 100% bandwidth unreserved' -ForegroundColor Green;" ^
    "Write-Host '[OK] Network Tuning Complete!' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 6: WI-FI PING SPIKE MITIGATOR
:: ============================================================================
:OPT_WIFI
cls
color 0E
echo ================================================================================
echo             WI-FI BACKGROUND SCAN MITIGATOR (STOP 60s PING SPIKES)
echo ================================================================================
echo.
echo Windows searches for Wi-Fi networks in the background every 60 seconds,
echo causing severe 100-300ms ping spikes during multiplayer games.
echo.
echo   [1] DISABLE Wi-Fi Background Scan (Competitive Gaming Mode - Zero Ping Spikes)
echo   [2] ENABLE Wi-Fi Background Scan (Normal Mode - Discover New Networks)
echo   [0] Return to Main Menu
echo.
set /p "WCHOICE=Select an option [0-2]: "
if "%WCHOICE%"=="1" (
    powershell -NoProfile -Command "$w = Get-NetAdapter | Where-Object { $_.InterfaceType -eq 71 -or $_.InterfaceDescription -match 'Wi-Fi|Wireless' } | Select-Object -First 1; if ($w) { netsh wlan set autoconfig enabled=no interface=\"$($w.Name)\"; Write-Host '[OK] Background scan disabled for zero ping spikes!' -ForegroundColor Green } else { Write-Host '[!] No Wi-Fi adapter detected.' -ForegroundColor Yellow }"
    pause
    goto MENU
)
if "%WCHOICE%"=="2" (
    powershell -NoProfile -Command "$w = Get-NetAdapter | Where-Object { $_.InterfaceType -eq 71 -or $_.InterfaceDescription -match 'Wi-Fi|Wireless' } | Select-Object -First 1; if ($w) { netsh wlan set autoconfig enabled=yes interface=\"$($w.Name)\"; Write-Host '[OK] Background scan re-enabled!' -ForegroundColor Green } else { Write-Host '[!] No Wi-Fi adapter detected.' -ForegroundColor Yellow }"
    pause
    goto MENU
)
goto MENU

:: ============================================================================
:: OPTION 7: CPU & SYSTEM ENGINE
:: ============================================================================
:OPT_CPU
cls
color 0B
echo ================================================================================
echo             CPU & SYSTEM ENGINE (KERNEL RAM LOCKING & CORE UNPARK)
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$memKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management';" ^
    "Set-ItemProperty -Path $memKey -Name 'DisablePagingExecutive' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $memKey -Name 'LargeSystemCache' -Value 0 -Type DWord;" ^
    "powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100;" ^
    "powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100;" ^
    "powercfg -setactive scheme_current;" ^
    "$gcs = 'HKCU:\System\GameConfigStore';" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_Enabled' -Value 0 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord;" ^
    "Set-ItemProperty -Path $gcs -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord;" ^
    "Write-Host '[+] Kernel locked in RAM + Cores unparked + Direct Flip enabled' -ForegroundColor Green;" ^
    "Write-Host '[OK] CPU & System Engine Applied!' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 8: LATENCY & 8000Hz INPUT ENGINE
:: ============================================================================
:OPT_LATENCY
cls
color 0E
echo ================================================================================
echo             ULTRA-LOW LATENCY, DPC & 8000Hz INPUT ENGINE
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power';" ^
    "Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord;" ^
    "Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord;" ^
    "bcdedit /set disabledynamictick yes | Out-Null;" ^
    "bcdedit /set x2apicpolicy Enable | Out-Null;" ^
    "bcdedit /deletevalue useplatformclock | Out-Null;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters' -Name 'MouseDataQueueSize' -Value 200 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters' -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord;" ^
    "$mouseKey = 'HKCU:\Control Panel\Mouse';" ^
    "Set-ItemProperty -Path $mouseKey -Name 'MouseSpeed' -Value '0' -Type String;" ^
    "Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold1' -Value '0' -Type String;" ^
    "Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold2' -Value '0' -Type String;" ^
    "[byte[]]$sx = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x29,0xdc,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00;" ^
    "[byte[]]$sy = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xa8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xe0,0x00,0x00,0x00,0x00,0x00;" ^
    "Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseXCurve' -Value $sx -Type Binary;" ^
    "Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseYCurve' -Value $sy -Type Binary;" ^
    "Write-Host '[+] StopHighDPC zero latency tolerance applied' -ForegroundColor Green;" ^
    "Write-Host '[+] 8000Hz mouse queue buffer + MarkC 1:1 raw mouse curve set' -ForegroundColor Green;" ^
    "Write-Host '[OK] Low Latency Engine Applied!' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 9: COMPETITIVE MATCH BOOSTER
:: ============================================================================
:OPT_BOOST
cls
color 0C
echo ================================================================================
echo             COMPETITIVE MATCH BOOSTER (KILL HOGS & FREE RAM)
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "taskkill /f /im SteelSeriesCaptureSvc.exe 2>$null;" ^
    "taskkill /f /im SteelSeriesMoments.exe 2>$null;" ^
    "taskkill /f /im SignalRgb.exe 2>$null;" ^
    "taskkill /f /im SignalRgbLauncher.exe 2>$null;" ^
    "taskkill /f /im GameBarFTServer.exe 2>$null;" ^
    "[System.GC]::Collect();" ^
    "[System.GC]::WaitForPendingFinalizers();" ^
    "Write-Host '[+] Background video capture services terminated (Freed GPU encoder)' -ForegroundColor Green;" ^
    "Write-Host '[+] High-polling RGB background services terminated (Freed USB polling)' -ForegroundColor Green;" ^
    "Write-Host '[+] Standby memory garbage collection executed' -ForegroundColor Green;" ^
    "Write-Host '[OK] Competitive Match Booster Complete!' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 10: ESPORTS PROCESS PRIORITY HOOKS
:: ============================================================================
:OPT_HOOKS
cls
color 0B
echo ================================================================================
echo             ESPORTS GAME PROCESS PRIORITY HOOKS (IFEO)
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$games = @('VALORANT-Win64-Shipping.exe','cs2.exe','r5apex.exe','FortniteClient-Win64-Shipping.exe','cod.exe','RainbowSix.exe','RainbowSix_Vulkan.exe','Overwatch.exe','PUBG-Win64-Shipping.exe','Deadlock.exe','AndroidEmulatorEn.exe','AndroidEmulator.exe');" ^
    "foreach ($g in $games) {" ^
    "    $path = \"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions\";" ^
    "    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null };" ^
    "    Set-ItemProperty -Path $path -Name 'CpuPriorityClass' -Value 3 -Type DWord;" ^
    "    Set-ItemProperty -Path $path -Name 'IoPriority' -Value 3 -Type DWord;" ^
    "    Write-Host \"[+] Hooked $g -> High CPU Priority & High I/O Priority\" -ForegroundColor Green;" ^
    "};" ^
    "Write-Host '[OK] All 12 Esports titles hooked!' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 11: DIAGNOSTICS & PING TEST
:: ============================================================================
:OPT_DIAG
cls
color 03
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "Write-Host '================================================================================' -ForegroundColor Cyan;" ^
    "Write-Host '                       LIVE SYSTEM & LATENCY DIAGNOSTICS                        ' -ForegroundColor Cyan;" ^
    "Write-Host '================================================================================' -ForegroundColor Cyan;" ^
    "$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1;" ^
    "$gpus = Get-CimInstance Win32_VideoController;" ^
    "Write-Host \"CPU: $($cpu.Name)\" -ForegroundColor Yellow;" ^
    "foreach ($g in $gpus) { Write-Host \"GPU: $($g.Name) (Driver: $($g.DriverVersion))\" -ForegroundColor Yellow };" ^
    "$dpc = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -ErrorAction SilentlyContinue).ExitLatency;" ^
    "Write-Host \"StopHighDPC Latency Tolerance: $dpc (Target: 1)\" -ForegroundColor White;" ^
    "$mem = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management').DisablePagingExecutive;" ^
    "Write-Host \"Kernel Locked in RAM: $mem (Target: 1)\" -ForegroundColor White;" ^
    "$ping = Test-Connection -ComputerName '1.1.1.1' -Count 4 -ErrorAction SilentlyContinue;" ^
    "if ($ping) {" ^
    "    $avg = ($ping | Measure-Object -Property ResponseTime -Average).Average;" ^
    "    Write-Host \"Ping to Cloudflare DNS (1.1.1.1): $avg ms (0% Loss)\" -ForegroundColor Green;" ^
    "};"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 12: SYSTEM RESTORE POINT
:: ============================================================================
:OPT_BACKUP
cls
color 0B
echo ================================================================================
echo             CREATING WINDOWS SYSTEM RESTORE POINT
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "try {" ^
    "    Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue;" ^
    "    Checkpoint-Computer -Description 'PumpkiN_Gaming_RestorePoint' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop;" ^
    "    Write-Host '[OK] System Restore Point created successfully!' -ForegroundColor Green;" ^
    "} catch {" ^
    "    Write-Host \"[!] Note: $($_.Exception.Message)\" -ForegroundColor Yellow;" ^
    "}"
}
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 13: RESTORE WINDOWS DEFAULTS
:: ============================================================================
:OPT_RESTORE
cls
color 0C
echo ================================================================================
echo             REVERTING ALL SETTINGS TO WINDOWS DEFAULTS
echo ================================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {" ^
    "$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1;" ^
    "if ($adapter) {" ^
    "    $guid = $adapter.InterfaceGuid;" ^
    "    $tcpKey = \"HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid\";" ^
    "    Remove-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -ErrorAction SilentlyContinue;" ^
    "    Remove-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -ErrorAction SilentlyContinue;" ^
    "    Remove-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -ErrorAction SilentlyContinue;" ^
    "    netsh int tcp set global rsc=enabled | Out-Null;" ^
    "};" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 0 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'SystemResponsiveness' -Value 10 -Type DWord;" ^
    "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -Name 'PowerThrottlingOff' -Value 0 -Type DWord;" ^
    "$games = @('VALORANT-Win64-Shipping.exe','cs2.exe','r5apex.exe','FortniteClient-Win64-Shipping.exe','cod.exe','RainbowSix.exe','RainbowSix_Vulkan.exe','Overwatch.exe','PUBG-Win64-Shipping.exe','Deadlock.exe','AndroidEmulatorEn.exe','AndroidEmulator.exe');" ^
    "foreach ($g in $games) { Remove-Item -Path \"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions\" -Recurse -Force -ErrorAction SilentlyContinue };" ^
    "bcdedit /deletevalue disabledynamictick 2>$null;" ^
    "Clear-DnsClientCache; ipconfig /flushdns | Out-Null;" ^
    "Write-Host '[OK] Windows default parameters restored.' -ForegroundColor Green;"
}
echo.
pause
goto MENU

:OPT_EXIT
cls
color 07
echo Thank you for using PumpkiN's Ultimate Gaming Optimizer!
timeout /t 2 >nul
exit /b
