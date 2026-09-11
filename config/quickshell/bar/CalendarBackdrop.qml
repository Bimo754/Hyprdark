import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: backdropWindow
    required property var modelData
    screen: modelData

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: StyleTokens.transparent
    exclusiveZone: 0

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: BarState.centerExpanded ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    mask: Region {
        Region {
            x: 0
            y: 0
            width: BarState.centerExpanded ? backdropWindow.width : 0
            height: BarState.centerExpanded ? backdropWindow.height : 0
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: BarState.centerExpanded
        onClicked: BarState.closeCenter()
    }

    Item {
        focus: BarState.centerExpanded
        Keys.onEscapePressed: BarState.closeCenter()
    }
}
