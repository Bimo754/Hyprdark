pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: notiStateRoot

    // Array of active notification items (max 3 displayed)
    property var activeList: []

    // ListModel for Notification Center (enables rich add/remove transitions in ListView)
    ListModel {
        id: historyListModel
    }

    readonly property alias historyModel: historyListModel
    readonly property int historyCount: historyListModel.count

    readonly property bool hasActiveNotification: activeList.length > 0
    readonly property int activeCount: activeList.length

    readonly property bool isHovered: {
        for (let i = 0; i < activeList.length; i++) {
            if (activeList[i] && activeList[i].isHovered) return true;
        }
        return false;
    }

    // Topmost item helpers for fallback / single item queries
    readonly property var topItem: activeList.length > 0 ? activeList[0] : null
    readonly property string appName: topItem ? topItem.appName : ""
    readonly property string appIcon: topItem ? topItem.appIcon : ""
    readonly property string summary: topItem ? topItem.summary : ""
    readonly property string body: topItem ? topItem.body : ""
    readonly property string desktopEntry: topItem ? topItem.desktopEntry : ""

    signal notificationArrived(var notiId)

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

    // Independent per-item lifetime countdown timer (ticks every 100ms)
    Timer {
        id: countdownTimer
        interval: 100
        repeat: true
        running: notiStateRoot.hasActiveNotification
        onTriggered: {
            let list = notiStateRoot.activeList.slice();
            let toRemove = [];

            for (let i = 0; i < list.length; i++) {
                let item = list[i];
                if (!item || item.isHovered || item.isEvicting) continue;

                item.timeRemaining -= 100;
                if (item.timeRemaining <= 0) {
                    toRemove.push(item.id);
                }
            }

            for (let j = 0; j < toRemove.length; j++) {
                notiStateRoot.dismissItem(toRemove[j]);
            }
        }
    }

    // Eviction delay timer for 4th notification merge
    Timer {
        id: evictionCleanupTimer
        interval: 240
        repeat: false
        onTriggered: {
            let list = notiStateRoot.activeList.slice();
            let filtered = [];
            for (let i = 0; i < list.length; i++) {
                if (list[i] && list[i].isEvicting) {
                    if (list[i].nativeNoti) {
                        try { list[i].nativeNoti.dismiss(); } catch(e) {}
                    }
                } else if (list[i]) {
                    filtered.push(list[i]);
                }
            }
            notiStateRoot.activeList = filtered;
        }
    }

    Connections {
        target: BarState
        function onCenterPanelChanged() {
            if (BarState.centerPanel === "notifications") {
                notiStateRoot.dismissAll();
            }
        }
    }

    Process {
        id: focusAppProc
        command: ["python3", "/home/diamond/Desktop/Github/Hyprdark/scripts/focus-or-open-app.py", "", ""]
    }

    function handleIncomingNotification(noti) {
        let uniqueId = "noti_" + Date.now() + "_" + Math.floor(Math.random() * 1000);
        let now = new Date();
        let item = {
            id: uniqueId,
            appName: (noti.appName && noti.appName.length > 0) ? noti.appName : "Notification",
            appIcon: noti.appIcon || noti.image || "",
            summary: noti.summary || "",
            body: noti.body || "",
            desktopEntry: noti.desktopEntry || "",
            urgency: noti.urgency !== undefined ? noti.urgency : 1,
            timeRemaining: 5000,
            timestamp: Date.now(),
            timeStr: Qt.formatTime(now, "h:mm AP"),
            isHovered: false,
            isEvicting: false,
            nativeNoti: noti
        };

        // 1. Insert into persistent ListModel (triggers animated entry transition in ListView)
        historyListModel.insert(0, item);
        if (historyListModel.count > 50) {
            historyListModel.remove(historyListModel.count - 1);
        }

        // 2. Active toast behavior based on active panel
        if (BarState.centerPanel === "notifications") {
            // Already inside Notification Center: appears directly in the list, no toast
            notiStateRoot.activeList = [];
        } else if (BarState.centerPanel === "calendar") {
            // Calendar is open: display max 1 notification ejected below the calendar
            notiStateRoot.activeList = [item];
        } else {
            // Resting island mode: physical multi-notification stack (max 3)
            let list = notiStateRoot.activeList.slice();
            if (list.length >= 3) {
                for (let i = 2; i < list.length; i++) {
                    list[i].isEvicting = true;
                }
                evictionCleanupTimer.restart();
            }
            list.unshift(item);
            notiStateRoot.activeList = list;
        }

        notiStateRoot.notificationArrived(uniqueId);
    }

    function setItemHovered(id, hovered) {
        let list = notiStateRoot.activeList.slice();
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].id === id) {
                list[i].isHovered = hovered;
                if (!hovered && list[i].timeRemaining < 1000) {
                    list[i].timeRemaining = 1000; // 1s grace period after unhovering
                }
                break;
            }
        }
        notiStateRoot.activeList = list;
    }

    function activateItem(id) {
        let list = notiStateRoot.activeList.slice();
        for (let i = 0; i < list.length; i++) {
            let item = list[i];
            if (item && item.id === id) {
                focusAppProc.command = ["python3", "/home/diamond/Desktop/Github/Hyprdark/scripts/focus-or-open-app.py", item.appName, item.desktopEntry];
                focusAppProc.running = true;
                if (item.nativeNoti && item.nativeNoti.actions && item.nativeNoti.actions.length > 0) {
                    try { item.nativeNoti.actions[0].invoke(); } catch(e) {}
                }
                break;
            }
        }
        dismissItem(id);
        dismissHistoryItem(id);
    }

    function dismissItem(id) {
        let list = notiStateRoot.activeList.slice();
        let idx = -1;
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].id === id) {
                idx = i;
                if (list[i].nativeNoti) {
                    try { list[i].nativeNoti.dismiss(); } catch(e) {}
                }
                break;
            }
        }
        if (idx !== -1) {
            list.splice(idx, 1);
            notiStateRoot.activeList = list;
        }
    }

    function dismissAll() {
        let list = notiStateRoot.activeList.slice();
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].nativeNoti) {
                try { list[i].nativeNoti.dismiss(); } catch(e) {}
            }
        }
        notiStateRoot.activeList = [];
    }

    function dismissHistoryItem(id) {
        for (let i = 0; i < historyListModel.count; i++) {
            if (historyListModel.get(i).id === id) {
                historyListModel.remove(i);
                break;
            }
        }
        dismissItem(id);
    }

    function clearHistory() {
        historyListModel.clear();
        dismissAll();
    }

    function activateHistoryItem(id) {
        for (let i = 0; i < historyListModel.count; i++) {
            let item = historyListModel.get(i);
            if (item && item.id === id) {
                focusAppProc.command = ["python3", "/home/diamond/Desktop/Github/Hyprdark/scripts/focus-or-open-app.py", item.appName, item.desktopEntry];
                focusAppProc.running = true;
                if (item.nativeNoti && item.nativeNoti.actions && item.nativeNoti.actions.length > 0) {
                    try { item.nativeNoti.actions[0].invoke(); } catch(e) {}
                }
                break;
            }
        }
        dismissHistoryItem(id);
    }
}
