# Windows 11 Fluent + Cyberpunk UI Overhaul Implementation Plan (v5.6.0)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Overhaul the Win_Optimizer WPF UI into a modern Windows 11 Fluent + Cyberpunk Dark desktop interface featuring a collapsible left navigation rail, instant search, a collapsible bottom drawer, individual live audit toggle switches (`[● ON]` / `[○ OFF]`), and sequential step-by-step master activation.

**Architecture:** Refactor `modules/Gui-Markup.ps1` to supply a clean modern shell with reusable Fluent control templates (including custom `ToggleButton` and card styles) and a collapsible bottom drawer. In `modules/Gui-Controller.ps1`, consolidate all 82 tweaks into a unified metadata catalog, dynamically instantiate tweak cards, bind live state from `Get-SystemAuditState`, and handle single-tweak and sequential step-by-step activations.

**Tech Stack:** Windows PowerShell 5.1 & PowerShell 7+, Windows Presentation Foundation (WPF / XAML), .NET Framework 4.8 / .NET Core CIM/WMI, WinGet.

**Spec:** [`docs/superpowers/specs/2026-10-21-fluent-cyberpunk-ui-redesign.md`](file:///E:/Projects/Win_Optimizer/docs/superpowers/specs/2026-10-21-fluent-cyberpunk-ui-redesign.md)

## Global Constraints

- **Strict 100% Reversibility**: Every tweak toggle must have an exact symmetrical inverse rollback.
- **Zero Third-Party Binaries**: Pure native Windows PowerShell, WPF, Registry, DISM, and WinGet only (`EmptyStandbyList.exe` is the only external binary).
- **PowerShell 5.1 & 7+ Compatibility**: No PowerShell 7-only syntax (`?:`, `??`, `&&`, `||`).
- **Strict ASCII / UTF-8 without BOM Safety**: No non-ASCII typographic characters in `.ps1` code.
- **Modular Separation**: Master orchestrator `optimizer.ps1` remains clean; UI changes reside in `modules/Gui-Markup.ps1` and `modules/Gui-Controller.ps1`.
- **Version Bumping & Synchronization**: Synchronously update version from v5.5.0 to v5.6.0 across `optimizer.ps1`, `modules/Gui-Markup.ps1`, `README.md`, and `agents.md`.

## Review Focus

1. **WPF Dispatcher Thread Deadlocks**: Executing system tweaks directly on the UI dispatcher thread freezes the window; ensure all actions use `$window.Dispatcher.Invoke` and proper UI pump cycles.
2. **Missing Registry Paths on Clean Windows Installs**: Probing keys that do not exist yet must default safely to `$false` without throwing unhandled exceptions.
3. **Toggle Switch State Desynchronization**: If a tweak fails to apply, the toggle switch must not flip to `ON`; it must revert to `OFF` and log an informative warning.
4. **Window Resizing / High-DPI Layout Clipping**: Squeezed controls on 125%/150% display scaling; ensure layout uses responsive Grids, ScrollViewers, and WrapPanels.
5. **AST Parsing Truncation in PowerShell 5.1**: Non-ASCII characters in XAML or script strings causing byte truncation; maintain strict ASCII encoding.

---

### Task 1: Create the Test Verification Harness

**Files:**
- Create: `tests/Verify-UiMarkupAndController.ps1`

**Interfaces:**
- Consumes: `modules/Gui-Markup.ps1`, `modules/Gui-Controller.ps1`, `modules/System-DiagnosticsAndRestore.ps1`
- Produces: Automated verification suite returning exit code 0 on pass or 1 on failure.

- [ ] **Step 1: Write the test harness script `tests/Verify-UiMarkupAndController.ps1`**

```powershell
# tests/Verify-UiMarkupAndController.ps1
param()
$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "=== 1. AST Parser Syntax Validation ===" -ForegroundColor Cyan
$psFiles = Get-ChildItem -Path (Join-Path $projectRoot "modules") -Filter "*.ps1"
$hasAstErrors = $false
foreach ($f in $psFiles) {
    $errs = $null
    [System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$errs)
    if ($errs -and $errs.Count -gt 0) {
        Write-Host "[-] $($f.Name): $($errs.Count) syntax errors!" -ForegroundColor Red
        $hasAstErrors = $true
    } else {
        Write-Host "  [+] $($f.Name): OK" -ForegroundColor Green
    }
}
if ($hasAstErrors) { throw "AST Syntax Verification failed!" }

Write-Host "`n=== 2. WPF XAML Schema Validation ===" -ForegroundColor Cyan
Add-Type -AssemblyName PresentationFramework
. (Join-Path $projectRoot "modules\Gui-Markup.ps1")
$markup = Get-OptimizerXamlMarkup
if (-not $markup) { throw "Get-OptimizerXamlMarkup returned null or empty string!" }
$xmlReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($markup))
$window = [System.Windows.Markup.XamlReader]::Load($xmlReader)
if (-not $window) { throw "XamlReader failed to load Window object!" }
Write-Host "  [+] XAML Markup parsed and loaded successfully into WPF Window!" -ForegroundColor Green

