import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"
import "controlcenter"

Rectangle {
    id: ccRoot

    property bool isOpen: false
    signal closeRequested()

    property real volumeVal: 0.5
    property real brightnessVal: 0.8

    width: 320
    implicitHeight: Math.min(380, ccColumn.implicitHeight + 32)
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
        id: ccColumn
        width: parent.width - 32
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 16
        spacing: 14

        ControlCenterHeader {
            width: parent.width
        }

        QuickToggleGrid {
            id: toggleGrid
            width: parent.width
        }

        Rectangle {
            width: parent.width
            height: 1
            color: StyleTokens.hairlineDivider
        }

        FrostedSlider {
            width: parent.width
            icon: "󰕾"
            label: "Volume"
            value: ccRoot.volumeVal
            onValueModified: newVal => {
                ccRoot.volumeVal = newVal
                volSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", String(newVal)]
                volSetProc.running = true
            }
        }

        FrostedSlider {
            width: parent.width
            icon: "󰃠"
            label: "Display Backlight"
            value: ccRoot.brightnessVal
            onValueModified: newVal => {
                ccRoot.brightnessVal = newVal
                brightSetProc.command = ["brightnessctl", "set", Math.round(newVal * 100) + "%"]
                brightSetProc.running = true
            }
        }
    }

    Process { id: volSetProc }
    Process { id: brightSetProc }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    Process {
        id: statusProc
        command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2 || echo ''; wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'; brightnessctl -m | cut -d, -f4 | tr -d '%' || echo '80'"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.trim().split("\n")
                if (lines.length >= 1 && lines[0].trim().length > 0) {
                    toggleGrid.wifiSsid = lines[0].trim()
                    toggleGrid.wifiEnabled = true
                }
                if (lines.length >= 2 && lines[1].trim().length > 0) {
                    ccRoot.volumeVal = parseFloat(lines[1].trim()) || 0.5
                }
                if (lines.length >= 3 && lines[2].trim().length > 0) {
                    ccRoot.brightnessVal = (parseFloat(lines[2].trim()) || 80) / 100.0
                }
            }
        }
    }
}
