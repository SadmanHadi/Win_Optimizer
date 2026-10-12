# WPF GUI & WinGet Software Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform `optimizer.ps1` into a self-contained, modern WPF desktop application with an integrated 10-category WinGet Software Downloader, hardware-level gaming optimizer, and the complete suite of WinUtil low-latency hardening tweaks, while maintaining a `-CLI` headless fallback.

**Architecture:** A monolithic, zero-dependency PowerShell script with embedded WPF XAML markup, a structured WinGet package catalog, non-blocking asynchronous worker runspaces, thread-safe UI Dispatcher logging, and complete rollback routines.

**Tech Stack:** PowerShell 5.1 / 7+, .NET WPF (`PresentationFramework`, `PresentationCore`, `WindowsBase`, `System.Xaml`), native WinGet (`winget.exe`), Windows CIM/WMI, Registry APIs.

**Spec:** `docs/superpowers/specs/2026-10-12-wpf-gui-and-app-manager-design.md`

## Global Constraints
- **Single-Script Standalone Distribution:** All code, XAML markup, and package definitions must reside within `e:\Projects\Win_Optimizer\optimizer.ps1` so `irm https://raw.githubusercontent.com/.../optimizer.ps1 | iex` works directly.
- **Admin Elevation:** Script must automatically detect elevation and self-elevate via `Start-Process powershell -Verb RunAs` if not administrative.
- **Non-Blocking UI:** Long-running tasks (winget downloads, DISM commands, restore point creation) must never execute synchronously on the WPF UI thread; all must execute in background runspaces and stream logs via `Dispatcher.Invoke()`.
- **Zero Syntax Errors:** The entire script must pass PowerShell AST parser validation (`[System.Management.Automation.Language.Parser]::ParseInput`).
- **Full Revert Safety:** Every single tweak must have a symmetrical revert operation in `Restore-Defaults`.

## Review Focus
- **WinGet Absence:** Handled gracefully if `winget` is missing on older LTSC/Server installations, alerting the user and providing remediation.
- **WPF Initialization Failure:** If WPF fails to load (e.g. Server Core or headless terminal), script must catch the exception and automatically fall back to the `-CLI` interactive menu.
- **Package Id Accuracy:** Every WinGet ID in the catalog must match the official Microsoft community repository.
- **Runspace Exception Safety:** Any background runspace error must be captured and logged to the UI console box rather than causing a silent crash.
- **Registry Permissions:** File folder locks (`icacls`) on peripheral folders must handle existing vs. non-existing paths without halting execution.

---

### Task 1: Implement S-Tier WinUtil & Snappy OS Optimization Functions

**Files:**
- Modify: `e:\Projects\Win_Optimizer\optimizer.ps1`
- Test: PowerShell Pester / AST validation command

**Interfaces:**
- Produces:
  - `Disable-MultiplaneOverlay`
  - `Set-MouseLinearCurve`
  - `Disable-StickyKeysPrompt`
  - `Enable-EndTaskRightClick`
  - `Disable-BackgroundAppsGlobal`
  - `Remove-WidgetsPlatform`
  - `Optimize-SvcHostSplitting`
  - `Block-WpbtExecution`
  - `Block-PeripheralBloat`
  - `Remove-WindowsAI`
  - `Enable-ClassicContextMenu`
  - `Disable-StartMenuBing`
  - `Disable-ExplorerAutoDiscovery`
  - `Enable-LongPaths`
  - `Disable-LockScreen`
  - `Enable-BsodVerbose`
  - `Disable-ReservedStorage`
  - `Set-ShowFileExtensionsAndHidden`
  - `Set-SecurityUpdatesOnly`
  - Corresponding rollback steps in `Restore-Defaults`

- [ ] **Step 1: Write test script for WinUtil tweak functions**
  Create a test script `test_tweaks.ps1` in `scratch/` that invokes each function in dry-run/mock mode and verifies registry targets and syntax.

