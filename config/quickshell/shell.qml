import QtQuick
import Quickshell
import "bar"
import "cyber"

Scope {
    id: shellRoot

    Variants {
        id: backdropVariants
        model: Quickshell.screens
        CalendarBackdrop {}
    }

    Variants {
        id: panelVariants
        model: Quickshell.screens
        BarWindow {}
    }

    Variants {
        id: cyberVariants
        model: Quickshell.screens
        CyberMenuWindow {}
    }
}
