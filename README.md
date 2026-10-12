# 🎃 PumpkiN's Ultimate Windows & Gaming Optimizer v4.0

> **The all-in-one low-latency, high-FPS Windows performance engine for competitive gaming.**  
> Zero external executable downloads • 100% Native PowerShell & Batch • Safe, modular, and fully reversible.  
> **Created by PumpkiN | Max FPS - Ultra Low Latency**

---

## ⚡ Quick Start: One-Line Run (PowerShell)

Open **PowerShell** (or Windows Terminal) as **Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex
```

*(If not already running as Administrator, the script will automatically prompt for elevation.)*

---

## 💻 Alternative: Offline Double-Click (.BAT)

1. Download [`PumpkiN_Ultimate_Gaming_Optimizer.bat`](PumpkiN_Ultimate_Gaming_Optimizer.bat) from this repository.
2. Double-click the file (it will self-elevate to Administrator automatically).
3. Use the interactive CMD menu to select your desired optimization module.

---

## 🚀 Key Features in v4.0 Ultimate Edition

### 🔴 1. Dedicated AMD Radeon GPU Optimization Suite
* **ULPS (Ultra Low Power State) Disabled:** Disables `EnableUlps` and `EnableUlps_NA` across all active display driver registry keys. Eliminates aggressive core power gating that causes frametime drops, 1% low stuttering, and multi-monitor sleep freezes.
* **Locked Shader Cache:** Forces AMD driver shader caching (`ShaderCache = 1`) to eliminate compilation micro-stutters during intense game moments.
* **Anti-Lag & Direct DMA Engine:** Sets `AntiLag = 1` and `DisableDMACopy = 1` for direct driver command stream submission.
* **Deep Sleep Throttle Mitigation:** Disables `PP_ThermalAutoThrottlingEnable` and `PP_MCLKStutterMode` to prevent erratic clock fluctuations.
* **Shader Cache Cleaning:** Flushes stale AMD DxCache, GLCache, and D3DSCache directories.

### 🟢 2. NVIDIA GeForce Dedicated Suite
* **PowerMizer P0 Lock:** Locks GPU clocks in the highest performance state (`PowerMizerLevel = 1`, `PowerMizerLevelAC = 1`) to eliminate clock drops between rounds and scene transitions.
* **NVIDIA DXCache Cleaning:** Flushes fragmented DirectX shader caches to restore smooth frametimes.

### 🧠 3. Smart Hardware Auto-Detection
* **AMD Ryzen & X3D Tuning:** Detects Ryzen processors (including 5800X3D, 7800X3D, 9800X3D) to unpark 100% of cores and eliminate dynamic tick timer jitter.
* **Intel Hybrid Architecture (12th–15th Gen):** Prioritizes Performance Cores (P-Cores) over Efficient Cores (E-Cores) for game threads, preventing stutter caused by Windows Thread Director misallocation.

### 📶 4. Wi-Fi Ping Spike Mitigator (0ms Spikes)
* Windows scans for surrounding wireless networks every 60 seconds in the background, causing catastrophic 100–300ms ping spikes during online gaming.
* Built-in toggle allows players to **freeze background scanning** while gaming for flat, wired-like ping, and re-enable it whenever they need to search for new networks.

### 🖱️ 5. Ultra-Low Latency & 8000Hz Input Engine
* **8000Hz Mouse Buffer:** Increases `MouseDataQueueSize` to 200 (default 100) and `KeyboardDataQueueSize` to 100 to prevent packet drops and DPC spikes with 1000Hz, 4000Hz, and 8000Hz high-polling gaming mice.
* **MarkC 1:1 Raw Mouse Curve:** Replaces Windows mouse acceleration curves with 100% 1:1 linear registry curves (`SmoothMouseXCurve` / `SmoothMouseYCurve`) to eliminate hidden cursor smoothing.
* **USB Selective Suspend Disabled:** Locks USB root hubs at 100% bus power to prevent mouse wake lag during flicks.

### 🌐 6. Network & Anti-Lag Suite (0ms Bufferbloat)
* **Nagle's Algorithm Disabled (`TCPNoDelay = 1`):** Sends game tick packets immediately without waiting for TCP packet coalescing.
* **Delayed ACKs Disabled (`TcpAckFrequency = 1`):** Removes up to 200ms ACK response delays.
* **100% Bandwidth Unlocked:** Removes the hidden 20% QoS bandwidth cap (`NonBestEffortLimit = 0`).
* **ServiceProvider DNS Priorities:** Prioritizes local DNS and hosts resolution ahead of NetBT.
* **NIC Hardware Power Saving Off:** Disables Interrupt Moderation, Flow Control pause frames, Green Ethernet, and Gigabit Lite.

### ⚡ 7. Kernel RAM Locking & Direct Flip Display Latency
* **Kernel Locked in Physical RAM (`DisablePagingExecutive = 1`):** Prevents system drivers and DirectX runtime code from being paged to disk/pagefile, eliminating 1% low frame hitching.
* **Direct Flip / Fullscreen Exclusive Overrides:** Forces games to scan directly to your high-refresh display without DWM composition buffering, saving 1–2 frames of input latency.
* **Windows Game Mode & 100% Responsiveness:** Sets `SystemResponsiveness = 0` and allocates high CPU thread priority to active game titles.

### 🎯 8. Competitive Match Booster & 12 Esports Hooks (IFEO)
* **Pre-Match Flush:** Terminates background recording/streaming hogs (SteelSeries Moments, Game Bar) and high-polling RGB software (SignalRGB) to free CPU and NVENC/VCE encoders, followed by a RAM garbage collection.
* **Esports Process Priority Hooks:** Automatically sets High CPU Priority and High I/O Priority for:
  - *Valorant* (`VALORANT-Win64-Shipping.exe`)
  - *Counter-Strike 2* (`cs2.exe`)
  - *Apex Legends* (`r5apex.exe`)
  - *Fortnite* (`FortniteClient-Win64-Shipping.exe`)
  - *Call of Duty: Warzone* (`cod.exe`)
  - *Tom Clancy's Rainbow Six Siege* (`RainbowSix.exe` & `RainbowSix_Vulkan.exe`)
  - *Overwatch 2* (`Overwatch.exe`)
  - *PUBG: Battlegrounds* (`PUBG-Win64-Shipping.exe`)
  - *Deadlock* (`Deadlock.exe`)
  - *Gameloop Android Emulator* (`AndroidEmulatorEn.exe` & `AndroidEmulator.exe`)

### 🛡️ 9. Safety, Backup & Reversibility
* **System Restore Point Creator:** Create a `PumpkiN_Gaming_RestorePoint` in Windows System Restore with one click before applying any tweaks.
* **Zero Third-Party Downloads:** Safe and transparent. No shady `.exe` files injected into `System32`.
* **One-Click Revert:** Option `[13]` in the menu cleanly restores default Windows settings at any time.

---

## 📋 Menu Overview

```
================================================================================
           ULTIMATE GAMING & NETWORK OPTIMIZER v4.0
          Created by PumpkiN | Max FPS - Ultra Low Latency
