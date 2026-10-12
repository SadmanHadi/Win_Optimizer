# Design Spec: Win_Optimizer WPF GUI & WinGet App Manager Suite

**Date:** 2026-10-12  
**Status:** Approved for Implementation Planning  
**Target:** `e:\Projects\Win_Optimizer\optimizer.ps1`  

---

## 1. Executive Summary & Goals

Transform PumpkiN's `Win_Optimizer` (`optimizer.ps1`) into a modern, high-performance desktop application with a native **WPF (XAML) Graphical User Interface**, an integrated **WinGet Application Manager**, and advanced **WinUtil-inspired low-latency hardening tweaks**, while retaining a zero-dependency, self-contained single-script distribution model.

### Key Goals
1. **Self-Contained Single Script**: Keep everything embedded in `optimizer.ps1` so users can still execute `irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex` with zero external dependencies.
2. **Modern Dark WPF GUI**: A dark, responsive GUI with cyan/neon accents, tab navigation, interactive tweak cards, category chips, and real-time status reporting.
3. **Dual-Mode Execution**:
   - Default: Launches the rich WPF GUI.
   - CLI Fallback (`optimizer.ps1 -CLI`): Preserves the interactive ASCII terminal menu for headless systems, SSH sessions, or power users.
4. **App Manager Engine**: WinGet-powered package manager to install, upgrade, and uninstall gaming launchers, overclocking tools, drivers, and daily apps.
5. **WinUtil Hardening Tweaks**: Integrate the 6 identified high-impact optimizations: MPO disabler, peripheral bloatware immunization, SvcHost RAM splitting, WPBT OEM bootloader injection block, Windows AI / Recall purge, and 2-year feature update deferral.
6. **Non-Blocking Async UI**: Multi-threaded execution via PowerShell Runspaces so the GUI never hangs during package downloads or DISM modifications.

---

## 2. System Architecture

### 2.1 File & Execution Layout
```
optimizer.ps1
├── 1. Administrator Elevation Check (Relaunches elevated if non-admin)
├── 2. CLI vs. GUI Dispatcher (-CLI switch detection)
├── 3. Core Optimization Engine (All functions: GPU, CPU, Network, Beast Mode, WinUtil)
├── 4. WinGet Package Catalog & Manager Engine (App definitions + WinGet runner)
├── 5. Embedded WPF XAML String ($xamlContent)
├── 6. GUI Controller & Runspace Orchestrator (Event wiring, Dispatcher logs)
└── 7. CLI Menu Engine (Interactive terminal loop when -CLI is specified)
```

### 2.2 Threading & Responsiveness Model
WPF controls must not be blocked by synchronous tasks like `winget install` or `DISM`.
- **UI Thread**: Owns the WPF Window, tabs, checkboxes, and buttons.
- **Worker Runspace / Job**: Executes optimization functions and WinGet operations in the background.
- **Thread-Safe Logging**: Background workers pass messages to the UI thread via `Dispatcher.Invoke([Action]{ ... })` to update the bottom real-time log box and status text.

---

## 3. Detailed UI Specification (Tabs & Controls)

### Window Shell
- **Title**: `PumpkiN's Ultimate Gaming Optimizer & App Manager v5.0`
- **Theme**: Dark Mode (`#121820` background, `#1A2332` card panels, `#00E5FF` cyan primary accent, `#00FF7F` green success indicators, `#FF3366` warning highlights).
- **Size**: 1050x700 (Resizable, centered on screen).
- **Navigation Tabs**:
  1. `[🎮 Gaming Tweaks]`
  2. `[📦 App Manager]`
  3. `[🚀 Match Booster]`
  4. `[🛡️ Hardening & Tools]`

---

### Tab 1: 🎮 Gaming Tweaks
Organized into collapsible or categorized panels:
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
   - `[⚡ Run All-in-One Beast Mode]` (applies all recommended optimizations)
   - `[↺ Revert All to Defaults]` (restores standard Windows configuration)

---

### Tab 2: 📦 App Manager (WinGet Engine)
A full-featured software center for gamers:
1. **Category Filter Chips**:
   - `[All]`
   - `[Gaming & Launchers]` (Steam, Epic Games, Battle.net, EA App, GOG Galaxy, Discord, Heroic Games Launcher)
   - `[Gaming Utilities & OC]` (MSI Afterburner, RivaTuner Statistics Server, OBS Studio, Voicemeeter Banana, DDU, System Informer)
   - `[Drivers & Runtimes]` (NVIDIA App, AMD Adrenalin, DirectX End-User Runtime, Visual C++ All-in-One)
   - `[Browsers & Media]` (Brave, Google Chrome, Mozilla Firefox, VLC Media Player, Spotify)
   - `[Tools & Productivity]` (7-Zip, Notepad++, Git, VS Code)
