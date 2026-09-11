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

    WlrLayershell.layer: WlrLayer.Overlay

    // Dynamic exclusive zone: Reserves 52px in pinned mode, 0 in dynamic island mode
    exclusiveZone: BarState.isPinned ? 52 : 0
    implicitHeight: 340

    // Layer-Shell Region Masking: Dynamically shrinks to island bounds in resting mode,
    // and expands to full bar bounds when calendar or modals are open.
    mask: Region {
        Region {
            x: 0
            y: 0
            width: BarState.calendarOpen ? barWindow.width : 0
            height: BarState.calendarOpen ? barWindow.height : 0
        }
        Region {
            intersection: Intersection.Combine
            x: Math.floor(leftIsland.x)
            y: 0
            width: Math.ceil(leftIsland.width)
            height: Math.ceil(leftIsland.interactiveHeight)
        }
        Region {
            intersection: Intersection.Combine
            x: Math.floor(centerIsland.x - Math.max(0, (centerIsland.triggerSpanWidth - centerIsland.width) / 2))
            y: 0
            width: Math.ceil(Math.max(centerIsland.width, centerIsland.triggerSpanWidth))
            height: Math.ceil(centerIsland.interactiveHeight)
        }
    }

    // Top Bar Outside Click Dismissal for Open Calendar
    MouseArea {
        id: barBackdropClick
        anchors.fill: parent
        enabled: BarState.calendarOpen
        z: -1
        onClicked: BarState.calendarOpen = false
    }

    // Top Left Island Capsule
    LeftIsland {
        id: leftIsland
        anchors { left: parent.left; leftMargin: 16; top: parent.top }
    }

    // Top Center Dynamic Island Capsule
    CenterIsland {
        id: centerIsland
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
    }
}
