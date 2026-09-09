import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import ".."
import "../components"

IslandCapsule {
    id: rightIslandRoot

    signal toggleControlCenterRequested()
    signal togglePowerRequested()

    property int cpuUsage: 0
    property string ramUsage: "0.0G"
    property int batteryPercent: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) : 100
    property bool isCharging: UPower.displayDevice ? UPower.displayDevice.state === UPowerDeviceState.Charging : false
    property int volumeLevel: 50

    implicitHeight: 38
    implicitWidth: rightRow.implicitWidth + 24

    Row {
        id: rightRow
        anchors.centerIn: parent
        spacing: 12

        // 1. CPU Metric
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 13
                color: StyleTokens.textSecondary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: rightIslandRoot.cpuUsage + "%"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: StyleTokens.textPrimary
            }
        }

        // Hairline Divider
        Rectangle {
            width: 1
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 2. RAM Metric
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰍛"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 13
                color: StyleTokens.textSecondary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: rightIslandRoot.ramUsage
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: StyleTokens.textPrimary
            }
        }

        // Hairline Divider
        Rectangle {
            width: 1
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 3. Audio Sink Metric
        Rectangle {
            id: audioButton
            height: 24
            width: audioRow.implicitWidth + 8
            radius: StyleTokens.capsuleRadius
            anchors.verticalCenter: parent.verticalCenter
            color: audioMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

            Row {
                id: audioRow
                anchors.centerIn: parent
                spacing: 5

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰕾"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 13
                    color: StyleTokens.textSecondary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: rightIslandRoot.volumeLevel + "%"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: StyleTokens.textPrimary
                }
            }

            MouseArea {
                id: audioMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: rightIslandRoot.toggleControlCenterRequested()
            }
        }

        // 4. Battery Metric (if available)
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5
            visible: UPower.displayDevice && UPower.displayDevice.isPresent

            Rectangle {
                width: 1
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                color: StyleTokens.hairlineDivider
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: rightIslandRoot.isCharging ? "󰂄" : "󰁹"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 13
                color: StyleTokens.textSecondary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: rightIslandRoot.batteryPercent + "%"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: StyleTokens.textPrimary
            }
        }

        // Hairline Divider
        Rectangle {
            width: 1
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 5. Control Center Trigger Button
        Rectangle {
            id: ccButton
            width: 24
            height: 24
            radius: StyleTokens.capsuleRadius
            anchors.verticalCenter: parent.verticalCenter
            color: ccMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

            Text {
                anchors.centerIn: parent
                text: "󰍜"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 14
                color: StyleTokens.textPrimary
            }

            MouseArea {
                id: ccMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: rightIslandRoot.toggleControlCenterRequested()
            }
        }

        // 6. Power Button
        Rectangle {
            id: powerButton
            width: 24
            height: 24
            radius: StyleTokens.capsuleRadius
            anchors.verticalCenter: parent.verticalCenter
            color: powerMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

            Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 13
                color: StyleTokens.textPrimary
            }

            MouseArea {
                id: powerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: rightIslandRoot.togglePowerRequested()
            }
        }
    }

    // System Metrics Polling Timer
    Timer {
        id: metricTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: metricProc.running = true
    }

    Process {
        id: metricProc
        command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}'; free -m | awk '/Mem:/ {printf \"%.1fG\", $3/1024}'; wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.trim().split("\n")
                if (lines.length >= 1 && lines[0].trim().length > 0) {
                    rightIslandRoot.cpuUsage = parseInt(lines[0].trim()) || 0
                }
                if (lines.length >= 2 && lines[1].trim().length > 0) {
                    rightIslandRoot.ramUsage = lines[1].trim()
                }
                if (lines.length >= 3 && lines[2].trim().length > 0) {
                    rightIslandRoot.volumeLevel = parseInt(lines[2].trim()) || 0
                }
            }
        }
    }
}
