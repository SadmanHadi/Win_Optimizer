# AGENTS.md

Operating instructions and development standards for coding agents working on **PumpkiN's Ultimate Windows Optimizer & Software Suite v5.1.0** (`Win_Optimizer`). Read this file before every task.

**Working code only. Finish the job. Plausibility is not correctness.**

---

## 0. Non-Negotiables

These rules override everything else in this file when in conflict:

1. **100% Reversibility**: Every optimization tweak added to `modules/Optimize-*.ps1` MUST have an exact symmetrical reversal in `Restore-Defaults` (in `modules/System-DiagnosticsAndRestore.ps1`) or within its dedicated module. No "one-way" destructive actions. Never permanently delete system components or files; only disable or uninstall gracefully.
2. **Zero Third-Party Malware or Unnecessary Binaries**: Only native Windows utilities (PowerShell, DISM, Registry, WinGet, BCDEDIT, Netsh, WMI/CIM) are permitted. The only allowed standalone external binary in the root is `EmptyStandbyList.exe` for memory cache clearing. Never bundle unauthorized executables, miners, or unverified DLLs.
3. **Strict PowerShell 5.1 & PowerShell 7+ Compatibility**: All scripts, modules, and commands must execute cleanly in Windows PowerShell 5.1 (the default built into Windows 10/11) and PowerShell 7+. Do not use PowerShell 7-only syntax (e.g., ternary operators `?:`, null-coalescing `??` / `??=`, pipeline chaining `&&` / `||`).
4. **Strict ASCII / UTF-8 without BOM Safety**: Never use non-ASCII typographic characters (em dashes `--`, smart quotes `""`, stylized bullets, ellipses) in `.ps1` code. In Windows PowerShell 5.1, non-ASCII characters without BOM corrupt string literals and cause byte-level truncation, leading to fatal AST parser errors. Always use standard ASCII hyphens `--` and plain quotes `""`.
5. **Modular Architecture Integrity**: Maintain the clean modular separation established in v5.0. `optimizer.ps1` is the master orchestrator (~330 lines); specific functionality belongs in dedicated modules under `modules/`. Do not bloat `optimizer.ps1` with feature implementations.
6. **Dual Invocation Pattern**: Standalone modules in `modules/` must support both being dot-sourced by `optimizer.ps1` and being run directly as standalone scripts:
   ```powershell
   if ($MyInvocation.InvocationName -ne '.') {
       # Elevation check and standalone execution
   }
   ```
7. **Never Fabricate**: Do not invent file paths, function names, test results, or API behavior. Test all changes with AST validation and functional test scripts.
8. **Verify Before Saying Done**: Run AST parser checks and test suites before claiming completion. Evidence before assertions always.
9. **Mandatory Version Bumping & Synchronization**: Whenever updating features, fixing bugs, or committing changes, increment and synchronously update the version number across all project locations (`optimizer.ps1`, `modules/Gui-Markup.ps1`, `README.md`, `agents.md`) and tag commit messages with the version. Never make updates or commits without updating the version number.

---

## 1. Architecture & Module Map

The codebase is organized into an orchestrator and 15 dedicated modules:

### Root Orchestrator
- **`optimizer.ps1`**: Master entry point. Handles admin elevation check, CLI argument parsing (`-CLI`), module loader (local dot-sourcing with automatic fallback to GitHub raw web streaming for portable `irm ... | iex` usage), and GUI launcher.
- **`EmptyStandbyList.exe`**: Pre-compiled native utility used by Match Booster for clearing Windows memory standby cache.
- **`README.md`**: Public-facing user guide, feature overview, and quick-start instructions.
- **`agents.md`**: This developer and AI agent operating contract.

