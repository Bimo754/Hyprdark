import QtQuick
import Quickshell
import Quickshell.Io
import "../.."

Row {
    id: memMetricRoot
    anchors.verticalCenter: parent.verticalCenter
    spacing: 5

    property string ramUsage: "0.0G"

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "󰍛"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 13
        color: StyleTokens.textSecondary
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: memMetricRoot.ramUsage
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 11
        font.weight: Font.Medium
        color: StyleTokens.textPrimary
    }

    Timer {
        id: memTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: memProc.running = true
    }

    Process {
        id: memProc
        command: ["bash", "-c", "free -m | awk '/Mem:/ {printf \"%.1fG\", $3/1024}'"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim()
                if (str.length > 0) {
                    memMetricRoot.ramUsage = str
                }
            }
        }
    }
}
