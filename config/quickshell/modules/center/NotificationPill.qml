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

    // Stacked Glass Layer Contour (Appears when extra notifications are queued)
    Rectangle {
        id: stackedCardLayer
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: -3
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        z: -1
        radius: 18
        color: StyleTokens.glassBackground
        border.width: 1
        border.color: StyleTokens.hairlineDivider
        visible: NotificationState.extraCount > 0
        opacity: NotificationState.extraCount > 0 ? 0.75 : 0.0
        scale: NotificationState.extraCount > 0 ? 0.98 : 0.90

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutBack; easing.overshoot: 1.15 } }
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
                    from: 8
                    to: 0
                    duration: 220
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.15
                }
                NumberAnimation {
                    target: contentHolder
                    property: "scale"
                    from: 0.94
                    to: 1.0
                    duration: 220
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.15
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
                        visible: textCol.width > 120
                    }

                    // Minimalist Stack Counter Badge (+N)
                    Rectangle {
                        id: stackBadge
                        visible: NotificationState.extraCount > 0
                        height: 18
                        width: stackText.implicitWidth + 10
                        radius: 9
                        anchors.verticalCenter: parent.verticalCenter
                        color: Qt.rgba(255, 255, 255, 0.12)
                        border.width: 1
                        border.color: StyleTokens.hairlineBorderHover
                        opacity: NotificationState.extraCount > 0 ? 1.0 : 0.0
                        scale: NotificationState.extraCount > 0 ? 1.0 : 0.6

                        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }

                        Text {
                            id: stackText
                            anchors.centerIn: parent
                            text: "+" + NotificationState.extraCount
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: StyleTokens.textPrimary
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
