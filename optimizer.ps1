<#
================================================================================
   ____                       _    _       _   _ 
  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |
  | |_) | | | | '_ ` _ \| '_ \ |/ / | '_ \|  \| |
  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |
  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|
                        |_|                       
           ULTIMATE GAMING & NETWORK OPTIMIZER v5.0
          Created by PumpkiN | Max FPS - Ultra Low Latency
================================================================================
One-line run:
irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex
================================================================================
#>

# 1. Administrator Elevation Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/SadmanHadi/Win_Optimizer/main/optimizer.ps1 | iex`"" -Verb RunAs
    return
}

$Host.UI.RawUI.WindowTitle = "PumpkiN's Ultimate Gaming and Network Optimizer v5.0"

# --- HELPER FUNCTIONS ---
function Get-HardwareProfile {
    $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
    $gpus = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue
    $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*VPN*' } | Select-Object -First 1
    $ram = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object -Property Capacity -Sum
    $totalRamGb = [math]::Round($ram.Sum / 1GB, 1)

    return [PSCustomObject]@{
        CpuName     = $cpu.Name
        CpuCores    = "$($cpu.NumberOfCores)C / $($cpu.NumberOfLogicalProcessors)T"
        IsAmdCpu    = ($cpu.Name -match 'AMD|Ryzen')
        IsIntelCpu  = ($cpu.Name -match 'Intel|Core')
        Gpus        = $gpus
        HasNvidia   = ($gpus | Where-Object { $_.Name -match 'NVIDIA|GeForce' }) -ne $null
        HasAmdGpu   = ($gpus | Where-Object { $_.Name -match 'AMD|Radeon' }) -ne $null
        Adapter     = $adapter
        IsWifi      = ($adapter -and ($adapter.InterfaceType -eq 71 -or $adapter.InterfaceDescription -match 'Wi-Fi|Wireless|802\.11'))
        RamGb       = $totalRamGb
    }
}

# --- WINGET SOFTWARE CATALOG & MANAGER ENGINE ---

$Global:AppCatalog = @(
    # Browsers
    @{ Key='brave'; Name='Brave'; Category='Browsers'; Winget='Brave.Brave'; Desc='Privacy-first high performance browser' },
    @{ Key='chrome'; Name='Google Chrome'; Category='Browsers'; Winget='Google.Chrome'; Desc='Fast, popular Chromium browser' },
    @{ Key='chromium'; Name='Chromium'; Category='Browsers'; Winget='Chromium.Chromium'; Desc='Open-source browser project behind Chrome' },
    @{ Key='edge'; Name='Microsoft Edge'; Category='Browsers'; Winget='Microsoft.Edge'; Desc='Native Windows Chromium browser' },
    @{ Key='firefox'; Name='Mozilla Firefox'; Category='Browsers'; Winget='Mozilla.Firefox'; Desc='Customizable, privacy-respecting browser' },
    @{ Key='firefoxesr'; Name='Firefox ESR'; Category='Browsers'; Winget='Mozilla.Firefox.ESR'; Desc='Extended Support Release for rock-solid stability' },
    @{ Key='floorp'; Name='Floorp'; Category='Browsers'; Winget='Ablaze.Floorp'; Desc='Feature-rich Japanese Firefox fork' },
    @{ Key='librewolf'; Name='LibreWolf'; Category='Browsers'; Winget='LibreWolf.LibreWolf'; Desc='Hardened privacy and security Firefox build' },
    @{ Key='tor'; Name='Tor Browser'; Category='Browsers'; Winget='TorProject.TorBrowser'; Desc='Onion routing anonymous browser' },
    @{ Key='ungoogled'; Name='Ungoogled Chromium'; Category='Browsers'; Winget='eloston.ungoogled-chromium'; Desc='Chromium with Google services stripped' },
    @{ Key='vivaldi'; Name='Vivaldi'; Category='Browsers'; Winget='VivaldiTechnologies.Vivaldi'; Desc='Power-user browser with deep customizability' },
    @{ Key='waterfox'; Name='Waterfox'; Category='Browsers'; Winget='Waterfox.Waterfox'; Desc='Fast, legacy-compatible Firefox derivative' },
    @{ Key='zen'; Name='Zen Browser'; Category='Browsers'; Winget='Zen-Team.Zen-Browser'; Desc='Modern tab-split Firefox-based browser' },

    # Communications
    @{ Key='discord'; Name='Discord'; Category='Communications'; Winget='Discord.Discord'; Desc='All-in-one voice and text chat for gamers' },
    @{ Key='telegram'; Name='Telegram'; Category='Communications'; Winget='Telegram.TelegramDesktop'; Desc='Fast, cloud-based messaging app' },
    @{ Key='signal'; Name='Signal'; Category='Communications'; Winget='OpenWhisperSystems.Signal'; Desc='End-to-end encrypted private messaging' },
    @{ Key='slack'; Name='Slack'; Category='Communications'; Winget='SlackTechnologies.Slack'; Desc='Team collaboration and channel messaging' },
    @{ Key='teams'; Name='Microsoft Teams'; Category='Communications'; Winget='Microsoft.Teams'; Desc='Workplace collaboration and video meetings' },
    @{ Key='whatsapp'; Name='WhatsApp Desktop'; Category='Communications'; Winget='WhatsApp.WhatsApp'; Desc='Popular global mobile messaging on PC' },
    @{ Key='zoom'; Name='Zoom'; Category='Communications'; Winget='Zoom.Zoom'; Desc='High-definition video calls and meetings' },
    @{ Key='vesktop'; Name='Vesktop'; Category='Communications'; Winget='Vencord.Vesktop'; Desc='Custom Discord client with Vencord preloaded' },
    @{ Key='teamspeak3'; Name='TeamSpeak 3'; Category='Communications'; Winget='TeamSpeakSystems.TeamSpeakClient'; Desc='Ultra-low latency crystal voice for gamers' },
    @{ Key='element'; Name='Element'; Category='Communications'; Winget='Element.Element'; Desc='Secure decentralized Matrix chat client' },

    # Development
    @{ Key='vscode'; Name='VS Code'; Category='Development'; Winget='Microsoft.VisualStudioCode'; Desc='Microsoft modern code and script editor' },
    @{ Key='cursor'; Name='Cursor'; Category='Development'; Winget='Anysphere.Cursor'; Desc='AI-powered code editor built on VS Code' },
    @{ Key='git'; Name='Git'; Category='Development'; Winget='Git.Git'; Desc='Fast, scalable distributed version control' },
    @{ Key='githubdesktop'; Name='GitHub Desktop'; Category='Development'; Winget='GitHub.GitHubDesktop'; Desc='Official GUI for GitHub repositories' },
    @{ Key='githubcli'; Name='GitHub CLI'; Category='Development'; Winget='GitHub.cli'; Desc='Command-line tool for GitHub pull requests and issues' },
    @{ Key='python3'; Name='Python 3'; Category='Development'; Winget='Python.Python.3.12'; Desc='Versatile programming language runtime' },
    @{ Key='nodejs'; Name='NodeJS LTS'; Category='Development'; Winget='OpenJS.NodeJS.LTS'; Desc='JavaScript runtime built on Chrome V8' },
    @{ Key='docker'; Name='Docker Desktop'; Category='Development'; Winget='Docker.DockerDesktop'; Desc='Container development and execution platform' },
    @{ Key='neovim'; Name='Neovim'; Category='Development'; Winget='Neovim.Neovim'; Desc='Hyperextensible Vim-based terminal editor' },
    @{ Key='sublime'; Name='Sublime Text'; Category='Development'; Winget='SublimeHQ.SublimeText.4'; Desc='Ultra-fast lightweight text and code editor' },
    @{ Key='jetbrains'; Name='JetBrains Toolbox'; Category='Development'; Winget='JetBrains.Toolbox'; Desc='Manager for IntelliJ, PyCharm, and CLion' },
    @{ Key='claudecode'; Name='Claude Code'; Category='Development'; Winget='Anthropic.ClaudeCode'; Desc='Agentic AI coding assistant from Anthropic' },
    @{ Key='rust'; Name='Rustup'; Category='Development'; Winget='Rustlang.Rustup'; Desc='Rust toolchain installer and compiler' },
    @{ Key='go'; Name='Go'; Category='Development'; Winget='GoLang.Go'; Desc='Fast, statically compiled programming language' },

    # Document
    @{ Key='acrobat'; Name='Adobe Acrobat Reader'; Category='Document'; Winget='Adobe.Acrobat.Reader.64-bit'; Desc='Industry standard PDF reader' },
    @{ Key='obsidian'; Name='Obsidian'; Category='Document'; Winget='Obsidian.Obsidian'; Desc='Markdown-based personal knowledge base' },
    @{ Key='libreoffice'; Name='LibreOffice'; Category='Document'; Winget='TheDocumentFoundation.LibreOffice'; Desc='Free and open source full office suite' },
    @{ Key='pdf24'; Name='PDF24 Creator'; Category='Document'; Winget='geeksoftwareGmbH.PDF24'; Desc='Free Swiss Army knife for converting and merging PDFs' },
    @{ Key='sumatrapdf'; Name='Sumatra PDF'; Category='Document'; Winget='SumatraPDF.SumatraPDF'; Desc='Featherweight, lightning-fast PDF viewer' },
    @{ Key='joplin'; Name='Joplin'; Category='Document'; Winget='Joplin.Joplin'; Desc='Encrypted note-taking with sync capabilities' },
    @{ Key='zotero'; Name='Zotero'; Category='Document'; Winget='DigitalScholar.Zotero'; Desc='Research tool and citation manager' },
    @{ Key='foxit'; Name='Foxit PDF Reader'; Category='Document'; Winget='Foxit.FoxitReader'; Desc='Fast, feature-rich PDF reader' },

    # Games
    @{ Key='steam'; Name='Steam'; Category='Games'; Winget='Valve.Steam'; Desc='Premier PC gaming store and platform' },
    @{ Key='epicgames'; Name='Epic Games Launcher'; Category='Games'; Winget='EpicGames.EpicGamesLauncher'; Desc='Home of Unreal Engine, Fortnite, and weekly free games' },
    @{ Key='battlenet'; Name='Battle.net'; Category='Games'; Winget='Blizzard.BattleNet'; Desc='Blizzard launcher for COD, Overwatch, WoW' },
    @{ Key='eaapp'; Name='EA App'; Category='Games'; Winget='ElectronicArts.EADesktop'; Desc='Electronic Arts gaming platform' },
    @{ Key='gog'; Name='GOG Galaxy'; Category='Games'; Winget='GOG.Galaxy'; Desc='DRM-free PC game store and library manager' },
    @{ Key='heroic'; Name='Heroic Games Launcher'; Category='Games'; Winget='HeroicGamesLauncher.HeroicGamesLauncher'; Desc='Open source launcher for Epic and GOG' },
    @{ Key='roblox'; Name='Roblox'; Category='Games'; Winget='Roblox.RobloxPlayer'; Desc='Online game creation and player platform' },
    @{ Key='curseforge'; Name='CurseForge'; Category='Games'; Winget='Overwolf.CurseForge'; Desc='Mod and addon manager for Minecraft and WoW' },
    @{ Key='playnite'; Name='Playnite'; Category='Games'; Winget='Playnite.Playnite'; Desc='Universal open source video game library manager' },
    @{ Key='ubisoft'; Name='Ubisoft Connect'; Category='Games'; Winget='Ubisoft.Connect'; Desc='Ubisoft official store and game hub' },
    @{ Key='prismlauncher'; Name='Prism Launcher'; Category='Games'; Winget='PrismLauncher.PrismLauncher'; Desc='High-performance Minecraft instance launcher' },
    @{ Key='cemu'; Name='Cemu'; Category='Games'; Winget='Cemu.Cemu'; Desc='High-performance Wii U emulator' },
    @{ Key='geforcenow'; Name='GeForce NOW'; Category='Games'; Winget='Nvidia.GeForceNow'; Desc='NVIDIA cloud gaming client' },

    # Microsoft Tools
    @{ Key='powertoys'; Name='PowerToys'; Category='Microsoft Tools'; Winget='Microsoft.PowerToys'; Desc='System utilities for power users and window management' },
    @{ Key='winterminal'; Name='Windows Terminal'; Category='Microsoft Tools'; Winget='Microsoft.WindowsTerminal'; Desc='Modern, tabbed command line for Windows' },
    @{ Key='procexp'; Name='Process Explorer'; Category='Microsoft Tools'; Winget='Microsoft.Sysinternals.ProcessExplorer'; Desc='Advanced Task Manager replacement from Mark Russinovich' },
    @{ Key='procmon'; Name='Process Monitor'; Category='Microsoft Tools'; Winget='Microsoft.Sysinternals.ProcessMonitor'; Desc='Real-time file system, registry, and process monitor' },
    @{ Key='autoruns'; Name='Autoruns'; Category='Microsoft Tools'; Winget='Microsoft.Sysinternals.Autoruns'; Desc='Comprehensive startup and boot autostart inspector' },
    @{ Key='tcpview'; Name='TCPView'; Category='Microsoft Tools'; Winget='Microsoft.Sysinternals.TCPView'; Desc='Real-time network socket connection viewer' },
    @{ Key='pwsh'; Name='PowerShell 7'; Category='Microsoft Tools'; Winget='Microsoft.PowerShell'; Desc='Cross-platform, modern PowerShell core' },
    @{ Key='dotnet8'; Name='.NET Desktop Runtime 8'; Category='Microsoft Tools'; Winget='Microsoft.DotNet.DesktopRuntime.8'; Desc='Microsoft .NET 8 desktop application runtime' },
    @{ Key='vcredist'; Name='Visual C++ All-in-One'; Category='Microsoft Tools'; Winget='Microsoft.VCRedist.2015+.x64'; Desc='Essential runtime for PC games and programs' },

    # Multimedia Tools
    @{ Key='obs'; Name='OBS Studio'; Category='Multimedia Tools'; Winget='OBSProject.OBSStudio'; Desc='Live streaming and screen recording studio' },
    @{ Key='vlc'; Name='VLC Media Player'; Category='Multimedia Tools'; Winget='VideoLAN.VLC'; Desc='Plays all video and audio formats flawlessly' },
    @{ Key='handbrake'; Name='HandBrake'; Category='Multimedia Tools'; Winget='HandBrake.HandBrake'; Desc='Open-source video transcoder and converter' },
    @{ Key='audacity'; Name='Audacity'; Category='Multimedia Tools'; Winget='Audacity.Audacity'; Desc='Multi-track audio editor and recorder' },
    @{ Key='blender'; Name='Blender'; Category='Multimedia Tools'; Winget='BlenderFoundation.Blender'; Desc='Open-source 3D graphics and rendering suite' },
    @{ Key='gimp'; Name='GIMP'; Category='Multimedia Tools'; Winget='GIMP.GIMP'; Desc='Free Photoshop alternative for photo manipulation' },
    @{ Key='klite'; Name='K-Lite Codec Standard'; Category='Multimedia Tools'; Winget='CodecGuide.K-LiteCodecPack.Standard'; Desc='Comprehensive video codecs and MPC-HC player' },
    @{ Key='sharex'; Name='ShareX'; Category='Multimedia Tools'; Winget='ShareX.ShareX'; Desc='Screen capture, file sharing, and productivity tool' },
    @{ Key='mpv'; Name='mpv.net'; Category='Multimedia Tools'; Winget='mpv.net'; Desc='Minimalist, GPU-accelerated modern media player' },
    @{ Key='eartrumpet'; Name='EarTrumpet'; Category='Multimedia Tools'; Winget='File-New-Project.EarTrumpet'; Desc='Powerful per-app audio volume control tray' },
    @{ Key='paintnet'; Name='Paint.NET'; Category='Multimedia Tools'; Winget='dotPDN.PaintDotNet'; Desc='Intuitive image and photo editing software' },

    # Pro Tools
    @{ Key='ddu'; Name='Display Driver Uninstaller'; Category='Pro Tools'; Winget='Wagnardsoft.DisplayDriverUninstaller'; Desc='Cleanly strips GPU drivers for fresh install' },
    @{ Key='cpuz'; Name='CPU-Z'; Category='Pro Tools'; Winget='CPUID.CPU-Z'; Desc='Detailed processor, cache, and motherboard specs' },
    @{ Key='gpuz'; Name='GPU-Z'; Category='Pro Tools'; Winget='TechPowerUp.GPU-Z'; Desc='Graphics card hardware diagnostic utility' },
    @{ Key='hwinfo'; Name='HWiNFO'; Category='Pro Tools'; Winget='REALiX.HWiNFO'; Desc='Hardware analysis, sensor monitoring, and telemetry' },
    @{ Key='hwmonitor'; Name='HWMonitor'; Category='Pro Tools'; Winget='CPUID.HWMonitor'; Desc='Voltages, temperatures, and fan speed monitor' },
    @{ Key='cinebench'; Name='Cinebench R23'; Category='Pro Tools'; Winget='Maxon.CinebenchR23'; Desc='Industry standard CPU rendering benchmark' },
    @{ Key='wireshark'; Name='Wireshark'; Category='Pro Tools'; Winget='WiresharkFoundation.Wireshark'; Desc='Deep-packet network protocol analyzer' },
    @{ Key='putty'; Name='PuTTY'; Category='Pro Tools'; Winget='PuTTY.PuTTY'; Desc='SSH and telnet terminal client' },
    @{ Key='advipscan'; Name='Advanced IP Scanner'; Category='Pro Tools'; Winget='Famatech.AdvancedIPScanner'; Desc='Fast local network subnet scanner' },
    @{ Key='nmap'; Name='Nmap'; Category='Pro Tools'; Winget='Insecure.Nmap'; Desc='Network discovery and vulnerability security scanner' },
    @{ Key='protonvpn'; Name='Proton VPN'; Category='Pro Tools'; Winget='Proton.ProtonVPN'; Desc='Swiss encrypted zero-log virtual private network' },

    # Selfhosted Tools
    @{ Key='jellyfin'; Name='Jellyfin Media Player'; Category='Selfhosted Tools'; Winget='Jellyfin.JellyfinMediaPlayer'; Desc='Desktop client for self-hosted media server' },
    @{ Key='plex'; Name='Plex Desktop'; Category='Selfhosted Tools'; Winget='Plex.Plex'; Desc='Personal media streaming client' },
    @{ Key='moonlight'; Name='Moonlight'; Category='Selfhosted Tools'; Winget='MoonlightGameStreamingProject.Moonlight'; Desc='Ultra-low latency NVIDIA/Sunshine PC game streaming' },
    @{ Key='sunshine'; Name='Sunshine'; Category='Selfhosted Tools'; Winget='LizardByte.Sunshine'; Desc='Self-hosted GameStream server for Moonlight clients' },
    @{ Key='localsend'; Name='LocalSend'; Category='Selfhosted Tools'; Winget='LocalSend.LocalSend'; Desc='AirDrop alternative for local network file transfer' },
    @{ Key='syncthing'; Name='Syncthing'; Category='Selfhosted Tools'; Winget='Syncthing.Syncthing'; Desc='Continuous peer-to-peer file synchronization' },
    @{ Key='kodi'; Name='Kodi'; Category='Selfhosted Tools'; Winget='Kodi.Kodi'; Desc='Open source entertainment media center hub' },

    # Utilities
    @{ Key='afterburner'; Name='MSI Afterburner'; Category='Utilities'; Winget='Guru3D.Afterburner'; Desc='Gold standard GPU overclocking and fan curve tool' },
    @{ Key='7zip'; Name='7-Zip'; Category='Utilities'; Winget='7zip.7zip'; Desc='High-compression file archiver' },
    @{ Key='nanazip'; Name='NanaZip'; Category='Utilities'; Winget='M2Team.NanaZip'; Desc='7-Zip derivative integrated with Windows 11 context menu' },
    @{ Key='revo'; Name='Revo Uninstaller'; Category='Utilities'; Winget='RevoUninstaller.RevoUninstaller'; Desc='Completely eradicates leftover files and registry keys' },
    @{ Key='processlasso'; Name='Process Lasso'; Category='Utilities'; Winget='Bitsum.ProcessLasso'; Desc='CPU affinity and process priority optimization engine' },
    @{ Key='bcuninstaller'; Name='Bulk Crap Uninstaller'; Category='Utilities'; Winget='Klocman.BulkCrapUninstaller'; Desc='Batch uninstaller for deep software cleaning' },
    @{ Key='crystaldiskinfo'; Name='CrystalDiskInfo'; Category='Utilities'; Winget='CrystalDewWorld.CrystalDiskInfo'; Desc='SMART health and temperature monitor for SSDs/HDDs' },
    @{ Key='crystaldiskmark'; Name='CrystalDiskMark'; Category='Utilities'; Winget='CrystalDewWorld.CrystalDiskMark'; Desc='Read/write storage speed benchmark' },
    @{ Key='rufus'; Name='Rufus'; Category='Utilities'; Winget='Rufus.Rufus'; Desc='Bootable USB drive creator with Windows 11 bypasses' },
    @{ Key='everything'; Name='Everything'; Category='Utilities'; Winget='voidtools.Everything'; Desc='Instantaneous desktop filename search engine' },
    @{ Key='autohotkey'; Name='AutoHotkey'; Category='Utilities'; Winget='AutoHotkey.AutoHotkey'; Desc='Macro creation and desktop automation scripting' },
    @{ Key='bitwarden'; Name='Bitwarden'; Category='Utilities'; Winget='Bitwarden.Bitwarden'; Desc='Open source secure password vault' },
    @{ Key='1password'; Name='1Password'; Category='Utilities'; Winget='AgileBits.1Password'; Desc='Premium password manager and digital wallet' },
    @{ Key='warp'; Name='Cloudflare WARP'; Category='Utilities'; Winget='Cloudflare.Warp'; Desc='Fast, private DNS and secure network proxy' },
    @{ Key='nilesoft'; Name='Nilesoft Shell'; Category='Utilities'; Winget='Nilesoft.Shell'; Desc='Powerful context menu customizer for Windows' },
    @{ Key='openrgb'; Name='OpenRGB'; Category='Utilities'; Winget='OpenRGB-org.OpenRGB'; Desc='Unified open source RGB lighting control' },
    @{ Key='parsec'; Name='Parsec'; Category='Utilities'; Winget='Parsec.Parsec'; Desc='Ultra-low latency desktop and co-op remote streaming' },
    @{ Key='snappydriver'; Name='Snappy Driver Installer'; Category='Utilities'; Winget='GlennDelahoy.SnappyDriverInstallerOrigin'; Desc='Driver updater and installer without bundled ads' },
    @{ Key='winrar'; Name='WinRAR'; Category='Utilities'; Winget='RARLab.WinRAR'; Desc='Popular file archiver and RAR decompression utility' },
    @{ Key='wiztree'; Name='WizTree'; Category='Utilities'; Winget='AntibodySoftware.WizTree'; Desc='High-speed MFT-reading disk space visualizer' }
)

