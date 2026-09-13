import QtQuick
import ".."

Rectangle {
    id: actionCardRoot
    width: (parent.width - 10) / 2
    height: 58
    radius: StyleTokens.buttonRadius

    property string indexNumber: "1"
    property string icon: ""
    property string title: ""
    property string subtitle: ""
    signal clicked()

    color: mouseArea.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
    border.width: 1
    border.color: mouseArea.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

    Behavior on color { ColorAnimation { duration: StyleTokens.animFast } }
    Behavior on border.color { ColorAnimation { duration: StyleTokens.animFast } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Rectangle {
            width: 24
            height: 24
            radius: 6
            color: StyleTokens.surfaceSubtle
            border.width: 1
            border.color: StyleTokens.hairlineBorder
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: actionCardRoot.indexNumber
                color: StyleTokens.textSecondary
                font.pixelSize: 11
                font.bold: true
                font.family: StyleTokens.monoFontFamily
            }
        }

        Text {
            text: actionCardRoot.icon
            color: StyleTokens.textPrimary
            font.pixelSize: 18
            font.family: StyleTokens.monoFontFamily
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: actionCardRoot.title
                color: StyleTokens.textPrimary
                font.pixelSize: 12
                font.bold: true
                font.family: StyleTokens.fontFamily
            }
            Text {
                text: actionCardRoot.subtitle
                color: StyleTokens.textSecondary
                font.pixelSize: 10
                font.family: StyleTokens.fontFamily
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: actionCardRoot.clicked()
    }
}
