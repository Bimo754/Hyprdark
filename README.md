# Hyprdark

An ultra-refined, distraction-free, professional Arch Linux desktop environment powered by Hyprland and Quickshell. It is specifically tailored for daily productivity and cybersecurity/penetration testing workflows.

---

## Key Architectural Highlights
- **Apple Dark Frosted Glass Aesthetic:** Monochromatic `rgba(22, 22, 26, 0.82)` frosted glass with subtle blur, 1px hairline borders (`rgba(255, 255, 255, 0.12)`), solid white typography hierarchy, and zero neon/rainbow clutter.
- **Strict Single Responsibility Principle (<150 Lines/File):** Every UI and telemetry component is decomposed into micro-components strictly under 150 lines following `CODE_STANDARDS.md`.
- **Three Floating Capsule Islands:**
  1. **Left Island:** Arch logo launcher, Workspaces 1-5 with active pill lens, 1-click Target IP telemetry (`wl-copy`), and 1-click VPN status telemetry.
  2. **Center Dynamic Island:** Monochromatic Date & Clock capsule morphing smoothly in-place into an Apple dual-pane Calendar and Notification Deck with built-in DBus server.
  3. **Right Island:** CPU %, RAM (GB), Volume level, Battery %, Control Center trigger, and Power menu trigger.
- **Dedicated Drawers & Popups:**
  - **Audio Drawer:** Dedicated popup for volume control, mute toggle, and active audio sink.
  - **Control Center Drawer:** Quick toggles for Wi-Fi, Bluetooth, Night Light, Cyber Menu, volume, and backlight sliders.
  - **Zero App Resizing:** Uses fixed 48px exclusive zone and layer-shell region masking so popups never squash or resize client windows.

---

## Keyboard Shortcuts Reference

Shortcuts use the `Super` key (`$mainMod`), with dedicated modifier combos (`Ctrl + Alt`, `Ctrl + Super`) for relative workspace navigation and window management.

### Desktop Shell & Popups
| Shortcut / Action | Feature | Description |
| :--- | :--- | :--- |
| `Super + N` / `Click Center Island` | Dynamic Island Dual-Pane | Toggles in-place morphing Calendar & Notification Center |
| `Super + S` / `Click CC Trigger` | Control Center Drawer | Toggles system quick toggles (Wi-Fi, BT, Night Light, Sliders) |
| `Click Volume Metric` | Audio Drawer | Dedicated Sound Output popup drawer |
| `Super + C` | Cyber Menu | Launches interactive cyber reconnaissance & tool launcher |
| `set-target <IP>` | Terminal Target Setter | Sets target IP (`~/.local/share/hyprdark/target_ip`) with 1-click copy |
| `Left Click Target Badge` | Copy Target IP | Copies active target IP to system clipboard (`wl-copy`) |
| `Left Click VPN Badge` | Copy VPN IP | Copies active VPN IP (`tun0`/`wg0`) to system clipboard |

### Window & Workspace Management
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Super + Q` | Close Window | Closes currently focused window |
| `Super + V` | Toggle Floating | Toggles window floating state |
| `Super + F` | Toggle Fullscreen | Toggles fullscreen mode |
| `Super + 1 .. 5` | Switch Workspace | Jump to workspace 1 through 5 |
| `Ctrl + Alt + Left / Right` | Relative Workspace Switch | Switch to previous (`ws - 1`) or next (`ws + 1`) workspace |
| `Ctrl + Alt + Shift + Left / Right` | Move Window Relative | Move focused window to previous or next workspace |
| `Ctrl + Super + Left / Right` | Swap Workspaces / Slide | Reciprocally swap all windows between workspaces or slide cleanly |

---

## Verification & Testing
Run automated line count audit:
```bash
find config/quickshell -name "*.qml" -exec wc -l {} + | sort -n
```
All files strictly satisfy the `< 150 lines` requirement.
