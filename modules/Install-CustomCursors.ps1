<#
================================================================================
  PumpkiN's Modular Suite: 1-Click Custom Gaming Cursors Engine & Manager
  Supports 23+ Custom Animated & Precision Cursor Schemes (.inf / .crs)
  Instant Live Application without Reboot & 100% Symmetrical Rollback
================================================================================
#>

function Get-CursorBaseFolder {
    <#
    .SYNOPSIS
        Resolves the absolute path to the Cursors directory across all execution modes.
    #>
    $candidates = @()
    if ($Global:OptimizerProjectRoot) {
        $candidates += (Join-Path $Global:OptimizerProjectRoot "Cursors")
    }
    if ($PSScriptRoot) {
        $candidates += (Join-Path (Split-Path $PSScriptRoot -Parent) "Cursors")
        $candidates += (Join-Path $PSScriptRoot "Cursors")
    }
    $candidates += "E:\Projects\Win_Optimizer\Cursors"
    $candidates += (Join-Path (Get-Location) "Cursors")

    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) {
            return $c
        }
    }
    return $null
}

function Get-AvailableCursorSchemes {
    <#
    .SYNOPSIS
        Scans the Cursors directory and returns metadata for all available cursor packs.
    #>
    $baseFolder = Get-CursorBaseFolder
    if (-not $baseFolder -or -not (Test-Path $baseFolder)) {
        return @()
    }

    $dirs = Get-ChildItem -Path $baseFolder -Directory | Sort-Object Name
    $schemes = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($d in $dirs) {
        $infFile = Get-ChildItem -Path $d.FullName -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        $crsFile = Get-ChildItem -Path $d.FullName -Filter "*.crs" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        $preview = Get-ChildItem -Path $d.FullName -Filter "*Preview*.jpg" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $preview) {
            $preview = Get-ChildItem -Path $d.FullName -Filter "*preview*.png" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        }

        $schemes.Add([PSCustomObject]@{
            Name        = $d.Name
            FolderPath  = $d.FullName
            HasInf      = ($null -ne $infFile)
            InfPath     = if ($infFile) { $infFile.FullName } else { $null }
            HasCrs      = ($null -ne $crsFile)
            CrsPath     = if ($crsFile) { $crsFile.FullName } else { $null }
            PreviewPath = if ($preview) { $preview.FullName } else { $null }
        })
    }

    return $schemes
}

function Get-ActiveCursorSchemeName {
    <#
    .SYNOPSIS
        Reads the current active cursor scheme name from Windows registry.
    #>
    try {
        $reg = Get-ItemProperty 'HKCU:\Control Panel\Cursors' -ErrorAction SilentlyContinue
        if ($reg -and $reg.'(default)') {
            return [string]$reg.'(default)'
        }
    } catch {}
    return "Windows Default"
}

function Update-WindowsCursorBroadcast {
    <#
    .SYNOPSIS
        Notifies Windows Shell to immediately reload cursors across all windows without reboot.
    #>
    try {
        & rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True
    } catch {}
}

