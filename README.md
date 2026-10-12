# 🎃 PumpkiN's Ultimate Windows Optimizer & Software Suite v5.1.0

> **The all-in-one low-latency Windows gaming engine and 100+ app package manager.**  
> 100% Native PowerShell & WPF Architecture • Dark Cyberpunk Desktop GUI & CLI Fallback • Safe, transparent, and 100% reversible.  
> **Created by PumpkiN | Max FPS - Ultra Low Latency**

---

## ⚡ Quick Start: One-Line Run (PowerShell)

Open **PowerShell** (or Windows Terminal) as **Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex
```

*(Launches the modern WPF Desktop GUI by default. If running in a headless or terminal-only environment, or if you prefer the interactive terminal menu, append `-CLI`)*:

```powershell
irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex; & ./optimizer.ps1 -CLI
```

---

## 🖥️ Modern WPF Desktop GUI (Cyberpunk Dark Theme)

PumpkiN's Ultimate Optimizer features a sleek, hardware-accelerated dark desktop interface with real-time logging, dynamic progress indicators, and 4 dedicated operational tabs:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ ⚡ PUMPKIN ULTIMATE OPTIMIZER [v5.1.0]        [🛡️ Restore Point]  [🔑 MAS Activation]    │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ [📦 Software Downloader]  [🎮 Gaming Tweaks]  [🚀 Match Booster]  [🛡️ System & Tools] │
├────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                        │
│  🔍 Search 100+ apps...                      [All] [Browsers] [Comms] [Dev] [Games]... │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐ │
│  │ ☑ Brave Browser  │  │ ☑ Discord        │  │ ☑ VS Code        │  │ [⚡ Install]    │ │
│  │ Fast, ad-free    │  │ Voice & chat     │  │ Code editor      │  │ [🗑️ Uninstall]  │ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  │ [🔄 Upgrade All]│ │
│                                                                    └─────────────────┘ │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ OUTPUT LOG: [12:00:00] PumpkiN Ultimate Gaming Optimizer & Software Suite initialized. │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100%      │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

1. **📦 Software Downloader (Install Tab):**
   - 10 curated categories with 100+ popular applications (Browsers, Communications, Development, Document, Games, Microsoft Tools, Multimedia, Pro Tools, Selfhosted, Utilities).
   - Real-time search filter and horizontal category chips.
   - Batch install, silent uninstall, and 1-click system-wide upgrade powered by native Windows WinGet.
2. **🎮 Gaming Tweaks:**
   - Categorized optimization panes for GPU & Display, Ultra-Low Latency & Timers, Network Engine, Power & Visuals, and Background Services.
   - One-click **ENGAGE BEAST MODE** banner applying all 20+ low-latency tweaks in one sweep.
3. **🚀 Match Booster:**
   - Real-time Standby List memory purger for stutter-free matches.
   - Wi-Fi ping spike shield (freezes background network auto-roaming).
   - High-priority process hooks (IFEO) for Valorant, CS2, Apex, PUBG, Fortnite, Call of Duty, Rainbow Six Siege, and Overwatch 2.
4. **🛡️ System & Tools:**
   - Snappy OS & WinUtil security hardening (UEFI WPBT block, peripheral bloatware auto-install block, Windows AI purge, classic context menu).
   - TrafficMonitor taskbar telemetry suite with MiSans typography engine and custom layout configuration.
   - 1-Click Microsoft Activation Scripts (MAS) integration.
   - 1-Click System Restore Point safety backup.

---

## 📁 Repository & Architecture Overview

Everything in this repository is cleanly organized, modular, and self-contained:

```text
Win_Optimizer/
├── optimizer.ps1                            # Master orchestrator & CLI/GUI launcher (~330 lines)
├── EmptyStandbyList.exe                     # Native kernel memory management utility (wj32)
├── README.md                                # Documentation and quick-start guide
├── LICENSE                                  # Open-source MIT License
│
└── modules/                                 # Modular standalone scripts (clean & decoupled)
    ├── App-Catalog.ps1                      # $Global:AppCatalog (100+ packages) & WinGet runners
    ├── Gui-Markup.ps1                       # Cyberpunk Dark WPF (XAML) UI Markup
    ├── Gui-Controller.ps1                   # Desktop GUI Event Controller & Async Engine
    ├── Hardware-Detection.ps1               # Hardware profiler (CPU/GPU/RAM/Network auto-detect)
    ├── Match-Booster.ps1                    # Instant RAM Purge & 5-Min Background Auto-Cleaner
    ├── Optimize-KernelAndCpu.ps1            # Win32Priority 0x26, FTH Shield, DPC Threading & Quantum
    ├── Optimize-Network.ps1                 # Nagle off, TCPNoDelay, NDU memory leak fix & DNS
    ├── Optimize-AmdGpu.ps1                  # AMD Radeon ULPS disable, Shader Cache, Anti-Lag
    ├── Optimize-NvidiaGpu.ps1               # NVIDIA PowerMizer P0 lock, Max Performance & Cache
    ├── Optimize-GpuAuto.ps1                 # Smart GPU detection & automatic routing
    ├── Optimize-InputLatency.ps1            # 8000Hz mouse queue buffer & 1:1 MarkC raw mouse curve
    ├── Toggle-WifiScan.ps1                  # Wi-Fi background roaming spike toggle (0ms spikes)
    ├── Optimize-Hardening.ps1               # WinUtil S-Tier & Snappy OS hardening (MPO, AI, WPBT)
    ├── Optimize-SystemAndDebloat.ps1        # Background services debloat, power plans & storage
    └── System-DiagnosticsAndRestore.ps1     # Esports IFEO hooks, diagnostics & full rollback
