import QtQuick
import ".."

Rectangle {
    id: targetInputRoot
    width: parent.width
    height: 38
    radius: StyleTokens.buttonRadius
    color: StyleTokens.cardBackground
    border.width: 1
    border.color: innerInput.activeFocus ? Qt.rgba(10/255, 132/255, 255/255, 0.55) : StyleTokens.hairlineBorder

    property alias text: innerInput.text
    required property var backend
    signal submitted(string value)

    function forceActiveFocus() {
        innerInput.forceActiveFocus();
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 8
        spacing: 8

        Text {
            text: "󰄾"
            color: innerInput.activeFocus ? Qt.rgba(10/255, 132/255, 255/255, 1.0) : StyleTokens.textTertiary
            font.pixelSize: 14
            font.family: StyleTokens.monoFontFamily
            anchors.verticalCenter: parent.verticalCenter
        }

        TextInput {
            id: innerInput
            width: parent.width - 90
            anchors.verticalCenter: parent.verticalCenter
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 12
            color: StyleTokens.textPrimary
            selectByMouse: true
            clip: true

            Text {
                text: "Set target (e.g. 10.10.11.50, +subdomain, 'clear')"
                color: StyleTokens.textTertiary
                font.family: StyleTokens.fontFamily
                font.pixelSize: 11
                visible: !innerInput.text && !innerInput.activeFocus
                anchors.verticalCenter: parent.verticalCenter
            }

            onAccepted: {
                if (innerInput.text.trim() !== "") {
                    backend.setTarget(innerInput.text);
                    targetInputRoot.submitted(innerInput.text);
                    innerInput.text = "";
                }
            }
        }

        // Enter Submit Pill
        Rectangle {
            width: 44
            height: 24
            radius: 6
            anchors.verticalCenter: parent.verticalCenter
            color: submitHover.containsMouse ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
            border.width: 1
            border.color: StyleTokens.hairlineBorder

            Text {
                anchors.centerIn: parent
                text: "SET"
                color: StyleTokens.textSecondary
                font.pixelSize: 10
                font.bold: true
                font.family: StyleTokens.monoFontFamily
            }

            MouseArea {
                id: submitHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (innerInput.text.trim() !== "") {
                        backend.setTarget(innerInput.text);
                        targetInputRoot.submitted(innerInput.text);
                        innerInput.text = "";
                    }
                }
            }
        }
    }
}
