import QtQuick
import "../../../"

Item {
    id: notiPaneRoot
    width: 270
    height: parent ? parent.height : 290

    property var notificationList: []
    signal closeRequested()
    signal clearAllRequested()
    signal dismissRequested(int index)

    Column {
        anchors.fill: parent
        spacing: 10

        NotificationHeader {
            width: parent.width
            count: notiPaneRoot.notificationList ? notiPaneRoot.notificationList.length : 0
            onClearAllClicked: notiPaneRoot.clearAllRequested()
            onCloseClicked: notiPaneRoot.closeRequested()
        }

        Item {
            width: parent.width
            height: parent.height - 34

            NotificationEmptyState {
                visible: !notiPaneRoot.notificationList || notiPaneRoot.notificationList.length === 0
            }

            ListView {
                id: notiListView
                anchors.fill: parent
                spacing: 6
                clip: true
                visible: notiPaneRoot.notificationList && notiPaneRoot.notificationList.length > 0
                model: notiPaneRoot.notificationList

                delegate: NotificationCard {
                    width: notiListView.width
                    itemData: modelData
                    onDismissRequested: notiPaneRoot.dismissRequested(index)
                }
            }
        }
    }
}