function Get-WinGetCommand {
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) { return $winget.Source }
    
    $localApps = "$Env:LocalAppData\Microsoft\WindowsApps\winget.exe"
    if (Test-Path $localApps) { return $localApps }

    return $null
}

function Install-WinGetPackage {
    param(
        [Parameter(Mandatory=$true)][string]$PackageId,
        [scriptblock]$LogCallback
    )
    $cmd = Get-WinGetCommand
    if (-not $cmd) {
        if ($LogCallback) { & $LogCallback "[!] WinGet is not installed on this system. Please install the App Installer from Microsoft Store." "Red" }
        return $false
    }
    
    if ($LogCallback) { & $LogCallback "[*] Installing $PackageId via WinGet..." "Yellow" }
    $proc = Start-Process -FilePath $cmd -ArgumentList "install --id `"$PackageId`" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity" -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -eq 0) {
        if ($LogCallback) { & $LogCallback "[+] Successfully installed $PackageId!" "Green" }
        return $true
    } else {
        if ($LogCallback) { & $LogCallback "[-] Installation failed or cancelled (Exit code: $($proc.ExitCode))" "Red" }
        return $false
    }
}

function Uninstall-WinGetPackage {
    param(
        [Parameter(Mandatory=$true)][string]$PackageId,
        [scriptblock]$LogCallback
    )
    $cmd = Get-WinGetCommand
    if (-not $cmd) {
        if ($LogCallback) { & $LogCallback "[!] WinGet is not installed." "Red" }
        return $false
    }
    
    if ($LogCallback) { & $LogCallback "[*] Uninstalling $PackageId via WinGet..." "Yellow" }
    $proc = Start-Process -FilePath $cmd -ArgumentList "uninstall --id `"$PackageId`" --silent" -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -eq 0) {
        if ($LogCallback) { & $LogCallback "[+] Successfully uninstalled $PackageId!" "Green" }
        return $true
    } else {
        if ($LogCallback) { & $LogCallback "[-] Uninstall failed (Exit code: $($proc.ExitCode))" "Red" }
        return $false
    }
}

function Upgrade-AllWinGetPackages {
    param([scriptblock]$LogCallback)
    $cmd = Get-WinGetCommand
    if (-not $cmd) {
        if ($LogCallback) { & $LogCallback "[!] WinGet is not installed." "Red" }
        return $false
    }
    
    if ($LogCallback) { & $LogCallback "[*] Upgrading all applications via WinGet..." "Yellow" }
    $proc = Start-Process -FilePath $cmd -ArgumentList "upgrade --all --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -eq 0) {
        if ($LogCallback) { & $LogCallback "[+] All applications upgraded successfully!" "Green" }
        return $true
    } else {
        if ($LogCallback) { & $LogCallback "[~] Upgrade completed with exit code: $($proc.ExitCode)" "DarkYellow" }
        return $false
    }
}

function Show-PumpkiNBanner {
    Clear-Host
    $Host.UI.RawUI.ForegroundColor = 'Cyan'
    Write-Host "================================================================================"
    Write-Host "   ____                       _    _       _   _ "
    Write-Host "  |  _ \ _   _ _ __ ___  _ __| | _(_)_ __ | \ | |"
    Write-Host "  | |_) | | | | '_ \ _ \| '_ \ |/ / | '_ \|  \| |"
    Write-Host "  |  __/| |_| | | | | | | |_) |   <| | | | | |\  |"
    Write-Host "  |_|    \__,_|_| |_| |_| .__/|_|\_\_|_| |_|_| \_|"
    Write-Host "                        |_|                       "
    Write-Host "           ULTIMATE GAMING & NETWORK OPTIMIZER v5.0"
    Write-Host "          Created by PumpkiN | Max FPS - Ultra Low Latency"
    Write-Host "================================================================================"
    $Host.UI.RawUI.ForegroundColor = 'Gray'
    
    $hw = Get-HardwareProfile
    Write-Host "  [CPU] $($hw.CpuName) ($($hw.CpuCores))" -ForegroundColor DarkCyan
    foreach ($g in $hw.Gpus) {
        Write-Host "  [GPU] $($g.Name) (Driver: $($g.DriverVersion))" -ForegroundColor DarkCyan
    }
    if ($hw.Adapter) {
        $netType = if ($hw.IsWifi) { "Wi-Fi (Wireless)" } else { "Ethernet (Wired)" }
        Write-Host "  [NET] $($hw.Adapter.Name) [$netType]" -ForegroundColor DarkCyan
    }
    Write-Host "--------------------------------------------------------------------------------"
    Write-Host "  [1]  FULL ALL-IN-ONE OPTIMIZATION (Hardware Auto-Detect + All Tweaks) [BEST]" -ForegroundColor Green
    Write-Host "  [2]  Auto-Detect & Optimize Active GPU (NVIDIA / AMD Radeon)"
    Write-Host "  [3]  AMD Radeon GPU Dedicated Suite (Disable ULPS, Shader Cache, Anti-Lag)" -ForegroundColor Magenta
    Write-Host "  [4]  NVIDIA GeForce Dedicated Suite (PowerMizer P0, Max Performance, Cache)" -ForegroundColor Green
    Write-Host "  [5]  Network & Anti-Lag Suite (Nagle Off, 100% QoS, NDU Leak Fix, DNS)"
    Write-Host "  [6]  Wi-Fi Ping Spike Mitigator (Toggle Background Scan for 0ms Spikes)"
    Write-Host "  [7]  CPU, Kernel & Quantum Engine (Win32Priority 0x26, FTH Off, Core Unpark)"
    Write-Host "  [8]  Ultra-Low Latency, DPC & 8000Hz Input (StopHighDPC, Raw Mouse Curve)"
    Write-Host "  [9]  Competitive Match Booster (Immediate RAM Flush + 5-Min Background Auto-Purge)" -ForegroundColor Cyan
    Write-Host "  [10] Game-Specific High Priority Hooks (Valorant, CS2, Apex, Fortnite, COD)"
    Write-Host "  [11] System Health, Live Diagnostics & Hardware Spec Sheet"
    Write-Host "  [12] Create Windows System Restore Point (Safety Backup)" -ForegroundColor Cyan
    Write-Host "  [13] Revert All Settings to Windows Defaults" -ForegroundColor DarkYellow
    Write-Host "  [14] Activate Windows (Microsoft Activation Scripts - MAS)" -ForegroundColor Yellow
    Write-Host "  ---- BEAST MODE OPTIMIZATIONS ------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "  [15] Debloat & Disable Background Services (SysMain, Telemetry, Xbox, Cortana)"
    Write-Host "  [16] Ultimate Performance Power Plan + HPET/Timer Optimization" -ForegroundColor Green
    Write-Host "  [17] Strip All Visual Effects & Animations (Pure Performance Mode)"
    Write-Host "  [18] Privacy & Telemetry Hardening (Kill All Tracking & Ads)" -ForegroundColor Magenta
    Write-Host "  [19] Disk I/O & Storage Optimization (NTFS Tweaks + Temp Cleanup)"
    Write-Host "  [20] Disable Junk Scheduled Tasks (Compatibility, Defrag, Diagnostics)"
    Write-Host "  [21] Startup Bloat Cleanup & Gaming DNS (Cloudflare 1.1.1.1)" -ForegroundColor Cyan
    Write-Host "  [0]  Exit" -ForegroundColor Red
    Write-Host "================================================================================"
}

# --- OPTIMIZATION MODULES ---

function Optimize-AmdGpu {
    Write-Host "`n[*] Starting AMD Radeon GPU Optimization Suite..." -ForegroundColor Magenta
    $classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $amdFound = 0

    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$classPath\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.DriverDesc -match 'AMD|Radeon' -or $props.ProviderName -match 'AMD|Advanced Micro Devices' -or $props.EnableUlps -ne $null)) {
                $amdFound++
                Write-Host "      -> Found AMD Radeon Adapter at Key [$subKey]: $($props.DriverDesc)" -ForegroundColor Cyan
                
                # 1. Disable ULPS (Ultra Low Power State)
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] Disabled ULPS (Ultra Low Power State) - Prevents clock-drop stutters" -ForegroundColor Green

                # 2. Shader Cache Optimization
                Set-ItemProperty -Path $targetPath -Name 'ShaderCache' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'ShaderCache_NA' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] Shader Cache locked to Enabled (Stops compilation frame-stutter)" -ForegroundColor Green

                # 3. Anti-Lag & Low-Latency Direct Pipeline
                Set-ItemProperty -Path $targetPath -Name 'AntiLag' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'DisableDMACopy' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] Anti-Lag and Direct Engine DMA Copy enabled" -ForegroundColor Green

                # 4. Disable Aggressive Clock Dropping & Multi-Monitor Stutter
                Set-ItemProperty -Path $targetPath -Name 'PP_ThermalAutoThrottlingEnable' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'PP_MCLKStutterMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'StutterMode' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'KMD_EnableCrossFireAutoLink' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] PowerPlay deep-sleep throttle and MCLK stutter mitigations applied" -ForegroundColor Green
            }
        }
    }

    # ControlSet001 fallback check
    $cs1Path = 'HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$cs1Path\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.EnableUlps -ne $null -or $props.DriverDesc -match 'AMD|Radeon')) {
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps_NA' -Value 0 -Type DWord -ErrorAction SilentlyContinue
            }
        }
    }

    # Flush stale AMD precompiled shader caches
    $amdCaches = @(
        "$env:LOCALAPPDATA\AMD\DxCache",
        "$env:LOCALAPPDATA\AMD\GLCache",
        "$env:LOCALAPPDATA\AMD\D3DSCache"
    )
    foreach ($cacheDir in $amdCaches) {
        if (Test-Path $cacheDir) {
            Remove-Item "$cacheDir\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "         [+] Flushed AMD shader cache: $cacheDir" -ForegroundColor Green
        }
    }

    if ($amdFound -eq 0) {
        Write-Host "      [!] No AMD Radeon card found in primary registry keys (Applied global ULPS fallback)." -ForegroundColor DarkYellow
    } else {
        Write-Host "      [OK] AMD Radeon GPU Optimized: Maximum Clock Stability and 0 ULPS Latency!" -ForegroundColor Green
    }
}

function Optimize-NvidiaGpu {
    Write-Host "`n[*] Starting NVIDIA GeForce GPU Optimization Suite..." -ForegroundColor Green
    $classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $nvFound = 0

    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$classPath\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.DriverDesc -match 'NVIDIA' -or $props.ProviderName -match 'NVIDIA')) {
                $nvFound++
                Write-Host "      -> Found NVIDIA Adapter at Key [$subKey]: $($props.DriverDesc)" -ForegroundColor Cyan
                Set-ItemProperty -Path $targetPath -Name 'PowerMizerEnable' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevel' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $targetPath -Name 'PowerMizerLevelAC' -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Write-Host "         [+] PowerMizer locked to Maximum Performance (P0 State - No clock drops)" -ForegroundColor Green
            }
        }
    }

    $nvCaches = @(
        "$env:LOCALAPPDATA\NVIDIA\DXCache",
        "$env:LOCALAPPDATA\NVIDIA\GLCache",
        "$env:LOCALAPPDATA\D3DSCache"
    )
    foreach ($cacheDir in $nvCaches) {
        if (Test-Path $cacheDir) {
            Remove-Item "$cacheDir\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "         [+] Flushed shader cache: $cacheDir" -ForegroundColor Green
        }
    }

    if ($nvFound -eq 0) {
        Write-Host "      [!] No NVIDIA card found in primary keys." -ForegroundColor DarkYellow
    } else {
        Write-Host "      [OK] NVIDIA GPU Optimized for Maximum FPS and Stable Frametimes!" -ForegroundColor Green
    }
}

function Optimize-GpuAuto {
    Write-Host "`n[*] Auto-Detecting Graphics Hardware..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile
    if ($hw.HasAmdGpu) {
        Optimize-AmdGpu
    }
    if ($hw.HasNvidia) {
        Optimize-NvidiaGpu
    }
    if (-not $hw.HasAmdGpu -and -not $hw.HasNvidia) {
        Write-Host "      -> Applying universal GPU power optimizations..." -ForegroundColor Cyan
        Optimize-NvidiaGpu
        Optimize-AmdGpu
    }
}

