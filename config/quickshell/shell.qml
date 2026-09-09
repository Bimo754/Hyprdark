import QtQuick
import Quickshell
import "bar"

Scope {
    id: shellRoot

    Variants {
        id: panelVariants
        model: Quickshell.screens
        BarWindow {}
    }
}