```

---

## 🚀 Key Features Breakdown

### 📦 1. 10-Category WinGet Software Suite (100+ Applications)
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

### 🛡️ 2. WinUtil S-Tier & Snappy OS Hardening
- **Disable Multiplane Overlay (MPO Fix):** Resolves desktop stuttering, black screens, and Discord/browser hardware acceleration hitching.
- **1:1 Linear Mouse Curve:** Disables Windows pointer acceleration curves (`SmoothMouseXCurve` / `SmoothMouseYCurve`) for pure 1:1 raw tracking.
- **Optimize SvcHost Splitting:** Sets `SvcHostSplitThresholdInKB` according to your physical installed RAM (3.5GB+ sets to full RAM capacity), stopping unnecessary memory overhead while preserving process isolation.
- **Block Peripheral Bloatware:** Employs NTFS deny-execute (`icacls`) on temporary installer paths to prevent Razer Synapse, Armoury Crate, and Alienware bloat from auto-installing upon plugging in mice/keyboards.
- **Block UEFI WPBT Bloatware:** Disables Windows Platform Binary Table execution (`DisableWpbtExecution = 1`) to prevent motherboard vendor payloads from running silently.
- **Purge Windows AI Bloatware:** Removes Windows Recall snapshotting, Copilot hooks, and CoreAI background services.
- **Security-Only Windows Updates:** Defers feature upgrades by 2 years (`DeferFeatureUpdates = 1`, 730 days) while keeping zero-day quality and security patches active.
- **Enable Classic Context Menu:** Restores the responsive Windows 10 right-click menu on Windows 11.

### 🔴 3. Dedicated AMD Radeon & NVIDIA GeForce Suites
- **AMD ULPS Disabled:** Eliminates aggressive core power gating causing frametime drops, 1% low stutter, and multi-monitor sleep freezes.
- **NVIDIA PowerMizer P0 Lock:** Prevents clock drops between rounds and scene transitions.
- **DirectX Shader Cache Flushing:** Cleans fragmented cache folders to eliminate frame compilation hitching.

### 📶 4. Wi-Fi Ping Spike Mitigator (0ms Spikes)
- Windows scans for wireless networks every 60 seconds in the background, causing periodic 100–300ms ping spikes during online gaming.
- Built-in toggle allows players to **freeze background scanning** while gaming for flat, wired-like ping, and re-enable it whenever needed.

### 🎯 5. Competitive Match Booster & Esports Hooks (IFEO)
- **Pre-Match Flush:** Terminates background recording hogs and high-polling RGB software, followed by an immediate standby memory purge.
- **Esports Process Priority Hooks:** Permanently sets High CPU Priority and High I/O Priority for:
  - *Counter-Strike 2* (`cs2.exe`)
  - *Valorant* (`VALORANT-Win64-Shipping.exe`)
  - *PUBG: BATTLEGROUNDS* (`TslGame.exe` / `PUBG-Win64-Shipping.exe`)
  - *Apex Legends* (`r5apex.exe`)
  - *Fortnite* (`FortniteClient-Win64-Shipping.exe`)
  - *Call of Duty* (`cod.exe`)
  - *Rainbow Six Siege* (`RainbowSix.exe`)
  - *Overwatch 2* (`Overwatch.exe`)

### 📊 6. TrafficMonitor Taskbar Telemetry & MiSans Fonts
- **Direct GitHub Releases Grabber:** Automatically pulls and extracts the latest official x64 release of TrafficMonitor (`zhongyang219/TrafficMonitor`) into `Program Files`.
- **MiSans Typography Engine:** Installs and registers all 10 MiSans TrueType font weights with real-time Windows font cache registration (`WM_FONTCHANGE`).
- **Custom Config Preset:** 1-Click deployment of customized `config.ini` telemetry taskbar layout.

### 🎨 7. Compact Window Metrics, Ad Killer & Clean Desktop
- **Compact Window Metrics:** 8px thin scrollbars (`ScrollWidth = -120`, `ScrollHeight = -120`), 1px borders (`BorderWidth = -15`), 0px border padding (`PaddedBorderWidth = 0`), and 10px compact title bar (`CaptionHeight = -150`, `SmCaptionHeight = -150`) for a sleek, modern, distraction-free desktop layout.
- **Disable All Windows Ads:** Eliminates Lock Screen ads & suggestions, Start Menu promoted app suggestions, File Explorer OneDrive sync ads, Settings app commercial tips, Bing Web Search telemetry, and consumer cloud bloatware.
- **Remove Shortcut Arrow Overlays (No Arrow):** Uses bundled transparent icon asset (`blank.ico`) to cleanly strip shortcut arrow badges across Windows desktop and Explorer icons without black square glitches.
- **100% Reversibility:** Full one-click default restoration for all WindowMetrics, commercial ad keys, and shortcut icons.

---

## 📋 Interactive CLI Menu Overview [0-49]

When launched with the `-CLI` switch or in headless environments, the complete interactive menu is accessible:

```text
================================================================================
           ULTIMATE GAMING & NETWORK OPTIMIZER v5.1.0
          Created by PumpkiN | Max FPS - Ultra Low Latency