Write-Host "`n=== 3. Audit State & Tweak Catalog Alignment ===" -ForegroundColor Cyan
. (Join-Path $projectRoot "modules\System-DiagnosticsAndRestore.ps1")
$audit = Get-SystemAuditState
if (-not $audit.State -or $audit.State.Keys.Count -lt 50) {
    throw "Get-SystemAuditState returned invalid or incomplete state map!"
}
Write-Host "  [+] Audit Engine active: $($audit.State.Keys.Count) audit keys probed." -ForegroundColor Green
Write-Host "`n[PASS] All UI verification checks passed!" -ForegroundColor Green
```

- [ ] **Step 2: Run test harness to establish baseline**

Run: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Verify-UiMarkupAndController.ps1`  
Expected: PASS on existing codebase.

- [ ] **Step 3: Commit test harness**

```bash
git add tests/Verify-UiMarkupAndController.ps1
git commit -m "test: add automated UI markup and controller verification harness"
```

---

### Task 2: Implement Modern Fluent Cyberpunk XAML in `modules/Gui-Markup.ps1`

**Files:**
- Modify: `modules/Gui-Markup.ps1`
- Test: `tests/Verify-UiMarkupAndController.ps1`

**Interfaces:**
- Consumes: None (pure XAML markup string provider)
- Produces: `Get-OptimizerXamlMarkup` exporting the complete Windows 11 Fluent + Cyberpunk WPF XAML markup.

- [ ] **Step 1: Write the failing / validating test step**

Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Verify-UiMarkupAndController.ps1` to verify current state.

- [ ] **Step 2: Implement modern XAML markup in `modules/Gui-Markup.ps1`**

Restructure `$Global:xamlContent` in `modules/Gui-Markup.ps1`:
1. **Window Definition**: Base 1240x820, `Background="#0A0E17"`, `WindowStartupLocation="CenterScreen"`.
2. **Resource Styles & Control Templates**:
   - `FluentToggleSwitch`: Custom `Style TargetType="ToggleButton"` with rounded pill container (`CornerRadius="10"`, Width 48, Height 22), animated sliding thumb ellipse, and label text (`[● ON]` / `[○ OFF]`). Triggers handle `IsChecked="True"` (`Background="#00FF88"`, thumb moves right) vs `IsChecked="False"` (`Background="#1F293D"`, thumb on left).
   - `NavRadioButton`: Sidebar navigation item with hover glow, icon + label layout, and active cyan indicator line.
   - `PresetChip`: Pill-shaped filter button (`CornerRadius="12"`, hover border `#00D2FF`).
   - `FluentCard`: Dark card container (`Background="#121824"`, `BorderBrush="#1F293D"`, `CornerRadius="6"`).
3. **Master Window Layout**:
   - `RowDefinition Height="Auto"`: Top App Bar.
   - `RowDefinition Height="*"`: Split into `Column 0 (Sidebar, Width="220")` and `Column 1 (Page Content Host, Width="*")`.
   - `RowDefinition Height="Auto"`: Collapsible Bottom Log Drawer (animated or toggled via row height).
4. **Top App Bar**:
   - App Icon + "PUMPKIN" + "ULTIMATE OPTIMIZER" + "v5.6.0" badge.
   - Instant Search Box `TxtSearch` with watermark text.
   - Quick action buttons: `BtnRestorePointTop`, `BtnMasActivateTop`, `BtnExitTop`.
5. **Left Navigation Rail (`Grid.Column="0"`)**:
   - Stack of `RadioButton` elements: `NavDashboard`, `NavGaming`, `NavPrivacy`, `NavSystem`, `NavSoftware`, `NavDevice`.
   - Bottom sidebar version & system status text.
