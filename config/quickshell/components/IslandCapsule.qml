import QtQuick
import ".."

Rectangle {
    id: capsuleRoot

    property bool hoverEnabled: true
    readonly property bool containsMouse: hoverHandler.hovered

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

    HoverHandler {
        id: hoverHandler
        enabled: capsuleRoot.hoverEnabled
    }
}
