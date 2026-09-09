# Hyprdark - Agent Guidelines & Coding Criteria

This document establishes the mandatory architectural rules, visual standards, keybinding conventions, and testing protocols for any AI agent pair programming on the **Hyprdark** desktop environment.

---

## 1. Project Identity & Purpose
Hyprdark is an ultra-refined, distraction-free, professional Arch Linux desktop environment powered by Hyprland and Quickshell Qt6/QML. It is specifically tailored for daily productivity and cybersecurity/penetration testing workflows.

---

## 2. Strict Code Quality & Modular Architecture Rules (Mandatory)
- **Hard Limit: Max 150 Lines per File**: No code file (QML, shell, Python, or config) may exceed 150 lines. Large components must be decomposed into focused sub-components.
- **Single Responsibility Principle (SRP)**: Each file has one explicit role. Top-level containers (e.g. `LeftIsland.qml`, `CenterIsland.qml`, `RightIsland.qml`) only orchestrate sub-components.
- **Design System Encapsulation**: Zero hardcoded hex colors or arbitrary pixel values in feature modules. All styles, radii, and timings must consume `StyleTokens.qml`.
- **See Full Specification**: [`CODE_STANDARDS.md`](CODE_STANDARDS.md).

---

## 3. Strict UI/UX Design System (Zero-Tolerance Rules)

### A. Color Palette: Pure Apple Dark Frosted Glass
- **STRICTLY PROHIBITED**: NEVER use saturated neon colors, rainbow palettes, cyber cyan/blue glowing spans, or loud multi-color gradients.
- **Allowed Aesthetic**: Minimalist, monochromatic Apple Dark Mode frosted glass (`systemMaterialDark`):
  - **Glass Background**: `rgba(22, 22, 26, 0.80)` to `rgba(22, 22, 26, 0.85)` with background blur.
  - **Hairline Borders**: `1px solid rgba(255, 255, 255, 0.12)`.
  - **Typography Hierarchy**:
    - Primary / Active: Crisp solid white (`#ffffff`).
    - Secondary / Inactive / Metadata: Translucent white (`rgba(255, 255, 255, 0.45)`).
    - Subtle Hairline Dividers: `rgba(255, 255, 255, 0.08)`.
  - **Corner Radii**: Smooth squircles (`14px` - `18px` for windows/cards, `999px` capsule pills for buttons and bar islands).
  - **Hover Illumination**: Soft, subtle white illumination (`rgba(255, 255, 255, 0.12)`).

### B. Three Floating Capsule Islands
- The status bar consists of **three floating capsule islands**:
  1. **Left Island**: Arch logo launcher, Workspace numbers (1-5 / 1-10), Target IP telemetry, VPN status telemetry.
     - **RULE**: NEVER include active window titles or current working directory (`pwd`) text in the left island.
  2. **Middle Island**: Monochromatic Date & Clock capsule (`󰸗  %a %b %d     %H:%M:%S`). Clicking morphs in-place into the Apple dual-pane calendar & notification card.
  3. **Right Island**: Hardware metrics (CPU, RAM, Battery, Audio, Control Center trigger, Power).
- **Seamless Item Integration**:
  - NO nested rectangular pill boxes or visible bounding box shadows inside islands.
  - Buttons inside islands must use `background: transparent; box-shadow: none;` at rest.

### C. Popups & Dropdowns
- **In-Place Morphing Center Island**:
  - Center Island expands smoothly in-place from capsule into a single `600x330px` dual-pane card (Left: Apple calendar, Right: Notification Deck).
  - Never squashes or resizes desktop tiled windows (`exclusiveZone: 48`).
- **Dedicated Right-Side Drawers**:
  - Clicking Volume opens dedicated `AudioDrawer.qml`.
  - Clicking Control Center icon opens `ControlCenterDrawer.qml`.

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
- Active window border: `col.active_border = rgba(ffffffee)` or `rgb(ffffff)`.
- Inactive window border: `col.inactive_border = rgba(255, 255, 255, 0.12)`.

### B. Workspace Navigation
- `CTRL + ALT + Left/Right`: Switch relative workspace (`ws - 1` / `ws + 1`).
- `CTRL + ALT + SHIFT + Left/Right`: Move window to relative workspace.
- `CTRL + SUPER + Left/Right`: Swap workspaces cleanly without mixing layout.

### C. In-Place Window Swapping
- `SUPER + SHIFT + arrows` / `H/J/K/L`: Swap window positions in-place.

---

## 6. Verification & Testing Standards (No Assumptions)
- **Visual Proof**: Capture live screenshots using `grim` and inspect them with `view_file`.
- **Line Count Audits**: Verify all files satisfy the <150 lines rule before committing.

---

## 7. Git & Commit Protocol
- **SSH Key Signing**: All git commits MUST be signed with the user's SSH key:
  - User: `Bimo754 <mohamad.chahed@hotmail.com>`
  - Signing Key: `~/.ssh/id_mykey.pub`
  - GPG Sign: `git config commit.gpgsign true`
- **Pushing**: Push all verified commits to `origin main`.