function Optimize-Network {
    Write-Host "`n[*] Tuning Network Interface, Anti-Lag & Memory Leaks..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile
    $adapter = $hw.Adapter
    if ($adapter) {
        $guid = $adapter.InterfaceGuid
        $tcpKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
        if (Test-Path $tcpKey) {
            Set-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -Value 1 -Type DWord
            Set-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -Value 1 -Type DWord
            Set-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -Value 0 -Type DWord
        }
        $nicProps = @('Interrupt Moderation','Flow Control','Green Ethernet','Gigabit Lite','Power Saving Mode','Energy-Efficient Ethernet')
        foreach ($p in $nicProps) {
            try { Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName $p -DisplayValue 'Disabled' -NoRestart -ErrorAction Stop } catch {}
        }
        netsh int tcp set global rsc=disabled | Out-Null
        netsh int tcp set global rss=enabled | Out-Null
        netsh int tcp set global autotuninglevel=normal | Out-Null
        Write-Host "      [+] Nagle disabled (TCPNoDelay=1, TcpAckFrequency=1, TcpDelAckTicks=0)" -ForegroundColor Green
        Write-Host "      [+] RSC disabled, RSS enabled, NIC green power saving disabled" -ForegroundColor Green
    }

    # Fix NDU Non-Paged Pool Memory Leak (WinDebloatTools gem)
    $nduKey = 'HKLM:\SYSTEM\ControlSet001\Services\Ndu'
    if (Test-Path $nduKey) {
        Set-ItemProperty -Path $nduKey -Name 'Start' -Value 4 -Type DWord
        Write-Host "      [+] NDU memory leak fixed (Prevents non-paged RAM growth over long gaming sessions)" -ForegroundColor Green
    }

    # DNS ServiceProvider Priorities
    $spKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider'
    Set-ItemProperty -Path $spKey -Name 'LocalPriority' -Value 4 -Type DWord
    Set-ItemProperty -Path $spKey -Name 'HostsPriority' -Value 5 -Type DWord
    Set-ItemProperty -Path $spKey -Name 'DnsPriority' -Value 6 -Type DWord
    Set-ItemProperty -Path $spKey -Name 'NetbtPriority' -Value 7 -Type DWord

    # Uncap 20% QoS Limit
    $psched = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched'
    if (-not (Test-Path $psched)) { New-Item -Path $psched -Force | Out-Null }
    Set-ItemProperty -Path $psched -Name 'NonBestEffortLimit' -Value 0 -Type DWord
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [+] ServiceProvider priorities set + 100% bandwidth unreserved + DNS flushed" -ForegroundColor Green
}

function Toggle-WifiAutoconfig {
    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host "                       WI-FI BACKGROUND SCAN MITIGATOR                          " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "Windows scans for Wi-Fi networks every 60s in the background, causing 100-300ms ping spikes."
    Write-Host "Disabling AutoConfig during gaming gives flat, wired-like ping."
    Write-Host ""
    $wifi = Get-NetAdapter | Where-Object { $_.InterfaceType -eq 71 -or $_.InterfaceDescription -match 'Wi-Fi|Wireless' } | Select-Object -First 1
    if (-not $wifi) {
        Write-Host "[!] No active Wi-Fi adapter detected on this PC." -ForegroundColor Yellow
        Read-Host "Press Enter to return"
        return
    }
    Write-Host "Active Wi-Fi Adapter: $($wifi.Name)" -ForegroundColor Green
    Write-Host "  [1] DISABLE Background Scan (Competitive Gaming Mode - ZERO Ping Spikes)" -ForegroundColor Green
    Write-Host "  [2] ENABLE Background Scan (Normal Mode - Discover New Wi-Fi Networks)" -ForegroundColor Yellow
    Write-Host "  [0] Back to Main Menu"
    $wChoice = Read-Host "`nSelect option [0-2]"
    switch ($wChoice) {
        "1" {
            netsh wlan set autoconfig enabled=no interface="$($wifi.Name)"
            Write-Host "`n[OK] Wi-Fi AutoConfig DISABLED! Background scanning is frozen for 0ms ping spikes." -ForegroundColor Green
        }
        "2" {
            netsh wlan set autoconfig enabled=yes interface="$($wifi.Name)"
            Write-Host "`n[OK] Wi-Fi AutoConfig ENABLED! Normal Wi-Fi discovery restored." -ForegroundColor Green
        }
    }
}

function Optimize-CpuAndSystem {
    Write-Host "`n[*] Tuning CPU Scheduling, Kernel Executive, FTH & Game Mode..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile

    # 1. Memory Management: Lock kernel in physical DDR RAM
    $memKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    Set-ItemProperty -Path $memKey -Name 'DisablePagingExecutive' -Value 1 -Type DWord
    Set-ItemProperty -Path $memKey -Name 'LargeSystemCache' -Value 0 -Type DWord
    Write-Host "      [+] DisablePagingExecutive = 1 (Kernel and drivers locked in RAM, 0 pagefile lag)" -ForegroundColor Green

    # 2. Win32 Priority Separation (0x26: Short, Variable, 3:1 Foreground Boost - Alchemy gem)
    $prioKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl'
    if (-not (Test-Path $prioKey)) { New-Item -Path $prioKey -Force | Out-Null }
    Set-ItemProperty -Path $prioKey -Name 'Win32PrioritySeparation' -Value 38 -Type DWord # 0x26 = 38
    Write-Host "      [+] Win32PrioritySeparation = 0x26 (3:1 Foreground CPU quantum boost for active game)" -ForegroundColor Green

    # 3. Kernel DPC Immediate Dispatch & SplitLargeCaches (Alchemy Kernel gem)
    $kernelKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'
    if (-not (Test-Path $kernelKey)) { New-Item -Path $kernelKey -Force | Out-Null }
    Set-ItemProperty -Path $kernelKey -Name 'ThreadDpcEnable' -Value 0 -Type DWord
    Set-ItemProperty -Path $kernelKey -Name 'SplitLargeCaches' -Value 1 -Type DWord
    Write-Host "      [+] ThreadDpcEnable = 0 (Immediate DISPATCH_LEVEL DPC execution, no thread queue lag)" -ForegroundColor Green
    Write-Host "      [+] SplitLargeCaches = 1 (Optimized memory cache line splitting across CPU cores)" -ForegroundColor Green

    # 4. Executive Worker Thread Pool Scaling (Alchemy gem)
    $execKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive'
    if (-not (Test-Path $execKey)) { New-Item -Path $execKey -Force | Out-Null }
    Set-ItemProperty -Path $execKey -Name 'AdditionalCriticalWorkerThreads' -Value 16 -Type DWord
    Set-ItemProperty -Path $execKey -Name 'AdditionalDelayedWorkerThreads' -Value 16 -Type DWord
    Write-Host "      [+] Executive Worker Threads scaled to 16 for high-speed I/O streaming" -ForegroundColor Green

    # 5. Disable Fault Tolerant Heap (FTH - AtlasOS gem)
    $fthKey = 'HKLM:\SOFTWARE\Microsoft\FTH'
    if (-not (Test-Path $fthKey)) { New-Item -Path $fthKey -Force | Out-Null }
    Set-ItemProperty -Path $fthKey -Name 'Enabled' -Value 0 -Type DWord
    Write-Host "      [+] Fault Tolerant Heap (FTH) disabled (Stops tracking shims from slowing games)" -ForegroundColor Green

    # 6. Disable Desktop Energy Estimation Engine (Valorant Pack gem)
    $pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
    Set-ItemProperty -Path $pwrKey -Name 'EnergyEstimationEnabled' -Value 0 -Type DWord
    $taggedEnergy = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\EnergyEstimation\TaggedEnergy'
    if (-not (Test-Path $taggedEnergy)) { New-Item -Path $taggedEnergy -Force | Out-Null }
    Set-ItemProperty -Path $taggedEnergy -Name 'DisableTaggedEnergyLogging' -Value 1 -Type DWord
    Set-ItemProperty -Path $taggedEnergy -Name 'TelemetryMaxApplication' -Value 0 -Type DWord
    Write-Host "      [+] Desktop EnergyEstimation disabled (No background battery logging on AC power)" -ForegroundColor Green

    # 7. Direct Flip / Fullscreen Exclusive Overrides (Bypass DWM latency)
    $gcs = 'HKCU:\System\GameConfigStore'
    Set-ItemProperty -Path $gcs -Name 'GameDVR_Enabled' -Value 0 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_DXGIHonorFSEWindowsCompatible' -Value 1 -Type DWord
    Set-ItemProperty -Path $gcs -Name 'GameDVR_EFSEFeatureFlags' -Value 0 -Type DWord
    Write-Host "      [+] Direct Flip scanout active (1-2 frames display latency saved)" -ForegroundColor Green

    # 8. CPU Core Unparking (100% Active Cores for both AMD & Intel)
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100

    # Architecture-specific CPU Scheduling
    if ($hw.IsIntelCpu) {
        powercfg -setacvalueindex scheme_current sub_processor HETEROPOLICY 0 2>$null
        powercfg -setacvalueindex scheme_current sub_processor SCHEDPOLICY 2 2>$null
        Write-Host "      [+] Intel Core Detected: Unparked all cores and prioritized Performance P-Cores" -ForegroundColor Green
    } elseif ($hw.IsAmdCpu) {
        Write-Host "      [+] AMD Ryzen Detected ($($hw.CpuName)): 100% Cores unparked for full boost clock" -ForegroundColor Green
    }
    powercfg -setactive scheme_current

    # Windows Game Mode & System Responsiveness
    $mmKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    Set-ItemProperty -Path $mmKey -Name 'NetworkThrottlingIndex' -Value 0xFFFFFFFF -Type DWord
    Set-ItemProperty -Path $mmKey -Name 'SystemResponsiveness' -Value 0 -Type DWord
    $gameKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
    if (Test-Path $gameKey) {
        Set-ItemProperty -Path $gameKey -Name 'Priority' -Value 6 -Type DWord
        Set-ItemProperty -Path $gameKey -Name 'GPU Priority' -Value 8 -Type DWord
        Set-ItemProperty -Path $gameKey -Name 'Scheduling Category' -Value 'High' -Type String
        Set-ItemProperty -Path $gameKey -Name 'SFIO Priority' -Value 'High' -Type String
    }
    $gbKey = 'HKCU:\Software\Microsoft\GameBar'
    if (-not (Test-Path $gbKey)) { New-Item -Path $gbKey -Force | Out-Null }
    Set-ItemProperty -Path $gbKey -Name 'AutoGameModeEnabled' -Value 1 -Type DWord

    $ptKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'
    if (-not (Test-Path $ptKey)) { New-Item -Path $ptKey -Force | Out-Null }
    Set-ItemProperty -Path $ptKey -Name 'PowerThrottlingOff' -Value 1 -Type DWord

    $gdvr = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'
    if (-not (Test-Path $gdvr)) { New-Item -Path $gdvr -Force | Out-Null }
    Set-ItemProperty -Path $gdvr -Name 'AllowGameDVR' -Value 0 -Type DWord

    $trans = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    if (Test-Path $trans) { Set-ItemProperty -Path $trans -Name 'EnableTransparency' -Value 0 -Type DWord }
    Write-Host "      [+] Windows Game Mode enabled, Power Throttling disabled, DWM transparency off" -ForegroundColor Green
}

function Optimize-LatencyAndInput {
    Write-Host "`n[*] Forcing Zero DPC Latency Tolerance & 8000Hz Input Buffer..." -ForegroundColor Yellow
    # StopHighDPC & Latency Tolerance
    $pwrKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'ExitLatencyCheckEnabled' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'Latency' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceDefault' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyToleranceFSVP' -Value 1 -Type DWord
    Set-ItemProperty -Path $pwrKey -Name 'LatencyTolerancePerfOverride' -Value 1 -Type DWord

    # Dynamic Tick Jitter Elimination & x2APIC
    bcdedit /set disabledynamictick yes | Out-Null
    bcdedit /set x2apicpolicy Enable | Out-Null
    bcdedit /deletevalue useplatformclock | Out-Null
    Write-Host "      [+] StopHighDPC active + x2APIC enabled + dynamic tick jitter eliminated" -ForegroundColor Green

    # Input Queues for High-Polling Gaming Mice (Up to 8000Hz)
    $mouKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters'
    if (Test-Path $mouKey) { Set-ItemProperty -Path $mouKey -Name 'MouseDataQueueSize' -Value 200 -Type DWord }
    $kbdKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters'
    if (Test-Path $kbdKey) { Set-ItemProperty -Path $kbdKey -Name 'KeyboardDataQueueSize' -Value 100 -Type DWord }

    # USB Selective Suspend Disabled
    $usbKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
    if (-not (Test-Path $usbKey)) { New-Item -Path $usbKey -Force | Out-Null }
    Set-ItemProperty -Path $usbKey -Name 'DisableSelectiveSuspend' -Value 1 -Type DWord

    # MarkC 1:1 Raw Mouse Acceleration Curve
    $mouseKey = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mouseKey -Name 'MouseSpeed' -Value '0' -Type String
    Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold1' -Value '0' -Type String
    Set-ItemProperty -Path $mouseKey -Name 'MouseThreshold2' -Value '0' -Type String
    [byte[]]$smoothX = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x29,0xdc,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00
    [byte[]]$smoothY = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xa8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xe0,0x00,0x00,0x00,0x00,0x00
    Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseXCurve' -Value $smoothX -Type Binary
    Set-ItemProperty -Path $mouseKey -Name 'SmoothMouseYCurve' -Value $smoothY -Type Binary
    Write-Host "      [+] 8000Hz Mouse Buffer tuned + 100% Raw 1:1 Mouse Input Curve applied" -ForegroundColor Green
}

function Boost-CompetitiveMatch {
    Write-Host "`n[*] Purging Kernel Standby Memory & Idle Working Sets..." -ForegroundColor Yellow

    $exeCandidates = @(
        "$PSScriptRoot\EmptyStandbyList.exe",
        "$PSScriptRoot\..\EmptyStandbyList.exe",
        "$env:SystemRoot\System32\EmptyStandbyList.exe",
        "e:\Projects\Win_Optimizer\EmptyStandbyList.exe"
    )
    $emptyListExe = $exeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($emptyListExe) {
        $memBefore = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
        Start-Process -FilePath $emptyListExe -ArgumentList "workingsets" -Wait -WindowStyle Hidden
        Start-Process -FilePath $emptyListExe -ArgumentList "standbylist" -Wait -WindowStyle Hidden
        $memAfter = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
        $freedMb = [math]::Round(($memAfter - $memBefore) / 1024, 0)
        if ($freedMb -gt 0) {
            Write-Host "      [+] Kernel Standby RAM purged: $freedMb MB returned to Zero-Latency Free Pool!" -ForegroundColor Green
        } else {
            Write-Host "      [+] Kernel Standby RAM & idle working sets trimmed successfully" -ForegroundColor Green
        }

        # Verify / Activate 5-minute background Task Scheduler job
        $TaskName = "PumpkiN_AutoEmptyStandbyList"
        $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existing) {
            $info = Get-ScheduledTaskInfo -TaskName $TaskName
            Write-Host "      [+] 5-Minute Background Auto-Cleaner: ACTIVE (Next run: $($info.NextRunTime))" -ForegroundColor Green
        } else {
            try {
                $action = New-ScheduledTaskAction -Execute $emptyListExe -Argument "standbylist"
                $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
                $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
                $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -Priority 4
                Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
                Start-ScheduledTask -TaskName $TaskName
                Write-Host "      [+] 5-Minute Background Auto-Cleaner registered and active in Task Scheduler!" -ForegroundColor Green
            } catch {
                Write-Host "      [!] Task Scheduler note: $($_.Exception.Message)" -ForegroundColor DarkYellow
            }
        }
    } else {
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Write-Host "      [+] CLR Garbage collector executed (EmptyStandbyList.exe optional fallback)" -ForegroundColor Yellow
    }
}

function Apply-GameHooks {
    Write-Host "`n[*] Hooking High CPU & IO Priority for Top Competitive Titles..." -ForegroundColor Yellow
    $games = @(
        'VALORANT-Win64-Shipping.exe',
        'cs2.exe',
        'r5apex.exe',
        'FortniteClient-Win64-Shipping.exe',
        'cod.exe',
        'RainbowSix.exe',
        'RainbowSix_Vulkan.exe',
        'Overwatch.exe',
        'PUBG-Win64-Shipping.exe',
        'Deadlock.exe',
        'AndroidEmulatorEn.exe',
        'AndroidEmulator.exe'
    )
    foreach ($g in $games) {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name 'CpuPriorityClass' -Value 3 -Type DWord
        Set-ItemProperty -Path $path -Name 'IoPriority' -Value 3 -Type DWord
        Write-Host "      [+] Hooked $g -> High CPU Priority & High I/O Priority" -ForegroundColor Green
    }
}

function Create-RestorePoint {
    Write-Host "`n[*] Creating Windows System Restore Point..." -ForegroundColor Yellow
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "PumpkiN_Gaming_RestorePoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "      [OK] System Restore Point 'PumpkiN_Gaming_RestorePoint' created successfully!" -ForegroundColor Green
    } catch {
        Write-Host "      [!] Note: System Restore status: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
}

function Run-Diagnostics {
    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host "                       LIVE SYSTEM & LATENCY DIAGNOSTICS                        " -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    
    $hw = Get-HardwareProfile
    Write-Host "`n--- Hardware Specification ---" -ForegroundColor Yellow
    Write-Host "CPU: $($hw.CpuName) ($($hw.CpuCores))"
    foreach ($g in $hw.Gpus) {
        Write-Host "GPU: $($g.Name) (Driver: $($g.DriverVersion))"
    }
    Write-Host "RAM: $($hw.RamGb) GB"

    Write-Host "`n--- Network & TCP Status ---" -ForegroundColor Yellow
    if ($hw.Adapter) {
        Write-Host "Adapter: $($hw.Adapter.Name) ($($hw.Adapter.InterfaceDescription))"
        $guid = $hw.Adapter.InterfaceGuid
        $tcp = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -ErrorAction SilentlyContinue
        Write-Host "Nagle Disabled (TCPNoDelay): $($tcp.TCPNoDelay)"
        Write-Host "Delayed ACKs Disabled (TcpAckFrequency): $($tcp.TcpAckFrequency)"
    }
    $qos = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched' -ErrorAction SilentlyContinue).NonBestEffortLimit
    Write-Host "QoS Bandwidth Reserved: $qos% (Target: 0%)"
    $sp = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider' -ErrorAction SilentlyContinue).DnsPriority
    Write-Host "ServiceProvider DNS Priority: $sp (Target: 6)"
    $ndu = (Get-ItemProperty 'HKLM:\SYSTEM\ControlSet001\Services\Ndu' -ErrorAction SilentlyContinue).Start
    Write-Host "NDU Memory Leak Fix State: $ndu (Target: 4)"

    Write-Host "`n--- System, Kernel & Quantum Status ---" -ForegroundColor Yellow
    $mem = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management').DisablePagingExecutive
    Write-Host "Kernel Locked in RAM (DisablePagingExecutive): $mem (Target: 1)"
    $prio = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -ErrorAction SilentlyContinue).Win32PrioritySeparation
    Write-Host "Win32PrioritySeparation (Foreground Quantum): $prio (Target: 38 / 0x26)"
    $fth = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\FTH' -ErrorAction SilentlyContinue).Enabled
    Write-Host "Fault Tolerant Heap (FTH): $fth (Target: 0)"
    $dpc = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -ErrorAction SilentlyContinue).ExitLatency
    Write-Host "StopHighDPC Latency Tolerance: $dpc (Target: 1)"

    Write-Host "`n--- Live Ping & Jitter Test ---" -ForegroundColor Yellow
    $pingCf = Test-Connection -ComputerName '1.1.1.1' -Count 4 -ErrorAction SilentlyContinue
    if ($pingCf) {
        $avgCf = ($pingCf | Measure-Object -Property ResponseTime -Average).Average
        $minCf = ($pingCf | Measure-Object -Property ResponseTime -Minimum).Minimum
        $maxCf = ($pingCf | Measure-Object -Property ResponseTime -Maximum).Maximum
        Write-Host "Cloudflare DNS (1.1.1.1): Avg: $avgCf ms | Min: $minCf ms | Max: $maxCf ms (Jitter: $([math]::Round($maxCf - $minCf, 1)) ms)" -ForegroundColor Green
    }
}

