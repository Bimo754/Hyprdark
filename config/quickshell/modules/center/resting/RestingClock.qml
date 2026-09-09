import QtQuick
import "../../../"

Row {
    id: clockRoot
    anchors.centerIn: parent
    spacing: 12

    property string currentTime: Qt.formatDateTime(new Date(), "hh:mm:ss")
    property string currentDate: Qt.formatDateTime(new Date(), "ddd MMM dd")

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            clockRoot.currentTime = Qt.formatDateTime(new Date(), "hh:mm:ss")
            clockRoot.currentDate = Qt.formatDateTime(new Date(), "ddd MMM dd")
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰸗"
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 14
            color: StyleTokens.textSecondary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: clockRoot.currentDate
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: StyleTokens.textPrimary
        }
    }

    Rectangle {
        width: 1
        height: 14
        anchors.verticalCenter: parent.verticalCenter
        color: StyleTokens.hairlineDivider
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 14
            color: StyleTokens.textSecondary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: clockRoot.currentTime
            font.family: StyleTokens.monoFontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: StyleTokens.textPrimary
        }
    }
}