6. **Page Views Container (`Grid.Column="1"`)**:
   - Page 1: `PageDashboard` (Radial Gauge, Quick stats, Preset quick launchers).
   - Page 2: `PageGaming` (Preset filter bar, Master Action bar, `PanelGamingTweaks` scrollable container).
   - Page 3: `PagePrivacy` (Preset filter bar, Master Action bar, `PanelPrivacyTweaks` scrollable container).
   - Page 4: `PageSystem` (Preset filter bar, Master Action bar, `PanelSystemTweaks` scrollable container).
   - Page 5: `PageSoftware` (Category chips, `WrapPackages`, App action sidebar).
   - Page 6: `PageDevice` (Hardware specs cards, copy buttons).
7. **Collapsible Bottom Drawer**:
   - Slim status strip (`TxtStatusSummary`, `BtnToggleLogDrawer`).
   - Collapsible panel containing `TxtConsole` and `MainProgressBar`.

- [ ] **Step 3: Run verification harness to verify XAML parses and loads without errors**

Run: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Verify-UiMarkupAndController.ps1`  
Expected: PASS (AST parse clean, XAML load clean).

- [ ] **Step 4: Commit `modules/Gui-Markup.ps1`**

```bash
git add modules/Gui-Markup.ps1
git commit -m "feat(ui): implement modern Windows 11 Fluent Cyberpunk XAML with navigation rail and toggle switches"
```

---

### Task 3: Implement Unified Tweak Catalog & Dynamic Card Factory in `modules/Gui-Controller.ps1`

**Files:**
- Modify: `modules/Gui-Controller.ps1`
- Test: `tests/Verify-UiMarkupAndController.ps1`

**Interfaces:**
- Consumes: `Get-SystemAuditState` from `modules/System-DiagnosticsAndRestore.ps1`, XAML elements from `modules/Gui-Markup.ps1`
- Produces: Dynamically generated tweak cards with live audit state binding and single-tweak toggle event listeners.

- [ ] **Step 1: Define the Unified Tweak Catalog in `modules/Gui-Controller.ps1`**

Consolidate all 82 tweaks into `$script:TweakDefinitions` with metadata:
- `Key`: Matching key from `Get-SystemAuditState`.
- `Title`: User-facing title.
- `Description`: Clear 1-2 sentence description.
- `Category`: `Gaming`, `Privacy`, `System`.
- `Tier`: `Recommended`, `Safe`, `Esports`.
- `Apply`: Exact cmdlet scriptblock.
- `Rollback`: Exact rollback cmdlet scriptblock.

- [ ] **Step 2: Implement Dynamic Card Factory `New-TweakCardElement`**

Write a lightweight builder function in `modules/Gui-Controller.ps1`:
```powershell
function New-TweakCardElement {
    param([hashtable]$Tweak, [hashtable]$AuditState)
    # Builds Border with Grid:
    # Left: Title, Tier Badge (Recommended/Esports), Description
    # Right: ToggleButton (Style={StaticResource FluentToggleSwitch})
    # Binds IsChecked to ($AuditState.State[$Tweak.Key] -eq $true)
    # Adds Click event handler for single-tweak apply/rollback
}
```

- [ ] **Step 3: Wire Single-Tweak Toggle Switch Interaction**

Implement the switch event listener:
1. When toggle is checked (`IsChecked = $true`):
   - Invokes `& $Tweak.Apply`.
   - Probes `Get-SystemAuditState` to verify application.
   - Updates status: `[✓] <Title> applied successfully.`
   - Recalculates Optimization Score Gauge.
2. When toggle is unchecked (`IsChecked = $false`):
   - Invokes `& $Tweak.Rollback`.
   - Probes `Get-SystemAuditState` to verify restoration.
   - Updates status: `[↺] <Title> restored to Windows defaults.`
   - Recalculates Optimization Score Gauge.

- [ ] **Step 4: Wire Navigation Rail Page Switching**

Add `Checked` events for `NavDashboard`, `NavGaming`, `NavPrivacy`, `NavSystem`, `NavSoftware`, and `NavDevice` to toggle page container visibility (`Visibility = Visible` vs `Collapsed`).

- [ ] **Step 5: Run verification harness**

Run: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Verify-UiMarkupAndController.ps1`  
Expected: PASS.

- [ ] **Step 6: Commit controller enhancements**

