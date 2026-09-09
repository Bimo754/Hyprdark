import QtQuick
import ".."
import "../components"
import "../modules/left"

IslandCapsule {
    id: leftIslandRoot
    height: 38
    width: contentRow.implicitWidth + 24

    Row {
        id: contentRow
        spacing: 8
        anchors.centerIn: parent

        // 1. Arch Linux App Launcher Button
        ArchLauncher {}

        // Subtle Hairline Divider
        Rectangle {
            width: 1
            height: 14
            color: StyleTokens.hairlineDivider
            anchors.verticalCenter: parent.verticalCenter
        }

        // 2. Hyprland Workspace Matrix
        WorkspaceList {}

        // Subtle Hairline Divider
        Rectangle {
            width: 1
            height: 14
            color: StyleTokens.hairlineDivider
            anchors.verticalCenter: parent.verticalCenter
        }

        // 3. Cyber Telemetry: Target IP Badge
        TargetBadge {}

        // 4. Cyber Telemetry: VPN Status Badge
        VpnBadge {}
    }
}
