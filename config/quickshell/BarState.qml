pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: barState

    property bool isPinned: true
    property bool calendarOpen: false
    property bool isFullscreen: false
    readonly property bool isDynamic: !isPinned

    Process {
        id: fsCheckProc
        command: ["python3", "-c", "import os, subprocess, json; res = subprocess.check_output(['hyprctl', 'activeworkspace', '-j']); print(json.loads(res.decode()).get('hasfullscreen', False))"]
        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim().toLowerCase();
                barState.isFullscreen = (trimmed === "true" || trimmed === "1");
            }
        }
    }

    Timer {
        interval: 350
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fsCheckProc.running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(name, data) {
            if (name === "fullscreen" || name === "workspace" || name === "focusedmon" || name === "activewindow" || name === "activewindowv2") {
                fsCheckProc.running = true;
            }
        }
    }

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
