import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../.."

Row {
    id: batteryMetricRoot
    anchors.verticalCenter: parent.verticalCenter
    spacing: 5
    visible: UPower.displayDevice && UPower.displayDevice.isPresent

    property int batteryPercent: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) : 100
    property bool isCharging: UPower.displayDevice ? UPower.displayDevice.state === UPowerDeviceState.Charging : false

    Rectangle {
        width: 1
        height: 16
        anchors.verticalCenter: parent.verticalCenter
        color: StyleTokens.hairlineDivider
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: batteryMetricRoot.isCharging ? "󰂄" : "󰁹"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 14
        color: StyleTokens.textSecondary
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: batteryMetricRoot.batteryPercent + "%"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 12
        font.weight: Font.Medium
        color: StyleTokens.textPrimary
    }
}
