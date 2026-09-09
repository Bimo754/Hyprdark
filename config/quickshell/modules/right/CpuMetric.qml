import QtQuick
import Quickshell
import Quickshell.Io
import "../.."

Row {
    id: cpuMetricRoot
    anchors.verticalCenter: parent.verticalCenter
    spacing: 5

    property int cpuPercent: 0

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: ""
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 13
        color: StyleTokens.textSecondary
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: cpuMetricRoot.cpuPercent + "%"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 11
        font.weight: Font.Medium
        color: StyleTokens.textPrimary
    }

    Timer {
        id: cpuTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: cpuProc.running = true
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}'"]
        stdout: SplitParser {
            onRead: data => {
                var val = parseInt(data.trim())
                if (!isNaN(val)) {
                    cpuMetricRoot.cpuPercent = val
                }
            }
        }
    }
}
