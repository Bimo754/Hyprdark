import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0d0e15"

    // Digital Clock
    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -120
        spacing: 6

        Text {
            id: clockText
            text: Qt.formatTime(new Date(), "hh:mm:ss")
            font.pixelSize: 64
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
            color: "#e0e6ed"
            Layout.alignment: Qt.AlignHCenter

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm:ss")
            }
        }

        Text {
            id: dateText
            text: Qt.formatDate(new Date(), "dddd, dd MMMM yyyy")
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
            color: "#7a829e"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // Login Box
    Rectangle {
        width: 340
        height: 220
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        color: "#151722"
        border.color: "#282c3f"
        border.width: 1
        radius: 3

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                text: "[AUTHENTICATE SESSION]"
                font.pixelSize: 12
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                color: "#e63946"
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: usernameInput
                text: userModel.lastUser
                placeholderText: "Username"
                color: "#e0e6ed"
                font.family: "JetBrainsMono Nerd Font"
                Layout.fillWidth: true
                background: Rectangle {
                    color: "#0d0e15"
                    border.color: usernameInput.activeFocus ? "#00e5ff" : "#282c3f"
                    border.width: 1
                    radius: 2
                }
            }

            TextField {
                id: passwordInput
                echoMode: TextInput.Password
                placeholderText: "Password"
                color: "#e0e6ed"
                font.family: "JetBrainsMono Nerd Font"
                Layout.fillWidth: true
                focus: true
                background: Rectangle {
                    color: "#0d0e15"
                    border.color: passwordInput.activeFocus ? "#e63946" : "#282c3f"
                    border.width: 1
                    radius: 2
                }
                onAccepted: sddm.login(usernameInput.text, passwordInput.text, sessionModel.lastIndex)
            }

            Button {
                text: "LOGIN >"
                Layout.fillWidth: true
                contentItem: Text {
                    text: parent.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.bold: true
                    color: "#0d0e15"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "#e63946"
                    radius: 2
                }
                onClicked: sddm.login(usernameInput.text, passwordInput.text, sessionModel.lastIndex)
            }
        }
    }

    // System Footer
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
        text: "[HYPRDARK WORKSTATION - ARCH LINUX]"
        font.pixelSize: 11
        font.family: "JetBrainsMono Nerd Font"
        color: "#282c3f"
    }
}
