# Hyprdark: Master Architecture, Planning, and Progress Tracker

## 1. System Baseline and Environment Context

- Operating System: Arch Linux x86_64
- Linux Kernel: Standard Arch rolling release
- Compositor: Hyprland v0.56.2 (Libraries: Aquamarine 0.15.0, Hyprgraphics 0.5.1, Hyprutils 0.14.2, Hyprcursor 0.1.13, Hyprlang 0.6.8)
- Display Manager: SDDM (running via systemd sddm.service)
- Primary Shell: Zsh (/usr/bin/zsh) with Oh My Zsh, zsh-autosuggestions, and zsh-syntax-highlighting
- Package Managers: pacman, yay (AUR)
- Git Configuration:
  - User: Bimo754 <mohamad.chahed@hotmail.com>
  - Commit Signing: SSH signature enabled (Key: ~/.ssh/id_rsa.pub via id_mykey symlink, configured with allowedSignersFile)
- Working Workspace: /home/diamond/Desktop/Github/Hyprdark
- Target Role: Cybersecurity, Penetration Testing, Daily Driver Workflow (Integration with BlackArch repositories planned)

---

## 2. Design System and Aesthetic Principles

The visual identity of Hyprdark is engineered around high contrast, functional density, stealth, and cyber operational clarity.

- Palette:
  - Background Deep / Void: #0d0e15 (primary desktop / terminal background)
  - Surface Dark: #151722 (panels, popups, sidebars)
  - Surface Highlight: #1e2130 (active selections, card headers)
  - Border Inactive: #282c3f (subtle structure separation)
  - Border Active: #e63946 (Crimson Cyber) or #00ff66 (Matrix Green) or #00e5ff (Electric Cyan)
  - Text Primary: #e0e6ed (crisp high contrast)
  - Text Secondary: #7a829e (subtle metadata)
  - Text Critical / Alert: #ff3344 (errors, critical notifications, target lock)
  - Text Warning: #ffaa00 (VPN disconnected, low battery)
  - Text Success: #00ff66 (VPN active, service healthy)