### Modules (`modules/`)
1. **`App-Catalog.ps1`**: Curated WinGet application catalog containing 100+ packages across 10 categories (Browsers, Gaming, Dev & Tools, Productivity, Communication, Media & Creative, Utilities & System, Security & Privacy, Runtimes & Drivers, Emulators & Gaming Tools). Exports `Get-AppCatalog` and `Get-AppCatalogCategories`.
2. **`Gui-Markup.ps1`**: Pure XAML markup generator (`Get-OptimizerXamlMarkup`). Features Cyberpunk dark theme palette (`#0A0C10`, `#00FFCC`, `#FF0055`, `#BD93F9`, `#1F2430`), vector icon geometries, custom scrollbars, and tab styling.
3. **`Gui-Controller.ps1`**: WPF UI controller. Manages window events, hardware detection display, tweak checkboxes, WinGet install/upgrade/uninstall via background Runspaces (`Start-WinGetAsyncAction`), live console logging, and status banners.
4. **`Hardware-Detection.ps1`**: Hardware probing engine. Detects CPU (name, cores, architecture), GPUs (NVIDIA/AMD/Intel, driver versions), active network adapters (Ethernet vs Wi-Fi), RAM, and Windows build. Exports `Get-HardwareProfile`.
5. **`Optimize-SystemAndDebloat.ps1`**: Core Windows debloating and system responsiveness tweaks (telemetry, Cortana/Bing search, GameDVR, Visual Effects, Storage Sense, bloatware AppX removal). Exports `Optimize-SystemAndDebloat`.
6. **`Optimize-KernelAndCpu.ps1`**: Low-latency kernel scheduler, Win32PrioritySeparation (0x26), large system cache, MMCSS game priority, power scheme unlocking (Ultimate Performance). Exports `Optimize-KernelAndCpu`.
7. **`Optimize-InputLatency.ps1`**: USB polling latency tweaks, keyboard response rate, mouse acceleration disable (raw input), game bar presence disable. Exports `Optimize-InputLatency`.
8. **`Optimize-Network.ps1`**: TCP autotuning (`normal`), CTCP/BBR congestion provider, RSS, RSC, Netsh optimizations, DNS flushing. Exports `Optimize-Network`.
9. **`Toggle-WifiScan.ps1`**: Wi-Fi background roaming/scanning toggle (`autoconfig=disabled`) to eliminate periodic gaming ping spikes. Exports `Toggle-WifiScan`.
10. **`Optimize-NvidiaGpu.ps1`**: NVIDIA-specific GPU optimizations (MSI mode, low latency, pre-rendered frames, shader cache). Exports `Optimize-NvidiaGpu`.
11. **`Optimize-AmdGpu.ps1`**: AMD Radeon-specific GPU optimizations (Anti-Lag, Chill disable, shader cache). Exports `Optimize-AmdGpu`.
12. **`Optimize-GpuAuto.ps1`**: Automatic GPU dispatcher that detects hardware and invokes appropriate vendor tweaks. Exports `Optimize-GpuAuto`.
13. **`Optimize-Hardening.ps1`**: Windows Defender enhancements, Network Protection, Cloud-delivered protection, PUA blocking, Attack Surface Reduction (ASR) rules. Exports `Optimize-Hardening`.
14. **`Match-Booster.ps1`**: Match Booster routine that closes background resource hogs, flushes standby memory list via `EmptyStandbyList.exe`, suppresses Wi-Fi scanning, and prioritizes gaming processes. Exports `Invoke-MatchBooster`.
15. **`System-DiagnosticsAndRestore.ps1`**: System Restore point creation, DISM health restore, SFC scannow, and full symmetrical `Restore-Defaults`. Exports `New-SystemRestorePointSafe`, `Repair-SystemHealth`, and `Restore-Defaults`.

---

## 2. Key Commands & Verification

### Running the Suite
- **Launch GUI (Default, Elevated)**:
  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\optimizer.ps1
  ```
- **Launch Interactive CLI Menu**:
  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\optimizer.ps1 -CLI
  ```
- **One-Line Remote Launch (GitHub Web Stream)**:
  ```powershell
  irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex
  ```
- **Direct Standalone Module Execution**:
  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\modules\Match-Booster.ps1
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\modules\Toggle-WifiScan.ps1
  ```

### AST Syntax Verification (Mandatory before every commit)
Execute AST parsing across all scripts to verify zero parser errors:
```powershell
Get-ChildItem -Recurse -Filter *.ps1 | ForEach-Object {
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$errors)
    if ($errors) {
        Write-Error "$($_.Name): $($errors.Count) errors"
    } else {
        Write-Host "$($_.Name): OK" -ForegroundColor Green
    }
}
```

### Application Catalog Integrity Verification
Verify that the WinGet catalog loads and formats correctly:
```powershell
& {
    . .\modules\App-Catalog.ps1
    $apps = Get-AppCatalog
    $cats = Get-AppCatalogCategories
    Write-Host "Catalog: $($apps.Count) apps across $($cats.Count) categories" -ForegroundColor Green
}
```

### XAML Markup Verification
Verify that the WPF XAML parser accepts the UI definition:
```powershell
& {
    Add-Type -AssemblyName PresentationFramework
    . .\modules\Gui-Markup.ps1
    $xaml = Get-OptimizerXamlMarkup
    [System.Windows.Markup.XamlReader]::Parse($xaml) | Out-Null
    Write-Host "XAML Markup Validated Successfully" -ForegroundColor Green
}
```

---

## 3. Development Guidelines

### Adding a New System Tweak
1. Identify the appropriate module under `modules/` (e.g., `Optimize-SystemAndDebloat.ps1` or `Optimize-Network.ps1`).
2. Write the tweak function using idempotent registry/service modifications. Always wrap volatile calls in `try { ... } catch { ... }`.
3. **MANDATORY**: Add the exact inverse operation into `Restore-Defaults` in `modules/System-DiagnosticsAndRestore.ps1`.
4. If exposing the tweak in the GUI, add the control in `modules/Gui-Markup.ps1` and wire the event handler in `modules/Gui-Controller.ps1`.
5. Test using AST parsing and dry-run execution.

### Adding an Application to the WinGet Catalog
1. Verify the official WinGet package ID using `winget search <App>`.
2. Add the entry to `$AppCatalog` in `modules/App-Catalog.ps1` following the schema:
   ```powershell
   [PSCustomObject]@{
       Id          = "Vendor.PackageName"
       Name        = "Display Name"
       Category    = "Category Name"
       Description = "Concise description of the software"
       Selected    = $false
   }
   ```
3. Ensure `Category` matches one of the 10 standard categories in `Get-AppCatalogCategories`.

### WPF / XAML & Thread Safety
- **Background Operations**: Never perform long-running operations (like `winget install`, DISM, or SFC) on the UI dispatcher thread. Use background Runspaces (`Start-WinGetAsyncAction`) or Jobs.
- **Dispatcher Invocations**: Never touch WPF controls directly from background threads. Always dispatch to the UI thread:
  ```powershell
  $sync.Window.Dispatcher.Invoke([action]{
      $sync.LogBox.AppendText("$message`r`n")
      $sync.LogBox.ScrollToEnd()
  })
  ```
- **Styling Consistency**: Retain the Cyberpunk dark aesthetic (`#0A0C10` background, `#00FFCC` neon cyan highlights, `#FF0055` accent pink, `#BD93F9` purple, `#1F2430` surface cards).

