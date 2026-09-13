import QtQuick
import Quickshell
import "../.."

Item {
    id: itemRoot
    width: parent ? parent.width : 332
    height: 52

    property string curId: ""
    property string curAppName: "Notification"
    property string curAppIcon: ""
    property string curSummary: ""
    property string curBody: ""
    property string curTimeStr: ""

    readonly property string resolvedIcon: {
        const rawIcon = itemRoot.curAppIcon;
        const app = itemRoot.curAppName ? itemRoot.curAppName.toLowerCase() : "";

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

    // Card Background
    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: 12
        color: rowMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.surfaceSubtle
        border.width: 1
        border.color: rowMouse.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineDivider

        Behavior on color { ColorAnimation { duration: StyleTokens.animFast } }
        Behavior on border.color { ColorAnimation { duration: StyleTokens.animFast } }
    }

    // Icon Badge
    Rectangle {
        id: iconBadge
        width: 32
        height: 32
        radius: 8
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        color: StyleTokens.glassBackground
        border.width: 1
        border.color: StyleTokens.hairlineDivider

        Image {
            anchors.centerIn: parent
            width: 20
            height: 20
            source: itemRoot.resolvedIcon
            fillMode: Image.PreserveAspectFit
            visible: itemRoot.resolvedIcon !== ""
            smooth: true
            mipmap: true
        }

        Text {
            anchors.centerIn: parent
            text: "󰂚"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 13
            color: StyleTokens.textPrimary
            visible: itemRoot.resolvedIcon === ""
        }
    }

    // Text Details
    Column {
        anchors.left: iconBadge.right
        anchors.leftMargin: 10
        anchors.right: rightMeta.left
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: itemRoot.curSummary.length > 0 ? itemRoot.curSummary : itemRoot.curAppName
            font.family: StyleTokens.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: StyleTokens.textPrimary
            elide: Text.ElideRight
            width: parent.width
        }

        Text {
            text: itemRoot.curBody.length > 0 ? itemRoot.curBody : (itemRoot.curSummary.length > 0 ? itemRoot.curAppName : "")
            font.family: StyleTokens.fontFamily
            font.pixelSize: 10
            color: StyleTokens.textSecondary
            elide: Text.ElideRight
            width: parent.width
            maximumLineCount: 1
            visible: text.length > 0
        }
    }

    // Right Side: Timestamp & Dismiss Button
    Row {
        id: rightMeta
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        // Timestamp
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: itemRoot.curTimeStr
            font.family: StyleTokens.fontFamily
            font.pixelSize: 9
            color: StyleTokens.textTertiary
            visible: !rowMouse.containsMouse
        }

        // Dismiss button on hover
        Rectangle {
            width: 20
            height: 20
            radius: 10
            color: dismissMouse.containsMouse ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
            anchors.verticalCenter: parent.verticalCenter
            visible: rowMouse.containsMouse

            Text {
                anchors.centerIn: parent
                text: "󰅖"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 10
                color: StyleTokens.textPrimary
            }

            MouseArea {
                id: dismissMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (itemRoot.curId.length > 0) {
                        NotificationState.dismissHistoryItem(itemRoot.curId);
                    }
                }
            }
        }
    }

    // Entire Card Mouse Area to Open / Focus App
    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (itemRoot.curId.length > 0) {
                    NotificationState.dismissHistoryItem(itemRoot.curId);
                }
            } else {
                if (itemRoot.curId.length > 0) {
                    NotificationState.activateHistoryItem(itemRoot.curId);
                }
            }
        }
    }
}
