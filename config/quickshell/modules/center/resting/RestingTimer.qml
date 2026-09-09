import QtQuick
import "../../../"

Row {
    id: timerRoot
    anchors.centerIn: parent
    spacing: 8

    property int secondsRemaining: 0
    signal cancelRequested()

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "󰔛"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 13
        color: StyleTokens.textSecondary
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: {
            var m = Math.floor(timerRoot.secondsRemaining / 60)
            var s = timerRoot.secondsRemaining % 60
            return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
        }
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 11
        font.weight: Font.Medium
        color: StyleTokens.textPrimary
    }

    Rectangle {
        width: 18
        height: 18
        radius: StyleTokens.capsuleRadius
        color: cancelMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: "✕"
            font.family: StyleTokens.fontFamily
            font.pixelSize: 10
            color: StyleTokens.textSecondary
        }

        MouseArea {
            id: cancelMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: timerRoot.cancelRequested()
        }
    }
}
