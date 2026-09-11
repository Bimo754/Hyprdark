import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import ".."
import "../components"
import "../engine"
import "../modules/left"

Item {
    id: leftIslandRoot

    implicitHeight: 42
    implicitWidth: innerRow.implicitWidth + 24
    width: implicitWidth
    height: implicitHeight

    property bool isRevealed: false
    readonly property bool isIslandActive: BarState.isPinned || isRevealed

    readonly property real totalActiveHeight: 7 + implicitHeight + (dropdownOpen || animatedDrawerH > 0.1 ? 160 : 0) + 12
    readonly property real interactiveHeight: isIslandActive ? totalActiveHeight : 3

    // 1. Screen edge hit trigger (catches mouse hitting top edge y=0 in dynamic mode)
    Item {
        id: edgeTriggerZone
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 3

        HoverHandler {
            id: edgeHover
            cursorShape: Qt.ArrowCursor
            onHoveredChanged: {
                if (hovered && !BarState.isPinned) {
                    hideTimer.stop();
                    leftIslandRoot.isRevealed = true;
                }
            }
        }
    }

    // 2. Active capsule + drawer hover zone spanning from top edge down through capsule & drawers
    Item {
        id: activeHoverZone
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: leftIslandRoot.totalActiveHeight
        enabled: leftIslandRoot.isIslandActive

        HoverHandler {
            id: fullHover
            cursorShape: Qt.ArrowCursor
        }
    }

    // 3. Grace close timer to prevent twitching when pointer moves
    Timer {
        id: hideTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (!BarState.isPinned && !edgeHover.hovered && !fullHover.hovered && !leftIslandRoot.isHovered && !leftIslandRoot.dropdownOpen) {
                leftIslandRoot.isRevealed = false;
            }
        }
    }

    readonly property bool hasAnyPointer: edgeHover.hovered || fullHover.hovered || isHovered || dropdownOpen

    onHasAnyPointerChanged: {
        if (BarState.isPinned) {
            isRevealed = hasAnyPointer;
            return;
        }
        if (hasAnyPointer) {
            hideTimer.stop();
            isRevealed = true;
        } else {
            hideTimer.restart();
        }
    }

    readonly property bool canOpenDrawer: BarState.isPinned || (isRevealed && morphEngine.isFullyDisplayed)

    Connections {
        target: BarState
        function onIsPinnedChanged() {
            if (!BarState.isPinned) {
                if (!leftIslandRoot.hasAnyPointer) {
                    leftIslandRoot.isRevealed = false;
                    leftIslandRoot.activeDrawerMode = "none";
                    leftIslandRoot.pendingDrawerMode = "";
                } else {
                    leftIslandRoot.isRevealed = true;
                }
            }
        }
    }

    onCanOpenDrawerChanged: {
        if (canOpenDrawer) {
            if (targetBadge.isHovered || targetBadge.dropdownHovered) {
                pendingDrawerMode = "";
                activeDrawerMode = "target";
                lastActiveMode = "target";
            } else if (vpnBadge.isHovered || vpnBadge.dropdownHovered) {
                pendingDrawerMode = "";
                activeDrawerMode = "vpn";
                lastActiveMode = "vpn";
            } else {
                pendingDrawerMode = "";
                activeDrawerMode = "none";
            }
        } else {
            activeDrawerMode = "none";
            pendingDrawerMode = "";
        }
    }

    onIsRevealedChanged: {
        if (!isRevealed) {
            activeDrawerMode = "none";
            pendingDrawerMode = "";
        }
    }

    property string activeDrawerMode: "none"
    property string lastActiveMode: "target"
    property string pendingDrawerMode: ""
    readonly property bool isSwitchingDrawers: pendingDrawerMode !== ""

    Timer {
        id: drawerSwitchTimer
        interval: 125
        repeat: false
        onTriggered: leftIslandRoot.applyPendingDrawer()
    }

    function applyPendingDrawer() {
        if (!canOpenDrawer) return;

        if (pendingDrawerMode !== "") {
            var nextMode = pendingDrawerMode;
            pendingDrawerMode = "";

            var stillValid = false;
            if (nextMode === "target" && (targetBadge.isHovered || targetBadge.dropdownHovered)) {
                stillValid = true;
            } else if (nextMode === "vpn" && (vpnBadge.isHovered || vpnBadge.dropdownHovered)) {
                stillValid = true;
            }

            if (stillValid) {
                activeDrawerMode = nextMode;
                lastActiveMode = nextMode;
            } else {
                activeDrawerMode = "none";
            }
        }
    }

    function requestDrawer(mode) {
        if (!canOpenDrawer) {
            pendingDrawerMode = mode;
            return;
        }

        if (mode === activeDrawerMode && pendingDrawerMode === "") return;

        if (activeDrawerMode === "none" || animatedDrawerH <= 2.0) {
            pendingDrawerMode = "";
            drawerSwitchTimer.stop();
            activeDrawerMode = mode;
            lastActiveMode = mode;
        } else {
            pendingDrawerMode = mode;
            activeDrawerMode = "none";
            drawerSwitchTimer.restart();
        }
    }

    Connections {
        target: targetBadge
        function onIsHoveredChanged() {
            if (targetBadge.isHovered) {
                vpnBadge.closeDrawerImmediately();
                leftIslandRoot.requestDrawer("target");
            } else if (!leftIslandRoot.canOpenDrawer) {
                if (leftIslandRoot.pendingDrawerMode === "target") {
                    leftIslandRoot.pendingDrawerMode = "";
                }
            }
        }
        function onDropdownHoveredChanged() {
            if (targetBadge.dropdownHovered) {
                leftIslandRoot.requestDrawer("target");
            }
        }
    }

    Connections {
        target: vpnBadge
        function onIsHoveredChanged() {
            if (vpnBadge.isHovered) {
                targetBadge.closeDrawerImmediately();
                leftIslandRoot.requestDrawer("vpn");
            } else if (!leftIslandRoot.canOpenDrawer) {
                if (leftIslandRoot.pendingDrawerMode === "vpn") {
                    leftIslandRoot.pendingDrawerMode = "";
                }
            }
        }
        function onDropdownHoveredChanged() {
            if (vpnBadge.dropdownHovered) {
                leftIslandRoot.requestDrawer("vpn");
            }
        }
    }

    readonly property bool isVpnActive: canOpenDrawer && activeDrawerMode === "vpn" && vpnBadge.dropdownOpen
    readonly property bool isTargetActive: canOpenDrawer && activeDrawerMode === "target" && targetBadge.dropdownOpen
    readonly property bool dropdownOpen: isVpnActive || isTargetActive

    readonly property real targetH: canOpenDrawer ? (isVpnActive ? vpnBadge.contentHeight : (isTargetActive ? targetBadge.contentHeight : 0)) : 0
    property real animatedDrawerH: targetH

    Behavior on animatedDrawerH {
        NumberAnimation {
            duration: leftIslandRoot.targetH > 0 ? 320 : (leftIslandRoot.isSwitchingDrawers ? 120 : 200)
            easing.type: leftIslandRoot.targetH > 0 ? Easing.OutBack : Easing.OutCubic
            easing.overshoot: 1.20
        }
    }

    onAnimatedDrawerHChanged: {
        if (pendingDrawerMode !== "" && animatedDrawerH <= 2.0) {
            drawerSwitchTimer.stop();
            applyPendingDrawer();
        } else if (animatedDrawerH <= 0.5 && targetH === 0 && pendingDrawerMode === "") {
            activeDrawerMode = "none";
        }
    }

    property bool isHovered: islandHover.hovered || targetBadge.isHovered || targetBadge.dropdownHovered || vpnBadge.isHovered || vpnBadge.dropdownHovered
    readonly property color baseBorderColor: isHovered ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
    property color activeBorderColor: morphEngine.physics.pulseShimmer > 0.01 
        ? Qt.rgba(1, 1, 1, 0.12 + 0.32 * morphEngine.physics.pulseShimmer)
        : baseBorderColor
    Behavior on activeBorderColor {
        ColorAnimation { duration: StyleTokens.animFast }
    }

    // --- Modular Animation & Fluid Droplet Physics Engine ---
    IslandMorphEngine {
        id: morphEngine
        targetWidth: leftIslandRoot.implicitWidth
        targetHeight: leftIslandRoot.implicitHeight
        targetRadius: 21
        isIslandActive: leftIslandRoot.isIslandActive
        isPinned: BarState.isPinned
    }

    // --- Animated Dynamic Island Capsule Container ---
    Item {
        id: capsuleContainer
        width: morphEngine.curW
        x: morphEngine.curX
        y: morphEngine.curY
        height: leftIslandRoot.implicitHeight
        opacity: morphEngine.curOpacity

        transform: Scale {
            id: islandScale
            origin.x: capsuleContainer.width / 2
            origin.y: 21
            xScale: morphEngine.scaleX
            yScale: morphEngine.scaleY
        }

        HoverHandler {
            id: islandHover
        }

        // Unified Morphing Dynamic Island Silhouette & Outline
        Shape {
            id: islandShape
            anchors.top: parent.top
            anchors.left: parent.left
            width: capsuleContainer.width
            height: 220
            layer.enabled: true
            layer.samples: 4

            readonly property real w: capsuleContainer.width
            readonly property real hBar: 42
            readonly property real rCap: 21
            readonly property real hDraw: Math.max(0.0, leftIslandRoot.animatedDrawerH)

            // Target drawer coordinates (Center drawer)
            readonly property real targetXL: innerRow.x + targetBadge.x - 9
            readonly property real targetXR: innerRow.x + targetBadge.x + targetBadge.width + 9
            readonly property real targetCurW: targetXR - targetXL
            readonly property real targetRBottom: Math.min(14.0, Math.min(targetCurW / 2.0, hDraw * 0.58))
            readonly property real targetRFillet: Math.min(8.0, hDraw * 0.38)
            readonly property bool showVpnShape: leftIslandRoot.activeDrawerMode === "vpn" || (leftIslandRoot.activeDrawerMode === "none" && leftIslandRoot.lastActiveMode === "vpn")
            readonly property bool hasTargetDrawer: !showVpnShape && hDraw > 1.0

            // VPN drawer coordinates (Right-edge morph drawer ending precisely at the divider line)
            readonly property real vpnDividerX: innerRow.x + targetVpnDivider.x + 0.5
            readonly property real vpnRFillet: Math.min(6.0, hDraw * 0.3)
            readonly property real vpnXL: vpnDividerX
            readonly property real vpnCurW: w - vpnXL
            readonly property real vpnRBottom: Math.min(16.0, Math.min(vpnCurW / 2.0, hDraw * 0.58))
            readonly property bool hasVpnDrawer: showVpnShape && hDraw > 1.0

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
            transformOrigin: Item.Center

            opacity: morphEngine.contentOpacity
            scale: morphEngine.contentScale
            visible: opacity > 0.005

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
                isDrawerActive: leftIslandRoot.canOpenDrawer && leftIslandRoot.activeDrawerMode === "target"
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
                isDrawerActive: leftIslandRoot.canOpenDrawer && leftIslandRoot.activeDrawerMode === "vpn"
            }
        }
    }
}
