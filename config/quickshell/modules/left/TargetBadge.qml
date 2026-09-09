import QtQuick
import Quickshell.Io
import "../.."

Rectangle {
    id: targetRoot
    height: 26
    width: targetRow.implicitWidth + 18
    radius: StyleTokens.capsuleRadius
    anchors.verticalCenter: parent.verticalCenter

    property string targetIp: ""
    property var domains: []
    readonly property bool isSet: targetIp.length > 0 && targetIp !== "Unset"
    property bool isCopied: false

    property bool isHovered: false
    property bool dropdownHovered: false
    readonly property bool dropdownOpen: (isHovered || dropdownHovered || closeTimer.running) && (domains.length > 0)
    
    readonly property int visibleCount: Math.min(domains.length, 2)
    readonly property real contentHeight: visibleCount > 0 ? (visibleCount * 26 + (visibleCount > 1 ? 4 : 0) + 12) : 0
    property int scrollIndex: 0

    function copyText(txt) {
        copyProc.textToCopy = txt;
        copyProc.running = true;
    }

    function deleteDomain(dom) {
        deleteDomainProc.domainToDelete = dom;
        deleteDomainProc.running = true;
    }

    function clearIp() {
        clearIpProc.running = true;
    }

    function restartCloseTimer() {
        closeTimer.restart();
    }

    function stopCloseTimer() {
        closeTimer.stop();
    }

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
        if (isCopied) return Qt.rgba(10/255, 132/255, 255/255, 0.35)
        if (targetMouse.containsMouse && isSet) return StyleTokens.targetBlueHover
        return StyleTokens.transparent
    }
    border.width: 1
    border.color: {
        if (isCopied) return Qt.rgba(10/255, 132/255, 255/255, 0.75)
        if (targetMouse.containsMouse && isSet) return Qt.rgba(10/255, 132/255, 255/255, 0.45)
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
            target: targetRow
            property: "scale"
            to: 0.88
            duration: 70
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: targetRow
            property: "scale"
            to: 1.08
            duration: 110
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
        NumberAnimation {
            target: targetRow
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
        interval: 220
        repeat: false
        onTriggered: {
            targetRoot.isHovered = false;
            targetRoot.dropdownHovered = false;
        }
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

    Row {
        id: targetRow
        spacing: 6
        anchors.centerIn: parent

        Text {
            width: 14
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
            text: targetRoot.isCopied ? "󰄬" : "󰓾"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 13
            color: targetRoot.isCopied ? Qt.rgba(10/255, 132/255, 255/255, 1.0) : (targetRoot.isSet ? StyleTokens.textPrimary : StyleTokens.textSecondary)

            Behavior on color {
                ColorAnimation { duration: StyleTokens.animFast }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: targetRoot.isSet ? targetRoot.targetIp : "Unset"
            font.family: targetRoot.isSet ? StyleTokens.monoFontFamily : StyleTokens.fontFamily
            font.pixelSize: 12
            font.weight: targetRoot.isSet ? Font.DemiBold : Font.Normal
            color: targetRoot.isSet ? StyleTokens.textPrimary : StyleTokens.textSecondary
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
            closeTimer.restart();
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (targetRoot.isSet) {
                    targetRoot.clearIp();
                }
            } else {
                if (targetRoot.isSet) {
                    targetRoot.copyText(targetRoot.targetIp);
                    targetRoot.isCopied = true;
                    copiedResetTimer.restart();
                    clickAnim.restart();
                }
            }
        }
    }
}
