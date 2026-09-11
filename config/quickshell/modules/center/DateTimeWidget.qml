import QtQuick
import "../.."

Item {
    id: clockWidgetRoot
    implicitHeight: 30
    implicitWidth: clockText.implicitWidth + 16
    anchors.verticalCenter: parent.verticalCenter

    property string currentTime: "00:00"

    function updateClock() {
        const now = new Date();
        currentTime = Qt.formatTime(now, "HH:mm");
        // Synchronize timer precisely to the next minute turnover
        clockTimer.interval = Math.max(100, (60 - now.getSeconds()) * 1000 - now.getMilliseconds());
    }

    Timer {
        id: clockTimer
        running: true
        repeat: true
        triggeredOnStart: true
        interval: 1000
        onTriggered: clockWidgetRoot.updateClock()
    }

    Component.onCompleted: {
        updateClock();
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: clockWidgetRoot.currentTime
        font.family: StyleTokens.fontFamily
        font.pixelSize: 13
        font.weight: Font.Bold
        font.letterSpacing: 0.3
        color: StyleTokens.textPrimary
    }
}
