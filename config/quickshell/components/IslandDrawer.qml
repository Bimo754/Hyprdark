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

    property int hoveredItemCount: 0
    readonly property bool hasItemHovered: hoveredItemCount > 0
    readonly property bool isDrawerHovered: (drawerHover.hovered || hasItemHovered) && drawerRoot.open
    signal drawerHoverChanged(bool hovered)

    onIsDrawerHoveredChanged: {
        drawerRoot.drawerHoverChanged(isDrawerHovered);
        if (drawerRoot.closeTimer) {
            if (isDrawerHovered) {
                drawerRoot.closeTimer.stop();
            } else {
                drawerRoot.closeTimer.restart();
            }
        }
    }

    onOpenChanged: {
        if (!open) {
            hoveredItemCount = 0;
        }
    }

    function handleChildHover(hovered) {
        if (hovered) {
            hoveredItemCount++;
            if (drawerRoot.closeTimer) {
                drawerRoot.closeTimer.stop();
            }
        } else {
            hoveredItemCount = Math.max(0, hoveredItemCount - 1);
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
            duration: drawerRoot.open ? 320 : 130
            easing.type: drawerRoot.open ? Easing.OutBack : Easing.OutCubic
            easing.overshoot: 1.20
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: drawerRoot.open ? 200 : 90
            easing.type: Easing.OutCubic
        }
    }

    // Unified robust hover detection spanning the drawer and bridging into parent badge
    Item {
        id: hoverBridgeZone
        anchors.fill: parent
        anchors.topMargin: -16
        anchors.bottomMargin: -6
        anchors.leftMargin: -6
        anchors.rightMargin: -6

        HoverHandler {
            id: drawerHover
            enabled: drawerRoot.open
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