2. **Interactive Cards Grid**:
   - Checkbox for multi-select.
   - App Name + Category Badge + Short Description.
   - Installed State Detection (indicates if app is already present via WinGet query).
3. **Action Buttons**:
   - `[Install / Upgrade Selected]` -> calls `winget install --id <Id> --silent --accept-package-agreements --accept-source-agreements`
   - `[Uninstall Selected]` -> calls `winget uninstall --id <Id> --silent`
   - `[Upgrade All Applications]` -> calls `winget upgrade --all --silent`
   - `[Select All / Deselect All]`

---

### Tab 3: 🚀 Match Booster & Latency
Hardware-level match tuning for competitive esports:
1. **Live Standby List Memory Monitor**:
   - Total RAM vs. Free RAM vs. Standby Cache gauge.
   - `[Purge Standby Memory Now]` button.
   - Toggle: `[Auto-Purge Standby Cache Every 5 Minutes (Daemon)]`.
2. **Wi-Fi Ping Spike Mitigator**:
   - Toggle: `[Disable Background Wi-Fi Scans During Gameplay]` (eliminates 100ms+ spikes).
3. **Esports High Priority Hooks**:
   - One-click installer for IFEO High CPU Priority & High GPU Performance preferences for:
     - Valorant (`VALORANT-Win64-Shipping.exe`)
     - Counter-Strike 2 (`cs2.exe`)
     - Apex Legends (`r5apex.exe`)
     - Fortnite (`FortniteClient-Win64-Shipping.exe`)
     - Call of Duty / Warzone (`cod.exe`)
     - Overwatch 2 (`Overwatch.exe`)

---

### Tab 4: 🛡️ Hardening, WinUtil & Tools
Advanced system tweaks and utility actions:
1. **WinUtil Hardening Suite**:
   - Multiplane Overlay (MPO) Disabler
   - Peripheral Auto-Bloatware Block (Immunizes Razer & Logitech installer paths via `icacls`)
   - SvcHost RAM Threshold Splitting (`SvcHostSplitThresholdInKB` tuned to physical RAM)
   - UEFI / WPBT Bootloader Binary Execution Block (`DisableWpbtExecution = 1`)
   - Windows AI / Copilot / Recall Total Purge
   - Windows Update Policy: Security-Only (delays feature updates 2 years, keeps security patches)
2. **System Tools**:
   - Microsoft Activation Scripts (MAS) 1-Click Launch (`irm https://get.activated.win | iex`)
   - Create System Restore Point
   - Hardware Spec Sheet & Diagnostics Viewer

---

### Bottom Status & Real-Time Console Bar
- A multi-line scrollable text console at the bottom of the window displaying timestamped output from executed scripts, WinGet downloads, and errors in real-time.
- Progress bar indicator for ongoing operations.

---

## 4. Error Handling & Rollback Strategy

1. **Prerequisite Validation**:
   - Elevation check ensures script runs with Administrator privileges.
   - WinGet presence check: If `winget` is missing on older Windows 10 builds, the script alerts the user and provides an automatic install command.
2. **Revert Capability**:
   - Every tweak added has a complete corresponding rollback routine in `Restore-Defaults`:
     - Re-enables MPO, re-enables WPBT execution, resets SvcHostSplitThresholdInKB to default, unlocks peripheral folders, resets Windows Update policies, re-enables background services.
3. **Graceful UI Fallback**:
   - If WPF fails to load for any reason (e.g. Server Core or headless environment), the script automatically drops into the `-CLI` interactive menu.

---

## 5. Verification & Testing Plan

1. **Syntax Validation**: Run PowerShell AST parser check (`[System.Management.Automation.Language.Parser]::ParseInput`) to guarantee zero syntax errors.
2. **XAML Parsing Validation**: Validate that XAML schema correctly parses under `[Windows.Markup.XamlReader]::Parse()`.
3. **CLI Mode Verification**: Test `optimizer.ps1 -CLI` to verify full feature availability in terminal mode.
4. **WinGet Integration Verification**: Test WinGet ID resolution and argument formatting.
5. **Rollback Verification**: Verify that Revert restores all changed registry keys and permissions.
