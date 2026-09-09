import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"

Rectangle {
    id: audioDrawerRoot

    property bool isOpen: false
    signal closeRequested()

    property real volumeVal: 0.5
    property bool isMuted: false
    property string activeSinkName: "Default Output"

    width: 280
    implicitHeight: Math.min(220, audioColumn.implicitHeight + 28)
    radius: StyleTokens.cardRadius
    color: StyleTokens.cardBackground
    border.width: 1
    border.color: StyleTokens.hairlineBorder
    clip: true

    opacity: isOpen ? 1.0 : 0.0
    visible: opacity > 0.001
    scale: isOpen ? 1.0 : 0.96

    Behavior on opacity {
        NumberAnimation { duration: StyleTokens.animNormal; easing.type: Easing.OutQuad }
    }

    Behavior on scale {
        NumberAnimation { duration: StyleTokens.animNormal; easing.type: Easing.OutQuad }
    }

    Column {
        id: audioColumn
        width: parent.width - 28
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        spacing: 12

        // 1. Header Row
        Row {
            width: parent.width
            height: 22

            Text {
                text: "Sound Output"
                font.family: StyleTokens.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: StyleTokens.textPrimary
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: parent.width - 90 - muteBtn.width
                height: 1
            }

            // Mute Button
            Rectangle {
                id: muteBtn
                width: 24
                height: 24
                radius: StyleTokens.capsuleRadius
                color: audioDrawerRoot.isMuted ? StyleTokens.alertRed : (muteMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.surfaceSubtle)
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: audioDrawerRoot.isMuted ? "󰝟" : "󰕾"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 12
                    color: StyleTokens.textPrimary
                }

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        audioDrawerRoot.isMuted = !audioDrawerRoot.isMuted
                        muteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
                        muteProc.running = true
                    }
                }
            }
        }

        // 2. Active Output Device Pill
        Rectangle {
            width: parent.width
            height: 32
            radius: StyleTokens.buttonRadius
            color: StyleTokens.surfaceSubtle
            border.width: 1
            border.color: StyleTokens.hairlineDivider

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰓃"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 13
                    color: StyleTokens.textSecondary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: audioDrawerRoot.activeSinkName
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: StyleTokens.textPrimary
                    elide: Text.ElideRight
                    width: parent.width - 30
                }
            }
        }

        // 3. Main Volume Slider
        FrostedSlider {
            width: parent.width
            icon: audioDrawerRoot.isMuted ? "󰝟" : (audioDrawerRoot.volumeVal > 0.5 ? "󰕾" : (audioDrawerRoot.volumeVal > 0 ? "󰖀" : "󰕿"))
            label: "Volume"
            value: audioDrawerRoot.volumeVal
            onValueModified: newVal => {
                audioDrawerRoot.volumeVal = newVal
                volProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", String(newVal)]
                volProc.running = true
            }
        }
    }

    // Helper processes
    Process { id: muteProc }
    Process { id: volProc }

    // Status sync timer
    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: syncProc.running = true
    }

    Process {
        id: syncProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@; wpctl status | grep -A 2 -E 'Sinks:' | grep -E '\\*' | sed -E 's/.*\\*\\s+[0-9]+\\.\\s+(.*)\\[.*/\\1/' || echo 'Default Audio'"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.trim().split("\n")
                if (lines.length >= 1) {
                    var volLine = lines[0]
                    audioDrawerRoot.isMuted = volLine.includes("[MUTED]")
                    var parts = volLine.replace("[MUTED]", "").trim().split(" ")
                    if (parts.length >= 2) {
                        audioDrawerRoot.volumeVal = parseFloat(parts[1]) || 0.5
                    }
                }
                if (lines.length >= 2 && lines[1].trim().length > 0) {
                    audioDrawerRoot.activeSinkName = lines[1].trim()
                }
            }
        }
    }
}
