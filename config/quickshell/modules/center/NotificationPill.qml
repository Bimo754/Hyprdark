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

    // Fluid Card Container with Entry / Flip Transitions
    Item {
        id: contentHolder
        anchors.fill: parent

        property int currentNotiId: NotificationState.notificationId
        onCurrentNotiIdChanged: cardTransitionAnim.restart()

        SequentialAnimation {
            id: cardTransitionAnim
            ParallelAnimation {
                NumberAnimation {
                    target: contentHolder
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 180
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: contentHolder
                    property: "y"
                    from: 6
                    to: 0
                    duration: 200
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.12
                }
                NumberAnimation {
                    target: contentHolder
                    property: "scale"
                    from: 0.96
                    to: 1.0
                    duration: 200
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.12
                }
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
                    width: Math.min(implicitWidth, parent.width - rightMetaRow.width - 8)
                }

                Item {
                    // Flexible spacer
                    width: Math.max(0, textCol.width - titleText.width - rightMetaRow.width - 6)
                    height: 1
                }

                Row {
                    id: rightMetaRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        id: nowTag
                        text: "now"
                        font.family: StyleTokens.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Normal
                        color: StyleTokens.textTertiary
                        anchors.verticalCenter: parent.verticalCenter
                        visible: NotificationState.queueCount <= 1
                    }

                    // Stack Queue Position Badge (e.g. 1/3)
                    Rectangle {
                        id: queueBadge
                        visible: NotificationState.queueCount > 1
                        height: 18
                        width: queueText.implicitWidth + 12
                        radius: 9
                        anchors.verticalCenter: parent.verticalCenter
                        color: Qt.rgba(255, 255, 255, 0.12)
                        border.width: 1
                        border.color: StyleTokens.hairlineBorderHover
                        opacity: NotificationState.queueCount > 1 ? 1.0 : 0.0
                        scale: NotificationState.queueCount > 1 ? 1.0 : 0.7

                        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.15 } }

                        Text {
                            id: queueText
                            anchors.centerIn: parent
                            text: (NotificationState.activeIndex + 1) + "/" + NotificationState.queueCount
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: StyleTokens.textPrimary
                        }
                    }

                    // Slim Pagination Dots
                    Row {
                        id: dotsRow
                        spacing: 3
                        anchors.verticalCenter: parent.verticalCenter
                        visible: NotificationState.queueCount > 1

                        Repeater {
                            model: Math.min(4, NotificationState.queueCount)
                            Rectangle {
                                width: modelData === NotificationState.activeIndex ? 8 : 4
                                height: 4
                                radius: 2
                                color: modelData === NotificationState.activeIndex ? "#ffffff" : Qt.rgba(255, 255, 255, 0.28)

                                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
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
    }

    // Click & Scroll Interactions
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                NotificationState.dismissCurrent();
            } else {
                NotificationState.activate();
            }
        }

        onWheel: wheel => {
            if (wheel.angleDelta.y < 0) {
                NotificationState.nextNotification();
            } else if (wheel.angleDelta.y > 0) {
                NotificationState.prevNotification();
            }
        }
    }
}
