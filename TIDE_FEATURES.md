# Tide Island - Comprehensive Feature Breakdown & Hyprdark Integration Catalog

This document provides an exhaustive, component-by-component analysis of all features, animation behaviors, backend services, and UI layers discovered in the **Tide-island** architecture. It serves as the master blueprint for porting and integrating these capabilities natively into the **Hyprdark** desktop environment.

---

## 1. Core Architecture & Performance Mechanics

### Why Tide Island Achieves Fluid Animations & Execution Speed
| Capability | Tide Island Implementation | Hyprdark Next-Gen Goal |
| :--- | :--- | :--- |
| **Rendering Engine** | **QtQuick / QML Scene Graph**: 120Hz/144Hz GPU-accelerated rendering with sub-millisecond frame times. | Replace slow Python GTK / multi-process overhead with a hardware-accelerated declarative shell. |
| **Dynamic Input Masking** | **Wayland Layer-Shell `mask: Region`**: Dynamically calculates pixel bounds of visible capsules so clicks pass through transparent areas directly to desktop windows. | No full-screen invisible blocking overlays; transparent regions pass clicks straight to Hyprland clients. |
| **Animation Physics** | **Spring Physics & Morph Transitions**: Declarative `NumberAnimation` and `Behavior on width/height/x/y` with easing curves (`InOutQuad`, `OutCubic`, `OutBack`). | Buttery morphing between collapsed capsule, long notification pills, split bubbles, and full control cards. |
| **IPC Communication** | **Native Unix Socket IPC**: Instant sub-millisecond IPC (`quickshell ipc call <target> <action>`) without shell spawning overhead. | Instant keybinding and gesture trigger execution. |

---

## 2. Exhaustive Feature Matrix

### A. Dynamic Island States & Morphing Behaviors
1. **Resting Capsule (Normal State)**:
   - Floating pill at the top of the monitor.
   - Displays compact Time / Status indicators.
   - Click to expand or swipe to cycle pages.
2. **Long Capsule Mode**:
   - Temporarily expands horizontally on workspace switch or system alerts.
   - Smoothly slides text in/out depending on navigation direction (left vs right).
3. **Split Bubble / Detached Island Mode**:
   - Splits the capsule into a primary island and detached secondary bubbles (e.g. detached File Shelf or OSD icon).
4. **Auto-Hide & Gesture Reveal**:
   - Automatically hides when fullscreen windows are active or upon idle timeout.
   - Edge gesture detection at the very top of the screen instantly reveals the island.

---

### B. Music & Audio Suite
1. **MPRIS Media Controller**:
   - Connects to any active MPRIS player (Spotify, Brave, MPV, VLC, Apple Music, etc.).
   - Displays album art (with smooth thumbnail caching), track title, artist name, and duration.
   - Interactive progress bar with timeline scrubbing and playback controls (Play/Pause, Previous, Next).
2. **Real-time Synchronized Lyrics Displayer**:
   - Connects to `lyricsmpris` / local LRC files / NetEase API.
   - Displays current synced lyrics line in the resting capsule or expanded overlay with real-time scrolling.
3. **Cava Audio Spectrum Visualizer**:
   - Reads FIFO from `cava` audio daemon.
   - Renders animated audio equalizer bars directly inside the island during media playback.

---

### C. Productivity & Timing Suite
1. **Interactive Dynamic Timer**:
   - Scrollable hour and minute duration picker.
   - Live circular/ring countdown timer in the capsule.
   - Notification alarm with audio chime upon timer completion.
2. **Stopwatch Mode**:
   - Millisecond-precision stopwatch display with Lap recording.
3. **File Shelf (Drag-and-Drop Staging Area)**:
   - Dragging a file from Thunar/Yazi/browser to the top of the screen auto-expands the shelf bubble.
   - Dropped files remain pinned on the shelf across workspace switches.
   - Drag files off the shelf into Discord, Slack, terminal, or other workspaces.

---

### D. System Feedback & OSD (On-Screen Display)
1. **Volume HUD**:
   - Instant pill pop-out on `XF86AudioRaiseVolume` / `LowerVolume`.
   - Displays volume percentage, mute state icon, and animated progress bar.
