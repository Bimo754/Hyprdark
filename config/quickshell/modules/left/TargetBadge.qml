import QtQuick
import Quickshell.Io
import "../.."

Rectangle {
    id: targetRoot
    height: 24
    width: targetRow.implicitWidth + 16
    radius: StyleTokens.capsuleRadius
    anchors.verticalCenter: parent.verticalCenter

    property string targetIp: ""
    readonly property bool isSet: targetIp.length > 0 && targetIp !== "Unset"

    color: {
        if (targetMouse.containsMouse && isSet) return StyleTokens.targetBlueHover
        return StyleTokens.transparent
    }
    border.width: 1
    border.color: {
        if (targetMouse.containsMouse && isSet) return Qt.rgba(10/255, 132/255, 255/255, 0.45)
        return StyleTokens.transparent
    }

    Behavior on color {
        ColorAnimation { duration: StyleTokens.animFast }
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
        spacing: 5
        anchors.centerIn: parent

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰓾"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 12
            color: targetRoot.isSet ? StyleTokens.textPrimary : StyleTokens.textSecondary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: targetRoot.isSet ? targetRoot.targetIp : "Unset"
            font.family: targetRoot.isSet ? StyleTokens.monoFontFamily : StyleTokens.fontFamily
            font.pixelSize: 11
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
            if (targetRoot.isSet) copyProc.running = true
        }
    }
}
