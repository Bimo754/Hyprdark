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
    property color hoverColor: StyleTokens.surfaceHover
    property color hoverBorderColor: StyleTokens.hairlineBorderHover
    property bool isCopied: false

    signal clicked(var mouse)
    signal rightClicked()
    signal itemHovered(bool hovered)
    signal wheelScrolled(var wheel)

    function triggerCopied() {
        itemRoot.isCopied = true;
        copiedTimer.restart();
        clickAnim.restart();
    }

    width: parent ? parent.width : 160
    height: 26
    radius: StyleTokens.capsuleRadius

    opacity: itemRoot.active ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation {
            duration: itemRoot.active ? 180 : 100
            easing.type: Easing.OutCubic
        }
    }

    color: {
        if (isCopied) return Qt.rgba(copiedBaseColor.r, copiedBaseColor.g, copiedBaseColor.b, 0.35);
        if (itemMouse.containsMouse) return itemRoot.hoverColor;
        return StyleTokens.transparent;
    }
    border.width: 1
    border.color: {
        if (isCopied) return Qt.rgba(copiedBaseColor.r, copiedBaseColor.g, copiedBaseColor.b, 0.75);
        if (itemMouse.containsMouse) return itemRoot.hoverBorderColor;
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
            target: itemText
            property: "scale"
            to: 0.86
            duration: 60
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: itemText
            property: "scale"
            to: 1.12
            duration: 120
            easing.type: Easing.OutBack
            easing.overshoot: 1.6
        }
        NumberAnimation {
            target: itemText
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

    Text {
        id: itemText
        anchors.centerIn: parent
        width: parent.width - 16
        horizontalAlignment: Text.AlignHCenter
        text: itemRoot.text
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 11
        font.weight: Font.DemiBold
        color: itemRoot.isCopied ? itemRoot.copiedBaseColor : StyleTokens.textPrimary
        elide: Text.ElideRight

        Behavior on color {
            ColorAnimation { duration: StyleTokens.animFast }
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

        onWheel: wheel => {
            itemRoot.wheelScrolled(wheel);
            if (itemRoot.drawer) {
                itemRoot.drawer.wheelScrolled(wheel);
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
