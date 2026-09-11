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
- **Top-Center Dynamic Island Capsule:**
  1. **Clock & Calendar:** Clean monochromatic time and date pill; 1-click smoothly morphs into an interactive calendar view with backdrop dismissal.
  2. **Physical Multi-Notification Stack:** Displays up to 3 discrete frosted-glass notification capsules stacked vertically (`y: 0`, `y: 60`, `y: 120`). New arrivals push older notifications downward with spring physics (`Easing.OutBack`). A 4th incoming notification executes an upward merge eviction of the oldest card. Includes independent 5s timers with hover isolation (hovering pauses only that specific card) and fluid gap closing on dismissal.
- **Dual-Mode Bar Architecture (Pinned vs. Floating Dynamic Island):**
  - **Pinned Mode (Default):** Fixed 52px exclusive zone reserving top space for status bar capsules with layer-shell click-through masking.
  - **Dynamic Island Mode (`Super + W`):** Autohiding floating mode with zero reserved space (`exclusiveZone: 0`), allowing applications to utilize 100% of screen height. Islands retract above the screen into minimalist bubbles with concurrent upward suction physics and bloom down with spring morphing when pointer reaches the top bezel (`y = 0`) or notifications arrive.

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

### Top-Center Dynamic Island Actions
| Action / Command | Feature | Description |
| :--- | :--- | :--- |
| `Left Click Clock` | Expand Calendar | Morphs clock capsule into interactive monthly calendar |
| `Click Outside Calendar` | Close Calendar | Dismisses calendar back into clock capsule |
| `Left Click Notification` | Open / Focus App | Activates notification action and focuses the originating application |
| `Right Click Notification` | Dismiss Item | Dismisses individual notification pill; stack smoothly closes the gap |
| `Hover Notification` | Pause Expiration | Isolates hovered notification, pausing its 5-second countdown timer |

### Wallpaper Controls (Hyprpaper Native)
| Action / Command | Feature | Description |
| :--- | :--- | :--- |
| `wallpaper-ctl.sh` | Interactive Selector | Opens Rofi menu to browse and pick static wallpapers |
| `wallpaper-ctl.sh <file>` | Direct Setter | Applies target static wallpaper immediately |
| `wallpaper-ctl.sh --daemon [s]` | Auto-Rotation Daemon | Automatically rotates static wallpapers every 5 minutes (300s default) |
| `wallpaper-ctl.sh --next` | Next Wallpaper | Manually cycles forward to next static wallpaper in `~/Pictures/Wallpapers` |
| `wallpaper-ctl.sh --prev` | Previous Wallpaper | Manually cycles backward to previous static wallpaper |
| `wallpaper-ctl.sh --random` | Random Wallpaper | Switches to a random static wallpaper from `~/Pictures/Wallpapers` |
| `wallpaper-ctl.sh --restore` | Session Restore | Restores previously saved static wallpaper |

---

## Static Wallpaper Engine (Hyprpaper Native)

Hyprdark uses a pure, high-performance static wallpaper architecture powered by `hyprpaper`:
- **Wallpaper Directory**: Managed directly within `~/Pictures/Wallpapers` (automatically provisioned by `install.sh`).
- **Resource Overhead**: 0.0% CPU and ~15MB RAM via native C++ Wayland surface rendering.
- **Auto-Cycling Daemon**: Rotates automatically every 5 minutes across all static dark wallpapers in `~/Pictures/Wallpapers`.
- **Persistence**: Saved automatically to `~/.local/share/hyprdark/current_wallpaper` and restored on login.

---

## Verification & Testing
Run automated line count audit:
```bash
find config/quickshell -name "*.qml" -exec wc -l {} + | sort -n
```
All files strictly satisfy the `< 150 lines` requirement.


