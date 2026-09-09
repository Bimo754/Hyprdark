import QtQuick
import Quickshell
import ".."
import "../components"
import "../modules/right"

IslandCapsule {
    id: rightIslandRoot

    signal toggleAudioDrawerRequested()
    signal toggleControlCenterRequested()
    signal togglePowerRequested()

    implicitHeight: 42
    implicitWidth: rightRow.implicitWidth + 24

    Row {
        id: rightRow
        anchors.centerIn: parent
        spacing: 12

        // 1. CPU Telemetry
        CpuMetric {}

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 2. RAM Telemetry
        MemoryMetric {}

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 3. Audio Volume Pill & Trigger
        VolumeMetric {
            onClicked: rightIslandRoot.toggleAudioDrawerRequested()
        }

        // 4. Battery Telemetry (auto-hidden if no battery)
        BatteryMetric {}

        // Divider
        Rectangle {
            width: 1
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            color: StyleTokens.hairlineDivider
        }

        // 5. Control Center Trigger
        ControlCenterTrigger {
            onClicked: rightIslandRoot.toggleControlCenterRequested()
        }

        // 6. Power Menu Trigger
        PowerButton {
            onClicked: rightIslandRoot.togglePowerRequested()
        }
    }
}
