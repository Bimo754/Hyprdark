import QtQuick
import "../.."

Rectangle {
    id: ccTriggerRoot
    width: 24
    height: 24
    radius: StyleTokens.capsuleRadius
    anchors.verticalCenter: parent.verticalCenter
    color: ccMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

    signal clicked()

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
        onClicked: ccTriggerRoot.clicked()
    }
}