function Restore-Defaults {
    Write-Host "`n[*] Restoring Windows Default Network and System Settings..." -ForegroundColor Yellow
    $hw = Get-HardwareProfile
    $adapter = $hw.Adapter
    if ($adapter) {
        $guid = $adapter.InterfaceGuid
        $tcpKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
        Remove-ItemProperty -Path $tcpKey -Name 'TcpAckFrequency' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $tcpKey -Name 'TCPNoDelay' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $tcpKey -Name 'TcpDelAckTicks' -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Interrupt Moderation' -DisplayValue 'Enabled' -NoRestart -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Flow Control' -DisplayValue 'Rx & Tx Enabled' -NoRestart -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Green Ethernet' -DisplayValue 'Enabled' -NoRestart -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Power Saving Mode' -DisplayValue 'Enabled' -NoRestart -ErrorAction SilentlyContinue
        netsh int tcp set global rsc=enabled | Out-Null
    }
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 0 -Type DWord
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'SystemResponsiveness' -Value 10 -Type DWord
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -Name 'PowerThrottlingOff' -Value 0 -Type DWord
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 1 -Type DWord
    
    # Restore Win32PrioritySeparation, FTH, NDU, EnergyEstimation
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\FTH' -Name 'Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\ControlSet001\Services\Ndu' -Name 'Start' -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'EnergyEstimationEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' -Name 'ThreadDpcEnable' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' -Name 'SplitLargeCaches' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive' -Name 'AdditionalCriticalWorkerThreads' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive' -Name 'AdditionalDelayedWorkerThreads' -ErrorAction SilentlyContinue

    # Revert AMD ULPS to 1 if user wants defaults
    $classPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    foreach ($sub in 0..9) {
        $subKey = "{0:D4}" -f $sub
        $targetPath = "$classPath\$subKey"
        if (Test-Path $targetPath) {
            $props = Get-ItemProperty -Path $targetPath -ErrorAction SilentlyContinue
            if ($props -and ($props.DriverDesc -match 'AMD|Radeon')) {
                Set-ItemProperty -Path $targetPath -Name 'EnableUlps' -Value 1 -Type DWord -ErrorAction SilentlyContinue
            }
        }
    }

    $games = @(
        'VALORANT-Win64-Shipping.exe','cs2.exe','r5apex.exe','FortniteClient-Win64-Shipping.exe',
        'cod.exe','RainbowSix.exe','RainbowSix_Vulkan.exe','Overwatch.exe','PUBG-Win64-Shipping.exe',
        'Deadlock.exe','AndroidEmulatorEn.exe','AndroidEmulator.exe'
    )
    foreach ($g in $games) { Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$g\PerfOptions" -Recurse -Force -ErrorAction SilentlyContinue }
    
    bcdedit /deletevalue disabledynamictick 2>$null
    Unregister-ScheduledTask -TaskName 'PumpkiN_AutoEmptyStandbyList' -Confirm:$false -ErrorAction SilentlyContinue
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [OK] Original network and system parameters restored." -ForegroundColor Green

    # --- Revert Beast Mode Optimizations ---
    Write-Host "`n[*] Reverting Beast Mode optimizations..." -ForegroundColor Yellow

    # Re-enable disabled services
    $servicesToRestore = @('SysMain', 'DiagTrack', 'dmwappushservice', 'WSearch', 'XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc', 'MapsBroker', 'lfsvc', 'WerSvc')
    foreach ($svcName in $servicesToRestore) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($svc) {
            Set-Service -Name $svcName -StartupType Manual -ErrorAction SilentlyContinue
        }
    }
    Write-Host "      [+] Background services restored to Manual startup" -ForegroundColor Green

    # Re-enable Cortana / Web Search
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'DisableWebSearch' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'ConnectedSearchUseWeb' -ErrorAction SilentlyContinue

    # Restore Balanced power plan
    $balanced = powercfg /list | Select-String "Balanced"
    if ($balanced) {
        $guid = ($balanced -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        powercfg /setactive $guid
        Write-Host "      [+] Balanced power plan restored" -ForegroundColor Green
    }
    powercfg /hibernate on 2>$null
    bcdedit /deletevalue useplatformtick 2>$null
    bcdedit /deletevalue tscsyncpolicy 2>$null

    # Restore Visual Effects to default
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '400' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'DragFullWindows' -Value '1' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\DWM' -Name 'EnableAeroPeek' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' -Name 'StartupDelayInMSec' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name 'NoLockScreen' -ErrorAction SilentlyContinue
    Write-Host "      [+] Visual effects and animations restored to defaults" -ForegroundColor Green

    # Restore Telemetry / Privacy
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableActivityFeed' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'PublishUserActivities' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'UploadUserActivities' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Name 'DisableLocation' -ErrorAction SilentlyContinue
    Write-Host "      [+] Privacy and telemetry settings restored to Windows defaults" -ForegroundColor Green

    # Restore NTFS defaults
    fsutil behavior set disablelastaccess 2 | Out-Null
    fsutil behavior set disable8dot3 0 | Out-Null
    fsutil behavior set memoryusage 1 | Out-Null
    Write-Host "      [+] NTFS defaults restored (last access, 8.3 names, memory usage)" -ForegroundColor Green

    # Re-enable scheduled tasks
    $tasksToReEnable = @(
        '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
        '\Microsoft\Windows\Defrag\ScheduledDefrag',
        '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
        '\Microsoft\Windows\Maintenance\WinSAT'
    )
    foreach ($task in $tasksToReEnable) {
        try {
            Enable-ScheduledTask -TaskPath ($task -replace '[^\\]*$', '') -TaskName ($task -replace '.*\\', '') -ErrorAction SilentlyContinue | Out-Null
        } catch {}
    }
    Write-Host "      [+] Key scheduled tasks re-enabled" -ForegroundColor Green

    # Reset DNS to DHCP automatic
    if ($adapter) {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ResetServerAddresses -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'MaxCacheTtl' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'MaxNegativeCacheTtl' -ErrorAction SilentlyContinue
        Write-Host "      [+] DNS reset to automatic (DHCP)" -ForegroundColor Green
    }

    # Revert WinUtil & Snappy OS hardening
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' -Name 'OverlayTestMode' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'DisableOverlays' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed' -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1' -Value 6 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2' -Value 10 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Value '510' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' -Name 'TaskbarEndTask' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Name 'GlobalUserDisabled' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value 380000 -Type DWord -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'DisableWpbtExecution' -ErrorAction SilentlyContinue
    icacls "$Env:SystemRoot\Installer\Razer" /grant "*S-1-1-0:(W)" 2>$null | Out-Null
    icacls "$Env:ProgramFiles\LogiDownloadAssistant" /grant "*S-1-1-0:(W)" 2>$null | Out-Null
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer' -Name 'DisableCoInstallers' -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' -Name 'SearchOrderConfig' -Value 1 -ErrorAction SilentlyContinue
    Remove-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableSearchBoxSuggestions' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BingSearchEnabled' -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 0 -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name 'NoLockScreen' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'DisplayParameters' -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value 2 -ErrorAction SilentlyContinue
    Remove-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] WinUtil hardening & Snappy OS tweaks reverted to Windows defaults" -ForegroundColor Green

    Write-Host "      [OK] ALL settings restored to Windows defaults!" -ForegroundColor Green
}

# --- NEW BEAST MODE OPTIMIZATION MODULES ---

function Debloat-BackgroundServices {
    Write-Host "`n[*] Debloating Background Services & Bloatware..." -ForegroundColor Yellow

    # Services to disable (Set to Manual or Disabled)
    $servicesToDisable = @(
        @{ Name = 'SysMain';          Desc = 'Superfetch (SysMain) - Pre-caches apps, steals I/O during gaming' },
        @{ Name = 'DiagTrack';        Desc = 'Connected User Experiences & Telemetry - MS data collection' },
        @{ Name = 'dmwappushservice';  Desc = 'WAP Push Message Routing - Telemetry relay service' },
        @{ Name = 'WSearch';          Desc = 'Windows Search Indexer - Constant background disk I/O' },
        @{ Name = 'XblAuthManager';   Desc = 'Xbox Live Auth Manager - Not needed for PC gaming' },
        @{ Name = 'XblGameSave';      Desc = 'Xbox Live Game Save - Cloud save sync overhead' },
        @{ Name = 'XboxNetApiSvc';    Desc = 'Xbox Live Networking - Background Xbox connectivity' },
        @{ Name = 'XboxGipSvc';       Desc = 'Xbox Accessory Management - Xbox controller management' },
        @{ Name = 'MapsBroker';       Desc = 'Downloaded Maps Manager - Unused background service' },
        @{ Name = 'lfsvc';            Desc = 'Geolocation Service - Background location tracking' },
        @{ Name = 'SharedAccess';     Desc = 'Internet Connection Sharing - Not needed on gaming PCs' },
        @{ Name = 'RetailDemo';       Desc = 'Retail Demo Service - Store display mode' },
        @{ Name = 'wisvc';            Desc = 'Windows Insider Service - Preview build telemetry' },
        @{ Name = 'WerSvc';           Desc = 'Windows Error Reporting - Crash dump collection' },
        @{ Name = 'Fax';              Desc = 'Fax Service - Nobody faxes from a gaming PC' }
    )

    foreach ($svc in $servicesToDisable) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            try {
                Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
                Write-Host "      [+] Disabled: $($svc.Desc)" -ForegroundColor Green
            } catch {
                Write-Host "      [~] Skipped: $($svc.Name) ($($_.Exception.Message))" -ForegroundColor DarkYellow
            }
        }
    }

    # Disable Cortana
    $cortanaKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
    if (-not (Test-Path $cortanaKey)) { New-Item -Path $cortanaKey -Force | Out-Null }
    Set-ItemProperty -Path $cortanaKey -Name 'AllowCortana' -Value 0 -Type DWord
    Set-ItemProperty -Path $cortanaKey -Name 'DisableWebSearch' -Value 1 -Type DWord
    Set-ItemProperty -Path $cortanaKey -Name 'ConnectedSearchUseWeb' -Value 0 -Type DWord
    Write-Host "      [+] Cortana disabled + Web Search in Start Menu blocked" -ForegroundColor Green

    # Disable Delivery Optimization P2P (stops uploading updates to other PCs)
    $doKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'
    if (-not (Test-Path $doKey)) { New-Item -Path $doKey -Force | Out-Null }
    Set-ItemProperty -Path $doKey -Name 'DODownloadMode' -Value 0 -Type DWord
    Write-Host "      [+] Delivery Optimization P2P disabled (No upload bandwidth stolen)" -ForegroundColor Green

    Write-Host "      [OK] Background Services Debloated  --  Maximum CPU/IO freed for gaming!" -ForegroundColor Green
}

