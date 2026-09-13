import QtQuick
import ".."

Rectangle {
    id: feedbackRoot
    height: 22
    width: fbRow.implicitWidth + 16
    radius: StyleTokens.capsuleRadius
    color: Qt.rgba(10/255, 132/255, 255/255, 0.25)
    border.width: 1
    border.color: Qt.rgba(10/255, 132/255, 255/255, 0.55)
    visible: false

    property string titleText: ""
    property string bodyText: ""

    function show(title, body) {
        titleText = title;
        bodyText = body;
        visible = true;
        feedbackTimer.restart();
    }

    Row {
        id: fbRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "󰄬"
            color: Qt.rgba(10/255, 132/255, 255/255, 1.0)
            font.pixelSize: 11
            font.family: StyleTokens.monoFontFamily
        }

        Text {
            text: feedbackRoot.titleText + ": " + feedbackRoot.bodyText
            color: StyleTokens.textPrimary
            font.pixelSize: 10
            font.family: StyleTokens.monoFontFamily
        }
    }

    Timer {
        id: feedbackTimer
        interval: 2800
        repeat: false
        onTriggered: feedbackRoot.visible = false
    }
}