================================================================================
  [CPU] AMD Ryzen 7 5800X3D (8C / 16T)
  [GPU] NVIDIA GeForce RTX 3080
  [NET] Ethernet [Ethernet (Wired)]
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
  ---- BEAST MODE OPTIMIZATIONS ------------------------------------------------
  [15] Debloat & Disable Background Services (SysMain, Telemetry, Xbox, Cortana)
  [16] Ultimate Performance Power Plan + HPET/Timer Optimization
  [17] Strip All Visual Effects & Animations (Pure Performance Mode)
  [18] Privacy & Telemetry Hardening (Kill All Tracking & Ads)
  [19] Disk I/O & Storage Optimization (NTFS Tweaks + Temp Cleanup)
  [20] Disable Junk Scheduled Tasks (Compatibility, Defrag, Diagnostics)
  [21] Startup Bloat Cleanup & Gaming DNS (Cloudflare 1.1.1.1)
  ---- PRO TOOLS & HARDENING ---------------------------------------------------
  [22] WinUtil Tweaks (MPO Fix, Mouse Curve, SvcHost Splitting, End Task)
  [23] WinGet Software Manager (Install, Update, or Search 100+ Applications)
  [24] Block Peripheral & UEFI Bloatware (Razer, Armoury Crate icacls deny)
  [25] Purge Windows AI Bloatware (Recall, Copilot, CoreAI)
  [26] Security-Only Updates (Defer Feature Builds 2 Years, Keep Quality Updates)
  [27] Restore Windows 10 Classic Right-Click Menu & File Visibility
  [0]  Exit
================================================================================
```

---

## 👤 Author & Credits

* **Created by:** [PumpkiN (Sadman Hadi)](https://github.com/SadmanHadi)
* **Repository:** [https://github.com/SadmanHadi/Win_Optimizer](https://github.com/SadmanHadi/Win_Optimizer)
* **License:** [MIT License](LICENSE)
