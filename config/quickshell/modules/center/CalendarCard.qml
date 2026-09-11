import QtQuick
import QtQuick.Layouts
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

    function resetToToday() {
        var now = new Date();
        viewYear = now.getFullYear();
        viewMonth = now.getMonth();
        selectedDay = now.getDate();
        updateGridModel();
    }

    function changeMonth(delta) {
        var nextM = viewMonth + delta;
        if (nextM < 0) {
            viewMonth = 11;
            viewYear -= 1;
        } else if (nextM > 11) {
            viewMonth = 0;
            viewYear += 1;
        } else {
            viewMonth = nextM;
        }
        updateGridModel();
    }

    property var daysList: []

    function updateGridModel() {
        var days = [];
        var firstDayIndex = new Date(viewYear, viewMonth, 1).getDay();
        var daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
        var daysInPrevMonth = new Date(viewYear, viewMonth, 0).getDate();

        // Previous month filler days
        for (var i = firstDayIndex - 1; i >= 0; i--) {
            days.push({
                day: daysInPrevMonth - i,
                isCurrentMonth: false,
                isToday: false,
                isPrev: true
            });
        }

        // Current month days
        for (var d = 1; d <= daysInMonth; d++) {
            var isToday = (d === todayDate && viewMonth === todayMonth && viewYear === todayYear);
            days.push({
                day: d,
                isCurrentMonth: true,
                isToday: isToday,
                isPrev: false
            });
        }

        // Next month filler days to complete grid
        var totalSlots = days.length > 35 ? 42 : 35;
        var nextDay = 1;
        while (days.length < totalSlots) {
            days.push({
                day: nextDay++,
                isCurrentMonth: false,
                isToday: false,
                isPrev: false
            });
        }

        daysList = days;
    }

    Component.onCompleted: {
        updateGridModel();
    }

    Column {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 12
        spacing: 9

        // 1. Navigation Header (‹ Month Year ›)
        Row {
            width: parent.width
            height: 26

            // Previous Month Button
            Rectangle {
                width: 26
                height: 26
                radius: StyleTokens.capsuleRadius
                color: prevMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: StyleTokens.textPrimary
                }

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: calRoot.changeMonth(-1)
                }
            }

            // Month & Year Title (Click to reset to today)
            Rectangle {
                width: parent.width - 52
                height: 26
                radius: 6
                color: titleMouse.containsMouse ? StyleTokens.surfaceSubtle : StyleTokens.transparent
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: calRoot.monthNames[calRoot.viewMonth] + " " + calRoot.viewYear
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: StyleTokens.textPrimary
                }

                MouseArea {
                    id: titleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: calRoot.resetToToday()
                }
            }

            // Next Month Button
            Rectangle {
                width: 26
                height: 26
                radius: StyleTokens.capsuleRadius
                color: nextMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "›"
                    font.family: StyleTokens.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: StyleTokens.textPrimary
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: calRoot.changeMonth(1)
                }
            }
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
                        text: modelData
                        font.family: StyleTokens.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: StyleTokens.textSecondary
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

                Item {
                    width: Math.floor((dayGrid.width - 12) / 7)
                    height: 24

                    readonly property var itemData: modelData
                    readonly property bool isToday: itemData.isToday
                    readonly property bool isCurrentMonth: itemData.isCurrentMonth
                    readonly property bool isSelected: isCurrentMonth && (calRoot.selectedDay === itemData.day)

                    // Perfectly Centered 24x24 Circular Hover / Active Pill
                    Rectangle {
                        width: 24
                        height: 24
                        anchors.centerIn: parent
                        radius: StyleTokens.capsuleRadius
                        color: isToday
                            ? Qt.rgba(1, 1, 1, 0.14)
                            : (isSelected
                                ? Qt.rgba(1, 1, 1, 0.12)
                                : (cellMouse.containsMouse && isCurrentMonth ? StyleTokens.surfaceHover : StyleTokens.transparent))
                        border.width: (isToday || isSelected) ? 1 : 0
                        border.color: isToday ? Qt.rgba(1, 1, 1, 0.30) : Qt.rgba(1, 1, 1, 0.22)

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: String(itemData.day)
                        font.family: StyleTokens.fontFamily
                        font.pixelSize: 11
                        font.weight: isToday ? Font.Bold : (isSelected ? Font.Bold : (isCurrentMonth ? Font.DemiBold : Font.Normal))
                        color: isCurrentMonth ? "#ffffff" : StyleTokens.textTertiary
                    }

                    MouseArea {
                        id: cellMouse
                        anchors.fill: parent
                        hoverEnabled: isCurrentMonth
                        cursorShape: isCurrentMonth ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (isCurrentMonth) {
                                calRoot.selectedDay = itemData.day;
                            }
                        }
                    }
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

    // Wheel on calendar changes month smoothly
    MouseArea {
        anchors.fill: parent
        z: -1
        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                calRoot.changeMonth(-1);
            } else if (wheel.angleDelta.y < 0) {
                calRoot.changeMonth(1);
            }
        }
    }
}
