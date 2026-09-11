import QtQuick
import ".."

Rectangle {
    id: itemRoot

    property int index: 0
    property bool active: true
    property var drawer: null

    property string icon: ""
    property string text: ""
    property color accentColor: StyleTokens.textSecondary
    property color copiedBaseColor: Qt.rgba(10/255, 132/255, 255/255, 1.0)
    property bool isCopied: false

    signal clicked(var mouse)
    signal rightClicked()
    signal itemHovered(bool hovered)

    function triggerCopied() {
        itemRoot.isCopied = true;
        copiedTimer.restart();
        clickAnim.restart();
    }

    width: parent ? parent.width : 160
    height: 26
    radius: StyleTokens.capsuleRadius

    // Cascading spring reveal
    property real entryY: active ? 0 : -8
    property real entryScale: active ? 1.0 : 0.88
    property real entryOpacity: active ? 1.0 : 0.0

    transform: [
        Translate {
            y: itemRoot.entryY
        },
        Scale {
            origin.x: itemRoot.width / 2
            origin.y: itemRoot.height / 2
            xScale: itemRoot.entryScale
            yScale: itemRoot.entryScale
        }
    ]
    opacity: itemRoot.entryOpacity

    Behavior on entryY {
        SequentialAnimation {
            PauseAnimation { duration: itemRoot.active ? Math.max(0, itemRoot.index * 35) : 0 }
            NumberAnimation {
                duration: itemRoot.active ? 280 : 120
                easing.type: itemRoot.active ? Easing.OutBack : Easing.OutCubic
                easing.overshoot: 1.35
            }
        }
    }
    Behavior on entryScale {
        SequentialAnimation {
            PauseAnimation { duration: itemRoot.active ? Math.max(0, itemRoot.index * 35) : 0 }
            NumberAnimation {
                duration: itemRoot.active ? 280 : 120
                easing.type: itemRoot.active ? Easing.OutBack : Easing.OutCubic
                easing.overshoot: 1.35
            }
        }
    }
    Behavior on entryOpacity {
        SequentialAnimation {
            PauseAnimation { duration: itemRoot.active ? Math.max(0, itemRoot.index * 25) : 0 }
            NumberAnimation {
                duration: itemRoot.active ? 180 : 100
                easing.type: Easing.OutCubic
            }
        }
    }

    color: {
        if (isCopied) return Qt.rgba(copiedBaseColor.r, copiedBaseColor.g, copiedBaseColor.b, 0.35);
        if (itemMouse.containsMouse) return StyleTokens.surfaceHover;
        return StyleTokens.transparent;
    }
    border.width: 1
    border.color: {
        if (isCopied) return Qt.rgba(copiedBaseColor.r, copiedBaseColor.g, copiedBaseColor.b, 0.75);
        if (itemMouse.containsMouse) return StyleTokens.hairlineBorderHover;
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
            target: rowContent
            property: "scale"
            to: 0.86
            duration: 60
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: rowContent
            property: "scale"
            to: 1.12
            duration: 120
            easing.type: Easing.OutBack
            easing.overshoot: 1.6
        }
        NumberAnimation {
            target: rowContent
            property: "scale"
            to: 1.0
            duration: 80
            easing.type: Easing.OutQuad
        }
    }

    Timer {
        id: copiedTimer
        interval: 900
        repeat: false
        onTriggered: itemRoot.isCopied = false
    }

    Row {
        id: rowContent
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        spacing: 4

        Text {
            id: iconText
            width: 14
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
            text: itemRoot.isCopied ? "󰄬" : itemRoot.icon
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 12
            color: itemRoot.isCopied ? itemRoot.copiedBaseColor : itemRoot.accentColor

            scale: itemMouse.containsMouse ? 1.16 : 1.0
            rotation: itemRoot.isCopied ? 0 : (itemMouse.containsMouse ? -4 : 0)

            Behavior on scale {
                NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
            }
            Behavior on rotation {
                NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
            }
            Behavior on color {
                ColorAnimation { duration: StyleTokens.animFast }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 18
            text: itemRoot.text
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: StyleTokens.textPrimary
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            itemRoot.itemHovered(true);
            if (itemRoot.drawer) {
                itemRoot.drawer.handleChildHover(true);
            }
        }

        onExited: {
            itemRoot.itemHovered(false);
            if (itemRoot.drawer) {
                itemRoot.drawer.handleChildHover(false);
            }
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                itemRoot.rightClicked();
            } else {
                itemRoot.clicked(mouse);
            }
        }
    }
}
