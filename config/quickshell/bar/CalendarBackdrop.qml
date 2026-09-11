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
    WlrLayershell.keyboardFocus: BarState.calendarOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    mask: Region {
        Region {
            x: 0
            y: 0
            width: BarState.calendarOpen ? backdropWindow.width : 0
            height: BarState.calendarOpen ? backdropWindow.height : 0
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: BarState.calendarOpen
        onClicked: BarState.calendarOpen = false
    }

    Item {
        focus: BarState.calendarOpen
        Keys.onEscapePressed: BarState.calendarOpen = false
    }
}
