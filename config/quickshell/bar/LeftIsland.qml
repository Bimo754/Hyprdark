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

    readonly property bool isTargetOpen: targetBadge.dropdownOpen
    readonly property bool isVpnOpen: vpnBadge.dropdownOpen
    readonly property bool dropdownOpen: isTargetOpen || isVpnOpen

    readonly property real targetTargetH: isTargetOpen ? targetBadge.contentHeight : 0
    readonly property real vpnTargetH: isVpnOpen ? vpnBadge.contentHeight : 0
    readonly property real targetH: Math.max(targetTargetH, vpnTargetH)

    property real animatedDrawerH: targetH

    Behavior on animatedDrawerH {
        NumberAnimation {
            duration: leftIslandRoot.targetH > 0 ? 240 : 180
            easing.type: Easing.OutCubic
        }
    }

    property real lastDrawerLeft: 0
    property real lastDrawerRight: 0

    onIsTargetOpenChanged: {
        if (isTargetOpen) {
            lastDrawerLeft = innerRow.x + targetBadge.x - 9;
            lastDrawerRight = innerRow.x + targetBadge.x + targetBadge.width + 9;
        }
    }
    onIsVpnOpenChanged: {
        if (isVpnOpen) {
            lastDrawerLeft = innerRow.x + vpnBadge.x - 9;
            lastDrawerRight = innerRow.x + vpnBadge.x + vpnBadge.width + 9;
        }
    }

    readonly property real activeDrawerLeft: isTargetOpen ? (innerRow.x + targetBadge.x - 9) : (isVpnOpen ? (innerRow.x + vpnBadge.x - 9) : lastDrawerLeft)
    readonly property real activeDrawerRight: isTargetOpen ? (innerRow.x + targetBadge.x + targetBadge.width + 9) : (isVpnOpen ? (innerRow.x + vpnBadge.x + vpnBadge.width + 9) : lastDrawerRight)

    property bool isHovered: islandHover.hovered || targetBadge.isHovered || targetBadge.dropdownHovered || vpnBadge.isHovered || vpnBadge.dropdownHovered

    HoverHandler {
        id: islandHover
    }

    // Unified Morphing Dynamic Island Silhouette & Outline
    Shape {
        id: islandShape
        anchors.top: parent.top
        anchors.left: parent.left
        width: leftIslandRoot.width
        height: 200
        layer.enabled: true
        layer.samples: 4

        readonly property real w: leftIslandRoot.width
        readonly property real hBar: 42
        readonly property real rCap: 21
        readonly property real hDraw: Math.max(0.0, leftIslandRoot.animatedDrawerH)
        readonly property real rFillet: Math.min(8.0, hDraw * 0.22)
        readonly property real rBottom: Math.min(14.0, hDraw * 0.42)
        readonly property real xL: leftIslandRoot.activeDrawerLeft
        readonly property real xR: leftIslandRoot.activeDrawerRight

        ShapePath {
            strokeColor: leftIslandRoot.isHovered ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
            strokeWidth: 1
            fillColor: StyleTokens.glassBackground
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap

            Behavior on strokeColor {
                ColorAnimation { duration: StyleTokens.animFast }
            }

            // Start at top-left curve: (rCap, 0)
            startX: islandShape.rCap
            startY: 0

            // 1. Top horizontal line
            PathLine {
                x: islandShape.w - islandShape.rCap
                y: 0
            }

            // 2. Right capsule half-circle
            PathArc {
                x: islandShape.w - islandShape.rCap
                y: islandShape.hBar
                radiusX: islandShape.rCap
                radiusY: islandShape.rCap
                direction: PathArc.Clockwise
            }

            // 3. Bottom line going left to drawer right
            PathLine {
                x: islandShape.xR + islandShape.rFillet
                y: islandShape.hBar
            }

            // 4. Concave fillet down into drawer right
            PathArc {
                x: islandShape.xR
                y: islandShape.hBar + islandShape.rFillet
                radiusX: islandShape.rFillet
                radiusY: islandShape.rFillet
                direction: PathArc.Counterclockwise
            }

            // 5. Drawer right side line
            PathLine {
                x: islandShape.xR
                y: islandShape.hBar + islandShape.hDraw - islandShape.rBottom
            }

            // 6. Drawer bottom-right convex curve
            PathArc {
                x: islandShape.xR - islandShape.rBottom
                y: islandShape.hBar + islandShape.hDraw
                radiusX: islandShape.rBottom
                radiusY: islandShape.rBottom
                direction: PathArc.Clockwise
            }

            // 7. Drawer bottom horizontal line
            PathLine {
                x: islandShape.xL + islandShape.rBottom
                y: islandShape.hBar + islandShape.hDraw
            }

            // 8. Drawer bottom-left convex curve
            PathArc {
                x: islandShape.xL
                y: islandShape.hBar + islandShape.hDraw - islandShape.rBottom
                radiusX: islandShape.rBottom
                radiusY: islandShape.rBottom
                direction: PathArc.Clockwise
            }

            // 9. Drawer left side line
            PathLine {
                x: islandShape.xL
                y: islandShape.hBar + islandShape.rFillet
            }

            // 10. Concave fillet up into island bottom
            PathArc {
                x: islandShape.xL - islandShape.rFillet
                y: islandShape.hBar
                radiusX: islandShape.rFillet
                radiusY: islandShape.rFillet
                direction: PathArc.Counterclockwise
            }

            // 11. Bottom line to left capsule
            PathLine {
                x: islandShape.rCap
                y: islandShape.hBar
            }

            // 12. Left capsule half-circle back to start
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
