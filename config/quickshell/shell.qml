import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Io
import "."
import "bar"
import "dropdowns"

Scope {
    id: shellRoot

    // Global IPC Handler
    IpcHandler {
        target: "hyprdark"

        function toggleCenterDrawer() {
            shellRoot.forEachWindow(w => w.toggleCenterDrawer())
        }

        function toggleControlCenter() {
            shellRoot.forEachWindow(w => w.toggleControlCenter())
        }

        function toggleMedia() {
            shellRoot.forEachWindow(w => w.toggleMedia())
        }
    }

    // Built-in DBus Notification Server
    NotificationServer {
        id: notifServer

        onNotification: notification => {
            var app = notification.appName || "Notification"
            var summary = notification.summary || ""
            var body = notification.body || ""

            shellRoot.forEachWindow(w => {
                if (w && w.handleNotification) {
                    w.handleNotification(app, summary, body)
                }
            })
        }
    }

    function forEachWindow(callback) {
        var instances = panelVariants.instances || []
        for (var i = 0; i < instances.length; i++) {
            if (instances[i]) callback(instances[i])
        }
    }

    Variants {
        id: panelVariants
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            color: StyleTokens.transparent
            anchors {
                top: true
                left: true
                right: true
            }

            // Window Height: Accommodates bar (52px) or drawers when open (~440px)
            implicitHeight: (centerDrawer.isOpen || controlCenterDrawer.isOpen) ? 440 : 52

            // Wayland Layer-Shell Region Masking: Only visible islands & drawers intercept mouse clicks!
            mask: Region {
                // Left Island
                Region {
                    x: Math.floor(leftIsland.x)
                    y: Math.floor(leftIsland.y)
                    width: Math.ceil(leftIsland.width)
                    height: Math.ceil(leftIsland.height)
                }

                // Middle Dynamic Island
                Region {
                    intersection: Intersection.Combine
                    x: Math.floor(centerIsland.x)
                    y: Math.floor(centerIsland.y)
                    width: Math.ceil(centerIsland.width)
                    height: Math.ceil(centerIsland.height)
                }

                // Right Island
                Region {
                    intersection: Intersection.Combine
                    x: Math.floor(rightIsland.x)
                    y: Math.floor(rightIsland.y)
                    width: Math.ceil(rightIsland.width)
                    height: Math.ceil(rightIsland.height)
                }

                // Center Drawer (Calendar & Notifications)
                Region {
                    intersection: Intersection.Combine
                    x: Math.floor(centerDrawer.x)
                    y: Math.floor(centerDrawer.y)
                    width: centerDrawer.isOpen ? Math.ceil(centerDrawer.width) : 0
                    height: centerDrawer.isOpen ? Math.ceil(centerDrawer.height) : 0
                }

                // Control Center Drawer
                Region {
                    intersection: Intersection.Combine
                    x: Math.floor(controlCenterDrawer.x)
                    y: Math.floor(controlCenterDrawer.y)
                    width: controlCenterDrawer.isOpen ? Math.ceil(controlCenterDrawer.width) : 0
                    height: controlCenterDrawer.isOpen ? Math.ceil(controlCenterDrawer.height) : 0
                }
            }

            // 1. Left Island Capsule
            LeftIsland {
                id: leftIsland
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.top: parent.top
                anchors.topMargin: 8
            }

            // 2. Middle Dynamic Island Capsule
            CenterIsland {
                id: centerIsland
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 8
                onToggleCenterDrawerRequested: barWindow.toggleCenterDrawer()
            }

            // 3. Right Island Capsule
            RightIsland {
                id: rightIsland
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.top: parent.top
                anchors.topMargin: 8
                onToggleControlCenterRequested: barWindow.toggleControlCenter()
                onTogglePowerRequested: {
                    powerProc.running = true
                }
            }

            // 4. Center Dropdown Drawer (Unified Calendar & Notifications)
            CenterDrawer {
                id: centerDrawer
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: centerIsland.bottom
                anchors.topMargin: 8
                onCloseRequested: centerDrawer.isOpen = false
            }

            // 5. Control Center Dropdown Drawer
            ControlCenterDrawer {
                id: controlCenterDrawer
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.top: rightIsland.bottom
                anchors.topMargin: 8
                onCloseRequested: controlCenterDrawer.isOpen = false
            }

            Process {
                id: powerProc
                command: ["wlogout"]
            }

            // Window API methods
            function toggleCenterDrawer() {
                if (controlCenterDrawer.isOpen) controlCenterDrawer.isOpen = false
                centerDrawer.isOpen = !centerDrawer.isOpen
            }

            function toggleControlCenter() {
                if (centerDrawer.isOpen) centerDrawer.isOpen = false
                controlCenterDrawer.isOpen = !controlCenterDrawer.isOpen
            }

            function toggleMedia() {
                if (centerIsland.islandState === "mpris") {
                    centerIsland.islandState = "clock"
                } else {
                    centerIsland.islandState = "mpris"
                }
            }

            function handleNotification(app, summary, body) {
                centerDrawer.addNotification(app, summary, body)
                centerIsland.triggerNotificationBanner(app, summary, body)
            }

            function startTimer(minutes) {
                centerIsland.startTimer(minutes)
            }

            function triggerOsd(icon, value) {
                centerIsland.triggerOsd(icon, value)
            }
        }
    }
}
