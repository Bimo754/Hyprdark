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

    color: {
        if (vpnMouse.containsMouse && isConnected) return StyleTokens.vpnGreenHover
        return StyleTokens.transparent
    }
    border.width: 1
    border.color: {
        if (vpnMouse.containsMouse && isConnected) return Qt.rgba(48/255, 209/255, 88/255, 0.45)
        return StyleTokens.transparent
    }

    Behavior on color {
        ColorAnimation { duration: StyleTokens.animFast }
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
            anchors.verticalCenter: parent.verticalCenter
            text: "󰖂"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 13
            color: vpnRoot.isConnected ? StyleTokens.textPrimary : StyleTokens.textSecondary
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
            if (vpnRoot.isConnected) copyProc.running = true
        }
    }
}
