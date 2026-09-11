pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: notiStateRoot

    // Multi-notification Queue
    property var notificationQueue: []
    property int activeIndex: 0

    readonly property int queueCount: notificationQueue.length
    readonly property int extraCount: Math.max(0, notificationQueue.length - 1)
    readonly property bool hasActiveNotification: notificationQueue.length > 0

    readonly property var activeItem: (notificationQueue.length > 0 && activeIndex >= 0 && activeIndex < notificationQueue.length)
        ? notificationQueue[activeIndex]
        : null

    readonly property string appName: activeItem ? activeItem.appName : ""
    readonly property string appIcon: activeItem ? activeItem.appIcon : ""
    readonly property string summary: activeItem ? activeItem.summary : ""
    readonly property string body: activeItem ? activeItem.body : ""
    readonly property string desktopEntry: activeItem ? activeItem.desktopEntry : ""
    readonly property int urgency: activeItem ? activeItem.urgency : 1
    readonly property int notificationId: activeItem ? activeItem.id : 0

    property bool isHovered: false

    signal notificationArrived(int totalCount)

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
                notiStateRoot.dismissCurrent();
            }
        }
    }

    onIsHoveredChanged: {
        if (!isHovered && hasActiveNotification) {
            // When user moves mouse away after inspecting, advance/dismiss after 0.6s grace period
            dismissTimer.interval = 600;
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
        let item = {
            id: Date.now() + Math.floor(Math.random() * 1000),
            appName: (noti.appName && noti.appName.length > 0) ? noti.appName : "Notification",
            appIcon: noti.appIcon || noti.image || "",
            summary: noti.summary || "",
            body: noti.body || "",
            desktopEntry: noti.desktopEntry || "",
            urgency: noti.urgency !== undefined ? noti.urgency : 1,
            nativeNoti: noti
        };

        let q = notificationQueue.slice();
        q.unshift(item); // Newest notification displayed immediately at index 0
        notificationQueue = q;
        activeIndex = 0;

        dismissTimer.interval = 5000;
        dismissTimer.restart();
        notificationArrived(q.length);
    }

    function nextNotification() {
        if (notificationQueue.length > 1) {
            activeIndex = (activeIndex + 1) % notificationQueue.length;
            dismissTimer.interval = 5000;
            dismissTimer.restart();
        }
    }

    function prevNotification() {
        if (notificationQueue.length > 1) {
            activeIndex = (activeIndex - 1 + notificationQueue.length) % notificationQueue.length;
            dismissTimer.interval = 5000;
            dismissTimer.restart();
        }
    }

    function activate() {
        if (!activeItem) return;
        focusAppProc.command = ["python3", "/home/diamond/Desktop/Github/Hyprdark/scripts/focus-or-open-app.py", activeItem.appName, activeItem.desktopEntry];
        focusAppProc.running = true;
        if (activeItem.nativeNoti && activeItem.nativeNoti.actions && activeItem.nativeNoti.actions.length > 0) {
            try {
                activeItem.nativeNoti.actions[0].invoke();
            } catch (e) {}
        }
        dismissCurrent();
    }

    function dismissCurrent() {
        if (notificationQueue.length === 0) return;
        let q = notificationQueue.slice();
        let item = q[activeIndex];
        if (item && item.nativeNoti) {
            try {
                item.nativeNoti.dismiss();
            } catch (e) {}
        }
        q.splice(activeIndex, 1);
        if (activeIndex >= q.length) {
            activeIndex = Math.max(0, q.length - 1);
        }
        notificationQueue = q;

        if (q.length > 0) {
            dismissTimer.interval = 5000;
            dismissTimer.restart();
        } else {
            dismissTimer.stop();
        }
    }

    function dismissAll() {
        for (let i = 0; i < notificationQueue.length; i++) {
            let item = notificationQueue[i];
            if (item && item.nativeNoti) {
                try {
                    item.nativeNoti.dismiss();
                } catch (e) {}
            }
        }
        notificationQueue = [];
        activeIndex = 0;
        dismissTimer.stop();
    }
}
