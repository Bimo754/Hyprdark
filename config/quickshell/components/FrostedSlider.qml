import QtQuick
import ".."

Item {
    id: sliderRoot

    property real value: 0.0 // 0.0 to 1.0
    property string icon: ""
    property string label: ""
    property bool interactive: true
    signal valueModified(real newValue)

    implicitWidth: 260
    implicitHeight: 38

    Rectangle {
        id: track
        anchors.fill: parent
        radius: StyleTokens.capsuleRadius
        color: StyleTokens.surfaceSubtle
        border.width: 1
        border.color: StyleTokens.hairlineBorder

        // Fill bar
        Rectangle {
            id: fillBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(parent.height, parent.width * Math.max(0, Math.min(1, sliderRoot.value)))
            radius: StyleTokens.capsuleRadius
            color: StyleTokens.surfaceHover
            border.width: 1
            border.color: StyleTokens.hairlineBorder

            Behavior on width {
                enabled: !mouseArea.drag.active
                NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 10

            Text {
                id: iconText
                anchors.verticalCenter: parent.verticalCenter
                text: sliderRoot.icon
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 14
                color: StyleTokens.textPrimary
            }

            Text {
                id: labelText
                anchors.verticalCenter: parent.verticalCenter
                text: sliderRoot.label
                font.family: StyleTokens.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                color: StyleTokens.textSecondary
                elide: Text.ElideRight
                width: parent.width - iconText.width - percentText.width - 30
            }

            Text {
                id: percentText
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(sliderRoot.value * 100) + "%"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 11
                color: StyleTokens.textPrimary
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: sliderRoot.interactive
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            function updateValueFromPos(mouseX) {
                var clampedX = Math.max(0, Math.min(width, mouseX))
                var newVal = clampedX / width
                sliderRoot.value = newVal
                sliderRoot.valueModified(newVal)
            }

            onPressed: updateValueFromPos(mouse.x)
            onPositionChanged: {
                if (pressed) {
                    updateValueFromPos(mouse.x)
                }
            }
        }
    }
}
