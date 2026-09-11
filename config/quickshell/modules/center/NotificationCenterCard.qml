import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../.."

Item {
    id: notiCenterRoot

    implicitWidth: 360
    implicitHeight: 330

    readonly property int historyCount: NotificationState.historyCount
    readonly property bool hasItems: historyCount > 0

    Column {
        id: mainCol
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // 1. Header (Icon + "Notifications" + Count Pill + Clear All Button)
        Item {
            width: parent.width
            height: 28

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // Notification Bell Icon
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰂚"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 15
                    color: StyleTokens.textPrimary
                }

                // Title
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 1
                    text: "Notifications"
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: StyleTokens.textPrimary
                }

                // Count Badge Pill
                Rectangle {
                    visible: notiCenterRoot.hasItems
                    anchors.verticalCenter: parent.verticalCenter
                    width: countText.implicitWidth + 10
                    height: 18
                    radius: StyleTokens.capsuleRadius
                    color: StyleTokens.surfaceHover
                    border.width: 1
                    border.color: StyleTokens.hairlineBorder

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 1
                        text: String(notiCenterRoot.historyCount)
                        font.family: StyleTokens.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: StyleTokens.textSecondary
                    }
                }
            }

            // "Clear All" Button
            Rectangle {
                id: clearBtn
                visible: notiCenterRoot.hasItems
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: clearBtnRow.implicitWidth + 14
                height: 24
                radius: StyleTokens.capsuleRadius
                color: clearMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.surfaceSubtle
                border.width: 1
                border.color: clearMouse.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineDivider

                Behavior on color {
                    ColorAnimation { duration: StyleTokens.animFast }
                }

                Row {
                    id: clearBtnRow
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰅖"
                        font.family: StyleTokens.monoFontFamily
                        font.pixelSize: 11
                        color: StyleTokens.textSecondary
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 1
                        text: "Clear"
                        font.family: StyleTokens.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: StyleTokens.textSecondary
                    }
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationState.clearHistory()
                }
            }
        }

        // Hairline Divider
        Rectangle {
            width: parent.width
            height: 1
            color: StyleTokens.hairlineDivider
        }

        // 2. Notification List View or Empty State
        Item {
            width: parent.width
            height: parent.height - 40
            clip: true

            // Empty State
            Column {
                anchors.centerIn: parent
                spacing: 8
                visible: !notiCenterRoot.hasItems
                opacity: visible ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: StyleTokens.surfaceSubtle
                    border.width: 1
                    border.color: StyleTokens.hairlineDivider

                    Text {
                        anchors.centerIn: parent
                        text: "󰂛"
                        font.family: StyleTokens.monoFontFamily
                        font.pixelSize: 20
                        color: StyleTokens.textTertiary
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No Notifications"
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: StyleTokens.textSecondary
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "You're all caught up"
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 10
                    color: StyleTokens.textTertiary
                }
            }

            // Active Notifications List
            ListView {
                id: notiListView
                anchors.fill: parent
                visible: notiCenterRoot.hasItems
                clip: true
                spacing: 6
                model: NotificationState.historyModel
                boundsBehavior: Flickable.StopAtBounds

                add: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 260
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.75
                            to: 1.0
                            duration: 300
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.25
                        }
                        NumberAnimation {
                            property: "y"
                            from: -30
                            duration: 280
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.15
                        }
                    }
                }

                addDisplaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 280
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.10
                    }
                }

                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            to: 0.0
                            duration: 180
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            property: "scale"
                            to: 0.75
                            duration: 200
                            easing.type: Easing.InQuad
                        }
                    }
                }

                removeDisplaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 240
                        easing.type: Easing.OutCubic
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    active: notiListView.moving || notiListView.dragging
                    policy: ScrollBar.AsNeeded
                    width: 3

                    contentItem: Rectangle {
                        radius: 1.5
                        color: StyleTokens.surfaceActive
                    }

                    background: Rectangle {
                        color: StyleTokens.transparent
                    }
                }

                delegate: Item {
                    id: itemDelegate
                    width: notiListView.width
                    height: 52

                    readonly property string curId: model.id || ""
                    readonly property string curAppName: model.appName || "Notification"
                    readonly property string curAppIcon: model.appIcon || ""
                    readonly property string curSummary: model.summary || ""
                    readonly property string curBody: model.body || ""
                    readonly property string curTimeStr: model.timeStr || ""

                    readonly property string resolvedIcon: {
                        const rawIcon = itemDelegate.curAppIcon;
                        const app = itemDelegate.curAppName ? itemDelegate.curAppName.toLowerCase() : "";

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

                        Behavior on color {
                            ColorAnimation { duration: StyleTokens.animFast }
                        }
                        Behavior on border.color {
                            ColorAnimation { duration: StyleTokens.animFast }
                        }
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
                            source: itemDelegate.resolvedIcon
                            fillMode: Image.PreserveAspectFit
                            visible: itemDelegate.resolvedIcon !== ""
                            smooth: true
                            mipmap: true
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰂚"
                            font.family: StyleTokens.monoFontFamily
                            font.pixelSize: 13
                            color: StyleTokens.textPrimary
                            visible: itemDelegate.resolvedIcon === ""
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
                            text: itemDelegate.curSummary.length > 0 ? itemDelegate.curSummary : itemDelegate.curAppName
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: StyleTokens.textPrimary
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: itemDelegate.curBody.length > 0 ? itemDelegate.curBody : (itemDelegate.curSummary.length > 0 ? itemDelegate.curAppName : "")
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
                            text: itemDelegate.curTimeStr
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
                                    if (itemDelegate.curId.length > 0) {
                                        NotificationState.dismissHistoryItem(itemDelegate.curId);
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
                                if (itemDelegate.curId.length > 0) {
                                    NotificationState.dismissHistoryItem(itemDelegate.curId);
                                }
                            } else {
                                if (itemDelegate.curId.length > 0) {
                                    NotificationState.activateHistoryItem(itemDelegate.curId);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
