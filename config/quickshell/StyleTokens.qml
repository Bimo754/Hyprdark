pragma Singleton
import QtQuick

QtObject {
    id: tokens

    // Monochromatic Apple Dark Frosted Glass Palette (Zero Neon/Rainbow Saturated Colors)
    readonly property color glassBackground: Qt.rgba(22/255, 22/255, 26/255, 0.82)
    readonly property color glassBackgroundHover: Qt.rgba(32/255, 32/255, 38/255, 0.90)
    readonly property color cardBackground: Qt.rgba(26/255, 26/255, 30/255, 0.94)
    readonly property color surfaceSubtle: Qt.rgba(255/255, 255/255, 255/255, 0.05)
    readonly property color surfaceHover: Qt.rgba(255/255, 255/255, 255/255, 0.12)
    readonly property color surfaceActive: Qt.rgba(255/255, 255/255, 255/255, 0.20)

    // Hairline Borders & Dividers
    readonly property color hairlineBorder: Qt.rgba(255/255, 255/255, 255/255, 0.12)
    readonly property color hairlineBorderHover: Qt.rgba(255/255, 255/255, 255/255, 0.24)
    readonly property color hairlineDivider: Qt.rgba(255/255, 255/255, 255/255, 0.08)

    // Typography
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: Qt.rgba(255/255, 255/255, 255/255, 0.80)
    readonly property color textTertiary: Qt.rgba(255/255, 255/255, 255/255, 0.45)
    readonly property color textActive: "#16161a"

    // Active Solid Pill Accent
    readonly property color activePill: "#ffffff"
    readonly property color activePillText: "#16161a"

    // Dynamic Telemetry Soft Glows (Used exclusively on active hover)
    readonly property color targetBlueHover: Qt.rgba(10/255, 132/255, 255/255, 0.22)
    readonly property color vpnGreenHover: Qt.rgba(48/255, 209/255, 88/255, 0.22)
    readonly property color alertRed: Qt.rgba(255/255, 69/255, 58/255, 0.85)

    // Transparent
    readonly property color transparent: "transparent"

    // Typography Fonts
    readonly property string fontFamily: "Inter, -apple-system, sans-serif"
    readonly property string monoFontFamily: "JetBrainsMono Nerd Font, JetBrains Mono, monospace"

    // Radii
    readonly property real capsuleRadius: 999
    readonly property real cardRadius: 16
    readonly property real buttonRadius: 10
    readonly property real squircleRadius: 14

    // Animation Timings
    readonly property int animFast: 150
    readonly property int animNormal: 250
    readonly property int animSmooth: 350
}
