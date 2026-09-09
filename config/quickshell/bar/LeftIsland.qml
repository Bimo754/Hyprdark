import QtQuick
import Quickshell
import ".."
import "../components"
import "../modules/left"

IslandCapsule {
    id: leftIslandRoot

    implicitHeight: 42
    implicitWidth: innerRow.implicitWidth + 24

    readonly property bool dropdownOpen: targetBadge.dropdownOpen || vpnBadge.dropdownOpen

    Row {
        id: innerRow
        anchors.centerIn: parent
        spacing: 10

        // 1. Arch Logo Launcher
        ArchLauncher {}

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 2. Workspaces 1-5
        WorkspaceList {}

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 3. Target IP Telemetry
        TargetBadge {
            id: targetBadge
        }

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 4. VPN Status Telemetry
        VpnBadge {
            id: vpnBadge
        }
    }

    // Target Drawer Outline Cutout (Opens the island bottom border where the drawer begins)
    Rectangle {
        id: targetCutoutBridge
        z: 10
        visible: targetBadge.dropdownOpen && targetBadge.drawerHeight > 4
        x: Math.round(innerRow.x + targetBadge.x - 9 + 1)
        y: parent.height - 1
        width: Math.round(targetBadge.width + 18 - 2)
        height: 2
        color: StyleTokens.glassBackground
    }

    // VPN Drawer Outline Cutout (Opens the island bottom border where the drawer begins)
    Rectangle {
        id: vpnCutoutBridge
        z: 10
        visible: vpnBadge.dropdownOpen && vpnBadge.drawerHeight > 4
        x: Math.round(innerRow.x + vpnBadge.x - 9 + 1)
        y: parent.height - 1
        width: Math.round(vpnBadge.width + 18 - 2)
        height: 2
        color: StyleTokens.glassBackground
    }
}
