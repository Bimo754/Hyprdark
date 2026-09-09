# Hyprdark - Modular Architecture & Code Quality Standards

This document defines the strict, non-negotiable coding conventions and architectural patterns for the Hyprdark desktop environment.

---

## 1. Single Responsibility & File Line Limit (Hard Limit: 150 Lines)
- **Hard Limit**: No single code file (QML, shell, Python, or config) may exceed **150 lines**.
- **Decomposition Mandate**: If a component approaches 120–140 lines, it must be decomposed into focused sub-components.
- **Single Responsibility Principle (SRP)**: Each file must do exactly one thing:
  - Container files (e.g. `LeftIsland.qml`) ONLY orchestrate sub-components with layout properties.
  - Micro-components (e.g. `ArchLauncher.qml`, `TargetBadge.qml`, `WorkspaceList.qml`) manage their own isolated state, visual hierarchy, and telemetry.

---

## 2. Directory & Component Structure
```text
config/quickshell/
├── shell.qml                (Window container & Layer-Shell exclusivity)
├── StyleTokens.qml          (Central design system singleton)
├── bar/
│   ├── LeftIsland.qml       (Left Island orchestrator)
│   ├── CenterIsland.qml     (Center Dynamic Island orchestrator)
│   └── RightIsland.qml      (Right Island orchestrator)
├── modules/
│   ├── left/                (Left Island micro-components)
│   │   ├── ArchLauncher.qml
│   │   ├── WorkspaceList.qml
│   │   ├── TargetBadge.qml
│   │   └── VpnBadge.qml
│   ├── center/              (Center Island micro-components)
│   │   ├── RestingClock.qml
│   │   ├── CalendarGrid.qml
│   │   ├── NotificationDeck.qml
│   │   └── NotificationCard.qml
│   └── right/               (Right Island micro-components)
│       ├── CpuMetric.qml
│       ├── MemoryMetric.qml
│       ├── BatteryMetric.qml
│       ├── VolumeMetric.qml
│       └── PowerButton.qml
├── dropdowns/               (Floating popups / drawers)
│   ├── AudioDrawer.qml
│   └── ControlCenterDrawer.qml
└── components/              (Shared primitive controls)
    ├── FrostedSlider.qml
    ├── IslandCapsule.qml
    └── IconButton.qml
```

---

## 3. Design System Encapsulation (StyleTokens.qml)
- **Zero Magic Colors or Dimensions**: NEVER hardcode hex codes or arbitrary pixel sizes directly in modules.
- Always reference `StyleTokens.glassBackground`, `StyleTokens.hairlineBorder`, `StyleTokens.textPrimary`, `StyleTokens.capsuleRadius`, etc.
- **Monochromatic Apple Dark Glass**: Monochromatic Apple frosted glass aesthetic with pure solid white typography and translucent white accents.

---

## 4. Verification & Testing Rule
- Every modification must be visually verified via `grim` screenshot capture and inspected with `view_file`.
- Run line count audits to ensure no files exceed the 150-line limit:
  ```bash
  find config/quickshell -name "*.qml" -exec wc -l {} +
  ```
