import QtQuick
import "../.."

Column {
    id: emptyStateRoot
    anchors.centerIn: parent
    spacing: 8

    Rectangle {
        width: 44
        height: 44
        radius: 22
        anchors.horizontalCenter: parent.horizontalCenter
        color: StyleTokens.surfaceSubtle
        border.width: 1
        border.color: StyleTokens.hairlineDivider

        Text {
            anchors.centerIn: parent
            text: "󰂛"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 20
            color: StyleTokens.textTertiary
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "No Notifications"
        font.family: StyleTokens.fontFamily
        font.pixelSize: 12
        font.weight: Font.DemiBold
        color: StyleTokens.textSecondary
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "You're all caught up"
        font.family: StyleTokens.fontFamily
        font.pixelSize: 10
        color: StyleTokens.textTertiary
    }
}
