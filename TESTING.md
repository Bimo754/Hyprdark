# Hyprdark: Systematic Verification, Testing & Bug Ledger

This document is the QA and testing workbook for **Hyprdark**. Use it to systematically test every component, verify expected behavior on your hardware, and log any bugs, glitches, or visual adjustments needed.

---

## 1. Testing Strategy: Full Installation vs. Phase-by-Phase

### Recommended Approach: Full Deployment with Phase-by-Phase Verification
> [!TIP]
> **Recommendation:** Run `./install.sh` once to install dependencies and link all dotfiles, but **test each component systematically phase-by-phase** following the matrix below.
> 
> **Why?** Desktop components are inherently interconnected:
> - Hyprland keybindings call `kitty`, `rofi`, `wlogout`, and `swaync`.
> - Waybar modules call custom scripts in `scripts/` and launch `rofi` menus.
> - If you deploy *only* Phase 2 without Phase 3 & 5, pressing `Super + Return` or `Super + Space` will fail because those targets haven't been linked yet.
> 
> By running `./install.sh` first, all symlinks and dependencies exist in their proper locations. You can then test each phase methodically without running into "file not found" errors caused by isolated testing.

### Alternative Approach: Incremental Phase-by-Phase Deployment
If you prefer strictly testing each subsystem in complete isolation, the installer supports incremental phase linking:

```bash
cd ~/Desktop/Github/Hyprdark

# Step 1: Run safety backup
./install.sh -p 1

# Step 2: Deploy & test only Core Hyprland
./install.sh -p 2 --no-deps
hyprctl reload

# Step 3: Deploy & test Shell, Kitty & File Managers
./install.sh -p 3 --no-deps

# Step 4: Deploy & test Waybar Upper & Lower Bars
./install.sh -p 4 --no-deps

# Step 5: Deploy & test Rofi, Cyber Menu & Wlogout
./install.sh -p 5 --no-deps

# Step 6: Deploy & test SwayNC, Dunst & Screenshots
./install.sh -p 6 --no-deps

# Step 7: Deploy & test Video Wallpaper Daemons
./install.sh -p 7 --no-deps

# Step 8: Deploy & test GRUB and SDDM Themes
./install.sh -p 8
```

---

## 2. Phase-by-Phase Test Matrix

Mark status as `[PASS]`, `[FAIL]`, or `[NEEDS_TWEAK]`. Record notes directly in the tables below.

### Phase 1: Backup & Deployment Engine
| Test ID | Component | Test Procedure | Expected Result | Status | Notes / Adjustments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T1.1** | `backup.sh` | Run `./scripts/backup.sh` | Creates `~/.local/share/hyprdark/backups/backup_YYYYMMDD_HHMMSS/` with a manifest and snapshots of existing configs. | [PASS] | Verified live during build |
| **T1.2** | `install.sh` | Run `./install.sh --dry-run` | Prints all dry-run actions cleanly without altering disk state. | [PASS] | Verified live during build |
| **T1.3** | Symlinks | Run `./install.sh` | Dotfiles in `config/*` are symlinked to `~/.config/*`. Modifying a file in the repo instantly reflects in the system. | [PENDING] | |

---

### Phase 2: Core Hyprland Compositor Engine
| Test ID | Component | Test Procedure | Expected Result | Status | Notes / Adjustments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T2.1** | Display Scaling | Log in to Hyprland | Display `eDP-1` renders at 2560x1600 with crisp 1.6 scaling (no blur, correct UI size). | [PENDING] | |
| **T2.2** | Border Gradient | Open any window | Active window border displays a 45-degree cyber crimson to stealth dark gradient. Inactive border is subtle charcoal `#282c3f`. | [PENDING] | |
| **T2.3** | Window Controls | Press `Super + Q`, `Super + V`, `Super + F` | `Super + Q` kills window; `Super + V` toggles floating; `Super + F` toggles fullscreen. | [PENDING] | |
| **T2.4** | Navigation | Press `Super + H/J/K/L` and arrows | Smoothly moves focus between tiled windows. | [PENDING] | |
| **T2.5** | Quake Scratchpad | Press `Super + \`` (Grave/Tilde) | Centered floating terminal drops down (`85% x 65%`). Pressing again smoothly toggles it away. | [PENDING] | |
| **T2.6** | Hyprlock Screen | Press `Super + Shift + L` | Locks screen with `#0d0e15` background, digital clock, date, and cyber auth prompt. Type password to unlock. | [PENDING] | |
| **T2.7** | Hypridle Daemon | Let system idle for 5 min | Screen dims at 5m, session locks at 6m, display powers off at 10m. Resumes cleanly on input. | [PENDING] | |