- [ ] **Step 2: Run test to verify initial state**
  Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scratch/test_tweaks.ps1`
  Expected: FAIL (functions not yet declared)

- [ ] **Step 3: Implement all 19 optimization functions and rollback logic in `optimizer.ps1`**
  Add full definitions with detailed user feedback (`Write-Host`, error handling with `-ErrorAction SilentlyContinue`). Update `Restore-Defaults` to cleanly reverse all registry entries, remove folder deny ACLs, reset `SvcHostSplitThresholdInKB`, and reset policies.

- [ ] **Step 4: Run test to verify all functions execute cleanly**
  Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scratch/test_tweaks.ps1`
  Expected: PASS with exit code 0

- [ ] **Step 5: Commit Task 1 changes**
  ```bash
  git add optimizer.ps1
  git commit -m "feat: add WinUtil S-tier and Snappy OS optimization functions with rollback"
  ```

---

### Task 2: Implement Complete 10-Category WinGet Software Catalog & Engine

**Files:**
- Modify: `e:\Projects\Win_Optimizer\optimizer.ps1`
- Test: `scratch/test_winget_catalog.ps1`

**Interfaces:**
- Produces:
  - `$Global:AppCatalog`: Structured array/hashtable of 100+ packages across all 10 categories:
    - `Browsers` (Brave, Chrome, Chromium, Edge, Firefox, Floorp, LibreWolf, Tor, Vivaldi, Waterfox, Zen)
    - `Communications` (Discord, Telegram, Signal, Slack, Teams, WhatsApp, Zoom, Vesktop, TeamSpeak)
    - `Development` (VS Code, Cursor, Git, GitHub Desktop, Python, NodeJS, Docker, Claude Code, Rust, Go)
    - `Document` (Adobe Acrobat, Obsidian, LibreOffice, PDF24, Sumatra PDF, Joplin, Zotero)
    - `Games` (Steam, Epic Games, Battle.net, EA App, GOG Galaxy, Heroic, Roblox, CurseForge, Playnite, Ubisoft)
    - `Microsoft Tools` (PowerToys, Windows Terminal, Sysinternals Suite, .NET Runtimes, VC++ Redistributables)
    - `Multimedia Tools` (OBS Studio, VLC, HandBrake, Audacity, Blender, GIMP, K-Lite, ShareX, mpv)
    - `Pro Tools` (DDU, CPU-Z, GPU-Z, HWiNFO, HWMonitor, Cinebench R23, Wireshark, PuTTY, Mullvad/Proton VPN)
    - `Selfhosted Tools` (Jellyfin, Plex, Moonlight, Sunshine, LocalSend, Syncthing)
    - `Utilities` (MSI Afterburner, 7-Zip, NanaZip, Revo Uninstaller, Process Lasso, Bulk Crap Uninstaller, CrystalDiskInfo, Rufus, Everything)
  - `Install-WinGetPackage -PackageId <string>`
  - `Uninstall-WinGetPackage -PackageId <string>`
  - `Update-AllWinGetPackages`

- [ ] **Step 1: Write test script to validate catalog schema**
  Verify each entry in `$AppCatalog` has `Key`, `Name`, `Category`, `WingetId`, and `Description`.

- [ ] **Step 2: Run catalog test**
  Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scratch/test_winget_catalog.ps1`
  Expected: FAIL

- [ ] **Step 3: Embed `$Global:AppCatalog` and WinGet handler functions into `optimizer.ps1`**
  Populate with verified IDs matching official WinGet repository. Ensure functions write timestamped logs to callback/console.

- [ ] **Step 4: Run test to verify catalog schema and WinGet command generation**
  Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scratch/test_winget_catalog.ps1`
  Expected: PASS

- [ ] **Step 5: Commit Task 2 changes**
  ```bash
  git add optimizer.ps1
  git commit -m "feat: embed 10-category WinGet software catalog and runner engine"
  ```

---

### Task 3: Design & Embed Cyberpunk Dark WPF (XAML) UI Markup

**Files:**
- Modify: `e:\Projects\Win_Optimizer\optimizer.ps1`
- Test: `scratch/test_xaml_parse.ps1`

**Interfaces:**
- Produces:
  - `$xamlContent`: Full XAML string containing:
    - Root `Window` with dark theme styling, cyan/neon highlights, window buttons.
    - Top `TabControl` with 4 stylized tabs:
      - Tab 1: `[📦 Software Downloader]` with search box, category chips, scrollable card grid WrapPanel, and action buttons.
      - Tab 2: `[🎮 Gaming Tweaks]` with categorized checkboxes for GPU, CPU, Network, Beast Mode, and Action bar.
      - Tab 3: `[🚀 Match Booster]` with Standby memory gauge, auto-purge toggle, Wi-Fi scan toggle, and game priority buttons.
      - Tab 4: `[🛡️ System & Tools]` with WinUtil hardening checkboxes, Snappy OS toggles, MAS Activation button, Restore Point button.
    - Bottom real-time `TextBox` / console log area and progress bar.

