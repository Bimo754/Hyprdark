import QtQuick
import Quickshell
import Quickshell.Io
import "../.."

Rectangle {
    id: volumeMetricRoot
    height: 24
    width: volRow.implicitWidth + 8
    radius: StyleTokens.capsuleRadius
    anchors.verticalCenter: parent.verticalCenter
    color: volMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

    signal clicked()

    property int volumeLevel: 50
    property bool isMuted: false

    Row {
        id: volRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: volumeMetricRoot.isMuted ? "󰝟" : (volumeMetricRoot.volumeLevel > 50 ? "󰕾" : (volumeMetricRoot.volumeLevel > 0 ? "󰖀" : "󰕿"))
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 13
            color: StyleTokens.textSecondary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: volumeMetricRoot.volumeLevel + "%"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: StyleTokens.textPrimary
        }
    }

    MouseArea {
        id: volMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: volumeMetricRoot.clicked()
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                volUpProc.running = true
            } else if (wheel.angleDelta.y < 0) {
                volDownProc.running = true
            }
        }
    }

    Timer {
        id: volTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volProc.running = true
    }

    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100), ($3 == \"[MUTED]\" ? 1 : 0)}'"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(" ")
                if (parts.length >= 1) {
                    var lvl = parseInt(parts[0])
                    if (!isNaN(lvl)) volumeMetricRoot.volumeLevel = lvl
                }
                if (parts.length >= 2) {
                    volumeMetricRoot.isMuted = (parts[1] === "1")
                }
            }
        }
    }

    Process {
        id: volUpProc
        command: ["bash", "-c", "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"]
        stdout: SplitParser {
            onRead: data => {
                var lvl = parseInt(data.trim())
                if (!isNaN(lvl)) volumeMetricRoot.volumeLevel = lvl
            }
        }
    }

    Process {
        id: volDownProc
        command: ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"]
        stdout: SplitParser {
            onRead: data => {
                var lvl = parseInt(data.trim())
                if (!isNaN(lvl)) volumeMetricRoot.volumeLevel = lvl
            }
        }
    }
}
