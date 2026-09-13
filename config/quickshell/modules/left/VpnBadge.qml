import QtQuick
import Quickshell.Io
import "../.."
import "../../components"

Rectangle {
    id: vpnRoot
    height: 26
    width: vpnText.implicitWidth + 18
    radius: StyleTokens.capsuleRadius
    anchors.verticalCenter: parent.verticalCenter

    property var vpnList: []
    readonly property var primaryVpn: vpnList.length > 0 ? vpnList[0] : null
    readonly property var secondaryVpns: vpnList.length > 1 ? vpnList.slice(1) : []
    readonly property bool isConnected: primaryVpn !== null

    property bool isCopied: false
    property bool isHovered: false
    property bool dropdownHovered: false
    property bool isDrawerActive: true
    readonly property bool dropdownOpen: isDrawerActive && (isHovered || dropdownHovered || closeTimer.running) && (secondaryVpns.length > 0)
    property alias drawer: vpnDrawer
    readonly property real drawerHeight: vpnDrawer.height
    readonly property real contentHeight: vpnDrawer.contentHeight
    property int scrollIndex: 0

    onDropdownOpenChanged: {
        if (!dropdownOpen) vpnRoot.scrollIndex = 0;
    }

    HoverHandler {
        id: rootHover
        onHoveredChanged: {
            if (hovered) {
                vpnRoot.isHovered = true;
                closeTimer.stop();
            } else {
                vpnRoot.isHovered = false;
                closeTimer.restart();
            }
        }
    }

    color: {
        if (isCopied) return Qt.rgba(48/255, 209/255, 88/255, 0.35);
        if (vpnMouse.containsMouse && isConnected) return StyleTokens.vpnGreenHover;
        if (dropdownOpen && isConnected) return Qt.rgba(48/255, 209/255, 88/255, 0.20);
        return StyleTokens.transparent;
    }
    border.width: 1
    border.color: {
        if (isCopied) return Qt.rgba(48/255, 209/255, 88/255, 0.75);
        if (vpnMouse.containsMouse && isConnected) return Qt.rgba(48/255, 209/255, 88/255, 0.45);
        if (dropdownOpen && isConnected) return Qt.rgba(48/255, 209/255, 88/255, 0.30);
        return StyleTokens.transparent;
    }

    Behavior on color { ColorAnimation { duration: StyleTokens.animFast } }
    Behavior on border.color { ColorAnimation { duration: StyleTokens.animFast } }

    SequentialAnimation {
        id: clickAnim
        NumberAnimation { target: vpnText; property: "scale"; to: 0.88; duration: 70; easing.type: Easing.OutQuad }
        NumberAnimation { target: vpnText; property: "scale"; to: 1.08; duration: 110; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
        NumberAnimation { target: vpnText; property: "scale"; to: 1.0; duration: 80; easing.type: Easing.OutQuad }
    }

    Timer {
        id: copiedResetTimer
        interval: 900
        repeat: false
        onTriggered: vpnRoot.isCopied = false
    }

    Timer {
        id: closeTimer
        interval: 320
        repeat: false
        onTriggered: {
            if (!vpnMouse.containsMouse && !rootHover.hovered && !vpnDrawer.isDrawerHovered) {
                vpnRoot.isHovered = false;
                vpnRoot.dropdownHovered = false;
            }
        }
    }

    function closeDrawerImmediately() {
        vpnRoot.isHovered = false;
        vpnRoot.dropdownHovered = false;
        closeTimer.stop();
    }

    // Telemetry Process via helper script
    Process {
        id: vpnReader
        command: ["python3", "-c", "import os, subprocess; s = os.path.expanduser('~/.config/hypr/scripts/helpers/get-vpn-status.py'); print(subprocess.check_output(['python3', s], text=True) if os.path.exists(s) else '[]')"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    vpnRoot.vpnList = JSON.parse(data) || [];
                    var maxIndex = Math.max(0, vpnRoot.secondaryVpns.length - 2);
                    if (vpnRoot.scrollIndex > maxIndex) vpnRoot.scrollIndex = maxIndex;
                } catch(e) {}
            }
        }
    }

    Process {
        id: copyProc
        property string textToCopy: ""
        command: ["wl-copy", textToCopy]
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: vpnReader.running = true
    }

    Text {
        id: vpnText
        anchors.centerIn: parent
        text: vpnRoot.isConnected ? vpnRoot.primaryVpn.ip : "VPN Off"
        font.family: vpnRoot.isConnected ? StyleTokens.monoFontFamily : StyleTokens.fontFamily
        font.pixelSize: 12
        font.weight: vpnRoot.isConnected ? Font.DemiBold : Font.Normal
        color: vpnRoot.isCopied ? Qt.rgba(48/255, 209/255, 88/255, 1.0) : (vpnRoot.isConnected ? StyleTokens.textPrimary : StyleTokens.textSecondary)

        Behavior on color { ColorAnimation { duration: StyleTokens.animFast } }
    }

    MouseArea {
        id: vpnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: vpnRoot.isConnected ? Qt.PointingHandCursor : Qt.ArrowCursor

        onEntered: { vpnRoot.isHovered = true; closeTimer.stop(); }
        onExited: { vpnRoot.isHovered = false; closeTimer.restart(); }
        onClicked: {
            if (vpnRoot.isConnected) {
                copyProc.textToCopy = vpnRoot.primaryVpn.ip;
                copyProc.running = true;
                vpnRoot.isCopied = true;
                copiedResetTimer.restart();
                clickAnim.restart();
            }
        }
        onWheel: wheel => {
            if (vpnRoot.dropdownOpen) vpnDrawer.wheelScrolled(wheel);
        }
    }

    // Modular Secondary VPNs Drawer
    IslandDrawer {
        id: vpnDrawer
        open: vpnRoot.dropdownOpen
        closeTimer: closeTimer
        preferredWidth: vpnRoot.width + 18
        alignment: Qt.AlignRight

        readonly property int visibleCount: Math.min(vpnRoot.secondaryVpns.length, 2)
        contentHeight: visibleCount > 0 ? (4 + visibleCount * 26 + (visibleCount > 1 ? (visibleCount - 1) * 4 : 0) + 8) : 0

        onDrawerHoverChanged: hovered => vpnRoot.dropdownHovered = hovered
        onWheelScrolled: wheel => {
            var maxIndex = Math.max(0, vpnRoot.secondaryVpns.length - 2);
            if (wheel.angleDelta.y < 0 && vpnRoot.scrollIndex < maxIndex) vpnRoot.scrollIndex++;
            else if (wheel.angleDelta.y > 0 && vpnRoot.scrollIndex > 0) vpnRoot.scrollIndex--;
        }

        Column {
            id: vpnColumn
            width: parent.width
            spacing: 4
            y: -vpnRoot.scrollIndex * 30
            opacity: vpnRoot.dropdownOpen ? 1.0 : 0.0

            Behavior on y {
                NumberAnimation { duration: 260; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }
            Behavior on opacity {
                NumberAnimation { duration: vpnRoot.dropdownOpen ? 200 : 160; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: vpnRoot.secondaryVpns
                DrawerItem {
                    id: vpnItem
                    width: vpnColumn.width
                    index: model.index
                    active: vpnRoot.dropdownOpen
                    drawer: vpnDrawer
                    icon: "󰒍"
                    text: (modelData.iface ? modelData.iface + ": " : "") + modelData.ip
                    hoverColor: Qt.rgba(48/255, 209/255, 88/255, 0.28)
                    hoverBorderColor: Qt.rgba(48/255, 209/255, 88/255, 0.55)
                    accentColor: Qt.rgba(48/255, 209/255, 88/255, 0.85)
                    copiedBaseColor: Qt.rgba(48/255, 209/255, 88/255, 1.0)

                    onClicked: {
                        copyProc.textToCopy = modelData.ip;
                        copyProc.running = true;
                        vpnItem.triggerCopied();
                    }
                }
            }
        }
    }
}
