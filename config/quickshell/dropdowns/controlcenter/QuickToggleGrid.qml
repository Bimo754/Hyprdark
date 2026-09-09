import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Grid {
    id: gridRoot
    columns: 2
    spacing: 8
    width: parent ? parent.width : 288

    property bool wifiEnabled: true
    property string wifiSsid: "Wi-Fi"
    property bool bluetoothEnabled: true
    property bool nightLightEnabled: false

    // 1. Wi-Fi
    QuickToggleCard {
        width: (gridRoot.width - 8) / 2
        active: gridRoot.wifiEnabled
        icon: gridRoot.wifiEnabled ? "󰤨" : "󰤭"
        label: "Wi-Fi"
        sublabel: gridRoot.wifiEnabled ? gridRoot.wifiSsid : "Off"
        onClicked: {
            gridRoot.wifiEnabled = !gridRoot.wifiEnabled
            wifiProc.command = ["nmcli", "radio", "wifi", gridRoot.wifiEnabled ? "on" : "off"]
            wifiProc.running = true
        }
    }

    // 2. Bluetooth
    QuickToggleCard {
        width: (gridRoot.width - 8) / 2
        active: gridRoot.bluetoothEnabled
        icon: gridRoot.bluetoothEnabled ? "󰂯" : "󰂲"
        label: "Bluetooth"
        sublabel: gridRoot.bluetoothEnabled ? "On" : "Off"
        onClicked: {
            gridRoot.bluetoothEnabled = !gridRoot.bluetoothEnabled
            btProc.command = ["bluetoothctl", "power", gridRoot.bluetoothEnabled ? "on" : "off"]
            btProc.running = true
        }
    }

    // 3. Night Light
    QuickToggleCard {
        width: (gridRoot.width - 8) / 2
        active: gridRoot.nightLightEnabled
        icon: "󰖔"
        label: "Night Light"
        sublabel: gridRoot.nightLightEnabled ? "Warm" : "Off"
        onClicked: {
            gridRoot.nightLightEnabled = !gridRoot.nightLightEnabled
            if (gridRoot.nightLightEnabled) {
                nlProc.command = ["hyprsunset", "-t", "4500"]
            } else {
                nlProc.command = ["pkill", "hyprsunset"]
            }
            nlProc.running = true
        }
    }

    // 4. Cyber Arsenal
    QuickToggleCard {
        width: (gridRoot.width - 8) / 2
        active: false
        icon: "󰓾"
        iconColor: "#38bdf8"
        label: "Cyber Menu"
        sublabel: "Arsenal"
        onClicked: cyberProc.running = true
    }

    Process { id: wifiProc }
    Process { id: btProc }
    Process { id: nlProc }
    Process { id: cyberProc; command: ["bash", "-c", "~/.config/rofi/scripts/cyber-menu.sh"] }
}
