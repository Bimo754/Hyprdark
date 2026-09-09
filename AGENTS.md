# Hyprdark - Agent Guidelines & Coding Criteria

This document establishes the mandatory architectural rules, visual standards, keybinding conventions, and testing protocols for any AI agent pair programming on the **Hyprdark** desktop environment.

---

## 1. Project Identity & Purpose
Hyprdark is an ultra-refined, distraction-free, professional Arch Linux desktop environment powered by Hyprland and Waybar. It is specifically tailored for daily productivity and cybersecurity/penetration testing workflows.

---

## 2. Strict UI/UX Design System (Zero-Tolerance Rules)

### A. Color Palette: Pure Apple Dark Frosted Glass
- **STRICTLY PROHIBITED**: NEVER use saturated neon colors, rainbow palettes, cyber cyan/blue glowing spans, or loud multi-color gradients.
- **Allowed Aesthetic**: Minimalist, monochromatic Apple Dark Mode frosted glass (`systemMaterialDark`):
  - **Glass Background**: `rgba(22, 22, 26, 0.80)` to `rgba(22, 22, 26, 0.85)` with background blur.
  - **Hairline Borders**: `1px solid rgba(255, 255, 255, 0.12)`.
  - **Typography Hierarchy**:
    - Primary / Active: Crisp solid white (`#ffffff`).
    - Secondary / Inactive / Metadata: Translucent white (`rgba(255, 255, 255, 0.45)`).
    - Subtle Hairline Dividers: `rgba(255, 255, 255, 0.08)`.
  - **Corner Radii**: Smooth squircles (`12px` - `18px` for windows/cards, `999px` capsule pills for buttons and bar islands).
  - **Hover Illumination**: Soft, subtle white illumination (`rgba(255, 255, 255, 0.12)`).

### B. Island Architecture (Waybar)
- The status bar consists of **three floating capsule islands**:
  1. **Left Island**: Arch logo launcher, Workspace numbers (1-5 / 1-10), Target IP telemetry, VPN status telemetry.
     - **RULE**: NEVER include active window titles or current working directory (`pwd`) text in the left island.
  2. **Middle Island**: Monochromatic Date & Clock capsule (`󰸗  %a %b %d     %H:%M:%S`). Clicking toggles the unified calendar & notification dropdown.
  3. **Right Island**: Hardware metrics (CPU, RAM, Battery, Audio, Control Center trigger, Power).
- **Seamless Item Integration**:
  - NO nested rectangular pill boxes or visible bounding box shadows inside islands.
  - Buttons inside islands must use `background: transparent; box-shadow: none;` at rest.

### C. Popups & Dropdowns (Calendar & Notifications)
- **Single Unified Compact Window**:
  - Popups must be a **single card**, NOT multiple stacked windows.
  - Height MUST be compact (max height ~420px) to prevent screen overflow. Must comfortably stay in the upper half of the display.
- **Strict Separation of Concerns**:
  - The calendar & notification center drawer must contain ONLY:
    1. The interactive calendar (month/year navigation, day grid, today lens).
    2. The compact notification list with individual dismiss (`✕`) and "Clear" actions.
  - **RULE**: NEVER place Wi-Fi, Bluetooth, volume, backlight sliders, or quick setting grids inside the notification drawer.

---

## 3. Telemetry & Security Modules (Target & VPN)

### A. Target IP Telemetry (`custom/target`)
- **Setter**: MUST ONLY be set via terminal script / CLI (`scripts/set-target.sh <IP>`). NEVER provide a right-click prompt/menu on the Waybar module.
- **Click Action**: Left-click copies the Target IP to the clipboard (`wl-copy`).
- **Dynamic Lighting**:
  - **Set**: Illuminates with blue hover (`rgba(10, 132, 255, 0.22)`).
  - **Unset**: Stays completely transparent / unlit on hover.

### B. VPN Status Telemetry (`custom/vpn`)
- **Click Action**: Left-click copies the VPN IP to the clipboard (`wl-copy`).
- **Dynamic Lighting**:
  - **Connected**: Illuminates with green hover (`rgba(48, 209, 88, 0.22)`).
  - **Disconnected**: Stays completely transparent / unlit on hover.

---

## 4. Window Management & Keybindings

### A. Focused Window Indication
- The currently focused window must ALWAYS have a distinct, crisp border highlight (`col.active_border = rgba(ffffffee)` or `rgb(ffffff)`) to immediately differentiate it from inactive windows (`col.inactive_border = rgba(255, 255, 255, 0.12)`).

### B. Workspace Navigation
- **Relative Workspace Stepping**:
  - `CTRL + ALT + Left`: Switch to previous workspace relative to current active (`ws - 1`, clamped at 1).
  - `CTRL + ALT + Right`: Switch to next workspace relative to current active (`ws + 1`, clamped at 10).
  - `CTRL + ALT + SHIFT + Left/Right`: Move focused window to relative previous/next workspace.
- **Whole Workspace Swapping / Sliding**:
  - `CTRL + SUPER + Left/Right`: Clean reciprocal swap of all windows between the active workspace and the adjacent workspace. If adjacent workspace is empty, smoothly slides all windows into the destination without mixing or distorting the tiling layout.

### C. In-Place Window Swapping
- Windows must be swappable in-place using `swapwindow` (`SUPER + SHIFT + arrows` / `H/J/K/L`).

### D. Documentation Mandate
- Whenever shortcuts are added or modified, **`README.md` must be updated immediately**.

---

## 5. Daemons & Background Services Architecture
- **Unified Calendar & Notification Daemon**: `scripts/calendar-service.py` is the primary resident daemon. It implements DBus `org.freedesktop.Notifications`.
- **Daemon Conflicts**: Do NOT run `swaync` or `dunst` simultaneously in `autostart.conf` or `hyprland.lua`, as they contest ownership of the DBus notification name.
- **Toggle Script**: Use `scripts/toggle-center-dropdown.sh` (`pkill -USR1 -f calendar-service.py`) for the toggle action.

---

## 6. Verification & Testing Standards (No Assumptions)
- **Visual Proof**: Never assume an animation or UI change works based on code edits alone. Always capture live screenshots using `grim` and inspect them with `view_file`.
- **Inspection Checklist**:
  1. Absence of unwanted shadows or borders.
  2. Centering and alignment of icons and pills.
  3. No saturated colors or accidental gradients.
  4. Correct height and no overflow off the bottom edge of the display.
- **Documentation**: Keep `TESTING.md` and `bugs.md` up to date with test cases and bug resolutions.

---

## 7. Git & Commit Protocol
- **SSH Key Signing**: All git commits MUST be signed with the user's SSH key:
  - User: `Bimo754 <mohamad.chahed@hotmail.com>`
  - Signing Key: `~/.ssh/id_mykey.pub`
  - GPG Sign: `git config commit.gpgsign true`
- **Pushing**: Push all verified commits to `origin main` to protect the user's work.
