import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import ".."
import "."

PanelWindow {
    id: cyberWindow
    required property var modelData
    screen: modelData

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: StyleTokens.transparent
    exclusiveZone: 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: CyberState.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Layer-Shell input mask: captures full screen when open, transparent to mouse when closed
    mask: Region {
        Region {
            x: 0
            y: 0
            width: CyberState.isOpen || exitGraceTimer.running ? cyberWindow.width : 0
            height: CyberState.isOpen || exitGraceTimer.running ? cyberWindow.height : 0
        }
    }

    CyberBackend {
        id: backend
        onActionFeedback: (title, message) => feedbackBanner.show(title, message)
    }

    Timer {
        id: exitGraceTimer
        interval: 320
        repeat: false
    }

    Connections {
        target: CyberState
        function onIsOpenChanged() {
            if (!CyberState.isOpen) {
                exitGraceTimer.restart();
                mainScope.focus = false;
            } else {
                exitGraceTimer.stop();
                targetInput.text = "";
                mainScope.focus = true;
                mainScope.forceActiveFocus();
                randomizePhysics();
            }
        }
    }

    // Dynamic Fluid Physics Randomizer
    property real dropPlungeY: 26.0
    property real morphOvershoot: 1.24
    property real teardropScaleY: 1.34
    property real teardropScaleX: 0.75
    property real landingSquashX: 1.15
    property real landingSquashY: 0.88
    property real shimmerPeak: 1.0

    function randomizePhysics() {
        dropPlungeY = Math.round((22.0 + Math.random() * 8.0) * 10) / 10;
        morphOvershoot = Math.round((1.18 + Math.random() * 0.16) * 100) / 100;
        teardropScaleY = Math.round((1.28 + Math.random() * 0.14) * 100) / 100;
        teardropScaleX = Math.round((1.0 / Math.sqrt(teardropScaleY)) * 100) / 100;
        landingSquashX = Math.round((1.10 + Math.random() * 0.12) * 100) / 100;
        landingSquashY = Math.round((1.0 / Math.sqrt(landingSquashX)) * 100) / 100;
        shimmerPeak = Math.round((0.60 + Math.random() * 0.40) * 100) / 100;
    }

    FocusScope {
        id: mainScope
        anchors.fill: parent
        focus: CyberState.isOpen

        Keys.onEscapePressed: CyberState.close()
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                CyberState.close();
                event.accepted = true;
            } else if (event.key === Qt.Key_1) {
                targetInput.forceActiveFocus();
                event.accepted = true;
            } else if (event.key === Qt.Key_2) {
                backend.copyTarget();
                event.accepted = true;
            } else if (event.key === Qt.Key_3) {
                backend.copyVpn();
                event.accepted = true;
            } else if (event.key === Qt.Key_4) {
                backend.runNmapScan("fast");
                event.accepted = true;
            } else if (event.key === Qt.Key_5) {
                backend.runNmapScan("vuln");
                event.accepted = true;
            } else if (event.key === Qt.Key_6) {
                backend.launchHttpServer();
                event.accepted = true;
            } else if (event.key === Qt.Key_7) {
                backend.launchGuiTool("burpsuite");
                event.accepted = true;
            } else if (event.key === Qt.Key_8) {
                backend.switchWallpaper();
                event.accepted = true;
            }
        }

        // 1. Scrim Backdrop
        Rectangle {
            id: scrim
            anchors.fill: parent
            color: StyleTokens.scrimBackground
            opacity: CyberState.isOpen ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: CyberState.isOpen ? 220 : 180
                    easing.type: Easing.OutQuad
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: CyberState.close()
            }
        }

        // 2. Dynamic Island Liquid Morphing Cyber Card
        Item {
            id: cardContainer
            anchors.horizontalCenter: parent.horizontalCenter

            readonly property real fullWidth: 620
            readonly property real fullHeight: 520
            readonly property real circleSize: 42

            property real curW: CyberState.isOpen ? fullWidth : circleSize
            property real curH: CyberState.isOpen ? fullHeight : circleSize
            property real curY: CyberState.isOpen ? 18 : -80
            property real pulseShimmer: 0.0

            width: curW
            height: curH
            y: curY

            transform: Scale {
                id: cardScale
                origin.x: cardContainer.width / 2
                origin.y: 21
                xScale: 1.0
                yScale: 1.0
            }

            states: [
                State {
                    name: "hidden"
                    when: !CyberState.isOpen
                    PropertyChanges { target: cardContainer; curY: -80; curW: cardContainer.circleSize; curH: cardContainer.circleSize; opacity: 0.0; pulseShimmer: 0.0 }
                    PropertyChanges { target: cardContent; opacity: 0.0; scale: 0.88; visible: false }
                    PropertyChanges { target: cardScale; xScale: 1.0; yScale: 1.0 }
                },
                State {
                    name: "visible"
                    when: CyberState.isOpen
                    PropertyChanges { target: cardContainer; curY: 18; curW: cardContainer.fullWidth; curH: cardContainer.fullHeight; opacity: 1.0 }
                    PropertyChanges { target: cardContent; opacity: 1.0; scale: 1.0; visible: true }
                    PropertyChanges { target: cardScale; xScale: 1.0; yScale: 1.0 }
                }
            ]

            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    ParallelAnimation {
                        NumberAnimation { target: cardContainer; property: "opacity"; to: 1.0; duration: 90; easing.type: Easing.OutQuad }
                        SequentialAnimation {
                            NumberAnimation { target: cardContainer; property: "curY"; to: cyberWindow.dropPlungeY; duration: 280; easing.type: Easing.OutQuad }
                            NumberAnimation { target: cardContainer; property: "curY"; to: 18; duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                        }
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation { target: cardScale; property: "xScale"; to: cyberWindow.teardropScaleX; duration: 160; easing.type: Easing.OutQuad }
                                NumberAnimation { target: cardScale; property: "yScale"; to: cyberWindow.teardropScaleY; duration: 160; easing.type: Easing.OutQuad }
                            }
                            ParallelAnimation {
                                NumberAnimation { target: cardScale; property: "xScale"; to: cyberWindow.landingSquashX; duration: 120; easing.type: Easing.OutQuad }
                                NumberAnimation { target: cardScale; property: "yScale"; to: cyberWindow.landingSquashY; duration: 120; easing.type: Easing.OutQuad }
                            }
                            ParallelAnimation {
                                NumberAnimation { target: cardScale; property: "xScale"; to: 1.0; duration: 140; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                                NumberAnimation { target: cardScale; property: "yScale"; to: 1.0; duration: 140; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                            }
                        }
                        SequentialAnimation {
                            PauseAnimation { duration: 120 }
                            ParallelAnimation {
                                NumberAnimation { target: cardContainer; property: "curW"; to: cardContainer.fullWidth; duration: 400; easing.type: Easing.OutBack; easing.overshoot: cyberWindow.morphOvershoot }
                                NumberAnimation { target: cardContainer; property: "curH"; to: cardContainer.fullHeight; duration: 400; easing.type: Easing.OutBack; easing.overshoot: cyberWindow.morphOvershoot }
                            }
                        }
                        SequentialAnimation {
                            PauseAnimation { duration: 320 }
                            ParallelAnimation {
                                NumberAnimation { target: cardContent; property: "opacity"; to: 1.0; duration: 180; easing.type: Easing.OutQuad }
                                NumberAnimation { target: cardContent; property: "scale"; to: 1.0; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    ParallelAnimation {
                        NumberAnimation { target: cardContent; property: "opacity"; to: 0.0; duration: 90; easing.type: Easing.OutQuad }
                        NumberAnimation { target: cardContent; property: "scale"; to: 0.88; duration: 120; easing.type: Easing.InQuad }
                        SequentialAnimation {
                            PauseAnimation { duration: 40 }
                            ParallelAnimation {
                                NumberAnimation { target: cardContainer; property: "curW"; to: cardContainer.circleSize; duration: 240; easing.type: Easing.InBack; easing.overshoot: 1.10 }
                                NumberAnimation { target: cardContainer; property: "curH"; to: cardContainer.circleSize; duration: 240; easing.type: Easing.InBack; easing.overshoot: 1.10 }
                                NumberAnimation { target: cardContainer; property: "curY"; to: -80; duration: 260; easing.type: Easing.InBack; easing.overshoot: 1.20 }
                                NumberAnimation { target: cardContainer; property: "opacity"; to: 0.0; duration: 260; easing.type: Easing.InQuad }
                            }
                        }
                    }
                }
            ]

            // Frosted Glass Background
            Rectangle {
                id: cardBg
                anchors.fill: parent
                radius: 20
                color: StyleTokens.glassBackground
                border.width: 1
                border.color: cardContainer.pulseShimmer > 0.01 
                    ? Qt.rgba(1, 1, 1, 0.12 + 0.38 * cardContainer.pulseShimmer)
                    : StyleTokens.hairlineBorder

                Behavior on border.color { ColorAnimation { duration: StyleTokens.animFast } }
            }

            // Card Inner Content
            Column {
                id: cardContent
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                // Header
                Item {
                    width: parent.width
                    height: 32

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Rectangle {
                            width: 28
                            height: 28
                            radius: 8
                            color: StyleTokens.surfaceSubtle
                            border.width: 1
                            border.color: StyleTokens.hairlineBorder
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "󰞇"
                                color: StyleTokens.textPrimary
                                font.pixelSize: 14
                                font.family: StyleTokens.monoFontFamily
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: "CYBER ARSENAL & TELEMETRY"
                                color: StyleTokens.textPrimary
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 0.6
                                font.family: StyleTokens.fontFamily
                            }
                            Text {
                                text: "Hyprdark Penetration Testing & Operation Suite"
                                color: StyleTokens.textSecondary
                                font.pixelSize: 10
                                font.family: StyleTokens.fontFamily
                            }
                        }
                    }

                    // Close Button
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 52
                        height: 24
                        radius: StyleTokens.capsuleRadius
                        color: closeHover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.surfaceSubtle
                        border.width: 1
                        border.color: closeHover.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "ESC"
                                color: StyleTokens.textSecondary
                                font.pixelSize: 10
                                font.bold: true
                                font.family: StyleTokens.monoFontFamily
                            }
                            Text {
                                text: "✕"
                                color: StyleTokens.textSecondary
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            id: closeHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: CyberState.close()
                        }
                    }
                }

                // Telemetry Status Cards
                CyberStatusCards {
                    backend: backend
                    onTargetPillClicked: targetInput.forceActiveFocus()
                }

                // Target Input Field
                CyberTargetInput {
                    id: targetInput
                    backend: backend
                    onSubmitted: mainScope.forceActiveFocus()
                }

                // 8 Quick Operation Cards (Grid Layout)
                Grid {
                    width: parent.width
                    columns: 2
                    spacing: 10

                    CyberActionCard {
                        indexNumber: "1"
                        icon: "󰓾"
                        title: "Set Target & Domains"
                        subtitle: "Configure active target IP"
                        onClicked: targetInput.forceActiveFocus()
                    }
                    CyberActionCard {
                        indexNumber: "2"
                        icon: "󰆏"
                        title: "Copy Target to Clipboard"
                        subtitle: "Export IP via wl-copy"
                        onClicked: backend.copyTarget()
                    }
                    CyberActionCard {
                        indexNumber: "3"
                        icon: "󰒍"
                        title: "Copy VPN to Clipboard"
                        subtitle: "Export VPN IP via wl-copy"
                        onClicked: backend.copyVpn()
                    }
                    CyberActionCard {
                        indexNumber: "4"
                        icon: "󱓞"
                        title: "Nmap Fast Scan (-F)"
                        subtitle: "Top ports service detection"
                        onClicked: backend.runNmapScan("fast")
                    }
                    CyberActionCard {
                        indexNumber: "5"
                        icon: "󰒃"
                        title: "Nmap Full Vuln Scan"
                        subtitle: "Comprehensive vuln script scan"
                        onClicked: backend.runNmapScan("vuln")
                    }
                    CyberActionCard {
                        indexNumber: "6"
                        icon: "󰒋"
                        title: "Python HTTP Server :8000"
                        subtitle: "Quick staging file server"
                        onClicked: backend.launchHttpServer()
                    }
                    CyberActionCard {
                        indexNumber: "7"
                        icon: "󰍹"
                        title: "Burp Suite / Arsenal"
                        subtitle: "Launch web penetration suite"
                        onClicked: backend.launchGuiTool("burpsuite")
                    }
                    CyberActionCard {
                        indexNumber: "8"
                        icon: "󰸉"
                        title: "Rotate Wallpaper"
                        subtitle: "Cycle next static background"
                        onClicked: backend.switchWallpaper()
                    }
                }

                // Footer with Feedback Banner & Hints
                Item {
                    width: parent.width
                    height: 24

                    CyberFeedbackBanner {
                        id: feedbackBanner
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Press [1-8] or click • [ESC] to exit"
                        color: StyleTokens.textTertiary
                        font.pixelSize: 10
                        font.family: StyleTokens.fontFamily
                    }
                }
            }
        }
    }
}
