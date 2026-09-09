import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import "../.."

Item {
    id: wsListRoot
    implicitWidth: 146
    implicitHeight: 26
    anchors.verticalCenter: parent.verticalCenter

    property int activeWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property var workspaceModel: [1, 2, 3, 4, 5]
    readonly property real slotStride: 30.0
    readonly property real slotSize: 26.0

    // Compute target x for any workspace ID 1..5
    function getSlotX(wsId) {
        var idx = Math.max(1, Math.min(5, wsId)) - 1;
        return idx * slotStride;
    }

    // 1. Soft Frosted Capsule Slider Pill (Clean, flat, zero glare)
    Rectangle {
        id: activeCapsule
        anchors.verticalCenter: parent.verticalCenter
        height: wsListRoot.slotSize
        width: wsListRoot.slotSize
        radius: StyleTokens.capsuleRadius
        z: 1
        transformOrigin: Item.Center

        x: wsListRoot.getSlotX(wsListRoot.activeWsId)

        color: Qt.rgba(255/255, 255/255, 255/255, 0.12)
        border.width: 1
        border.color: Qt.rgba(255/255, 255/255, 255/255, 0.22)

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutBack
                easing.overshoot: 1.12
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
    }

    // 2. Numbers & Interactive Hitboxes (On Top)
    Row {
        id: numRow
        spacing: 4
        anchors.fill: parent
        z: 2

        Repeater {
            model: wsListRoot.workspaceModel

            Item {
                id: wsItem
                width: wsListRoot.slotSize
                height: wsListRoot.slotSize

                readonly property int wsNumber: modelData
                readonly property bool isActive: wsListRoot.activeWsId === wsNumber

                // Discrete Per-Slot Smooth Hover Pill (Fade in / Fade out)
                Rectangle {
                    anchors.fill: parent
                    radius: StyleTokens.capsuleRadius
                    color: StyleTokens.surfaceHover
                    opacity: (wsMouse.containsMouse && !wsItem.isActive) ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: StyleTokens.animFast }
                    }
                }

                Text {
                    id: wsText
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 1
                    text: String(wsItem.wsNumber)
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 12
                    font.weight: wsItem.isActive ? Font.Bold : (wsMouse.containsMouse ? Font.DemiBold : Font.Normal)
                    color: wsItem.isActive ? "#ffffff" : (wsMouse.containsMouse ? StyleTokens.textPrimary : StyleTokens.textSecondary)

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onPressed: {
                        activeCapsule.scale = 0.90;
                    }
                    onReleased: {
                        activeCapsule.scale = 1.0;
                    }
                    onClicked: {
                        wsClickProc.running = true;
                    }
                    onWheel: function(wheel) {
                        if (wheel.angleDelta.y > 0) {
                            wsPrevProc.running = true;
                        } else if (wheel.angleDelta.y < 0) {
                            wsNextProc.running = true;
                        }
                    }
                }

                Process {
                    id: wsClickProc
                    command: ["bash", "-c", "hyprctl dispatch 'hl.dsp.focus({ workspace = " + wsItem.wsNumber + " })' || hyprctl dispatch workspace " + wsItem.wsNumber]
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
}

