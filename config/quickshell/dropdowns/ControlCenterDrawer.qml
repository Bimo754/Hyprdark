import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"

Rectangle {
    id: ccRoot

    property bool isOpen: false
    signal closeRequested()

    property bool wifiEnabled: true
    property string wifiSsid: "Wi-Fi"
    property bool bluetoothEnabled: true
    property bool nightLightEnabled: false

    property real volumeVal: 0.5
    property real brightnessVal: 0.8

    width: 320
    implicitHeight: Math.min(380, ccColumn.implicitHeight + 32)
    radius: StyleTokens.cardRadius
    color: StyleTokens.cardBackground
    border.width: 1
    border.color: StyleTokens.hairlineBorder
    clip: true

    opacity: isOpen ? 1.0 : 0.0
    visible: opacity > 0.001
    scale: isOpen ? 1.0 : 0.96

    Behavior on opacity {
        NumberAnimation { duration: StyleTokens.animNormal; easing.type: Easing.OutQuad }
    }

    Behavior on scale {
        NumberAnimation { duration: StyleTokens.animNormal; easing.type: Easing.OutQuad }
    }

    Column {
        id: ccColumn
        width: parent.width - 32
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 16
        spacing: 14

        // 1. Title Header
        Row {
            width: parent.width
            height: 22

            Text {
                text: "Control Center"
                font.family: StyleTokens.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: StyleTokens.textPrimary
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // 2. Quick Toggles Grid (Wi-Fi, Bluetooth, Night Light, Target Telemetry)
        Grid {
            columns: 2
            spacing: 8
            width: parent.width

            // Wi-Fi Button
            Rectangle {
                width: (ccColumn.width - 8) / 2
                height: 48
                radius: StyleTokens.buttonRadius
                color: ccRoot.wifiEnabled ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
                border.width: 1
                border.color: ccRoot.wifiEnabled ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: ccRoot.wifiEnabled ? "󰤨" : "󰤭"
                        font.family: StyleTokens.monoFontFamily
                        font.pixelSize: 15
                        color: StyleTokens.textPrimary
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "Wi-Fi"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: StyleTokens.textPrimary
                        }

                        Text {
                            text: ccRoot.wifiEnabled ? ccRoot.wifiSsid : "Off"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 10
                            color: StyleTokens.textSecondary
                            elide: Text.ElideRight
                            width: 70
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        ccRoot.wifiEnabled = !ccRoot.wifiEnabled
                        wifiToggleProc.command = ["nmcli", "radio", "wifi", ccRoot.wifiEnabled ? "on" : "off"]
                        wifiToggleProc.running = true
                    }
                }
            }

            // Bluetooth Button
            Rectangle {
                width: (ccColumn.width - 8) / 2
                height: 48
                radius: StyleTokens.buttonRadius
                color: ccRoot.bluetoothEnabled ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
                border.width: 1
                border.color: ccRoot.bluetoothEnabled ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: ccRoot.bluetoothEnabled ? "󰂯" : "󰂲"
                        font.family: StyleTokens.monoFontFamily
                        font.pixelSize: 15
                        color: StyleTokens.textPrimary
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "Bluetooth"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: StyleTokens.textPrimary
                        }

                        Text {
                            text: ccRoot.bluetoothEnabled ? "On" : "Off"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 10
                            color: StyleTokens.textSecondary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        ccRoot.bluetoothEnabled = !ccRoot.bluetoothEnabled
                        btToggleProc.command = ["bluetoothctl", "power", ccRoot.bluetoothEnabled ? "on" : "off"]
                        btToggleProc.running = true
                    }
                }
            }

            // Night Light Button
            Rectangle {
                width: (ccColumn.width - 8) / 2
                height: 48
                radius: StyleTokens.buttonRadius
                color: ccRoot.nightLightEnabled ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
                border.width: 1
                border.color: ccRoot.nightLightEnabled ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰖔"
                        font.family: StyleTokens.monoFontFamily
                        font.pixelSize: 15
                        color: StyleTokens.textPrimary
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "Night Light"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: StyleTokens.textPrimary
                        }

                        Text {
                            text: ccRoot.nightLightEnabled ? "Warm" : "Off"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 10
                            color: StyleTokens.textSecondary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        ccRoot.nightLightEnabled = !ccRoot.nightLightEnabled
                        if (ccRoot.nightLightEnabled) {
                            nightLightProc.command = ["hyprsunset", "-t", "4500"]
                        } else {
                            nightLightProc.command = ["pkill", "hyprsunset"]
                        }
                        nightLightProc.running = true
                    }
                }
            }

            // Cyber Arsenal / Target Launcher Button
            Rectangle {
                width: (ccColumn.width - 8) / 2
                height: 48
                radius: StyleTokens.buttonRadius
                color: StyleTokens.surfaceSubtle
                border.width: 1
                border.color: StyleTokens.hairlineBorder

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰓾"
                        font.family: StyleTokens.monoFontFamily
                        font.pixelSize: 15
                        color: "#38bdf8"
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "Cyber Menu"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: StyleTokens.textPrimary
                        }

                        Text {
                            text: "Arsenal"
                            font.family: StyleTokens.fontFamily
                            font.pixelSize: 10
                            color: StyleTokens.textSecondary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        cyberProc.running = true
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

        // 3. Smooth Volume Slider
        FrostedSlider {
            width: parent.width
            icon: "󰕾"
            label: "Volume"
            value: ccRoot.volumeVal
            onValueModified: newVal => {
                ccRoot.volumeVal = newVal
                volSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", String(newVal)]
                volSetProc.running = true
            }
        }

        // 4. Smooth Backlight Slider
        FrostedSlider {
            width: parent.width
            icon: "󰃠"
            label: "Display Backlight"
            value: ccRoot.brightnessVal
            onValueModified: newVal => {
                ccRoot.brightnessVal = newVal
                brightSetProc.command = ["brightnessctl", "set", Math.round(newVal * 100) + "%"]
                brightSetProc.running = true
            }
        }
    }

    // Helper processes
    Process { id: wifiToggleProc }
    Process { id: btToggleProc }
    Process { id: nightLightProc }
    Process { id: volSetProc }
    Process { id: brightSetProc }
    Process { id: cyberProc; command: ["bash", "-c", "~/.config/rofi/scripts/cyber-menu.sh"] }

    // Initial Status Check
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    Process {
        id: statusProc
        command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2 || echo ''; wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'; brightnessctl -m | cut -d, -f4 | tr -d '%' || echo '80'"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.trim().split("\n")
                if (lines.length >= 1 && lines[0].trim().length > 0) {
                    ccRoot.wifiSsid = lines[0].trim()
                    ccRoot.wifiEnabled = true
                }
                if (lines.length >= 2 && lines[1].trim().length > 0) {
                    ccRoot.volumeVal = parseFloat(lines[1].trim()) || 0.5
                }
                if (lines.length >= 3 && lines[2].trim().length > 0) {
                    ccRoot.brightnessVal = (parseFloat(lines[2].trim()) || 80) / 100.0
                }
            }
        }
    }
}
