import QtQuick
import "../.."

Item {
    id: calRoot

    implicitWidth: 268
    implicitHeight: contentCol.implicitHeight + 24

    property var currentDate: new Date()
    property int viewYear: currentDate.getFullYear()
    property int viewMonth: currentDate.getMonth()
    property int selectedDay: currentDate.getDate()

    readonly property int todayDate: currentDate.getDate()
    readonly property int todayMonth: currentDate.getMonth()
    readonly property int todayYear: currentDate.getFullYear()

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    readonly property var dayHeaders: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    function calculateDays(y, m) {
        var days = [];
        var firstDayIndex = new Date(y, m, 1).getDay();
        var daysInMonth = new Date(y, m + 1, 0).getDate();
        var daysInPrevMonth = new Date(y, m, 0).getDate();

        // Previous month filler days
        for (var i = firstDayIndex - 1; i >= 0; i--) {
            days.push({ day: daysInPrevMonth - i, isCurrentMonth: false, isToday: false, isPrev: true });
        }

        // Current month days
        for (var d = 1; d <= daysInMonth; d++) {
            var isToday = (d === todayDate && m === todayMonth && y === todayYear);
            days.push({ day: d, isCurrentMonth: true, isToday: isToday, isPrev: false });
        }

        // Next month filler days
        var totalSlots = days.length > 35 ? 42 : 35;
        var nextDay = 1;
        while (days.length < totalSlots) {
            days.push({ day: nextDay++, isCurrentMonth: false, isToday: false, isPrev: false });
        }

        return days;
    }

    property var daysList: calculateDays(viewYear, viewMonth)

    function resetToToday() {
        var now = new Date();
        viewYear = now.getFullYear();
        viewMonth = now.getMonth();
        selectedDay = now.getDate();
        daysList = calculateDays(viewYear, viewMonth);
    }

    function changeMonth(delta) {
        var nextM = viewMonth + delta;
        var nextY = viewYear;
        if (nextM < 0) {
            nextM = 11;
            nextY -= 1;
        } else if (nextM > 11) {
            nextM = 0;
            nextY += 1;
        }
        viewMonth = nextM;
        viewYear = nextY;
        daysList = calculateDays(viewYear, viewMonth);
    }

    Column {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 12
        spacing: 9

        // 1. Navigation Header
        CalendarHeader {
            titleText: calRoot.monthNames[calRoot.viewMonth] + " " + calRoot.viewYear
            onPrevClicked: calRoot.changeMonth(-1)
            onNextClicked: calRoot.changeMonth(1)
            onTitleClicked: calRoot.resetToToday()
        }

        // 2. Weekday Column Headers
        Grid {
            columns: 7
            width: parent.width
            spacing: 2

            Repeater {
                model: calRoot.dayHeaders
                Item {
                    width: Math.floor((parent.width - 12) / 7)
                    height: 18
                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 1
                        text: modelData
                        font.family: StyleTokens.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: StyleTokens.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // 3. Calendar Day Grid (7 columns)
        Grid {
            id: dayGrid
            columns: 7
            width: parent.width
            spacing: 2

            Repeater {
                model: calRoot.daysList
                CalendarDayCell {
                    width: Math.floor((dayGrid.width - 12) / 7)
                    dayData: modelData
                    selectedDay: calRoot.selectedDay
                    onDayClicked: day => calRoot.selectedDay = day
                }
            }
        }

        // Hairline Divider
        Rectangle {
            width: parent.width
            height: 1
            color: StyleTokens.hairlineDivider
        }

        // 4. Footer Glance
        Item {
            width: parent.width
            height: 20

            Text {
                id: glanceText
                anchors.centerIn: parent
                text: {
                    var dateObj = new Date(calRoot.viewYear, calRoot.viewMonth, calRoot.selectedDay);
                    return Qt.formatDate(dateObj, "dddd, MMMM d, yyyy");
                }
                font.family: StyleTokens.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: StyleTokens.textSecondary
            }
        }
    }

    // Smooth Month Changing on Scroll
    MouseArea {
        anchors.fill: parent
        z: -1
        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) calRoot.changeMonth(-1);
            else if (wheel.angleDelta.y < 0) calRoot.changeMonth(1);
        }
    }
}
