import QtQuick
import "../../"

Rectangle {
    id: cardRoot
    width: parent ? parent.width : 252
    height: 32
    radius: StyleTokens.buttonRadius
    color: StyleTokens.surfaceSubtle
    border.width: 1
    border.color: StyleTokens.hairlineDivider

    property string sinkName: "Default Output"

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰓃"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 13
            color: StyleTokens.textSecondary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: cardRoot.sinkName
            font.family: StyleTokens.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: StyleTokens.textPrimary
            elide: Text.ElideRight
            width: parent.width - 30
        }
    }
}
