import QtQuick
import "../../../"

Column {
    id: gridRoot
    width: parent ? parent.width : 260
    spacing: 6

    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()
    property int selectedDay: new Date().getDate()
    property date todayDate: new Date()

    readonly property var dayHeaders: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    // Days of Week Header
    Row {
        width: parent.width
        spacing: (parent.width - 7 * 30) / 6

        Repeater {
            model: gridRoot.dayHeaders
            Item {
                width: 30
                height: 18

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.family: StyleTokens.monoFontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: StyleTokens.textSecondary
                }
            }
        }
    }

    // 6x7 Days Grid
    Grid {
        width: parent.width
        columns: 7
        columnSpacing: (parent.width - 7 * 30) / 6
        rowSpacing: 4

        Repeater {
            model: 42
            delegate: Item {
                width: 30
                height: 28

                readonly property int cellIndex: index
                readonly property var dayInfo: calculateDay(cellIndex)
                readonly property bool isToday: dayInfo.inMonth && dayInfo.day === gridRoot.todayDate.getDate() && gridRoot.viewMonth === gridRoot.todayDate.getMonth() && gridRoot.viewYear === gridRoot.todayDate.getFullYear()
                readonly property bool isSelected: dayInfo.inMonth && dayInfo.day === gridRoot.selectedDay

                Rectangle {
                    anchors.centerIn: parent
                    width: 26
                    height: 26
                    radius: StyleTokens.capsuleRadius
                    color: isToday ? StyleTokens.activePill : (isSelected ? StyleTokens.surfaceHover : (cellMouse.containsMouse && dayInfo.inMonth ? StyleTokens.surfaceSubtle : StyleTokens.transparent))

                    Text {
                        anchors.centerIn: parent
                        text: dayInfo.day > 0 ? String(dayInfo.day) : ""
                        font.family: StyleTokens.monoFontFamily
                        font.pixelSize: 11
                        font.weight: (isToday || isSelected) ? Font.Bold : Font.Normal
                        color: isToday ? StyleTokens.activePillText : (dayInfo.inMonth ? StyleTokens.textPrimary : StyleTokens.textTertiary)
                    }
                }

                MouseArea {
                    id: cellMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: dayInfo.inMonth ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (dayInfo.inMonth) {
                            gridRoot.selectedDay = dayInfo.day
                        }
                    }
                }
            }
        }
    }

    function calculateDay(index) {
        var firstDayIndex = new Date(viewYear, viewMonth, 1).getDay()
        var totalDaysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate()
        var dayNum = index - firstDayIndex + 1

        if (dayNum < 1) {
            var prevMonthDays = new Date(viewYear, viewMonth, 0).getDate()
            return { day: prevMonthDays + dayNum, inMonth: false }
        } else if (dayNum > totalDaysInMonth) {
            return { day: dayNum - totalDaysInMonth, inMonth: false }
        } else {
            return { day: dayNum, inMonth: true }
        }
    }
}
