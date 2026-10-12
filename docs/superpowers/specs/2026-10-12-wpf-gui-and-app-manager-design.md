# Design Spec: Win_Optimizer WPF GUI & Complete WinGet Software Suite

**Date:** 2026-10-12  
**Status:** Approved for Implementation Planning  
**Target:** `e:\Projects\Win_Optimizer\optimizer.ps1`  

---

## 1. Executive Summary & Goals

Transform PumpkiN's `Win_Optimizer` (`optimizer.ps1`) into a modern, complete desktop application featuring:
1. A **Native WPF (XAML) Graphical User Interface** with sleek cyberpunk/dark styling.
2. A **Comprehensive Software Downloader & App Manager (Install Tab)** covering all 10 major software categories with 100+ curated packages, search filtering, and 1-click Install / Upgrade / Uninstall actions powered by native WinGet.
3. Advanced **WinUtil-inspired low-latency hardening tweaks** (MPO disabler, peripheral bloat block, SvcHost RAM splitting, WPBT UEFI block, Windows AI / Recall purge, and 2-year feature update deferral).
4. Retains **single-script self-contained distribution** (`irm ... | iex`) with an optional `-CLI` headless fallback.

---

## 2. Navigation Architecture & Tabs

```
+---------------------------------------------------------------------------------------------------+
|  [⚡] PUMPKIN'S ULTIMATE GAMING OPTIMIZER & SOFTWARE SUITE v5.0                      [_] [□] [X]  |
+---------------------------------------------------------------------------------------------------+
|  [📦 Install Software]    [🎮 Gaming Tweaks]    [🚀 Match Booster]    [🛡️ WinUtil & Tools]        |
+---------------------------------------------------------------------------------------------------+
```

### Tab 1: 📦 Install Software (Direct App Downloader & Manager)
Matches the full WinUtil Software Downloader shown in the screenshots:
1. **Search & Filter Bar**:
   - Real-time instant search input box (filters apps dynamically as you type).
   - Category Chips Bar:
     - `[All]`
     - `[Browsers]` (Brave, Chrome, Chromium, Edge, Firefox, Floorp, LibreWolf, Tor, Vivaldi, Waterfox, Zen)
     - `[Communications]` (Discord, Telegram, Signal, Slack, Teams, WhatsApp, Zoom, Vesktop, TeamSpeak)
     - `[Development]` (VS Code, Cursor, Git, GitHub Desktop, Python, NodeJS, Docker, Cursor, Claude Code, Rust, Go)
     - `[Document]` (Adobe Acrobat, Obsidian, LibreOffice, PDF24, Sumatra PDF, Joplin)
     - `[Games]` (Steam, Epic Games, Battle.net, EA App, GOG Galaxy, Heroic, Roblox, CurseForge, Playnite, Ubisoft)
     - `[Microsoft Tools]` (PowerToys, Windows Terminal, Sysinternals Suite, .NET Runtimes, VC++ Redistributables)
     - `[Multimedia Tools]` (OBS Studio, VLC, HandBrake, Audacity, Blender, GIMP, K-Lite, ShareX, mpv)
     - `[Pro Tools]` (DDU, CPU-Z, GPU-Z, HWiNFO, HWMonitor, Cinebench, Wireshark, Putty, Mullvad/Proton VPN)
     - `[Selfhosted Tools]` (Jellyfin, Plex, Moonlight, Sunshine, LocalSend, Syncthing)
     - `[Utilities]` (MSI Afterburner, 7-Zip, NanaZip, Revo Uninstaller, Process Lasso, Bulk Crap Uninstaller, CrystalDiskInfo, Rufus, Everything)
2. **Action Sidebar**:
   - `[Install / Upgrade Selected]` (executes `winget install --id <Id> --silent --accept-package-agreements --accept-source-agreements`)
   - `[Uninstall Selected]` (executes `winget uninstall --id <Id> --silent`)
   - `[Upgrade All Applications]` (executes `winget upgrade --all --silent`)
   - `[Select All]` / `[Clear Selection]`
   - `Selected Apps Count: X` indicator
