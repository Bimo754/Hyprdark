import QtQuick
import ".."

Item {
    id: drawerRoot

    property bool open: false
    property real contentHeight: 0
    property real preferredWidth: parent ? parent.width + 18 : 160
    property int alignment: Qt.AlignHCenter
    property int horizontalOffset: 0
    property var closeTimer: null

    property real innerLeftMargin: 8
    property real innerRightMargin: 8
    property real innerTopMargin: 4
    property real innerBottomMargin: 8

    readonly property bool isDrawerHovered: drawerBridgeMouse.containsMouse || drawerHover.hovered
    signal drawerHoverChanged(bool hovered)

    function handleChildHover(hovered) {
        drawerRoot.drawerHoverChanged(hovered);
        if (drawerRoot.closeTimer) {
            if (hovered) {
                drawerRoot.closeTimer.stop();
            } else {
                drawerRoot.closeTimer.restart();
            }
        }
    }

    y: 34
    width: preferredWidth
    x: {
        var pWidth = parent ? parent.width : 0;
        if (alignment === Qt.AlignRight) {
            return pWidth - width + horizontalOffset;
        } else if (alignment === Qt.AlignLeft) {
            return horizontalOffset;
        } else {
            return Math.round((pWidth - width) / 2) + horizontalOffset;
        }
    }

    height: Math.max(0, open ? contentHeight : 0)
    clip: true

    visible: height > 1 && opacity > 0.01
    opacity: open ? 1.0 : 0.0

    Behavior on height {
        NumberAnimation {
            duration: drawerRoot.open ? 320 : 200
            easing.type: drawerRoot.open ? Easing.OutBack : Easing.OutCubic
            easing.overshoot: 1.20
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: drawerRoot.open ? 200 : 100
            easing.type: Easing.OutCubic
        }
    }

    // Zero-gap hit-testing bridge: spans the drawer and reaches into parent badge
    MouseArea {
        id: drawerBridgeMouse
        anchors.fill: parent
        anchors.topMargin: -14
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onEntered: {
            drawerRoot.drawerHoverChanged(true);
            if (drawerRoot.closeTimer) {
                drawerRoot.closeTimer.stop();
            }
        }
        onExited: {
            drawerRoot.drawerHoverChanged(false);
            if (drawerRoot.closeTimer) {
                drawerRoot.closeTimer.restart();
            }
        }
    }

    HoverHandler {
        id: drawerHover
        onHoveredChanged: {
            drawerRoot.drawerHoverChanged(hovered);
            if (drawerRoot.closeTimer) {
                if (hovered) {
                    drawerRoot.closeTimer.stop();
                } else {
                    drawerRoot.closeTimer.restart();
                }
            }
        }
    }

    default property alias content: innerContainer.data

    Item {
        id: innerContainer
        anchors.fill: parent
        anchors.topMargin: drawerRoot.innerTopMargin
        anchors.bottomMargin: drawerRoot.innerBottomMargin
        anchors.leftMargin: drawerRoot.innerLeftMargin
        anchors.rightMargin: drawerRoot.innerRightMargin
        clip: true
        visible: drawerRoot.height > 12
    }
}
