import QtQuick
import Quickshell
import ".."
import "../components"

Rectangle {
    id: centerDrawerRoot

    property bool isOpen: false
    property var notificationList: [] // Array of { id, app, title, body }
    signal closeRequested()

    property date currentDate: new Date()
    property int displayYear: currentDate.getFullYear()
    property int displayMonth: currentDate.getMonth() // 0-11

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var dayHeaders: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    width: 340
    implicitHeight: Math.min(420, contentColumn.implicitHeight + 32)
    radius: StyleTokens.cardRadius
    color: StyleTokens.cardBackground
    border.width: 1
    border.color: StyleTokens.hairlineBorder
    clip: true

    opacity: isOpen ? 1.0 : 0.0
    visible: opacity > 0.001
    scale: isOpen ? 1.0 : 0.96

    Behavior on opacity {
        NumberAnimation { duration: StyleTokens.animNormal; easing.type: Easing.OutQuad }
    }

    Behavior on scale {
        NumberAnimation { duration: StyleTokens.animNormal; easing.type: Easing.OutQuad }
    }

    Column {
        id: contentColumn
        width: parent.width - 32
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 16
        spacing: 14

        // 1. Calendar Header (Month / Year Navigation)
        Row {
            width: parent.width
            height: 24

            Text {
                id: monthYearText
                text: centerDrawerRoot.monthNames[centerDrawerRoot.displayMonth] + " " + centerDrawerRoot.displayYear
                font.family: StyleTokens.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: StyleTokens.textPrimary
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: parent.width - monthYearText.implicitWidth - navRow.implicitWidth
                height: 1
            }

            Row {
                id: navRow
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: 22
                    height: 22
                    radius: StyleTokens.capsuleRadius
                    color: prevMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

                    Text {
                        anchors.centerIn: parent
                        text: "󰅁"
                        font.family: StyleTokens.monoFontFamily
                        font.pixelSize: 12
                        color: StyleTokens.textPrimary
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (centerDrawerRoot.displayMonth === 0) {
                                centerDrawerRoot.displayMonth = 11
                                centerDrawerRoot.displayYear--
                            } else {
                                centerDrawerRoot.displayMonth--
                            }
                        }
                    }
                }

                Rectangle {
                    width: 22
                    height: 22
                    radius: StyleTokens.capsuleRadius
                    color: nextMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent

                    Text {
                        anchors.centerIn: parent
                        text: "󰅂"
                        font.family: StyleTokens.monoFontFamily
                        font.pixelSize: 12
                        color: StyleTokens.textPrimary
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (centerDrawerRoot.displayMonth === 11) {
                                centerDrawerRoot.displayMonth = 0
                                centerDrawerRoot.displayYear++
                            } else {
                                centerDrawerRoot.displayMonth++
                            }
                        }
                    }
                }
            }
        }

        // 2. Day Headers (Su Mo Tu We Th Fr Sa)
        Grid {
            columns: 7
            spacing: 0
            width: parent.width

            Repeater {
                model: centerDrawerRoot.dayHeaders
                Item {
                    width: (contentColumn.width) / 7
                    height: 18

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: StyleTokens.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: StyleTokens.textSecondary
                    }
                }
            }
        }

        // 3. Calendar Day Grid (42 cells max)
        Grid {
            columns: 7
            spacing: 0
            width: parent.width

            Repeater {
                model: 35 // 5 weeks standard grid

                Item {
                    id: cellItem
                    width: (contentColumn.width) / 7
                    height: 24

                    property int firstDayOffset: new Date(centerDrawerRoot.displayYear, centerDrawerRoot.displayMonth, 1).getDay()
                    property int daysInMonth: new Date(centerDrawerRoot.displayYear, centerDrawerRoot.displayMonth + 1, 0).getDate()
                    property int dayNumber: modelData - firstDayOffset + 1
                    property bool isCurrentMonth: dayNumber >= 1 && dayNumber <= daysInMonth
                    property bool isToday: isCurrentMonth && dayNumber === centerDrawerRoot.currentDate.getDate() && centerDrawerRoot.displayMonth === centerDrawerRoot.currentDate.getMonth() && centerDrawerRoot.displayYear === centerDrawerRoot.currentDate.getFullYear()

                    Rectangle {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        radius: StyleTokens.capsuleRadius
                        color: cellItem.isToday ? StyleTokens.activePill : (cellMouse.containsMouse && cellItem.isCurrentMonth ? StyleTokens.surfaceHover : StyleTokens.transparent)

                        Text {
                            anchors.centerIn: parent
                            text: cellItem.isCurrentMonth ? String(cellItem.dayNumber) : ""
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 11
                            font.weight: cellItem.isToday ? Font.Bold : Font.Normal
                            color: cellItem.isToday ? StyleTokens.activePillText : (cellItem.isCurrentMonth ? StyleTokens.textPrimary : StyleTokens.textTertiary)
                        }

                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            hoverEnabled: cellItem.isCurrentMonth
                        }
                    }
                }
            }
        }

        // Hairline Divider between Calendar and Notifications
        Rectangle {
            width: parent.width
            height: 1
            color: StyleTokens.hairlineDivider
        }

        // 4. Notification Section Header
        Row {
            width: parent.width
            height: 20

            Text {
                text: "Notifications"
                font.family: StyleTokens.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: StyleTokens.textSecondary
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: parent.width - 90 - 45
                height: 1
            }

            Rectangle {
                width: 44
                height: 18
                radius: 4
                color: clearMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
                visible: centerDrawerRoot.notificationList.length > 0
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "Clear"
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    color: StyleTokens.textSecondary
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: centerDrawerRoot.notificationList = []
                }
            }
        }

        // 5. Notification List (Scrollable / Clamped)
        ListView {
            id: notifList
            width: parent.width
            height: Math.min(130, Math.max(28, centerDrawerRoot.notificationList.length * 48))
            clip: true
            spacing: 6
            model: centerDrawerRoot.notificationList

            delegate: Rectangle {
                width: notifList.width
                height: 42
                radius: StyleTokens.buttonRadius
                color: StyleTokens.surfaceSubtle
                border.width: 1
                border.color: StyleTokens.hairlineDivider

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    spacing: 8

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 30
                        spacing: 2

                        Text {
                            text: modelData.title || modelData.app || "Notification"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: StyleTokens.textPrimary
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: modelData.body || ""
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 10
                            color: StyleTokens.textSecondary
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    // Dismiss Button (✕)
                    Rectangle {
                        width: 18
                        height: 18
                        radius: StyleTokens.capsuleRadius
                        color: dismissMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 9
                            color: StyleTokens.textSecondary
                        }

                        MouseArea {
                            id: dismissMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var updated = []
                                for (var i = 0; i < centerDrawerRoot.notificationList.length; i++) {
                                    if (i !== index) {
                                        updated.push(centerDrawerRoot.notificationList[i])
                                    }
                                }
                                centerDrawerRoot.notificationList = updated
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "No new notifications"
                font.family: StyleTokens.fontFamily
                font.pixelSize: 11
                color: StyleTokens.textTertiary
                visible: centerDrawerRoot.notificationList.length === 0
            }
        }
    }

    function addNotification(app, title, body) {
        var list = centerDrawerRoot.notificationList.slice()
        list.unshift({ app: app, title: title, body: body, time: new Date() })
        if (list.length > 20) list.pop()
        centerDrawerRoot.notificationList = list
    }
}
