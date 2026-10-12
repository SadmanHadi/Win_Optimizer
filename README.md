<div align="center">

# 🎃 PumpkiN's Ultimate Windows Optimizer & Software Suite
### *v5.4.0 — The Definitive Gaming Engine, Privacy Hardener & App Manager for Windows 10 & 11*

<p align="center" style="font-size: 1.15rem; color: #00FFCC; font-weight: bold;">
  <strong>Streamline • Optimize • Dominate</strong><br>
  <span style="font-size: 0.95rem; color: #8892B0; font-weight: normal;">Hardware-Probed Performance • 100% Symmetrical Rollback Guarantee • Zero Bloatware • 100+ App Catalog</span>
</p>

[![Release](https://img.shields.io/badge/Release-v5.4.0-00FFCC?style=for-the-badge&logo=github&logoColor=0A0C10)](https://github.com/SadmanHadi/Win_Optimizer/releases)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/SadmanHadi/Win_Optimizer)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/SadmanHadi/Win_Optimizer)
[![Reversibility](https://img.shields.io/badge/Reversibility-100%25%20Symmetrical-FF0055?style=for-the-badge&logo=shield&logoColor=white)](https://github.com/SadmanHadi/Win_Optimizer)
[![License](https://img.shields.io/badge/License-MIT-BD93F9?style=for-the-badge)](LICENSE)

<br/>

<a href="#-quick-start"><img src="https://img.shields.io/badge/Quick%20Start-Launch%20Now-00FFCC?style=for-the-badge&logo=powershell&logoColor=black" alt="Quick Start"></a>
<a href="#-modern-wpf-desktop-gui-cyberpunk-dark-theme"><img src="https://img.shields.io/badge/UI-Cyberpunk%20Dark%20GUI-FF0055?style=for-the-badge" alt="Cyberpunk GUI"></a>
<a href="#-symmetrical-rollback-guarantee--system-audit"><img src="https://img.shields.io/badge/Safety-1--Click%20Rollback-BD93F9?style=for-the-badge" alt="Safety Rollback"></a>
<a href="https://github.com/SadmanHadi/Win_Optimizer/stargazers"><img src="https://img.shields.io/github/stars/SadmanHadi/Win_Optimizer?style=for-the-badge&color=gold" alt="GitHub Stars"></a>

</div>

---

## 💡 Why Choose PumpkiN's Ultimate Optimizer?

Unlike black-box debloaters that irreversibly gut system files or install unverified third-party binaries, **PumpkiN's Ultimate Optimizer** is built on four core principles:

1. **100% Reversibility & Auditability:** Every single registry tweak, service toggle, and policy has an exact, symmetrical inverse rollback. You can audit live system state anytime, inspect tweak badges, and roll back any change with a single click.
2. **Zero Third-Party Binaries or Malware:** 100% pure native Windows PowerShell, Registry, DISM, BCDEDIT, WinGet, and WMI/CIM. Only one safe, open-source memory cache clearing utility (`EmptyStandbyList.exe` by wj32) is included for competitive match boosting.
3. **Hardware Auto-Detection:** Automatically probes your CPU (Cores/Threads), GPU vendor (NVIDIA GeForce vs AMD Radeon vs Intel), active network interface (Ethernet wired vs Wi-Fi), and RAM capacity to apply tailored optimizations.
4. **PowerShell 5.1 & 7+ Universal Support:** Executes out of the box on Windows 10 (20H1+) and Windows 11 without requiring extra runtimes or installations.

---

## ⚡ Quick Start

### Option 1: 1-Click Double-Click Launcher (Recommended)
If you have cloned or downloaded this repository, simply **double-click** [`Run-Optimizer.cmd`](file:///e:/Projects/Win_Optimizer/Run-Optimizer.cmd).  
It automatically self-elevates with Administrator rights and launches the modern WPF GUI without execution policy restrictions.

### Option 2: One-Line Remote Run (PowerShell)
Open **PowerShell** (or Windows Terminal) as **Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex
```

### Option 3: Terminal / CLI Mode
Prefer a lightweight terminal menu or running in a headless / remote SSH environment? Append `-CLI`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\optimizer.ps1 -CLI
```

---

## 🖥️ Modern WPF Desktop GUI (Cyberpunk Dark Theme)

PumpkiN's Ultimate Optimizer features a responsive, hardware-accelerated WPF dark desktop interface with real-time audit scoring, live tweak status badges, and 4 dedicated operational tabs:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ ⚡ PUMPKIN ULTIMATE OPTIMIZER [v5.4.0]        [🛡️ Restore Point]  [🔑 MAS Activation]    │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ [📦 Software]  [🎮 Gaming]  [🚀 Match Booster]  [🛡️ System & Tools]  [💻 Device Details]│
├────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                        │
│  📊 SYSTEM AUDIT & OPTIMIZATION SCORE                                                  │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │ ⚡ OPTIMIZATION SCORE: 88% [GRADE A - HIGH PERFORMANCE]                          │  │
│  │ 52 / 77 Tweaks Applied • 25 Tweaks Recommend Optimization                        │  │
│  │ [🔍 Re-Scan System State]  [⚡ Apply Unapplied Tweaks Only]  [↺ Revert All Defaults]│  │
│  └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                        │
│  🎮 GAMING & LOW LATENCY TWEAKS:                                                       │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │ [Optimal ✓] Win32Priority Separation (0x26)    [Apply]  [↺ Rollback]              │  │
│  │ [Optimal ✓] Device Manager High-Latency Tuning [Apply]  [↺ Rollback]              │  │
│  │ [Optimal ✓] Turn Off BitLocker Permanently     [Apply]  [↺ Rollback]              │  │
│  │ [Optimal ✓] Multiplane Overlay (MPO) Fix       [Apply]  [↺ Rollback]              │  │
│  │ [Optimal ✓] 1:1 Raw Mouse Linear Curve         [Apply]  [↺ Rollback]              │  │
│  │ [Needed]    8000Hz USB Keyboard Response Rate  [Apply]  [↺ Rollback]              │  │
│  │ [Optimal ✓] TCP / IP NoDelay & Anti-Lag Engine [Apply]  [↺ Rollback]              │  │
│  └──────────────────────────────────────────────────────────────────────────────────┘  │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ OUTPUT LOG: [12:00:00] PumpkiN Ultimate Gaming Optimizer v5.4.0 initialized.           │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100%      │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Dashboard Tabs Overview
1. **📦 Software Downloader:** Curated 10-category catalog containing 100+ popular applications powered by Windows WinGet. Real-time search filter, category chips, batch installation, silent uninstaller, and 1-click upgrade.
2. **🎮 Gaming Tweaks:** System debloat, kernel scheduler (0x26), Device Manager tuning (HPET, SMBus, System Speaker, Timers), DPC latency, 8000Hz raw mouse curves, TCP NoDelay, GPU suites, and individual 1-click apply and rollback buttons.
3. **🚀 Match Booster:** Standby list memory purger, Wi-Fi 0ms ping spike shield, and esports process priority hooks (Valorant, CS2, Apex, Fortnite, PUBG, COD, Overwatch 2).
4. **🛡️ System & Tools:** Live System Audit Dashboard with percentage score, Windows 11 Exclusives Suite, Advanced 3rd-Party App Telemetry Killer, permanent BitLocker & device encryption disable, UEFI WPBT & peripheral block, TrafficMonitor telemetry suite, and Microsoft Activation Scripts (MAS).
5. **💻 Device Details:** Real-time hardware spec sheet displaying Master PC Banner, OS, CPU (cores/cache), GPU, RAM, Storage (physical drives & volume capacities), Network, and Battery with collapsible cards and 1-click clipboard copying.

---

## 📊 Feature Comparison Matrix

| Feature | Default Windows | Generic Debloaters | PumpkiN Optimizer v5.4.0 |
| :--- | :---: | :---: | :---: |
| **100% Symmetrical Rollback** | ❌ None | ⚠️ Partial / Broken | ✅ **Every Single Tweak** |
| **Live Optimization Score Gauge** | ❌ None | ❌ None | ✅ **0–100% Live Score Card** |
| **Individual Tweak Badges** | ❌ None | ❌ None | ✅ **[Optimal ✓] / [Needed]** |
| **Per-Tweak 1-Click Rollback** | ❌ None | ❌ None | ✅ **[↺ Rollback] on every tweak** |
| **Apply Unapplied Only** | ❌ None | ❌ None | ✅ **1-Click Smart Apply** |
| **Hardware Auto-Detection** | ❌ None | ❌ None | ✅ **CPU, GPU, RAM, Net Probed** |
| **Esports Match Booster (RAM + Wi-Fi)** | ❌ None | ❌ None | ✅ **Standby Purge + 0ms Ping Shield** |
| **Windows 11 Exclusives Suite** | ❌ None | ⚠️ Basic | ✅ **VBS, Taskbar, Menus, Snap, Ads** |
| **3rd Party App Telemetry Killer** | ❌ None | ❌ None | ✅ **Edge, Chrome, Firefox, VS, Nvidia** |
| **WinGet 100+ App Manager** | ❌ None | ⚠️ External | ✅ **10 Categories Built-in** |
| **Open Source & Native PowerShell** | ❌ N/A | ⚠️ Often Closed EXE | ✅ **100% Transparent Code** |

---

## 🚀 Complete Optimization Suites

### 1. 🛡️ Live System Audit & Safety Engine
- **Live System Audit (`Get-SystemAuditState`):** Probes 75+ registry keys and system settings in real time to calculate your overall **Optimization Score (0–100%)** and performance grade (A+, A, B, C, D).
- **Live Visual Status Badges:** Visual badges indicate whether a tweak is currently applied (`[Optimal ✓]` in neon cyan) or needs attention (`[Needed]`).
- **Selective Optimization:** Click **"Apply Unapplied Tweaks Only"** to intelligently skip already-optimized settings and configure only what needs tuning.
- **Safety Backups:** Creates Windows System Restore points (`New-SystemRestorePointSafe`) with 1-click confirmation before modifying critical system values.

### 2. 🪟 Windows 11 Exclusives & Shell Usability Suite
- **Disable Virtualization-Based Security (VBS / HVCI):** Recovers up to 5–15% CPU gaming performance lost to hypervisor paging and virtualization overhead (`bcdedit /set hypervisorlaunchtype off`).
- **Taskbar Left Alignment:** Restores ergonomic left alignment (`TaskbarAl = 0`).
- **Remove Recommended Section in Start:** Eliminates clutter and cloud promoted items in the Start Menu.
- **Disable Taskbar Chat & Widgets:** Removes Microsoft Teams Chat (`TaskbarMn = 0`) and Windows Widgets panel (`TaskbarDa = 0`).
- **Enable File Explorer Compact Mode:** Restores dense, high-efficiency item spacing (`FolderDescriptions CompactMode = 1`).
- **Disable Snap Assist Flyouts:** Stops intrusive snapping suggestion popups (`SnapAssist = 0`).
- **Disable Desktop Stickers:** Strips Windows 11 desktop sticker bloat.
- **Disable Edge Discover Button:** Strips Bing Discover button and sidebar hooks.
- **Add "Copy To" & "Move To" Context Menu:** Adds native Explorer shell verbs for rapid file operations.
- **Disable Aero Shake:** Stops background windows from minimizing when shaking the active title bar.
- **Enable System-Wide Dark Mode:** Sets Apps and System theme to high-contrast Dark Mode (`AppsUseLightTheme = 0`, `SystemUsesLightTheme = 0`).
- **Enable Verbose Logon Messages:** Displays granular Windows startup/shutdown status messages.
- **Legacy Boot Menu:** Restores instant F8 Safe Mode boot menu (`bcdedit /set {default} bootmenupolicy legacy`).

### 3. 🔒 Advanced Privacy & Third-Party App Telemetry Killer
- **3rd-Party Browser & Tool Telemetry Removal:**
  - **Microsoft Edge:** Disables metrics reporting, shopping assistant, personalization, and background hub.
  - **Google Chrome:** Disables metrics reporting, crash dumping, and background cloud services.
  - **Mozilla Firefox:** Disables telemetry, Normandy studies, and crash reporting.
  - **Visual Studio & VS Code:** Disables SQM telemetry and customer feedback reporting.
  - **NVIDIA GeForce Experience:** Disables `NvTelemetry` daemon and client tracking keys.
- **Bluetooth Advertising Beacon Block:** Disables peripheral proximity beacons.
- **Disable Cloud Content & Consumer Promotions:** Prevents silent cloud app installations and OOBE suggestions.
- **Connected Devices Platform (CDP):** Disables background cross-device tracking service.
- **Disable Toast Action Center Notifications:** Silences intrusive desktop toast interruptions.
- **Disable Online Speech Recognition & ARSO:** Disables cloud voice recognition and automatic restart of apps after sign-on.
- **Disable Handwriting & Inking Telemetry:** Stops keystroke harvesting and ink sample reporting.
- **Disable Cloud Clipboard & Message Sync:** Prevents clipboard contents from uploading to Microsoft cloud servers.
- **Disable SafeSearch & Find My Device:** Eliminates location polling and Bing search history logging.
- **Disable Legacy SMBv1 & Remote Registry:** Closes legacy attack vectors and unauthorized network registry access.
- **Exclude Driver Updates from Windows Update:** Stops Windows Update from overwriting custom graphics and peripheral drivers.
- **Tune System Shutdown & Hung App Timeouts:** Reduces service kill and hung application timeouts to 2000ms for instant system shutdown.

### 4. 🎮 Gaming, Kernel & Latency Engine
- **Win32PrioritySeparation (0x26):** Optimizes thread quantum scheduling for foreground gaming processes.
- **Disable Multiplane Overlay (MPO Fix):** Resolves desktop hitching, black screen flickers, and Discord/browser hardware acceleration lag.
- **1:1 Linear Raw Mouse Curve:** Strips pointer acceleration curves (`SmoothMouseXCurve` / `SmoothMouseYCurve`) for pixel-perfect tracking.
- **SvcHost Splitting Optimization:** Scales `SvcHostSplitThresholdInKB` to your physical RAM (3.5GB+ sets to full capacity), reducing memory footprint while maintaining process stability.
- **8000Hz High-Polling Input Tuning:** Optimizes USB queue depth and keyboard repeat rates for ultra-low latency inputs.
- **Network Anti-Lag Engine:** Disables Nagle's algorithm (`TcpAckFrequency = 1`, `TCPNoDelay = 1`), fixes NDU memory leaks, and configures Netsh autotuning.

### 5. 🚀 Match Booster & Competitive Esports Hooks
- **Pre-Match RAM Purger:** Flushes standby memory cache via `EmptyStandbyList.exe` before jumping into matches.
- **Wi-Fi Ping Spike Shield:** Freezes Windows wireless background roaming scans (`autoconfig=disabled`) for flat 0ms ping spikes.
- **High CPU & I/O Priority Esports Hooks (IFEO):**
  - *Counter-Strike 2* (`cs2.exe`)
  - *Valorant* (`VALORANT-Win64-Shipping.exe`)
  - *PUBG: BATTLEGROUNDS* (`TslGame.exe` / `PUBG-Win64-Shipping.exe`)
  - *Apex Legends* (`r5apex.exe`)
  - *Fortnite* (`FortniteClient-Win64-Shipping.exe`)
  - *Call of Duty* (`cod.exe`)
  - *Rainbow Six Siege* (`RainbowSix.exe`)
  - *Overwatch 2* (`Overwatch.exe`)

### 6. 📦 10-Category WinGet Software Suite (100+ Applications)
- **Browsers:** Brave, Chrome, Chromium, Edge, Firefox, Floorp, LibreWolf, Tor, Vivaldi, Waterfox, Zen Browser, Opera GX.
- **Communications:** Discord, Telegram, Signal, Slack, Teams, WhatsApp, Zoom, Vesktop, TeamSpeak 3, Element.
- **Development:** VS Code, Cursor AI, Git, GitHub Desktop, Python 3.12, NodeJS LTS, Docker, Rustup, Go, Neovim, Windows Terminal, Notepad++, Sublime Text, DBeaver, Postman.
- **Document:** Adobe Acrobat Reader, Obsidian, LibreOffice, PDF24 Creator, Sumatra PDF, Joplin, Zotero, Foxit PDF, Calibre, Typora.
- **Games:** Steam, Epic Games Launcher, Battle.net, EA App, GOG Galaxy, Heroic Games Launcher, Roblox, CurseForge, Playnite, Ubisoft Connect, Prism Launcher, Moonlight.
- **Microsoft Tools:** Microsoft PowerToys, Windows Terminal, Sysinternals Suite, .NET 8 Runtime, Visual C++ 2015-2022 (x64/x86), DirectX Runtimes, Process Explorer, AutoRuns, PowerShell 7.
- **Multimedia Tools:** OBS Studio, VLC, HandBrake, Audacity, Blender, GIMP, K-Lite Codec Pack Mega, ShareX, mpv.net, Paint.NET, Foobar2000, Spotify.
- **Pro Tools:** DDU (Display Driver Uninstaller), CPU-Z, GPU-Z, HWiNFO, HWMonitor, Cinebench R23, Wireshark, PuTTY, Mullvad VPN, Proton VPN, WinSCP, FileZilla.
- **Selfhosted Tools:** Jellyfin Media Player, Plex Desktop, Sunshine, LocalSend, Syncthing, Tailscale, WireGuard, RustDesk.
- **Utilities:** MSI Afterburner, 7-Zip, NanaZip, Revo Uninstaller, Process Lasso, Bulk Crap Uninstaller, CrystalDiskInfo, CrystalDiskMark, Rufus, Everything, TreeSize Free, BleachBit, WinDirStat, FastCopy.

---

## 📁 Repository Architecture & Modular Engine

The repository follows a clean, decoupled design with an orchestrator and 17 dedicated standalone modules:

```text
Win_Optimizer/
├── Run-Optimizer.cmd                        # 1-Click Administrative double-click launcher
├── optimizer.ps1                            # Master orchestrator & CLI/GUI launcher
├── Build-Bundle.ps1                         # Production bundler (compiles dist/optimizer.ps1)
├── EmptyStandbyList.exe                     # Native memory cache clearing utility (wj32)
├── README.md                                # Public documentation & user guide
├── agents.md                                # AI & developer operating contract
├── LICENSE                                  # Open-source MIT License
│
├── dist/                                    # Pre-compiled standalone release bundles
│   └── optimizer.ps1                        # Standalone all-in-one distribution bundle
│
└── modules/                                 # 17 Modular standalone optimization engines
    ├── App-Catalog.ps1                      # WinGet 100+ package catalog & async runners
    ├── Gui-Markup.ps1                       # Cyberpunk Dark WPF (XAML) UI Markup
    ├── Gui-Controller.ps1                   # Event controller, audit scoring & async runner
    ├── Hardware-Detection.ps1               # Hardware profiler (CPU, GPU, RAM, Net)
    ├── Match-Booster.ps1                    # RAM standby purge & esports process priority
    ├── Optimize-KernelAndCpu.ps1            # Win32Priority 0x26, quantum scheduler & MMCSS
    ├── Optimize-Network.ps1                 # TCPNoDelay, Nagle off, NDU fix, Netsh autotuning
    ├── Optimize-AmdGpu.ps1                  # AMD Radeon ULPS disable, Shader Cache, Anti-Lag
    ├── Optimize-NvidiaGpu.ps1               # NVIDIA PowerMizer P0 lock, Max Performance & Cache
    ├── Optimize-GpuAuto.ps1                 # Smart GPU vendor detection & auto-routing
    ├── Optimize-InputLatency.ps1            # 8000Hz polling buffer & 1:1 MarkC mouse curve
    ├── Toggle-WifiScan.ps1                  # Wi-Fi background roaming toggle (0ms ping spikes)
    ├── Optimize-Hardening.ps1               # Defender, ASR, WPBT block, peripheral block
    ├── Optimize-SystemAndDebloat.ps1        # Services debloat, power plans & visual effects
    ├── System-DiagnosticsAndRestore.ps1     # Live audit state engine & symmetrical restore
    ├── Optimize-Windows11AndShell.ps1       # Windows 11 exclusives (VBS, Start, Menus, Snap)
    └── Optimize-PrivacyAndTelemetry.ps1     # 3rd party app telemetry & advanced privacy
```

---

## 📋 Interactive CLI Menu Overview

When running with `-CLI` or in a terminal session, the complete interactive menu is accessible:

```text
================================================================================
           ULTIMATE GAMING & NETWORK OPTIMIZER v5.4.0
          Created by PumpkiN | Max FPS - Ultra Low Latency
================================================================================
  [CPU] AMD Ryzen 7 5800X3D (8C / 16T)
  [GPU] NVIDIA GeForce RTX 3080
  [NET] Ethernet [Ethernet (Wired)]
  [SCORE] 88% [GRADE A - HIGH PERFORMANCE] (52/77 Applied)
--------------------------------------------------------------------------------
  [1]  FULL ALL-IN-ONE OPTIMIZATION (Hardware Auto-Detect + All Tweaks) [BEST]
  [2]  Auto-Detect & Optimize Active GPU (NVIDIA / AMD Radeon)
  [3]  AMD Radeon GPU Dedicated Suite (Disable ULPS, Shader Cache, Anti-Lag)
  [4]  NVIDIA GeForce Dedicated Suite (PowerMizer P0, Max Performance, Cache)
  [5]  Network & Anti-Lag Suite (Nagle Off, 100% QoS, NDU Leak Fix, DNS)
  [6]  Wi-Fi Ping Spike Mitigator (Toggle Background Scan for 0ms Spikes)
  [7]  CPU, Kernel & Quantum Engine (Win32Priority 0x26, FTH Off, Core Unpark)
  [8]  Ultra-Low Latency, DPC & 8000Hz Input (StopHighDPC, Raw Mouse Curve)
  [9]  Competitive Match Booster (Immediate RAM Flush + 5-Min Background Auto-Purge)
  [10] Game-Specific High Priority Hooks (Valorant, CS2, Apex, PUBG, Fortnite, COD)
  [11] System Health, Live Diagnostics & Hardware Spec Sheet
  [12] Create Windows System Restore Point (Safety Backup)
  [13] Revert All Settings to Windows Defaults
  [14] Activate Windows (Microsoft Activation Scripts - MAS)
  ...
  [45] TrafficMonitor Suite (Latest x64 Release, MiSans Fonts, Custom Config)
  [46] Compact Window Metrics (8px Scrollbars, 1px Border, 0 Padding, Compact Title Bar)
  [47] Disable All Windows Ads (Lock Screen, Start, Explorer, Settings, Search)
  [48] Remove Shortcut Arrow Overlays (Clean No-Arrow Desktop Icons)
  [49] Restore Window Metrics, Windows Ads & Shortcut Arrows to Defaults
  [50] Apply Unapplied Tweaks Only (Smart Scan & Fix Missing Optimizations)
  [51] Windows 11 Exclusives Suite (VBS Off, Taskbar Left, Compact Mode, Snap Assist)
  [52] Advanced Privacy & App Telemetry Suite (Edge, Chrome, VS, Nvidia, SafeSearch)
  [53] Device Manager Tuning (Disable HPET, SMBus, System Speaker & Legacy Timers)
  [54] Turn Off BitLocker Permanently (Disable Encryption, BDESVC & Decrypt Drives)
  [0]  Exit
================================================================================
```

---

## 🤝 Contributing & Standards

We welcome community contributions, additional software packages, and performance optimizations. Please adhere to our development standards:

1. **100% Symmetrical Reversibility:** Any tweak added must include an exact symmetrical reversal in `Restore-Defaults` and its module.
2. **Zero Third-Party Binaries:** Only native PowerShell, Registry, DISM, and WinGet commands are accepted.
3. **PowerShell 5.1 & 7+ Compatibility:** Avoid PowerShell 7-only operators (`?:`, `??`, `&&`, `||`).
4. **ASCII / UTF-8 without BOM Safety:** Use standard ASCII hyphens `--` and plain quotes `""`.
5. **AST Syntax Validation:** All scripts must pass `[System.Management.Automation.Language.Parser]::ParseFile` with zero errors.

---

## 👤 Author & Credits

* **Created by:** [PumpkiN (Sadman Hadi)](https://github.com/SadmanHadi)
* **Repository:** [https://github.com/SadmanHadi/Win_Optimizer](https://github.com/SadmanHadi/Win_Optimizer)
* **License:** [MIT License](LICENSE)