- Gradient Rule: PROFESSIONAL STEALTH GRADIENTS PERMITTED. Gradients must NEVER look "vibe-coded", pastel, or rainbow. Gradients must be strictly high-contrast, directional metallic/cyber sheens (e.g., deep charcoal #1a1c26 fading into razor-sharp cyber crimson #e63946 or electric cyan #00e5ff at 45-degree angles, subtle dark glass bevels, or dark-to-stealth linear fades).
- Geometry: Sharp or micro-rounded corners (2px to 4px maximum). No bubbly, pill-shaped, or floating rounded UI.
- Iconography: Strictly NO emojis. All icons must use monospace Nerd Font glyphs (JetBrains Mono Nerd Font / FiraCode Nerd Font) or crisp SVG icons.
- Animation Rule: Fast, snappy, industrial transitions (100ms - 150ms linear or cubic-bezier(0.1, 1, 0.1, 1)). Zero elastic bounce or floating delays.
- Cyber Workflow Integration:
  - Permanent VPN/tun0 interface monitor.
  - Active Target IP tracker in the status bar with 1-click clipboard copy.
  - Quake-style dropdown scratchpad terminal for rapid shell access.
  - Native support for video/animated wallpapers (MP4 format).

---

## 3. Repository Architecture and Directory Structure

To maintain clean code, DRY principles, and automated single-command reinstallation, the repository is organized as follows:

```
Hyprdark/
├── install.sh                  # Idempotent master setup and deployment script
├── commands.md                 # Baseline Arch setup commands and reference
├── currentsetup.md              # Initial inventory of default applications
├── TRACKING.md                 # This file: persistent architectural and progress log
├── Background/                 # Static and animated MP4 video wallpapers
│   ├── knight-red-cloak-moewalls-com.mp4
│   ├── protocolo-sombra-overwatch-moewalls-com.mp4
│   ├── red-skull-glitch-moewalls-com.mp4
│   └── windows-logo-glitch-moewalls-com.mp4
├── config/                     # Modular configuration files (symlinked to ~/.config/)
│   ├── hypr/
│   │   ├── hyprland.conf       # Clean modular root config
│   │   ├── monitors.conf       # Display outputs and scaling
│   │   ├── env.conf            # Environment variables
│   │   ├── autostart.conf      # Background services and daemons
│   │   ├── look_and_feel.conf  # Gaps, borders, animations, rules
│   │   ├── keybinds.conf       # Keybindings and window management
│   │   ├── windowrules.conf    # Floating, pinning, and security app rules
│   │   ├── hyprlock.conf       # Screen locker configuration
│   │   └── hypridle.conf       # Idle, DPMS, and timeout management
│   ├── waybar/
│   │   ├── config.jsonc        # Top bar layout and modules
│   │   ├── bottom-bar.jsonc    # Optional bottom launcher / workspace dock
│   │   ├── style.css           # Pure dark, sharp CSS styling
│   │   └── modules/            # Custom scripts (VPN monitor, Target IP)
│   ├── rofi/
│   │   ├── config.rasi         # Core launcher configuration
│   │   ├── theme.rasi          # Dark cyber flat styling
│   │   └── scripts/            # Pentest tool runner, target selector, power menu
│   ├── kitty/
│   │   ├── kitty.conf          # GPU acceleration, keybinds, font sizing
│   │   └── theme.conf          # Custom Hyprdark high-contrast cyber palette
│   ├── swaync/ or dunst/       # Notification center configuration
│   ├── wlogout/                # Session logout overlay layout and icons
│   ├── yazi/                   # Fast terminal file manager config
│   └── gtk-3.0/                # GTK dark styling overrides
├── scripts/                    # Standalone utility scripts
│   ├── set-target.sh           # Set active pentest target IP
│   ├── vpn-status.sh           # Monitor tun0 / wireguard status
│   ├── wallpaper-ctl.sh        # Switch between static and mp4 video wallpapers
│   ├── screenshot.sh           # Grim/Slurp crop, copy, or edit with Swappy
│   └── backup.sh               # Safety backup of existing ~/.config files
└── themes/                     # System-level themes
    ├── grub/                   # Custom 1080p sharp dark GRUB theme
    └── sddm/                   # Custom dark SDDM login theme
```

---

## 4. Software Evaluation and Selection Matrix

Below is an engineering analysis of available software for each component of the desktop environment, comparing alternatives against the criteria: Performance, Wayland Native Support, Customizability, and Suitability for Cybersecurity workflows.

### 4.1. Terminal Emulator

| Software | Pros | Cons | Verdict / Recommendation |
| :--- | :--- | :--- | :--- |
| Kitty | GPU-accelerated, built-in kitten ecosystem (icat image preview, hints, diff, unicode), scriptable remote control, excellent tabs and splits, low latency. | Slightly higher RAM usage than foot. | RECOMMENDED. Highly customizable, supports Yazi image preview out-of-the-box, already installed. |
| Alacritty | Extremely fast raw throughput, pure Rust, low resource overhead. | Lacks tabs, splits, and graphics protocol without tmux. | Alternative for lightweight tasks. |
| Foot | Blazing fast, pure Wayland native, client-daemon mode saves memory, great keyboard selection. | Limited graphics protocol support compared to Kitty. | Excellent lightweight secondary terminal. |
| WezTerm | Rust-based, Lua config, built-in multiplexer, SSH domains. | Heavy binary, more complex Lua configuration. | Solid, but Kitty offers simpler integration. |
| Ghostty | Fast, modern Zig codebase, native Wayland rendering. | Relatively new, AUR packaging still maturing. | Worth monitoring, but Kitty is currently more proven. |

### 4.2. File Manager (GUI and CLI)

| Software | Pros | Cons | Verdict / Recommendation |
| :--- | :--- | :--- | :--- |
| Thunar (GUI) | Extremely lightweight, modular GTK3, instant startup, supports custom action scripts (e.g. "Run Hash Check", "Open Terminal Here", "Extract Archive", "Launch Ghidra/Burp"). | Does not have built-in terminal split pane like Dolphin. | RECOMMENDED (GUI). Far faster than Dolphin on Wayland, clean dark GTK integration, custom pentest action support. |
| Dolphin (GUI) | Rich features, split view, embedded terminal panel (F4). | Drags KDE Frameworks dependencies, bulky appearance, slower cold start. | Kept as optional fallback. |
| Nemo (GUI) | Dual-pane navigation, Cinnamon GTK base, reliable file operations. | Moderate dependency weight, less customizable than Thunar. | Alternative. |
| Yazi (CLI) | Written in Rust, non-blocking asynchronous I/O, built-in image and PDF preview inside Kitty, lightning-fast navigation, tabs. | Requires terminal knowledge (vim keybindings). | RECOMMENDED (CLI/TUI). Essential for rapid penetration testing file inspection without GUI overhead. |
| Ranger (CLI) | Mature, Python-based, rich preview ecosystem. | Noticeably slower on large directories compared to Yazi. | Superseded by Yazi. |

### 4.3. Status Bar (Top Bar and Bottom Bar)

| Software | Pros | Cons | Verdict / Recommendation |
| :--- | :--- | :--- | :--- |
| Waybar | De-facto Wayland standard, highly modular JSONC + CSS styling, supports multiple concurrent bars (both Top Status and Bottom Dock/Bar), native network, hardware monitors, custom shell scripts (tun0 IP, target IP). | Requires CSS tuning for custom styles. | RECOMMENDED. Configured for a dedicated Top Information Bar + optional Bottom Quick Dock/Workspaces Bar. |
| Eww | Unlimited widget flexibility, ElKowar's markup, GTK styling. | High maintenance, syntax learning curve, higher idle CPU if unoptimized. | Overkill for status bar needs. |
| AGS (Aylur's GTK Shell) | TypeScript/GJS powered, modern fluid components. | Requires JavaScript/TypeScript toolchain, frequent breaking changes across major versions. | Complex maintenance. |
| Ironbar | Rust-based, lightweight. | Smaller community, fewer prebuilt modules for complex security monitoring. | Not yet mature enough. |

### 4.4. Application Launcher, Window Switcher, and Quick Menus

| Software | Pros | Cons | Verdict / Recommendation |
| :--- | :--- | :--- | :--- |
| Rofi (Wayland native in extra/rofi 2.0) | Standard launcher, complete CSS-like styling (.rasi), support for dmenu mode, window switching, clipboard search, custom pentest script runners, no emojis needed. | Requires .rasi theming. | RECOMMENDED. Highly versatile for launcher, window switcher, and custom cyber utility menus. |
| Wofi | Simple GTK3 launcher, CSS styling, already installed. | Less flexible than Rofi, limited dmenu script modes, no built-in window switcher on Wayland. | Viable fallback, but Rofi provides more power. |
| Hyprlauncher | Built specifically for Hypr ecosystem, lightweight. | In very early development, limited custom script and module capabilities. | Experimental. |
| Fuzzel | Minimalist, suckless dmenu clone for Wayland, near-zero latency. | Pure text list only, limited multi-column formatting. | Great for minimalist hotkey runners. |

### 4.5. Wallpaper and Animated/Video Backgrounds

| Software | Pros | Cons | Verdict / Recommendation |
| :--- | :--- | :--- | :--- |
| mpvpaper | Plays video files (MP4, MKV, WebM) smoothly as wallpapers using mpv under Wayland, hardware accelerated, low CPU. | Uses more power during video playback than static images. | RECOMMENDED for animated MP4 backgrounds (the 4 video files in Background/). |
| awww (replaces swww in extra) | Blazing fast, animated GIF and static wallpaper daemon, smooth frame transitions, low memory footprint. | Does not directly decode MP4 video containers without converting to GIF. | RECOMMENDED for static/transition wallpapers. |
| Hyprpaper | Official Hyprland tool, ultra-fast IPC controls. | Only supports static images (PNG/JPG), no video or GIF animation support. | Useful for ultra-low resource static profiles. |

### 4.6. Notification Management

| Software | Pros | Cons | Verdict / Recommendation |
| :--- | :--- | :--- | :--- |
| SwayNC | Modern notification center with slide-out control drawer, widget support, Do-Not-Disturb toggle, dark CSS styling, notification history. | Slightly higher footprint than Dunst. | RECOMMENDED for full-featured control panel and pentest notification logging. |
| Dunst | Classic, ultra-minimalist, single-process, low resource usage, already installed. | Floating banners only, no slide-out notification drawer or history GUI. | RECOMMENDED for ultra-minimalist profile. |
| Mako | Lightweight, native Wayland client. | Lacks notification history panel. | Simple alternative. |

### 4.7. Screen Locking, Idle, and Session Management

| Software | Pros | Cons | Verdict / Recommendation |
| :--- | :--- | :--- | :--- |
| Hyprlock | Official Hyprland screen lock, GPU-accelerated, native config syntax, supports dark cyber aesthetic, authentication feedback without emojis. | Wayland only. | RECOMMENDED. |
| Hypridle | Official Hyprland idle daemon, integrates cleanly with hyprlock, DPMS screen sleep, and suspend. | None. | RECOMMENDED. |
| Wlogout | Wayland logout menu overlay (Lock, Logout, Reboot, Shutdown, Suspend), CSS customizable, high contrast icons. | Needs custom icon/CSS tuning. | RECOMMENDED for session management hotkey. |

### 4.8. Clipboard, Screenshots, and On-Screen Display (OSD)

| Component | Selected Tool | Rationale |
| :--- | :--- | :--- |
| Clipboard Manager | cliphist + wl-clipboard + rofi | Fast SQLite clipboard history, handles both text and images, searchable via rofi. |
| Screenshot Suite | grim + slurp + swappy | Standard Wayland screenshot pipeline: area selection (slurp), capture (grim), annotation and redlining (swappy). |
| On-Screen Display | swayosd | Clean, dark, non-intrusive OSD for volume, brightness, caps-lock. |

### 4.9. Display Manager (Login Screen) and Bootloader (GRUB)

| Component | Software | Plan |
| :--- | :--- | :--- |
| Display Manager | SDDM | Custom dark cyber theme matching Hyprdark palette, disabling avatar roundness, sharp input fields, Wayland greeter enabled. |
| Bootloader | GRUB | Clean dark 1080p theme, custom background, eliminating duplicate EFI entries, setting fast timeout. |

### 4.10. System Theming and Font Hierarchy

- Fonts:
  - Primary Monospace & Terminal: `JetBrains Mono Nerd Font` (Clean, highly legible coding ligatures, comprehensive glyphs).
  - UI Font: `Inter` or `JetBrains Mono`.
- GTK Theme: `Adwaita-dark` base or custom dark CSS override matching #0d0e15.
- Qt Theme: `qt5ct` / `qt6ct` with dark palette synchronization to prevent white flashes in Qt apps.
- Icons: `Papirus-Dark` (sharp, monochromatic/dark style, zero emojis).
- Cursor: `Bibata-Modern-Classic` or dark Hyprcursor.

---

## 5. Implementation Status and History

### 5.1. Currently Implemented and Committed

- [x] Initial Repository Commit (Commit: `15ccee0`):
  - Added baseline `commands.md` (Arch setup, yay AUR helper, GRUB duplicate entry fix).
  - Added `currentsetup.md` (inventory of initial packages).
  - Added `Background/` with 4 animated video wallpapers:
    - `knight-red-cloak-moewalls-com.mp4` (77.8MB)
    - `protocolo-sombra-overwatch-moewalls-com.mp4` (29.6MB)
    - `red-skull-glitch-moewalls-com.mp4` (1.3MB)
    - `windows-logo-glitch-moewalls-com.mp4` (11.3MB)
  - Git commit signature verified with SSH key for `Bimo754 <mohamad.chahed@hotmail.com>`.
- [x] Repository Tracking and Architectural Design:
  - Created `TRACKING.md` documenting complete roadmap, software comparison matrix, and technical specs.
- [x] Phase 1 - Repository Skeleton and Deployment Engine:
  - Created directory hierarchy (`config/`, `scripts/`, `themes/`).
  - Created `scripts/backup.sh`: Automated snapshot utility saving current configs to `~/.local/share/hyprdark/backups/`.
  - Created `install.sh`: Master idempotent installer supporting package checks, backup, dotfile linking, and zsh setup.
- [x] Phase 2 - Core Hyprland Modular Configuration:
  - Deconstructed into modular configuration files in `config/hypr/`:
    - `hyprland.conf`: Master entry point sourcing sub-configs.
    - `monitors.conf`: Configured eDP-1 for 2560x1600@165Hz with 1.6 scaling.
    - `env.conf`: Set Wayland, Qt dark, and Chromium/Electron environment flags.
    - `autostart.conf`: Autostarts polkit, waybar, swaync/dunst, cliphist, hypridle, and wallpaper daemon.
    - `look_and_feel.conf`: Dark palette `#0d0e15`, 45-degree cyber crimson/stealth gradient borders, micro-radii (3px), snappy non-bouncy easing.
    - `keybinds.conf`: Full application bindings, Quake scratchpad terminal (`Super + ` `), media/brightness keys, screenshot pipeline.
    - `windowrules.conf`: Floating dialogs, Quake scratchpad terminal positioning, subtle terminal transparency.
    - `hyprlock.conf`: GPU-accelerated lockscreen with dark cyber authentication prompts (zero emojis).
    - `hypridle.conf`: Inactivity listeners for screen dimming (5 min), lock (6 min), and DPMS off (10 min).
    - `scripts/wallpaper-daemon.sh` & `scripts/wallpaper-ctl.sh`: Video wallpaper runners for MP4 backgrounds in `Background/`.
- [x] Phase 3 - Shell, Terminal, and File Management:
  - `config/zsh/.zshrc`: Configured Oh My Zsh, autosuggestions, syntax highlighting, two-line cyber prompt, target IP shortcuts (`set-target`, `target`), network status (`myip`), and package aliases.
  - `config/kitty/kitty.conf` & `theme.conf`: JetBrains Mono font, zsh shell, 20k scrollback, custom void dark `#0d0e15` palette with cyber crimson and electric cyan accents.
  - `config/yazi/yazi.toml` & `theme.toml`: Asynchronous Rust file manager with Kitty graphics protocol support and custom dark cyber palette.
  - `config/gtk-3.0/` & `config/Thunar/uca.xml`: Pure dark Adwaita-dark overrides, Papirus-Dark icons, custom Thunar actions (terminal, sublime, sha256 checksum).
  - `scripts/set-target.sh`: CLI and Rofi-based target IP setter for penetration testing.
- [x] Phase 4 - Upper Status Bar and Lower Bar (Waybar):
  - `config/waybar/config.jsonc`: Dual-bar layout with high-performance `top-bar` and `bottom-bar`.
  - Top Bar: Workspaces, active window title, live VPN monitor, Target IP monitor, hardware load (CPU/RAM/Temp), audio control, battery, and clock.
  - Bottom Bar: Dedicated quick-launch dock for Terminal, Quake shell, Files, Browser, Editor, Wallpaper changer, and storage.
  - `config/waybar/modules/`: Created `vpn-status.sh` and `target-status.sh` with interactive click handlers and JSON output.
  - `config/waybar/style.css`: Void dark `#0d0e15` palette, micro-radii, sharp borders, directional metallic gradients for active states.
- [x] Phase 5 - Menus, Runners, and Session Controls:
  - `config/rofi/config.rasi` & `theme.rasi`: High-contrast void dark application runner, command launcher, and window switcher.
  - `config/rofi/scripts/cyber-menu.sh`: Dedicated Cyber Operations HUD (Super + O) for target IP assignment, nmap triggers, HTTP server, and wallpaper selection.
  - `config/wlogout/layout` & `style.css`: Dark session overlay with keyboard accelerators for lock, logout, reboot, and shutdown.
- [x] Phase 6 - Screen Locker, Idle Daemon, and Notifications:
  - `config/swaync/config.json` & `style.css`: Dark cyber notification center with Do-Not-Disturb and volume slider.
  - `config/dunst/dunstrc`: Minimalist dark notification fallback.
  - `scripts/screenshot.sh`: Automated screen and area capture with clipboard sync and Swappy annotation editor.
- [x] Phase 7 - Wallpaper Daemon and Video Background Runner:
  - `config/hypr/scripts/wallpaper-daemon.sh`: Looping MP4 video wallpaper daemon.
  - `scripts/wallpaper-ctl.sh`: Dynamic video switcher.
- [x] Phase 8 - System Theming, SDDM Login, and GRUB Bootloader:
  - `themes/grub/theme.txt` & `install-grub-theme.sh`: 1080p high-contrast GRUB theme with timeout countdown, multi-OS detection fix, and automatic cfg generation.
  - `themes/sddm/hyprdark/` (`Main.qml`, `metadata.desktop`, `theme.conf`) & `install-sddm-theme.sh`: High-contrast dark cyber login greeter with digital clock and session selectors.
  - Master installer updated (`install.sh` supporting `--grub`, `--sddm`, and `--all` flags).

---

## 6. Step-by-Step Implementation Queue

Below is the planned sequential execution roadmap. Each step will be coded, configured, tested, and committed to git as an atomic milestone.

1. Phase 1: Repository Architecture and Backup / Installer Engine
   - [x] Build directory skeleton (`config/`, `scripts/`, `themes/`).
   - [x] Create `scripts/backup.sh` (safely snapshots existing user configs before any symlink).
   - [x] Create `install.sh` (automated idempotent installer supporting package checks, backup, and symlink deployment).

2. Phase 2: Core Hyprland Configuration Engine
   - [x] Split monolithic config into clean, modular `.conf` files:
     - [x] `monitors.conf` (auto resolution/preferred 165Hz)
     - [x] `env.conf` (Wayland environment flags, cursor sizes, toolkit hints)
     - [x] `autostart.conf` (launching polkit, bars, clipboard, notifications, wallpaper)
     - [x] `look_and_feel.conf` (dark palette borders with sleek directional cyber gradients, sharp micro-radii, snappy animations)
     - [x] `keybinds.conf` (clean navigation, window controls, cyber tool shortcuts)
     - [x] `windowrules.conf` (floating rules for pentest tools, dialogs, scratchpad terminal)
   - [x] Dropdown/Quake Scratchpad Terminal setup (Super + ` instant terminal scratchpad).
   - [x] GPU-accelerated lock screen (`hyprlock.conf`) and idle management (`hypridle.conf`).

3. Phase 3: Shell, Terminal, and File Management
   - [x] Zsh & Oh My Zsh configuration (`.zshrc`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, custom cyber prompt, pentest aliases).
   - [x] Kitty configuration (`kitty.conf` and `theme.conf` with pure dark cyber palette, JetBrains Mono font, zsh integration).
   - [x] Yazi CLI file manager configuration (`yazi.toml`, `theme.toml`, Kitty graphics preview).
   - [x] Thunar GUI file manager setup (`settings.ini`, `gtk.css`, `uca.xml` custom actions).
   - [x] Target IP utility (`scripts/set-target.sh`).

4. Phase 4: Upper Status Bar and Lower Bar (Waybar)
   - [x] Upper Bar (`config.jsonc`):
     - Workspaces indicator (clean numbers/labels, no emojis)
     - Active window title
     - Pentest modules: Active VPN (tun0 / wireguard IP) + Target IP indicator
     - System hardware metrics: CPU load, RAM usage, temperature
     - Audio volume, Battery status (BAT0), Clock/Date, Tray, Power
   - [x] Lower Bar / Dock (`bottom-bar` in `config.jsonc`):
     - Quick launchers: Terminal, Quake scratchpad, Thunar files, Brave browser, Sublime editor, Wallpaper picker
     - Network & root disk metrics
   - [x] Custom Waybar modules (`config/waybar/modules/`):
     - `vpn-status.sh` (tun0 / wg0 detection)
     - `target-status.sh` (active penetration test target IP)
   - [x] Waybar styling (`style.css`): Void dark `#0d0e15`, sharp borders, directional metallic gradients for active states.

5. Phase 5: Menus, Runners, and Session Controls
   - [x] Rofi launcher (`config.rasi` and dark cyber `theme.rasi`):
     - Application runner (`EXEC >`)
     - Active window switcher (`WINDOW >`)
     - Pentest quick scripts menu (`config/rofi/scripts/cyber-menu.sh` bound to Super + O)
     - Target IP setter dialog (`scripts/set-target.sh`)
   - [x] Clipboard manager integration (`cliphist` + `rofi` bound to Super + C).
   - [x] Session logout overlay (`wlogout/layout` & `style.css` bound to Super + X).

6. Phase 6: Screen Locker, Idle Daemon, and Notifications
   - [x] `hyprlock.conf`: High-contrast dark unlock screen with authentication indicator (zero emojis).
   - [x] `hypridle.conf`: Idle timeouts (screen dimming at 5m, lock at 6m, display power-off at 10m).
   - [x] Notification configuration (`swaync/config.json` & `style.css` + minimalist `dunst/dunstrc`).
   - [x] Screenshot pipeline (`scripts/screenshot.sh` using `grim` + `slurp` + `swappy`).

7. Phase 7: Wallpaper Daemon and Video Background Runner
   - [x] `config/hypr/scripts/wallpaper-daemon.sh`: Autostarts `mpvpaper` with video wallpaper loop.
   - [x] `scripts/wallpaper-ctl.sh`: Interactive Rofi/CLI switcher between the 4 video wallpapers in `Background/`.

8. Phase 8: System Theming, SDDM Login, and GRUB Bootloader
   - [x] GTK/Qt dark theme consistency configuration (`config/gtk-3.0/settings.ini`, `gtk.css`, environment variables).
   - [x] SDDM custom dark theme (`themes/sddm/hyprdark/` Main.qml, metadata, theme.conf, and `install-sddm-theme.sh`).
   - [x] GRUB dark cyber theme (`themes/grub/` theme.txt and automated `install-grub-theme.sh`).
   - [x] Full integration into master `install.sh` (`--grub`, `--sddm`, `--all` flags).

---

## 7. Context Persistence Log

This section records ongoing technical state so future instructions retain complete context without needing re-explanation:

- Monolithic vs Modular Hyprland: Standardizing on modular Hyprland `.conf` files sourced by `hyprland.conf`. This ensures compatibility with all standard Hyprland tools, syntax highlighters, and documentation.
- Wallpapers Available: 4 MP4 video files in `Background/` require `mpvpaper` for hardware-accelerated looping on Wayland.
- User Credentials and Git: Git commits must be signed using SSH format key `~/.ssh/id_rsa.pub` (symlinked as `~/.ssh/id_mykey.pub`).
- Target Directory: `/home/diamond/Desktop/Github/Hyprdark`
