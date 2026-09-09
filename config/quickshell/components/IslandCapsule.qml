import QtQuick
import ".."

Rectangle {
    id: capsuleRoot

    property bool hoverEnabled: true
    property bool containsMouse: mouseArea.containsMouse
    property color customHoverColor: StyleTokens.surfaceHover
    property bool animateSize: false

    color: StyleTokens.glassBackground
    radius: StyleTokens.capsuleRadius
    border.width: 1
    border.color: (hoverEnabled && containsMouse) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

    Behavior on border.color {
        ColorAnimation { duration: StyleTokens.animFast }
    }

    Behavior on color {
        ColorAnimation { duration: StyleTokens.animFast }
    }

    Behavior on width {
        enabled: capsuleRoot.animateSize
        NumberAnimation { duration: StyleTokens.animSmooth; easing.type: Easing.OutCubic }
    }

    Behavior on height {
        enabled: capsuleRoot.animateSize
        NumberAnimation { duration: StyleTokens.animSmooth; easing.type: Easing.OutCubic }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: capsuleRoot.hoverEnabled
        acceptedButtons: Qt.NoButton
    }
}
