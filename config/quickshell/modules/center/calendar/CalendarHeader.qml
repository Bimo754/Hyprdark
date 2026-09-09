import QtQuick
import "../../../"

Item {
    id: headerRoot
    width: parent ? parent.width : 260
    height: 24

    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()
    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    signal prevClicked()
    signal nextClicked()
    signal resetTodayClicked()

    // Previous Month Button
    Rectangle {
        width: 22
        height: 22
        radius: StyleTokens.capsuleRadius
        color: prevMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: "‹"
            font.family: StyleTokens.fontFamily
            font.pixelSize: 15
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

    // Month & Year Label / Reset Today Button
    Rectangle {
        id: monthYearBtn
        width: monthYearText.implicitWidth + 14
        height: 22
        radius: 6
        color: monthYearMouse.containsMouse ? StyleTokens.surfaceSubtle : StyleTokens.transparent
        anchors.centerIn: parent

        Text {
            id: monthYearText
            anchors.centerIn: parent
            text: headerRoot.monthNames[headerRoot.viewMonth] + " " + headerRoot.viewYear
            font.family: StyleTokens.fontFamily
            font.pixelSize: 13
            font.weight: Font.Bold
            color: StyleTokens.textPrimary
        }

        MouseArea {
            id: monthYearMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: headerRoot.resetTodayClicked()
        }
    }

    // Next Month Button
    Rectangle {
        width: 22
        height: 22
        radius: StyleTokens.capsuleRadius
        color: nextMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: "›"
            font.family: StyleTokens.fontFamily
            font.pixelSize: 15
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