---

## 4. Runtime & Safety Rules

- **Elevation Check**: Any script or module that modifies system state must verify administrator privileges and elevate if necessary.
- **System Restore Points**: Always offer or trigger `New-SystemRestorePointSafe` before executing aggressive system modifications.
- **Protected Services**: NEVER disable critical operating system services (RPC, PlugPlay, CryptSvc, DnsCache, Dhcp, EventLog, Winmgmt).
- **Idempotency**: All registry tweaks must check for key existence with `Test-Path` and create parents via `New-Item -Force` if missing. Tweaks must be safe to run multiple times without causing errors.
- **Log Streaming**: Write timestamped output to both the console and the in-app log box so users have complete transparency on what changed.

---

## 5. Git Hygiene, Versioning & Release Control

### Commit Standards
- Use Conventional Commits formatting:
  - `feat:` New features, tweaks, or application catalog additions
  - `fix:` Bug fixes, syntax corrections, or rollback repairs
  - `refactor:` Code modularization and performance improvements
  - `docs:` Documentation updates in `README.md` or `agents.md`
  - `test:` Test scripts and AST validation checks
- Run the full AST parser validation across all `.ps1` files before staging or committing.
- Do not commit scratch scripts or local debug outputs.

### Mandatory Version Bumping on Every Update / Commit
Whenever updating features, fixing bugs, or preparing a commit, the version number MUST be bumped and synchronized so releases are easy to find, track, and control:
1. **Semantic Versioning (SemVer) Rules**:
   - **`PATCH` (e.g. `v5.0.0` -> `v5.0.1`)**: Small bug fixes, registry value corrections, rollback repairs, or app catalog updates.
   - **`MINOR` (e.g. `v5.0.x` -> `v5.1.0`)**: New optimization features, new modules, new GUI tabs/cards, external tool integrations, or new CLI menu items.
   - **`MAJOR` (e.g. `v5.x.x` -> `v6.0.0`)**: Breaking architectural changes, major framework rewrites, or fundamental overhaul.
2. **Synchronized Files Checklist**:
   Every version bump must be updated in unison across:
   - **`optimizer.ps1`**: `$Host.UI.RawUI.WindowTitle` and `Show-PumpkiNBanner` ASCII banner.
   - **`modules/Gui-Markup.ps1`**: Window `Title="..."` and the Top Bar Cyberpunk Header version badge (`<TextBlock Text="vX.Y.Z" .../>`).
   - **`README.md`**: Top title heading, ASCII UI preview box, and CLI menu overview header.
   - **`agents.md`**: Document header and operating contract version.
   - **Git Commit Message**: Include the new version in the commit scope or title (e.g., `feat(v5.1.0): add TrafficMonitor and compact metrics`).

---

## 6. Project Learnings & Gotchas

1. **Non-ASCII Characters Break PowerShell 5.1 AST Parser**: Non-ASCII characters (such as Unicode em dashes `--`, curly quotes, or fancy symbols) encoded without UTF-8 BOM cause byte-level truncation in Windows PowerShell 5.1 string literals, triggering fatal parser errors. All scripts must remain strictly ASCII or UTF-8 with standard ASCII hyphens `--`.
2. **Regex.Replace Substitution Danger with `$`**: In .NET `[regex]::Replace()`, `$` characters inside the replacement string are evaluated as regex substitution tokens (`$'`, `$&`). When modifying code containing PowerShell variables (`$var`), use substring concatenation or scriptblock match evaluators: `[regex]::Replace($str, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ ... })`.
3. **Dual Invocation Pattern for Standalone Modules**: Modules in `modules/` must check `$MyInvocation.InvocationName -ne '.'` so they export functions when dot-sourced into `optimizer.ps1`, but execute standalone with elevation check when invoked directly.
4. **Asynchronous WinGet Execution**: Running `winget` synchronously on the WPF UI thread freezes the window. Always execute package manager commands through background Runspaces and stream stdout/stderr back via `Dispatcher.Invoke`.
5. **Portable GitHub Raw Web Loader**: `optimizer.ps1` supports both local module dot-sourcing and remote raw GitHub streaming fallback, enabling single-command execution via `irm ... | iex` for users without git cloned locally.