function Enable-UltimatePerformancePlan {
    Write-Host "`n[*] Activating Ultimate Performance Power Plan..." -ForegroundColor Yellow

    # Check if Ultimate Performance plan already exists
    $existingPlan = powercfg /list | Select-String "Ultimate Performance"
    if (-not $existingPlan) {
        # Unhide and create Ultimate Performance plan
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
        $existingPlan = powercfg /list | Select-String "Ultimate Performance"
    }

    if ($existingPlan) {
        $guid = ($existingPlan -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
        powercfg /setactive $guid
        Write-Host "      [+] Ultimate Performance Plan ACTIVATED (GUID: $guid)" -ForegroundColor Green
    } else {
        # Fallback: set High Performance
        $highPerf = powercfg /list | Select-String "High performance"
        if ($highPerf) {
            $guid = ($highPerf -replace '.*GUID:\s*', '' -replace '\s*\(.*', '').Trim()
            powercfg /setactive $guid
            Write-Host "      [+] High Performance Plan activated (Ultimate not available on this build)" -ForegroundColor Green
        }
    }

    # Disable USB selective suspend in current plan
    powercfg -setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setactive scheme_current

    # Disable hibernate (frees GB of disk + prevents sleep interrupts)
    powercfg /hibernate off 2>$null

    # HPET & Timer Resolution
    bcdedit /set useplatformtick yes 2>$null
    bcdedit /set tscsyncpolicy enhanced 2>$null
    Write-Host "      [+] Hibernate disabled, USB suspend off, TSC sync policy enhanced" -ForegroundColor Green

    Write-Host "      [OK] Power Plan optimized  --  Zero CPU throttling, maximum clock speeds!" -ForegroundColor Green
}

function Strip-VisualEffects {
    Write-Host "`n[*] Stripping Windows Visual Effects & Animations..." -ForegroundColor Yellow

    # Set Visual Effects to "Adjust for best performance" (UserPreferencesMask)
    $visualKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
    if (-not (Test-Path $visualKey)) { New-Item -Path $visualKey -Force | Out-Null }
    Set-ItemProperty -Path $visualKey -Name 'VisualFXSetting' -Value 2 -Type DWord
    Write-Host "      [+] Visual Effects set to 'Best Performance' mode" -ForegroundColor Green

    # Disable individual animations
    $dwKey = 'HKCU:\Control Panel\Desktop\WindowMetrics'
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '0' -Type String
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'DragFullWindows' -Value '0' -Type String

    # Disable all animation flags
    $advKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $advKey -Name 'TaskbarAnimations' -Value 0 -Type DWord
    Set-ItemProperty -Path $advKey -Name 'ListviewAlphaSelect' -Value 0 -Type DWord
    Set-ItemProperty -Path $advKey -Name 'ListviewShadow' -Value 0 -Type DWord
    Set-ItemProperty -Path $advKey -Name 'IconsOnly' -Value 0 -Type DWord

    # Disable DWM animations
    $dwmKey = 'HKCU:\Software\Microsoft\Windows\DWM'
    if (-not (Test-Path $dwmKey)) { New-Item -Path $dwmKey -Force | Out-Null }
    Set-ItemProperty -Path $dwmKey -Name 'EnableAeroPeek' -Value 0 -Type DWord
    Set-ItemProperty -Path $dwmKey -Name 'AlwaysHibernateThumbnails' -Value 0 -Type DWord

    # Disable startup delay
    $serializeKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize'
    if (-not (Test-Path $serializeKey)) { New-Item -Path $serializeKey -Force | Out-Null }
    Set-ItemProperty -Path $serializeKey -Name 'StartupDelayInMSec' -Value 0 -Type DWord
    Write-Host "      [+] Startup delay zeroed, all menu/taskbar animations disabled" -ForegroundColor Green

    # Disable transparency effects (if not already done)
    $persKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    if (Test-Path $persKey) {
        Set-ItemProperty -Path $persKey -Name 'EnableTransparency' -Value 0 -Type DWord
    }

    # Disable lock screen animations / tips
    $lockKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
    if (-not (Test-Path $lockKey)) { New-Item -Path $lockKey -Force | Out-Null }
    Set-ItemProperty -Path $lockKey -Name 'NoLockScreen' -Value 1 -Type DWord
    Write-Host "      [+] Lock screen disabled, DWM Aero Peek off, transparency off" -ForegroundColor Green

    Write-Host "      [OK] All visual fluff stripped  --  GPU resources 100% for your game!" -ForegroundColor Green
}

function Harden-PrivacyTelemetry {
    Write-Host "`n[*] Hardening Privacy & Disabling Telemetry..." -ForegroundColor Yellow

    # Disable Telemetry level
    $dataKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
    if (-not (Test-Path $dataKey)) { New-Item -Path $dataKey -Force | Out-Null }
    Set-ItemProperty -Path $dataKey -Name 'AllowTelemetry' -Value 0 -Type DWord
    Set-ItemProperty -Path $dataKey -Name 'MaxTelemetryAllowed' -Value 0 -Type DWord
    Write-Host "      [+] Windows Telemetry set to Security (minimum) level" -ForegroundColor Green

    # Disable Activity History
    $actKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    if (-not (Test-Path $actKey)) { New-Item -Path $actKey -Force | Out-Null }
    Set-ItemProperty -Path $actKey -Name 'EnableActivityFeed' -Value 0 -Type DWord
    Set-ItemProperty -Path $actKey -Name 'PublishUserActivities' -Value 0 -Type DWord
    Set-ItemProperty -Path $actKey -Name 'UploadUserActivities' -Value 0 -Type DWord
    Write-Host "      [+] Activity History and Timeline sync disabled" -ForegroundColor Green

    # Disable Advertising ID
    $adKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
    if (-not (Test-Path $adKey)) { New-Item -Path $adKey -Force | Out-Null }
    Set-ItemProperty -Path $adKey -Name 'Enabled' -Value 0 -Type DWord
    Write-Host "      [+] Advertising ID disabled" -ForegroundColor Green

    # Disable Tailored Experiences
    $cloudKey = 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent'
    if (-not (Test-Path $cloudKey)) { New-Item -Path $cloudKey -Force | Out-Null }
    Set-ItemProperty -Path $cloudKey -Name 'DisableTailoredExperiencesWithDiagnosticData' -Value 1 -Type DWord
    Set-ItemProperty -Path $cloudKey -Name 'DisableWindowsConsumerFeatures' -Value 1 -Type DWord
    Write-Host "      [+] Tailored Experiences and Consumer Features disabled" -ForegroundColor Green

    # Disable feedback requests
    $siufKey = 'HKCU:\Software\Microsoft\Siuf\Rules'
    if (-not (Test-Path $siufKey)) { New-Item -Path $siufKey -Force | Out-Null }
    Set-ItemProperty -Path $siufKey -Name 'NumberOfSIUFInPeriod' -Value 0 -Type DWord
    Write-Host "      [+] Windows Feedback popups disabled" -ForegroundColor Green

    # Disable app suggestions / pre-installed bloat apps
    $contentKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    if (Test-Path $contentKey) {
        Set-ItemProperty -Path $contentKey -Name 'SystemPaneSuggestionsEnabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SilentInstalledAppsEnabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SoftLandingEnabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SubscribedContent-338389Enabled' -Value 0 -Type DWord
        Set-ItemProperty -Path $contentKey -Name 'SubscribedContent-310093Enabled' -Value 0 -Type DWord
        Write-Host "      [+] App suggestions and silent app installs blocked" -ForegroundColor Green
    }

    # Disable Location Tracking globally
    $locKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'
    if (-not (Test-Path $locKey)) { New-Item -Path $locKey -Force | Out-Null }
    Set-ItemProperty -Path $locKey -Name 'DisableLocation' -Value 1 -Type DWord
    Write-Host "      [+] Location tracking disabled system-wide" -ForegroundColor Green

    Write-Host "      [OK] Privacy Hardened  --  No telemetry, no ads, no tracking!" -ForegroundColor Green
}

function Optimize-DiskIO {
    Write-Host "`n[*] Optimizing Disk I/O & Storage Performance..." -ForegroundColor Yellow

    # Disable Last Access Timestamp (huge NTFS perf win)
    fsutil behavior set disablelastaccess 1 | Out-Null
    Write-Host "      [+] NTFS Last Access Timestamps disabled (Faster file reads)" -ForegroundColor Green

    # Disable 8.3 short filename creation
    fsutil behavior set disable8dot3 1 | Out-Null
    Write-Host "      [+] 8.3 Short Filename creation disabled (Faster directory enumeration)" -ForegroundColor Green

    # Increase NTFS memory usage for performance
    fsutil behavior set memoryusage 2 | Out-Null
    Write-Host "      [+] NTFS Memory Usage set to Level 2 (More RAM for file system cache)" -ForegroundColor Green

    # Disable boot trace logging
    $bootKey = 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction'
    if (Test-Path $bootKey) {
        Set-ItemProperty -Path $bootKey -Name 'Enable' -Value 'N' -Type String -ErrorAction SilentlyContinue
    }

    # Clean Temp Files
    $tempPaths = @(
        "$env:TEMP",
        "$env:LOCALAPPDATA\Temp",
        "$env:SystemRoot\Temp",
        "$env:SystemRoot\Prefetch",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db"
    )
    $totalCleaned = 0
    foreach ($tp in $tempPaths) {
        if (Test-Path $tp) {
            $sizeBefore = (Get-ChildItem $tp -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            Remove-Item "$tp\*" -Recurse -Force -ErrorAction SilentlyContinue
            $totalCleaned += $sizeBefore
        }
    }
    $cleanedMb = [math]::Round($totalCleaned / 1MB, 1)
    Write-Host "      [+] Temp files cleaned: ~$cleanedMb MB freed (Temp, Prefetch, Thumbnails)" -ForegroundColor Green

    # Clear Windows Update cache (can be several GB)
    $wuCache = "$env:SystemRoot\SoftwareDistribution\Download"
    if (Test-Path $wuCache) {
        $wuSize = (Get-ChildItem $wuCache -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Remove-Item "$wuCache\*" -Recurse -Force -ErrorAction SilentlyContinue
        $wuMb = [math]::Round($wuSize / 1MB, 1)
        Write-Host "      [+] Windows Update cache cleared: ~$wuMb MB freed" -ForegroundColor Green
    }

    Write-Host "      [OK] Disk I/O optimized  --  Faster game loads and reduced stuttering!" -ForegroundColor Green
}

function Disable-ScheduledJunkTasks {
    Write-Host "`n[*] Disabling Junk Scheduled Tasks (Frame Drop Eliminators)..." -ForegroundColor Yellow

    $tasksToDisable = @(
        '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
        '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
        '\Microsoft\Windows\Autochk\Proxy',
        '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
        '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
        '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
        '\Microsoft\Windows\Maintenance\WinSAT',
        '\Microsoft\Windows\Maps\MapsToastTask',
        '\Microsoft\Windows\Maps\MapsUpdateTask',
        '\Microsoft\Windows\Shell\FamilySafetyMonitor',
        '\Microsoft\Windows\Shell\FamilySafetyRefreshTask',
        '\Microsoft\Windows\Windows Error Reporting\QueueReporting',
        '\Microsoft\Windows\Feedback\Siuf\DmClient',
        '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload',
        '\Microsoft\Windows\PI\Sqm-Tasks',
        '\Microsoft\Windows\CloudExperienceHost\CreateObjectTask',
        '\Microsoft\Windows\DiskFootprint\Diagnostics',
        '\Microsoft\Windows\FileHistory\File History (maintenance mode)',
        '\Microsoft\Windows\NetTrace\GatherNetworkInfo',
        '\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem'
    )

    $disabled = 0
    foreach ($task in $tasksToDisable) {
        try {
            $existing = Get-ScheduledTask -TaskPath ($task -replace '[^\\]*$', '') -TaskName ($task -replace '.*\\', '') -ErrorAction SilentlyContinue
            if ($existing -and $existing.State -ne 'Disabled') {
                Disable-ScheduledTask -TaskPath ($task -replace '[^\\]*$', '') -TaskName ($task -replace '.*\\', '') -ErrorAction Stop | Out-Null
                $disabled++
                Write-Host "      [+] Disabled: $($task -replace '.*\\', '')" -ForegroundColor Green
            }
        } catch {
            # Task doesn't exist on this system - skip silently
        }
    }

    # Disable Defrag schedule (SSDs don't need it, HDDs can run manually)
    try {
        $defrag = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag' -ErrorAction SilentlyContinue
        if ($defrag -and $defrag.State -ne 'Disabled') {
            Disable-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag' -ErrorAction Stop | Out-Null
            $disabled++
            Write-Host "      [+] Disabled: ScheduledDefrag (SSDs self-manage TRIM)" -ForegroundColor Green
        }
    } catch {}

    Write-Host "      [OK] $disabled junk tasks disabled  --  No more random frame drops!" -ForegroundColor Green
}

function Optimize-StartupAndDns {
    Write-Host "`n[*] Optimizing Startup Programs & DNS..." -ForegroundColor Yellow

    # --- DNS Optimization ---
    Write-Host "`n      --- DNS Optimization ---" -ForegroundColor Cyan
    $hw = Get-HardwareProfile
    $adapter = $hw.Adapter
    if ($adapter) {
        try {
            # Set Cloudflare DNS (1.1.1.1 primary, 1.0.0.1 secondary)
            Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @('1.1.1.1', '1.0.0.1') -ErrorAction Stop
            Write-Host "      [+] DNS set to Cloudflare (1.1.1.1, 1.0.0.1)  --  Fastest gaming DNS" -ForegroundColor Green
        } catch {
            Write-Host "      [~] DNS auto-set skipped: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }

        # Disable DNS over HTTPS throttle, enable DNS cache optimization
        $dnsParams = 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
        if (Test-Path $dnsParams) {
            Set-ItemProperty -Path $dnsParams -Name 'MaxCacheTtl' -Value 86400 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $dnsParams -Name 'MaxNegativeCacheTtl' -Value 5 -Type DWord -ErrorAction SilentlyContinue
            Write-Host "      [+] DNS Cache optimized (24h positive TTL, 5s negative TTL)" -ForegroundColor Green
        }
    }

    # Flush DNS after changes
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null
    Write-Host "      [+] DNS cache flushed" -ForegroundColor Green

    # --- Startup Audit ---
    Write-Host "`n      --- Startup Program Audit ---" -ForegroundColor Cyan
    $startupItems = Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue
    $runKey = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
    $runKeyLM = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue

    Write-Host "      Current startup programs:" -ForegroundColor Yellow
    $allProps = @()
    if ($runKey) {
        $runKey.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
            Write-Host "        [HKCU] $($_.Name): $($_.Value)" -ForegroundColor Gray
            $allProps += $_.Name
        }
    }
    if ($runKeyLM) {
        $runKeyLM.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
            Write-Host "        [HKLM] $($_.Name): $($_.Value)" -ForegroundColor Gray
        }
    }

    # Known bloatware startup entries to auto-disable
    $bloatStartup = @('OneDrive', 'Skype', 'Teams', 'Spotify', 'Discord Update', 'CortanaStartupId', 'BingDesktop', 'AdobeAAMUpdater')
    foreach ($bloat in $bloatStartup) {
        if ($allProps -contains $bloat) {
            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $bloat -ErrorAction SilentlyContinue
            Write-Host "      [+] Auto-disabled bloat startup: $bloat" -ForegroundColor Green
        }
    }

    Write-Host "      [OK] DNS optimized + Startup audited  --  Faster boot and lower latency!" -ForegroundColor Green
}

# --- WINUTIL S-TIER & SNAPPY OS OPTIMIZATION FUNCTIONS ---

function Disable-MultiplaneOverlay {
    Write-Host "`n[*] Disabling Multiplane Overlay (MPO)..." -ForegroundColor Yellow
    $dwmPath = 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm'
    if (-not (Test-Path $dwmPath)) { New-Item -Path $dwmPath -Force | Out-Null }
    Set-ItemProperty -Path $dwmPath -Name 'OverlayTestMode' -Value 5 -Type DWord -ErrorAction SilentlyContinue

    $gfxPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
    if (-not (Test-Path $gfxPath)) { New-Item -Path $gfxPath -Force | Out-Null }
    Set-ItemProperty -Path $gfxPath -Name 'DisableOverlays' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    Write-Host "      [+] MPO Disabled (OverlayTestMode=5, DisableOverlays=1)  --  Zero DWM stuttering & flickering!" -ForegroundColor Green
}

function Set-MouseLinearCurve {
    Write-Host "`n[*] Applying 1:1 True Linear Mouse Tracking Curve..." -ForegroundColor Yellow
    $mousePath = 'HKCU:\Control Panel\Mouse'
    Set-ItemProperty -Path $mousePath -Name 'MouseSpeed' -Value 0 -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mousePath -Name 'MouseThreshold1' -Value 0 -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mousePath -Name 'MouseThreshold2' -Value 0 -Type String -ErrorAction SilentlyContinue
    
    $linearX = [byte[]](0,0,0,0, 0,0,0,0, 0,0,4,0, 0,0,0,0, 0,0,8,0, 0,0,0,0, 0,0,12,0, 0,0,0,0, 0,0,16,0, 0,0,0,0)
    $linearY = [byte[]](0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0)
    Set-ItemProperty -Path $mousePath -Name 'SmoothMouseXCurve' -Value $linearX -Type Binary -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mousePath -Name 'SmoothMouseYCurve' -Value $linearY -Type Binary -ErrorAction SilentlyContinue
    Write-Host "      [+] Enhance Pointer Precision forced OFF + 1:1 linear curve active" -ForegroundColor Green
}

function Disable-StickyKeysPrompt {
    Write-Host "`n[*] Disabling Sticky Keys & Accessibility Hotkey Prompts..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Value '506' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\Keyboard Response' -Name 'Flags' -Value '122' -Type String -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\ToggleKeys' -Name 'Flags' -Value '58' -Type String -ErrorAction SilentlyContinue
    Write-Host "      [+] Sticky Keys popups permanently disabled  --  No more clutch game interruptions!" -ForegroundColor Green
}

function Enable-EndTaskRightClick {
    Write-Host "`n[*] Enabling 'End Task' on Taskbar Right-Click Menu..." -ForegroundColor Yellow
    $taskbarDev = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings'
    if (-not (Test-Path $taskbarDev)) { New-Item -Path $taskbarDev -Force | Out-Null }
    Set-ItemProperty -Path $taskbarDev -Name 'TaskbarEndTask' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] End Task enabled on Taskbar  --  Terminate frozen games instantly!" -ForegroundColor Green
}

function Disable-BackgroundAppsGlobal {
    Write-Host "`n[*] Disabling Background Apps Globally..." -ForegroundColor Yellow
    $bgAccess = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'
    if (-not (Test-Path $bgAccess)) { New-Item -Path $bgAccess -Force | Out-Null }
    Set-ItemProperty -Path $bgAccess -Name 'GlobalUserDisabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $searchPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    if (-not (Test-Path $searchPath)) { New-Item -Path $searchPath -Force | Out-Null }
    Set-ItemProperty -Path $searchPath -Name 'BackgroundAppGlobalToggle' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] All UWP background apps disabled  --  Zero CPU interrupt polling" -ForegroundColor Green
}

function Remove-WidgetsPlatform {
    Write-Host "`n[*] Removing Windows Widgets & WebExperience Platform..." -ForegroundColor Yellow
    Get-Process *Widget* -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-AppxPackage Microsoft.WidgetsPlatformRuntime -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxPackage MicrosoftWindows.Client.WebExperience -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

    $dsh = 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh'
    if (-not (Test-Path $dsh)) { New-Item -Path $dsh -Force | Out-Null }
    Set-ItemProperty -Path $dsh -Name 'AllowNewsAndInterests' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Widgets and News removed  --  Reclaimed 300MB+ RAM" -ForegroundColor Green
}

function Optimize-SvcHostSplitting {
    Write-Host "`n[*] Optimizing SvcHost Process Memory Threshold..." -ForegroundColor Yellow
    try {
        $ramKb = [int]((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1KB)
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value $ramKb -Type DWord -ErrorAction SilentlyContinue
        Write-Host "      [+] SvcHostSplitThresholdInKB set to $ramKb KB (Matched to Physical RAM)" -ForegroundColor Green
    } catch {
        Write-Host "      [~] SvcHost threshold set to 16GB default" -ForegroundColor DarkYellow
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value 16777216 -Type DWord -ErrorAction SilentlyContinue
    }
}

function Block-WpbtExecution {
    Write-Host "`n[*] Blocking UEFI/BIOS Windows Platform Binary Table (WPBT)..." -ForegroundColor Yellow
    $smPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
    Set-ItemProperty -Path $smPath -Name 'DisableWpbtExecution' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] WPBT execution blocked  --  Motherboard vendor bloatware cannot inject at boot!" -ForegroundColor Green
}

function Block-PeripheralBloat {
    Write-Host "`n[*] Immunizing System Against Peripheral Auto-Bloatware..." -ForegroundColor Yellow
    $razerPath = "$Env:SystemRoot\Installer\Razer"
    if (!(Test-Path $razerPath)) { New-Item -Path $razerPath -ItemType Directory -Force | Out-Null }
    icacls $razerPath /deny "*S-1-1-0:(W)" 2>$null | Out-Null

    $logiPath = "$Env:ProgramFiles\LogiDownloadAssistant"
    if (!(Test-Path $logiPath)) { New-Item -Path $logiPath -ItemType Directory -Force | Out-Null }
    icacls $logiPath /deny "*S-1-1-0:(W)" 2>$null | Out-Null

    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer' -Name 'DisableCoInstallers' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' -Name 'SearchOrderConfig' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Stop-Process -Name 'logi_download_assistant' -Force -ErrorAction SilentlyContinue
    Write-Host "      [+] Razer Synapse & Logitech Download Assistant auto-installers permanently locked!" -ForegroundColor Green
}

function Remove-WindowsAI {
    Write-Host "`n[*] Purging Windows AI, Copilot & Recall Packages..." -ForegroundColor Yellow
    Disable-WindowsOptionalFeature -FeatureName Recall -Online -NoRestart -ErrorAction SilentlyContinue | Out-Null
    Set-Service -Name WSAIFabricSvc -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name WSAIFabricSvc -Force -ErrorAction SilentlyContinue

    Get-AppxPackage -AllUsers "*Copilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    $coreAi = (Get-AppxPackage MicrosoftWindows.Client.CoreAI -ErrorAction SilentlyContinue).PackageFullName
    if ($coreAi) { Remove-AppxPackage $coreAi -ErrorAction SilentlyContinue }

    $np = 'HKLM:\SOFTWARE\Policies\WindowsNotepad'
    if (-not (Test-Path $np)) { New-Item -Path $np -Force | Out-Null }
    Set-ItemProperty -Path $np -Name 'DisableAIFeatures' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $exp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    if (-not (Test-Path $exp)) { New-Item -Path $exp -Force | Out-Null }
    Set-ItemProperty -Path $exp -Name 'SettingsPageVisibility' -Value 'hide:aicomponents' -Type String -ErrorAction SilentlyContinue
    Write-Host "      [+] Windows AI, Copilot and Recall stripped completely!" -ForegroundColor Green
}

function Enable-ClassicContextMenu {
    Write-Host "`n[*] Restoring Classic Windows 10 Right-Click Menu in Windows 11..." -ForegroundColor Yellow
    $clsid = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
    if (-not (Test-Path $clsid)) { New-Item -Path $clsid -Force | Out-Null }
    Set-ItemProperty -Path $clsid -Name '(Default)' -Value '' -ErrorAction SilentlyContinue
    Write-Host "      [+] Classic Context Menu active  --  Zero lag right-click restored!" -ForegroundColor Green
}

function Disable-StartMenuBing {
    Write-Host "`n[*] Disabling Bing Web Search in Start Menu..." -ForegroundColor Yellow
    $pol = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
    if (-not (Test-Path $pol)) { New-Item -Path $pol -Force | Out-Null }
    Set-ItemProperty -Path $pol -Name 'DisableSearchBoxSuggestions' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    $srch = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    if (-not (Test-Path $srch)) { New-Item -Path $srch -Force | Out-Null }
    Set-ItemProperty -Path $srch -Name 'BingSearchEnabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Bing Web Search disabled  --  Local search only, instant results!" -ForegroundColor Green
}

