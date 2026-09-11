import QtQuick
import Quickshell.Io
import "../.."
import "../../components"

Rectangle {
    id: targetRoot
    height: 26
    width: targetText.implicitWidth + 18
    radius: StyleTokens.capsuleRadius
    anchors.verticalCenter: parent.verticalCenter

    property string targetIp: ""
    property var domains: []
    readonly property bool isSet: targetIp.length > 0 && targetIp !== "Unset"
    property bool isCopied: false

    property bool isHovered: false
    property bool dropdownHovered: false
    property bool isDrawerActive: true
    readonly property bool dropdownOpen: isDrawerActive && (isHovered || dropdownHovered || closeTimer.running) && (domains.length > 0)
    property alias drawer: targetDrawer
    readonly property real drawerHeight: targetDrawer.height
    readonly property real contentHeight: targetDrawer.contentHeight
    property int scrollIndex: 0

    HoverHandler {
        id: rootHover
        onHoveredChanged: {
            if (hovered) {
                targetRoot.isHovered = true;
                closeTimer.stop();
            } else {
                targetRoot.isHovered = false;
                closeTimer.restart();
            }
        }
    }

    scale: 1.0

    color: {
        if (isCopied) return Qt.rgba(10/255, 132/255, 255/255, 0.35);
        if (targetMouse.containsMouse && isSet) return StyleTokens.targetBlueHover;
        if (dropdownOpen && isSet) return Qt.rgba(10/255, 132/255, 255/255, 0.20);
        return StyleTokens.transparent;
    }
    border.width: 1
    border.color: {
        if (isCopied) return Qt.rgba(10/255, 132/255, 255/255, 0.75);
        if (targetMouse.containsMouse && isSet) return Qt.rgba(10/255, 132/255, 255/255, 0.45);
        if (dropdownOpen && isSet) return Qt.rgba(10/255, 132/255, 255/255, 0.30);
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
            target: targetText
            property: "scale"
            to: 0.88
            duration: 70
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: targetText
            property: "scale"
            to: 1.08
            duration: 110
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
        NumberAnimation {
            target: targetText
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
        onTriggered: targetRoot.isCopied = false
    }

    Timer {
        id: closeTimer
        interval: 320
        repeat: false
        onTriggered: {
            if (!targetMouse.containsMouse && !rootHover.hovered && !targetDrawer.isDrawerHovered) {
                targetRoot.isHovered = false;
                targetRoot.dropdownHovered = false;
            }
        }
    }

    function closeDrawerImmediately() {
        targetRoot.isHovered = false;
        targetRoot.dropdownHovered = false;
        closeTimer.stop();
    }

    Process {
        id: targetReader
        command: ["python3", "-c", "import os, json; d=os.path.expanduser('~/.local/share/hyprdark'); ip_f=os.path.join(d,'target_ip'); dom_f=os.path.join(d,'target_domains'); ip=open(ip_f).read().strip() if os.path.exists(ip_f) else ''; doms=[l.strip() for l in open(dom_f) if l.strip()] if os.path.exists(dom_f) else []; print(json.dumps({'ip':ip,'domains':doms}))"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data);
                    targetRoot.targetIp = parsed.ip || "";
                    targetRoot.domains = parsed.domains || [];
                    if (targetRoot.scrollIndex > Math.max(0, targetRoot.domains.length - 2)) {
                        targetRoot.scrollIndex = Math.max(0, targetRoot.domains.length - 2);
                    }
                } catch(e) {}
            }
        }
    }

    Process {
        id: clearIpProc
        command: ["bash", "-c", "/home/diamond/Desktop/Github/Hyprdark/scripts/set-target.sh --clear-ip"]
        onExited: targetReader.running = true
    }

    Process {
        id: deleteDomainProc
        property string domainToDelete: ""
        command: ["bash", "-c", "/home/diamond/Desktop/Github/Hyprdark/scripts/set-target.sh --rm '" + domainToDelete + "'"]
        onExited: targetReader.running = true
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
        onTriggered: targetReader.running = true
    }

    Text {
        id: targetText
        anchors.centerIn: parent
        text: targetRoot.isSet ? targetRoot.targetIp : "Unset"
        font.family: targetRoot.isSet ? StyleTokens.monoFontFamily : StyleTokens.fontFamily
        font.pixelSize: 12
        font.weight: targetRoot.isSet ? Font.DemiBold : Font.Normal
        color: targetRoot.isCopied ? Qt.rgba(10/255, 132/255, 255/255, 1.0) : (targetRoot.isSet ? StyleTokens.textPrimary : StyleTokens.textSecondary)

        Behavior on color {
            ColorAnimation { duration: StyleTokens.animFast }
        }
    }

    MouseArea {
        id: targetMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: targetRoot.isSet ? Qt.PointingHandCursor : Qt.ArrowCursor

        onEntered: {
            targetRoot.isHovered = true;
            closeTimer.stop();
        }
        onExited: {
            targetRoot.isHovered = false;
            closeTimer.restart();
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (targetRoot.isSet) {
                    clearIpProc.running = true;
                }
            } else {
                if (targetRoot.isSet) {
                    copyProc.textToCopy = targetRoot.targetIp;
                    copyProc.running = true;
                    targetRoot.isCopied = true;
                    copiedResetTimer.restart();
                    clickAnim.restart();
                }
            }
        }
    }

    // Modular Target Domains Drawer
    IslandDrawer {
        id: targetDrawer
        open: targetRoot.dropdownOpen
        closeTimer: closeTimer
        preferredWidth: targetRoot.width + 18
        alignment: Qt.AlignHCenter

        readonly property int visibleCount: Math.min(targetRoot.domains.length, 2)
        contentHeight: visibleCount > 0 ? (4 + visibleCount * 26 + (visibleCount > 1 ? (visibleCount - 1) * 4 : 0) + 8) : 0

        onDrawerHoverChanged: hovered => {
            targetRoot.dropdownHovered = hovered;
        }

        WheelHandler {
            onWheel: event => {
                if (event.angleDelta.y < 0) {
                    if (targetRoot.scrollIndex < targetRoot.domains.length - 2) {
                        targetRoot.scrollIndex++;
                    }
                } else if (event.angleDelta.y > 0) {
                    if (targetRoot.scrollIndex > 0) {
                        targetRoot.scrollIndex--;
                    }
                }
            }
        }

        Column {
            id: domainColumn
            width: parent.width
            spacing: 4
            y: -targetRoot.scrollIndex * 30
            opacity: targetRoot.dropdownOpen ? 1.0 : 0.0

            Behavior on y {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }
            Behavior on opacity {
                NumberAnimation { duration: targetRoot.dropdownOpen ? 200 : 160; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: targetRoot.domains

                DrawerItem {
                    id: domainItem
                    width: domainColumn.width
                    index: model.index
                    active: targetRoot.dropdownOpen
                    drawer: targetDrawer
                    icon: "󰖟"
                    text: modelData
                    hoverColor: Qt.rgba(10/255, 132/255, 255/255, 0.28)
                    hoverBorderColor: Qt.rgba(10/255, 132/255, 255/255, 0.55)
                    accentColor: Qt.rgba(10/255, 132/255, 255/255, 0.85)
                    copiedBaseColor: Qt.rgba(10/255, 132/255, 255/255, 1.0)

                    onClicked: {
                        copyProc.textToCopy = modelData;
                        copyProc.running = true;
                        domainItem.triggerCopied();
                    }

                    onRightClicked: {
                        deleteDomainProc.domainToDelete = modelData;
                        deleteDomainProc.running = true;
                    }
                }
            }
        }
    }
}
