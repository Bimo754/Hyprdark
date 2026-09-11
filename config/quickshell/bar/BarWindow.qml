import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: barWindow
    required property var modelData
    screen: modelData

    color: StyleTokens.transparent
    anchors { top: true; left: true; right: true }

    // Fixed exclusive zone: Reserves 52px at top
    exclusiveZone: 52
    implicitHeight: 220

    // Layer-Shell Region Masking: Left Island (plus dropdown when open) intercepts clicks
    mask: Region {
        Region {
            x: Math.floor(leftIsland.x)
            y: Math.floor(leftIsland.y)
            width: Math.ceil(leftIsland.width)
            height: Math.ceil(leftIsland.height + (leftIsland.dropdownOpen || leftIsland.animatedDrawerH > 0.1 ? 160 : 0))
        }
    }

    // Top Left Island Capsule
    LeftIsland {
        id: leftIsland
        anchors { left: parent.left; leftMargin: 16; top: parent.top; topMargin: 7 }
    }
}