---

### Phase 3: Shell, Terminal & File Management
| Test ID | Component | Test Procedure | Expected Result | Status | Notes / Adjustments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T3.1** | Kitty Launch | Press `Super + Return` | Kitty launches instantly with JetBrains Mono font, 94% opacity, and void dark `#0d0e15` palette. | [PENDING] | |
| **T3.2** | Zsh Cyber Prompt | Launch terminal with Zsh | Two-line cyber prompt appears (`┌──[user@arch]─[path] [git:branch] └──╼ $`). No emojis. | [PENDING] | |
| **T3.3** | Zsh Plugins | Type command partially | `zsh-autosuggestions` provides gray completions; syntax highlighting colors commands green/red. | [PENDING] | |
| **T3.4** | Target IP Setter | Run `set-target 10.10.14.5` in shell | Prints `[OK]` and sets target in `~/.local/share/hyprdark/target_ip`. Running `target` prints and copies it. | [PENDING] | |
| **T3.5** | Cyber Aliases | Run `myip`, `ports`, `ll` | `myip` shows LAN + tun0 IP; `ports` shows active listening sockets; `ll` lists files with permissions. | [PENDING] | |
| **T3.6** | Yazi File Manager | Run `y` in Kitty | Yazi opens in terminal. Navigating over images renders preview using Kitty graphics protocol. | [PENDING] | |
| **T3.7** | Thunar GUI | Press `Super + E` | Thunar opens with pure dark GTK theme. Right-click context menu offers "Open Kitty Here" and "Compute SHA256 Checksum". | [PENDING] | |

---

### Phase 4: Upper Status Bar & Lower Dock (Waybar)
| Test ID | Component | Test Procedure | Expected Result | Status | Notes / Adjustments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T4.1** | Upper Status Bar | Observe top edge of screen | Top bar renders workspaces, active window title, system metrics (CPU, RAM, Temp), volume, battery, and clock. | [PENDING] | |
| **T4.2** | VPN Module | Connect/Disconnect OpenVPN or WireGuard | When disconnected, displays `[VPN: DISCONNECTED]` in amber. When connected, displays `[VPN: 10.10.X.X]` in green. | [PENDING] | |
| **T4.3** | Target IP Module | Set target IP via `set-target` | Displays `[TARGET: 10.10.X.X]` in cyan. Left-click copies IP to clipboard. Right-click opens Rofi target prompt. | [PENDING] | |
| **T4.4** | Lower Dock | Observe bottom edge of screen | Bottom bar renders quick-launch buttons `[TERM]`, `[QUAKE-SHELL]`, `[FILES]`, `[BROWSER]`, `[EDITOR]`, `[WALL]`. Clicking launches each tool. | [PENDING] | |
| **T4.5** | Audio & Battery | Scroll on volume module | Mouse wheel raises/lowers volume. Left click toggles mute. Battery module shows percentage and charging state. | [PENDING] | |

---

### Phase 5: Menus, Runners & Session Controls
| Test ID | Component | Test Procedure | Expected Result | Status | Notes / Adjustments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T5.1** | Rofi App Runner | Press `Super + Space` or `Super + D` | Rofi opens centered in void dark theme (`EXEC >`). Typing filters applications. Pressing Enter launches app. | [PENDING] | |
| **T5.2** | Cyber Ops Menu | Press `Super + O` | Rofi menu opens with 8 cybersecurity operations: Set Target IP, Copy Target IP, Network Status, HTTP Server, Nmap Scan, Wallpaper Switcher, Lock, Quake Terminal. | [PENDING] | |
| **T5.3** | Clipboard History | Copy text, then press `Super + C` | Rofi displays recent clipboard entries from `cliphist`. Selecting one copies it back to active clipboard. | [PENDING] | |
| **T5.4** | Session Overlay | Press `Super + X` | `wlogout` opens fullscreen dark overlay with buttons `[L] LOCK`, `[E] LOGOUT`, `[S] SHUTDOWN`, `[R] REBOOT`, `[U] SUSPEND`. Keyboard accelerators work. | [PENDING] | |

