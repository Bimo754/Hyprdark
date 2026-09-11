# Hyprdark

An ultra-refined, distraction-free, bare-minimum Arch Linux desktop environment powered by Hyprland and Quickshell.

---

## Architectural Highlights

- **Apple Dark Frosted Glass Aesthetic:** Monochromatic `rgba(22, 22, 26, 0.82)` frosted glass with subtle blur, 1px hairline borders (`rgba(255, 255, 255, 0.12)`), solid white typography hierarchy, and zero neon/rainbow clutter.
- **Strict Single Responsibility Principle (<150 Lines/File):** Every UI and telemetry component is decomposed into clean micro-components strictly under 150 lines.
- **Top-Left Capsule Island:**
  1. **Arch Logo Launcher:** 1-click launcher triggering Rofi application menu.
  2. **Workspaces 1–5:** Interactive workspace switcher with solid white active pill lens and mouse wheel scroll navigation.
  3. **Target IP Telemetry:** Displays current active engagement target IP (`~/.local/share/hyprdark/target_ip`) with 1-click clipboard copy (`wl-copy`).
  4. **VPN Telemetry:** Detects and displays active VPN IP (`tun0`/`wg0`) with 1-click clipboard copy (`wl-copy`).
- **Dual-Mode Bar Architecture (Pinned vs. Floating Dynamic Island):**
  - **Pinned Mode (Default):** Fixed 52px exclusive zone reserving top space for status bar capsules with layer-shell click-through masking.
  - **Dynamic Island Mode (`Super + W`):** Autohiding floating mode with zero reserved space (`exclusiveZone: 0`), allowing applications to utilize 100% of screen height. Islands retract above the screen into minimalist bubbles and pop down with Apple Dynamic Island wobbly spring physics when the mouse hits the monitor's top bezel (`y = 0`).

---

## Keyboard Shortcuts Reference

Shortcuts use the `Super` key (`$mainMod`), with dedicated modifier combos (`Ctrl + Alt`) for relative workspace navigation and window management.

### Core Application Launchers
| Shortcut | Application / Action | Description |
| :--- | :--- | :--- |
| `Super + Return` | Terminal | Launches Kitty terminal |
| `Super + Space` | Application Menu | Launches Rofi application menu |
| `Super + E` | File Manager | Launches Thunar file manager |
| `Super + B` | Web Browser | Launches Brave browser |
| `Super + S` | Text Editor | Launches Sublime Text |

### Window & Workspace Management
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Super + Q` | Close Window | Closes currently focused window |
| `Super + V` | Toggle Floating | Toggles window floating state |
| `Super + F` | Toggle Fullscreen | Toggles fullscreen mode |
| `Super + W` | Toggle Bar Mode | Switches between Pinned (Waybar-like) and Floating Dynamic Island mode |
| `Super + Arrow Keys` / `H/J/K/L` | Focus Navigation | Move focus in direction (Vim + Arrows) |
| `Super + Shift + Arrow Keys` / `H/J/K/L` | Move Window | Move active window in tiling layout |
| `Super + 1 .. 5` | Switch Workspace | Jump to workspace 1 through 5 |
| `Super + Shift + 1 .. 5` | Move to Workspace | Move focused window to workspace 1 through 5 |
| `Ctrl + Alt + Left / Right` | Relative Workspace Switch | Switch to previous (`ws - 1`) or next (`ws + 1`) workspace |
| `Ctrl + Alt + Shift + Left / Right` | Move Window Relative | Move focused window to previous or next workspace |

### Screenshots, Media & System
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Print` | Fullscreen Screenshot | Captures full screen to clipboard (`grim`) |
| `Super + Shift + S` | Area Screenshot | Interactive area crop and annotation (`grim + slurp + swappy`) |
| `Volume Keys` | Audio Volume / Mute | Volume up, down, mute toggle (`wpctl`) |
| `Brightness Keys` | Screen Brightness | Adjust display backlight (`brightnessctl`) |
| `Super + Shift + L` | Lock Screen | Locks session with Hyprlock |
| `Super + Shift + M` | Exit Hyprland | Exits Hyprland session |
| `Super + Left Click Drag` | Move Floating Window | Drags window across screen |
| `Super + Right Click Drag` | Resize Window | Resizes window interactively |

### Top-Left Island Telemetry Actions
| Action / Command | Feature | Description |
| :--- | :--- | :--- |
| `set-target <IP>` | Target Setter | Sets target IP (`~/.local/share/hyprdark/target_ip`) |
| `Left Click Target Badge` | Copy Target IP | Copies active target IP to system clipboard (`wl-copy`) |
| `Left Click VPN Badge` | Copy VPN IP | Copies active VPN IP (`tun0`/`wg0`) to system clipboard |
| `Scroll on Workspace Pill` | Workspace Scroll | Cycles through adjacent workspaces with mouse wheel |

### Wallpaper & Video Engine Controls
| Action / Command | Feature | Description |
| :--- | :--- | :--- |
| `wallpaper-ctl.sh` | Interactive Selector | Opens Rofi menu to pick between static images and video loops |
| `wallpaper-ctl.sh <file>` | Direct Setter | Automatically detects image or video and applies with optimal engine |
| `wallpaper-ctl.sh --daemon [s]` | Auto-Rotation Daemon | Automatically rotates wallpapers every 5 minutes (300s default) |
| `wallpaper-ctl.sh --next` | Next Wallpaper | Manually cycles forward to next wallpaper/video in `Background/` |
| `wallpaper-ctl.sh --prev` | Previous Wallpaper | Manually cycles backward to previous wallpaper/video in `Background/` |
| `wallpaper-ctl.sh --random` | Random Wallpaper | Switches to a random wallpaper from `Background/` |
| `wallpaper-ctl.sh --restore` | Session Restore | Restores previously saved wallpaper |

---

## Unified Wallpaper & Video Engine

Hyprdark features a high-performance, resource-efficient dual-engine wallpaper architecture:
- **Static Wallpapers (`.png`, `.jpg`, `.webp`)**: Handled by `hyprpaper` with native C++ performance (0% CPU, ~15MB RAM).
- **Video Wallpapers (`.mp4`, `.webm`)**: Handled by `mpvpaper` with hardware-accelerated GPU decoding (`--hwdec=auto`), disabled audio processing (`--no-audio`), and automatic pausing when windows are fullscreen or maximized (`-p -a MAX`).
- **Auto-Cycling Daemon**: Rotates automatically every 5 minutes across all static images and video loops in `Background/`.
- **Persistence**: Saved automatically to `~/.local/share/hyprdark/current_wallpaper` and restored on login.

---

## Verification & Testing
Run automated line count audit:
```bash
find config/quickshell -name "*.qml" -exec wc -l {} + | sort -n
```
All files strictly satisfy the `< 150 lines` requirement.


