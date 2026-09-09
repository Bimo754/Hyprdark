import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."
import "../dropdowns"

PanelWindow {
    id: barWindow
    required property var modelData
    screen: modelData

    color: StyleTokens.transparent
    anchors { top: true; left: true; right: true }

    // Fixed exclusive zone: Reserves 52px at top, NEVER resizes or squashes client windows!
    exclusiveZone: 52
    implicitHeight: (centerIsland.isExpanded || controlCenterDrawer.isOpen || audioDrawer.isOpen) ? 440 : 56

    // Layer-Shell Region Masking: Only visible islands & open drawers intercept clicks
    mask: Region {
        Region {
            x: Math.floor(leftIsland.x); y: Math.floor(leftIsland.y)
            width: Math.ceil(leftIsland.width); height: Math.ceil(leftIsland.height)
        }
        Region {
            intersection: Intersection.Combine
            x: Math.floor(centerIsland.x); y: Math.floor(centerIsland.y)
            width: Math.ceil(centerIsland.width); height: Math.ceil(centerIsland.height)
        }
        Region {
            intersection: Intersection.Combine
            x: Math.floor(rightIsland.x); y: Math.floor(rightIsland.y)
            width: Math.ceil(rightIsland.width); height: Math.ceil(rightIsland.height)
        }
        Region {
            intersection: Intersection.Combine
            x: Math.floor(controlCenterDrawer.x); y: Math.floor(controlCenterDrawer.y)
            width: controlCenterDrawer.isOpen ? Math.ceil(controlCenterDrawer.width) : 0
            height: controlCenterDrawer.isOpen ? Math.ceil(controlCenterDrawer.height) : 0
        }
        Region {
            intersection: Intersection.Combine
            x: Math.floor(audioDrawer.x); y: Math.floor(audioDrawer.y)
            width: audioDrawer.isOpen ? Math.ceil(audioDrawer.width) : 0
            height: audioDrawer.isOpen ? Math.ceil(audioDrawer.height) : 0
        }
    }

    // 1. Left Island Capsule
    LeftIsland {
        id: leftIsland
        anchors { left: parent.left; leftMargin: 16; top: parent.top; topMargin: 7 }
    }

    // 2. Middle Dynamic Island Capsule
    CenterIsland {
        id: centerIsland
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 7 }
    }

    // 3. Right Island Capsule
    RightIsland {
        id: rightIsland
        anchors { right: parent.right; rightMargin: 16; top: parent.top; topMargin: 7 }
        onToggleAudioDrawerRequested: barWindow.toggleAudioDrawer()
        onToggleControlCenterRequested: barWindow.toggleControlCenter()
        onTogglePowerRequested: powerProc.running = true
    }

    // 4. Control Center Dropdown Drawer
    ControlCenterDrawer {
        id: controlCenterDrawer
        anchors { right: parent.right; rightMargin: 16; top: rightIsland.bottom; topMargin: 8 }
        onCloseRequested: controlCenterDrawer.isOpen = false
    }

    // 5. Dedicated Sound / Audio Pop-up Drawer
    AudioDrawer {
        id: audioDrawer
        anchors { right: parent.right; rightMargin: 16; top: rightIsland.bottom; topMargin: 8 }
        onCloseRequested: audioDrawer.isOpen = false
    }

    Process { id: powerProc; command: ["wlogout"] }

    function toggleCenterDrawer() {
        if (controlCenterDrawer.isOpen) controlCenterDrawer.isOpen = false
        if (audioDrawer.isOpen) audioDrawer.isOpen = false
        centerIsland.toggleExpand()
    }

    function toggleControlCenter() {
        if (centerIsland.isExpanded) centerIsland.isExpanded = false
        if (audioDrawer.isOpen) audioDrawer.isOpen = false
        controlCenterDrawer.isOpen = !controlCenterDrawer.isOpen
    }

    function toggleAudioDrawer() {
        if (centerIsland.isExpanded) centerIsland.isExpanded = false
        if (controlCenterDrawer.isOpen) controlCenterDrawer.isOpen = false
        audioDrawer.isOpen = !audioDrawer.isOpen
    }

    function toggleMedia() {
        centerIsland.islandState = (centerIsland.islandState === "mpris") ? "clock" : "mpris"
    }

    function handleNotification(app, summary, body) {
        centerIsland.addNotification(app, summary, body)
    }
}