---

### Phase 6: Notifications & Screen Capture
| Test ID | Component | Test Procedure | Expected Result | Status | Notes / Adjustments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T6.1** | SwayNC Drawer | Press `Super + N` | Slide-out notification center opens from right edge with Do-Not-Disturb switch and volume slider. | [PENDING] | |
| **T6.2** | Test Notification | Run `notify-send "Test" "Sample notification"` | Dark banner appears on top-right. Respects `#0d0e15` palette and monospace font. | [PENDING] | |
| **T6.3** | Fullscreen Capture | Press `Print` | Entire screen captured and copied directly to clipboard buffer. | [PENDING] | |
| **T6.4** | Area Annotation | Press `Super + Shift + S` | Screen freezes with crosshair selection. Selected region immediately opens in Swappy for arrows/text/redlining. | [PENDING] | |

---

### Phase 7: Dynamic Video Wallpapers
| Test ID | Component | Test Procedure | Expected Result | Status | Notes / Adjustments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T7.1** | Video Looping | Launch session or run `wallpaper-daemon.sh` | Selected MP4 video wallpaper (`red-skull-glitch`) plays continuously in background with no audio and smooth rendering. | [PENDING] | |
| **T7.2** | Wallpaper Switcher | Run `./scripts/wallpaper-ctl.sh` | Interactive menu opens with the 4 video wallpapers. Selecting one (`knight-red-cloak`, `protocolo-sombra`, `windows-logo-glitch`) seamlessly transitions playback. | [PENDING] | |

---

### Phase 8: System Bootloader & Display Manager Themes
| Test ID | Component | Test Procedure | Expected Result | Status | Notes / Adjustments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T8.1** | GRUB Theme Deploy | Run `sudo ./themes/grub/install-grub-theme.sh` | Theme copied to `/boot/grub/themes/hyprdark/`, `/etc/default/grub` updated, and `grub.cfg` generated without duplicate UKI entries. | [PENDING] | |
| **T8.2** | GRUB Boot Screen | Reboot computer | GRUB menu displays in sharp 1080p void dark style with digital timeout countdown and Arch/Windows boot options. | [PENDING] | |
| **T8.3** | SDDM Theme Deploy | Run `sudo ./themes/sddm/install-sddm-theme.sh` | Theme copied to `/usr/share/sddm/themes/hyprdark/` and activated in `/etc/sddm.conf.d/hyprdark.conf`. | [PENDING] | |
| **T8.4** | SDDM Login Screen | Log out of Hyprland | SDDM renders void dark theme with clock, date, username/password fields, and Hyprland Wayland session selector. | [PENDING] | |

---

## 3. Bug, Glitch & Modification Tracker

Use this table to log any issues or visual adjustments discovered during testing. Report the **Issue ID** back to Antigravity to have it fixed and committed immediately.

