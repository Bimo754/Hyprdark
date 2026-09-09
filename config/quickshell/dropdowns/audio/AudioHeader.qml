import QtQuick
import "../../"

Row {
    id: headerRoot
    width: parent ? parent.width : 252
    height: 24

    property bool isMuted: false
    signal toggleMuteClicked()

    Text {
        text: "Sound Output"
        font.family: StyleTokens.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: StyleTokens.textPrimary
        anchors.verticalCenter: parent.verticalCenter
    }

    Item {
        width: parent.width - 90 - muteBtn.width
        height: 1
    }

    Rectangle {
        id: muteBtn
        width: 24
        height: 24
        radius: StyleTokens.capsuleRadius
        color: headerRoot.isMuted ? StyleTokens.alertRed : (muteMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.surfaceSubtle)
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: headerRoot.isMuted ? "󰝟" : "󰕾"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 12
            color: StyleTokens.textPrimary
        }

        MouseArea {
            id: muteMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: headerRoot.toggleMuteClicked()
        }
    }
}
