import QtQuick
import Quickshell.Io
import "../.."

Rectangle {
    id: vpnRoot
    height: 26
    width: vpnRow.implicitWidth + 18
    radius: StyleTokens.capsuleRadius
    anchors.verticalCenter: parent.verticalCenter

    property var vpnList: []
    readonly property var primaryVpn: vpnList.length > 0 ? vpnList[0] : null
    readonly property var secondaryVpns: vpnList.length > 1 ? vpnList.slice(1) : []
    readonly property bool isConnected: primaryVpn !== null

    property bool isCopied: false
    property bool isHovered: false
    property bool dropdownHovered: false
    readonly property bool dropdownOpen: (isHovered || dropdownHovered || closeTimer.running) && (secondaryVpns.length > 0)

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

    scale: 1.0

    color: {
        if (isCopied) return Qt.rgba(48/255, 209/255, 88/255, 0.35)
        if (vpnMouse.containsMouse && isConnected) return StyleTokens.vpnGreenHover
        return StyleTokens.transparent
    }
    border.width: 1
    border.color: {
        if (isCopied) return Qt.rgba(48/255, 209/255, 88/255, 0.75)
        if (vpnMouse.containsMouse && isConnected) return Qt.rgba(48/255, 209/255, 88/255, 0.45)
        return StyleTokens.transparent
    }

    Behavior on color {
        ColorAnimation { duration: StyleTokens.animFast }
    }
    Behavior on border.color {
        ColorAnimation { duration: StyleTokens.animFast }
    }

    SequentialAnimation {
        id: clickAnim
        NumberAnimation {
            target: vpnRow
            property: "scale"
            to: 0.88
            duration: 70
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: vpnRow
            property: "scale"
            to: 1.08
            duration: 110
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
        NumberAnimation {
            target: vpnRow
            property: "scale"
            to: 1.0
            duration: 80
            easing.type: Easing.OutQuad
        }
    }

    Timer {
        id: copiedResetTimer
        interval: 900
        repeat: false
        onTriggered: vpnRoot.isCopied = false
    }

    Timer {
        id: closeTimer
        interval: 220
        repeat: false
        onTriggered: {
            vpnRoot.isHovered = false;
            vpnRoot.dropdownHovered = false;
        }
    }

    Process {
        id: vpnReader
        command: ["python3", "-c", "import subprocess, json, re, os; vpns=[];\ntry:\n out=subprocess.check_output(['ip','-o','-4','addr','show'], text=True)\n for l in out.splitlines():\n  p=l.split()\n  if len(p)>=4 and re.match(r'^(tun|wg|tap|ppp|tailscale|nord|proton)', p[1]):\n   vpns.append({'iface':p[1], 'ip':p[3].split('/')[0]})\n vpns.sort(key=lambda x:x['iface'])\nexcept Exception:\n pass\nif not vpns:\n f=os.path.expanduser('~/.local/share/hyprdark/vpn_ip')\n if os.path.exists(f):\n  v=open(f).read().strip()\n  if v and v!='Off': vpns.append({'iface':'tun0','ip':v})\nprint(json.dumps(vpns))"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    vpnRoot.vpnList = JSON.parse(data) || [];
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

    Row {
        id: vpnRow
        spacing: 6
        anchors.centerIn: parent

        Text {
            width: 14
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
            text: vpnRoot.isCopied ? "󰄬" : "󰖂"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 13
            color: vpnRoot.isCopied ? Qt.rgba(48/255, 209/255, 88/255, 1.0) : (vpnRoot.isConnected ? StyleTokens.textPrimary : StyleTokens.textSecondary)

            Behavior on color {
                ColorAnimation { duration: StyleTokens.animFast }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: vpnRoot.isConnected ? vpnRoot.primaryVpn.ip : "Off"
            font.family: vpnRoot.isConnected ? StyleTokens.monoFontFamily : StyleTokens.fontFamily
            font.pixelSize: 12
            font.weight: vpnRoot.isConnected ? Font.DemiBold : Font.Normal
            color: vpnRoot.isConnected ? StyleTokens.textPrimary : StyleTokens.textSecondary
        }
    }

    MouseArea {
        id: vpnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: vpnRoot.isConnected ? Qt.PointingHandCursor : Qt.ArrowCursor

        onEntered: {
            vpnRoot.isHovered = true;
            closeTimer.stop();
        }
        onExited: {
            closeTimer.restart();
        }

        onClicked: {
            if (vpnRoot.isConnected) {
                copyProc.textToCopy = vpnRoot.primaryVpn.ip;
                copyProc.running = true;
                vpnRoot.isCopied = true;
                copiedResetTimer.restart();
                clickAnim.restart();
            }
        }
    }

    // Secondary VPN Drawer Container (Morphs organically from bottom edge of island)
    Rectangle {
        id: vpnDropdownCard
        y: 33
        x: -9
        width: vpnRoot.width + 18
        
        readonly property int secCount: vpnRoot.secondaryVpns.length
        readonly property real contentHeight: secCount > 0 ? (secCount * 26 + (secCount > 1 ? (secCount - 1) * 4 : 0) + 12) : 0
        
        height: vpnRoot.dropdownOpen ? contentHeight : 0
        
        bottomLeftRadius: 14
        bottomRightRadius: 14
        topLeftRadius: 0
        topRightRadius: 0
        color: StyleTokens.glassBackground
        border.width: 1
        border.color: StyleTokens.hairlineBorder
        clip: true

        visible: height > 1 || opacity > 0.01
        opacity: vpnRoot.dropdownOpen ? 1.0 : 0.0

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 1.15
            }
        }
        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        // Seamless glass bridge masking the horizontal divider seam
        Rectangle {
            id: seamBridge
            y: -2
            height: 4
            anchors.left: parent.left
            anchors.leftMargin: 1
            anchors.right: parent.right
            anchors.rightMargin: 1
            color: StyleTokens.glassBackground
            visible: vpnDropdownCard.height > 4
        }

        HoverHandler {
            id: cardHover
            onHoveredChanged: {
                if (hovered) {
                    vpnRoot.dropdownHovered = true;
                    closeTimer.stop();
                } else {
                    vpnRoot.dropdownHovered = false;
                    closeTimer.restart();
                }
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 6
            clip: true

            Column {
                id: secVpnColumn
                width: parent.width
                spacing: 4
                y: vpnRoot.dropdownOpen ? 0 : -8
                opacity: vpnRoot.dropdownOpen ? 1.0 : 0.0

                Behavior on y {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.1
                    }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }

                Repeater {
                    model: vpnRoot.secondaryVpns

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
                                vpnRoot.dropdownHovered = true;
                                closeTimer.stop();
                            }
                            onExited: {
                                closeTimer.restart();
                            }

                            onClicked: {
                                copyProc.textToCopy = modelData.ip;
                                copyProc.running = true;
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
