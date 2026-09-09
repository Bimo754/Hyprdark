import QtQuick
import "../../../"

Row {
    id: osdRoot
    anchors.centerIn: parent
    spacing: 10

    property string icon: "󰕾"
    property int value: 50

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: osdRoot.icon
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 13
        color: StyleTokens.textSecondary
    }

    Rectangle {
        width: 100
        height: 5
        radius: 3
        color: StyleTokens.surfaceSubtle
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            height: parent.height
            width: parent.width * Math.max(0, Math.min(1, osdRoot.value / 100))
            radius: 3
            color: StyleTokens.textPrimary
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: osdRoot.value + "%"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 11
        color: StyleTokens.textPrimary
    }
}
