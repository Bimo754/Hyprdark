pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: notiStateRoot

    property bool hasActiveNotification: false
    property string appName: ""
    property string appIcon: ""
    property string summary: ""
    property string body: ""
    property string desktopEntry: ""
    property int urgency: 1
    property var currentNotification: null

    property bool isHovered: false

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: (noti) => {
            noti.tracked = true;
            notiStateRoot.handleIncomingNotification(noti);
        }
    }

    Timer {
        id: dismissTimer
        interval: 5000
        repeat: false
        onTriggered: {
            if (!notiStateRoot.isHovered) {
                notiStateRoot.dismiss();
            }
        }
    }

    onIsHoveredChanged: {
        if (!isHovered && hasActiveNotification) {
            // When user moves mouse away after inspecting, dismiss after 0.5s grace period
            dismissTimer.interval = 500;
            dismissTimer.restart();
        } else if (isHovered) {
            dismissTimer.stop();
        }
    }

    Process {
        id: focusAppProc
        command: ["python3", "/home/diamond/Desktop/Github/Hyprdark/scripts/focus-or-open-app.py", notiStateRoot.appName, notiStateRoot.desktopEntry]
    }

    function handleIncomingNotification(noti) {
        currentNotification = noti;
        appName = (noti.appName && noti.appName.length > 0) ? noti.appName : "Notification";
        appIcon = noti.appIcon || noti.image || "";
        summary = noti.summary || "";
        body = noti.body || "";
        desktopEntry = noti.desktopEntry || "";
        urgency = noti.urgency !== undefined ? noti.urgency : 1;

        hasActiveNotification = true;
        dismissTimer.interval = 5000;
        dismissTimer.restart();
    }

    function activate() {
        focusAppProc.command = ["python3", "/home/diamond/Desktop/Github/Hyprdark/scripts/focus-or-open-app.py", appName, desktopEntry];
        focusAppProc.running = true;
        if (currentNotification && currentNotification.actions && currentNotification.actions.length > 0) {
            try {
                currentNotification.actions[0].invoke();
            } catch (e) {
                // Ignore invocation errors
            }
        }
        dismiss();
    }

    function dismiss() {
        dismissTimer.stop();
        hasActiveNotification = false;
        if (currentNotification) {
            try {
                currentNotification.dismiss();
            } catch (e) {
                // Ignore any disposal errors
            }
            currentNotification = null;
        }
    }
}
