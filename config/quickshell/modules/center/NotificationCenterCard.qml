import QtQuick
import QtQuick.Controls
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

        // 1. Header (Icon + Title + Count Pill + Clear All Button)
        Item {
            width: parent.width
            height: 28

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰂚"
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 15
                    color: StyleTokens.textPrimary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 1
                    text: "Notifications"
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: StyleTokens.textPrimary
                }

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

                Behavior on color { ColorAnimation { duration: StyleTokens.animFast } }

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

            NotificationEmptyState {
                visible: !notiCenterRoot.hasItems
                opacity: visible ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

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
                        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 260; easing.type: Easing.OutQuad }
                        NumberAnimation { property: "scale"; from: 0.75; to: 1.0; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                        NumberAnimation { property: "y"; from: -30; duration: 280; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
                    }
                }

                addDisplaced: Transition {
                    NumberAnimation { properties: "y"; duration: 280; easing.type: Easing.OutBack; easing.overshoot: 1.10 }
                }

                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; to: 0.0; duration: 180; easing.type: Easing.OutQuad }
                        NumberAnimation { property: "scale"; to: 0.75; duration: 200; easing.type: Easing.InQuad }
                    }
                }

                removeDisplaced: Transition {
                    NumberAnimation { properties: "y"; duration: 240; easing.type: Easing.OutCubic }
                }

                ScrollBar.vertical: ScrollBar {
                    active: notiListView.moving || notiListView.dragging
                    policy: ScrollBar.AsNeeded
                    width: 3
                    contentItem: Rectangle { radius: 1.5; color: StyleTokens.surfaceActive }
                    background: Rectangle { color: StyleTokens.transparent }
                }

                delegate: NotificationCenterItem {
                    modelData: model
                }
            }
        }
    }
}
