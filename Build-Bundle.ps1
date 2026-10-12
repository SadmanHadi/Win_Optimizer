<#
================================================================================
  PumpkiN's Modular Suite: Production Release Bundler
  Combines orchestrator and all 17 modules into a single, high-performance
  distribution file (dist/optimizer.ps1) for instant local and web streaming.
================================================================================
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "dist/optimizer.ps1"
)

$baseDir = $PSScriptRoot
if (-not $baseDir) { $baseDir = Get-Location }

$orchestratorPath = Join-Path $baseDir "optimizer.ps1"
$modulesDir = Join-Path $baseDir "modules"
$fullOutputPath = Join-Path $baseDir $OutputPath

if (-not (Test-Path $orchestratorPath)) {
    throw "orchestrator not found at: $orchestratorPath"
}

$ModuleList = @(
    "Hardware-Detection",
    "App-Catalog",
    "Gui-Markup",
    "Gui-Controller",
    "Optimize-AmdGpu",
    "Optimize-NvidiaGpu",
    "Optimize-GpuAuto",
    "Optimize-Network",
    "Toggle-WifiScan",
    "Optimize-KernelAndCpu",
    "Optimize-InputLatency",
    "Match-Booster",
    "Optimize-Hardening",
    "Optimize-SystemAndDebloat",
    "Optimize-Windows11AndShell",
    "Optimize-PrivacyAndTelemetry",
    "System-DiagnosticsAndRestore"
)

Write-Host "[*] Building PumpkiN Optimizer standalone production bundle..." -ForegroundColor Cyan

$orchContent = Get-Content -Path $orchestratorPath -Raw

# Locate Section 2 in optimizer.ps1
$sec2Header = "# 2. MODULAR LOADER ENGINE"
$sec3Header = "# 3. CONSOLE BANNER & INTERACTIVE CLI MENU"

$sec2Index = $orchContent.IndexOf($sec2Header)
if ($sec2Index -lt 0) {
    throw "Could not locate Section 2 in optimizer.ps1"
}

# Find the start of the section 2 divider
$sec2Start = $orchContent.LastIndexOf("# ==============================================================================", $sec2Index)

$sec3Index = $orchContent.IndexOf($sec3Header)
if ($sec3Index -lt 0) {
    throw "Could not locate Section 3 in optimizer.ps1"
}
$sec3Start = $orchContent.LastIndexOf("# ==============================================================================", $sec3Index)

$part1 = $orchContent.Substring(0, $sec2Start)
$part3 = $orchContent.Substring($sec3Start)

# Build bundled modules content
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# ==============================================================================")
[void]$sb.AppendLine("# 2. EMBEDDED ENGINE MODULES (ALL-IN-ONE STANDALONE BUNDLE)")
[void]$sb.AppendLine("# ==============================================================================")
[void]$sb.AppendLine('$Script:IsBundled = $true')
[void]$sb.AppendLine()

foreach ($modName in $ModuleList) {
    $modFile = Join-Path $modulesDir "$modName.ps1"
    if (-not (Test-Path $modFile)) {
        throw "Module file not found: $modFile"
    }

    Write-Host "  -> Bundling module: $modName" -ForegroundColor Gray
    $modRaw = Get-Content -Path $modFile -Raw

    # Guard standalone invocation blocks so they do not execute during bundle import
    $modGuarded = $modRaw.Replace(
        "if (`$MyInvocation.InvocationName -ne '.')",
        "if (-not `$Script:IsBundled -and `$MyInvocation.InvocationName -ne '.')"
    )

    [void]$sb.AppendLine("# ------------------------------------------------------------------------------")
    [void]$sb.AppendLine("# MODULE: $modName")
    [void]$sb.AppendLine("# ------------------------------------------------------------------------------")
    [void]$sb.AppendLine($modGuarded)
    [void]$sb.AppendLine()
}

$finalContent = $part1 + $sb.ToString() + $part3

$outDir = Split-Path $fullOutputPath -Parent
if (-not (Test-Path $outDir)) {
    [void](New-Item -ItemType Directory -Path $outDir -Force)
}

# Write output as ASCII/UTF-8 without BOM
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($fullOutputPath, $finalContent, $utf8NoBom)

Write-Host "[+] Bundle created successfully at: $fullOutputPath" -ForegroundColor Green

# Validate AST
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($fullOutputPath, [ref]$null, [ref]$errors)
if ($errors) {
    Write-Error "Bundle AST Parser failed with $($errors.Count) errors!"
    foreach ($err in $errors) {
        Write-Error "  Line $($err.Extent.StartLineNumber): $($err.Message)"
    }
} else {
    $sizeKb = [math]::Round(((Get-Item $fullOutputPath).Length / 1KB), 1)
    Write-Host "[+] AST Parser validation PASSED! Bundle size: $sizeKb KB" -ForegroundColor Green
}
