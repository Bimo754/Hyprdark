import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"
import "audio"

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

    Behavior on opacity { NumberAnimation { duration: StyleTokens.animNormal; easing.type: Easing.OutQuad } }
    Behavior on scale { NumberAnimation { duration: StyleTokens.animNormal; easing.type: Easing.OutQuad } }

    Column {
        id: audioColumn
        width: parent.width - 28
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        spacing: 12

        AudioHeader {
            width: parent.width
            isMuted: audioDrawerRoot.isMuted
            onToggleMuteClicked: {
                audioDrawerRoot.isMuted = !audioDrawerRoot.isMuted
                muteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
                muteProc.running = true
            }
        }

        AudioDeviceCard {
            width: parent.width
            sinkName: audioDrawerRoot.activeSinkName
        }

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

    Process { id: muteProc }
    Process { id: volProc }

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
