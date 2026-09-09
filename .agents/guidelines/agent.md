# Hyprdark - Agent Guidelines & Coding Criteria

This document establishes the mandatory architectural rules, visual standards, keybinding conventions, and testing protocols for any AI agent pair programming on the **Hyprdark** desktop environment.

---

## 1. Project Identity & Purpose
Hyprdark is an ultra-refined, distraction-free, professional Arch Linux desktop environment powered by Hyprland and Quickshell Qt6/QML. It is specifically tailored for daily productivity and cybersecurity/penetration testing workflows.

---

## 2. Strict Code Quality & Modular Architecture Rules (Mandatory)
- **Hard Limit: Max 150 Lines per File**: No code file (QML, shell, Python, or config) may exceed 150 lines. Large components must be decomposed into focused sub-components.
- **Single Responsibility Principle (SRP)**: Each file has one explicit role. Top-level containers (e.g. `LeftIsland.qml`, `BarWindow.qml`) only orchestrate sub-components.
- **Design System Encapsulation**: Zero hardcoded hex colors or arbitrary pixel values in feature modules. All styles, radii, and timings must consume `StyleTokens.qml`.
- **See Full Specification**: [`CODE_STANDARDS.md`](CODE_STANDARDS.md).

---

## 3. Strict UI/UX Design System (Zero-Tolerance Rules)

### A. Color Palette: Pure Apple Dark Frosted Glass
- **STRICTLY PROHIBITED**: NEVER use saturated neon colors, rainbow palettes, cyber cyan/blue glowing spans, or loud multi-color gradients.
- **Allowed Aesthetic**: Minimalist, monochromatic Apple Dark Mode frosted glass (`systemMaterialDark`):
  - **Glass Background**: `rgba(22, 22, 26, 0.82)` with background blur.
  - **Hairline Borders**: `1px solid rgba(255, 255, 255, 0.12)`.
  - **Typography Hierarchy**:
    - Primary / Active: Crisp solid white (`#ffffff`).
    - Secondary / Inactive / Metadata: Translucent white (`rgba(255, 255, 255, 0.45)`).
    - Subtle Hairline Dividers: `rgba(255, 255, 255, 0.08)`.
  - **Corner Radii**: Smooth squircles (`14px` - `18px` for windows/cards, `999px` capsule pills for buttons and bar islands).
  - **Hover Illumination**: Soft, subtle white illumination (`rgba(255, 255, 255, 0.12)`).

### B. Top-Left Floating Capsule Island
- Built natively with **Quickshell (Qt6/QML)**:
  1. **Arch Logo Launcher (`ArchLauncher.qml`)**: 1-click launcher triggering Rofi application menu.
  2. **Workspaces 1–5 (`WorkspaceList.qml`)**: Interactive workspace switcher with solid white active pill lens and mouse wheel scroll navigation.
  3. **Target IP Telemetry (`TargetBadge.qml`)**: Displays current active engagement target IP with 1-click clipboard copy (`wl-copy`).
  4. **VPN Telemetry (`VpnBadge.qml`)**: Detects and displays active VPN IP (`tun0`/`wg0`) with 1-click clipboard copy (`wl-copy`).
- **Seamless Item Integration**:
  - Buttons and items inside the capsule must have `background: transparent; box-shadow: none;` at rest.
  - No nested rectangular bounding boxes or unwanted shadows.

### C. Layer-Shell Masking & Exclusivity
- Reserves a fixed 52px top exclusive zone so tiled windows do not overlap.
- Region masking ensures only the top-left capsule area intercepts clicks; all other screen space is transparent to click events.

---

## 4. Telemetry & Security Modules (Target & VPN)

### A. Target IP Telemetry
- **Setter**: MUST ONLY be set via terminal script / CLI (`scripts/set-target.sh <IP>`).
- **Click Action**: Left-click copies the Target IP to the clipboard (`wl-copy`).
- **Dynamic Lighting**:
  - **Set**: Illuminates with blue hover (`rgba(10, 132, 255, 0.22)`).
  - **Unset**: Stays completely transparent / unlit on hover.

### B. VPN Status Telemetry
- **Click Action**: Left-click copies the VPN IP to the clipboard (`wl-copy`).
- **Dynamic Lighting**:
  - **Connected**: Illuminates with green hover (`rgba(48, 209, 88, 0.22)`).
  - **Disconnected**: Stays completely transparent / unlit on hover.

---

## 5. Window Management & Keybindings

### A. Focused Window Indication
- Active window border: `col.active_border = rgba(ffffffee)`.
- Inactive window border: `col.inactive_border = rgba(255, 255, 255, 0.12)`.

### B. Dual-Synchronized Keybindings
When adding or modifying shortcuts, implement them in BOTH files:
1. `config/hypr/keybinds.conf`
2. `config/hypr/hyprland.lua`

### C. Core Shortcuts
- Launchers: `Super + Return` (Kitty), `Super + Space` (Rofi), `Super + E` (Thunar), `Super + B` (Brave), `Super + S` (Sublime Text).
- Window Management: `Super + Q` (Close), `Super + V` (Float), `Super + F` (Fullscreen), `Super + Arrows/HJKL` (Focus), `Super + Shift + Arrows/HJKL` (Move).
- Workspaces: `Super + 1..5` (Switch), `Super + Shift + 1..5` (Move window), `Ctrl + Alt + Left/Right` (Relative switch), `Ctrl + Alt + Shift + Left/Right` (Move relative).
- Screenshots: `Print` (Fullscreen crop to clipboard), `Super + Shift + S` (Area crop with Swappy).
- Session: `Super + Shift + L` (Hyprlock), `Super + Shift + M` (Exit).

---

## 6. Verification & Testing Standards (No Assumptions)
- **Visual Proof**: Capture live screenshots using `grim` and inspect them with `view_file`.
- **Line Count Audits**: Verify all files satisfy the <150 lines rule before committing:
  ```bash
  find config/quickshell -name "*.qml" -exec wc -l {} +
  ```
- **Live Reload Verification**:
  ```bash
  hyprctl reload
  ~/.config/hypr/scripts/quickshell-launcher.sh
  ```

---

## 7. Git & Commit Protocol
- **SSH Key Signing**: All git commits MUST be signed with the user's SSH key:
  - User: `Bimo754 <mohamad.chahed@hotmail.com>`
  - Signing Key: `~/.ssh/id_mykey.pub`
  - GPG Sign: `git config commit.gpgsign true`
- **Pushing**: Push all verified commits to `origin main`.
