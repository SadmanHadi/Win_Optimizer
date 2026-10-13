<#
================================================================================
  PumpkiN's Modular Suite: Advanced Privacy, App Telemetry & System Services
================================================================================
#>

# 1. Third-Party App Telemetry Disabler (Edge, Chrome, Firefox, VS, Nvidia)
function Disable-AppTelemetry {
    Write-Host "`n[*] Disabling Browser, IDE & Driver Telemetry (Edge, Chrome, Firefox, VS, Nvidia)..." -ForegroundColor Yellow

    # Microsoft Edge Telemetry
    $edgeKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
    if (-not (Test-Path $edgeKey)) { New-Item -Path $edgeKey -Force | Out-Null }
    Set-ItemProperty -Path $edgeKey -Name 'MetricsReportingEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $edgeKey -Name 'SendDoNotTrack' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $edgeKey -Name 'PersonalizationReportingEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    # Google Chrome Telemetry
    $chromeKey = 'HKLM:\SOFTWARE\Policies\Google\Chrome'
    if (-not (Test-Path $chromeKey)) { New-Item -Path $chromeKey -Force | Out-Null }
    Set-ItemProperty -Path $chromeKey -Name 'MetricsReportingEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $chromeKey -Name 'SendingDataUsageReports' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    # Mozilla Firefox Telemetry
    $ffKey = 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox'
    if (-not (Test-Path $ffKey)) { New-Item -Path $ffKey -Force | Out-Null }
    Set-ItemProperty -Path $ffKey -Name 'DisableTelemetry' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    # Visual Studio Telemetry
    $vsLM = 'HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Telemetry'
    $vsCU = 'HKCU:\Software\Microsoft\VisualStudio\Telemetry'
    if (-not (Test-Path $vsLM)) { New-Item -Path $vsLM -Force | Out-Null }
    if (-not (Test-Path $vsCU)) { New-Item -Path $vsCU -Force | Out-Null }
    Set-ItemProperty -Path $vsLM -Name 'TurnOffSwitch' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $vsCU -Name 'TurnOffSwitch' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    # Nvidia Driver Telemetry Tasks
    $nvTasks = @('NvTmMon', 'NvTmRep', 'NvTmRepOnLogon')
    foreach ($nt in $nvTasks) {
        Disable-ScheduledTask -TaskName $nt -ErrorAction SilentlyContinue | Out-Null
    }

    Write-Host "      [+] Edge, Chrome, Firefox, VS, and Nvidia telemetry blocked system-wide!" -ForegroundColor Green
}

