import QtQuick
import "../.."

Row {
    id: headerRoot
    width: parent ? parent.width : 244
    height: 26

    required property string titleText
    signal prevClicked()
    signal nextClicked()
    signal titleClicked()

    // Previous Month Button
    Rectangle {
        width: 26
        height: 26
        radius: StyleTokens.capsuleRadius
        color: prevMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: "‹"
            font.family: StyleTokens.fontFamily
            font.pixelSize: 16
            font.weight: Font.Bold
            color: StyleTokens.textPrimary
        }

        MouseArea {
            id: prevMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: headerRoot.prevClicked()
        }
    }

    // Month & Year Title
    Rectangle {
        width: parent.width - 52
        height: 26
        radius: 6
        color: titleMouse.containsMouse ? StyleTokens.surfaceSubtle : StyleTokens.transparent
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: headerRoot.titleText
            font.family: StyleTokens.fontFamily
            font.pixelSize: 13
            font.weight: Font.Bold
            color: StyleTokens.textPrimary
        }

        MouseArea {
            id: titleMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: headerRoot.titleClicked()
        }
    }

    // Next Month Button
    Rectangle {
        width: 26
        height: 26
        radius: StyleTokens.capsuleRadius
        color: nextMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: "›"
            font.family: StyleTokens.fontFamily
            font.pixelSize: 16
            font.weight: Font.Bold
            color: StyleTokens.textPrimary
        }

        MouseArea {
            id: nextMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: headerRoot.nextClicked()
        }
    }
}
