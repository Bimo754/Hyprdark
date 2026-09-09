---
name: hyprdark-development
description: >-
  Expert workflows, UI/UX criteria, keybindings standards, and verification
  procedures for developing, customizing, and maintaining the Hyprdark desktop environment.
---

# Hyprdark Development Skill

This skill provides step-by-step procedures, coding patterns, and architectural rules for developing and maintaining the Hyprdark desktop environment.

---

## 1. Quick Architecture Reference

| Component | Primary Files | Role |
| :--- | :--- | :--- |
| **Hyprland Core** | `config/hypr/hyprland.conf`<br>`config/hypr/hyprland.lua` | Compositor configuration, Lua event loop, window dispatchers. |
| **Keybindings** | `config/hypr/keybinds.conf`<br>`config/hypr/hyprland.lua` | Dual-synchronized keybindings. **Always update both!** |
| **Top-Left Island (Quickshell)** | `config/quickshell/bar/LeftIsland.qml`<br>`config/quickshell/bar/BarWindow.qml`<br>`config/quickshell/StyleTokens.qml` | Monochromatic frosted glass top-left capsule status bar. |
| **Island Modules** | `config/quickshell/modules/left/` | Arch launcher, Workspaces 1-5, Target IP telemetry, VPN telemetry. |
| **Telemetry Scripts** | `scripts/set-target.sh`<br>`scripts/quickshell-launcher.sh` | CLI-driven telemetry and Quickshell supervisor. |

---

## 2. UI/UX Styling & Implementation Rules

### Rule 1: Monochromatic Frosted Glass Only
- **Zero Saturated Colors**: Do NOT use neon cyan (`#00f0ff`), bright blue (`#7aa2f7`), purple, or rainbow markup in status modules.
- **Glass Formula**:
  ```css
  background-color: rgba(22, 22, 26, 0.82);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 999px;
  ```
- **Text Palette**:
  - Active/Heading: `#ffffff`
  - Body/Muted: `rgba(255, 255, 255, 0.45)`
  - Hairline Dividers: `rgba(255, 255, 255, 0.08)`

### Rule 2: Seamless Island Rendering in Quickshell
- Buttons and items inside the capsule island must NEVER have visible bounding-box rectangular backgrounds or shadows at rest:
  - Active Workspace: Solid white pill (`background: #ffffff; color: #16161a;`).
  - Hover States: Soft translucent white pill (`background: rgba(255, 255, 255, 0.12); color: #ffffff;`).
  - Transparent at rest: `background: transparent;`.

### Rule 3: Fixed Exclusivity & Layer Masking
- Always use **`exclusiveZone: 52`** on `BarWindow.qml` to prevent client windows from overlapping the bar.
- Use **`Region` masking** so only the top-left capsule area intercepts clicks; the rest allows click-through.

---

## 3. Keybindings & Navigation Playbook

### Step 1: Dual-Synchronize Lua & Conf
When adding or modifying shortcuts, implement them in BOTH files:
1. **`config/hypr/keybinds.conf`**:
   ```conf
   bind = CTRL ALT, left, workspace, m-1
   bind = CTRL ALT, right, workspace, m+1
   ```
2. **`config/hypr/hyprland.lua`**:
   ```lua
   hl.bind("CTRL + ALT + left", function()
       local ws = hl.get_active_workspace()
       if ws and ws.id and ws.id > 1 then
           hl.dispatch(hl.dsp.focus({ workspace = ws.id - 1 }))
       end
   end)
   ```

### Step 2: Focused Window Border Highlight
- Set active border to a crisp, unmistakable highlight:
  ```conf
  col.active_border = rgba(ffffffee)
  col.inactive_border = rgba(255, 255, 255, 0.12)
  ```

### Step 3: Update Documentation
- **Mandatory**: Document the shortcut immediately in `README.md` under the Keybindings table.

---

## 4. Verification & Testing Playbook

### Never Assume — Always Verify Visually
1. **Trigger the Change**:
   ```bash
   # Reload Hyprland config
   hyprctl reload
   # Relaunch Quickshell Top-Left Island
   ~/.config/hypr/scripts/quickshell-launcher.sh
   ```
2. **Line Count Audit**:
   ```bash
   find config/quickshell -name "*.qml" -exec wc -l {} + | sort -n
   ```
3. **Capture Live Screenshot**:
   ```bash
   grim <artifact_path>/verification.png
   ```

---

## 5. Git Commit & Release Protocol

1. **Verify SSH Signing Configuration**:
   ```bash
   git config user.name "Bimo754"
   git config user.email "mohamad.chahed@hotmail.com"
   git config user.signingkey "~/.ssh/id_mykey.pub"
   git config commit.gpgsign true
   ```
2. **Stage and Commit**:
   ```bash
   git add config/ scripts/ README.md
   git commit -m "feat(scope): concise description of changes"
   ```
3. **Push to Remote**:
   ```bash
   git push origin main
   ```