================================================================================

  [1]  FULL ALL-IN-ONE OPTIMIZATION (Auto-Detects Hardware & Applies All) [BEST]
  [2]  Auto-Detect & Optimize Active GPU (NVIDIA / AMD Radeon)
  [3]  AMD Radeon GPU Dedicated Suite (Disable ULPS, Shader Cache, Anti-Lag)
  [4]  NVIDIA GeForce Dedicated Suite (PowerMizer P0, Max Performance, Cache)
  [5]  Network & Anti-Lag Suite (Nagle Off, 100% QoS, ServiceProvider DNS)
  [6]  Wi-Fi Ping Spike Mitigator (Toggle Background Scan for 0ms Spikes)
  [7]  CPU & System Engine (Kernel RAM Locking, Direct Flip, Core Unparking)
  [8]  Ultra-Low Latency, DPC & 8000Hz Input (StopHighDPC, Raw Mouse Curve)
  [9]  Competitive Match Booster (Flush Standby RAM, Kill Capture & RGB Hogs)
  [10] Game-Specific High Priority Hooks (Valorant, CS2, Apex, Fortnite, COD)
  [11] System Health, Live Diagnostics & Hardware Spec Sheet
  [12] Create Windows System Restore Point (Safety Backup)
  [13] Revert All Settings to Windows Defaults
  [0]  Exit
================================================================================
```

---

## 👤 Author & Credits

* **Created by:** [PumpkiN (Sadman Hadi)](https://github.com/SadmanHadi)
* **Repository:** [https://github.com/SadmanHadi/Win_Optimizer](https://github.com/SadmanHadi/Win_Optimizer)
* **License:** [MIT License](LICENSE)
