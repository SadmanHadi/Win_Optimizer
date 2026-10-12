# 🔬 PumpkiN's PC Optimizer: Deep-Dive Technical Analysis

> **A comprehensive engineering analysis of modern Windows operating system latency, kernel scheduling, GPU power states, and competitive esports networking.**  
> **Author:** [PumpkiN (Sadman Hadi)](https://github.com/SadmanHadi)  
> **Repository:** [https://github.com/SadmanHadi/Win_Optimizer](https://github.com/SadmanHadi/Win_Optimizer)

---

## 📑 Table of Contents
1. [Executive Summary & Optimization Philosophy](#1-executive-summary--optimization-philosophy)
2. [Target System Hardware Profile](#2-target-system-hardware-profile)
3. [Memory & Kernel Subsystem Analysis](#3-memory--kernel-subsystem-analysis)
4. [GPU Architecture & Display Latency Engine](#4-gpu-architecture--display-latency-engine)
   - [4.1 AMD Radeon ULPS & Stutter Mitigation](#41-amd-radeon-ulps--stutter-mitigation)
   - [4.2 NVIDIA GeForce PowerMizer & Clock Stability](#42-nvidia-geforce-powermizer--clock-stability)
   - [4.3 Desktop Window Manager (DWM) & Direct Flip Bypass](#43-desktop-window-manager-dwm--direct-flip-bypass)
5. [CPU Scheduling & Interrupt Latency Subsystem](#5-cpu-scheduling--interrupt-latency-subsystem)
   - [5.1 AMD Ryzen & 3D V-Cache Core Unparking](#51-amd-ryzen--3d-v-cache-core-unparking)
   - [5.2 Intel Hybrid Architecture (P-Core Priority)](#52-intel-hybrid-architecture-p-core-priority)
   - [5.3 StopHighDPC & BCD Dynamic Tick Elimination](#53-stophighdpc--bcd-dynamic-tick-elimination)
6. [Input Latency & High-Polling USB Subsystem (Up to 8000Hz)](#6-input-latency--high-polling-usb-subsystem-up-to-8000hz)
7. [Networking & Netcode Subsystem (0ms Bufferbloat)](#7-networking--netcode-subsystem-0ms-bufferbloat)
   - [7.1 Nagle's Algorithm & Delayed ACKs](#71-nagles-algorithm--delayed-acks)
   - [7.2 Wi-Fi 60-Second Background Roaming Ping Spikes](#72-wi-fi-60-second-background-roaming-ping-spikes)
   - [7.3 QoS 20% Bandwidth Uncap & DNS ServiceProvider Priorities](#73-qos-20-bandwidth-uncap--dns-serviceprovider-priorities)
8. [Competitive Match Memory & Thread Hygiene](#8-competitive-match-memory--thread-hygiene)
9. [Esports Game Image File Execution Options (IFEO)](#9-esports-game-image-file-execution-options-ifeo)
10. [Safety, Backups & Complete Reversibility](#10-safety-backups--complete-reversibility)

---

## 1. Executive Summary & Optimization Philosophy

Out-of-the-box Windows 10 and Windows 11 installations are configured by Microsoft for **power conservation on battery laptops, enterprise office workloads, and server compatibility**. These defaults actively penalize competitive gaming workloads:

* **Energy-saving sleep states (ULPS, C-states, core parking)** throttle processor clocks during subtle scene pauses, producing sharp frametime spikes when intense action resumes.
* **TCP packet coalescing (Nagle's Algorithm)** delays small gaming netcode packets up to 200ms to conserve network overhead designed for 1990s dial-up connections.
* **DWM compositing buffers** introduce 1 to 2 frames of input lag to ensure window transparency and transitions look fluid.
* **Wi-Fi AutoConfig background scans** freeze active game sockets every 60 seconds to search for new access points, causing massive rubberbanding.

**PumpkiN's Ultimate Gaming Optimizer** eliminates these artificial bottlenecks using **100% native Windows APIs and registry settings**. It requires zero third-party `.exe` binaries, avoids disabling critical security features like Windows Defender, and is completely reversible.

---

## 2. Target System Hardware Profile

The benchmarks and baseline tests were analyzed on the following test rig:

| Component | Specification | Optimization Focus |
| :--- | :--- | :--- |
| **CPU** | AMD Ryzen 7 5800X3D (8C / 16T, 96MB 3D V-Cache) | Unpark all cores, lock boost clock, eliminate BCD dynamic tick jitter |
| **GPU** | NVIDIA GeForce RTX 3080 10GB (Driver 32.0.16.1742) | Lock PowerMizer to P0 state, direct scanout flip, flush DXCache |
| **GPU Support** | AMD Radeon RX 5000 / 6000 / 7000 / 9000 Series | Disable ULPS, force shader cache, Anti-Lag, stop deep sleep throttling |
| **RAM** | 32 GB Corsair DDR4-3200 (Dual Channel, 4x8GB) | Lock kernel routines in physical RAM (`DisablePagingExecutive = 1`) |
| **Storage** | Samsung 980 NVMe SSD (OS) + Corsair MP510 NVMe | Disable pagefile swapping for core OS driver routines |
| **Network** | Realtek GbE Controller (Wired Ethernet) + Wi-Fi | Disable NIC interrupt moderation, green ethernet, Nagle off, QoS uncap |
| **Display** | 1080p @ 165Hz (6.06 ms frame window) | Direct Flip scanout (saves ~6–12ms input delay) |

---

## 3. Memory & Kernel Subsystem Analysis

### The Problem: Driver Paging & Pagefile Micro-Stutters
By default, Windows sets `DisablePagingExecutive = 0`. When physical RAM is under moderate pressure or during background memory balancing, Windows pages out inactive kernel code, graphics driver user-mode runtimes (`nvlddmkm.sys`, `amdkmdag.sys`, `dxgkrnl.sys`), and file system buffers into the pagefile (`pagefile.sys`) on the SSD/HDD.

When a sudden explosion, player peek, or new texture load occurs in-game, the processor encounters a **Page Fault**. It must wait for the storage drive to fetch the driver code back into RAM, resulting in a sudden **10ms–50ms frametime spike** (often felt as a micro-freeze).

### The Solution: `DisablePagingExecutive = 1`
```registry
[HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management]
"DisablePagingExecutive"=dword:00000001
"LargeSystemCache"=dword:00000000
```
* Locks all kernel routines and loaded hardware drivers permanently in physical high-speed DDR RAM.
* `LargeSystemCache = 0` allocates memory preferentially to running application working sets rather than OS file caching.
* **Result:** Page faults for critical driver routines drop to near zero, significantly stabilizing **0.1% and 1% low FPS**.

---

## 4. GPU Architecture & Display Latency Engine

### 4.1 AMD Radeon ULPS & Stutter Mitigation

#### What is ULPS?
**ULPS (Ultra Low Power State)** is an aggressive power-saving mode in AMD Radeon drivers. While originally designed for CrossFire multi-GPU configurations, AMD kept ULPS enabled across single modern Radeon RX cards (RDNA 1, RDNA 2, RDNA 3).

When ULPS is active:
1. The driver shuts down idle compute units and drops GPU memory clocks (MCLK) when GPU utilization drops briefly (e.g. looking at a wall, waiting in a buy menu, or between rounds).
2. When the player engages in combat or enters an open area, the GPU must wake up from ULPS sleep. This wake-up transition takes **several hundred milliseconds**, manifesting as an immediate, severe frame drop.
3. On multi-monitor setups, ULPS is the primary cause of black screen flashes and sleep wake crashes.

#### The Fix:
```powershell
Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord
Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord
Set-ItemProperty -Path $targetPath -Name 'ShaderCache' -Value 1 -Type DWord
Set-ItemProperty -Path $targetPath -Name 'AntiLag' -Value 1 -Type DWord
Set-ItemProperty -Path $targetPath -Name 'PP_ThermalAutoThrottlingEnable' -Value 0 -Type DWord
Set-ItemProperty -Path $targetPath -Name 'PP_MCLKStutterMode' -Value 0 -Type DWord
```
* **`EnableUlps = 0`:** Completely terminates core sleep states. Clocks remain instant and responsive.
* **`ShaderCache = 1`:** Forces driver to maintain precompiled shaders on disk rather than recompiling per match.
* **`PP_MCLKStutterMode = 0`:** Prevents memory clock frequency stuttering.
* **`AntiLag = 1`:** Limits CPU frame buffering ahead of the GPU to reduce input delay.

### 4.2 NVIDIA GeForce PowerMizer & Clock Stability

#### The Problem: Adaptive Clock Fluctuation
NVIDIA mobile and desktop drivers employ **PowerMizer** to dynamically shift power states between P8 (idle), P2 (video), and P0 (3D gaming). When a CPU-bound game (such as *Counter-Strike 2*, *Valorant*, or *Rainbow Six Siege*) runs at high framerates with low GPU utilization (40–60%), PowerMizer often misinterprets this as light load and drops core clocks by 200–400 MHz.

#### The Fix:
```registry
[HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000]
"PowerMizerEnable"=dword:00000001
"PowerMizerLevel"=dword:00000001
"PowerMizerLevelAC"=dword:00000001
```
* `Level 1` forces the graphics card to maintain maximum P0 performance clocks under AC mains power without erratic downclocking.

### 4.3 Desktop Window Manager (DWM) & Direct Flip Bypass

In standard Windowed and Borderless Windowed modes, Windows routes game frames through the Desktop Window Manager (DWM) composition buffer (`dwm.exe`). DWM holds each frame for at least one refresh cycle to composite window shadows, notifications, and taskbars, introducing **16.6ms of latency at 60Hz or 6.06ms at 165Hz**.

#### The Fix: Direct Flip Fullscreen Overrides
```registry
[HKCU\System\GameConfigStore]
"GameDVR_Enabled"=dword:00000000
"GameDVR_FSEBehaviorMode"=dword:00000002
"GameDVR_HonorUserFSEBehaviorMode"=dword:00000001
"GameDVR_DXGIHonorFSEWindowsCompatible"=dword:00000001
"GameDVR_EFSEFeatureFlags"=dword:00000000
```
* Bypasses the DWM composition swapchain via **Hardware Direct Flip (Independent Flip / True FSE)**.
* The game presents its backbuffer directly to the display scanout hardware, matching true exclusive fullscreen latency while retaining instant Alt-Tab capabilities.

---

## 5. CPU Scheduling & Interrupt Latency Subsystem

### 5.1 AMD Ryzen & 3D V-Cache Core Unparking
Windows default balanced power schemes park inactive CPU cores to save milliwatts of power. For processors with massive L3 caches like the **Ryzen 7 5800X3D / 7800X3D**, unparking ensures that all 8 cores and 16 threads have immediate access to the 96MB 3D V-Cache without wake-up penalty:
```cmd
powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100
powercfg -setactive scheme_current
```

### 5.2 Intel Hybrid Architecture (12th–15th Gen P-Core Priority)
On Intel Alder Lake, Raptor Lake, and Arrow Lake CPUs, Windows Thread Director occasionally misallocates competitive game worker threads onto slow Efficient Cores (E-Cores). We configure:
```cmd
powercfg -setacvalueindex scheme_current sub_processor HETEROPOLICY 0
powercfg -setacvalueindex scheme_current sub_processor SCHEDPOLICY 2
```
* Forces Windows scheduler to prioritize high-IPC Performance Cores (P-Cores) for active 3D game processes.

### 5.3 StopHighDPC & BCD Dynamic Tick Elimination
* **Dynamic Tick Jitter:** `bcdedit /set disabledynamictick yes` prevents Windows from disabling the timer tick when the system is briefly idle. This eliminates micro-stutters caused by timer frequency oscillation.
* **Hardware x2APIC:** `bcdedit /set x2apicpolicy Enable` activates the advanced x2APIC interrupt controller, reducing CPU interrupt routing overhead.
* **StopHighDPC:** Setting `ExitLatency = 1` and `LatencyTolerance = 1` in `HKLM\SYSTEM\CurrentControlSet\Control\Power` instructs Windows kernel power routines to refuse high DPC sleep states during active execution.

---

## 6. Input Latency & High-Polling USB Subsystem (Up to 8000Hz)

### Mouse Queue Buffer Overflow Bug
Windows defaults `MouseDataQueueSize` to `100` in `mouclass.sys`.
* On standard 125Hz or 500Hz mice, a 100-packet buffer is sufficient.
* On modern **1000Hz, 2000Hz, 4000Hz, and 8000Hz gaming mice** (Razer Viper 8K, DeathAdder V3 Pro, Logitech G Pro X Superlight 2, Pulsar), rapid mouse flicks send thousands of reports per second.
* If a CPU thread briefly spikes or GPU render latency delays packet consumption, the 100-packet buffer overflows, causing **dropped input packets, sudden cursor stutters, and DPC latency spikes**.

#### The Fix:
```registry
[HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters]
"MouseDataQueueSize"=dword:000000C8  ; (200 packets)

[HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters]
"KeyboardDataQueueSize"=dword:00000064 ; (100 packets)

[HKLM\SYSTEM\CurrentControlSet\Services\USB]
"DisableSelectiveSuspend"=dword:00000001
```
* **`MouseDataQueueSize = 200`:** Accommodates high-polling bursts without dropping packets or consuming excessive non-paged kernel pool memory.
* **`DisableSelectiveSuspend = 1`:** Stops Windows from power-cycling USB root hubs, eliminating first-flick wake delays.
* **MarkC 1:1 Raw Mouse Curve:** Replaces Windows non-linear acceleration curves (`SmoothMouseXCurve` / `SmoothMouseYCurve`) with pure linear 1:1 hardware sensor translation.

---

## 7. Networking & Netcode Subsystem (0ms Bufferbloat)

### 7.1 Nagle's Algorithm & Delayed ACKs

#### What is Nagle's Algorithm?
Invented by John Nagle in 1984, Nagle's algorithm (`TCPNoDelay = 0`) combines multiple small outgoing packets into a single larger packet before transmission.

In competitive multiplayer games (Valorant, CS2, Fortnite, Apex):
* Game netcode continuously transmits tiny 30–80 byte tick packets (player coordinates, inputs, bullet vectors).
* Nagle's algorithm holds these packets in memory until either a full MTU packet is formed or an ACK is received from the server.
* This introduces an artificial delay of **up to 40ms–200ms per packet**, resulting in hit registration delays and peekers advantage.

#### The Fix:
```registry
[HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{GUID}]
"TCPNoDelay"=dword:00000001
"TcpAckFrequency"=dword:00000001
"TcpDelAckTicks"=dword:00000000
```
* **`TCPNoDelay = 1`:** Sends every game packet the millisecond it is generated.
* **`TcpAckFrequency = 1`:** Sends an ACK response for every single packet received instead of waiting to coalesce acknowledgments.
* **`TcpDelAckTicks = 0`:** Completely terminates the 200ms delayed acknowledgment timer.

### 7.2 Wi-Fi 60-Second Background Roaming Ping Spikes
On wireless adapters, the Windows WLAN AutoConfig service (`WlanSvc`) periodically triggers an active 802.11 probe scan every 60 seconds to search for nearby SSIDs. During this probe window:
* The Wi-Fi chip switches channels away from your router.
* All game packet transmission freezes for **100ms–300ms**, causing rubberbanding and ping spikes.

#### The Fix:
`PumpkiN_Ultimate_Gaming_Optimizer` provides a native toggle:
```cmd
netsh wlan set autoconfig enabled=no interface="<AdapterName>"
```
* Freezes background scanning during gaming sessions for a flat, wired-like ping line.
* Easily re-enabled with `enabled=yes` when looking for new Wi-Fi networks.

### 7.3 QoS 20% Bandwidth Uncap & DNS ServiceProvider Priorities
* **QoS Uncap:** Windows reserves up to 20% of network throughput for system QoS tasks. Setting `NonBestEffortLimit = 0` in `HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched` frees 100% of bandwidth for gaming.
* **DNS Priorities:** Tuning `HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider` sets local hosts (`5`) and DNS cache (`6`) ahead of legacy NetBT resolution (`7`), accelerating match server connection handshakes.

---

## 8. Competitive Match Memory & Thread Hygiene

Modern gaming setups often run background software that consumes GPU encoder sessions and pollutes CPU cache:
* **SteelSeries Moments (`SteelSeriesCaptureSvc.exe`):** Continuously encodes gameplay in the background, occupying GPU NVENC/VCE sessions and reducing gaming FPS.
* **SignalRGB (`SignalRgb.exe`):** Continuously polls USB device hardware at high frequencies, spiking DPC latency and CPU kernel time.
* **Standby Memory Fragmentation:** Windows file cache can leave gigabytes of standby memory unallocated.

The optimizer's **Competitive Match Booster** terminates these background hogs with one click and triggers a managed garbage collection cycle (`[System.GC]::Collect()`) to ensure maximum CPU cache and physical RAM availability before entering a match.

---

## 9. Esports Game Image File Execution Options (IFEO)

Windows allows setting permanent execution priorities for specific executables under `Image File Execution Options (IFEO)`. The optimizer hooks 12 major competitive titles:

1. `VALORANT-Win64-Shipping.exe` (Valorant)
2. `cs2.exe` (Counter-Strike 2)
3. `r5apex.exe` (Apex Legends)
4. `FortniteClient-Win64-Shipping.exe` (Fortnite)
5. `cod.exe` (Call of Duty: Warzone / Modern Warfare)
6. `RainbowSix.exe` & `RainbowSix_Vulkan.exe` (Rainbow Six Siege)
7. `Overwatch.exe` (Overwatch 2)
8. `PUBG-Win64-Shipping.exe` (PUBG: Battlegrounds)
9. `Deadlock.exe` (Valve Deadlock)
10. `AndroidEmulatorEn.exe` & `AndroidEmulator.exe` (Gameloop Android Emulator)

For each game:
```registry
[HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\<Executable>\PerfOptions]
"CpuPriorityClass"=dword:00000003  ; High CPU Priority
"IoPriority"=dword:00000003        ; High I/O Priority
```
This guarantees game worker threads and texture streaming assets receive processor scheduling preference over background Discord, browser, or antivirus tasks.

---

## 10. Safety, Backups & Complete Reversibility

* **Native System Restore Integration:** Option `[12]` invokes Windows System Restore (`Checkpoint-Computer -Description "PumpkiN_Gaming_RestorePoint"`) to snapshot system state before applying any optimizations.
* **One-Click Reversion:** Option `[13]` cleanly deletes or restores every modified TCP parameter, memory flag, power throttling policy, and game hook back to official Windows defaults.
* **Antivirus Transparency:** Zero obfuscated scripts, zero compiled DLL injections, and zero disabled Defender shields.