2. **Brightness HUD**:
   - Instant pill pop-out on `XF86MonBrightnessUp` / `Down`.
   - Smooth brightness level tracking via `brightnessctl`.
3. **Battery & Power Alerts**:
   - Charging/discharging status feedback with percentage indicators.
4. **Workspace Navigation HUD**:
   - Morphing pill indicator confirming active workspace switches with directional slide animations.

---

### E. Control Center & Connectivity
1. **Wi-Fi Connectivity Panel**:
   - Live SSID network scanner via NetworkManager / `nmcli` / DBus.
   - Interactive modal for password prompt and network connection.
   - Signal strength indicator and instant disconnect action.
2. **Bluetooth Connectivity Panel**:
   - BlueZ DBus pairing agent for automatic device discovery and pairing.
   - Individual device volume tracking and connection toggle.
3. **Display & Night Light**:
   - Night light toggle and warm color temperature slider using `hyprsunset` / `gammastep`.
4. **Hardware Sliders**:
   - Custom smooth slider cards for Audio Sink volume and Monitor backlight.

---

### F. Notification Center & Popups
1. **Native DBus Notification Daemon**:
   - Implements `org.freedesktop.Notifications` specification directly.
   - Replaces external daemons like SwayNC or Dunst without conflicts.
2. **Pill Notification Banner**:
   - Incoming notifications morph the island into an alert capsule displaying the application icon and summary.
   - Clicking the pill expands it to display the full notification body and action buttons.
3. **Notification History Drawer**:
   - Scrollable history log of all received notifications.
   - Individual dismiss button (`✕`) and single-click "Clear All" action.

---

### G. Workspace Overview & Window Management
1. **Live Workspace Overview**:
   - Full-screen or windowed overview showing thumbnails of active workspaces and open windows.
   - Click to focus windows or drag windows between workspaces.
2. **Application Launcher**:
   - Built-in fuzzy application finder parsing `.desktop` files.
   - Keyboard-driven quick launch.
3. **Wallpaper Picker**:
   - Visual grid of wallpapers in the `Background/` folder with cached image previews.
   - Single-click instantaneous wallpaper application.

---

### H. Cybersecurity & Pentest Telemetry (Hyprdark Signature Integration)
1. **Target IP Capsule**:
   - Live target IP telemetry badge.
   - Left-click copies IP to clipboard (`wl-copy`).
   - Dynamic Apple Dark frosted illumination when target is active.
2. **VPN Status Capsule**:
   - Monitors `tun0`, `wg0`, `proton0`, and OpenVPN interfaces.
   - Left-click copies VPN IP to clipboard.
   - Soft green/frosted indicator when secured.
3. **Cyber Menu / Rofi Drawer**:
   - Quick launch for Burp Suite, Wireshark, Metasploit, Nmap scanners, and reverse shell generators.

---

## 3. High-Performance Implementation Roadmap for Hyprdark

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       HYPRDARK UNIFIED SHELL ARCHITECTURE                   │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                         Hyprland Compositor                         │   │
│   └──────────────────────────────────┬──────────────────────────────────┘   │
│                                      │ Wayland Layer-Shell + IPC Socket     │
│   ┌──────────────────────────────────▼──────────────────────────────────┐   │
│   │                    Hyprdark High-Performance Shell                  │   │
│   │                                                                     │   │
│   │   ┌────────────────────────┐  ┌─────────────────────────────────┐   │   │
│   │   │   Left Island Capsule  │  │      Middle Dynamic Island      │   │   │
│   │   │  • Logo / Workspaces   │  │  • Clock & Swipe Preview        │   │   │
│   │   │  • Target IP Telemetry │  │  • MPRIS Player & Lyrics        │   │   │
│   │   │  • VPN Status          │  │  • Dynamic Timer / Stopwatch    │   │   │
│   │   └────────────────────────┘  │  • Morphing OSDs (Vol/Bright)   │   │   │
│   │                               │  • Pill Notifications           │   │   │
│   │   ┌────────────────────────┐  └─────────────────────────────────┘   │   │
│   │   │  Right Control Capsule │                                        │   │
│   │   │  • Hardware Metrics    │                                        │   │
│   │   │  • Control Center Drop │                                        │   │
│   │   │  • Notification Center │                                        │   │
│   │   └────────────────────────┘                                        │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```
