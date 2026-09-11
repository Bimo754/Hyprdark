import QtQuick
import Quickshell
import ".."
import "../engine"
import "../modules/center"

Item {
    id: centerIslandRoot

    // --- State & Target Dimensions ---
    readonly property bool hasNotification: NotificationState.hasActiveNotification
    readonly property bool calendarOpen: BarState.calendarOpen && !hasNotification
    property bool isRevealed: false
    readonly property bool isIslandActive: BarState.isPinned || isRevealed || calendarOpen || hasNotification

    readonly property real circleSize: 42
    readonly property real notificationWidth: 380
    readonly property real expandedWidth: 268
    readonly property real collapsedWidth: Math.max(88, clockView.implicitWidth + 28)

    readonly property real notificationHeight: 52
    readonly property real collapsedHeight: 42
    readonly property real expandedHeight: calendarCard.implicitHeight + 12

    readonly property real targetWidth: hasNotification ? notificationWidth : (calendarOpen ? expandedWidth : collapsedWidth)
    readonly property real targetHeight: hasNotification ? notificationHeight : (calendarOpen ? expandedHeight : collapsedHeight)
    readonly property real targetRadius: hasNotification ? 20 : (calendarOpen ? 18 : 21)

    readonly property real triggerSpanWidth: 420
    readonly property real interactiveWidth: Math.max(targetWidth, triggerSpanWidth)
    readonly property real interactiveHeight: (isIslandActive || morphEngine.curOpacity > 0.01 || morphEngine.curY > -50) ? (7 + morphEngine.curH + 12) : 5

    implicitWidth: targetWidth
    implicitHeight: targetHeight
    width: implicitWidth
    height: implicitHeight

    // --- Actions ---
    function toggleCalendar() {
        if (BarState.calendarOpen) {
            closeCalendar();
        } else {
            BarState.calendarOpen = true;
            calendarCard.resetToToday();
        }
    }

    function closeCalendar() {
        BarState.calendarOpen = false;
        if (!BarState.isPinned) {
            hideTimer.stop();
            centerIslandRoot.isRevealed = false;
        }
    }

    // --- Coordination & Pointer Tracking ---
    Connections {
        target: BarState
        function onCalendarOpenChanged() {
            if (!BarState.calendarOpen && !BarState.isPinned) {
                hideTimer.stop();
                centerIslandRoot.isRevealed = false;
            }
        }
        function onIsPinnedChanged() {
            if (!BarState.isPinned) {
                if (!centerIslandRoot.hasAnyPointer && !centerIslandRoot.hasNotification) {
                    centerIslandRoot.isRevealed = false;
                    BarState.calendarOpen = false;
                }
            }
        }
    }

    Connections {
        target: NotificationState
        function onHasActiveNotificationChanged() {
            if (!NotificationState.hasActiveNotification && !BarState.isPinned) {
                if (!centerIslandRoot.hasAnyPointer) {
                    centerIslandRoot.isRevealed = false;
                } else {
                    hideTimer.restart();
                }
            }
        }
        function onNotificationArrived(totalCount) {
            if (centerIslandRoot.hasNotification) {
                morphEngine.physics.triggerShimmer();
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

        HoverHandler {
            id: edgeHover
            cursorShape: Qt.ArrowCursor
            onHoveredChanged: {
                if (hovered && !BarState.isPinned) {
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
            if (!BarState.isPinned && !edgeHover.hovered && !fullHover.hovered && !centerIslandRoot.isHovered && !centerIslandRoot.calendarOpen) {
                centerIslandRoot.isRevealed = false;
            }
        }
    }

    readonly property bool isHovered: islandHover.hovered || clockClickArea.containsMouse
    readonly property bool hasAnyPointer: edgeHover.hovered || fullHover.hovered || isHovered || calendarOpen

    onHasAnyPointerChanged: {
        if (BarState.isPinned) return;
        if (hasAnyPointer) {
            hideTimer.stop();
            centerIslandRoot.isRevealed = true;
        } else {
            hideTimer.restart();
        }
    }

    onIsRevealedChanged: {
        if (!isRevealed && !hasNotification) {
            BarState.calendarOpen = false;
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
            color: StyleTokens.glassBackground
            border.width: 1
            border.color: morphEngine.physics.pulseShimmer > 0.01
                ? Qt.rgba(1, 1, 1, 0.12 + 0.32 * morphEngine.physics.pulseShimmer)
                : ((centerIslandRoot.isHovered || centerIslandRoot.calendarOpen || centerIslandRoot.hasNotification) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder)

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

            readonly property bool shouldShowClock: (centerIslandRoot.isIslandActive && !centerIslandRoot.calendarOpen && !centerIslandRoot.hasNotification)
            opacity: shouldShowClock ? morphEngine.contentOpacity : 0.0
            scale: shouldShowClock ? morphEngine.contentScale : 0.85
            visible: opacity > 0.005

            Behavior on opacity {
                enabled: morphEngine.isFullyDisplayed
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on scale {
                enabled: morphEngine.isFullyDisplayed
                NumberAnimation {
                    duration: 180
                    easing.type: clockView.shouldShowClock ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.15
                }
            }

            DateTimeWidget {
                id: dateTimeWidget
                anchors.centerIn: parent
            }
        }

        // Click Area to Expand Calendar
        MouseArea {
            id: clockClickArea
            anchors.fill: parent
            enabled: !centerIslandRoot.calendarOpen && !centerIslandRoot.hasNotification
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: centerIslandRoot.toggleCalendar()
        }

        // --- 2. Calendar View ---
        Item {
            id: calendarCardContainer
            anchors.fill: parent
            clip: true
            opacity: centerIslandRoot.calendarOpen ? 1.0 : 0.0
            scale: centerIslandRoot.calendarOpen ? 1.0 : 0.94
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: centerIslandRoot.calendarOpen ? 180 : 70
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: centerIslandRoot.calendarOpen ? 240 : 100
                    easing.type: centerIslandRoot.calendarOpen ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.10
                }
            }

            CalendarCard {
                id: calendarCard
                anchors.fill: parent
            }
        }

        // --- 3. Notification View ---
        Item {
            id: notificationCardContainer
            anchors.fill: parent
            clip: true
            opacity: centerIslandRoot.hasNotification ? 1.0 : 0.0
            scale: centerIslandRoot.hasNotification ? 1.0 : 0.85
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: centerIslandRoot.hasNotification ? 200 : 100
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: centerIslandRoot.hasNotification ? 260 : 140
                    easing.type: centerIslandRoot.hasNotification ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.12
                }
            }

            NotificationPill {
                id: notificationPill
                anchors.fill: parent
            }
        }
    }
}