function Restore-AppTelemetry {
    Write-Host "`n[*] Restoring Browser, IDE & Driver Telemetry Defaults..." -ForegroundColor Yellow
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'MetricsReportingEnabled' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Name 'MetricsReportingEnabled' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' -Name 'DisableTelemetry' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Telemetry' -Name 'TurnOffSwitch' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\VisualStudio\Telemetry' -Name 'TurnOffSwitch' -ErrorAction SilentlyContinue

    $nvTasks = @('NvTmMon', 'NvTmRep', 'NvTmRepOnLogon')
    foreach ($nt in $nvTasks) {
        Enable-ScheduledTask -TaskName $nt -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Host "      [+] Browser, IDE and Driver telemetry settings restored." -ForegroundColor Green
}

# 2. Bluetooth Advertising Disabler
function Disable-BluetoothAdvertising {
    Write-Host "`n[*] Disabling Bluetooth Advertising & Discovery Broadcasts..." -ForegroundColor Yellow
    $btKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Bluetooth'
    if (-not (Test-Path $btKey)) { New-Item -Path $btKey -Force | Out-Null }
    Set-ItemProperty -Path $btKey -Name 'AllowAdvertising' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Bluetooth Advertising disabled -- Device presence broadcast stopped." -ForegroundColor Green
}

function Restore-BluetoothAdvertising {
    Write-Host "`n[*] Restoring Bluetooth Advertising..." -ForegroundColor Yellow
    $btKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Bluetooth'
    if (Test-Path $btKey) {
        Remove-ItemProperty -Path $btKey -Name 'AllowAdvertising' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Bluetooth Advertising restored." -ForegroundColor Green
}

# 3. Cloud-Optimized Content Disabler
function Disable-CloudOptimizedContent {
    Write-Host "`n[*] Disabling Cloud-Optimized Content & Remote Asset Syncing..." -ForegroundColor Yellow
    $cloudKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
    if (-not (Test-Path $cloudKey)) { New-Item -Path $cloudKey -Force | Out-Null }
    Set-ItemProperty -Path $cloudKey -Name 'DisableCloudOptimizedContent' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Cloud-optimized content disabled -- Internet bandwidth saved!" -ForegroundColor Green
}

function Restore-CloudOptimizedContent {
    Write-Host "`n[*] Restoring Cloud-Optimized Content..." -ForegroundColor Yellow
    $cloudKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
    if (Test-Path $cloudKey) {
        Remove-ItemProperty -Path $cloudKey -Name 'DisableCloudOptimizedContent' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Cloud-optimized content restored." -ForegroundColor Green
}

# 4. Connected Devices Platform (CDP) Telemetry Services
function Disable-CdpServices {
    Write-Host "`n[*] Disabling Connected Devices Platform (CDP) Services..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CDPSvc' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CDPUserSvc' -Name 'Start' -Value 4 -Type DWord -ErrorAction SilentlyContinue
    Stop-Service -Name CDPSvc -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] CDP Services disabled -- User Activity and device sync halted." -ForegroundColor Green
}

function Restore-CdpServices {
    Write-Host "`n[*] Restoring Connected Devices Platform (CDP) Services..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CDPSvc' -Name 'Start' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CDPUserSvc' -Name 'Start' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Start-Service -Name CDPSvc -ErrorAction SilentlyContinue
    Write-Host "      [+] CDP Services restored to Automatic." -ForegroundColor Green
}

# 5. Diagnostic Toast Notifications
function Disable-DiagnosticsToasts {
    Write-Host "`n[*] Disabling Diagnostic & Maintenance Toast Notifications..." -ForegroundColor Yellow
    $toastKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance'
    if (-not (Test-Path $toastKey)) { New-Item -Path $toastKey -Force | Out-Null }
    Set-ItemProperty -Path $toastKey -Name 'Enabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Security and Maintenance diagnostic toast notifications muted." -ForegroundColor Green
}

function Restore-DiagnosticsToasts {
    Write-Host "`n[*] Restoring Diagnostic Toast Notifications..." -ForegroundColor Yellow
    $toastKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance'
    if (Test-Path $toastKey) {
        Set-ItemProperty -Path $toastKey -Name 'Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Diagnostic toast notifications restored." -ForegroundColor Green
}

# 6. Online Speech Recognition & Voice Activation Privacy
function Disable-OnlineSpeechPrivacy {
    Write-Host "`n[*] Disabling Online Speech Recognition & Cloud Voice Storage..." -ForegroundColor Yellow
    $speechKey = 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'
    if (-not (Test-Path $speechKey)) { New-Item -Path $speechKey -Force | Out-Null }
    Set-ItemProperty -Path $speechKey -Name 'HasAccepted' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    $voiceKey = 'HKCU:\Software\Microsoft\Speech_OneCore\Preferences'
    if (-not (Test-Path $voiceKey)) { New-Item -Path $voiceKey -Force | Out-Null }
    Set-ItemProperty -Path $voiceKey -Name 'AgentActivationEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Online speech recognition and voice assistant activation disabled." -ForegroundColor Green
}

function Restore-OnlineSpeechPrivacy {
    Write-Host "`n[*] Restoring Online Speech Recognition..." -ForegroundColor Yellow
    $speechKey = 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'
    if (Test-Path $speechKey) {
        Set-ItemProperty -Path $speechKey -Name 'HasAccepted' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    $voiceKey = 'HKCU:\Software\Microsoft\Speech_OneCore\Preferences'
    if (Test-Path $voiceKey) {
        Set-ItemProperty -Path $voiceKey -Name 'AgentActivationEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Online speech settings restored." -ForegroundColor Green
}

# 7. Automatic Restart Sign-On (ARSO)
function Disable-AutomaticRestartSignOn {
    Write-Host "`n[*] Disabling Automatic Restart Sign-On (ARSO Credential Caching)..." -ForegroundColor Yellow
    $sysKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    if (-not (Test-Path $sysKey)) { New-Item -Path $sysKey -Force | Out-Null }
    Set-ItemProperty -Path $sysKey -Name 'DisableAutomaticRestartSignOn' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] ARSO disabled -- User credentials not auto-unlocked after reboot." -ForegroundColor Green
}

function Restore-AutomaticRestartSignOn {
    Write-Host "`n[*] Restoring Automatic Restart Sign-On..." -ForegroundColor Yellow
    $sysKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    if (Test-Path $sysKey) {
        Remove-ItemProperty -Path $sysKey -Name 'DisableAutomaticRestartSignOn' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] ARSO restored." -ForegroundColor Green
}

# 8. Handwriting Data Sharing & Text Input Collection (Typing Telemetry)
function Disable-TextInputCollection {
    Write-Host "`n[*] Disabling Typing & Handwriting Telemetry Data Collection..." -ForegroundColor Yellow
    $inputPol = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'
    if (-not (Test-Path $inputPol)) { New-Item -Path $inputPol -Force | Out-Null }
    Set-ItemProperty -Path $inputPol -Name 'RestrictImplicitInkCollection' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $inputPol -Name 'RestrictImplicitTextCollection' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $hwKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports'
    if (-not (Test-Path $hwKey)) { New-Item -Path $hwKey -Force | Out-Null }
    Set-ItemProperty -Path $hwKey -Name 'PreventHandwritingDataSharing' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $userInp = 'HKCU:\Software\Microsoft\InputPersonalization'
    if (-not (Test-Path $userInp)) { New-Item -Path $userInp -Force | Out-Null }
    Set-ItemProperty -Path $userInp -Name 'RestrictImplicitInkCollection' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $userInp -Name 'RestrictImplicitTextCollection' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    Write-Host "      [+] Keystroke and handwriting diagnostic reporting disabled." -ForegroundColor Green
}

function Restore-TextInputCollection {
    Write-Host "`n[*] Restoring Typing & Handwriting Data Sharing..." -ForegroundColor Yellow
    $inputPol = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'
    if (Test-Path $inputPol) {
        Remove-ItemProperty -Path $inputPol -Name 'RestrictImplicitInkCollection' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $inputPol -Name 'RestrictImplicitTextCollection' -ErrorAction SilentlyContinue
    }
    $hwKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports'
    if (Test-Path $hwKey) {
        Remove-ItemProperty -Path $hwKey -Name 'PreventHandwritingDataSharing' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Typing and handwriting defaults restored." -ForegroundColor Green
}

# 9. Cross-Device Clipboard Sync
function Disable-ClipboardSync {
    Write-Host "`n[*] Disabling Cross-Device Cloud Clipboard Sync..." -ForegroundColor Yellow
    $sysPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (-not (Test-Path $sysPol)) { New-Item -Path $sysPol -Force | Out-Null }
    Set-ItemProperty -Path $sysPol -Name 'AllowCrossDeviceClipboard' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    $clipCU = 'HKCU:\Software\Microsoft\Clipboard'
    if (-not (Test-Path $clipCU)) { New-Item -Path $clipCU -Force | Out-Null }
    Set-ItemProperty -Path $clipCU -Name 'EnableClipboardHistory' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $clipCU -Name 'CloudClipboardEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Cloud clipboard sync disabled -- Copied text remains local." -ForegroundColor Green
}

function Restore-ClipboardSync {
    Write-Host "`n[*] Restoring Cloud Clipboard Sync..." -ForegroundColor Yellow
    $sysPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (Test-Path $sysPol) {
        Set-ItemProperty -Path $sysPol -Name 'AllowCrossDeviceClipboard' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Cloud clipboard sync restored." -ForegroundColor Green
}

# 10. Device Message & Settings Sync
function Disable-SettingsAndMessageSync {
    Write-Host "`n[*] Disabling Cross-Device Settings & Message Synchronization..." -ForegroundColor Yellow
    $syncPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'
    if (-not (Test-Path $syncPol)) { New-Item -Path $syncPol -Force | Out-Null }
    Set-ItemProperty -Path $syncPol -Name 'DisableSettingSync' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $syncPol -Name 'DisableSettingSyncUserOverride' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $msgPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging'
    if (-not (Test-Path $msgPol)) { New-Item -Path $msgPol -Force | Out-Null }
    Set-ItemProperty -Path $msgPol -Name 'AllowMessageSync' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] OS Settings and Message sync across devices disabled." -ForegroundColor Green
}

function Restore-SettingsAndMessageSync {
    Write-Host "`n[*] Restoring Settings & Message Sync..." -ForegroundColor Yellow
    $syncPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'
    if (Test-Path $syncPol) {
        Remove-ItemProperty -Path $syncPol -Name 'DisableSettingSync' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $syncPol -Name 'DisableSettingSyncUserOverride' -ErrorAction SilentlyContinue
    }
    $msgPol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging'
    if (Test-Path $msgPol) {
        Remove-ItemProperty -Path $msgPol -Name 'AllowMessageSync' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Settings and message sync restored." -ForegroundColor Green
}

# 11. Find My Device Tracking
function Disable-FindMyDevice {
    Write-Host "`n[*] Disabling 'Find My Device' Location Tracking..." -ForegroundColor Yellow
    $findPol = 'HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice'
    if (-not (Test-Path $findPol)) { New-Item -Path $findPol -Force | Out-Null }
    Set-ItemProperty -Path $findPol -Name 'AllowFindMyDevice' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Find My Device tracking disabled." -ForegroundColor Green
}

function Restore-FindMyDevice {
    Write-Host "`n[*] Restoring 'Find My Device'..." -ForegroundColor Yellow
    $findPol = 'HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice'
    if (Test-Path $findPol) {
        Remove-ItemProperty -Path $findPol -Name 'AllowFindMyDevice' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Find My Device restored." -ForegroundColor Green
}

# 12. SafeSearch Mode in Windows Search
function Disable-SafeSearchMode {
    Write-Host "`n[*] Disabling SafeSearch Filter in Windows Search..." -ForegroundColor Yellow
    $srchSet = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings'
    if (-not (Test-Path $srchSet)) { New-Item -Path $srchSet -Force | Out-Null }
    Set-ItemProperty -Path $srchSet -Name 'SafeSearchMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] SafeSearch filter disabled (Unfiltered instant local search)." -ForegroundColor Green
}

function Restore-SafeSearchMode {
    Write-Host "`n[*] Restoring SafeSearch Filter..." -ForegroundColor Yellow
    $srchSet = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings'
    if (Test-Path $srchSet) {
        Set-ItemProperty -Path $srchSet -Name 'SafeSearchMode' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] SafeSearch restored to Moderate." -ForegroundColor Green
}

# 13. Disable SMBv1 Protocol (Legacy Security Vulnerability)
function Disable-SmbV1Protocol {
    Write-Host "`n[*] Disabling Deprecated SMBv1 Protocol (Ransomware / WannaCry Shield)..." -ForegroundColor Yellow
    try {
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue | Out-Null
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
        Write-Host "      [+] SMBv1 protocol disabled successfully -- Network attack surface closed!" -ForegroundColor Green
    } catch {
        Write-Host "      [!] SMBv1 disable skipped: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
}

function Restore-SmbV1Protocol {
    Write-Host "`n[*] Restoring SMBv1 Protocol..." -ForegroundColor Yellow
    try {
        Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force -ErrorAction SilentlyContinue | Out-Null
        Write-Host "      [+] SMBv1 protocol restored." -ForegroundColor Green
    } catch {}
}

# 14. Disable Remote Assistance & Remote Registry
function Disable-RemoteAssistanceAndRegistry {
    Write-Host "`n[*] Disabling Remote Assistance & Remote Registry Access..." -ForegroundColor Yellow
    $raPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance'
    if (-not (Test-Path $raPath)) { New-Item -Path $raPath -Force | Out-Null }
    Set-ItemProperty -Path $raPath -Name 'fAllowToGetHelp' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    Set-Service -Name RemoteRegistry -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name RemoteRegistry -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] Remote Assistance and Remote Registry service disabled." -ForegroundColor Green
}

function Restore-RemoteAssistanceAndRegistry {
    Write-Host "`n[*] Restoring Remote Assistance & Remote Registry..." -ForegroundColor Yellow
    $raPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance'
    if (Test-Path $raPath) {
        Set-ItemProperty -Path $raPath -Name 'fAllowToGetHelp' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Set-Service -Name RemoteRegistry -StartupType Manual -ErrorAction SilentlyContinue
    Write-Host "      [+] Remote Assistance and Remote Registry restored." -ForegroundColor Green
}

# 15. Exclude Driver Updates from Windows Update
function Disable-DriverUpdatesFromWindowsUpdate {
    Write-Host "`n[*] Excluding Hardware Drivers from Windows Update (Prevents Driver Overwrites)..." -ForegroundColor Yellow
    $wuPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    if (-not (Test-Path $wuPath)) { New-Item -Path $wuPath -Force | Out-Null }
    Set-ItemProperty -Path $wuPath -Name 'ExcludeWUDriversInQualityUpdate' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Driver updates excluded from Windows Update -- GPU/Audio drivers protected!" -ForegroundColor Green
}

function Restore-DriverUpdatesFromWindowsUpdate {
    Write-Host "`n[*] Restoring Driver Updates in Windows Update..." -ForegroundColor Yellow
    $wuPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    if (Test-Path $wuPath) {
        Remove-ItemProperty -Path $wuPath -Name 'ExcludeWUDriversInQualityUpdate' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Driver updates via Windows Update restored." -ForegroundColor Green
}

# 16. Disable Microsoft Store Automatic Updates
function Disable-StoreAutoUpdates {
    Write-Host "`n[*] Disabling Microsoft Store Automatic App Updates..." -ForegroundColor Yellow
    $storePath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'
    if (-not (Test-Path $storePath)) { New-Item -Path $storePath -Force | Out-Null }
    Set-ItemProperty -Path $storePath -Name 'AutoDownload' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Store auto-downloads disabled -- Updates will only occur on demand." -ForegroundColor Green
}

function Restore-StoreAutoUpdates {
    Write-Host "`n[*] Restoring Microsoft Store Auto-Updates..." -ForegroundColor Yellow
    $storePath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'
    if (Test-Path $storePath) {
        Remove-ItemProperty -Path $storePath -Name 'AutoDownload' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Store auto-downloads restored." -ForegroundColor Green
}

# 17. Disable SmartScreen Filter
function Disable-SmartScreenFilter {
    Write-Host "`n[*] Disabling Windows Defender SmartScreen Filter..." -ForegroundColor Yellow
    $sysPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (-not (Test-Path $sysPath)) { New-Item -Path $sysPath -Force | Out-Null }
    Set-ItemProperty -Path $sysPath -Name 'EnableSmartScreen' -Value 0 -Type DWord -ErrorAction SilentlyContinue

    $appHost = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost'
    if (-not (Test-Path $appHost)) { New-Item -Path $appHost -Force | Out-Null }
    Set-ItemProperty -Path $appHost -Name 'EnableWebContentEvaluation' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] SmartScreen filter disabled -- App execution warnings suppressed." -ForegroundColor Green
}

function Restore-SmartScreenFilter {
    Write-Host "`n[*] Restoring SmartScreen Filter..." -ForegroundColor Yellow
    $sysPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (Test-Path $sysPath) {
        Set-ItemProperty -Path $sysPath -Name 'EnableSmartScreen' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    $appHost = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost'
    if (Test-Path $appHost) {
        Set-ItemProperty -Path $appHost -Name 'EnableWebContentEvaluation' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] SmartScreen filter restored." -ForegroundColor Green
}

# 18. Disable System Crash Dumps
function Disable-CrashDumps {
    Write-Host "`n[*] Disabling Application Crash Dumps & Memory MiniDumps..." -ForegroundColor Yellow
    $crashPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
    if (-not (Test-Path $crashPath)) { New-Item -Path $crashPath -Force | Out-Null }
    Set-ItemProperty -Path $crashPath -Name 'CrashDumpEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Crash dumps disabled -- Prevents gigabytes of useless dump files on disk." -ForegroundColor Green
}

function Restore-CrashDumps {
    Write-Host "`n[*] Restoring Default Crash Dump Generation..." -ForegroundColor Yellow
    $crashPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
    if (Test-Path $crashPath) {
        Set-ItemProperty -Path $crashPath -Name 'CrashDumpEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Crash dump generation restored." -ForegroundColor Green
}

# 19. Optimize System Timeouts & Responsiveness
function Optimize-SystemTimeouts {
    Write-Host "`n[*] Optimizing System Timeouts, Menu Show Delay & Broken Link Resolving..." -ForegroundColor Yellow
    $deskPath = 'HKCU:\Control Panel\Desktop'
    Set-ItemProperty -Path $deskPath -Name 'MenuShowDelay' -Value '0' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $deskPath -Name 'WaitToKillAppTimeout' -Value '2000' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $deskPath -Name 'HungAppTimeout' -Value '1000' -Type String -ErrorAction SilentlyContinue

    $mousePath = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mousePath -Name 'MouseHoverTime' -Value '0' -Type String -ErrorAction SilentlyContinue

    $ctrlPath = 'HKLM:\SYSTEM\CurrentControlSet\Control'
    Set-ItemProperty -Path $ctrlPath -Name 'WaitToKillServiceTimeout' -Value '2000' -Type String -ErrorAction SilentlyContinue

    $polExp = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    if (-not (Test-Path $polExp)) { New-Item -Path $polExp -Force | Out-Null }
    Set-ItemProperty -Path $polExp -Name 'NoLowDiskSpaceChecks' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $polExp -Name 'NoResolveSearch' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $polExp -Name 'NoResolveTrack' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    Write-Host "      [+] Instant menu popups (0ms delay), fast app shutdown (2s), and no broken link lag!" -ForegroundColor Green
}

function Restore-SystemTimeouts {
    Write-Host "`n[*] Restoring Default Windows Timeouts..." -ForegroundColor Yellow
    $deskPath = 'HKCU:\Control Panel\Desktop'
    Set-ItemProperty -Path $deskPath -Name 'MenuShowDelay' -Value '400' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $deskPath -Name 'WaitToKillAppTimeout' -Value '20000' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $deskPath -Name 'HungAppTimeout' -Value '5000' -Type String -ErrorAction SilentlyContinue

    $mousePath = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mousePath -Name 'MouseHoverTime' -Value '400' -Type String -ErrorAction SilentlyContinue

    $ctrlPath = 'HKLM:\SYSTEM\CurrentControlSet\Control'
    Set-ItemProperty -Path $ctrlPath -Name 'WaitToKillServiceTimeout' -Value '5000' -Type String -ErrorAction SilentlyContinue

    $polExp = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    if (Test-Path $polExp) {
        Remove-ItemProperty -Path $polExp -Name 'NoLowDiskSpaceChecks' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $polExp -Name 'NoResolveSearch' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $polExp -Name 'NoResolveTrack' -ErrorAction SilentlyContinue
    }
    Write-Host "      [+] Default timeouts and link tracking restored." -ForegroundColor Green
}

# Compatibility Aliases for GUI & CLI Dispatchers
function Disable-ThirdPartyAppTelemetry { Disable-AppTelemetry }
function Disable-CdpUserServices { Disable-CdpServices }
function Disable-RestartAppsAfterReboot { Disable-AutomaticRestartSignOn }
function Disable-HandwritingTypingCollection { Disable-TextInputCollection }
function Disable-ClipboardCloudSync { Disable-ClipboardSync }
function Disable-SafeSearchFiltering { Disable-SafeSearchMode }
function Exclude-DriverUpdatesInWindowsUpdate { Disable-DriverUpdatesFromWindowsUpdate }
function Disable-WindowsStoreAutoUpdates { Disable-StoreAutoUpdates }
function Disable-SmartScreenProtection { Disable-SmartScreenFilter }
function Disable-SystemCrashDumps { Disable-CrashDumps }

# Standalone execution check
if ($MyInvocation.InvocationName -ne '.') {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    Disable-AppTelemetry
    Disable-BluetoothAdvertising
    Disable-CloudOptimizedContent
    Disable-DiagnosticsToasts
    Disable-TextInputCollection
    Disable-ClipboardSync
    Disable-SmbV1Protocol
    Disable-DriverUpdatesFromWindowsUpdate
    Optimize-SystemTimeouts
    Read-Host "`nPress Enter to exit"
}
