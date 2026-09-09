# Hyprdark

A streamlined, high-contrast, dark-themed Hyprland desktop environment tailored for Arch Linux and cybersecurity workflows.

---

## Key Features
- **Aesthetic:** High-contrast void dark palette (`#0d0e15`), directional metallic cyber gradients for active states, sharp micro-radii (3px), strictly zero emojis (monospace Nerd Font glyphs only).
- **Cybersecurity Integration:** Real-time VPN interface (`tun0`/`wg0`) monitoring, active Target IP display with 1-click clipboard copy, dedicated Cyber Operations HUD, and Quake-style dropdown scratchpad terminal.
- **Dynamic Backgrounds:** Hardware-accelerated MP4 video wallpaper playback via `mpvpaper` with dynamic switching between the included video wallpapers.
- **Liquid Frosted Glass Status Bar:** Tide Island (powered by Quickshell + Qt 6 + native C++ backend) featuring a floating Dynamic Island, hardware-accelerated rendering, 0% CPU idle footprint, and fluid Apple micro-animations.
- **Cyber Arsenal & Telemetry:** Native C++ telemetry engine monitoring active Target IP (`~/.local/share/hyprdark/target_ip`) and VPN interfaces (`tun*`, `wg*`, `tailscale*`). Integrated Cyber Arsenal drawer (`Super + C`) for 1-click reconnaissance (Fast Nmap, Full Nmap, Vuln Scan, Ping) and tool launching (Burp Suite, Wireshark, Metasploit, Feroxbuster).
- **Workspace Navigation & Swapping:** Relative navigation (`Ctrl + Alt + Left/Right`), relative window movement (`Ctrl + Alt + Shift + Left/Right`), and full workspace window swapping (`Ctrl + Super + Left/Right`) that exchanges all windows between adjacent workspaces or slides workspaces cleanly when empty.
- **Architecture:** Fully modular, DRY configuration hierarchy with automated safety backup snapshotting, idempotent installer, and verified Git SSH commit signatures.

---

## Keyboard Shortcuts Reference

Shortcuts primarily use the `Super` key (`$mainMod` / Windows key), with dedicated modifier combos (`Ctrl + Alt`, `Ctrl + Super`) for relative navigation and workspace swapping.

### Dynamic Island & Cyber Operations
| Shortcut / Action | Feature | Description |
| :--- | :--- | :--- |
| `Super + C` | Cyber Arsenal & Telemetry | Opens interactive Apple Frosted Glass Cyber Arsenal card (Nmap scans, tool runners, Target IP setter) |
| `Super + Shift + C` | Clipboard History | Search and paste from SQLite clipboard history via Rofi |
| `Super + I` | Toggle Island | Manually toggle Dynamic Island auto-hide / visibility |
| `Super + TAB` | Workspace Overview | Opens interactive multi-workspace window overview |
| `Super + S` | Control Center | Toggles system quick settings (Wi-Fi, Bluetooth, volume, brightness) |
| `Super + N` | Notification Center | Toggles notification drawer and notification history |
| `Super + O` | Cyber Ops HUD | Interactive Rofi menu to set target IP, run scans, start HTTP server |
| `Super + \`` (Grave / Tilde) | Quake Scratchpad | Drops down or hides the persistent terminal scratchpad |
| `set-target <IP>` | Terminal Target Setter | Set active target IP directly from terminal shell (`set-target -c` to clear) |
| Left Click Target Island | Copy Target IP | 1-click copies active target IP to system clipboard |
| Left Click VPN Island | Copy VPN IP | 1-click copies active VPN IP (`tun0`/`wg0`) to system clipboard |

### Window & Layout Controls
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Super + Q` | Close Window | Closes/kills the currently focused window |
| `Super + V` | Toggle Floating | Toggles floating state for the focused window |
| `Super + F` | Toggle Fullscreen | Toggles fullscreen mode |
| `Super + P` | Pseudo Tiling | Toggles pseudotile mode in Dwindle layout |
| `Super + T` | Toggle Split | Toggles horizontal/vertical split orientation |

### Window Focus Navigation
| Shortcut | Action |
| :--- | :--- |
| `Super + Left` / `Super + H` | Focus Left |
| `Super + Right` / `Super + L` | Focus Right |
| `Super + Up` / `Super + K` | Focus Up |
| `Super + Down` / `Super + J` | Focus Down |

### Window Movement (Tiling)
| Shortcut | Action |
| :--- | :--- |
| `Super + Shift + Left` / `Super + Shift + H` | Move Window Left |
| `Super + Shift + Right` / `Super + Shift + L` | Move Window Right |
| `Super + Shift + Up` / `Super + Shift + K` | Move Window Up |
| `Super + Shift + Down` / `Super + Shift + J` | Move Window Down |

### Workspace Management
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Super + 1 .. 0` | Switch to Workspace | Direct jump to Workspace 1 through 10 |
| `Super + Shift + 1 .. 0` | Move Window to Workspace | Move active window to Workspace 1 through 10 |
| `Ctrl + Alt + Left / Right` | Relative Workspace Switch | Navigate to adjacent previous (`ws - 1`) or next (`ws + 1`) workspace |
| `Ctrl + Alt + Shift + Left / Right` | Move Window Relative | Move active window to adjacent previous or next workspace |
| `Ctrl + Super + Left / Right` | Swap Workspaces / Slide | Reciprocally swap all windows between workspaces (slides cleanly if empty) |

### Screenshot & Media Capture
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Print` | Fullscreen Capture | Takes fullscreen screenshot directly to clipboard |
| `Super + Shift + S` | Area Annotation | Crop region and open in Swappy for redlining/notes |
| `Super + Print` | Area to File | Crop region and save directly to `~/Pictures/Screenshots/` |

### System, Audio & Session
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Super + N` | Calendar & Notification Center | Toggles animated cyber calendar and notification dropdown |
| `Click Middle Island` | Calendar & Notification Center | Toggles animated calendar and notifications directly under top bar |
| `Super + X` | Session Overlay | Opens `wlogout` (Lock, Logout, Reboot, Shutdown) |
| `Super + Shift + L` | Lock Screen | Immediately locks workstation via `hyprlock` |
| `Super + Shift + M` | Exit Hyprland | Exits compositor back to display manager |
| `XF86AudioRaiseVolume` | Volume Up | Increases audio volume by 5% |
| `XF86AudioLowerVolume` | Volume Down | Decreases audio volume by 5% |
| `XF86AudioMute` | Toggle Mute | Mutes / unmutes default audio output |
| `XF86MonBrightnessUp` | Brightness Up | Increases display backlight by 5% |
| `XF86MonBrightnessDown` | Brightness Down | Decreases display backlight by 5% |

### Mouse Bindings
| Shortcut | Action |
| :--- | :--- |
| `Super + Left Click Drag` | Move active window |
| `Super + Right Click Drag` | Resize active window |

---

## Deployment & Testing

For complete architectural details and hardware benchmarks, see [TRACKING.md](TRACKING.md).  
For the systematic phase-by-phase test matrix and bug tracker, see [TESTING.md](TESTING.md).

```bash
# Automated deployment of all components:
./install.sh

# Or test phase-by-phase:
./install.sh --phase 2   # Deploy only Core Hyprland
./install.sh --phase 3   # Deploy Shell, Terminal & File Management
./install.sh --phase 4   # Deploy Waybar Upper & Lower Bars
./install.sh --phase 5   # Deploy Rofi, Cyber Menu & Wlogout
./install.sh --phase 6   # Deploy SwayNC, Dunst & Screenshots
./install.sh --phase 7   # Deploy Video Wallpaper Daemons
```
