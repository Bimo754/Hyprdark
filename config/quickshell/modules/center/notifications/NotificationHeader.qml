import QtQuick
import "../../../"

Item {
    id: headerRoot
    width: parent ? parent.width : 280
    height: 24

    property int count: 0
    signal clearAllClicked()
    signal closeClicked()

    Row {
        spacing: 6
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "NOTIFICATIONS"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 11
            font.weight: Font.Bold
            color: StyleTokens.textPrimary
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            height: 15
            width: Math.max(15, countText.implicitWidth + 8)
            radius: StyleTokens.capsuleRadius
            color: Qt.rgba(1, 1, 1, 0.09)
            border.width: 1
            border.color: StyleTokens.hairlineBorder
            anchors.verticalCenter: parent.verticalCenter
            visible: headerRoot.count > 0

            Text {
                id: countText
                anchors.centerIn: parent
                text: String(headerRoot.count)
                font.family: StyleTokens.fontFamily
                font.pixelSize: 9
                font.weight: Font.Bold
                color: StyleTokens.textSecondary
            }
        }
    }

    Row {
        spacing: 8
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        // Clear All
        Rectangle {
            width: 58
            height: 18
            radius: StyleTokens.capsuleRadius
            color: clearMouse.containsMouse ? Qt.rgba(255/255, 69/255, 58/255, 0.22) : Qt.rgba(1, 1, 1, 0.06)
            border.width: 1
            border.color: clearMouse.containsMouse ? Qt.rgba(255/255, 69/255, 58/255, 0.45) : StyleTokens.hairlineBorder
            visible: headerRoot.count > 0
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "Clear All"
                font.family: StyleTokens.fontFamily
                font.pixelSize: 10
                font.weight: Font.DemiBold
                color: clearMouse.containsMouse ? StyleTokens.textPrimary : StyleTokens.textSecondary
            }

            MouseArea {
                id: clearMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: headerRoot.clearAllClicked()
            }
        }

        // Close (✕)
        Rectangle {
            width: 18
            height: 18
            radius: StyleTokens.capsuleRadius
            color: closeMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.family: StyleTokens.fontFamily
                font.pixelSize: 10
                color: StyleTokens.textSecondary
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: headerRoot.closeClicked()
            }
        }
    }
}
