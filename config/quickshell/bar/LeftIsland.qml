import QtQuick
import QtQuick.Shapes
import Quickshell
import ".."
import "../components"
import "../modules/left"

Item {
    id: leftIslandRoot

    implicitHeight: 42
    implicitWidth: innerRow.implicitWidth + 24
    width: implicitWidth
    height: implicitHeight

    property string activeDrawerMode: "none"
    property string lastActiveMode: "target"

    Connections {
        target: targetBadge
        function onIsHoveredChanged() {
            if (targetBadge.isHovered) {
                leftIslandRoot.activeDrawerMode = "target";
                leftIslandRoot.lastActiveMode = "target";
                vpnBadge.closeDrawerImmediately();
            }
        }
        function onDropdownHoveredChanged() {
            if (targetBadge.dropdownHovered) {
                leftIslandRoot.activeDrawerMode = "target";
                leftIslandRoot.lastActiveMode = "target";
            }
        }
    }

    Connections {
        target: vpnBadge
        function onIsHoveredChanged() {
            if (vpnBadge.isHovered) {
                leftIslandRoot.activeDrawerMode = "vpn";
                leftIslandRoot.lastActiveMode = "vpn";
                targetBadge.closeDrawerImmediately();
            }
        }
        function onDropdownHoveredChanged() {
            if (vpnBadge.dropdownHovered) {
                leftIslandRoot.activeDrawerMode = "vpn";
                leftIslandRoot.lastActiveMode = "vpn";
            }
        }
    }

    readonly property bool isVpnActive: activeDrawerMode === "vpn" && vpnBadge.dropdownOpen
    readonly property bool isTargetActive: activeDrawerMode === "target" && targetBadge.dropdownOpen
    readonly property bool dropdownOpen: isVpnActive || isTargetActive

    readonly property real targetH: isVpnActive ? vpnBadge.contentHeight : (isTargetActive ? targetBadge.contentHeight : 0)
    property real animatedDrawerH: targetH

    Behavior on animatedDrawerH {
        NumberAnimation {
            duration: leftIslandRoot.targetH > 0 ? 320 : 200
            easing.type: leftIslandRoot.targetH > 0 ? Easing.OutBack : Easing.OutCubic
            easing.overshoot: 1.20
        }
    }

    onAnimatedDrawerHChanged: {
        if (animatedDrawerH <= 0.5 && targetH === 0) {
            activeDrawerMode = "none";
        }
    }

    property bool isHovered: islandHover.hovered || targetBadge.isHovered || targetBadge.dropdownHovered || vpnBadge.isHovered || vpnBadge.dropdownHovered
    property color activeBorderColor: isHovered ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
    Behavior on activeBorderColor {
        ColorAnimation { duration: StyleTokens.animFast }
    }

    HoverHandler {
        id: islandHover
    }

    // Unified Morphing Dynamic Island Silhouette & Outline
    Shape {
        id: islandShape
        anchors.top: parent.top
        anchors.left: parent.left
        width: leftIslandRoot.width
        height: 220
        layer.enabled: true
        layer.samples: 4

        readonly property real w: leftIslandRoot.width
        readonly property real hBar: 42
        readonly property real rCap: 21
        readonly property real hDraw: Math.max(0.0, leftIslandRoot.animatedDrawerH)

        // Target drawer coordinates (Center drawer)
        readonly property real targetXL: innerRow.x + targetBadge.x - 9
        readonly property real targetXR: innerRow.x + targetBadge.x + targetBadge.width + 9
        readonly property real targetCurW: targetXR - targetXL
        readonly property real targetRBottom: Math.min(14.0, Math.min(targetCurW / 2.0, hDraw * 0.58))
        readonly property real targetRFillet: Math.min(8.0, hDraw * 0.38)
        readonly property bool hasTargetDrawer: (leftIslandRoot.activeDrawerMode === "target" || leftIslandRoot.isTargetActive) && hDraw > 1.0

        // VPN drawer coordinates (Right-edge morph drawer ending precisely at the divider line)
        readonly property real vpnDividerX: innerRow.x + targetVpnDivider.x + 0.5
        readonly property real vpnRFillet: Math.min(6.0, hDraw * 0.3)
        readonly property real vpnXL: vpnDividerX
        readonly property real vpnCurW: w - vpnXL
        readonly property real vpnRBottom: Math.min(16.0, Math.min(vpnCurW / 2.0, hDraw * 0.58))
        readonly property bool hasVpnDrawer: (leftIslandRoot.activeDrawerMode === "vpn" || leftIslandRoot.isVpnActive) && hDraw > 1.0

        readonly property bool showVpnShape: leftIslandRoot.activeDrawerMode === "vpn" || (leftIslandRoot.activeDrawerMode === "none" && leftIslandRoot.lastActiveMode === "vpn")

        // 1. Standard / Center Drawer Morphology (Default closed capsule & Target drawer)
        ShapePath {
            id: targetShapePath
            strokeColor: !islandShape.showVpnShape ? leftIslandRoot.activeBorderColor : "transparent"
            strokeWidth: 1
            fillColor: !islandShape.showVpnShape ? StyleTokens.glassBackground : "transparent"
            joinStyle: ShapePath.MiterJoin
            capStyle: ShapePath.FlatCap

            startX: islandShape.rCap
            startY: 0

            // Top line
            PathLine {
                x: islandShape.w - islandShape.rCap
                y: 0
            }

            // Right capsule half-circle
            PathArc {
                x: islandShape.w - islandShape.rCap
                y: islandShape.hBar
                radiusX: islandShape.rCap
                radiusY: islandShape.rCap
                direction: PathArc.Clockwise
            }

            // Bottom line to drawer right
            PathLine {
                x: islandShape.hasTargetDrawer ? (islandShape.targetXR + islandShape.targetRFillet) : islandShape.rCap
                y: islandShape.hBar
            }

            // Concave fillet down into drawer right
            PathArc {
                x: islandShape.hasTargetDrawer ? islandShape.targetXR : islandShape.rCap
                y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.targetRFillet) : islandShape.hBar
                radiusX: islandShape.hasTargetDrawer ? islandShape.targetRFillet : 0
                radiusY: islandShape.hasTargetDrawer ? islandShape.targetRFillet : 0
                direction: PathArc.Counterclockwise
            }

            // Drawer right vertical line
            PathLine {
                x: islandShape.hasTargetDrawer ? islandShape.targetXR : islandShape.rCap
                y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.hDraw - islandShape.targetRBottom) : islandShape.hBar
            }

            // Drawer bottom-right convex curve
            PathArc {
                x: islandShape.hasTargetDrawer ? (islandShape.targetXR - islandShape.targetRBottom) : islandShape.rCap
                y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.hDraw) : islandShape.hBar
                radiusX: islandShape.hasTargetDrawer ? islandShape.targetRBottom : 0
                radiusY: islandShape.hasTargetDrawer ? islandShape.targetRBottom : 0
                direction: PathArc.Clockwise
            }

            // Drawer bottom horizontal line
            PathLine {
                x: islandShape.hasTargetDrawer ? (islandShape.targetXL + islandShape.targetRBottom) : islandShape.rCap
                y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.hDraw) : islandShape.hBar
            }

            // Drawer bottom-left convex curve
            PathArc {
                x: islandShape.hasTargetDrawer ? islandShape.targetXL : islandShape.rCap
                y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.hDraw - islandShape.targetRBottom) : islandShape.hBar
                radiusX: islandShape.hasTargetDrawer ? islandShape.targetRBottom : 0
                radiusY: islandShape.hasTargetDrawer ? islandShape.targetRBottom : 0
                direction: PathArc.Clockwise
            }

            // Drawer left vertical line
            PathLine {
                x: islandShape.hasTargetDrawer ? islandShape.targetXL : islandShape.rCap
                y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.targetRFillet) : islandShape.hBar
            }

            // Concave fillet up into island bottom
            PathArc {
                x: islandShape.hasTargetDrawer ? (islandShape.targetXL - islandShape.targetRFillet) : islandShape.rCap
                y: islandShape.hBar
                radiusX: islandShape.hasTargetDrawer ? islandShape.targetRFillet : 0
                radiusY: islandShape.hasTargetDrawer ? islandShape.targetRFillet : 0
                direction: PathArc.Counterclockwise
            }

            // Bottom line to left capsule
            PathLine {
                x: islandShape.rCap
                y: islandShape.hBar
            }

            // Left capsule half-circle back to start
            PathArc {
                x: islandShape.rCap
                y: 0
                radiusX: islandShape.rCap
                radiusY: islandShape.rCap
                direction: PathArc.Clockwise
            }
        }

        // 2. Right-Edge Morph Morphology (Right capsule half-circle opens and elongates down with VPN drawer)
        ShapePath {
            id: vpnShapePath
            strokeColor: islandShape.showVpnShape ? leftIslandRoot.activeBorderColor : "transparent"
            strokeWidth: 1
            fillColor: islandShape.showVpnShape ? StyleTokens.glassBackground : "transparent"
            joinStyle: ShapePath.MiterJoin
            capStyle: ShapePath.FlatCap

            startX: islandShape.rCap
            startY: 0

            // Top line
            PathLine {
                x: islandShape.w - islandShape.rCap
                y: 0
            }

            // Top-right quarter circle down to rightmost apex (w, rCap)
            PathArc {
                x: islandShape.w
                y: islandShape.rCap
                radiusX: islandShape.rCap
                radiusY: islandShape.rCap
                direction: PathArc.Clockwise
            }

            // Right vertical wall extending down when drawer opens
            PathLine {
                x: islandShape.w
                y: islandShape.rCap + islandShape.hDraw
            }

            // Bottom-right quarter circle curving into drawer bottom
            PathArc {
                x: islandShape.w - islandShape.rCap
                y: islandShape.hBar + islandShape.hDraw
                radiusX: islandShape.rCap
                radiusY: islandShape.rCap
                direction: PathArc.Clockwise
            }

            // Bottom line of drawer going left to bottom-left corner
            PathLine {
                x: islandShape.hasVpnDrawer ? (islandShape.vpnXL + islandShape.vpnRBottom) : islandShape.rCap
                y: islandShape.hasVpnDrawer ? (islandShape.hBar + islandShape.hDraw) : islandShape.hBar
            }

            // Bottom-left convex corner of drawer
            PathArc {
                x: islandShape.hasVpnDrawer ? islandShape.vpnXL : islandShape.rCap
                y: islandShape.hasVpnDrawer ? (islandShape.hBar + islandShape.hDraw - islandShape.vpnRBottom) : islandShape.hBar
                radiusX: islandShape.hasVpnDrawer ? islandShape.vpnRBottom : 0
                radiusY: islandShape.hasVpnDrawer ? islandShape.vpnRBottom : 0
                direction: PathArc.Clockwise
            }

            // Left vertical wall of drawer going up
            PathLine {
                x: islandShape.hasVpnDrawer ? islandShape.vpnXL : islandShape.rCap
                y: islandShape.hasVpnDrawer ? (islandShape.hBar + islandShape.vpnRFillet) : islandShape.hBar
            }

            // Concave fillet curving up into island capsule bottom line
            PathArc {
                x: islandShape.hasVpnDrawer ? (islandShape.vpnXL - islandShape.vpnRFillet) : islandShape.rCap
                y: islandShape.hBar
                radiusX: islandShape.hasVpnDrawer ? islandShape.vpnRFillet : 0
                radiusY: islandShape.hasVpnDrawer ? islandShape.vpnRFillet : 0
                direction: PathArc.Counterclockwise
            }

            // Bottom line of island capsule to left capsule
            PathLine {
                x: islandShape.rCap
                y: islandShape.hBar
            }

            // Left capsule half-circle back to start
            PathArc {
                x: islandShape.rCap
                y: 0
                radiusX: islandShape.rCap
                radiusY: islandShape.rCap
                direction: PathArc.Clockwise
            }
        }
    }

    Row {
        id: innerRow
        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        // 1. Arch Logo Launcher
        ArchLauncher {}

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 2. Workspaces 1-5
        WorkspaceList {}

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 3. Target IP Telemetry
        TargetBadge {
            id: targetBadge
        }

        // Divider
        Rectangle {
            id: targetVpnDivider
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 4. VPN Status Telemetry
        VpnBadge {
            id: vpnBadge
        }
    }
}
