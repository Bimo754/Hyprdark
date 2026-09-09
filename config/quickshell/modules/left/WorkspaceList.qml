import QtQuick
import Quickshell.Hyprland
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

            readonly property bool isActive: wsListRoot.activeWsId === modelData
            color: isActive ? StyleTokens.activePill : (wsMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent)

            Behavior on color {
                ColorAnimation { duration: StyleTokens.animFast }
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 0.5
                text: String(modelData)
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
                onClicked: Hyprland.dispatch("workspace " + modelData)
                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        Hyprland.dispatch("workspace e-1")
                    } else if (wheel.angleDelta.y < 0) {
                        Hyprland.dispatch("workspace e+1")
                    }
                }
            }
        }
    }
}
