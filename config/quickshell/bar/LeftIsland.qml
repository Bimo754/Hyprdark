import QtQuick
import QtQuick.Shapes
import Quickshell
import ".."
import "../components"
import "../modules/left"

Item {
    id: leftIslandRoot

    implicitHeight: 42
    implicitWidth: innerRow.implicitWidth + 24

    readonly property bool isTargetOpen: targetBadge.dropdownOpen
    readonly property bool isVpnOpen: vpnBadge.dropdownOpen
    readonly property bool dropdownOpen: isTargetOpen || isVpnOpen

    readonly property real targetTargetH: isTargetOpen ? targetBadge.contentHeight : 0
    readonly property real vpnTargetH: isVpnOpen ? vpnBadge.contentHeight : 0
    readonly property real targetH: Math.max(targetTargetH, vpnTargetH)

    property real animatedDrawerH: targetH

    Behavior on animatedDrawerH {
        NumberAnimation {
            duration: leftIslandRoot.targetH > 0 ? 240 : 180
            easing.type: Easing.OutCubic
        }
    }

    property real lastDrawerLeft: 0
    property real lastDrawerRight: 0
    property real lastDrawerContentH: 0
    property bool lastWasTarget: true

    onIsTargetOpenChanged: {
        if (isTargetOpen) {
            lastWasTarget = true;
            lastDrawerLeft = innerRow.x + targetBadge.x - 9;
            lastDrawerRight = innerRow.x + targetBadge.x + targetBadge.width + 9;
            lastDrawerContentH = targetBadge.contentHeight;
        }
    }
    onIsVpnOpenChanged: {
        if (isVpnOpen) {
            lastWasTarget = false;
            lastDrawerLeft = innerRow.x + vpnBadge.x - 9;
            lastDrawerRight = innerRow.x + vpnBadge.x + vpnBadge.width + 9;
            lastDrawerContentH = vpnBadge.contentHeight;
        }
    }

    readonly property real activeDrawerLeft: isTargetOpen ? (innerRow.x + targetBadge.x - 9) : (isVpnOpen ? (innerRow.x + vpnBadge.x - 9) : lastDrawerLeft)
    readonly property real activeDrawerRight: isTargetOpen ? (innerRow.x + targetBadge.x + targetBadge.width + 9) : (isVpnOpen ? (innerRow.x + vpnBadge.x + vpnBadge.width + 9) : lastDrawerRight)
    readonly property real activeDrawerContentH: isTargetOpen ? targetBadge.contentHeight : (isVpnOpen ? vpnBadge.contentHeight : lastDrawerContentH)

    property bool isHovered: islandHover.hovered || targetBadge.isHovered || targetBadge.dropdownHovered || vpnBadge.isHovered || vpnBadge.dropdownHovered

    HoverHandler {
        id: islandHover
    }

    // 1. Main Top Island Capsule (Rock-solid, constant 42px height, 21px radius)
    Rectangle {
        id: islandCapsule
        anchors.top: parent.top
        anchors.left: parent.left
        width: leftIslandRoot.width
        height: 42
        radius: 21
        color: StyleTokens.glassBackground
        border.width: 1
        border.color: leftIslandRoot.isHovered ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
        z: 2

        Behavior on border.color {
            ColorAnimation { duration: StyleTokens.animFast }
        }
    }

    // 2. Dynamic Sliding Drawer Extension (Sliding straight out from behind the island at constant width)
    Item {
        id: drawerViewport
        x: leftIslandRoot.activeDrawerLeft
        y: 42
        width: Math.max(0, leftIslandRoot.activeDrawerRight - leftIslandRoot.activeDrawerLeft)
        height: leftIslandRoot.animatedDrawerH
        clip: true
        visible: leftIslandRoot.animatedDrawerH > 0.1
        z: 1

        Item {
            id: drawerSlideContent
            width: parent.width
            height: Math.max(1, leftIslandRoot.activeDrawerContentH)
            y: leftIslandRoot.animatedDrawerH - height

            // Drawer Glass Background & 3-Sided Hairline Border (Left, Bottom-Rounded, Right)
            Shape {
                id: drawerBgShape
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4

                // Fill Path
                ShapePath {
                    strokeWidth: 0
                    strokeColor: "transparent"
                    fillColor: StyleTokens.glassBackground

                    startX: 0
                    startY: 0

                    PathLine { x: drawerBgShape.width; y: 0 }
                    PathLine { x: drawerBgShape.width; y: Math.max(0, drawerBgShape.height - 14) }
                    PathArc {
                        x: Math.max(0, drawerBgShape.width - 14)
                        y: drawerBgShape.height
                        radiusX: 14
                        radiusY: 14
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: 14; y: drawerBgShape.height }
                    PathArc {
                        x: 0
                        y: Math.max(0, drawerBgShape.height - 14)
                        radiusX: 14
                        radiusY: 14
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: 0; y: 0 }
                }

                // 3-Sided Hairline Border
                ShapePath {
                    strokeWidth: 1
                    strokeColor: leftIslandRoot.isHovered ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
                    fillColor: "transparent"
                    capStyle: ShapePath.FlatCap
                    joinStyle: ShapePath.MiterJoin

                    Behavior on strokeColor {
                        ColorAnimation { duration: StyleTokens.animFast }
                    }

                    startX: drawerBgShape.width - 0.5
                    startY: -1

                    PathLine {
                        x: drawerBgShape.width - 0.5
                        y: Math.max(0, drawerBgShape.height - 14)
                    }
                    PathArc {
                        x: Math.max(0, drawerBgShape.width - 14)
                        y: drawerBgShape.height - 0.5
                        radiusX: 13.5
                        radiusY: 13.5
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        x: 14
                        y: drawerBgShape.height - 0.5
                    }
                    PathArc {
                        x: 0.5
                        y: Math.max(0, drawerBgShape.height - 14)
                        radiusX: 13.5
                        radiusY: 13.5
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        x: 0.5
                        y: -1
                    }
                }
            }

            // Hover Handler for Drawer
            HoverHandler {
                id: drawerHover
                onHoveredChanged: {
                    if (hovered) {
                        if (leftIslandRoot.lastWasTarget) {
                            targetBadge.dropdownHovered = true;
                            targetBadge.stopCloseTimer();
                        } else {
                            vpnBadge.dropdownHovered = true;
                            vpnBadge.stopCloseTimer();
                        }
                    } else {
                        if (leftIslandRoot.lastWasTarget) {
                            targetBadge.dropdownHovered = false;
                            targetBadge.restartCloseTimer();
                        } else {
                            vpnBadge.dropdownHovered = false;
                            vpnBadge.restartCloseTimer();
                        }
                    }
                }
            }

            // Mouse Wheel Handler for Target Domains Scroll
            WheelHandler {
                enabled: leftIslandRoot.lastWasTarget
                onWheel: event => {
                    if (event.angleDelta.y < 0) {
                        if (targetBadge.scrollIndex < targetBadge.domains.length - 2) {
                            targetBadge.scrollIndex++;
                        }
                    } else if (event.angleDelta.y > 0) {
                        if (targetBadge.scrollIndex > 0) {
                            targetBadge.scrollIndex--;
                        }
                    }
                }
            }

            // Content Item Container
            Item {
                id: drawerContentContainer
                anchors.fill: parent
                anchors.margins: 6
                clip: true

                // Target Domains List
                Item {
                    id: targetDomainsWrapper
                    anchors.fill: parent
                    visible: leftIslandRoot.lastWasTarget
                    opacity: leftIslandRoot.isTargetOpen ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                    }

                    Column {
                        id: domainColumn
                        width: parent.width
                        spacing: 4
                        y: -targetBadge.scrollIndex * 30

                        Behavior on y {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }

                        Repeater {
                            model: targetBadge.domains

                            Rectangle {
                                id: domainItemRoot
                                width: domainColumn.width
                                height: 26
                                radius: StyleTokens.capsuleRadius

                                property bool itemCopied: false

                                color: {
                                    if (itemCopied) return Qt.rgba(10/255, 132/255, 255/255, 0.35);
                                    if (domMouse.containsMouse) return StyleTokens.surfaceHover;
                                    return StyleTokens.transparent;
                                }
                                border.width: 1
                                border.color: {
                                    if (itemCopied) return Qt.rgba(10/255, 132/255, 255/255, 0.75);
                                    if (domMouse.containsMouse) return StyleTokens.hairlineBorderHover;
                                    return StyleTokens.transparent;
                                }

                                Behavior on color {
                                    ColorAnimation { duration: StyleTokens.animFast }
                                }
                                Behavior on border.color {
                                    ColorAnimation { duration: StyleTokens.animFast }
                                }

                                SequentialAnimation {
                                   id: itemClickAnim
                                   NumberAnimation {
                                       target: itemRow
                                       property: "scale"
                                       to: 0.88
                                       duration: 70
                                       easing.type: Easing.OutQuad
                                   }
                                   NumberAnimation {
                                       target: itemRow
                                       property: "scale"
                                       to: 1.08
                                       duration: 110
                                       easing.type: Easing.OutBack
                                       easing.overshoot: 1.4
                                   }
                                   NumberAnimation {
                                       target: itemRow
                                       property: "scale"
                                       to: 1.0
                                       duration: 80
                                       easing.type: Easing.OutQuad
                                   }
                                }

                                Timer {
                                    id: itemCopiedTimer
                                    interval: 900
                                    repeat: false
                                    onTriggered: domainItemRoot.itemCopied = false
                                }

                                Row {
                                    id: itemRow
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    spacing: 6

                                    Text {
                                        width: 14
                                        horizontalAlignment: Text.AlignHCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: domainItemRoot.itemCopied ? "󰄬" : "󰖟"
                                        font.family: StyleTokens.monoFontFamily
                                        font.pixelSize: 12
                                        color: domainItemRoot.itemCopied ? Qt.rgba(10/255, 132/255, 255/255, 1.0) : StyleTokens.textSecondary

                                        Behavior on color {
                                            ColorAnimation { duration: StyleTokens.animFast }
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 20
                                        text: modelData
                                        font.family: StyleTokens.monoFontFamily
                                        font.pixelSize: 11
                                        color: StyleTokens.textPrimary
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: domMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    cursorShape: Qt.PointingHandCursor

                                    onEntered: {
                                        targetBadge.dropdownHovered = true;
                                        targetBadge.stopCloseTimer();
                                    }
                                    onExited: {
                                        targetBadge.restartCloseTimer();
                                    }

                                    onClicked: mouse => {
                                        if (mouse.button === Qt.RightButton) {
                                            targetBadge.deleteDomain(modelData);
                                        } else {
                                            targetBadge.copyText(modelData);
                                            domainItemRoot.itemCopied = true;
                                            itemCopiedTimer.restart();
                                            itemClickAnim.restart();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Secondary VPNs List
                Item {
                    id: secVpnsWrapper
                    anchors.fill: parent
                    visible: !leftIslandRoot.lastWasTarget
                    opacity: leftIslandRoot.isVpnOpen ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                    }

                    Column {
                        id: secVpnColumn
                        width: parent.width
                        spacing: 4
                        y: 0

                        Repeater {
                            model: vpnBadge.secondaryVpns

                            Rectangle {
                                id: secVpnItemRoot
                                width: secVpnColumn.width
                                height: 26
                                radius: StyleTokens.capsuleRadius

                                property bool itemCopied: false

                                color: {
                                    if (itemCopied) return Qt.rgba(48/255, 209/255, 88/255, 0.35);
                                    if (secMouse.containsMouse) return StyleTokens.surfaceHover;
                                    return StyleTokens.transparent;
                                }
                                border.width: 1
                                border.color: {
                                    if (itemCopied) return Qt.rgba(48/255, 209/255, 88/255, 0.75);
                                    if (secMouse.containsMouse) return StyleTokens.hairlineBorderHover;
                                    return StyleTokens.transparent;
                                }

                                Behavior on color {
                                    ColorAnimation { duration: StyleTokens.animFast }
                                }
                                Behavior on border.color {
                                    ColorAnimation { duration: StyleTokens.animFast }
                                }

                                SequentialAnimation {
                                    id: secClickAnim
                                    NumberAnimation {
                                        target: secRow
                                        property: "scale"
                                        to: 0.88
                                        duration: 70
                                        easing.type: Easing.OutQuad
                                    }
                                    NumberAnimation {
                                       target: secRow
                                       property: "scale"
                                       to: 1.08
                                       duration: 110
                                       easing.type: Easing.OutBack
                                       easing.overshoot: 1.4
                                    }
                                    NumberAnimation {
                                       target: secRow
                                       property: "scale"
                                       to: 1.0
                                       duration: 80
                                       easing.type: Easing.OutQuad
                                    }
                                }

                                Timer {
                                    id: secCopiedTimer
                                    interval: 900
                                    repeat: false
                                    onTriggered: secVpnItemRoot.itemCopied = false
                                }

                                Row {
                                    id: secRow
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    spacing: 6

                                    Text {
                                        width: 14
                                        horizontalAlignment: Text.AlignHCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: secVpnItemRoot.itemCopied ? "󰄬" : "󰖂"
                                        font.family: StyleTokens.monoFontFamily
                                        font.pixelSize: 12
                                        color: secVpnItemRoot.itemCopied ? Qt.rgba(48/255, 209/255, 88/255, 1.0) : StyleTokens.textSecondary

                                        Behavior on color {
                                            ColorAnimation { duration: StyleTokens.animFast }
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.iface + ": " + modelData.ip
                                        font.family: StyleTokens.monoFontFamily
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        color: StyleTokens.textPrimary
                                    }
                                }

                                MouseArea {
                                    id: secMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onEntered: {
                                        vpnBadge.dropdownHovered = true;
                                        vpnBadge.stopCloseTimer();
                                    }
                                    onExited: {
                                        vpnBadge.restartCloseTimer();
                                    }

                                    onClicked: {
                                        vpnBadge.copyText(modelData.ip);
                                        secVpnItemRoot.itemCopied = true;
                                        secCopiedTimer.restart();
                                        secClickAnim.restart();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Row {
        id: innerRow
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        z: 3

        // 1. Arch Logo Launcher
        ArchLauncher {}

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 2. Workspaces 1-5
        WorkspaceList {}

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 3. Target IP Telemetry
        TargetBadge {
            id: targetBadge
        }

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 4. VPN Status Telemetry
        VpnBadge {
            id: vpnBadge
        }
    }
}
