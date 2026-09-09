import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import "../.."

Row {
    id: wsListRoot
    spacing: 4
    anchors.verticalCenter: parent.verticalCenter

    property int activeWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property var workspaceModel: [1, 2, 3, 4, 5]

    Repeater {
        model: wsListRoot.workspaceModel

        Rectangle {
            id: wsPill
            width: 26
            height: 26
            radius: StyleTokens.capsuleRadius
            anchors.verticalCenter: parent.verticalCenter

            readonly property int wsNumber: modelData
            readonly property bool isActive: wsListRoot.activeWsId === wsNumber
            color: isActive ? StyleTokens.activePill : (wsMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent)

            Behavior on color {
                ColorAnimation { duration: StyleTokens.animFast }
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                text: String(wsPill.wsNumber)
                font.family: StyleTokens.fontFamily
                font.pixelSize: 12
                font.weight: wsPill.isActive ? Font.Bold : Font.DemiBold
                color: wsPill.isActive ? StyleTokens.activePillText : (wsMouse.containsMouse ? StyleTokens.textPrimary : StyleTokens.textSecondary)
            }

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: wsClickProc.running = true
                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        wsPrevProc.running = true
                    } else if (wheel.angleDelta.y < 0) {
                        wsNextProc.running = true
                    }
                }
            }

            Process {
                id: wsClickProc
                command: ["bash", "-c", "hyprctl dispatch 'hl.dsp.focus({ workspace = " + wsPill.wsNumber + " })' || hyprctl dispatch workspace " + wsPill.wsNumber]
            }

            Process {
                id: wsPrevProc
                command: ["bash", "-c", "hyprctl dispatch 'hl.dsp.focus({ workspace = \"-1\" })' || hyprctl dispatch workspace e-1"]
            }

            Process {
                id: wsNextProc
                command: ["bash", "-c", "hyprctl dispatch 'hl.dsp.focus({ workspace = \"+1\" })' || hyprctl dispatch workspace e+1"]
            }
        }
    }
}

