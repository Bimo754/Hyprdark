import QtQuick
import "../.."

Item {
    id: carouselRoot
    anchors.fill: parent
    clip: true

    required property bool isExpanded
    property real currentProgress: (BarState.centerPanel === "notifications") ? 1.0 : 0.0
    property bool isDragging: false
    property real dragDistanceX: 0.0

    readonly property alias calendarCard: calendarCard
    readonly property alias notificationCenterCard: notificationCenterCard

    property string activePanelState: "none"

    Connections {
        target: BarState
        function onCenterPanelChanged() {
            let newPanel = BarState.centerPanel;
            if (newPanel === "none") {
                // Collapsing back to island: keep currentProgress locked in place
                progressAnim.stop();
                carouselRoot.activePanelState = "none";
            } else if (carouselRoot.activePanelState === "none") {
                // Opening fresh from island: snap currentProgress directly so NO panel sliding occurs
                progressAnim.stop();
                carouselRoot.currentProgress = (newPanel === "notifications") ? 1.0 : 0.0;
                carouselRoot.activePanelState = newPanel;
            } else if (carouselRoot.activePanelState !== newPanel) {
                // Switching panels while island is already open: animate horizontal slide
                carouselRoot.activePanelState = newPanel;
                if (!carouselRoot.isDragging) {
                    progressAnim.to = (newPanel === "notifications") ? 1.0 : 0.0;
                    progressAnim.restart();
                }
            }
        }
    }

    property real islandExpandProgress: isExpanded ? 1.0 : 0.0

    Behavior on islandExpandProgress {
        NumberAnimation {
            duration: carouselRoot.isExpanded ? 240 : 160
            easing.type: carouselRoot.isExpanded ? Easing.OutBack : Easing.InQuad
            easing.overshoot: 1.10
        }
    }

    NumberAnimation {
        id: progressAnim
        target: carouselRoot
        property: "currentProgress"
        duration: 320
        easing.type: Easing.OutCubic
    }

    opacity: isExpanded ? 1.0 : 0.0
    scale: isExpanded ? 1.0 : 0.92
    visible: opacity > 0.01

    Behavior on opacity {
        NumberAnimation { duration: carouselRoot.isExpanded ? 200 : 150; easing.type: Easing.OutQuad }
    }
    Behavior on scale {
        NumberAnimation { duration: carouselRoot.isExpanded ? 260 : 180; easing.type: carouselRoot.isExpanded ? Easing.OutBack : Easing.InQuad; easing.overshoot: 1.10 }
    }

    DragHandler {
        id: swipeHandler
        target: null
        enabled: carouselRoot.isExpanded
        xAxis.enabled: true
        yAxis.enabled: false
        dragThreshold: 10

        onActiveChanged: {
            if (active) {
                progressAnim.stop();
                carouselRoot.isDragging = true;
                carouselRoot.dragDistanceX = 0;
            } else {
                carouselRoot.isDragging = false;
                let delta = carouselRoot.dragDistanceX;
                let baseProg = (BarState.centerPanel === "notifications") ? 1.0 : 0.0;

                if (baseProg === 0.0 && (delta < -28 || carouselRoot.currentProgress > 0.25)) {
                    BarState.openNotificationCenter();
                } else if (baseProg === 1.0 && (delta > 28 || carouselRoot.currentProgress < 0.75)) {
                    BarState.openCalendar();
                } else {
                    progressAnim.to = baseProg;
                    progressAnim.restart();
                }
                carouselRoot.dragDistanceX = 0;
            }
        }

        onTranslationChanged: {
            if (active) {
                let raw = swipeHandler.translation.x;
                carouselRoot.dragDistanceX = raw;
                let baseProg = (BarState.centerPanel === "notifications") ? 1.0 : 0.0;
                let span = Math.max(220, carouselRoot.width);
                let p = baseProg - (raw / span);
                if (p < 0) p = p * 0.20;
                if (p > 1) p = 1 + (p - 1) * 0.20;
                carouselRoot.currentProgress = p;
            }
        }
    }

    // Panel A: Calendar Card
    Item {
        id: calendarPanelWrapper
        width: parent.width
        height: parent.height
        x: -carouselRoot.currentProgress * parent.width
        opacity: Math.max(0.0, Math.min(1.0, 1.0 - carouselRoot.currentProgress * 1.5))
        scale: 1.0 - 0.05 * Math.max(0.0, Math.min(1.0, carouselRoot.currentProgress))
        visible: opacity > 0.001

        CalendarCard {
            id: calendarCard
            anchors.centerIn: parent
            expandProgress: carouselRoot.islandExpandProgress
        }
    }

    // Panel B: Notification Center Card
    Item {
        id: notificationCenterWrapper
        width: parent.width
        height: parent.height
        x: (1.0 - carouselRoot.currentProgress) * parent.width
        opacity: Math.max(0.0, Math.min(1.0, (carouselRoot.currentProgress - 0.15) * 1.25))
        scale: 0.95 + 0.05 * Math.max(0.0, Math.min(1.0, carouselRoot.currentProgress))
        visible: opacity > 0.001

        NotificationCenterCard {
            id: notificationCenterCard
            anchors.centerIn: parent
            expandProgress: carouselRoot.islandExpandProgress
        }
    }

    // Page Indicator Navigation Pills
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6
        visible: carouselRoot.isExpanded
        opacity: carouselRoot.isExpanded ? 0.75 : 0.0

        Behavior on opacity { NumberAnimation { duration: 150 } }

        Rectangle {
            width: carouselRoot.currentProgress < 0.5 ? 16 : 6
            height: 5
            radius: 2.5
            color: carouselRoot.currentProgress < 0.5 ? StyleTokens.textPrimary : StyleTokens.surfaceActive

            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: BarState.openCalendar()
            }
        }

        Rectangle {
            width: carouselRoot.currentProgress >= 0.5 ? 16 : 6
            height: 5
            radius: 2.5
            color: carouselRoot.currentProgress >= 0.5 ? StyleTokens.textPrimary : StyleTokens.surfaceActive

            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: BarState.openNotificationCenter()
            }
        }
    }
}
