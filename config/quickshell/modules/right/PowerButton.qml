import QtQuick
import Quickshell
import Quickshell.Io
import "../.."

Rectangle {
    id: powerButtonRoot
    width: 28
    height: 28
    radius: StyleTokens.capsuleRadius
    anchors.verticalCenter: parent.verticalCenter
    color: powerMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

    signal clicked()

    Text {
        anchors.centerIn: parent
        text: "󰐥"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 14
        color: StyleTokens.textPrimary
    }

    MouseArea {
        id: powerMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            powerButtonRoot.clicked()
            powerProc.running = true
        }
    }

    Process {
        id: powerProc
        command: ["bash", "-c", "wlogout || rofi -show power-menu -modi power-menu:~/.config/rofi/rofi-power-menu || hyprlock"]
    }
}
