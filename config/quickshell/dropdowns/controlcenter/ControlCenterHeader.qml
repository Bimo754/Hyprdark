import QtQuick
import "../../"

Row {
    id: headerRoot
    width: parent ? parent.width : 288
    height: 22

    Text {
        text: "Control Center"
        font.family: StyleTokens.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: StyleTokens.textPrimary
        anchors.verticalCenter: parent.verticalCenter
    }
}