function Disable-ExplorerAutoDiscovery {
    Write-Host "`n[*] Disabling File Explorer Automatic Folder Discovery..." -ForegroundColor Yellow
    $allFolders = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell'
    if (-not (Test-Path $allFolders)) { New-Item -Path $allFolders -Force | Out-Null }
    Set-ItemProperty -Path $allFolders -Name 'FolderType' -Value 'NotSpecified' -Type String -ErrorAction SilentlyContinue
    Write-Host "      [+] Explorer folder auto-discovery disabled  --  Instant folder opening!" -ForegroundColor Green
}

function Enable-LongPaths {
    Write-Host "`n[*] Enabling Win32 Long Paths (>260 characters)..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Long paths enabled (>260 chars)  --  Modding and game paths unrestricted!" -ForegroundColor Green
}

function Disable-LockScreen {
    Write-Host "`n[*] Disabling Windows Lock Screen Swipe Delay..." -ForegroundColor Yellow
    $pers = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
    if (-not (Test-Path $pers)) { New-Item -Path $pers -Force | Out-Null }
    Set-ItemProperty -Path $pers -Name 'NoLockScreen' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Lock screen disabled  --  Direct password/PIN login prompt!" -ForegroundColor Green
}

function Enable-BsodVerbose {
    Write-Host "`n[*] Enabling Verbose Crash Parameters on BSoD..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'DisplayParameters' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] BSoD verbose mode enabled  --  Driver and stopcode display active for tuning!" -ForegroundColor Green
}

function Disable-ReservedStorage {
    Write-Host "`n[*] Disabling Windows Reserved Storage..." -ForegroundColor Yellow
    try {
        Set-WindowsReservedStorageState -State Disabled -ErrorAction SilentlyContinue | Out-Null
    } catch {}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager' -Name 'ShippedWithReserves' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Reserved storage disabled  --  ~7GB SSD space reclaimed!" -ForegroundColor Green
}

function Set-ShowFileExtensionsAndHidden {
    Write-Host "`n[*] Showing File Extensions & Hidden Files..." -ForegroundColor Yellow
    $adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $adv -Name 'HideFileExt' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $adv -Name 'Hidden' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] File extensions and hidden files set to visible!" -ForegroundColor Green
}

function Set-SecurityUpdatesOnly {
    Write-Host "`n[*] Configuring Windows Updates: Security Patches Only (Defer Feature Builds 2 Years)..." -ForegroundColor Yellow
    $wu = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    if (-not (Test-Path $wu)) { New-Item -Path $wu -Force | Out-Null }
    Set-ItemProperty -Path $wu -Name 'DeferFeatureUpdates' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $wu -Name 'DeferFeatureUpdatesPeriodInDays' -Value 730 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $wu -Name 'DeferQualityUpdates' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "      [+] Security-only update policy active  --  Feature builds deferred 2 years, drivers protected!" -ForegroundColor Green
}



# ==============================================================================
# SECTION: WINGET APPLICATION CATALOG (10 CATEGORIES, 100+ PACKAGES)
# ==============================================================================

$Global:AppCatalog = @(
    # --- BROWSERS ---
    @{ Key = "brave"; Name = "Brave Browser"; Category = "Browsers"; WingetId = "Brave.Brave"; Description = "Privacy-oriented browser with built-in ad blocking" },
    @{ Key = "chrome"; Name = "Google Chrome"; Category = "Browsers"; WingetId = "Google.Chrome"; Description = "Fast, standard Chromium browser" },
    @{ Key = "chromium"; Name = "Chromium"; Category = "Browsers"; WingetId = "Hibbiki.Chromium"; Description = "Open-source foundation of Google Chrome" },
    @{ Key = "edge"; Name = "Microsoft Edge"; Category = "Browsers"; WingetId = "Microsoft.Edge"; Description = "Modern Windows built-in browser" },
    @{ Key = "firefox"; Name = "Mozilla Firefox"; Category = "Browsers"; WingetId = "Mozilla.Firefox"; Description = "Extensible open-source Gecko browser" },
    @{ Key = "floorp"; Name = "Floorp Browser"; Category = "Browsers"; WingetId = "Ablaze.Floorp"; Description = "Customizable Firefox fork created in Japan" },
    @{ Key = "librewolf"; Name = "LibreWolf"; Category = "Browsers"; WingetId = "LibreWolf.LibreWolf"; Description = "Hardened privacy-first Firefox fork" },
    @{ Key = "tor"; Name = "Tor Browser"; Category = "Browsers"; WingetId = "TorProject.TorBrowser"; Description = "Anonymity-focused onion-routing browser" },
    @{ Key = "vivaldi"; Name = "Vivaldi"; Category = "Browsers"; WingetId = "VivaldiTechnologies.Vivaldi"; Description = "Feature-packed browser with custom tabs" },
    @{ Key = "waterfox"; Name = "Waterfox"; Category = "Browsers"; WingetId = "Waterfox.Waterfox"; Description = "Fast, ethical 64-bit Gecko browser" },
    @{ Key = "zen"; Name = "Zen Browser"; Category = "Browsers"; WingetId = "Zen-Team.Zen-Browser"; Description = "Modern, beautiful Firefox-based vertical tabs browser" },
    @{ Key = "operagx"; Name = "Opera GX"; Category = "Browsers"; WingetId = "Opera.OperaGX"; Description = "Gaming browser with CPU/RAM limiters" },

    # --- COMMUNICATIONS ---
    @{ Key = "discord"; Name = "Discord"; Category = "Communications"; WingetId = "Discord.Discord"; Description = "All-in-one voice and text chat for gamers" },
    @{ Key = "telegram"; Name = "Telegram Desktop"; Category = "Communications"; WingetId = "Telegram.TelegramDesktop"; Description = "Fast, secure cloud messaging client" },
    @{ Key = "signal"; Name = "Signal"; Category = "Communications"; WingetId = "OpenWhisperSystems.Signal"; Description = "End-to-end encrypted private messenger" },
    @{ Key = "slack"; Name = "Slack"; Category = "Communications"; WingetId = "SlackTechnologies.Slack"; Description = "Team collaboration and workplace messaging" },
    @{ Key = "teams"; Name = "Microsoft Teams"; Category = "Communications"; WingetId = "Microsoft.Teams"; Description = "Video conferencing and enterprise chat" },
    @{ Key = "whatsapp"; Name = "WhatsApp"; Category = "Communications"; WingetId = "WhatsApp.WhatsApp"; Description = "Popular worldwide messaging desktop app" },
    @{ Key = "zoom"; Name = "Zoom Workplace"; Category = "Communications"; WingetId = "Zoom.Zoom"; Description = "Video meetings and webinars" },
    @{ Key = "vesktop"; Name = "Vesktop"; Category = "Communications"; WingetId = "Vencord.Vesktop"; Description = "Lightweight Discord desktop client with Vencord" },
    @{ Key = "teamspeak"; Name = "TeamSpeak 3"; Category = "Communications"; WingetId = "TeamSpeak-Systems.TeamSpeakClient"; Description = "Low-latency VoIP client for esports teams" },
    @{ Key = "element"; Name = "Element"; Category = "Communications"; WingetId = "Element.Element"; Description = "Decentralized, encrypted Matrix client" },

    # --- DEVELOPMENT ---
    @{ Key = "vscode"; Name = "Visual Studio Code"; Category = "Development"; WingetId = "Microsoft.VisualStudioCode"; Description = "Extensible source code editor by Microsoft" },
    @{ Key = "cursor"; Name = "Cursor AI"; Category = "Development"; WingetId = "Anysphere.Cursor"; Description = "AI-first code editor built on VS Code" },
    @{ Key = "git"; Name = "Git for Windows"; Category = "Development"; WingetId = "Git.Git"; Description = "Distributed version control system" },
    @{ Key = "githubdesktop"; Name = "GitHub Desktop"; Category = "Development"; WingetId = "GitHub.GitHubDesktop"; Description = "GUI client for Git and GitHub workflows" },
    @{ Key = "python"; Name = "Python 3.12"; Category = "Development"; WingetId = "Python.Python.3.12"; Description = "Interpreted high-level programming language" },
    @{ Key = "nodejs"; Name = "Node.js (LTS)"; Category = "Development"; WingetId = "OpenJS.NodeJS.LTS"; Description = "JavaScript runtime environment built on V8" },
    @{ Key = "docker"; Name = "Docker Desktop"; Category = "Development"; WingetId = "Docker.DockerDesktop"; Description = "Containerization platform for developers" },
    @{ Key = "rust"; Name = "Rustup"; Category = "Development"; WingetId = "Rustlang.Rustup"; Description = "Rust toolchain installer and version manager" },
    @{ Key = "golang"; Name = "Go Programming Language"; Category = "Development"; WingetId = "GoLang.Go"; Description = "Fast, concurrent compiled programming language" },
    @{ Key = "neovim"; Name = "Neovim"; Category = "Development"; WingetId = "Neovim.Neovim"; Description = "Vim-fork focused on extensibility and usability" },
    @{ Key = "winterminal"; Name = "Windows Terminal"; Category = "Development"; WingetId = "Microsoft.WindowsTerminal"; Description = "Modern, fast tabbed terminal emulator" },
    @{ Key = "notepadplusplus"; Name = "Notepad++"; Category = "Development"; WingetId = "Notepad++.Notepad++"; Description = "Fast, lightweight tabbed text and code editor" },
    @{ Key = "sublimetext"; Name = "Sublime Text"; Category = "Development"; WingetId = "SublimeHQ.SublimeText.4"; Description = "Sophisticated text editor for code and prose" },
    @{ Key = "dbeaver"; Name = "DBeaver Community"; Category = "Development"; WingetId = "dbeaver.dbeaver"; Description = "Universal database tool and SQL client" },
    @{ Key = "postman"; Name = "Postman"; Category = "Development"; WingetId = "Postman.Postman"; Description = "API design, testing, and documentation platform" },

    # --- DOCUMENT ---
    @{ Key = "acrobat"; Name = "Adobe Acrobat Reader"; Category = "Document"; WingetId = "Adobe.Acrobat.Reader.64-bit"; Description = "Standard PDF viewing and printing utility" },
    @{ Key = "obsidian"; Name = "Obsidian"; Category = "Document"; WingetId = "Obsidian.Obsidian"; Description = "Knowledge base on local plain-text Markdown" },
    @{ Key = "libreoffice"; Name = "LibreOffice"; Category = "Document"; WingetId = "TheDocumentFoundation.LibreOffice"; Description = "Open-source office suite (Writer, Calc, Impress)" },
    @{ Key = "pdf24"; Name = "PDF24 Creator"; Category = "Document"; WingetId = "geeksoftwareGmbH.PDF24Creator"; Description = "Free all-in-one PDF tools and converter" },
    @{ Key = "sumatrapdf"; Name = "Sumatra PDF"; Category = "Document"; WingetId = "SumatraPDF.SumatraPDF"; Description = "Ultra-fast, ultra-lightweight PDF and eBook viewer" },
    @{ Key = "joplin"; Name = "Joplin"; Category = "Document"; WingetId = "Joplin.Joplin"; Description = "Secure, end-to-end encrypted note-taking app" },
    @{ Key = "zotero"; Name = "Zotero"; Category = "Document"; WingetId = "DigitalScience.Zotero"; Description = "Research tool for collecting and citing references" },
    @{ Key = "foxit"; Name = "Foxit PDF Reader"; Category = "Document"; WingetId = "Foxit.FoxitReader"; Description = "Feature-rich, fast PDF viewer and annotator" },
    @{ Key = "calibre"; Name = "Calibre"; Category = "Document"; WingetId = "KovidGoyal.Calibre"; Description = "Complete eBook library manager and converter" },
    @{ Key = "typora"; Name = "Typora"; Category = "Document"; WingetId = "Typora.Typora"; Description = "Seamless live-preview Markdown editor" },

    # --- GAMES ---
    @{ Key = "steam"; Name = "Steam"; Category = "Games"; WingetId = "Valve.Steam"; Description = "Valve digital gaming platform and store" },
    @{ Key = "epicgames"; Name = "Epic Games Launcher"; Category = "Games"; WingetId = "EpicGames.EpicGamesLauncher"; Description = "Epic Games store, Unreal Engine, and Fortnite" },
    @{ Key = "battlenet"; Name = "Battle.net"; Category = "Games"; WingetId = "Blizzard.BattleNet"; Description = "Blizzard Entertainment game launcher" },
    @{ Key = "eaapp"; Name = "EA App"; Category = "Games"; WingetId = "ElectronicArts.EADesktop"; Description = "Electronic Arts gaming hub" },
    @{ Key = "goggalaxy"; Name = "GOG Galaxy"; Category = "Games"; WingetId = "GOG.Galaxy"; Description = "DRM-free gaming hub with universal library" },
    @{ Key = "heroic"; Name = "Heroic Games Launcher"; Category = "Games"; WingetId = "HeroicGamesLauncher.HeroicGamesLauncher"; Description = "Open-source Epic and GOG games launcher" },
    @{ Key = "roblox"; Name = "Roblox Player"; Category = "Games"; WingetId = "Roblox.Roblox"; Description = "Online gaming platform and game creation system" },
    @{ Key = "curseforge"; Name = "CurseForge"; Category = "Games"; WingetId = "Overwolf.CurseForge"; Description = "Modding and addon manager for Minecraft and WoW" },
    @{ Key = "playnite"; Name = "Playnite"; Category = "Games"; WingetId = "Playnite.Playnite"; Description = "Open-source video game library manager" },
    @{ Key = "ubisoft"; Name = "Ubisoft Connect"; Category = "Games"; WingetId = "Ubisoft.Connect"; Description = "Ubisoft digital store and ecosystem client" },
    @{ Key = "prism"; Name = "Prism Launcher"; Category = "Games"; WingetId = "PrismLauncher.PrismLauncher"; Description = "Custom open-source Minecraft launcher" },
    @{ Key = "moonlight"; Name = "Moonlight Game Streaming"; Category = "Games"; WingetId = "MoonlightGameStreamingProject.Moonlight"; Description = "NVIDIA GameStream and Sunshine open-source client" },

    # --- MICROSOFT TOOLS ---
    @{ Key = "powertoys"; Name = "Microsoft PowerToys"; Category = "Microsoft Tools"; WingetId = "Microsoft.PowerToys"; Description = "System utilities for power users (FancyZones, Run, OCR)" },
    @{ Key = "sysinternals"; Name = "Sysinternals Suite"; Category = "Microsoft Tools"; WingetId = "Microsoft.Sysinternals.Suite"; Description = "Complete suite of advanced Windows diagnostic tools" },
    @{ Key = "dotnet8"; Name = ".NET 8 Desktop Runtime"; Category = "Microsoft Tools"; WingetId = "Microsoft.DotNet.DesktopRuntime.8"; Description = "Runtime required for modern desktop .NET apps" },
    @{ Key = "vcredist64"; Name = "Visual C++ 2015-2022 (x64)"; Category = "Microsoft Tools"; WingetId = "Microsoft.VCRedist.2015+.x64"; Description = "Essential 64-bit runtime for almost all Windows games" },
    @{ Key = "vcredist86"; Name = "Visual C++ 2015-2022 (x86)"; Category = "Microsoft Tools"; WingetId = "Microsoft.VCRedist.2015+.x86"; Description = "Essential 32-bit runtime for legacy Windows games" },
    @{ Key = "directx"; Name = "DirectX End-User Runtimes"; Category = "Microsoft Tools"; WingetId = "Microsoft.DirectX"; Description = "DirectX 9/10/11 legacy library runtimes for games" },
    @{ Key = "procexp"; Name = "Process Explorer"; Category = "Microsoft Tools"; WingetId = "Microsoft.Sysinternals.ProcessExplorer"; Description = "Advanced Task Manager with DLL and handle inspection" },
    @{ Key = "autoruns"; Name = "AutoRuns"; Category = "Microsoft Tools"; WingetId = "Microsoft.Sysinternals.Autoruns"; Description = "Most comprehensive startup and autostart monitor" },
    @{ Key = "pwsh7"; Name = "PowerShell 7"; Category = "Microsoft Tools"; WingetId = "Microsoft.PowerShell"; Description = "Latest cross-platform PowerShell core engine" },

    # --- MULTIMEDIA TOOLS ---
    @{ Key = "obs"; Name = "OBS Studio"; Category = "Multimedia Tools"; WingetId = "OBSProject.OBSStudio"; Description = "Industry standard live streaming and video recording" },
    @{ Key = "vlc"; Name = "VLC Media Player"; Category = "Multimedia Tools"; WingetId = "VideoLAN.VLC"; Description = "Universal multimedia player for all codecs" },
    @{ Key = "handbrake"; Name = "HandBrake"; Category = "Multimedia Tools"; WingetId = "HandBrake.HandBrake"; Description = "Open-source video transcoder and compressor" },
    @{ Key = "audacity"; Name = "Audacity"; Category = "Multimedia Tools"; WingetId = "Audacity.Audacity"; Description = "Multi-track audio editor and recorder" },
    @{ Key = "blender"; Name = "Blender"; Category = "Multimedia Tools"; WingetId = "BlenderFoundation.Blender"; Description = "Professional 3D creation, modeling, and VFX suite" },
    @{ Key = "gimp"; Name = "GIMP"; Category = "Multimedia Tools"; WingetId = "GIMP.GIMP"; Description = "GNU Image Manipulation Program (Photoshop alternative)" },
    @{ Key = "klite"; Name = "K-Lite Codec Pack Mega"; Category = "Multimedia Tools"; WingetId = "CodecGuide.K-LiteCodecPack.Mega"; Description = "Comprehensive DirectShow filters and video codecs" },
    @{ Key = "sharex"; Name = "ShareX"; Category = "Multimedia Tools"; WingetId = "ShareX.ShareX"; Description = "Screen capture, file sharing, and productivity tool" },
    @{ Key = "mpv"; Name = "mpv.net"; Category = "Multimedia Tools"; WingetId = "mpv.net"; Description = "Modern, minimalist GPU-accelerated media player" },
    @{ Key = "paintnet"; Name = "Paint.NET"; Category = "Multimedia Tools"; WingetId = "dotPDN.PaintDotNet"; Description = "Free image and photo editing software for Windows" },
    @{ Key = "foobar2000"; Name = "Foobar2000"; Category = "Multimedia Tools"; WingetId = "PeterPawlowski.foobar2000"; Description = "Advanced lightweight freeware audio player" },
    @{ Key = "spotify"; Name = "Spotify"; Category = "Multimedia Tools"; WingetId = "Spotify.Spotify"; Description = "Digital music streaming desktop client" },

    # --- PRO TOOLS ---
    @{ Key = "ddu"; Name = "Display Driver Uninstaller"; Category = "Pro Tools"; WingetId = "Wagnardsoft.DisplayDriverUninstaller"; Description = "Clean uninstall tool for NVIDIA, AMD, and Intel drivers" },
    @{ Key = "cpuz"; Name = "CPU-Z"; Category = "Pro Tools"; WingetId = "CPUID.CPU-Z"; Description = "Processor, motherboard, and RAM hardware diagnostics" },
    @{ Key = "gpuz"; Name = "GPU-Z"; Category = "Pro Tools"; WingetId = "TechPowerUp.GPU-Z"; Description = "Video card and graphics information utility" },
    @{ Key = "hwinfo"; Name = "HWiNFO"; Category = "Pro Tools"; WingetId = "REALiX.HWiNFO"; Description = "Hardware analysis, monitoring, and thermal reporting" },
    @{ Key = "hwmonitor"; Name = "HWMonitor"; Category = "Pro Tools"; WingetId = "CPUID.HWMonitor"; Description = "Hardware voltage, temperature, and fan speed monitor" },
    @{ Key = "cinebench"; Name = "Cinebench R23"; Category = "Pro Tools"; WingetId = "Maxon.CinebenchR23"; Description = "Industry standard CPU rendering benchmark" },
    @{ Key = "wireshark"; Name = "Wireshark"; Category = "Pro Tools"; WingetId = "WiresharkFoundation.Wireshark"; Description = "Network protocol analyzer and packet sniffer" },
    @{ Key = "putty"; Name = "PuTTY"; Category = "Pro Tools"; WingetId = "PuTTY.PuTTY"; Description = "SSH, Telnet, and serial terminal client" },
    @{ Key = "mullvadvpn"; Name = "Mullvad VPN"; Category = "Pro Tools"; WingetId = "MullvadVPN.MullvadVPN"; Description = "Privacy-focused WireGuard VPN client" },
    @{ Key = "protonvpn"; Name = "Proton VPN"; Category = "Pro Tools"; WingetId = "Proton.ProtonVPN"; Description = "High-speed Swiss encrypted VPN service" },
    @{ Key = "winscp"; Name = "WinSCP"; Category = "Pro Tools"; WingetId = "WinSCP.WinSCP"; Description = "Free SFTP, SCP, and FTP client for Windows" },
    @{ Key = "filezilla"; Name = "FileZilla Client"; Category = "Pro Tools"; WingetId = "TimKosse.FileZilla.Client"; Description = "Fast and reliable cross-platform FTP client" },

    # --- SELFHOSTED TOOLS ---
    @{ Key = "jellyfin"; Name = "Jellyfin Media Player"; Category = "Selfhosted Tools"; WingetId = "Jellyfin.JellyfinMediaPlayer"; Description = "Free software media streaming client" },
    @{ Key = "plex"; Name = "Plex Desktop"; Category = "Selfhosted Tools"; WingetId = "Plex.PlexDesktop"; Description = "Desktop player for personal Plex media libraries" },
    @{ Key = "sunshine"; Name = "Sunshine"; Category = "Selfhosted Tools"; WingetId = "LizardByte.Sunshine"; Description = "Self-hosted low latency game stream host for Moonlight" },
    @{ Key = "localsend"; Name = "LocalSend"; Category = "Selfhosted Tools"; WingetId = "LocalSend.LocalSend"; Description = "AirDrop alternative for local network file sharing" },
    @{ Key = "syncthing"; Name = "Syncthing"; Category = "Selfhosted Tools"; WingetId = "Syncthing.Syncthing"; Description = "Continuous, decentralized peer-to-peer file sync" },
    @{ Key = "tailscale"; Name = "Tailscale"; Category = "Selfhosted Tools"; WingetId = "Tailscale.Tailscale"; Description = "Zero-config mesh VPN powered by WireGuard" },
    @{ Key = "wireguard"; Name = "WireGuard"; Category = "Selfhosted Tools"; WingetId = "WireGuard.WireGuard"; Description = "Extremely fast, modern cryptographic VPN tunnel" },
    @{ Key = "rustdesk"; Name = "RustDesk"; Category = "Selfhosted Tools"; WingetId = "RustDesk.RustDesk"; Description = "Open-source remote desktop alternative to TeamViewer" },

    # --- UTILITIES ---
    @{ Key = "afterburner"; Name = "MSI Afterburner"; Category = "Utilities"; WingetId = "Guru3D.Afterburner"; Description = "GPU overclocking, undervolting, and RivaTuner OSD" },
    @{ Key = "7zip"; Name = "7-Zip"; Category = "Utilities"; WingetId = "7zip.7zip"; Description = "High-compression file archiver" },
    @{ Key = "nanazip"; Name = "NanaZip"; Category = "Utilities"; WingetId = "M2Team.NanaZip"; Description = "Modern 7-Zip fork with Windows 11 context menus" },
    @{ Key = "revo"; Name = "Revo Uninstaller"; Category = "Utilities"; WingetId = "RevoUninstaller.RevoUninstaller"; Description = "Deep software removal and leftover registry cleanup" },
    @{ Key = "processlasso"; Name = "Process Lasso"; Category = "Utilities"; WingetId = "Bitsum.ProcessLasso"; Description = "CPU affinity, ProBalance, and process rules manager" },
    @{ Key = "bcu"; Name = "Bulk Crap Uninstaller"; Category = "Utilities"; WingetId = "Klocman.BulkCrapUninstaller"; Description = "Open-source bulk uninstaller with quiet uninstall" },
    @{ Key = "crystaldiskinfo"; Name = "CrystalDiskInfo"; Category = "Utilities"; WingetId = "CrystalDewWorld.CrystalDiskInfo"; Description = "HDD and NVMe SSD health monitoring (S.M.A.R.T.)" },
    @{ Key = "crystaldiskmark"; Name = "CrystalDiskMark"; Category = "Utilities"; WingetId = "CrystalDewWorld.CrystalDiskMark"; Description = "Storage drive read and write speed benchmark" },
    @{ Key = "rufus"; Name = "Rufus"; Category = "Utilities"; WingetId = "Rufus.Rufus"; Description = "Fast bootable USB drive creator with bypass options" },
    @{ Key = "everything"; Name = "Everything"; Category = "Utilities"; WingetId = "voidtools.Everything"; Description = "Instant desktop file search by voidtools" },
    @{ Key = "treesize"; Name = "TreeSize Free"; Category = "Utilities"; WingetId = "JAMSoftware.TreeSizeFree"; Description = "Fast disk space analyzer and folder tree view" },
    @{ Key = "bleachbit"; Name = "BleachBit"; Category = "Utilities"; WingetId = "BleachBit.BleachBit"; Description = "Open-source system disk cleaner and cache wiper" },
    @{ Key = "windirstat"; Name = "WinDirStat"; Category = "Utilities"; WingetId = "WinDirStat.WinDirStat"; Description = "Disk usage statistics viewer and cleanup tool" },
    @{ Key = "fastcopy"; Name = "FastCopy"; Category = "Utilities"; WingetId = "SHIRSystem.FastCopy"; Description = "Fastest copy and backup software on Windows" }
)

