import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import ".."
import "../modules/center/resting"
import "../modules/center/calendar"
import "../modules/center/notifications"

Rectangle {
    id: centerIslandRoot

    property bool isExpanded: false
    property string islandState: "clock"
    property var activePlayer: (Mpris.players.values && Mpris.players.values.length > 0) ? Mpris.players.values[0] : null
    property bool hasMedia: activePlayer !== null && (activePlayer.playbackState === MprisPlaybackState.Playing || activePlayer.playbackState === MprisPlaybackState.Paused)
    property var notificationList: []

    // Geometry Morphing
    width: isExpanded ? 580 : (restingLoader.item ? Math.max(220, restingLoader.item.implicitWidth + 32) : 230)
    height: isExpanded ? 330 : 42
    radius: isExpanded ? StyleTokens.cardRadius : StyleTokens.capsuleRadius
    color: StyleTokens.glassBackground
    border.width: 1
    border.color: (isExpanded || hoverMouse.containsMouse) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
    clip: true

    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on radius { NumberAnimation { duration: 240; easing.type: Easing.OutQuad } }
    Behavior on border.color { ColorAnimation { duration: StyleTokens.animFast } }

    // 1. RESTING STATE
    Item {
        id: restingContainer
        anchors.fill: parent
        opacity: centerIslandRoot.isExpanded ? 0.0 : 1.0
        visible: opacity > 0.001
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

        Loader {
            id: restingLoader
            anchors.centerIn: parent
            sourceComponent: {
                if (centerIslandRoot.islandState === "mpris" && centerIslandRoot.hasMedia) return mprisComp
                if (centerIslandRoot.islandState === "timer") return timerComp
                if (centerIslandRoot.islandState === "osd") return osdComp
                if (centerIslandRoot.islandState === "notification") return notifComp
                return clockComp
            }
        }

        Component { id: clockComp; RestingClock {} }
        Component { id: mprisComp; RestingMpris {} }
        Component { id: timerComp; RestingTimer { onCancelRequested: centerIslandRoot.islandState = "clock" } }
        Component { id: osdComp; RestingOsd {} }
        Component { id: notifComp; RestingNotifBanner {} }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: centerIslandRoot.toggleExpand()
        }
    }

    // 2. EXPANDED STATE (Dual-Pane)
    Row {
        id: expandedContainer
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14
        opacity: centerIslandRoot.isExpanded ? 1.0 : 0.0
        visible: opacity > 0.001
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }

        AppleCalendarPane {
            id: calendarPane
        }

        Rectangle {
            width: 1
            height: parent.height
            color: StyleTokens.hairlineDivider
        }

        NotificationDeckPane {
            id: notiPane
            width: parent.width - calendarPane.width - 29
            notificationList: centerIslandRoot.notificationList
            onCloseRequested: centerIslandRoot.toggleExpand()
            onClearAllRequested: centerIslandRoot.notificationList = []
            onDismissRequested: function(idx) {
                var updated = []
                for (var i = 0; i < centerIslandRoot.notificationList.length; i++) {
                    if (i !== idx) updated.push(centerIslandRoot.notificationList[i])
                }
                centerIslandRoot.notificationList = updated
            }
        }
    }

    MouseArea {
        id: hoverMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    function toggleExpand() {
        centerIslandRoot.isExpanded = !centerIslandRoot.isExpanded
    }

    function addNotification(app, title, body) {
        var list = centerIslandRoot.notificationList.slice()
        list.unshift({ app: app, title: title, body: body, time: new Date() })
        if (list.length > 20) list.pop()
        centerIslandRoot.notificationList = list
        if (!centerIslandRoot.isExpanded) {
            centerIslandRoot.islandState = "notification"
            notifTimer.restart()
        }
    }

    Timer {
        id: notifTimer
        interval: 4000
        onTriggered: {
            if (centerIslandRoot.islandState === "notification") {
                centerIslandRoot.islandState = "clock"
            }
        }
    }
}
