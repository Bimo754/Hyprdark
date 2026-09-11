pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: cyberState

    property bool isOpen: false

    function open() {
        isOpen = true;
    }

    function close() {
        isOpen = false;
    }

    function toggle() {
        isOpen = !isOpen;
    }

    IpcHandler {
        target: "cyber"

        function toggle(): string {
            cyberState.toggle();
            return cyberState.isOpen ? "open" : "closed";
        }

        function open(): void {
            cyberState.open();
        }

        function close(): void {
            cyberState.close();
        }

        function getStatus(): string {
            return cyberState.isOpen ? "open" : "closed";
        }
    }
}