- [ ] **Step 1: Write XAML parsing test script**
  Test using `[System.Windows.Markup.XamlReader]::Parse($xamlContent)` to guarantee XML validity and absence of namespace errors.

- [ ] **Step 2: Run XAML test to verify failure**
  Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scratch/test_xaml_parse.ps1`
  Expected: FAIL

- [ ] **Step 3: Embed `$xamlContent` and WPF asset styles in `optimizer.ps1`**
  Build the complete XAML specification adhering to WPF layout rules, high-DPI scaling, and responsive sizing.

- [ ] **Step 4: Run test to verify XAML parses cleanly into WPF Window**
  Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scratch/test_xaml_parse.ps1`
  Expected: PASS with valid `System.Windows.Window` object

- [ ] **Step 5: Commit Task 3 changes**
  ```bash
  git add optimizer.ps1
  git commit -m "feat: design and embed complete dark cyberpunk WPF XAML interface"
  ```

---

### Task 4: Implement GUI Controller, Async Runspace Workers & CLI Dispatcher

**Files:**
- Modify: `e:\Projects\Win_Optimizer\optimizer.ps1`
- Test: `scratch/test_controller.ps1`

**Interfaces:**
- Produces:
  - `Start-PumpkiNGui`: Loads XAML, dynamically creates app cards from `$AppCatalog`, binds events (Category filter clicks, Search text change, Checkbox toggles, Action clicks), manages background Runspace execution with thread-safe UI Dispatcher logging.
  - Parameter handling: `param([switch]$CLI)` at top of `optimizer.ps1`. If `$CLI` is set or if WPF fails to initialize, falls back to `Show-ConsoleMenu`.
  - Updated `Show-ConsoleMenu` to include all new options [1-27].

- [ ] **Step 1: Write controller test script**
  Verify card dynamic generation, search filter logic, and `-CLI` switch branching.

- [ ] **Step 2: Run controller test**
  Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scratch/test_controller.ps1`
  Expected: FAIL

- [ ] **Step 3: Implement controller, event wiring, and dynamic card rendering in `optimizer.ps1`**
  Add dynamic card generation in WPF WrapPanel, search filter text changed listener, category chip click listeners, action button handlers running via PowerShell Runspace, and Dispatcher log writer. Wire `-CLI` parameter.

- [ ] **Step 4: Run controller test to verify execution**
  Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scratch/test_controller.ps1`
  Expected: PASS

- [ ] **Step 5: Commit Task 4 changes**
  ```bash
  git add optimizer.ps1
  git commit -m "feat: implement GUI event controller, async runspace workers, and CLI fallback"
  ```

---

### Task 5: End-to-End Verification, Performance & Documentation Update

**Files:**
- Modify: `README.md`
- Test: Full AST Parser check on `optimizer.ps1`

**Interfaces:**
- Produces:
  - Fully verified, production-ready `optimizer.ps1`
  - Updated `README.md` showcasing the new WPF GUI, WinGet Software Downloader, and low-latency hardening tweaks.

- [ ] **Step 1: Run comprehensive PowerShell AST parser test**
  Verify zero syntax errors or parsing warnings in `optimizer.ps1`.

- [ ] **Step 2: Verify CLI mode execution**
  Run `powershell -NoProfile -ExecutionPolicy Bypass -File optimizer.ps1 -CLI` in a short timeout or test call to verify menu rendering.

- [ ] **Step 3: Update `README.md` with new features, screenshots/ASCII diagram, and usage guide**
  Detail the GUI launch (`irm ... | iex`), the `-CLI` fallback flag, the 10-category Software Downloader, and all optimization suites.

- [ ] **Step 4: Commit documentation and final verifications**
  ```bash
  git add README.md optimizer.ps1
  git commit -m "docs: update README with WPF GUI, WinGet Software Suite, and hardening docs"
  ```
