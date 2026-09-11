import QtQuick
import Quickshell
import "../.."

Item {
    id: notificationPillRoot
    anchors.fill: parent

    property string iconSource: {
        const rawIcon = NotificationState.appIcon;
        const app = NotificationState.appName ? NotificationState.appName.toLowerCase() : "";

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

    HoverHandler {
        id: pillHover
        onHoveredChanged: {
            NotificationState.isHovered = hovered;
        }
    }

    // Interactive Hover Background Highlight
    Rectangle {
        anchors.fill: parent
        radius: 20
        color: pillHover.hovered ? StyleTokens.surfaceHover : StyleTokens.transparent

        Behavior on color {
            ColorAnimation { duration: StyleTokens.animFast }
        }
    }

    // Left App/Notification Icon Container
    Rectangle {
        id: iconBadge
        width: 32
        height: 32
        radius: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        color: StyleTokens.surfaceSubtle
        border.width: 1
        border.color: StyleTokens.hairlineDivider

        Image {
            id: appIconImg
            anchors.centerIn: parent
            width: 20
            height: 20
            source: notificationPillRoot.iconSource
            fillMode: Image.PreserveAspectFit
            visible: notificationPillRoot.iconSource !== ""
            smooth: true
            mipmap: true
        }

        Text {
            anchors.centerIn: parent
            text: "󰂚"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 14
            color: StyleTokens.textPrimary
            visible: notificationPillRoot.iconSource === ""
        }
    }

    // Middle Information Column (Spans across to right edge)
    Column {
        id: textCol
        anchors.left: iconBadge.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Row {
            width: parent.width
            spacing: 6

            Text {
                id: titleText
                text: NotificationState.summary.length > 0 ? NotificationState.summary : NotificationState.appName
                font.family: StyleTokens.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: StyleTokens.textPrimary
                elide: Text.ElideRight
                width: Math.min(implicitWidth, parent.width - (nowTag.visible ? (nowTag.implicitWidth + 8) : 0))
            }

            Text {
                id: nowTag
                text: "now"
                font.family: StyleTokens.fontFamily
                font.pixelSize: 10
                font.weight: Font.Normal
                color: StyleTokens.textTertiary
                anchors.verticalCenter: parent.verticalCenter
                visible: parent.width > 120
            }
        }

        Text {
            id: bodyText
            width: parent.width
            text: NotificationState.body.length > 0 ? NotificationState.body : (NotificationState.summary.length > 0 ? NotificationState.appName : "")
            font.family: StyleTokens.fontFamily
            font.pixelSize: 11
            color: StyleTokens.textSecondary
            elide: Text.ElideRight
            maximumLineCount: 1
            visible: text.length > 0
        }
    }

    // Click to Open / Focus App & Dismiss Notification
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: NotificationState.activate()
    }
}
