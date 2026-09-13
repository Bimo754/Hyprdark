import QtQuick
import Quickshell
import ".."
import "../engine"
import "../modules/center"

Item {
    id: centerIslandRoot

    // --- State & Target Dimensions ---
    readonly property bool hasNotification: NotificationState.hasActiveNotification
    readonly property bool isCenterExpanded: BarState.centerExpanded
    readonly property bool calendarOpen: (BarState.centerPanel === "calendar")
    readonly property bool notificationCenterOpen: (BarState.centerPanel === "notifications")
    property bool isRevealed: false
    readonly property bool isIslandActive: !BarState.isFullscreen && (BarState.isPinned || isRevealed || isCenterExpanded || hasNotification)

    readonly property real circleSize: 42
    readonly property real notificationWidth: 380
    readonly property real calendarWidth: 268
    readonly property real notificationCenterWidth: 360
    readonly property real collapsedWidth: Math.max(88, clockView.implicitWidth + 28)

    readonly property real notificationHeight: 52
    readonly property real collapsedHeight: 42
    readonly property real calendarHeight: carousel.calendarCard.implicitHeight + 12
    readonly property real notificationCenterHeight: carousel.notificationCenterCard.implicitHeight + 12

    readonly property real targetWidth: isCenterExpanded
        ? (notificationCenterOpen ? notificationCenterWidth : calendarWidth)
        : (hasNotification ? notificationWidth : collapsedWidth)

    readonly property real targetHeight: isCenterExpanded
        ? (notificationCenterOpen ? notificationCenterHeight : calendarHeight)
        : (hasNotification ? notificationHeight : collapsedHeight)

    readonly property real targetRadius: (hasNotification && !isCenterExpanded) ? 20 : (isCenterExpanded ? 18 : 21)

    readonly property real triggerSpanWidth: 420
    readonly property real interactiveWidth: Math.max(targetWidth, triggerSpanWidth)
    readonly property real interactiveHeight: (isIslandActive || morphEngine.curOpacity > 0.01 || morphEngine.curY > -50)
        ? (isCenterExpanded
            ? (hasNotification ? (7 + morphEngine.curH + 10 + 52 + 14) : (7 + morphEngine.curH + 12))
            : (hasNotification ? (7 + 52 + Math.max(0, NotificationState.activeCount - 1) * 60 + 14) : (7 + morphEngine.curH + 12)))
        : 5

    implicitWidth: targetWidth
    implicitHeight: targetHeight
    width: implicitWidth
    height: implicitHeight

    // --- Actions ---
    function toggleCalendar() {
        if (BarState.centerPanel === "calendar") {
            closeCenter();
        } else {
            BarState.openCalendar();
            carousel.calendarCard.resetToToday();
        }
    }

    function toggleNotificationCenter() {
        if (BarState.centerPanel === "notifications") {
            closeCenter();
        } else {
            BarState.openNotificationCenter();
        }
    }

    function closeCenter() {
        BarState.closeCenter();
        if (!BarState.isPinned) {
            hideTimer.stop();
            centerIslandRoot.isRevealed = false;
        }
    }

    // --- Coordination & Pointer Tracking ---
    Connections {
        target: BarState
        function onCenterPanelChanged() {
            if (!BarState.centerExpanded && !BarState.isPinned) {
                hideTimer.stop();
                centerIslandRoot.isRevealed = false;
            }
        }
        function onIsPinnedChanged() {
            if (!BarState.isPinned) {
                if (!centerIslandRoot.hasAnyPointer && !centerIslandRoot.hasNotification) {
                    centerIslandRoot.isRevealed = false;
                    BarState.closeCenter();
                }
            }
        }
        function onIsFullscreenChanged() {
            if (BarState.isFullscreen) {
                centerIslandRoot.isRevealed = false;
                BarState.closeCenter();
            }
        }
    }

    Connections {
        target: NotificationState
        function onNotificationArrived(notiId) {
            if (centerIslandRoot.hasNotification) {
                morphEngine.physics.triggerShimmer();
            }
        }
        function onHasActiveNotificationChanged() {
            if (!NotificationState.hasActiveNotification && !BarState.isPinned) {
                if (!centerIslandRoot.hasAnyPointer) {
                    centerIslandRoot.isRevealed = false;
                } else {
                    hideTimer.restart();
                }
            }
        }
    }

    // 1. Wide top edge trigger for dynamic mode
    Item {
        id: edgeTriggerZone
        anchors.top: parent.top
        width: Math.max(centerIslandRoot.implicitWidth, centerIslandRoot.triggerSpanWidth)
        anchors.horizontalCenter: parent.horizontalCenter
        height: 5
        enabled: !BarState.isFullscreen

        HoverHandler {
            id: edgeHover
            cursorShape: Qt.ArrowCursor
            onHoveredChanged: {
                if (hovered && !BarState.isPinned && !BarState.isFullscreen) {
                    hideTimer.stop();
                    centerIslandRoot.isRevealed = true;
                }
            }
        }
    }

    // 2. Active capsule hover zone
    Item {
        id: activeHoverZone
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.max(morphEngine.curW, centerIslandRoot.triggerSpanWidth)
        height: centerIslandRoot.interactiveHeight
        enabled: centerIslandRoot.isIslandActive

        HoverHandler {
            id: fullHover
            cursorShape: Qt.ArrowCursor
        }
    }

    // 3. Grace close timer
    Timer {
        id: hideTimer
        interval: 220
        repeat: false
        onTriggered: {
            if (!BarState.isPinned && !edgeHover.hovered && !fullHover.hovered && !centerIslandRoot.isHovered && !centerIslandRoot.isCenterExpanded) {
                centerIslandRoot.isRevealed = false;
            }
        }
    }

    readonly property bool isHovered: islandHover.hovered || clockClickArea.containsMouse || NotificationState.isHovered
    readonly property bool hasAnyPointer: edgeHover.hovered || fullHover.hovered || isHovered || isCenterExpanded

    onHasAnyPointerChanged: {
        if (BarState.isPinned) return;
        if (hasAnyPointer && !BarState.isFullscreen) {
            hideTimer.stop();
            centerIslandRoot.isRevealed = true;
        } else {
            hideTimer.restart();
        }
    }

    onIsRevealedChanged: {
        if (!isRevealed && !hasNotification) {
            BarState.closeCenter();
        }
    }

    // --- Modular Island Animation & Morph Engine ---
    IslandMorphEngine {
        id: morphEngine
        targetWidth: centerIslandRoot.targetWidth
        targetHeight: centerIslandRoot.targetHeight
        targetRadius: centerIslandRoot.targetRadius
        isIslandActive: centerIslandRoot.isIslandActive
        isPinned: BarState.isPinned
    }

    // --- Animated Dynamic Island Capsule Container ---
    Item {
        id: capsuleContainer
        width: morphEngine.curW
        height: morphEngine.curH
        y: morphEngine.curY
        opacity: morphEngine.curOpacity
        anchors.horizontalCenter: parent.horizontalCenter

        transform: Scale {
            origin.x: capsuleContainer.width / 2
            origin.y: 21
            xScale: morphEngine.scaleX
            yScale: morphEngine.scaleY
        }

        // Monochromatic Frosted Glass Capsule Body
        Rectangle {
            id: capsulePill
            anchors.fill: parent
            radius: morphEngine.curRadius
            opacity: (centerIslandRoot.hasNotification && !centerIslandRoot.isCenterExpanded) ? 0.0 : 1.0
            visible: opacity > 0.01
            color: StyleTokens.glassBackground
            border.width: 1
            border.color: morphEngine.physics.pulseShimmer > 0.01
                ? Qt.rgba(1, 1, 1, 0.12 + 0.32 * morphEngine.physics.pulseShimmer)
                : ((centerIslandRoot.isHovered || centerIslandRoot.isCenterExpanded) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder)

            Behavior on opacity {
                NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
            }
            Behavior on border.color {
                ColorAnimation { duration: StyleTokens.animFast }
            }
        }

        HoverHandler { id: islandHover }

        // 1. Clock Capsule View
        Item {
            id: clockView
            anchors.top: parent.top
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: dateTimeWidget.implicitWidth
            implicitHeight: dateTimeWidget.implicitHeight
            width: implicitWidth
            height: implicitHeight

            readonly property bool shouldShowClock: (centerIslandRoot.isIslandActive && !centerIslandRoot.isCenterExpanded && !centerIslandRoot.hasNotification)
            opacity: shouldShowClock ? morphEngine.contentOpacity : 0.0
            scale: shouldShowClock ? morphEngine.contentScale : 0.85
            visible: opacity > 0.005

            Behavior on opacity {
                enabled: morphEngine.isFullyDisplayed
                NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
            }
            Behavior on scale {
                enabled: morphEngine.isFullyDisplayed
                NumberAnimation { duration: 220; easing.type: clockView.shouldShowClock ? Easing.OutBack : Easing.InQuad; easing.overshoot: 1.15 }
            }

            DateTimeWidget {
                id: dateTimeWidget
                anchors.centerIn: parent
            }
        }

        // Click Area to Expand Calendar (Left Click) or Notification Center (Right Click)
        MouseArea {
            id: clockClickArea
            anchors.fill: parent
            enabled: !centerIslandRoot.isCenterExpanded && !centerIslandRoot.hasNotification
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    centerIslandRoot.toggleNotificationCenter();
                } else {
                    centerIslandRoot.toggleCalendar();
                }
            }
        }

        // 2. Carousel Viewport
        CenterCarousel {
            id: carousel
            isExpanded: centerIslandRoot.isCenterExpanded
        }

        // 3. Notification Heads-Up Alert View
        Item {
            id: notificationCardContainer
            anchors.horizontalCenter: parent.horizontalCenter
            width: 380
            height: 52
            y: centerIslandRoot.isCenterExpanded ? (morphEngine.curH + 10) : 0
            opacity: (centerIslandRoot.hasNotification && !centerIslandRoot.notificationCenterOpen) ? 1.0 : 0.0
            scale: 1.0
            visible: opacity > 0.005

            Behavior on y {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
            }

            NotificationStack {
                id: notificationStack
                anchors.fill: parent
            }
        }
    }
}
