pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: barState

    property bool isPinned: true
    readonly property bool isDynamic: !isPinned

    IpcHandler {
        target: "barMode"

        function toggle(): string {
            barState.isPinned = !barState.isPinned;
            return barState.isPinned ? "pinned" : "dynamic";
        }

        function getMode(): string {
            return barState.isPinned ? "pinned" : "dynamic";
        }

        function setMode(mode: string): void {
            if (mode === "pinned") {
                barState.isPinned = true;
            } else if (mode === "dynamic") {
                barState.isPinned = false;
            }
        }
    }
}
