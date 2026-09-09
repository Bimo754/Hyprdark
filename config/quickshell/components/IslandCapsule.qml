import QtQuick
import ".."

Rectangle {
    id: capsuleRoot

    property bool hoverEnabled: true
    readonly property bool containsMouse: hoverHandler.hovered
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

    HoverHandler {
        id: hoverHandler
        enabled: capsuleRoot.hoverEnabled
    }
}