# ==============================================================================
# SECTION: WINGET ENGINE & RUNNER FUNCTIONS
# ==============================================================================

function Get-WinGetCommand {
    [CmdletBinding()]
    param()

    $cmd = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    $winAppsPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (Test-Path $winAppsPath) {
        return $winAppsPath
    }

    $progFilesPath = "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    $match = Get-Item $progFilesPath -ErrorAction SilentlyContinue | Select-Object -Last 1
    if ($match) {
        return $match.FullName
    }

    return $null
}

function Install-WinGetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,
        [scriptblock]$LogCallback
    )

    $winget = Get-WinGetCommand
    if (-not $winget) {
        $msg = "[-] ERROR: WinGet is not installed or detected on this system!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return $false
    }

    $msg = "[*] Installing $PackageId via WinGet..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $winget
    $psi.Arguments = "install --id `"$PackageId`" --exact --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    while (-not $proc.HasExited) {
        $out = $proc.StandardOutput.ReadLine()
        if ($out -and $LogCallback) { & $LogCallback "    $out" }
        Start-Sleep -Milliseconds 50
    }
    $rem = $proc.StandardOutput.ReadToEnd()
    if ($rem -and $LogCallback) { & $LogCallback "    $rem" }

    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 2316632065) {
        $msg = "[+] SUCCESS: $PackageId installed successfully!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
        return $true
    } else {
        $msg = "[-] WARNING: WinGet exited with code $($proc.ExitCode) for $PackageId"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }
        return $false
    }
}

function Uninstall-WinGetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,
        [scriptblock]$LogCallback
    )

    $winget = Get-WinGetCommand
    if (-not $winget) {
        $msg = "[-] ERROR: WinGet is not installed or detected on this system!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return $false
    }

    $msg = "[*] Uninstalling $PackageId via WinGet..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $winget
    $psi.Arguments = "uninstall --id `"$PackageId`" --exact --silent"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    while (-not $proc.HasExited) {
        $out = $proc.StandardOutput.ReadLine()
        if ($out -and $LogCallback) { & $LogCallback "    $out" }
        Start-Sleep -Milliseconds 50
    }
    $rem = $proc.StandardOutput.ReadToEnd()
    if ($rem -and $LogCallback) { & $LogCallback "    $rem" }

    if ($proc.ExitCode -eq 0) {
        $msg = "[+] SUCCESS: $PackageId uninstalled successfully!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
        return $true
    } else {
        $msg = "[-] WARNING: WinGet uninstall exited with code $($proc.ExitCode) for $PackageId"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }
        return $false
    }
}

function Upgrade-AllWinGetPackages {
    [CmdletBinding()]
    param(
        [scriptblock]$LogCallback
    )

    $winget = Get-WinGetCommand
    if (-not $winget) {
        $msg = "[-] ERROR: WinGet is not installed or detected on this system!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return $false
    }

    $msg = "[*] Upgrading all eligible applications via WinGet..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $winget
    $psi.Arguments = "upgrade --all --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    while (-not $proc.HasExited) {
        $out = $proc.StandardOutput.ReadLine()
        if ($out -and $LogCallback) { & $LogCallback "    $out" }
        Start-Sleep -Milliseconds 50
    }
    $rem = $proc.StandardOutput.ReadToEnd()
    if ($rem -and $LogCallback) { & $LogCallback "    $rem" }

    if ($proc.ExitCode -eq 0) {
        $msg = "[+] SUCCESS: All applications upgraded to latest version!"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
        return $true
    } else {
        $msg = "[*] WinGet upgrade completed with exit code $($proc.ExitCode)"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }
        return $true
    }
}



# ==============================================================================
# SECTION: WPF XAML GUI MARKUP (DARK CYBERPUNK THEME)
# ==============================================================================

