import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import ".."
import "../components"

IslandCapsule {
    id: leftIslandRoot

    property int activeWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    property string targetIp: ""
    property string vpnIp: ""
    property bool vpnConnected: false

    implicitHeight: 38
    implicitWidth: leftRow.implicitWidth + 24

    Row {
        id: leftRow
        anchors.centerIn: parent
        spacing: 12

        // 1. Arch Logo Launcher
        Rectangle {
            id: archButton
            width: 28
            height: 28
            radius: StyleTokens.capsuleRadius
            anchors.verticalCenter: parent.verticalCenter
            color: archMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

            Text {
                anchors.centerIn: parent
                text: "󰣇"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 15
                color: StyleTokens.textPrimary
            }

            MouseArea {
                id: archMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    launcherProc.running = true
                }
            }

            Process {
                id: launcherProc
                command: ["rofi", "-show", "drun", "-theme", "/home/diamond/.config/rofi/theme.rasi"]
            }
        }

        // Hairline Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 2. Workspaces 1 - 10
        Row {
            id: wsRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Repeater {
                model: 5 // Default show 1-5, or dynamically active

                Rectangle {
                    id: wsButton
                    property int wsId: modelData + 1
                    property bool isActive: leftIslandRoot.activeWorkspaceId === wsId

                    width: isActive ? 26 : 22
                    height: 24
                    radius: StyleTokens.capsuleRadius
                    color: isActive ? StyleTokens.activePill : (wsMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent)

                    Behavior on width {
                        NumberAnimation { duration: StyleTokens.animFast; easing.type: Easing.OutQuad }
                    }

                    Behavior on color {
                        ColorAnimation { duration: StyleTokens.animFast }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: String(wsButton.wsId)
                        font.family: StyleTokens.fontFamily
                        font.pixelSize: 12
                        font.weight: wsButton.isActive ? Font.Bold : Font.Normal
                        color: wsButton.isActive ? StyleTokens.activePillText : StyleTokens.textSecondary
                    }

                    MouseArea {
                        id: wsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wsDispatchProc.command = ["hyprctl", "dispatch", "workspace", String(wsButton.wsId)]
                            wsDispatchProc.running = true
                        }
                    }
                }
            }

            Process {
                id: wsDispatchProc
            }
        }

        // Hairline Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 3. Target IP Telemetry (󰓾)
        Rectangle {
            id: targetModule
            property bool isSet: leftIslandRoot.targetIp.length > 0
            height: 26
            width: targetRow.implicitWidth + 14
            radius: StyleTokens.capsuleRadius
            anchors.verticalCenter: parent.verticalCenter
            color: targetMouse.containsMouse ? (isSet ? StyleTokens.targetBlueHover : StyleTokens.surfaceHover) : StyleTokens.transparent

            Row {
                id: targetRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰓾"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 13
                    color: targetModule.isSet ? "#38bdf8" : StyleTokens.textSecondary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: targetModule.isSet ? leftIslandRoot.targetIp : "Unset"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: targetModule.isSet ? StyleTokens.textPrimary : StyleTokens.textSecondary
                }
            }

            MouseArea {
                id: targetMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (targetModule.isSet) {
                        copyTargetProc.command = ["wl-copy", leftIslandRoot.targetIp]
                        copyTargetProc.running = true
                    }
                }
            }

            Process {
                id: copyTargetProc
            }
        }

        // 4. VPN Status Telemetry (󰖂)
        Rectangle {
            id: vpnModule
            height: 26
            width: vpnRow.implicitWidth + 14
            radius: StyleTokens.capsuleRadius
            anchors.verticalCenter: parent.verticalCenter
            color: vpnMouse.containsMouse ? (leftIslandRoot.vpnConnected ? StyleTokens.vpnGreenHover : StyleTokens.surfaceHover) : StyleTokens.transparent

            Row {
                id: vpnRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰖂"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 13
                    color: leftIslandRoot.vpnConnected ? "#4ade80" : StyleTokens.textSecondary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: leftIslandRoot.vpnConnected ? leftIslandRoot.vpnIp : "Off"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: leftIslandRoot.vpnConnected ? StyleTokens.textPrimary : StyleTokens.textSecondary
                }
            }

            MouseArea {
                id: vpnMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (leftIslandRoot.vpnConnected) {
                        copyVpnProc.command = ["wl-copy", leftIslandRoot.vpnIp]
                        copyVpnProc.running = true
                    }
                }
            }

            Process {
                id: copyVpnProc
            }
        }
    }

    // Telemetry Update Timer
    Timer {
        id: telemetryTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            telemetryCheckProc.running = true
        }
    }

    Process {
        id: telemetryCheckProc
        command: ["bash", "-c", "cat ~/.cache/hyprdark/target_ip 2>/dev/null || echo ''; ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}' || ip -4 addr show wg0 2>/dev/null | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}' || echo ''"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.trim().split("\n")
                if (lines.length >= 1) {
                    leftIslandRoot.targetIp = lines[0].trim()
                }
                if (lines.length >= 2 && lines[1].trim().length > 0) {
                    leftIslandRoot.vpnIp = lines[1].trim()
                    leftIslandRoot.vpnConnected = true
                } else {
                    leftIslandRoot.vpnIp = ""
                    leftIslandRoot.vpnConnected = false
                }
            }
        }
    }
}
