# Design Spec: Win_Optimizer WPF GUI, WinGet Software Suite & Advanced Tweaks

**Date:** 2026-10-12  
**Status:** Approved for Implementation Planning  
**Target:** `e:\Projects\Win_Optimizer\optimizer.ps1`  

---

## 1. Executive Summary & Core Goals

Transform PumpkiN's `Win_Optimizer` (`optimizer.ps1`) into the ultimate Windows gaming and system suite:
1. **Modern Dark WPF (XAML) Desktop GUI**: Custom cyberpunk-styled GUI with navigation tabs, interactive cards, status badges, and real-time console logging.
2. **Complete WinGet Software Downloader (Install Tab)**: All 10 major categories with 100+ curated packages, search filtering, and 1-click Install, Upgrade, and Uninstall actions powered by native WinGet.
3. **Hardware-Level Gaming Engine**: GPU optimizations (NVIDIA PowerMizer / AMD Anti-Lag), CPU Quantum scheduling (Win32PrioritySeparation 0x28), DPC latency mitigations, and network anti-lag tuning (Nagle off, DSCP 46, NDU leak fix).
4. **All WinUtil S-Tier & Snappy OS Tweaks**: MPO disabler, mouse acceleration disable, sticky keys disable, end task with right-click, background apps disable, widgets removal, SvcHost RAM splitting, WPBT execution block, peripheral bloat block, Windows AI / Recall purge, classic right-click menu, Bing search disable, long paths, lock screen disable, BSoD verbose mode, and reserved storage disable.
5. **Zero-Dependency Single Script Distribution**: Everything embedded into `optimizer.ps1` (`irm ... | iex`) with an optional `-CLI` flag for terminal environments.
6. **100% Revert Coverage**: Clean rollback for every single tweak in `Restore-Defaults`.

---

## 2. Navigation Architecture & Tabs

```
+---------------------------------------------------------------------------------------------------+
|  [⚡] PUMPKIN'S ULTIMATE GAMING OPTIMIZER & SOFTWARE SUITE v5.0                      [_] [□] [X]  |
+---------------------------------------------------------------------------------------------------+
|  [📦 Software Downloader]    [🎮 Gaming Tweaks]    [🚀 Match Booster]    [🛡️ System & Tools]      |
+---------------------------------------------------------------------------------------------------+
```

### Tab 1: 📦 Software Downloader (Complete 10-Category WinGet Suite)
1. **Search & Category Filter Bar**:
   - Live Search Input Box (instant search filtering as you type).
   - Category Chips:
     - `[All]`
     - `[Browsers]` (Brave, Chrome, Chromium, Edge, Firefox, Floorp, LibreWolf, Tor, Vivaldi, Waterfox, Zen)
     - `[Communications]` (Discord, Telegram, Signal, Slack, Teams, WhatsApp, Zoom, Vesktop, TeamSpeak 3/5)
     - `[Development]` (VS Code, Cursor, Git, GitHub Desktop, Python, NodeJS, Docker, Claude Code, Rust, Go)
     - `[Document]` (Adobe Acrobat, Obsidian, LibreOffice, PDF24, Sumatra PDF, Joplin, Zotero)
     - `[Games]` (Steam, Epic Games, Battle.net, EA App, GOG Galaxy, Heroic, Roblox, CurseForge, Playnite, Ubisoft)
     - `[Microsoft Tools]` (PowerToys, Windows Terminal, Sysinternals Suite, .NET Runtimes, VC++ Redistributables)
     - `[Multimedia Tools]` (OBS Studio, VLC, HandBrake, Audacity, Blender, GIMP, K-Lite, ShareX, mpv)
     - `[Pro Tools]` (DDU, CPU-Z, GPU-Z, HWiNFO, HWMonitor, Cinebench R23, Wireshark, PuTTY, Mullvad/Proton VPN)
     - `[Selfhosted Tools]` (Jellyfin, Plex, Moonlight, Sunshine, LocalSend, Syncthing)
     - `[Utilities]` (MSI Afterburner, 7-Zip, NanaZip, Revo Uninstaller, Process Lasso, Bulk Crap Uninstaller, CrystalDiskInfo, Rufus, Everything, Snappy Driver)
2. **Action Sidebar**:
   - `[Install / Upgrade Selected]` (`winget install --id <Id> --silent --accept-package-agreements --accept-source-agreements`)
   - `[Uninstall Selected]` (`winget uninstall --id <Id> --silent`)
   - `[Upgrade All Applications]` (`winget upgrade --all --silent`)
   - `[Select All]` / `[Clear Selection]`
   - `Selected Apps Count: X` indicator
