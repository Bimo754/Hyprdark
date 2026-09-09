import QtQuick
import "../../"

Rectangle {
    id: cardRoot
    height: 48
    radius: StyleTokens.buttonRadius
    color: cardRoot.active ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
    border.width: 1
    border.color: cardRoot.active ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

    property bool active: false
    property string icon: ""
    property string label: ""
    property string sublabel: ""
    property color iconColor: StyleTokens.textPrimary

    signal clicked()

    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: cardRoot.icon
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 15
            color: cardRoot.iconColor
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: cardRoot.label
                font.family: StyleTokens.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: StyleTokens.textPrimary
            }

            Text {
                text: cardRoot.sublabel
                font.family: StyleTokens.fontFamily
                font.pixelSize: 10
                color: StyleTokens.textSecondary
                elide: Text.ElideRight
                width: 70
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: cardRoot.clicked()
    }
}
