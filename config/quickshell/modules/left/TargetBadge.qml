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
    readonly property bool isSet: targetIp.length > 0 && targetIp !== "Unset"
    property bool isCopied: false

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
            target: targetRoot
            property: "scale"
            to: 0.90
            duration: 70
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: targetRoot
            property: "scale"
            to: 1.05
            duration: 110
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
        NumberAnimation {
            target: targetRoot
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

    Process {
        id: targetReader
        command: ["bash", "-c", "target_file=~/.local/share/hyprdark/target_ip; [ -f \"$target_file\" ] && cat \"$target_file\" | tr -d '\\r\\n' || echo ''"]
        stdout: SplitParser {
            onRead: data => targetRoot.targetIp = data.trim()
        }
    }

    Process {
        id: copyProc
        command: ["wl-copy", targetRoot.targetIp]
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
        cursorShape: targetRoot.isSet ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (targetRoot.isSet) {
                copyProc.running = true
                targetRoot.isCopied = true
                copiedResetTimer.restart()
                clickAnim.restart()
            }
        }
    }
}