3. **Card Grid UI**:
   - Modern dark rounded cards (`#1E2430` background, `#2A3444` border, cyan hover outline).
   - Green corner status badge indicator.
   - App title, category tag, and selection checkbox.

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
3. **Latency & Input Tweaks**:
   - Mouse Acceleration Disable (Enhance Pointer Precision off + 1:1 linear curve)
   - Sticky Keys Prompt Disable (no Shift key interruptions in games)
   - DPC Latency Mitigations
4. **Network & Anti-Lag**:
   - Nagle's Algorithm Disable (TcpAckFrequency=1, TCPDelAckTicks=0)
   - 100% QoS Reservation & DSCP 46 Gaming Packet Tagging
   - NDU Memory Leak Fix
   - Cloudflare Gaming DNS (1.1.1.1)
5. **Beast Mode Debloat**:
   - Background Services Debloat (SysMain, DiagTrack, WSearch, Xbox)
   - Ultimate Performance Power Plan
   - Visual Effects Stripping (Pure Performance Mode)
   - Privacy & Telemetry Hardening
   - Disk I/O & Temp Cleanup
   - Junk Scheduled Tasks Disable
6. **Action Bar**:
   - `[⚡ Run All-in-One Beast Mode]`
   - `[↺ Revert All to Defaults]`

---

### Tab 3: 🚀 Match Booster & Latency
1. **Live Standby List Memory Monitor**:
   - Total RAM vs. Free RAM vs. Standby Cache gauge.
   - `[Purge Standby Memory Now]` button.
   - Toggle: `[Auto-Purge Standby Cache Every 5 Minutes (Daemon)]`.
2. **Wi-Fi Ping Spike Mitigator**:
   - Toggle: `[Disable Background Wi-Fi Scans During Gameplay]` (eliminates 100ms+ spikes).
3. **Esports High Priority Hooks**:
   - IFEO High CPU Priority & High GPU Performance preferences for:
     - Valorant, CS2, Apex Legends, Fortnite, Call of Duty / Warzone, Overwatch 2.

---

### Tab 4: 🛡️ System & Tools (WinUtil Hardening & Snappy OS)
1. **System & Gaming Hardening**:
   - Multiplane Overlay (MPO) Disabler
   - Peripheral Auto-Bloatware Block (Razer & Logitech auto-installer write deny via `icacls`)
   - SvcHost RAM Threshold Splitting (`SvcHostSplitThresholdInKB` tuned to physical RAM)
   - UEFI / WPBT Bootloader Binary Execution Block (`DisableWpbtExecution = 1`)
   - Windows AI / Copilot / Recall Total Purge
   - End Task With Right Click on Taskbar Enable
   - Background Apps Global Disable (`GlobalUserDisabled = 1`)
   - Widgets Platform Removal (`Microsoft.WidgetsPlatformRuntime`)
2. **Snappy OS & Power-User Tweaks**:
   - Classic Windows 10 Right-Click Menu on Windows 11
   - Start Menu Bing Search Disable
   - Explorer Auto Folder Discovery Disable
   - Enable Long Paths (>260 chars)
   - Disable Lock Screen
   - BSoD Verbose Mode
   - Disable Reserved Storage (~7GB SSD space reclaim)
   - Show File Extensions & Hidden Files
   - Windows Update Policy: Security-Only (delays feature updates 2 years, keeps security patches)
3. **System Tools**:
   - Microsoft Activation Scripts (MAS) 1-Click Launch (`irm https://get.activated.win | iex`)
   - Create System Restore Point
   - Hardware Spec Sheet & Diagnostics Viewer

---

### Bottom Console & Real-Time Output Bar
- Scrollable console text box at the bottom displaying timestamped output from executed scripts, WinGet downloads, and errors in real-time.
- Progress bar and status indicator for active background tasks.

---

## 3. Technical Implementation & Safety

1. **Self-Contained Embedded Script**:
   - Embedded XAML markup parsed natively with `[System.Windows.Markup.XamlReader]::Parse()`.
   - Embedded JSON catalog of software packages across all 10 categories.
2. **Asynchronous Non-Blocking Workers**:
   - Heavy tasks run in background PowerShell runspaces; UI thread remains responsive and logs update via `Dispatcher.Invoke()`.
3. **CLI Fallback Engine**:
   - Accessible via `optimizer.ps1 -CLI` or if GUI initialization fails.
4. **100% Rollback Coverage**:
   - `Restore-Defaults` cleanly reverses all tweaks (MPO, mouse curves, sticky keys, background apps, WPBT, SvcHost splitting, context menu, update policies, etc.).