| Issue ID | Phase / Component | Severity | Description / Steps to Reproduce | Desired Change / Modification | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **#BUG-01** | Phase 5: Rofi | High | Rofi failed to parse theme with `border: ... solid` and relative `@theme "theme"` | Fixed border syntax to pure integers (`2px`, `1px`) and set absolute path `@theme "~/.config/rofi/theme.rasi"`. Updated `modi` to `modes`. | **Resolved** |
| **#BUG-02** | Phase 2: Hyprland Lua | High | Lua threw errors on `dwindle.pseudotile` and `hl.bind("", "PRINT", ...)` | Removed `pseudotile` from dwindle table; corrected `hl.bind("PRINT", ...)` argument alignment. | **Resolved** |
| **#BUG-03** | Phase 7: Wallpaper Daemon | Medium | Desktop background appeared black after reload because daemon was not started and script had symlink path resolution issue | Fixed path resolution via `readlink -f` and fallback in `wallpaper-daemon.sh`. Actively playing `red-skull-glitch-moewalls-com.mp4` via `mpvpaper` on `eDP-1`. | **Resolved** |
| **#BUG-04** | Phase 4: Waybar & Autostart | Medium | Top status bar not visible after fixing initial boot config errors (`hyprland.start` only runs on cold start); height warning on bottom bar | Dispatched Waybar live via `hl.dsp.exec_cmd("waybar")`; adjusted bottom-bar height to 28px in `config.jsonc`. Both top-bar and bottom-bar verified active on `eDP-1` via `hyprctl layers`. | **Resolved** |
| **#BUG-05** | UI/UX Overhaul: Waybar & Desktop | High | Rigid rectangular bar with square brackets, artificial color palette, clock misplaced on right, missing GNOME-style Quick Settings control center, sharp 3px window corners | Overhauled upper bar into floating smooth capsule island (`border-radius: 999px`); placed Clock & Date in center island; added GNOME-style SwayNC Quick Settings pop-up (`󰖩 󰂯 󰂚`) adjacent to Power button; reorganized audio, battery, and system metrics; upgraded Hyprland window rounding to 10px with 5/10 gaps and vivid cyan-to-crimson gradient borders. | **Resolved** |
| **#BUG-06** | UI Architecture: Floating Islands & GNOME Dock | Medium | Outer shell made top bar look boxed in; cramped 11px font on HiDPI display; bottom bar was static rather than GNOME-style auto-hiding dock with pinned apps | Set outer canvas 100% transparent; styled `.modules-left`, `.modules-center`, `.modules-right` into 3 discrete floating islands; boosted height to 42px and font to 13.5px with comfortable padding; refactored CSS into modular files (`colors.css`, `base.css`, `modules.css`, `style.css`); deployed GNOME-style auto-hiding dock configuration (`nwg-dock-hyprland`) with pinned apps and bottom-edge trigger. | **Resolved** |
| **#BUG-07** | UI/UX Overhaul: Apple macOS Design System | High | Loud multi-color gradients, saturated neon colors, and non-Apple aesthetics caused eye fatigue | Eliminated all gradients completely; adopted Apple Dark Mode frosted glass (`systemMaterialDark`) with crisp off-white typography (`#f5f5f7`); styled macOS Spaces workspaces with solid white active pill; formatted Apple menu bar date/time; added iconic macOS Control Center switch icon (`󰮫`); styled SwayNC with Apple control cards; upgraded Hyprland to 12px squircle rounding with subtle monochromatic hairline borders and diffuse drop shadows. | **Resolved** |
| **#BUG-08** | Left Island Minimalism | Low | Left island included focused window title / PWD (`hyprland/window`), cluttering the minimal menu bar aesthetic | Removed `hyprland/window` from `modules-left` in `config.jsonc`, retaining strictly `custom/launcher` (Arch logo), `hyprland/workspaces`, `custom/target`, and `custom/vpn`. | **Resolved** |
| **#BUG-09** | Arch Logo Centering, Workspace Glow & Click Switching | High | Arch logo hover pill was visually off-center due to asymmetric font bearings; white workspace pill felt static with numbers spaced too far apart; clicking workspace buttons in Waybar failed to switch workspaces in Hyprland v0.56 due to Lua IPC protocol differences | Centered Arch logo hover squircle via dedicated 28x28 icon button rules; tightened workspace number spacing (`margin: 0 1px; padding: 2px 5px; min-width: 18px`); added multi-stage ambient cyan/specular glow to active workspace pill; engineered lightweight transparent IPC compatibility shim (`libwaybar_hyprfix.so`) translating legacy `dispatch workspace N` to Hyprland v0.56 Lua `dispatch hl.dsp.focus({ workspace = N })`. | **Resolved** |
| **#BUG-10** | iPhone Frosted Liquid Glass Workspaces | Medium | Solid white active workspace pill felt jarring and artificial; bare workspace numbers looked unanchored inside the left island | Designed an authentic iOS-style recessed capsule track (`background: rgba(0, 0, 0, 0.30)`) housing the workspace numbers; transformed active workspace pill into iPhone frosted liquid glass with top-down specular light gradient (`linear-gradient(180deg, rgba(255, 255, 255, 0.32), rgba(255, 255, 255, 0.18))`), hairline glass rim border (`rgba(255, 255, 255, 0.55)`), and crisp illuminated typography. | **Resolved** |
| **#BUG-11** | Fluid Workspace Switching Animations | Medium | Switching between workspaces lacked dynamic visual motion both on the status bar numbers and on the desktop compositor | Implemented dual-layer liquid switching animations: (1) Waybar status bar elastic width expansion (`18px` to `28px`) and luminous pulse keyframe (`@keyframes ws-active-glow`), and (2) Hyprland compositor `appleFluid` motion curve (`{0.16, 1.0}, {0.3, 1.0}`) with `slidefade 20%` easing for liquid desktop transitions. | **Resolved** |
| **#BUG-12** | Fixed-Lens iPhone Glass Transitions | High | Width expansion and keyframe animation caused horizontal text jumping and a harsh white flash on number switching, breaking the authentic glass sensation | Removed keyframes and dynamic width variations; locked all workspace buttons to identical 24x24px circular geometry; implemented smooth, tranquil frosted glass crossfades (`rgba(255, 255, 255, 0.20)` with `0.40` border and inner bevel) ensuring the capsule track and digits stay completely stationary while the glass lens glides between them. | **Resolved** |
| **#BUG-13** | Workspace Glass Lenses & Sliding Specular Wave | High | Workspace numbers were not true geometric circles, active glass felt flat and color-like rather than optical glass, and switching felt like disappearing and appearing rather than fluid motion | Locked buttons to true 26x26px 1:1 circular aspect ratio with `border-radius: 999px;`; upgraded active glass with authentic iPhone optical caustics using directional `radial-gradient` specular highlight, polished 0.75 glass chamfer rim, dual-refraction inner bevels (`inset 0 1.5px 1px` and `inset 0 -1.5px 2px`), and ambient caustic glow; implemented multi-stage `@keyframes glass-liquid-slide` simulating physical specular light surfing laterally across adjacent numbers into place. | **Resolved** |
| **#BUG-14** | Workspace Switch Flash / Glitch | High | High-opacity keyframe animation (`0.85` white on frame 0) and default GTK `button:active` click highlight caused a rapid white flash/strobe when activating a workspace | Removed keyframe animation; defined matched resting box-shadows (`box-shadow: inset 0 0 0 transparent, 0 0 0 transparent`); overrode GTK `button:active` click highlight; unified workspace lens transitions with smooth `0.28s cubic-bezier(0.16, 1, 0.3, 1)` easing for perfectly clean, flash-free liquid glass transitions. | **Resolved** |
| **#BUG-15** | Rectangular Shadow Behind Workspace Numbers | Medium | When switching away from workspace 1, GTK3 rendered an unrounded rectangular inset shadow (`inset 0 1px 3px`) on the `#workspaces` container and clipped active button drop-shadows into a dark rectangular halo behind the pills | Removed the dark nested background, border, and inset shadow from `#workspaces`, integrating the workspace number circles directly onto the seamless floating glass island (`.modules-left`); removed dark clipped drop-shadows in favor of diffuse ambient caustic glow (`0 0 14px rgba(255, 255, 255, 0.35)`). | **Resolved** |
| **#BUG-16** | Pure Monochromatic Workspaces & Zero Animation | High | Flashing, rectangular artifacts, and distracting colors on workspace numbers caused frustration | Stripped all animations (`transition: none; animation: none;`), removed all background pills, gradients, caustics, and borders, and unified numbers under clean, minimal monochromatic typography: active workspace in crisp bold `#ffffff`, inactive in calm muted `rgba(255, 255, 255, 0.40)` with zero outlines or shadows. | **Resolved** |
| **#BUG-17** | Cool Minimal Frosted Glass Workspace Highlight & Fluid Animation | Medium | Workspaces needed a cool, minimal highlight and smooth switching animation without bringing back rectangular artifacts, flashes, or non-circular button shapes | Replaced plain typography with refined, circular frosted glass lens highlight (`26x26px` true 1:1 geometry, `background: rgba(255, 255, 255, 0.16)`, `border: 1px solid rgba(255, 255, 255, 0.35)`, ambient glow `0 0 10px rgba(255, 255, 255, 0.14)` and specular bevel `inset 0 1px 1px rgba(255, 255, 255, 0.40)`); paired with fluid Apple micro-transition (`transition: all 0.22s cubic-bezier(0.16, 1, 0.3, 1)`) for flash-free, smooth workspace crossfading; verified across workspaces 1, 2, and 3 with zero rectangular shadow artifacts. | **Resolved** |
| **#BUG-18** | GTK Adwaita Button Shadow Artifact Between Launcher & Workspace 1 | High | A vertical shadow band/rectangle was visible between the Arch launcher icon and workspace 1, caused by GTK's default `Adwaita-dark` button stylesheet applying `background-image` and `box-shadow` to unreset buttons | Added a global button reset in `base.css` (`button, button:backdrop, button:active, button:focus, button:hover { background: transparent; background-image: none; box-shadow: none; }`); explicitly reset `#custom-launcher`; removed all residual `box-shadow` and `text-shadow` from `#workspaces button.active` for clean shadowless frosted glass styling. Verified 100% elimination of shadow line via pixel intensity inspection across workspaces 1, 2, and 3. | **Resolved** |
| **#BUG-19** | Target & VPN Telemetry Controls and Dynamic State-Aware Lighting | Medium | Target IP needed to be strictly terminal-controlled without right-click menu; hover lighting needed to illuminate in matched colors (blue for set target, green for connected VPN) and stay completely unlit when unset/disconnected; VPN IP needed to be 1-click copy-able | Removed right-click setter from `custom/target` in `config.jsonc`; implemented 1-click clipboard copying (`wl-copy`) for both Target and VPN modules; configured state-aware CSS hover styling in `modules.css`: `#custom-target.set:hover` illuminates in blue (`rgba(10, 132, 255, 0.22)`), `#custom-vpn.connected:hover` illuminates in green (`rgba(48, 209, 88, 0.22)`), and both `#custom-target.unset:hover` and `#custom-vpn.disconnected:hover` remain completely transparent without background illumination. Tested and verified live. | **Resolved** |
| **#BUG-20** | Relative Workspace Navigation via CTRL+ALT+ArrowLeft/Right | Low | Fast workspace navigation required relative previous/next switching keys (`CTRL + ALT + ArrowLeft` to lower workspace, `CTRL + ALT + ArrowRight` to higher workspace) based on currently active workspace | Implemented relative workspace stepping logic in `config/hypr/hyprland.lua` clamped between 1 and 10 (`math.max(1, ws.id - 1)` / `math.min(10, ws.id + 1)`) via `hl.get_active_workspace()`; added companion window movement shortcuts (`CTRL + ALT + SHIFT + ArrowLeft/Right`); synchronized standard configuration in `config/hypr/keybinds.conf`. Verified live via `hyprctl binds` and REPL stepping. | **Resolved** |
| **#BUG-21** | Whole Workspace Window Migration via CTRL+SUPER+ArrowLeft/Right | Medium | Moving entire workspaces with all their windows to adjacent workspaces (previous/next) required a single gesture (`CTRL + SUPER + ArrowLeft/Right`) that migrates every window simultaneously and follows to the destination | Implemented whole-workspace migration in `config/hypr/hyprland.lua` using `ws:get_windows()`, relocating each window via `hl.dispatch(hl.dsp.window.move({ window = win, workspace = target }))` and focusing the target workspace (`hl.dispatch(hl.dsp.focus({ workspace = target }))`), safely clamped between 1 and 10; synchronized companion fallback in `config/hypr/keybinds.conf`. Verified live via REPL window migration and registered keybinds (`modmask: 68`). | **Resolved** |