```bash
git add modules/Gui-Controller.ps1
git commit -m "feat(ui): implement dynamic tweak card factory and single-tweak toggle switch handlers"
```

---

### Task 4: Implement Sequential Step-by-Step Execution Engine & Master Controls

**Files:**
- Modify: `modules/Gui-Controller.ps1`
- Test: `tests/Verify-UiMarkupAndController.ps1`

**Interfaces:**
- Consumes: `$script:TweakDefinitions`, `Get-SystemAuditState`
- Produces: Sequential one-by-one execution runner, preset filtering, instant search filtering, and drawer expand/collapse.

- [ ] **Step 1: Implement the Sequential Execution Engine `Invoke-SequentialTweakAction`**

Implement sequential one-by-one runner:
```powershell
function Invoke-SequentialTweakAction {
    param(
        [System.Collections.Generic.List[PSCustomObject]]$Tweaks,
        [string]$Action # "Apply" or "Rollback"
    )
    # Expands bottom drawer if collapsed
    # Steps through each tweak:
    # 1. Highlights card
    # 2. Runs cmdlet
    # 3. Flips toggle switch
    # 4. Updates status bar with [current/total] progress
    # 5. Updates gauge score
}
```

- [ ] **Step 2: Wire Master Action Buttons and Preset Chips**

1. Wire **"Turn All ON"** button to collect all tweaks matching the active preset and invoke `Invoke-SequentialTweakAction -Action "Apply"`.
2. Wire **"Turn All OFF (Defaults)"** button to collect all tweaks matching the active preset and invoke `Invoke-SequentialTweakAction -Action "Rollback"`.
3. Wire preset chips (`All`, `Recommended`, `Esports`, `Active`, `Inactive`) to filter card visibility instantly.

- [ ] **Step 3: Wire Universal Instant Search Bar**

Implement `TxtSearch.Add_TextChanged`:
- When user types text, checks each tweak card's Title and Description against the search query.
- Hides non-matching cards and displays matching cards.
- If in Software Downloader page, filters app cards simultaneously.

- [ ] **Step 4: Wire Collapsible Bottom Drawer Logic**

Implement `BtnToggleLogDrawer.Add_Click`:
- Toggles the bottom row height between 34px (collapsed, showing only slim status bar) and 210px (expanded, showing full `TxtConsole`).
- Automatically expands drawer whenever a multi-tweak sequential action starts.

- [ ] **Step 5: Run verification harness**

Run: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Verify-UiMarkupAndController.ps1`  
Expected: PASS.

- [ ] **Step 6: Commit sequential runner and master controls**

```bash
git add modules/Gui-Controller.ps1
git commit -m "feat(ui): add sequential step-by-step master activation and collapsible log drawer"
```

---

### Task 5: Version Bump to v5.6.0 & Full End-to-End Verification

**Files:**
- Modify: `optimizer.ps1` (Window title, banner v5.6.0)
- Modify: `modules/Gui-Markup.ps1` (Window title, top bar badge v5.6.0)
- Modify: `README.md` (Top header, UI preview, badges v5.6.0)
- Modify: `agents.md` (Contract header v5.6.0)
- Test: `tests/Verify-UiMarkupAndController.ps1`

**Interfaces:**
- Consumes: All modules
- Produces: Verified, production-ready v5.6.0 release candidate.

- [ ] **Step 1: Synchronously bump version to v5.6.0 across all 4 files**

Update version numbers in:
- `optimizer.ps1`: Line 9, Line 34.
- `modules/Gui-Markup.ps1`: Window Title, Top Bar text badge.
- `README.md`: Header line 3, badge line 11, UI preview box line 67.
- `agents.md`: Header line 5.

- [ ] **Step 2: Run AST parse check across the entire repository**

Run:
```powershell
Get-ChildItem -Recurse -Filter *.ps1 | ForEach-Object {
    $e = $null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$e)
    if ($e) { throw "$($_.Name): $($e.Count) errors" }
}
```
Expected: Zero parser errors across all files.

- [ ] **Step 3: Run the complete verification test harness**

Run: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Verify-UiMarkupAndController.ps1`  
Expected: All tests PASS with exit code 0.

- [ ] **Step 4: Final commit and tagging**

```bash
git add optimizer.ps1 modules/Gui-Markup.ps1 README.md agents.md tests/
git commit -m "feat(v5.6.0): deliver Windows 11 Fluent Cyberpunk UI overhaul with live audit toggle switches"
```
