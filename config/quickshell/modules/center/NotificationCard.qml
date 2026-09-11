import QtQuick
import Quickshell
import "../.."

Item {
    id: notiCardRoot

    property string notiId: ""
    property int targetSlot: 0
    property bool isEvicting: false
    property bool isExiting: false

    property string appName: ""
    property string appIcon: ""
    property string summary: ""
    property string body: ""
    property string desktopEntry: ""
    property int urgency: 1
    property int timeRemaining: 5000
    property bool isHovered: false

    width: 380
    height: 52
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

    readonly property string resolvedIcon: {
        const rawIcon = notiCardRoot.appIcon;
        const app = notiCardRoot.appName ? notiCardRoot.appName.toLowerCase() : "";

        if (rawIcon && (rawIcon.startsWith("/") || rawIcon.startsWith("file://"))) {
            return rawIcon;
        }
        if (rawIcon && rawIcon.length > 0 && Quickshell.hasThemeIcon(rawIcon)) {
            const resolved = Quickshell.iconPath(rawIcon);
            if (resolved && resolved.length > 0) return resolved;
        }
        if (app && app.length > 0 && Quickshell.hasThemeIcon(app)) {
            const byName = Quickshell.iconPath(app);
            if (byName && byName.length > 0) return byName;
        }
        return "";
    }

    Behavior on y {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutBack
            easing.overshoot: 1.12
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutBack
            easing.overshoot: 1.10
        }
    }

    // Monochromatic Frosted Glass Pill Body
    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: 20
        color: StyleTokens.glassBackground
        border.width: 1
        border.color: (cardMouse.containsMouse || notiCardRoot.isHovered) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

        Behavior on border.color {
            ColorAnimation { duration: StyleTokens.animFast }
        }

        // Hover highlight overlay
        Rectangle {
            anchors.fill: parent
            radius: 20
            color: (cardMouse.containsMouse || notiCardRoot.isHovered) ? StyleTokens.surfaceHover : StyleTokens.transparent
            Behavior on color {
                ColorAnimation { duration: StyleTokens.animFast }
            }
        }
    }

    // Left App/Notification Icon Container
    Rectangle {
        id: iconBadge
        width: 32
        height: 32
        radius: 10
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        color: StyleTokens.surfaceSubtle
        border.width: 1
        border.color: StyleTokens.hairlineDivider

        Image {
            id: appIconImg
            anchors.centerIn: parent
            width: 20
            height: 20
            source: notiCardRoot.resolvedIcon
            fillMode: Image.PreserveAspectFit
            visible: notiCardRoot.resolvedIcon !== ""
            smooth: true
            mipmap: true
        }

        Text {
            anchors.centerIn: parent
            text: "󰂚"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 14
            color: StyleTokens.textPrimary
            visible: notiCardRoot.resolvedIcon === ""
        }
    }

    // Middle Information Column
    Column {
        id: textCol
        anchors.left: iconBadge.right
        anchors.leftMargin: 10
        anchors.right: metaRow.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            id: titleText
            text: notiCardRoot.summary.length > 0 ? notiCardRoot.summary : notiCardRoot.appName
            font.family: StyleTokens.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: StyleTokens.textPrimary
            elide: Text.ElideRight
            width: parent.width
        }

        Text {
            id: bodyText
            text: notiCardRoot.body.length > 0 ? notiCardRoot.body : (notiCardRoot.summary.length > 0 ? notiCardRoot.appName : "")
            font.family: StyleTokens.fontFamily
            font.pixelSize: 11
            color: StyleTokens.textSecondary
            elide: Text.ElideRight
            width: parent.width
            maximumLineCount: 1
            visible: text.length > 0
        }
    }

    // Right Meta Indicator
    Row {
        id: metaRow
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
            text: cardMouse.containsMouse ? "󰅖" : "now"
            font.family: cardMouse.containsMouse ? StyleTokens.monoFontFamily : StyleTokens.fontFamily
            font.pixelSize: cardMouse.containsMouse ? 12 : 10
            font.weight: cardMouse.containsMouse ? Font.Bold : Font.Normal
            color: cardMouse.containsMouse ? StyleTokens.textPrimary : StyleTokens.textTertiary
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Per-Card Interactive Mouse Area with Hover Isolation
    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: {
            NotificationState.setItemHovered(notiCardRoot.notiId, true);
        }
        onExited: {
            NotificationState.setItemHovered(notiCardRoot.notiId, false);
        }
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                NotificationState.dismissItem(notiCardRoot.notiId);
            } else {
                NotificationState.activateItem(notiCardRoot.notiId);
            }
        }
    }

    function updateData(item) {
        if (!item) return;
        notiCardRoot.appName = item.appName || "Notification";
        notiCardRoot.appIcon = item.appIcon || "";
        notiCardRoot.summary = item.summary || "";
        notiCardRoot.body = item.body || "";
        notiCardRoot.desktopEntry = item.desktopEntry || "";
        notiCardRoot.urgency = item.urgency !== undefined ? item.urgency : 1;
        notiCardRoot.timeRemaining = item.timeRemaining;
        notiCardRoot.isHovered = item.isHovered;
        notiCardRoot.isEvicting = item.isEvicting;
    }

    function exitAndDestroy() {
        notiCardRoot.isExiting = true;
        notiCardRoot.opacity = 0.0;
        notiCardRoot.scale = 0.85;
        destroyTimer.restart();
    }

    Timer {
        id: destroyTimer
        interval: 220
        repeat: false
        onTriggered: {
            notiCardRoot.destroy();
        }
    }
}
