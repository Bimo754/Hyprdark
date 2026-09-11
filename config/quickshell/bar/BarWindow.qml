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

    // Dynamic exclusive zone: Reserves 52px in pinned mode, 0 in dynamic island mode
    exclusiveZone: BarState.isPinned ? 52 : 0
    implicitHeight: 220

    // Layer-Shell Region Masking: Dynamically shrinks to top-edge trigger in dynamic mode,
    // and expands to full island + drawer bounds when revealed or pinned.
    mask: Region {
        Region {
            x: Math.floor(leftIsland.x)
            y: 0
            width: Math.ceil(leftIsland.width)
            height: Math.ceil(leftIsland.interactiveHeight)
        }
    }

    // Top Left Island Capsule
    LeftIsland {
        id: leftIsland
        anchors { left: parent.left; leftMargin: 16; top: parent.top }
    }
}