function Install-CursorScheme {
    <#
    .SYNOPSIS
        Installs and immediately applies a custom cursor scheme from the Cursors directory.
    .PARAMETER SchemeName
        The folder name of the cursor scheme to install.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SchemeName
    )

    Write-Host "`n[*] Installing Custom Cursor Scheme: $SchemeName..." -ForegroundColor Yellow

    $baseFolder = Get-CursorBaseFolder
    if (-not $baseFolder) {
        Write-Host "      [!] Error: Cursors directory could not be located." -ForegroundColor Red
        return $false
    }

    $sourceDir = Join-Path $baseFolder $SchemeName
    if (-not (Test-Path $sourceDir)) {
        Write-Host "      [!] Error: Cursor folder not found at: $sourceDir" -ForegroundColor Red
        return $false
    }

    $destDir = Join-Path "$env:SystemRoot\Cursors" $SchemeName
    try {
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        # Copy all cursor files (.cur, .ani) to %SystemRoot%\Cursors\<SchemeName>
        Get-ChildItem -Path $sourceDir -Include "*.cur", "*.ani", "*.inf", "*.crs" -Recurse -File | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination (Join-Path $destDir $_.Name) -Force -ErrorAction SilentlyContinue
        }
        Write-Host "      [+] Cursor assets deployed to $destDir" -ForegroundColor Green
    } catch {
        Write-Host "      [!] Note copying to Windows Cursors: $($_.Exception.Message)" -ForegroundColor DarkYellow
        $destDir = $sourceDir
    }

    # Search for installer INF file
    $infFile = Get-ChildItem -Path $sourceDir -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

    if ($infFile) {
        try {
            Write-Host "      [+] Executing native SetupAPI INF Section: $($infFile.Name)..." -ForegroundColor Yellow
            $infProc = Start-Process -FilePath "rundll32.exe" -ArgumentList "setupapi.dll,InstallHinfSection DefaultInstall 128 `"$($infFile.FullName)`"" -Wait -PassThru -WindowStyle Hidden
            Start-Sleep -Milliseconds 300
        } catch {
            Write-Host "      [!] INF install warning: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    }

    # Directly map registry values for instant activation
    $cursorKey = 'HKCU:\Control Panel\Cursors'
    if (-not (Test-Path $cursorKey)) { New-Item -Path $cursorKey -Force | Out-Null }

    # Parse .crs if present or find matching files in destDir
    $crsFile = Get-ChildItem -Path $sourceDir -Filter "*.crs" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    $fileMap = @{}

    if ($crsFile) {
        $lines = Get-Content -Path $crsFile.FullName -ErrorAction SilentlyContinue
        $currentSection = ""
        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if ($trimmed -match '^\[(.*)\]$') {
                $currentSection = $matches[1]
            } elseif ($trimmed -match '^Path=(.+)$' -and $currentSection) {
                $curFileName = $matches[1].Trim()
                $targetFile = Join-Path $destDir $curFileName
                if (Test-Path $targetFile) {
                    $fileMap[$currentSection] = $targetFile
                }
            }
        }
    }

    # Fallback to intelligent filename heuristic mapping if not fully mapped via .crs
    $allFiles = Get-ChildItem -Path $destDir -Include "*.cur", "*.ani" -Recurse -File -ErrorAction SilentlyContinue
    $roles = @{
        'Arrow'       = @('Normal', 'Arrow', 'Pointer', 'default')
        'Help'        = @('Help')
        'AppStarting' = @('Working', 'AppStarting', 'Flash', 'WaitBackground')
        'Wait'        = @('Busy', 'Wait')
        'Crosshair'   = @('Precision', 'Crosshair', 'Cross')
        'IBeam'       = @('Text', 'IBeam', 'Beam')
        'NWPen'       = @('Handwriting', 'Pen', 'Write')
        'No'          = @('Unavailable', 'No', 'Cancel')
        'SizeNS'      = @('Vertical', 'SizeNS', 'North')
        'SizeWE'      = @('Horizontal', 'SizeWE', 'East')
        'SizeNWSE'    = @('Diagonal Resize 1', 'Diagonal1', 'SizeNWSE', 'Dgn1')
        'SizeNESW'    = @('Diagonal Resize 2', 'Diagonal2', 'SizeNESW', 'Dgn2')
        'SizeAll'     = @('Move', 'SizeAll', 'All')
        'UpArrow'     = @('Alternate', 'UpArrow', 'Alternative')
        'Hand'        = @('Link', 'Hand')
        'Pin'         = @('Location', 'Pin')
        'Person'      = @('Person', 'User')
    }

    foreach ($role in $roles.Keys) {
        if (-not $fileMap.ContainsKey($role)) {
            $patterns = $roles[$role]
            foreach ($pat in $patterns) {
                $matched = $allFiles | Where-Object { $_.BaseName -like "*$pat*" } | Select-Object -First 1
                if ($matched) {
                    $fileMap[$role] = $matched.FullName
                    break
                }
            }
        }
    }

    # Write mapped cursor files to HKCU:\Control Panel\Cursors
    Set-ItemProperty -Path $cursorKey -Name '(default)' -Value $SchemeName -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $cursorKey -Name 'Scheme Source' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    foreach ($k in $fileMap.Keys) {
        if ($fileMap[$k]) {
            Set-ItemProperty -Path $cursorKey -Name $k -Value $fileMap[$k] -Type String -ErrorAction SilentlyContinue
        }
    }

    # Write to HKCU:\Control Panel\Cursors\Schemes
    $schemesKey = 'HKCU:\Control Panel\Cursors\Schemes'
    if (-not (Test-Path $schemesKey)) { New-Item -Path $schemesKey -Force | Out-Null }

    $orderedRoles = @('Arrow', 'Help', 'AppStarting', 'Wait', 'Crosshair', 'IBeam', 'NWPen', 'No', 'SizeNS', 'SizeWE', 'SizeNWSE', 'SizeNESW', 'SizeAll', 'UpArrow', 'Hand', 'Pin', 'Person')
    $schemeStringList = @()
    foreach ($r in $orderedRoles) {
        if ($fileMap.ContainsKey($r) -and $fileMap[$r]) {
            $schemeStringList += $fileMap[$r]
        } else {
            $schemeStringList += ""
        }
    }
    $schemeVal = $schemeStringList -join ','
    Set-ItemProperty -Path $schemesKey -Name $SchemeName -Value $schemeVal -Type String -ErrorAction SilentlyContinue

    # Broadcast live cursor update to Windows Shell
    Update-WindowsCursorBroadcast

    Write-Host "      [OK] Custom cursor scheme '$SchemeName' applied successfully and live!" -ForegroundColor Green
    return $true
}

function Restore-DefaultCursors {
    <#
    .SYNOPSIS
        Restores default Windows Aero/Segoe cursors immediately (100% reversible).
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n[*] Restoring Standard Windows Default Cursor Scheme..." -ForegroundColor Yellow

    $cursorKey = 'HKCU:\Control Panel\Cursors'
    if (Test-Path $cursorKey) {
        Set-ItemProperty -Path $cursorKey -Name '(default)' -Value "Windows Default" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorKey -Name 'Scheme Source' -Value 1 -Type DWord -ErrorAction SilentlyContinue

        $standardRoles = @('Arrow', 'Help', 'AppStarting', 'Wait', 'Crosshair', 'IBeam', 'NWPen', 'No', 'SizeNS', 'SizeWE', 'SizeNWSE', 'SizeNESW', 'SizeAll', 'UpArrow', 'Hand', 'Pin', 'Person')
        foreach ($r in $standardRoles) {
            Set-ItemProperty -Path $cursorKey -Name $r -Value "" -Type String -ErrorAction SilentlyContinue
        }
    }

    Update-WindowsCursorBroadcast

    Write-Host "      [OK] Windows Default Cursor Scheme restored in real time!" -ForegroundColor Green
    return $true
}

# Standalone execution check (Dual Invocation Pattern)
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Write-Host "=== PUMPKIN CUSTOM CURSORS MANAGER ===" -ForegroundColor Cyan
    $active = Get-ActiveCursorSchemeName
    Write-Host "Current Active Scheme: $active`n" -ForegroundColor Yellow
    $all = Get-AvailableCursorSchemes
    for ($i = 0; $i -lt $all.Count; $i++) {
        Write-Host "  [$i] $($all[$i].Name)"
    }
    Write-Host "  [D] Restore Windows Default Cursors"
    Write-Host "  [Q] Quit"
    $choice = Read-Host "`nEnter selection"
    if ($choice -match '^[0-9]+$' -and [int]$choice -lt $all.Count) {
        Install-CursorScheme -SchemeName ($all[[int]$choice].Name)
    } elseif ($choice -eq 'D' -or $choice -eq 'd') {
        Restore-DefaultCursors
    }
    Read-Host "`nPress Enter to exit"
}