3. **Card Grid UI**:
   - Modern dark rounded cards (`#1E2430` background, `#2A3444` border, cyan hover outline).
   - Green corner status badge indicator.
   - App icon / glyph placeholder, app title, and category badge.
   - Interactive checkbox / click-to-select toggle.

---

### Tab 2: 🎮 Gaming Tweaks
1. **GPU Optimization**:
   - Auto-Detect Active GPU (NVIDIA / AMD)
   - NVIDIA PowerMizer P0 / Max Performance / Shader Cache
   - AMD Anti-Lag / Shader Cache / Disable ULPS
   - Multiplane Overlay (MPO) Stutter & Black Screen Fix
2. **CPU & Kernel Engine**:
   - Win32PrioritySeparation (0x28 Long Quantum)
   - Core Unparking (100% min/max cores) & Idle State Disable
   - Fault Tolerant Heap (FTH) Disable
   - High-Precision Timer (`useplatformclock`, `disabledynamictick`)
3. **Network & Anti-Lag**:
   - Nagle's Algorithm Disable (TcpAckFrequency=1, TCPDelAckTicks=0)
   - 100% QoS Reservation & DSCP 46 Gaming Packet Tagging
   - NDU Memory Leak Fix
   - Cloudflare Gaming DNS (1.1.1.1)
4. **Beast Mode Debloat**:
   - Background Services Debloat (SysMain, DiagTrack, WSearch, Xbox)
   - Ultimate Performance Power Plan
   - Visual Effects Stripping (Pure Performance Mode)
   - Privacy & Telemetry Hardening
   - Disk I/O & Temp Cleanup
   - Junk Scheduled Tasks Disable
5. **Action Bar**:
   - `[⚡ Run All-in-One Beast Mode]` (applies all recommended gaming tweaks)
   - `[↺ Revert All to Defaults]` (restores standard Windows configuration)

---

### Tab 3: 🚀 Match Booster & Latency
1. **Live Standby List Memory Monitor**:
   - Total RAM vs. Free RAM vs. Standby Cache meter.
   - `[Purge Standby Memory Now]` button.
   - Toggle: `[Auto-Purge Standby Cache Every 5 Minutes (Daemon)]`.
2. **Wi-Fi Ping Spike Mitigator**:
   - Toggle: `[Disable Background Wi-Fi Scans During Gameplay]` (eliminates 100ms+ spikes).
3. **Esports High Priority Hooks**:
   - IFEO High CPU Priority & High GPU Performance preferences for:
     - Valorant, CS2, Apex Legends, Fortnite, Call of Duty / Warzone, Overwatch 2.

---

### Tab 4: 🛡️ WinUtil Hardening & Tools
1. **WinUtil Hardening Suite**:
   - Multiplane Overlay (MPO) Disabler
   - Peripheral Auto-Bloatware Block (Immunizes Razer & Logitech installer directories via `icacls`)
   - SvcHost RAM Threshold Splitting (`SvcHostSplitThresholdInKB` tuned to physical RAM)
   - UEFI / WPBT Bootloader Binary Execution Block (`DisableWpbtExecution = 1`)
   - Windows AI / Copilot / Recall Total Purge
   - Windows Update Policy: Security-Only (delays feature updates 2 years, keeps security patches)
2. **System Tools**:
   - Microsoft Activation Scripts (MAS) 1-Click Launch (`irm https://get.activated.win | iex`)
   - Create System Restore Point
   - Hardware Spec Sheet & Diagnostics Viewer

---

### Real-Time Console & Progress Area
- Scrollable console text box at the bottom displaying timestamped output from executed scripts, WinGet downloads, and errors in real-time.
- Progress bar and status indicator for active background tasks.

---

## 3. Implementation Details

1. **Self-Contained Execution**:
   - Embedded XAML string parsed via `[System.Windows.Markup.XamlReader]::Parse()`.
   - Embedded JSON catalog of apps with categories and WinGet IDs.
2. **Asynchronous Non-Blocking Workers**:
   - Background actions dispatched to background runspaces or PowerShell jobs with output marshaled to the UI thread via `Dispatcher.Invoke()`.
3. **CLI Fallback**:
   - Renders the interactive terminal menu when `-CLI` is specified.
4. **Full Revert Safety**:
   - Complete rollback coverage in `Restore-Defaults`.
