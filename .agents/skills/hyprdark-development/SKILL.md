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
| **Status Bar** | `config/waybar/config.jsonc`<br>`config/waybar/modules.css`<br>`config/waybar/base.css` | Tri-island floating Waybar status bar. |
| **Calendar & Notifications** | `scripts/calendar-service.py`<br>`scripts/toggle-center-dropdown.sh` | Single unified GTK3 Layer-Shell card and DBus notification daemon. |
| **Telemetry Scripts** | `scripts/set-target.sh`<br>`scripts/wallpaper-daemon.sh`<br>`scripts/dock-daemon.sh` | CLI-driven telemetry and daemon controllers. |

---

## 2. UI/UX Styling & Implementation Rules

### Rule 1: Monochromatic Frosted Glass Only
- **Zero Saturated Colors**: Do NOT use neon cyan (`#00f0ff`), bright blue (`#7aa2f7`), purple, or rainbow markup in status modules, popups, or cards.
- **Glass Formula**:
  ```css
  background-color: rgba(22, 22, 26, 0.82);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 16px;
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.55);
  ```
- **Text Palette**:
  - Active/Heading: `#ffffff`
  - Body/Muted: `rgba(255, 255, 255, 0.45)`
  - Hairline Dividers: `rgba(255, 255, 255, 0.08)`

### Rule 2: Seamless Island Rendering in Waybar
- Buttons and items inside Waybar capsule islands must NEVER have visible bounding-box rectangular backgrounds or shadows at rest:
  ```css
  #workspaces button, #clock, #custom-target, #custom-vpn {
      background: transparent;
      background-image: none;
      border: none;
      box-shadow: none;
  }
  ```
- Active Workspace: Render as a solid white pill or circular frosted lens (`background: #ffffff; color: #16161a;`).
- Hover States: Soft translucent white pill (`background: rgba(255, 255, 255, 0.12); color: #ffffff;`).

### Rule 3: Single Compact Card for Popups
- Never split calendar and notifications into multiple tall windows.
- Always use a **single GTK3 Layer-Shell window** (`width: 340px`, max height `~420px`).
- Never include quick settings (Wi-Fi, Bluetooth, volume sliders) in the notification drawer.
- Dynamically clamp notification scroll height (`set_min_content_height(min(160, 10 + count * 52))`).

---

## 3. Keybindings & Navigation Playbook

### Step 1: Dual-Synchronize Lua & Conf
When adding or modifying shortcuts, implement them in BOTH files:
1. **`config/hypr/hyprland.lua`** (Native Lua dispatch):
   ```lua
   hl.bind("CTRL + ALT + left", function()
       local ws = hl.get_active_workspace()
       if ws and ws.id and ws.id > 1 then
           hl.dispatch(hl.dsp.focus({ workspace = ws.id - 1 }))
       end
   end)
   ```
2. **`config/hypr/keybinds.conf`** (Standard Hyprland conf fallback):
   ```conf
   bind = CTRL ALT, left, workspace, -1
   ```

### Step 2: Whole Workspace Swapping (`CTRL + SUPER + Arrows`)
- Use reciprocal swapping:
  ```lua
  local curr_wins = curr_ws:get_windows()
  local target_wins = target_ws and target_ws:get_windows() or {}
  for _, win in ipairs(curr_wins) do
      hl.dispatch(hl.dsp.window.move({ window = win, workspace = target_id }))
  end
  for _, win in ipairs(target_wins) do
      hl.dispatch(hl.dsp.window.move({ window = win, workspace = curr_id }))
  end
  hl.dispatch(hl.dsp.focus({ workspace = target_id }))
  ```

### Step 3: Focused Window Border Highlight
- Set active border to a crisp, unmistakable highlight:
  ```conf
  col.active_border = rgba(ffffffee)
  col.inactive_border = rgba(255, 255, 255, 0.12)
  ```

### Step 4: Update Documentation
- **Mandatory**: Document the shortcut immediately in `README.md` under the Keybindings table.

---

## 4. Verification & Testing Playbook

### Never Assume — Always Verify Visually
1. **Trigger the Change**:
   ```bash
   # Example: reload Waybar
   ~/.config/waybar/launch.sh
   # Example: toggle calendar dropdown
   ~/.config/hypr/scripts/toggle-center-dropdown.sh
   ```
2. **Capture Live Screenshot**:
   ```bash
   grim <artifact_path>/verification.png
   ```
3. **Inspect with `view_file`**:
   - Check alignment, font crispness, absence of rectangular box shadows, and proper spacing.
4. **Test DBus Notifications**:
   ```bash
   notify-send "Test Title" "Test Notification Body"
   ```
5. **Update Tracking**:
   - Update `TESTING.md` with new test cases and resolution details.
   - Check off resolved items in `bugs.md`.

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
   git add config/ scripts/ TESTING.md README.md
   git commit -m "feat(scope): concise description of changes"
   ```
3. **Push to Remote**:
   ```bash
   git push origin main
   ```
