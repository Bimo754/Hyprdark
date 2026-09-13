import QtQuick
import Quickshell
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
    readonly property bool isIslandActive: !BarState.isFullscreen && (BarState.isPinned || isRevealed)

    readonly property real totalActiveHeight: 7 + implicitHeight + (dropdownOpen || animatedDrawerH > 0.1 ? 160 : 0) + 12
    readonly property real interactiveHeight: isIslandActive ? totalActiveHeight : 3

    // 1. Screen edge hit trigger
    Item {
        id: edgeTriggerZone
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 3
        enabled: !BarState.isFullscreen

        HoverHandler {
            id: edgeHover
            cursorShape: Qt.ArrowCursor
            onHoveredChanged: {
                if (hovered && !BarState.isPinned && !BarState.isFullscreen) {
                    hideTimer.stop();
                    leftIslandRoot.isRevealed = true;
                }
            }
        }
    }

    // 2. Active capsule + drawer hover zone
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

    // 3. Grace close timer
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
        if (hasAnyPointer && !BarState.isFullscreen) {
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
        function onIsFullscreenChanged() {
            if (BarState.isFullscreen) {
                leftIslandRoot.isRevealed = false;
                leftIslandRoot.activeDrawerMode = "none";
                leftIslandRoot.pendingDrawerMode = "";
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
            } else if (!leftIslandRoot.canOpenDrawer && leftIslandRoot.pendingDrawerMode === "target") {
                leftIslandRoot.pendingDrawerMode = "";
            }
        }
        function onDropdownHoveredChanged() {
            if (targetBadge.dropdownHovered) leftIslandRoot.requestDrawer("target");
        }
    }

    Connections {
        target: vpnBadge
        function onIsHoveredChanged() {
            if (vpnBadge.isHovered) {
                targetBadge.closeDrawerImmediately();
                leftIslandRoot.requestDrawer("vpn");
            } else if (!leftIslandRoot.canOpenDrawer && leftIslandRoot.pendingDrawerMode === "vpn") {
                leftIslandRoot.pendingDrawerMode = "";
            }
        }
        function onDropdownHoveredChanged() {
            if (vpnBadge.dropdownHovered) leftIslandRoot.requestDrawer("vpn");
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

    Behavior on activeBorderColor { ColorAnimation { duration: StyleTokens.animFast } }

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
            origin.x: capsuleContainer.width / 2
            origin.y: 21
            xScale: morphEngine.scaleX
            yScale: morphEngine.scaleY
        }

        HoverHandler { id: islandHover }

        // Modular Morphing Dynamic Island Silhouette & Outline
        LeftIslandShape {
            w: capsuleContainer.width
            hDraw: Math.max(0.0, leftIslandRoot.animatedDrawerH)
            borderColor: leftIslandRoot.activeBorderColor
            targetXL: innerRow.x + targetBadge.x - 9
            targetXR: innerRow.x + targetBadge.x + targetBadge.width + 9
            vpnXL: innerRow.x + targetVpnDivider.x + 0.5
            showVpnShape: leftIslandRoot.activeDrawerMode === "vpn" || (leftIslandRoot.activeDrawerMode === "none" && leftIslandRoot.lastActiveMode === "vpn")
        }

        // Inner Content Row
        Row {
            id: innerRow
            anchors.centerIn: parent
            spacing: 6
            opacity: morphEngine.contentOpacity
            scale: morphEngine.contentScale

            ArchLauncher { id: archLauncher }
            WorkspaceList { id: workspaceList }

            Rectangle {
                width: 1
                height: 14
                color: StyleTokens.hairlineDivider
                anchors.verticalCenter: parent.verticalCenter
            }

            TargetBadge { id: targetBadge }

            Rectangle {
                id: targetVpnDivider
                width: 1
                height: 14
                color: StyleTokens.hairlineDivider
                anchors.verticalCenter: parent.verticalCenter
            }

            VpnBadge { id: vpnBadge }
        }
    }
}
