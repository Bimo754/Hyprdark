import QtQuick
import "../../../"

Rectangle {
    id: cardRoot
    width: parent ? parent.width : 280
    height: Math.max(52, cardCol.implicitHeight + 16)
    radius: StyleTokens.buttonRadius
    color: StyleTokens.cardBackground
    border.width: 1
    border.color: cardMouse.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

    property var itemData
    signal dismissRequested()

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
    }

    Column {
        id: cardCol
        anchors.left: parent.left
        anchors.right: dismissBtn.left
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 3

        Row {
            spacing: 6
            width: parent.width

            Text {
                text: cardRoot.itemData ? (cardRoot.itemData.app || "System") : "System"
                font.family: StyleTokens.fontFamily
                font.pixelSize: 10
                font.weight: Font.DemiBold
                color: StyleTokens.textSecondary
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 120)
            }

            Text {
                text: "•"
                font.pixelSize: 9
                color: StyleTokens.textTertiary
            }

            Text {
                text: "Now"
                font.family: StyleTokens.fontFamily
                font.pixelSize: 9
                color: StyleTokens.textTertiary
            }
        }

        Text {
            text: cardRoot.itemData ? (cardRoot.itemData.title || "") : ""
            font.family: StyleTokens.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: StyleTokens.textPrimary
            elide: Text.ElideRight
            width: parent.width
            visible: text.length > 0
        }

        Text {
            text: cardRoot.itemData ? (cardRoot.itemData.body || "") : ""
            font.family: StyleTokens.fontFamily
            font.pixelSize: 10
            color: StyleTokens.textSecondary
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            width: parent.width
            visible: text.length > 0
        }
    }

    Rectangle {
        id: dismissBtn
        width: 18
        height: 18
        radius: StyleTokens.capsuleRadius
        color: dismissMouse.containsMouse ? Qt.rgba(255/255, 69/255, 58/255, 0.22) : StyleTokens.transparent
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 6

        Text {
            anchors.centerIn: parent
            text: "✕"
            font.family: StyleTokens.fontFamily
            font.pixelSize: 9
            color: dismissMouse.containsMouse ? StyleTokens.textPrimary : StyleTokens.textTertiary
        }

        MouseArea {
            id: dismissMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: cardRoot.dismissRequested()
        }
    }
}
