# Design Specification: Windows 11 Fluent + Cyberpunk UI Architecture (v5.6.0)

**Date:** 2026-10-21  
**Target Release:** PumpkiN's Ultimate Windows Optimizer & Software Suite v5.6.0  
**Status:** Approved for Implementation Planning  

---

## 1. Executive Summary & Goals

The goal of this architectural overhaul is to transform the user interface of **PumpkiN's Ultimate Windows Optimizer & Software Suite** from an overwhelming 2,500-line monolithic XAML card wall into a modern, responsive, and intuitive **Windows 11 Fluent + Cyberpunk Dark** desktop application.

### Key Deliverables:
1. **Windows 11 Left Navigation Rail**: Collapsible sidebar navigation (Dashboard, Gaming Tweaks, Privacy & Telemetry, System & Shell, Software Downloader, Device Specs) replacing legacy top horizontal tabs.
2. **Individual Fluent Toggle Switches**: Every tweak features a native-style toggle switch (`[● ON]` / `[○ OFF]`) combining live state detection and 1-click execution into a single, clean control.
3. **Preset-Aware Master Controls**: Dedicated **"Turn All ON"** and **"Turn All OFF"** controls that operate sequentially, tweak-by-tweak, with live visual feedback rather than an opaque black-box batch.
4. **Universal Instant Search & Filtering**: Top search bar filtering tweaks and applications in real time as the user types.
5. **Collapsible Bottom Activity Drawer**: Reclaiming ~25% of screen height by keeping the console log hidden in a 30px telemetry status bar until active operations run or the user expands it.
6. **Data-Driven Dynamic Card Factory**: Eliminating ~1,800 lines of repetitive hard-coded XAML in `modules/Gui-Markup.ps1` by driving tweak cards from a structured metadata registry in `modules/Gui-Controller.ps1`.
7. **100% Native PowerShell & Zero-Dependency Portability**: Preserving strict compatibility with Windows PowerShell 5.1 and PowerShell 7+, maintaining the single-command remote runner (`irm ... | iex`).

---

## 2. Visual Architecture & Layout Hierarchy

### Layout Wireframe

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ [🎃 PUMPKIN OPTIMIZER v5.6.0]   [ 🔍 Search tweaks & apps... ]   [🛡️ Restore] [🔑 MAS]  │
├───────────────┬────────────────────────────────────────────────────────────────────────┤
│ ⚡ Dashboard   │  🎮 Gaming & Low Latency                                               │
│ 🎮 Gaming     │  Presets: [ All ] [⭐ Recommended Safe ] [ 🔥 Esports Extreme ] [ Active ]│
│ 🛡️ Privacy    │  Actions: [⚡ Turn All ON ]  [↺ Turn All OFF (Defaults) ]  [🔍 Live Audit]│
│ ⚙️ System     │ ────────────────────────────────────────────────────────────────────── │
│ 📦 Software   │ ┌────────────────────────────────────────────────────────┐             │
│ 💻 Device     │ │ Hardware MSI Mode                         [ ● ON  ]    │             │
│               │ │ Switches GPU and USB controllers to MSI for lowest DPC.│             │
│               │ └────────────────────────────────────────────────────────┘             │
│               │ ┌────────────────────────────────────────────────────────┐             │
│               │ │ 8000Hz USB Input Polling                  [ ○ OFF ]    │             │
│               │ │ Removes keyboard buffer throttling and locks rate.     │             │
│               │ └────────────────────────────────────────────────────────┘             │
├───────────────┴────────────────────────────────────────────────────────────────────────┤
│ [▲ Show Console]  ● System Ready • Score: 86% (Grade A) • 52 / 82 Tweaks Active        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Window Specifications
- **Base Dimensions**: 1240 × 820 px (Min: 1040 × 680 px), centered on screen.
- **Color Palette (Cyberpunk Dark + Fluent)**:
  - Background Base: `#0A0E17` (Deep obsidian dark)
  - Surface Cards: `#121824` (Subtle dark slate card container)
  - Card Hover: `#1A2234`
  - Border Strokes: `#1F293D` (Subtle 1px border contrast)
  - Primary Accent (Cyan): `#00D2FF` (Glows, active indicators, titles)
  - Success / Active (Neon Green): `#00FF88` (Active toggles, optimal score)
  - Warning / Esports (Orange): `#FF7700` (Extreme tweaks, Beast Mode)
  - Danger / Rollback (Crimson): `#FF3366`
  - Text Primary: `#FFFFFF`
  - Text Muted: `#94A3B8`

---

## 3. Component Architecture & Data Flow

### 3.1 Unified Tweak Metadata Schema
In `modules/Gui-Controller.ps1`, all 82 tweaks are declared in a structured array `$script:TweakDefinitions`:

```powershell
[PSCustomObject]@{
    Key         = "HardwareMsi"
    Title       = "Hardware MSI Mode"
    Description = "Switches GPU, USB, and network adapters to Message Signaled Interrupts (MSI) for lowest DPC latency."
    Category    = "Gaming"        # Gaming, Privacy, System, Device
    Tier        = "Recommended"   # Recommended, Safe, Esports
    Apply       = { Optimize-HardwareMsiMode }
    Rollback    = { Restore-HardwareMsiMode }
}
```

