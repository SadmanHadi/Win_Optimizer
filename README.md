# 🎃 PumpkiN's Ultimate Windows & Gaming Optimizer

> **The all-in-one low-latency, high-FPS Windows performance engine for competitive gaming.**  
> Zero external executable downloads • 100% Native PowerShell & Batch • Safe and fully reversible.

---

## ⚡ Quick Start: One-Line Run (PowerShell)

Open **PowerShell** (or Windows Terminal) as **Administrator** and paste:

```powershell
irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex
```

*(If not already running as Administrator, the script will automatically prompt for elevation.)*

---

## 💻 Alternative: Offline Double-Click (.BAT)

1. Download [`PumpkiN_Ultimate_Gaming_Optimizer.bat`](PumpkiN_Ultimate_Gaming_Optimizer.bat) from this repository.
2. Double-click the file (it will self-elevate to Administrator automatically).
3. Use the interactive CMD menu to select your desired optimization tier.

---

## 🎯 What This Tool Optimizes

### 1. 🌐 Zero-Latency Network & Anti-Lag Stack
* **Nagle's Algorithm Disabled (`TCPNoDelay = 1`):** Stops Windows from buffering small packets, dispatching game tick packets instantly.
* **Delayed ACKs Disabled (`TcpAckFrequency = 1`):** Removes up to 200ms ACK response delays in multiplayer netcode.
* **QoS 20% Bandwidth Uncap:** Removes the hidden 20% Windows network reservation (`NonBestEffortLimit = 0`).
* **ServiceProvider DNS Priorities:** Prioritizes local DNS and hosts cache ahead of NetBT lookups.
* **NIC Hardware Throttling Off:** Disables Interrupt Moderation, Flow Control pause frames, Green Ethernet, and Gigabit Lite power sleep states.
* **Global TCP RSC Disabled:** Bypasses Receive Segment Coalescing packet merging delays.

### 2. ⚡ Memory & DWM Display Latency
* **Kernel Locked in Physical RAM (`DisablePagingExecutive = 1`):** Prevents system drivers and DirectX runtime code from being paged to disk/pagefile, eliminating 1% low frame hitching.
* **Direct Flip / Fullscreen Exclusive Overrides:** Forces games to scan directly to your high-refresh display without DWM composition buffering, saving 1–2 frames of input latency.
* **Windows Game Mode & 100% Responsiveness:** Sets `SystemResponsiveness = 0` and allocates 100% CPU thread priority to active game titles.
* **Windows CPU Power Throttling Off:** Stops Windows 11 from shifting game or anti-cheat threads into low-power "EcoQoS / Efficiency Mode".

### 3. ⏱️ Latency & DPC Tolerance Subsystem
* **StopHighDPC Active:** Forces Windows power management to stop tolerating high DPC and ISR sleep state transitions (`ExitLatency = 1`, `LatencyTolerance = 1`).
* **Dynamic Tick Disabled:** Locks the CPU clock timer frequency via `bcdedit /set disabledynamictick yes`, preventing clock frequency scaling jitter during gameplay.
* **Hardware x2APIC Enabled:** Modernizes CPU interrupt controller handling.
* **USB Selective Suspend Disabled:** Keeps all USB root hubs at 100% power to eliminate mouse polling wake lag when flicking.

### 4. 🎮 GPU & CPU Performance Engine
* **NVIDIA PowerMizer Maximum Performance:** Locks GPU clocks in highest performance state (P0) to prevent clock drops between rounds or scene transitions.
* **CPU Core Unparking:** Unparks 100% of CPU cores (`CPMINCORES 100`) to keep all cores and cache structures awake.
* **Shader Cache Cleaning:** Flushes corrupted and stale shader files to prevent map load stutters on modern drivers.

### 5. 🎯 Competitive Match Booster & Game Hooks
* **One-Click Pre-Match Flush:** Automatically shuts down high-CPU/GPU background hogs (SteelSeries Moments continuous recording, SignalRGB USB polling) and flushes standby RAM cache before you launch a match.
* **Automatic Game Priority Hooks (IFEO):** Automatically sets High CPU Priority (`Class 3`) and High-Performance GPU rendering for competitive titles (CS2, Valorant, Apex Legends, Gameloop).

---

## 🛡️ Safety & Reversibility

* **Zero Third-Party Downloads:** Unlike other tools, this script does not download sketchy third-party `.exe` files into your `System32` directory.
* **Antivirus Friendly:** Does not compromise Windows Defender security or ask you to disable protection.
* **Full Reversibility:** Option `[8]` in the menu cleanly restores all original Windows network and system parameters at any time.

---

## 👤 Author & Credits

* **Created by:** [PumpkiN (Sadman Hadi)](https://github.com/SadmanHadi)
* **License:** [MIT License](LICENSE)
