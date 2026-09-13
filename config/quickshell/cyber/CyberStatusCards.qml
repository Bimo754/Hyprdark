import QtQuick
import ".."

Row {
    id: statusCardsRoot
    width: parent.width
    height: 48
    spacing: 10

    required property var backend
    signal targetPillClicked()

    // 1. Target IP Status Pill
    Rectangle {
        height: parent.height
        width: (parent.width - 10) / 2
        radius: StyleTokens.buttonRadius
        color: targetPillHover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
        border.width: 1
        border.color: backend.hasTarget ? Qt.rgba(10/255, 132/255, 255/255, 0.45) : StyleTokens.hairlineBorder

        Behavior on color { ColorAnimation { duration: StyleTokens.animFast } }
        Behavior on border.color { ColorAnimation { duration: StyleTokens.animFast } }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Text {
                text: "󰓾"
                color: backend.hasTarget ? Qt.rgba(10/255, 132/255, 255/255, 1.0) : StyleTokens.textTertiary
                font.pixelSize: 18
                font.family: StyleTokens.monoFontFamily
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "TARGET TELEMETRY"
                    color: StyleTokens.textSecondary
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 0.5
                    font.family: StyleTokens.fontFamily
                }

                Text {
                    text: backend.hasTarget ? backend.targetIp : "Unset (Click to Set)"
                    color: backend.hasTarget ? StyleTokens.textPrimary : StyleTokens.textTertiary
                    font.pixelSize: 12
                    font.family: backend.hasTarget ? StyleTokens.monoFontFamily : StyleTokens.fontFamily
                    font.bold: backend.hasTarget
                }
            }
        }

        // Copy Target Button
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            radius: 14
            color: copyTargetHover.containsMouse ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
            border.width: 1
            border.color: StyleTokens.hairlineBorder

            Text {
                anchors.centerIn: parent
                text: "󰆏"
                color: StyleTokens.textPrimary
                font.pixelSize: 13
                font.family: StyleTokens.monoFontFamily
            }

            MouseArea {
                id: copyTargetHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: backend.copyTarget()
            }
        }

        MouseArea {
            id: targetPillHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: statusCardsRoot.targetPillClicked()
        }
    }

    // 2. VPN Status Pill
    Rectangle {
        height: parent.height
        width: (parent.width - 10) / 2
        radius: StyleTokens.buttonRadius
        color: vpnPillHover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
        border.width: 1
        border.color: backend.vpnConnected ? Qt.rgba(48/255, 209/255, 88/255, 0.45) : StyleTokens.hairlineBorder

        Behavior on color { ColorAnimation { duration: StyleTokens.animFast } }
        Behavior on border.color { ColorAnimation { duration: StyleTokens.animFast } }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: backend.vpnConnected ? Qt.rgba(48/255, 209/255, 88/255, 1.0) : StyleTokens.textTertiary
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "VPN TUNNEL (" + backend.vpnInterface + ")"
                    color: StyleTokens.textSecondary
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 0.5
                    font.family: StyleTokens.fontFamily
                }

                Text {
                    text: backend.vpnConnected ? backend.vpnIp : "Disconnected"
                    color: backend.vpnConnected ? StyleTokens.textPrimary : StyleTokens.textTertiary
                    font.pixelSize: 12
                    font.family: backend.vpnConnected ? StyleTokens.monoFontFamily : StyleTokens.fontFamily
                    font.bold: backend.vpnConnected
                }
            }
        }

        // Copy VPN Button
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            radius: 14
            color: copyVpnHover.containsMouse ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
            border.width: 1
            border.color: StyleTokens.hairlineBorder

            Text {
                anchors.centerIn: parent
                text: "󰆏"
                color: StyleTokens.textPrimary
                font.pixelSize: 13
                font.family: StyleTokens.monoFontFamily
            }

            MouseArea {
                id: copyVpnHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: backend.copyVpn()
            }
        }

        MouseArea {
            id: vpnPillHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: backend.copyVpn()
        }
    }
}
