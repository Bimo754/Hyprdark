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
    readonly property real calendarHeight: calendarCard.implicitHeight + 12
    readonly property real notificationCenterHeight: notificationCenterCard.implicitHeight + 12

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
            calendarCard.resetToToday();
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

    // --- Carousel Track Progress Control ---
    // 0.0 = Calendar, 1.0 = Notification Center
    property real targetProgress: (BarState.centerPanel === "notifications") ? 1.0 : 0.0
    property real currentProgress: targetProgress
    property real dragDistanceX: 0.0
    property bool isDragging: false

    onTargetProgressChanged: {
        if (!isDragging) {
            progressAnim.to = targetProgress;
            progressAnim.restart();
        }
    }

    NumberAnimation {
        id: progressAnim
        target: centerIslandRoot
        property: "currentProgress"
        duration: 320
        easing.type: Easing.OutCubic
    }

    // --- Coordination & Pointer Tracking ---
    Connections {
        target: BarState
        function onCenterPanelChanged() {
            if (!centerIslandRoot.isDragging) {
                let target = (BarState.centerPanel === "notifications") ? 1.0 : 0.0;
                progressAnim.to = target;
                progressAnim.restart();
            }
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
            id: islandScale
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

        HoverHandler {
            id: islandHover
        }

        // --- 1. Clock Capsule View ---
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
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on scale {
                enabled: morphEngine.isFullyDisplayed
                NumberAnimation {
                    duration: 220
                    easing.type: clockView.shouldShowClock ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.15
                }
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

        // --- 2. Multi-Panel Continuous Carousel Viewport (Calendar <-> Notification Center) ---
        Item {
            id: expandedPanelsViewport
            anchors.fill: parent
            clip: true
            opacity: centerIslandRoot.isCenterExpanded ? 1.0 : 0.0
            scale: centerIslandRoot.isCenterExpanded ? 1.0 : 0.92
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: centerIslandRoot.isCenterExpanded ? 200 : 150
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: centerIslandRoot.isCenterExpanded ? 260 : 180
                    easing.type: centerIslandRoot.isCenterExpanded ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.10
                }
            }

            DragHandler {
                id: swipeHandler
                target: null
                enabled: centerIslandRoot.isCenterExpanded
                xAxis.enabled: true
                yAxis.enabled: false
                dragThreshold: 10

                onActiveChanged: {
                    if (active) {
                        progressAnim.stop();
                        centerIslandRoot.isDragging = true;
                        centerIslandRoot.dragDistanceX = 0;
                    } else {
                        centerIslandRoot.isDragging = false;
                        let delta = centerIslandRoot.dragDistanceX;
                        let baseProg = (BarState.centerPanel === "notifications") ? 1.0 : 0.0;

                        if (baseProg === 0.0 && (delta < -28 || centerIslandRoot.currentProgress > 0.25)) {
                            BarState.openNotificationCenter();
                        } else if (baseProg === 1.0 && (delta > 28 || centerIslandRoot.currentProgress < 0.75)) {
                            BarState.openCalendar();
                        } else {
                            progressAnim.to = baseProg;
                            progressAnim.restart();
                        }
                        centerIslandRoot.dragDistanceX = 0;
                    }
                }

                onTranslationChanged: {
                    if (active) {
                        let raw = swipeHandler.translation.x;
                        centerIslandRoot.dragDistanceX = raw;
                        let baseProg = (BarState.centerPanel === "notifications") ? 1.0 : 0.0;
                        let span = Math.max(220, expandedPanelsViewport.width);

                        let p = baseProg - (raw / span);
                        if (p < 0) p = p * 0.20;
                        if (p > 1) p = 1 + (p - 1) * 0.20;
                        centerIslandRoot.currentProgress = p;
                    }
                }
            }

            // Panel A: Calendar Card (Page 0)
            Item {
                id: calendarPanelWrapper
                width: parent.width
                height: parent.height
                x: -centerIslandRoot.currentProgress * parent.width
                opacity: Math.max(0.0, Math.min(1.0, 1.0 - centerIslandRoot.currentProgress * 1.5))
                scale: 1.0 - 0.05 * Math.max(0.0, Math.min(1.0, centerIslandRoot.currentProgress))

                CalendarCard {
                    id: calendarCard
                    anchors.centerIn: parent
                }
            }

            // Panel B: Notification Center Card (Page 1)
            Item {
                id: notificationCenterWrapper
                width: parent.width
                height: parent.height
                x: (1.0 - centerIslandRoot.currentProgress) * parent.width
                opacity: Math.max(0.0, Math.min(1.0, (centerIslandRoot.currentProgress - 0.15) * 1.25))
                scale: 0.95 + 0.05 * Math.max(0.0, Math.min(1.0, centerIslandRoot.currentProgress))

                NotificationCenterCard {
                    id: notificationCenterCard
                    anchors.centerIn: parent
                }
            }

            // Page Indicator Navigation Pills at Bottom
            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                visible: centerIslandRoot.isCenterExpanded
                opacity: centerIslandRoot.isCenterExpanded ? 0.75 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                // Calendar Indicator Pill
                Rectangle {
                    width: centerIslandRoot.currentProgress < 0.5 ? 16 : 6
                    height: 5
                    radius: 2.5
                    color: centerIslandRoot.currentProgress < 0.5 ? StyleTokens.textPrimary : StyleTokens.surfaceActive

                    Behavior on width {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BarState.openCalendar()
                    }
                }

                // Notifications Indicator Pill
                Rectangle {
                    width: centerIslandRoot.currentProgress >= 0.5 ? 16 : 6
                    height: 5
                    radius: 2.5
                    color: centerIslandRoot.currentProgress >= 0.5 ? StyleTokens.textPrimary : StyleTokens.surfaceActive

                    Behavior on width {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BarState.openNotificationCenter()
                    }
                }
            }
        }

        // --- 3. Notification Heads-Up Alert View (Unified Stack) ---
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
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutQuad
                }
            }

            NotificationStack {
                id: notificationStack
                anchors.fill: parent
            }
        }
    }
}
