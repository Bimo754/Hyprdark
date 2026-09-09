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
    readonly property real drawerHeight: dropdownCard.height
    readonly property real contentHeight: dropdownCard.contentHeight
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

    // Drawer Extension Container (Items rendered over unified island shape)
    Item {
        id: dropdownCard
        y: 33
        x: -9
        width: targetRoot.width + 18
        
        readonly property int visibleCount: Math.min(targetRoot.domains.length, 2)
        readonly property real contentHeight: visibleCount > 0 ? (visibleCount * 26 + (visibleCount > 1 ? 4 : 0) + 12) : 0
        
        height: Math.max(0, targetRoot.dropdownOpen ? contentHeight : 0)
        clip: true

        visible: height > 1 && opacity > 0.01
        opacity: targetRoot.dropdownOpen ? 1.0 : 0.0

        Behavior on height {
            NumberAnimation {
                duration: targetRoot.dropdownOpen ? 240 : 180
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation { duration: targetRoot.dropdownOpen ? 160 : 90; easing.type: Easing.OutCubic }
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

        HoverHandler {
            id: cardHover
            onHoveredChanged: {
                if (hovered) {
                    targetRoot.dropdownHovered = true;
                    closeTimer.stop();
                } else {
                    targetRoot.dropdownHovered = false;
                    closeTimer.restart();
                }
            }
        }

        Item {
            id: domainListViewport
            anchors.fill: parent
            anchors.margins: 6
            clip: true
            visible: dropdownCard.height > 12

            Column {
                id: domainColumn
                width: parent.width
                spacing: 4
                y: -targetRoot.scrollIndex * 30
                opacity: targetRoot.dropdownOpen ? 1.0 : 0.0

                Behavior on y {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation { duration: targetRoot.dropdownOpen ? 180 : 120; easing.type: Easing.OutCubic }
                }

                Repeater {
                    model: targetRoot.domains

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
                                targetRoot.dropdownHovered = true;
                                closeTimer.stop();
                            }
                            onExited: {
                                closeTimer.restart();
                            }

                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    deleteDomainProc.domainToDelete = modelData;
                                    deleteDomainProc.running = true;
                                } else {
                                    copyProc.textToCopy = modelData;
                                    copyProc.running = true;
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
    }
}
