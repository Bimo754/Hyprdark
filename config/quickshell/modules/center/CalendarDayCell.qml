import QtQuick
import "../.."

Item {
    id: cellRoot
    width: 32
    height: 24

    required property var modelData
    required property int selectedDay
    signal dayClicked(int day)

    readonly property bool isToday: modelData.isToday
    readonly property bool isCurrentMonth: modelData.isCurrentMonth
    readonly property bool isSelected: isCurrentMonth && (selectedDay === modelData.day)

    Rectangle {
        id: dayBg
        width: 24
        height: 24
        anchors.centerIn: parent
        radius: StyleTokens.capsuleRadius
        color: cellRoot.isToday
            ? Qt.rgba(1, 1, 1, 0.14)
            : (cellRoot.isSelected
                ? Qt.rgba(1, 1, 1, 0.12)
                : (cellMouse.containsMouse && cellRoot.isCurrentMonth ? StyleTokens.surfaceHover : StyleTokens.transparent))
        border.width: (cellRoot.isToday || cellRoot.isSelected) ? 1 : 0
        border.color: cellRoot.isToday ? Qt.rgba(1, 1, 1, 0.30) : Qt.rgba(1, 1, 1, 0.22)

        Behavior on color { ColorAnimation { duration: 100 } }
    }

    Text {
        anchors.centerIn: dayBg
        anchors.verticalCenterOffset: 1
        text: String(cellRoot.modelData.day)
        font.family: StyleTokens.fontFamily
        font.pixelSize: 11
        font.weight: cellRoot.isToday ? Font.Bold : (cellRoot.isSelected ? Font.Bold : (cellRoot.isCurrentMonth ? Font.DemiBold : Font.Normal))
        color: cellRoot.isCurrentMonth ? "#ffffff" : StyleTokens.textTertiary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        id: cellMouse
        anchors.fill: parent
        hoverEnabled: cellRoot.isCurrentMonth
        cursorShape: cellRoot.isCurrentMonth ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (cellRoot.isCurrentMonth) {
                cellRoot.dayClicked(cellRoot.modelData.day);
            }
        }
    }
}
