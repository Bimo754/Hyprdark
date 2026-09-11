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

    Behavior on color {
        ColorAnimation { duration: StyleTokens.animFast }
    }
    Behavior on border.color {
        ColorAnimation { duration: StyleTokens.animFast }
    }

    SequentialAnimation {
        id: clickAnim
        NumberAnimation {
            target: vpnText
            property: "scale"
            to: 0.88
            duration: 70
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: vpnText
            property: "scale"
            to: 1.08
            duration: 110
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
        NumberAnimation {
            target: vpnText
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
        interval: 320
        repeat: false
        onTriggered: {
            if (!vpnRoot.isHovered && !vpnDrawer.isDrawerHovered) {
                vpnRoot.dropdownHovered = false;
            }
        }
    }

    function closeDrawerImmediately() {
        vpnRoot.isHovered = false;
        vpnRoot.dropdownHovered = false;
        closeTimer.stop();
    }

    Process {
        id: vpnReader
        command: ["python3", "-c", "import subprocess, json, re, os; vpns=[];\ntry:\n out=subprocess.check_output(['ip','-o','-4','addr','show'], text=True)\n for l in out.splitlines():\n  p=l.split()\n  if len(p)>=4 and re.match(r'^(tun|wg|tap|ppp|tailscale|nord|proton)', p[1]):\n   vpns.append({'iface':p[1], 'ip':p[3].split('/')[0]})\n vpns.sort(key=lambda x:x['iface'])\nexcept Exception:\n pass\nif not vpns:\n f=os.path.expanduser('~/.local/share/hyprdark/vpn_ip')\n if os.path.exists(f):\n  c=open(f).read().strip()\n  if c and c!='Off':\n   try:\n    parsed=json.loads(c)\n    if isinstance(parsed, list): vpns=parsed\n   except Exception:\n    for idx, line in enumerate(c.splitlines()):\n     l=line.strip()\n     if l and l!='Off':\n      if ':' in l:\n       pts=l.split(':',1)\n       vpns.append({'iface':pts[0].strip(), 'ip':pts[1].strip()})\n      else:\n       vpns.append({'iface':f'tun{idx}', 'ip':l})\nprint(json.dumps(vpns))"]
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

    Text {
        id: vpnText
        anchors.centerIn: parent
        text: vpnRoot.isConnected ? vpnRoot.primaryVpn.ip : "Off"
        font.family: vpnRoot.isConnected ? StyleTokens.monoFontFamily : StyleTokens.fontFamily
        font.pixelSize: 12
        font.weight: vpnRoot.isConnected ? Font.DemiBold : Font.Normal
        color: vpnRoot.isCopied ? Qt.rgba(48/255, 209/255, 88/255, 1.0) : (vpnRoot.isConnected ? StyleTokens.textPrimary : StyleTokens.textSecondary)

        Behavior on color {
            ColorAnimation { duration: StyleTokens.animFast }
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

    // Modular Secondary VPNs Drawer
    IslandDrawer {
        id: vpnDrawer
        open: vpnRoot.dropdownOpen
        closeTimer: closeTimer
        preferredWidth: Math.round(vpnRoot.width + 22.5)
        alignment: Qt.AlignRight
        horizontalOffset: 12
        innerRightMargin: 8
        innerLeftMargin: 4

        readonly property int secCount: vpnRoot.secondaryVpns.length
        contentHeight: secCount > 0 ? (4 + secCount * 26 + (secCount > 1 ? (secCount - 1) * 4 : 0) + 8) : 0

        onDrawerHoverChanged: hovered => {
            vpnRoot.dropdownHovered = hovered;
        }

        Column {
            id: secVpnColumn
            width: parent.width
            spacing: 4
            opacity: vpnRoot.dropdownOpen ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: vpnRoot.dropdownOpen ? 180 : 120; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: vpnRoot.secondaryVpns

                DrawerItem {
                    id: secVpnItem
                    width: secVpnColumn.width
                    index: model.index
                    active: vpnRoot.dropdownOpen
                    drawer: vpnDrawer
                    icon: "󰖂"
                    text: modelData.iface + ": " + modelData.ip
                    hoverColor: Qt.rgba(48/255, 209/255, 88/255, 0.28)
                    hoverBorderColor: Qt.rgba(48/255, 209/255, 88/255, 0.55)
                    accentColor: Qt.rgba(48/255, 209/255, 88/255, 0.85)
                    copiedBaseColor: Qt.rgba(48/255, 209/255, 88/255, 1.0)

                    onClicked: {
                        copyProc.textToCopy = modelData.ip;
                        copyProc.running = true;
                        secVpnItem.triggerCopied();
                    }
                }
            }
        }
    }
}
