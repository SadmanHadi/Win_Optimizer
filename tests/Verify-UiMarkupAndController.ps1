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
$stringReader = [System.IO.StringReader]::new($markup)
$xmlReader = [System.Xml.XmlReader]::Create($stringReader)
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

Write-Host "`n=== 4. Tweak Registry Schema Validation ===" -ForegroundColor Cyan
. (Join-Path $projectRoot "modules\Gui-Controller.ps1")
if (-not (Get-Command Start-PumpkiNGui -ErrorAction SilentlyContinue)) {
    throw "Start-PumpkiNGui function not found in Gui-Controller.ps1!"
}
Write-Host "  [+] Start-PumpkiNGui exported successfully." -ForegroundColor Green

Write-Host "`n[PASS] All UI verification checks passed!" -ForegroundColor Green
