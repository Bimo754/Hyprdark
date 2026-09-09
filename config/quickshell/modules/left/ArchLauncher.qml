import QtQuick
import Quickshell.Io
import "../.."

Rectangle {
    id: launcherRoot
    width: 30
    height: 30
    radius: StyleTokens.capsuleRadius
    color: hoverMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
    anchors.verticalCenter: parent.verticalCenter

    Behavior on color {
        ColorAnimation { duration: StyleTokens.animFast }
    }

    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0.5
        text: "󰣇"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 16
        color: hoverMouse.containsMouse ? StyleTokens.textPrimary : StyleTokens.textSecondary
    }

    Process {
        id: rofiProc
        command: ["bash", "-c", "rofi -show drun"]
    }

    MouseArea {
        id: hoverMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: rofiProc.running = true
    }
}