### 3.2 Dynamic WPF Card Factory
Rather than generating thousands of lines of hard-coded XML borders:
1. `modules/Gui-Markup.ps1` defines the master Window shell, styles, templates (including the custom Fluent `ToggleButton` style), and page layout containers.
2. The controller iterates through `$script:TweakDefinitions` and instantiates WPF controls directly using fast .NET constructors:
   - Container: `[System.Windows.Controls.Border]`
   - Text Blocks: Title (`#FFFFFF`, SemiBold), Description (`#94A3B8`, TextWrapping)
   - Toggle: Custom styled `[System.Windows.Controls.Primitives.ToggleButton]`
3. Cards are injected into the designated category panels (`WrapPanel` or `StackPanel`).

### 3.3 Live Audit Probe & Toggle State Binding
1. **Startup Probe**: On launch, the controller invokes `Get-SystemAuditState` (<60ms).
2. **State Application**:
   - For each tweak, if `$audit.State[$tw.Key] -eq $true`, the toggle switch is checked (`IsChecked = $true`), displaying `[● ON]` in Neon Green/Cyan.
   - If `$false`, the toggle switch is unchecked (`IsChecked = $false`), displaying `[○ OFF]` in dark slate.
3. **Individual Switch Click Handler**:
   - User flips switch from OFF → ON: The controller triggers `& $tw.Apply`, verifies the registry, updates the toggle, and updates the live health gauge.
   - User flips switch from ON → OFF: The controller triggers `& $tw.Rollback`, verifies default registry restoration, updates the toggle, and recalibrates the health score.

---

## 4. Sequential Step-by-Step Execution Engine

To satisfy the explicit user requirement (*"not in batch but single single tweak activation"*):

1. **Step-by-Step Runner**:
   - When **"Turn All ON"** or a preset filter is triggered, the controller creates a sequential execution queue of the matching tweaks.
   - For each tweak:
     1. The active view scrolls to the card.
     2. The switch displays a brief transition state.
     3. The tweak's cmdlet executes.
     4. A targeted audit verifies the result.
     5. The toggle switch flips visually to `[● ON]` (or `[○ OFF]` during rollback).
     6. The bottom activity bar increments progress: `[18/45] Hardware MSI Mode... OK`.
2. **Error Isolation**:
   - Every execution is wrapped in a `try / catch` block.
   - If a tweak fails or is unsupported on the current Windows build, the error is logged to the console, its toggle stays OFF, and the runner smoothly advances to the next tweak without crashing.

---

## 5. Navigation & Multi-Page View Specifications

### Page 1: Dashboard & Audit
- Radial Circular Score Gauge displaying overall Optimization Score (0–100%) and Grade (`A+`, `A`, `B`, `C`).
- Hardware Quick Stats: CPU model, GPU vendor, active network adapter, RAM capacity.
- Curated 1-Click Profile Launchers: *Esports Competitive*, *Recommended Safe*, *Privacy Hardened*.

### Page 2: Gaming & Latency Tweaks
- GPU Optimizations (Auto-Tuning, Hardware MSI, Disable USB Sleep, MPO Fix).
- Latency & Input (Raw Mouse Linear Curve, 8000Hz USB Keyboard Response, CSRSS Realtime I/O).
- Kernel & CPU Quantum (Win32PrioritySeparation 0x26, SvcHost RAM Splitting, Audio DPC).
- Network & Anti-Lag (TCP/IP Gaming Stack, 0ms Wi-Fi Ping Shield).

### Page 3: Privacy & Telemetry
- Windows Diagnostic Telemetry suppression.
- Cortana & Start Menu Bing Search suppression.
- 3rd-Party Telemetry Killers (Edge, Chrome, Firefox, NVIDIA telemetry).
- Speech, Handwriting, and Clipboard syncing disable.

### Page 4: System & Shell Usability
- Classic Windows 10 Context Menu on Windows 11.
- Explorer optimizations (Show file extensions, enable Win32 long paths, compact mode).
- Power Scheme Unlocking (Ultimate Performance profile).
- Bloatware AppX uninstaller and background junk task cleanup.

### Page 5: Software Downloader (WinGet Suite)
- 115+ curated packages across 10 categories.
- Real-time search filter and category chip selector.
- Asynchronous installation via background Runspaces with live streaming progress.

### Page 6: Device Details
- Master PC banner and interactive hardware spec sheet (CPU, GPU, RAM, Storage, Network, Battery).
- 1-click clipboard copy buttons for hardware specs.

---

## 6. Safety, Reversibility & Release Control

1. **100% Symmetrical Rollback Guarantee**:
   - Every tweak mapping contains an exact inverse function. No registry key is permanently modified without an exact default restoration function.
2. **Version Bump to v5.6.0**:
   - Synchronously updated across:
     - `optimizer.ps1`
     - `modules/Gui-Markup.ps1`
     - `README.md`
     - `agents.md`
3. **Verification Protocol**:
   - PowerShell AST parser check (`[System.Management.Automation.Language.Parser]::ParseFile`) across all `.ps1` files.
   - XAML validity check (`[System.Windows.Markup.XamlReader]::Parse()`).
   - Live audit integration verification.