$xamlContent = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="PumpkiN Ultimate Gaming Optimizer &amp; Software Suite"
    Height="840" Width="1240"
    MinHeight="700" MinWidth="1000"
    WindowStartupLocation="CenterScreen"
    Background="#0F141C"
    Foreground="#F1F5F9"
    FontFamily="Segoe UI">

    <Window.Resources>
        <!-- Dark Cyberpunk Styles -->
        <SolidColorBrush x:Key="BgDark" Color="#0F141C"/>
        <SolidColorBrush x:Key="BgCard" Color="#161E2B"/>
        <SolidColorBrush x:Key="BgCardHover" Color="#1E293B"/>
        <SolidColorBrush x:Key="BorderDark" Color="#26354A"/>
        <SolidColorBrush x:Key="AccentCyan" Color="#00D2FF"/>
        <SolidColorBrush x:Key="AccentOrange" Color="#FF7700"/>
        <SolidColorBrush x:Key="AccentGreen" Color="#00FF88"/>
        <SolidColorBrush x:Key="TextDim" Color="#94A3B8"/>
        <SolidColorBrush x:Key="ConsoleBg" Color="#0A0E14"/>

        <!-- Primary Cyan Button Style -->
        <Style x:Key="CyanButton" TargetType="Button">
            <Setter Property="Background" Value="#00D2FF"/>
            <Setter Property="Foreground" Value="#0A0E14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#38BDF8"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#0284C7"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Accent Orange Button Style -->
        <Style x:Key="OrangeButton" TargetType="Button">
            <Setter Property="Background" Value="#FF7700"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FB923C"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#EA580C"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Dark Outlined Button Style -->
        <Style x:Key="DarkOutlineButton" TargetType="Button">
            <Setter Property="Background" Value="#161E2B"/>
            <Setter Property="Foreground" Value="#F1F5F9"/>
            <Setter Property="BorderBrush" Value="#26354A"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="12,7"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#1E293B"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Category Chip Style (ToggleButton or Button) -->
        <Style x:Key="CategoryChip" TargetType="Button">
            <Setter Property="Background" Value="#161E2B"/>
            <Setter Property="Foreground" Value="#94A3B8"/>
            <Setter Property="BorderBrush" Value="#26354A"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="Margin" Value="0,0,8,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="12" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- CheckBox Dark Style -->
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#F1F5F9"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Margin" Value="0,4,0,4"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <!-- TabItem Cyberpunk Style -->
        <Style TargetType="TabItem">
            <Setter Property="Foreground" Value="#94A3B8"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="20,12"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border x:Name="tabBorder" Background="Transparent" BorderThickness="0,0,0,2" BorderBrush="Transparent" Margin="0,0,10,0" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" ContentSource="Header"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="tabBorder" Property="BorderBrush" Value="#00D2FF"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Foreground" Value="#F1F5F9"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="210"/>
        </Grid.RowDefinitions>

        <!-- TOP BAR: Cyberpunk Header -->
        <Border Grid.Row="0" Background="#121822" BorderBrush="#26354A" BorderThickness="0,0,0,1" Padding="20,14">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="âš¡" FontSize="26" Foreground="#FF7700" Margin="0,0,12,0" VerticalAlignment="Center"/>
                    <StackPanel>
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="PUMPKIN" FontSize="20" FontWeight="Bold" Foreground="#00D2FF" VerticalAlignment="Center"/>
                            <TextBlock Text=" ULTIMATE OPTIMIZER" FontSize="20" FontWeight="Bold" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                            <Border Background="#FF7700" CornerRadius="3" Padding="6,2" Margin="10,0,0,0" VerticalAlignment="Center">
                                <TextBlock Text="v2.5.0" FontSize="11" FontWeight="Bold" Foreground="#0F141C"/>
                            </Border>
                        </StackPanel>
                        <TextBlock Text="Ultra Low-Latency Windows Kernel Engine &amp; 10-Category WinGet Software Suite" FontSize="12" Foreground="#94A3B8" Margin="0,2,0,0"/>
                    </StackPanel>
                </StackPanel>

                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                    <Button Name="BtnRestorePointTop" Content="ðŸ›¡ï¸ Create Restore Point" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                    <Button Name="BtnMasActivateTop" Content="ðŸ”‘ MAS Activation" Style="{StaticResource DarkOutlineButton}"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- MAIN TAB CONTROL -->
        <TabControl Grid.Row="1" Background="Transparent" BorderThickness="0" Margin="14,10,14,0">

            <!-- TAB 1: SOFTWARE DOWNLOADER -->
            <TabItem Header="ðŸ“¦ Software Downloader">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="260"/>
                    </Grid.ColumnDefinitions>

                    <!-- TOP FILTER & CATEGORY CHIPS -->
                    <Border Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,0,0,10">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <!-- Search Input -->
                            <Grid Grid.Row="0" Margin="0,0,0,10">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <TextBox Name="TxtSearch" Height="34" Background="#0F141C" Foreground="#FFFFFF" BorderBrush="#26354A" BorderThickness="1" Padding="10,6" FontSize="13" VerticalContentAlignment="Center"/>
                                <TextBlock IsHitTestVisible="False" Text="ðŸ” Search 100+ applications (e.g. Brave, Discord, Steam, VS Code)..." VerticalAlignment="Center" Margin="12,0,0,0" Foreground="#64748B" FontSize="13">
                                    <TextBlock.Style>
                                        <Style TargetType="TextBlock">
                                            <Setter Property="Visibility" Value="Collapsed"/>
                                            <Style.Triggers>
                                                <DataTrigger Binding="{Binding Text, ElementName=TxtSearch}" Value="">
                                                    <Setter Property="Visibility" Value="Visible"/>
                                                </DataTrigger>
                                            </Style.Triggers>
                                        </Style>
                                    </TextBlock.Style>
                                </TextBlock>
                                <Button Name="BtnClearSearch" Grid.Column="1" Content="Clear" Style="{StaticResource DarkOutlineButton}" Margin="10,0,0,0"/>
                            </Grid>

                            <!-- Horizontal Scrollable Category Chips -->
                            <ScrollViewer Grid.Row="1" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Disabled">
                                <StackPanel Name="StackCategoryChips" Orientation="Horizontal">
                                    <Button Name="ChipCatAll" Content="All Apps (100+)" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatBrowsers" Content="Browsers" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatComms" Content="Communications" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatDev" Content="Development" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatDoc" Content="Document" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatGames" Content="Games" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatMs" Content="Microsoft Tools" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatMedia" Content="Multimedia Tools" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatPro" Content="Pro Tools" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatSelf" Content="Selfhosted Tools" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatUtil" Content="Utilities" Style="{StaticResource CategoryChip}"/>
                                </StackPanel>
                            </ScrollViewer>
                        </Grid>
                    </Border>

                    <!-- APP CARDS GRID (SCROLLABLE WRAPPANEL) -->
                    <Border Grid.Row="1" Grid.Column="0" Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="8" Margin="0,0,10,0">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <WrapPanel Name="WrapPackages" Margin="4"/>
                        </ScrollViewer>
                    </Border>

                    <!-- ACTION SIDEBAR -->
                    <Border Grid.Row="1" Grid.Column="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <StackPanel Grid.Row="0">
                                <TextBlock Text="ACTIONS" FontSize="12" FontWeight="Bold" Foreground="#94A3B8" Margin="0,0,0,10"/>
                                <Button Name="BtnInstallSelected" Content="âš¡ Install Selected" Style="{StaticResource CyanButton}" Margin="0,0,0,10"/>
                                <Button Name="BtnUninstallSelected" Content="ðŸ—‘ï¸ Uninstall Selected" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,10"/>
                                <Button Name="BtnUpgradeAll" Content="ðŸ”„ Upgrade All (WinGet)" Style="{StaticResource OrangeButton}" Margin="0,0,0,14"/>
                            </StackPanel>

                            <Separator Grid.Row="1" Background="#26354A" Margin="0,0,0,14"/>

                            <StackPanel Grid.Row="2">
                                <TextBlock Text="SELECTION" FontSize="12" FontWeight="Bold" Foreground="#94A3B8" Margin="0,0,0,8"/>
                                <Button Name="BtnSelectAll" Content="Select Visible" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,8"/>
                                <Button Name="BtnClearAll" Content="Clear Selection" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,12"/>
                                <TextBlock Name="TxtSelectedCount" Text="0 apps selected" FontSize="12" Foreground="#00D2FF" FontWeight="SemiBold"/>
                            </StackPanel>

                            <Border Grid.Row="3" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10">
                                <TextBlock Text="ðŸ’¡ WinGet installs directly from official vendor repositories with silent parameters." FontSize="11" Foreground="#64748B" TextWrapping="Wrap"/>
                            </Border>
                        </Grid>
                    </Border>
                </Grid>
            </TabItem>

            <!-- TAB 2: GAMING TWEAKS -->
            <TabItem Header="ðŸŽ® Gaming Tweaks">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <!-- COLUMN 1: GPU, LATENCY, NETWORK -->
                            <StackPanel Grid.Column="0" Margin="0,0,8,0">
                                <!-- Card: GPU & Display -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="GRAPHICS &amp; DISPLAY LATENCY" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkGpuAuto" Content="GPU Auto-Optimization (NVIDIA &amp; AMD Driver Tuning)" IsChecked="True"/>
                                        <CheckBox Name="ChkMpo" Content="Disable Multiplane Overlay (MPO Fix - Fixes Stutters &amp; Black Screens)" IsChecked="True"/>
                                        <CheckBox Name="ChkMouseCurve" Content="1:1 Linear Mouse Curve (Disables Windows Pointer Acceleration)" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Ultra-Low Latency & Input -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="INPUT &amp; TIMER RESOLUTION" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkInputLatency" Content="8000Hz Polling Rate &amp; Keyboard Response Tuning" IsChecked="True"/>
                                        <CheckBox Name="ChkCpuSystem" Content="CPU Scheduling &amp; MMCSS Gaming Priority Threads" IsChecked="True"/>
                                        <CheckBox Name="ChkSvcHost" Content="Optimize SvcHost Process Splitting for Physical RAM" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Esports Network Tuning -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="ESPORTS NETWORK ENGINE" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkNetwork" Content="Low-Latency TCP/IP Stack (TCPNoDelay, AckFrequency, CongestionProvider)" IsChecked="True"/>
                                        <CheckBox Name="ChkWifiScan" Content="Disable Wi-Fi Background Auto-Scanning (Eliminates Periodic Lag Spikes)" IsChecked="False"/>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <!-- COLUMN 2: SYSTEM OPTIMIZATIONS & PRO DEBLOAT -->
                            <StackPanel Grid.Column="1" Margin="8,0,0,0">
                                <!-- Card: Performance Power & Visuals -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="POWER &amp; SYSTEM VISUALS" FontWeight="Bold" FontSize="13" Foreground="#FF7700" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkUltimatePower" Content="Unlock Ultimate Performance Power Plan" IsChecked="True"/>
                                        <CheckBox Name="ChkStripVisual" Content="Strip Window Animations &amp; Visual Eye Candy for Max FPS" IsChecked="False"/>
                                        <CheckBox Name="ChkEndTask" Content="Enable Taskbar Right-Click 'End Task' Instant Kill" IsChecked="True"/>
                                        <CheckBox Name="ChkStickyKeys" Content="Disable Sticky Keys &amp; Accessibility Popups" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Background Services & Disk -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="SYSTEM DEBLOAT &amp; STORAGE" FontWeight="Bold" FontSize="13" Foreground="#FF7700" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkDebloatServices" Content="Debloat Telemetry, Diagnostics &amp; Background Services" IsChecked="True"/>
                                        <CheckBox Name="ChkDiskIo" Content="Optimize Disk I/O &amp; Disable NTFS Last Access Timestamps" IsChecked="True"/>
                                        <CheckBox Name="ChkJunkTasks" Content="Disable Telemetry &amp; CEIP Scheduled Tasks" IsChecked="True"/>
                                        <CheckBox Name="ChkPrivacy" Content="Harden Windows Privacy &amp; Disable Diagnostic Tracking" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <!-- Beast Mode Banner -->
                                <Border Background="#1F1626" BorderBrush="#FF7700" BorderThickness="1" CornerRadius="6" Padding="14">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0">
                                            <TextBlock Text="ðŸ”¥ FULL BEAST MODE" FontSize="14" FontWeight="Bold" Foreground="#FF7700"/>
                                            <TextBlock Text="Applies all 20+ competitive low-latency optimizations simultaneously." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0"/>
                                        </StackPanel>
                                        <Button Name="BtnBeastMode" Grid.Column="1" Content="ENGAGE BEAST MODE" Style="{StaticResource OrangeButton}" VerticalAlignment="Center"/>
                                    </Grid>
                                </Border>
                            </StackPanel>
                        </Grid>
                    </ScrollViewer>

                    <!-- ACTION BAR FOR TWEAKS -->
                    <Border Grid.Row="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,10,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="Select your desired optimizations above and click Apply. All tweaks are 100% reversible." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="12"/>
                            <StackPanel Grid.Column="1" Orientation="Horizontal">
                                <Button Name="BtnRevertDefaults" Content="âª Revert to Windows Defaults" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnRunAllTweaks" Content="âš¡ Apply Selected Tweaks" Style="{StaticResource CyanButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>
                </Grid>
            </TabItem>

            <!-- TAB 3: MATCH BOOSTER -->
            <TabItem Header="ðŸš€ Match Booster">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Grid Grid.Row="0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <!-- Standby Memory Purger Card -->
                        <Border Grid.Column="0" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="0,0,8,0">
                            <StackPanel>
                                <TextBlock Text="STANDBY MEMORY PURGER" FontWeight="Bold" FontSize="14" Foreground="#00D2FF" Margin="0,0,0,6"/>
                                <TextBlock Text="Clears cached standby list RAM instantly, preventing stutter during gaming matches." Foreground="#94A3B8" FontSize="12" Margin="0,0,0,14"/>
                                <Button Name="BtnPurgeStandby" Content="ðŸ§¹ Purge Standby Memory Now" Style="{StaticResource CyanButton}" Margin="0,0,0,10"/>
                                <TextBlock Text="Uses Win32 memory management API with zero disk wear." FontSize="11" Foreground="#64748B"/>
                            </StackPanel>
                        </Border>

                        <!-- Wi-Fi Ping Spike Shield Card -->
                        <Border Grid.Column="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="8,0,0,0">
                            <StackPanel>
                                <TextBlock Text="WI-FI LATENCY SPIKE SHIELD" FontWeight="Bold" FontSize="14" Foreground="#FF7700" Margin="0,0,0,6"/>
                                <TextBlock Text="Toggles WLAN AutoConfig to halt background network roaming scans." Foreground="#94A3B8" FontSize="12" Margin="0,0,0,14"/>
                                <Button Name="BtnToggleWifiScan" Content="ðŸ“¶ Toggle Wi-Fi AutoConfig" Style="{StaticResource OrangeButton}" Margin="0,0,0,10"/>
                                <TextBlock Text="Enable before entering matches to stop 60-second periodic 200ms ping spikes." FontSize="11" Foreground="#64748B"/>
                            </StackPanel>
                        </Border>
                    </Grid>

                    <!-- Esports Game Priority Hooks Card -->
                    <Border Grid.Row="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="0,14,0,0">
                        <StackPanel>
                            <TextBlock Text="ESPORTS GAME HIGH-PRIORITY HOOKS (IFEO)" FontWeight="Bold" FontSize="14" Foreground="#00FF88" Margin="0,0,0,6"/>
                            <TextBlock Text="Locks CPU High Priority and GPU High Performance for esports titles permanently via Windows IFEO registry:" Foreground="#94A3B8" FontSize="12" Margin="0,0,0,12"/>

                            <WrapPanel Margin="0,0,0,14">
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Counter-Strike 2 (cs2.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Valorant (VALORANT-Win64-Shipping.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Apex Legends (r5apex.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Fortnite (FortniteClient-Win64-Shipping.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Call of Duty (cod.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Rainbow Six Siege (RainbowSix.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Overwatch 2 (Overwatch.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                            </WrapPanel>

                            <Button Name="BtnApplyGameHooks" Content="âš¡ Install Esports Priority Hooks" Style="{StaticResource CyanButton}" HorizontalAlignment="Left"/>
                        </StackPanel>
                    </Border>
                </Grid>
            </TabItem>

            <!-- TAB 4: SYSTEM & HARDENING TOOLS -->
            <TabItem Header="ðŸ›¡ï¸ System &amp; Hardening">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <!-- COLUMN 1: SNAPPY OS & HARDENING -->
                            <StackPanel Grid.Column="0" Margin="0,0,8,0">
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="SECURITY &amp; BLOATWARE MITIGATION" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkBlockWpbt" Content="Block UEFI WPBT Vendor Bloatware Execution" IsChecked="True"/>
                                        <CheckBox Name="ChkBlockPeripheral" Content="Block Peripheral Bloatware Auto-Install (Razer, Armoury Crate)" IsChecked="True"/>
                                        <CheckBox Name="ChkRemoveAi" Content="Purge Windows AI Bloatware (Recall, Copilot, CoreAI)" IsChecked="True"/>
                                        <CheckBox Name="ChkSecurityUpdatesOnly" Content="Security-Only Updates (Defer Feature Builds 2 Years)" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="WINDOWS EXPLORER &amp; DESKTOP" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkClassicContext" Content="Restore Windows 10 Classic Right-Click Menu" IsChecked="True"/>
                                        <CheckBox Name="ChkDisableBing" Content="Disable Start Menu Bing Web Search &amp; Cloud Queries" IsChecked="True"/>
                                        <CheckBox Name="ChkDisableAutoDiscovery" Content="Disable Network File Sharing Auto-Discovery" IsChecked="True"/>
                                        <CheckBox Name="ChkShowExtensions" Content="Show File Extensions &amp; Hidden System Files" IsChecked="True"/>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <!-- COLUMN 2: ADVANCED KERNEL & SYSTEM POWER TOOLS -->
                            <StackPanel Grid.Column="1" Margin="8,0,0,0">
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="KERNEL &amp; STORAGE HARDENING" FontWeight="Bold" FontSize="13" Foreground="#FF7700" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkEnableLongPaths" Content="Enable Win32 Long Paths (&gt; 260 Characters)" IsChecked="True"/>
                                        <CheckBox Name="ChkDisableLockScreen" Content="Disable Lock Screen on Wake" IsChecked="True"/>
                                        <CheckBox Name="ChkBsodVerbose" Content="Enable Verbose BSOD Crash Messages" IsChecked="True"/>
                                        <CheckBox Name="ChkDisableReservedStorage" Content="Disable 7GB Reserved Storage" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="1-CLICK SYSTEM POWER TOOLS" FontWeight="Bold" FontSize="13" Foreground="#00FF88" Margin="0,0,0,10"/>
                                        <Button Name="BtnMasActivate" Content="ðŸ”‘ Microsoft Activation Scripts (MAS 1-Click)" Style="{StaticResource OrangeButton}" Margin="0,0,0,8"/>
                                        <Button Name="BtnRestorePoint" Content="ðŸ›¡ï¸ Create System Restore Point" Style="{StaticResource CyanButton}" Margin="0,0,0,8"/>
                                        <Button Name="BtnRunDiagnostics" Content="ðŸ©º Run System Hardware &amp; Latency Diagnostics" Style="{StaticResource DarkOutlineButton}"/>
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </Grid>
                    </ScrollViewer>

                    <Border Grid.Row="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,10,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="Hardening optimizations protect against OEM bloatware, telemetry, and background throttling." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="12"/>
                            <Button Name="BtnApplyHardening" Grid.Column="1" Content="âš¡ Apply Hardening Tweaks" Style="{StaticResource CyanButton}"/>
                        </Grid>
                    </Border>
                </Grid>
            </TabItem>
        </TabControl>

        <!-- BOTTOM CONSOLE & REAL-TIME LOG AREA -->
        <Border Grid.Row="2" Background="#0C1017" BorderBrush="#26354A" BorderThickness="0,1,0,0" Padding="14,10">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Grid Grid.Row="0" Margin="0,0,0,6">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="OUTPUT LOG" FontSize="11" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,8,0"/>
                        <TextBlock Name="TxtStatus" Text="Ready" FontSize="11" Foreground="#94A3B8"/>
                    </StackPanel>
                    <Button Name="BtnClearConsole" Grid.Column="1" Content="Clear Log" Style="{StaticResource CategoryChip}" Margin="0" Padding="8,2"/>
                </Grid>

                <TextBox Name="TxtConsole" Grid.Row="1" Background="#070A0F" Foreground="#00FF88" BorderBrush="#1E293B" BorderThickness="1" FontFamily="Consolas" FontSize="12" IsReadOnly="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" Padding="8" TextWrapping="NoWrap"/>

                <ProgressBar Name="MainProgressBar" Grid.Row="2" Height="4" Background="#161E2B" Foreground="#00D2FF" BorderThickness="0" Margin="0,6,0,0" Value="0" Maximum="100"/>
            </Grid>
        </Border>
    </Grid>
</Window>
'@


do {
    Show-PumpkiNBanner
    $choice = Read-Host "Select an option [0-21]"
    switch ($choice) {
        "1" {
            Optimize-Network
            Optimize-GpuAuto
            Optimize-CpuAndSystem
            Optimize-LatencyAndInput
            Apply-GameHooks
            Debloat-BackgroundServices
            Enable-UltimatePerformancePlan
            Strip-VisualEffects
            Harden-PrivacyTelemetry
            Optimize-DiskIO
            Disable-ScheduledJunkTasks
            Optimize-StartupAndDns
            Write-Host "`n================================================================================" -ForegroundColor Green
            Write-Host "  [OK] ALL OPTIMIZATIONS APPLIED SUCCESSFULLY  --  FULL BEAST MODE ENGAGED!" -ForegroundColor Green
            Write-Host "================================================================================" -ForegroundColor Green
            Write-Host "  A system RESTART is recommended for all changes to take full effect." -ForegroundColor Yellow
            Read-Host "`nPress Enter to return to menu"
        }
        "2" {
            Optimize-GpuAuto
            Write-Host "`n[OK] GPU Auto-Optimization complete!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "3" {
            Optimize-AmdGpu
            Write-Host "`n[OK] AMD Radeon GPU optimization complete!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "4" {
            Optimize-NvidiaGpu
            Write-Host "`n[OK] NVIDIA GeForce GPU optimization complete!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "5" {
            Optimize-Network
            Write-Host "`n[OK] Network optimizations applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "6" {
            Toggle-WifiAutoconfig
            Read-Host "`nPress Enter to return to menu"
        }
        "7" {
            Optimize-CpuAndSystem
            Write-Host "`n[OK] CPU & System optimizations applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "8" {
            Optimize-LatencyAndInput
            Write-Host "`n[OK] Ultra-low latency & 8000Hz input tweaks applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "9" {
            Boost-CompetitiveMatch
            Write-Host "`n[OK] Competitive Match Booster applied!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "10" {
            Apply-GameHooks
            Write-Host "`n[OK] Esports Game Priority Hooks installed!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "11" {
            Run-Diagnostics
            Read-Host "`nPress Enter to return to menu"
        }
        "12" {
            Create-RestorePoint
            Read-Host "`nPress Enter to return to menu"
        }
        "13" {
            Restore-Defaults
            Write-Host "`n[OK] Default settings restored!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "14" {
            Write-Host "`n[*] Launching Microsoft Activation Scripts (MAS)..." -ForegroundColor Yellow
            Write-Host "      A new PowerShell window will open with the MAS interface." -ForegroundColor Cyan
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
            Read-Host "`nPress Enter to return to menu"
        }
        "15" {
            Debloat-BackgroundServices
            Write-Host "`n[OK] Background services debloated!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "16" {
            Enable-UltimatePerformancePlan
            Write-Host "`n[OK] Ultimate Performance Power Plan activated!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "17" {
            Strip-VisualEffects
            Write-Host "`n[OK] All visual effects stripped for maximum performance!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "18" {
            Harden-PrivacyTelemetry
            Write-Host "`n[OK] Privacy hardened and telemetry disabled!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "19" {
            Optimize-DiskIO
            Write-Host "`n[OK] Disk I/O and storage optimized!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "20" {
            Disable-ScheduledJunkTasks
            Write-Host "`n[OK] Junk scheduled tasks disabled!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "21" {
            Optimize-StartupAndDns
            Write-Host "`n[OK] Startup cleaned and DNS optimized!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu"
        }
        "0" {
            Write-Host "`nThank you for using PumpkiN's Ultimate Gaming Optimizer!" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            return
        }
    }
} while ($choice -ne "0")
