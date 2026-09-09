# Hyprdark Bug Tracker & Resolutions

## Resolved Items
1. **Arch Logo Hover Pill Centering**:
   - **Status**: [RESOLVED]
   - **Fix**: Rebuilt in `config/quickshell/modules/left/ArchLauncher.qml` with explicit `anchors.centerIn: parent` on a 28x28 circular capsule hover plate. Perfectly centered.

2. **Control Center Redesign (Wi-Fi, Bluetooth, Night Light, Sliders)**:
   - **Status**: [RESOLVED]
   - **Fix**: Decomposed into `dropdowns/controlcenter/QuickToggleCard.qml`, `QuickToggleGrid.qml`, and `ControlCenterDrawer.qml` with Apple Frosted Glass design tokens.

3. **Window In-Place Swapping**:
   - **Resolution**: Use `Super + Shift + Left/Right/Up/Down` (or `H/J/K/L`) to swap the focused window in-place with the adjacent window using Hyprland's native `swapwindow` dispatcher without disrupting layout.

4. **Window Resizing/Squashing on Popups**:
   - **Status**: [RESOLVED]
   - **Fix**: Fixed `exclusiveZone: 48` in `BarWindow.qml` and layer-shell region mask so opened drawers never push or resize client tiling windows.

5. **Codebase Monolithic Structure**:
   - **Status**: [RESOLVED]
   - **Fix**: Enforced `< 150 lines per file` limit across all 37 components in `CODE_STANDARDS.md`. All legacy Waybar/Python GTK code archived into `archive/legacy-v1/`.
