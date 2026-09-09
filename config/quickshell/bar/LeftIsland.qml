import QtQuick
import QtQuick.Shapes
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

    // Target Drawer Outline Cutout (Completely blocks the horizontal island bottom border across the entire drawer + fillets)
    Rectangle {
        id: targetCutoutBridge
        z: 15
        visible: targetBadge.dropdownOpen && targetBadge.drawerHeight > 2
        x: Math.round(innerRow.x + targetBadge.x - 9 - 8)
        y: parent.height - 2
        width: Math.round(targetBadge.width + 18 + 16)
        height: 4
        color: "#16161a"
    }

    // Target Left Concave Corner Fillet
    Shape {
        z: 25
        x: Math.round(innerRow.x + targetBadge.x - 9 - 8)
        y: parent.height - 1
        width: 8
        height: 8
        visible: targetBadge.dropdownOpen && targetBadge.drawerHeight > 4
        opacity: targetBadge.dropdownOpen ? 1.0 : 0.0
        layer.enabled: true
        layer.samples: 4

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        ShapePath {
            strokeColor: (targetBadge.isHovered || targetBadge.dropdownHovered) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
            strokeWidth: 1
            fillColor: "#16161a"
            PathSvg {
                path: "M 0,0 Q 8,0 8,8 L 8,0 Z"
            }
        }
    }

    // Target Right Concave Corner Fillet
    Shape {
        z: 25
        x: Math.round(innerRow.x + targetBadge.x + targetBadge.width + 9)
        y: parent.height - 1
        width: 8
        height: 8
        visible: targetBadge.dropdownOpen && targetBadge.drawerHeight > 4
        opacity: targetBadge.dropdownOpen ? 1.0 : 0.0
        layer.enabled: true
        layer.samples: 4

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        ShapePath {
            strokeColor: (targetBadge.isHovered || targetBadge.dropdownHovered) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
            strokeWidth: 1
            fillColor: "#16161a"
            PathSvg {
                path: "M 8,0 Q 0,0 0,8 L 0,0 Z"
            }
        }
    }

    // VPN Drawer Outline Cutout (Completely blocks the horizontal island bottom border across the entire drawer + fillets)
    Rectangle {
        id: vpnCutoutBridge
        z: 15
        visible: vpnBadge.dropdownOpen && vpnBadge.drawerHeight > 2
        x: Math.round(innerRow.x + vpnBadge.x - 9 - 8)
        y: parent.height - 2
        width: Math.round(vpnBadge.width + 18 + 16)
        height: 4
        color: "#16161a"
    }

    // VPN Left Concave Corner Fillet
    Shape {
        z: 25
        x: Math.round(innerRow.x + vpnBadge.x - 9 - 8)
        y: parent.height - 1
        width: 8
        height: 8
        visible: vpnBadge.dropdownOpen && vpnBadge.drawerHeight > 4
        opacity: vpnBadge.dropdownOpen ? 1.0 : 0.0
        layer.enabled: true
        layer.samples: 4

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        ShapePath {
            strokeColor: (vpnBadge.isHovered || vpnBadge.dropdownHovered) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
            strokeWidth: 1
            fillColor: "#16161a"
            PathSvg {
                path: "M 0,0 Q 8,0 8,8 L 8,0 Z"
            }
        }
    }

    // VPN Right Concave Corner Fillet
    Shape {
        z: 25
        x: Math.round(innerRow.x + vpnBadge.x + vpnBadge.width + 9)
        y: parent.height - 1
        width: 8
        height: 8
        visible: vpnBadge.dropdownOpen && vpnBadge.drawerHeight > 4
        opacity: vpnBadge.dropdownOpen ? 1.0 : 0.0
        layer.enabled: true
        layer.samples: 4

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        ShapePath {
            strokeColor: (vpnBadge.isHovered || vpnBadge.dropdownHovered) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder
            strokeWidth: 1
            fillColor: "#16161a"
            PathSvg {
                path: "M 8,0 Q 0,0 0,8 L 0,0 Z"
            }
        }
    }
}
