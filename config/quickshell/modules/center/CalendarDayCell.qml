import QtQuick
import "../.."

Item {
    id: cellRoot
    width: 32
    height: 24

    property var dayData: null
    property int selectedDay: 0
    signal dayClicked(int day)

    readonly property bool isToday: dayData ? !!dayData.isToday : false
    readonly property bool isCurrentMonth: dayData ? !!dayData.isCurrentMonth : false
    readonly property int dayValue: dayData ? (dayData.day || 0) : 0
    readonly property bool isSelected: isCurrentMonth && (selectedDay === dayValue)

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
        text: cellRoot.dayValue > 0 ? String(cellRoot.dayValue) : ""
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
            if (cellRoot.isCurrentMonth && cellRoot.dayValue > 0) {
                cellRoot.dayClicked(cellRoot.dayValue);
            }
        }
    }
}
