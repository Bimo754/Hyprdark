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
        if (BarState.isPinned) return;
        if (hasAnyPointer) {
            hideTimer.stop();
            isRevealed = true;
        } else {
            hideTimer.restart();
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
        if (mode === activeDrawerMode && pendingDrawerMode === "") return;

        if (pendingDrawerMode !== "") {
            pendingDrawerMode = mode;
            return;
        }

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
            }
        }
        function onDropdownHoveredChanged() {
            if (vpnBadge.dropdownHovered) {
                leftIslandRoot.requestDrawer("vpn");
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
    property real pulseShimmer: 0.0
    property color activeBorderColor: pulseShimmer > 0.01 
        ? Qt.rgba(1, 1, 1, 0.12 + 0.32 * pulseShimmer)
        : baseBorderColor
    Behavior on activeBorderColor {
        ColorAnimation { duration: StyleTokens.animFast }
    }

    // Animated Dynamic Island Capsule Container with Circle-to-Island Morphing Physics
    Item {
        id: capsuleContainer

        readonly property real circleSize: 42
        readonly property real fullWidth: leftIslandRoot.implicitWidth

        property real curW: leftIslandRoot.isIslandActive ? fullWidth : circleSize
        property real curX: leftIslandRoot.isIslandActive ? 0 : (fullWidth - circleSize) / 2
        property real curY: leftIslandRoot.isIslandActive ? 7 : -52

        width: curW
        x: curX
        y: curY
        height: leftIslandRoot.implicitHeight

        transform: Scale {
            id: islandScale
            origin.x: capsuleContainer.width / 2
            origin.y: 21
            xScale: 1.0
            yScale: 1.0
        }

        states: [
            State {
                name: "hidden"
                when: !leftIslandRoot.isIslandActive
                PropertyChanges {
                    target: capsuleContainer
                    curY: -52
                    curW: capsuleContainer.circleSize
                    curX: (capsuleContainer.fullWidth - capsuleContainer.circleSize) / 2
                    opacity: 0.0
                }
                PropertyChanges {
                    target: innerRow
                    opacity: 0.0
                    scale: 0.85
                    visible: false
                }
                PropertyChanges {
                    target: leftIslandRoot
                    pulseShimmer: 0.0
                }
                PropertyChanges {
                    target: islandScale
                    xScale: 1.0
                    yScale: 1.0
                }
            },
            State {
                name: "visible"
                when: leftIslandRoot.isIslandActive
                PropertyChanges {
                    target: capsuleContainer
                    curY: 7
                    curW: capsuleContainer.fullWidth
                    curX: 0
                    opacity: 1.0
                }
                PropertyChanges {
                    target: innerRow
                    opacity: 1.0
                    scale: 1.0
                    visible: true
                }
                PropertyChanges {
                    target: leftIslandRoot
                    pulseShimmer: 0.0
                }
                PropertyChanges {
                    target: islandScale
                    xScale: 1.0
                    yScale: 1.0
                }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                ParallelAnimation {
                    // Quick fade in
                    NumberAnimation {
                        target: capsuleContainer
                        property: "opacity"
                        to: 1.0
                        duration: 80
                        easing.type: Easing.OutQuad
                    }

                    // 1. VERTICAL DROP TRAJECTORY: Ball drops out of top bezel and settles
                    SequentialAnimation {
                        NumberAnimation {
                            target: capsuleContainer
                            property: "curY"
                            to: 13
                            duration: 260
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: capsuleContainer
                            property: "curY"
                            to: 7
                            duration: 140
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.25
                        }
                    }

                    // 2. LIQUID DROPLET WOBBLE: Teardrop stretch during drop -> splash squash -> settle
                    SequentialAnimation {
                        // Teardrop stretch while falling out of top bezel
                        ParallelAnimation {
                            NumberAnimation { target: islandScale; property: "xScale"; to: 0.74; duration: 160; easing.type: Easing.OutQuad }
                            NumberAnimation { target: islandScale; property: "yScale"; to: 1.40; duration: 160; easing.type: Easing.OutQuad }
                        }
                        // Splash squash upon touching down
                        ParallelAnimation {
                            NumberAnimation { target: islandScale; property: "xScale"; to: 1.18; duration: 110; easing.type: Easing.OutQuad }
                            NumberAnimation { target: islandScale; property: "yScale"; to: 0.84; duration: 110; easing.type: Easing.OutQuad }
                        }
                        // Elastic rebound back to rest
                        ParallelAnimation {
                            NumberAnimation { target: islandScale; property: "xScale"; to: 1.0; duration: 130; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                            NumberAnimation { target: islandScale; property: "yScale"; to: 1.0; duration: 130; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                        }
                    }

                    // 3. OVERLAPPING HORIZONTAL MORPH:
                    // Stays a ball for the initial 150ms, and then WHILE STILL POPPING DOWN in mid-air,
                    // starts expanding horizontally into the island capsule!
                    SequentialAnimation {
                        PauseAnimation { duration: 150 }
                        ParallelAnimation {
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curW"
                                to: capsuleContainer.fullWidth
                                duration: 420
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.25
                            }
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curX"
                                to: 0
                                duration: 420
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.25
                            }
                        }
                    }

                    // 4. CASCADE GLYPH MATERIALIZATION: Fade and pop in while capsule unfurls
                    SequentialAnimation {
                        PauseAnimation { duration: 260 }
                        ParallelAnimation {
                            NumberAnimation {
                                target: innerRow
                                property: "opacity"
                                to: 1.0
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: innerRow
                                property: "scale"
                                to: 1.0
                                duration: 260
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.25
                            }
                        }
                    }

                    // 5. TACTILE FROSTED GLASS SHIMMER PULSE
                    SequentialAnimation {
                        PauseAnimation { duration: 420 }
                        NumberAnimation {
                            target: leftIslandRoot
                            property: "pulseShimmer"
                            to: 1.0
                            duration: 90
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: leftIslandRoot
                            property: "pulseShimmer"
                            to: 0.0
                            duration: 320
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            },
            Transition {
                from: "visible"
                to: "hidden"
                ParallelAnimation {
                    // 1. Content quick exit (fade out cleanly so only the liquid silhouette is seen)
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: innerRow
                                property: "opacity"
                                to: 0.0
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                            NumberAnimation {
                                target: innerRow
                                property: "scale"
                                to: 0.80
                                duration: 120
                                easing.type: Easing.InQuad
                            }
                        }
                    }

                    // 2. PHASE 1: HORIZONTAL COLLAPSE TO BALL
                    // The capsule pinches inward from both sides at resting height (y=7)
                    // Zero downward bounce — cleanly forms a circular droplet
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curW"
                                to: capsuleContainer.circleSize
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curX"
                                to: (capsuleContainer.fullWidth - capsuleContainer.circleSize) / 2
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // 3. PHASE 2: APERTURE SUCTION & UNIFORM SHRINK (STRICTLY NOT SQUISHED)
                    // The ball stays a flawless circle (xScale == yScale at all times, NEVER squished).
                    // As it accelerates up into the top bezel, it shrinks uniformly into a tiny point
                    // as if being pulled into a camera punch-hole aperture or vacuum port!
                    SequentialAnimation {
                        PauseAnimation { duration: 230 }
                        ParallelAnimation {
                            // Upward suction trajectory into top screen bezel
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curY"
                                to: -52
                                duration: 240
                                easing.type: Easing.InCubic
                            }
                            // Uniform 1:1 circular shrink (STRICTLY NOT SQUISHED)
                            SequentialAnimation {
                                // Subtle energetic pulse as the ball gathers
                                ParallelAnimation {
                                    NumberAnimation { target: islandScale; property: "xScale"; to: 1.06; duration: 60; easing.type: Easing.OutQuad }
                                    NumberAnimation { target: islandScale; property: "yScale"; to: 1.06; duration: 60; easing.type: Easing.OutQuad }
                                }
                                // Uniform aperture shrink into tiny bead disappearing into bezel
                                ParallelAnimation {
                                    NumberAnimation { target: islandScale; property: "xScale"; to: 0.18; duration: 180; easing.type: Easing.InQuad }
                                    NumberAnimation { target: islandScale; property: "yScale"; to: 0.18; duration: 180; easing.type: Easing.InQuad }
                                }
                                // Offscreen reset to 1.0 while invisible
                                ParallelAnimation {
                                    NumberAnimation { target: islandScale; property: "xScale"; to: 1.0; duration: 20; easing.type: Easing.Linear }
                                    NumberAnimation { target: islandScale; property: "yScale"; to: 1.0; duration: 20; easing.type: Easing.Linear }
                                }
                            }
                            // Dissolve as it enters the bezel
                            SequentialAnimation {
                                PauseAnimation { duration: 90 }
                                NumberAnimation {
                                    target: capsuleContainer
                                    property: "opacity"
                                    to: 0.0
                                    duration: 130
                                    easing.type: Easing.InQuad
                                }
                            }
                        }
                    }
                }
            }
        ]

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
            isDrawerActive: leftIslandRoot.activeDrawerMode === "target"
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
            isDrawerActive: leftIslandRoot.activeDrawerMode === "vpn"
        }
    }
    }
}
