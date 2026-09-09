import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import ".."
import "../components"

IslandCapsule {
    id: centerIslandRoot

    signal toggleCenterDrawerRequested()

    property string currentTime: Qt.formatDateTime(new Date(), "hh:mm:ss")
    property string currentDate: Qt.formatDateTime(new Date(), "ddd MMM dd")

    // Dynamic Island State: "clock" | "mpris" | "timer" | "osd" | "notification"
    property string islandState: "clock"
    property var activePlayer: (Mpris.players.values && Mpris.players.values.length > 0) ? Mpris.players.values[0] : null
    property bool hasMedia: activePlayer !== null && (activePlayer.playbackState === MprisPlaybackState.Playing || activePlayer.playbackState === MprisPlaybackState.Paused)

    // Notification banner state
    property string notifTitle: ""
    property string notifBody: ""
    property string notifApp: ""

    // Timer state
    property int timerSecondsRemaining: 0
    property bool timerActive: false

    // OSD state
    property string osdIcon: "󰕾"
    property int osdValue: 50

    implicitHeight: 38
    implicitWidth: mainContentLoader.item ? Math.max(180, mainContentLoader.item.implicitWidth + 28) : 220
    animateSize: true

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            centerIslandRoot.currentTime = Qt.formatDateTime(new Date(), "hh:mm:ss")
            centerIslandRoot.currentDate = Qt.formatDateTime(new Date(), "ddd MMM dd")

            if (centerIslandRoot.timerActive && centerIslandRoot.timerSecondsRemaining > 0) {
                centerIslandRoot.timerSecondsRemaining--
                if (centerIslandRoot.timerSecondsRemaining === 0) {
                    centerIslandRoot.timerActive = false
                    centerIslandRoot.triggerNotificationBanner("Timer", "Time is up!", "󰔛")
                }
            }
        }
    }

    // Main Content Switcher
    Loader {
        id: mainContentLoader
        anchors.centerIn: parent

        sourceComponent: {
            if (centerIslandRoot.islandState === "mpris" && centerIslandRoot.hasMedia) return mprisComponent
            if (centerIslandRoot.islandState === "timer" && centerIslandRoot.timerActive) return timerComponent
            if (centerIslandRoot.islandState === "osd") return osdComponent
            if (centerIslandRoot.islandState === "notification") return notifComponent
            return clockComponent
        }
    }

    // 1. Clock Component (Standard Hyprdark Monochromatic Island)
    Component {
        id: clockComponent

        Row {
            spacing: 12
            anchors.verticalCenter: parent.verticalCenter

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰸗"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 13
                    color: StyleTokens.textSecondary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: centerIslandRoot.currentDate
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: StyleTokens.textPrimary
                }
            }

            Rectangle {
                width: 1
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                color: StyleTokens.hairlineDivider
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 13
                    color: StyleTokens.textSecondary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: centerIslandRoot.currentTime
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: StyleTokens.textPrimary
                }
            }
        }
    }

    // 2. MPRIS Media Component
    Component {
        id: mprisComponent

        Row {
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰎆"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 13
                color: StyleTokens.textSecondary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: centerIslandRoot.activePlayer ? (centerIslandRoot.activePlayer.trackTitle || "Playing") : ""
                font.family: StyleTokens.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                color: StyleTokens.textPrimary
                elide: Text.ElideRight
                width: Math.min(140, implicitWidth)
            }

            // Play / Pause Button
            Rectangle {
                width: 22
                height: 22
                radius: StyleTokens.capsuleRadius
                anchors.verticalCenter: parent.verticalCenter
                color: playMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

                Text {
                    anchors.centerIn: parent
                    text: centerIslandRoot.activePlayer && centerIslandRoot.activePlayer.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 11
                    color: StyleTokens.textPrimary
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (centerIslandRoot.activePlayer) {
                            centerIslandRoot.activePlayer.playPause()
                        }
                    }
                }
            }
        }
    }

    // 3. Timer Component
    Component {
        id: timerComponent

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰔛"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 13
                color: StyleTokens.textSecondary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    var m = Math.floor(centerIslandRoot.timerSecondsRemaining / 60)
                    var s = centerIslandRoot.timerSecondsRemaining % 60
                    return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
                }
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 12
                font.weight: Font.Bold
                color: StyleTokens.textPrimary
            }
        }
    }

    // 4. Notification Pill Component
    Component {
        id: notifComponent

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰂚"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 13
                color: StyleTokens.textPrimary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: centerIslandRoot.notifTitle
                font.family: StyleTokens.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                color: StyleTokens.textPrimary
                elide: Text.ElideRight
                width: Math.min(180, implicitWidth)
            }
        }
    }

    // 5. OSD Pill Component
    Component {
        id: osdComponent

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: centerIslandRoot.osdIcon
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 13
                color: StyleTokens.textSecondary
            }

            Rectangle {
                width: 80
                height: 6
                radius: 3
                color: StyleTokens.surfaceSubtle
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    height: parent.height
                    width: parent.width * Math.max(0, Math.min(1, centerIslandRoot.osdValue / 100))
                    radius: 3
                    color: StyleTokens.textPrimary
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: centerIslandRoot.osdValue + "%"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 11
                color: StyleTokens.textPrimary
            }
        }
    }

    // Mouse Interaction: Clicking toggles center calendar dropdown or cycles mode
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            centerIslandRoot.toggleCenterDrawerRequested()
        }
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                if (centerIslandRoot.hasMedia && centerIslandRoot.islandState !== "mpris") {
                    centerIslandRoot.islandState = "mpris"
                } else if (centerIslandRoot.timerActive && centerIslandRoot.islandState !== "timer") {
                    centerIslandRoot.islandState = "timer"
                } else {
                    centerIslandRoot.islandState = "clock"
                }
            } else {
                centerIslandRoot.islandState = "clock"
            }
        }
    }

    // Helper functions for external events
    function triggerNotificationBanner(app, title, body) {
        centerIslandRoot.notifApp = app
        centerIslandRoot.notifTitle = title
        centerIslandRoot.notifBody = body
        centerIslandRoot.islandState = "notification"
        notifBannerTimer.restart()
    }

    function triggerOsd(icon, value) {
        centerIslandRoot.osdIcon = icon
        centerIslandRoot.osdValue = value
        centerIslandRoot.islandState = "osd"
        osdTimer.restart()
    }

    function startTimer(minutes) {
        centerIslandRoot.timerSecondsRemaining = minutes * 60
        centerIslandRoot.timerActive = true
        centerIslandRoot.islandState = "timer"
    }

    Timer {
        id: notifBannerTimer
        interval: 4000
        onTriggered: {
            if (centerIslandRoot.islandState === "notification") {
                centerIslandRoot.islandState = "clock"
            }
        }
    }

    Timer {
        id: osdTimer
        interval: 2000
        onTriggered: {
            if (centerIslandRoot.islandState === "osd") {
                centerIslandRoot.islandState = "clock"
            }
        }
    }
}
