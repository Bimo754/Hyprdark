import QtQuick
import "../../../"

Item {
    id: emptyRoot
    anchors.fill: parent

    Column {
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "󰂚"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 24
            color: StyleTokens.textTertiary
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "No Notifications"
            font.family: StyleTokens.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: StyleTokens.textSecondary
        }
    }
}
