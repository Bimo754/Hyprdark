import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "bar"

Scope {
    id: shellRoot

    IpcHandler {
        target: "hyprdark"

        function toggleCenterDrawer() {
            shellRoot.forEachWindow(w => w.toggleCenterDrawer())
        }

        function toggleControlCenter() {
            shellRoot.forEachWindow(w => w.toggleControlCenter())
        }

        function toggleAudioDrawer() {
            shellRoot.forEachWindow(w => w.toggleAudioDrawer())
        }

        function toggleMedia() {
            shellRoot.forEachWindow(w => w.toggleMedia())
        }
    }

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
        BarWindow {}
    }
}
