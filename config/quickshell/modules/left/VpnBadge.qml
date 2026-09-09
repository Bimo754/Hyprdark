import QtQuick
import Quickshell.Io
import "../.."

Rectangle {
    id: vpnRoot
    height: 26
    width: vpnRow.implicitWidth + 18
    radius: StyleTokens.capsuleRadius
    anchors.verticalCenter: parent.verticalCenter

    property string vpnIp: ""
    readonly property bool isConnected: vpnIp.length > 0 && vpnIp !== "Off"
    property bool isCopied: false

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

    Process {
        id: vpnReader
        command: ["bash", "-c", "ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}' || ip -4 addr show wg0 2>/dev/null | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}' || ([ -f ~/.local/share/hyprdark/vpn_ip ] && cat ~/.local/share/hyprdark/vpn_ip | tr -d '\\r\\n') || echo ''"]
        stdout: SplitParser {
            onRead: data => vpnRoot.vpnIp = data.trim()
        }
    }

    Process {
        id: copyProc
        command: ["wl-copy", vpnRoot.vpnIp]
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
            text: vpnRoot.isConnected ? vpnRoot.vpnIp : "Off"
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
        onClicked: {
            if (vpnRoot.isConnected) {
                copyProc.running = true
                vpnRoot.isCopied = true
                copiedResetTimer.restart()
                clickAnim.restart()
            }
        }
    }
}
