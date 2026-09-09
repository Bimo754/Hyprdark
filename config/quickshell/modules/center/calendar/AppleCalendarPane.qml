import QtQuick
import "../../../"

Item {
    id: calPaneRoot
    width: 250
    height: parent ? parent.height : 290

    property date todayDate: new Date()
    property int viewYear: todayDate.getFullYear()
    property int viewMonth: todayDate.getMonth()
    property int selectedDay: todayDate.getDate()

    Column {
        anchors.fill: parent
        spacing: 12

        // Month / Year Navigation Header
        CalendarHeader {
            id: header
            viewYear: calPaneRoot.viewYear
            viewMonth: calPaneRoot.viewMonth
            onPrevClicked: {
                if (calPaneRoot.viewMonth === 0) {
                    calPaneRoot.viewMonth = 11
                    calPaneRoot.viewYear--
                } else {
                    calPaneRoot.viewMonth--
                }
            }
            onNextClicked: {
                if (calPaneRoot.viewMonth === 11) {
                    calPaneRoot.viewMonth = 0
                    calPaneRoot.viewYear++
                } else {
                    calPaneRoot.viewMonth++
                }
            }
            onResetTodayClicked: {
                calPaneRoot.viewYear = calPaneRoot.todayDate.getFullYear()
                calPaneRoot.viewMonth = calPaneRoot.todayDate.getMonth()
                calPaneRoot.selectedDay = calPaneRoot.todayDate.getDate()
            }
        }

        // Days Grid
        CalendarGrid {
            id: grid
            viewYear: calPaneRoot.viewYear
            viewMonth: calPaneRoot.viewMonth
            selectedDay: calPaneRoot.selectedDay
            todayDate: calPaneRoot.todayDate
        }
    }
}
