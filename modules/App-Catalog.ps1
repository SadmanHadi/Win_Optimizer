<#
================================================================================
  PumpkiN's Modular Suite: 10-Category WinGet Software Catalog & Runner Engine
================================================================================
#>

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

function Install-DirectXDirect {
    [CmdletBinding()]
    param(
        [scriptblock]$LogCallback
    )

    $msg = "[*] Downloading official Microsoft DirectX End-User Runtime Web Installer..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    $url = "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe"
    $tempFile = Join-Path $env:TEMP "dxwebsetup.exe"

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
        (New-Object System.Net.WebClient).DownloadFile($url, $tempFile)
        
        $msg = "[*] Executing DirectX silent installation (/Q)..."
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }

        $proc = Start-Process -FilePath $tempFile -ArgumentList "/Q" -Wait -PassThru
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue

        if ($proc.ExitCode -eq 0) {
            $msg = "[+] SUCCESS: DirectX Legacy Runtimes installed successfully!"
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
            return $true
        } else {
            $msg = "[-] DirectX setup exited with code $($proc.ExitCode)"
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor DarkYellow }
            return $false
        }
    } catch {
        $msg = "[-] Failed to download or install DirectX: $($_.Exception.Message)"
        if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
        return $false
    }
}

function Install-VcRedistAioDirect {
    [CmdletBinding()]
    param(
        [scriptblock]$LogCallback
    )

    $msg = "[*] Downloading official Microsoft Visual C++ 2015-2022 Redistributables..."
    if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient

    $urls = @(
        @{ Name = "VC++ 2015-2022 x64"; Url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"; File = Join-Path $env:TEMP "vc_redist.x64.exe" },
        @{ Name = "VC++ 2015-2022 x86"; Url = "https://aka.ms/vs/17/release/vc_redist.x86.exe"; File = Join-Path $env:TEMP "vc_redist.x86.exe" }
    )

    $allSuccess = $true
    foreach ($item in $urls) {
        try {
            $msg = "[*] Downloading $($item.Name)..."
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Cyan }
            $wc.DownloadFile($item.Url, $item.File)

            $msg = "[*] Installing $($item.Name) silently..."
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Yellow }
            $proc = Start-Process -FilePath $item.File -ArgumentList "/install /quiet /norestart" -Wait -PassThru
            Remove-Item $item.File -Force -ErrorAction SilentlyContinue

            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                $msg = "[+] SUCCESS: $($item.Name) installed successfully!"
                if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Green }
            } else {
                $msg = "[!] Warning: $($item.Name) exited with code $($proc.ExitCode)"
                if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor DarkYellow }
            }
        } catch {
            $msg = "[-] Failed to install $($item.Name): $($_.Exception.Message)"
            if ($LogCallback) { & $LogCallback $msg } else { Write-Host $msg -ForegroundColor Red }
            $allSuccess = $false
        }
    }
    return $allSuccess
}

# ==============================================================================