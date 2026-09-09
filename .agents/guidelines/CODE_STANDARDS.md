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
├── shell.qml                (Window container & screen variants)
├── StyleTokens.qml          (Central design system singleton)
├── qmldir                   (Singleton module declarations)
├── bar/
│   ├── BarWindow.qml        (PanelWindow, 52px exclusive zone, region masking)
│   └── LeftIsland.qml       (Top-Left Island capsule orchestrator)
├── modules/
│   └── left/                (Top-Left Island micro-components)
│       ├── ArchLauncher.qml (Rofi application launcher trigger)
│       ├── WorkspaceList.qml (Workspaces 1-5 interactive pills & mouse scroll)
│       ├── TargetBadge.qml  (Target IP telemetry & 1-click copy)
│       └── VpnBadge.qml     (VPN status telemetry & 1-click copy)
└── components/              (Shared primitive controls)
    └── IslandCapsule.qml    (Monochromatic frosted glass capsule base)
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
