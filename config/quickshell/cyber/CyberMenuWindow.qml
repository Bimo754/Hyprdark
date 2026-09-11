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
        onActionFeedback: (title, message) => {
            feedbackBanner.titleText = title;
            feedbackBanner.bodyText = message;
            feedbackBanner.visible = true;
            feedbackTimer.restart();
        }
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

        Keys.onEscapePressed: {
            CyberState.close();
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                CyberState.close();
                event.accepted = true;
                return;
            }

            // Only process number accelerators if text input is not actively being edited
            if (!targetInput.activeFocus) {
                if (event.key === Qt.Key_1) {
                    targetInput.forceActiveFocus();
                    event.accepted = true;
                } else if (event.key === Qt.Key_2) {
                    backend.copyTarget();
                    event.accepted = true;
                } else if (event.key === Qt.Key_3) {
                    backend.openNetworkStatus();
                    event.accepted = true;
                } else if (event.key === Qt.Key_4) {
                    backend.launchHttpServer();
                    CyberState.close();
                    event.accepted = true;
                } else if (event.key === Qt.Key_5) {
                    backend.runNmapScan("standard");
                    CyberState.close();
                    event.accepted = true;
                } else if (event.key === Qt.Key_6) {
                    backend.launchGuiTool("burpsuite");
                    CyberState.close();
                    event.accepted = true;
                } else if (event.key === Qt.Key_7) {
                    backend.toggleScratchpad();
                    CyberState.close();
                    event.accepted = true;
                } else if (event.key === Qt.Key_8) {
                    backend.lockWorkstation();
                    CyberState.close();
                    event.accepted = true;
                }
            }
        }

        // 1. Ambient Frosted Dimmer Scrim
        Rectangle {
            id: scrim
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.45)
            opacity: CyberState.isOpen ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
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
                    PropertyChanges {
                        target: cardContainer
                        curY: -80
                        curW: cardContainer.circleSize
                        curH: cardContainer.circleSize
                        opacity: 0.0
                        pulseShimmer: 0.0
                    }
                    PropertyChanges {
                        target: cardContent
                        opacity: 0.0
                        scale: 0.88
                        visible: false
                    }
                    PropertyChanges {
                        target: cardScale
                        xScale: 1.0
                        yScale: 1.0
                    }
                },
                State {
                    name: "visible"
                    when: CyberState.isOpen
                    PropertyChanges {
                        target: cardContainer
                        curY: 18
                        curW: cardContainer.fullWidth
                        curH: cardContainer.fullHeight
                        opacity: 1.0
                    }
                    PropertyChanges {
                        target: cardContent
                        opacity: 1.0
                        scale: 1.0
                        visible: true
                    }
                    PropertyChanges {
                        target: cardScale
                        xScale: 1.0
                        yScale: 1.0
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    ParallelAnimation {
                        // Fade in
                        NumberAnimation {
                            target: cardContainer
                            property: "opacity"
                            to: 1.0
                            duration: 90
                            easing.type: Easing.OutQuad
                        }

                        // 1. Vertical Plunge Trajectory
                        SequentialAnimation {
                            NumberAnimation {
                                target: cardContainer
                                property: "curY"
                                to: cyberWindow.dropPlungeY
                                duration: 280
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: cardContainer
                                property: "curY"
                                to: 18
                                duration: 160
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.25
                            }
                        }

                        // 2. Teardrop Stretch & Splash Wobble
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

                        // 3. Overlapping Morph & Bloom
                        SequentialAnimation {
                            PauseAnimation { duration: 120 }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: cardContainer
                                    property: "curW"
                                    to: cardContainer.fullWidth
                                    duration: 400
                                    easing.type: Easing.OutBack
                                    easing.overshoot: cyberWindow.morphOvershoot
                                }
                                NumberAnimation {
                                    target: cardContainer
                                    property: "curH"
                                    to: cardContainer.fullHeight
                                    duration: 400
                                    easing.type: Easing.OutBack
                                    easing.overshoot: cyberWindow.morphOvershoot
                                }
                            }
                        }

                        // 4. Content Materialization
                        SequentialAnimation {
                            PauseAnimation { duration: 220 }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: cardContent
                                    property: "opacity"
                                    to: 1.0
                                    duration: 220
                                    easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    target: cardContent
                                    property: "scale"
                                    to: 1.0
                                    duration: 260
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.2
                                }
                            }
                        }

                        // 5. Tactile Shimmer Pulse
                        SequentialAnimation {
                            PauseAnimation { duration: 320 }
                            NumberAnimation {
                                target: cardContainer
                                property: "pulseShimmer"
                                to: cyberWindow.shimmerPeak
                                duration: 90
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: cardContainer
                                property: "pulseShimmer"
                                to: 0.0
                                duration: 300
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    ParallelAnimation {
                        // 1. Content Quick Exit
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation {
                                    target: cardContent
                                    property: "opacity"
                                    to: 0.0
                                    duration: 80
                                    easing.type: Easing.InQuad
                                }
                                NumberAnimation {
                                    target: cardContent
                                    property: "scale"
                                    to: 0.85
                                    duration: 90
                                    easing.type: Easing.InQuad
                                }
                            }
                        }

                        // 2. Collapse to Circle Capsule
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation {
                                    target: cardContainer
                                    property: "curW"
                                    to: cardContainer.circleSize
                                    duration: 230
                                    easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    target: cardContainer
                                    property: "curH"
                                    to: cardContainer.circleSize
                                    duration: 230
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        // 3. Upward Suction & Aperture Shrink
                        SequentialAnimation {
                            PauseAnimation { duration: 25 }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: cardContainer
                                    property: "curY"
                                    to: -80
                                    duration: 230
                                    easing.type: Easing.InCubic
                                }
                                SequentialAnimation {
                                    ParallelAnimation {
                                        NumberAnimation { target: cardScale; property: "xScale"; to: 1.04; duration: 45; easing.type: Easing.OutQuad }
                                        NumberAnimation { target: cardScale; property: "yScale"; to: 1.04; duration: 45; easing.type: Easing.OutQuad }
                                    }
                                    ParallelAnimation {
                                        NumberAnimation { target: cardScale; property: "xScale"; to: 0.18; duration: 160; easing.type: Easing.InQuad }
                                        NumberAnimation { target: cardScale; property: "yScale"; to: 0.18; duration: 160; easing.type: Easing.InQuad }
                                    }
                                    ParallelAnimation {
                                        NumberAnimation { target: cardScale; property: "xScale"; to: 1.0; duration: 25; easing.type: Easing.Linear }
                                        NumberAnimation { target: cardScale; property: "yScale"; to: 1.0; duration: 25; easing.type: Easing.Linear }
                                    }
                                }
                                SequentialAnimation {
                                    PauseAnimation { duration: 70 }
                                    NumberAnimation {
                                        target: cardContainer
                                        property: "opacity"
                                        to: 0.0
                                        duration: 140
                                        easing.type: Easing.InQuad
                                    }
                                }
                            }
                        }
                    }
                }
            ]

            // Frosted Background Card
            Rectangle {
                id: cardBg
                anchors.fill: parent
                radius: StyleTokens.cardRadius
                color: StyleTokens.glassBackground
                border.width: 1
                border.color: cardContainer.pulseShimmer > 0.01 
                    ? Qt.rgba(1, 1, 1, 0.12 + 0.35 * cardContainer.pulseShimmer)
                    : StyleTokens.hairlineBorder

                Behavior on border.color {
                    ColorAnimation { duration: StyleTokens.animFast }
                }

                // Prevent click through to scrim
                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => mouse.accepted = true
                }
            }

            // --- Inner Content Area ---
            Item {
                id: cardContent
                anchors.fill: parent
                anchors.margins: 18

                Column {
                    anchors.fill: parent
                    spacing: 14

                    // 1. Header Row
                    Item {
                        width: parent.width
                        height: 32

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Text {
                                text: "󰅶"
                                color: StyleTokens.textPrimary
                                font.pixelSize: 18
                                font.family: StyleTokens.monoFontFamily
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "CYBER OPS & ARSENAL"
                                color: StyleTokens.textPrimary
                                font.pixelSize: 14
                                font.bold: true
                                font.letterSpacing: 1.0
                                font.family: StyleTokens.fontFamily
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Close Pill Badge
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 64
                            height: 26
                            radius: StyleTokens.capsuleRadius
                            color: closeHover.containsMouse ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
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

                    // 2. Telemetry Status Strip
                    Row {
                        width: parent.width
                        height: 48
                        spacing: 10

                        // Target IP Status Pill
                        Rectangle {
                            height: parent.height
                            width: (parent.width - 10) / 2
                            radius: StyleTokens.buttonRadius
                            color: targetPillHover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: backend.hasTarget ? Qt.rgba(10/255, 132/255, 255/255, 0.45) : StyleTokens.hairlineBorder

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
                                onClicked: targetInput.forceActiveFocus()
                            }
                        }

                        // VPN Status Pill
                        Rectangle {
                            height: parent.height
                            width: (parent.width - 10) / 2
                            radius: StyleTokens.buttonRadius
                            color: vpnPillHover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: backend.vpnConnected ? Qt.rgba(48/255, 209/255, 88/255, 0.45) : StyleTokens.hairlineBorder

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

                    // 3. Inline Target & Domain Input Bar
                    Rectangle {
                        width: parent.width
                        height: 38
                        radius: StyleTokens.buttonRadius
                        color: StyleTokens.cardBackground
                        border.width: 1
                        border.color: targetInput.activeFocus ? Qt.rgba(10/255, 132/255, 255/255, 0.55) : StyleTokens.hairlineBorder

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                text: "󰄾"
                                color: targetInput.activeFocus ? Qt.rgba(10/255, 132/255, 255/255, 1.0) : StyleTokens.textTertiary
                                font.pixelSize: 14
                                font.family: StyleTokens.monoFontFamily
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextInput {
                                id: targetInput
                                width: parent.width - 90
                                anchors.verticalCenter: parent.verticalCenter
                                font.family: StyleTokens.monoFontFamily
                                font.pixelSize: 12
                                color: StyleTokens.textPrimary
                                selectByMouse: true
                                clip: true

                                Text {
                                    text: "Set target (e.g. 10.10.11.50, +subdomain, 'clear')"
                                    color: StyleTokens.textTertiary
                                    font.family: StyleTokens.fontFamily
                                    font.pixelSize: 11
                                    visible: !targetInput.text && !targetInput.activeFocus
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                onAccepted: {
                                    if (targetInput.text.trim() !== "") {
                                        backend.setTarget(targetInput.text);
                                        targetInput.text = "";
                                        mainScope.forceActiveFocus();
                                    }
                                }
                            }

                            // Enter Submit Pill
                            Rectangle {
                                width: 44
                                height: 24
                                radius: 6
                                anchors.verticalCenter: parent.verticalCenter
                                color: submitHover.containsMouse ? StyleTokens.surfaceActive : StyleTokens.surfaceSubtle
                                border.width: 1
                                border.color: StyleTokens.hairlineBorder

                                Text {
                                    anchors.centerIn: parent
                                    text: "SET"
                                    color: StyleTokens.textSecondary
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.family: StyleTokens.monoFontFamily
                                }

                                MouseArea {
                                    id: submitHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (targetInput.text.trim() !== "") {
                                            backend.setTarget(targetInput.text);
                                            targetInput.text = "";
                                            mainScope.forceActiveFocus();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 4. Operations Grid (2 Columns × 4 Rows)
                    Grid {
                        width: parent.width
                        columns: 2
                        spacing: 10

                        // Operation 1
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 58
                            radius: StyleTokens.buttonRadius
                            color: op1Hover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: op1Hover.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 6
                                    color: StyleTokens.surfaceSubtle
                                    border.width: 1
                                    border.color: StyleTokens.hairlineBorder
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "1"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: StyleTokens.monoFontFamily
                                    }
                                }

                                Text {
                                    text: "󰓾"
                                    color: StyleTokens.textPrimary
                                    font.pixelSize: 18
                                    font.family: StyleTokens.monoFontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: "Set Target & Domains"
                                        color: StyleTokens.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.family: StyleTokens.fontFamily
                                    }
                                    Text {
                                        text: "Configure active target IP"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 10
                                        font.family: StyleTokens.fontFamily
                                    }
                                }
                            }

                            MouseArea {
                                id: op1Hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: targetInput.forceActiveFocus()
                            }
                        }

                        // Operation 2
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 58
                            radius: StyleTokens.buttonRadius
                            color: op2Hover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: op2Hover.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 6
                                    color: StyleTokens.surfaceSubtle
                                    border.width: 1
                                    border.color: StyleTokens.hairlineBorder
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "2"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: StyleTokens.monoFontFamily
                                    }
                                }

                                Text {
                                    text: "󰆏"
                                    color: StyleTokens.textPrimary
                                    font.pixelSize: 18
                                    font.family: StyleTokens.monoFontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: "Copy Target to Clipboard"
                                        color: StyleTokens.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.family: StyleTokens.fontFamily
                                    }
                                    Text {
                                        text: "Export IP via wl-copy"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 10
                                        font.family: StyleTokens.fontFamily
                                    }
                                }
                            }

                            MouseArea {
                                id: op2Hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backend.copyTarget()
                            }
                        }

                        // Operation 3
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 58
                            radius: StyleTokens.buttonRadius
                            color: op3Hover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: op3Hover.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 6
                                    color: StyleTokens.surfaceSubtle
                                    border.width: 1
                                    border.color: StyleTokens.hairlineBorder
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "3"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: StyleTokens.monoFontFamily
                                    }
                                }

                                Text {
                                    text: "󰛳"
                                    color: StyleTokens.textPrimary
                                    font.pixelSize: 18
                                    font.family: StyleTokens.monoFontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: "Network & VPN Status"
                                        color: StyleTokens.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.family: StyleTokens.fontFamily
                                    }
                                    Text {
                                        text: "Inspect active interfaces"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 10
                                        font.family: StyleTokens.fontFamily
                                    }
                                }
                            }

                            MouseArea {
                                id: op3Hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backend.openNetworkStatus()
                            }
                        }

                        // Operation 4
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 58
                            radius: StyleTokens.buttonRadius
                            color: op4Hover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: op4Hover.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 6
                                    color: StyleTokens.surfaceSubtle
                                    border.width: 1
                                    border.color: StyleTokens.hairlineBorder
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "4"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: StyleTokens.monoFontFamily
                                    }
                                }

                                Text {
                                    text: "󰒋"
                                    color: StyleTokens.textPrimary
                                    font.pixelSize: 18
                                    font.family: StyleTokens.monoFontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: "Python HTTP Server"
                                        color: StyleTokens.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.family: StyleTokens.fontFamily
                                    }
                                    Text {
                                        text: "Instant payload server (:8000)"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 10
                                        font.family: StyleTokens.fontFamily
                                    }
                                }
                            }

                            MouseArea {
                                id: op4Hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    backend.launchHttpServer();
                                    CyberState.close();
                                }
                            }
                        }

                        // Operation 5
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 58
                            radius: StyleTokens.buttonRadius
                            color: op5Hover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: op5Hover.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 6
                                    color: StyleTokens.surfaceSubtle
                                    border.width: 1
                                    border.color: StyleTokens.hairlineBorder
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "5"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: StyleTokens.monoFontFamily
                                    }
                                }

                                Text {
                                    text: "󰓅"
                                    color: StyleTokens.textPrimary
                                    font.pixelSize: 18
                                    font.family: StyleTokens.monoFontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: "Quick Nmap Scan"
                                        color: StyleTokens.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.family: StyleTokens.fontFamily
                                    }
                                    Text {
                                        text: "Scan target in Kitty terminal"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 10
                                        font.family: StyleTokens.fontFamily
                                    }
                                }
                            }

                            MouseArea {
                                id: op5Hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    backend.runNmapScan("standard");
                                    CyberState.close();
                                }
                            }
                        }

                        // Operation 6
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 58
                            radius: StyleTokens.buttonRadius
                            color: op6Hover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: op6Hover.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 6
                                    color: StyleTokens.surfaceSubtle
                                    border.width: 1
                                    border.color: StyleTokens.hairlineBorder
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "6"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: StyleTokens.monoFontFamily
                                    }
                                }

                                Text {
                                    text: "󰈹"
                                    color: StyleTokens.textPrimary
                                    font.pixelSize: 18
                                    font.family: StyleTokens.monoFontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: "Launch Cyber Arsenal"
                                        color: StyleTokens.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.family: StyleTokens.fontFamily
                                    }
                                    Text {
                                        text: "Burp Suite & Security Tools"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 10
                                        font.family: StyleTokens.fontFamily
                                    }
                                }
                            }

                            MouseArea {
                                id: op6Hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    backend.launchGuiTool("burpsuite");
                                    CyberState.close();
                                }
                            }
                        }

                        // Operation 7
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 58
                            radius: StyleTokens.buttonRadius
                            color: op7Hover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: op7Hover.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 6
                                    color: StyleTokens.surfaceSubtle
                                    border.width: 1
                                    border.color: StyleTokens.hairlineBorder
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "7"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: StyleTokens.monoFontFamily
                                    }
                                }

                                Text {
                                    text: "󰞷"
                                    color: StyleTokens.textPrimary
                                    font.pixelSize: 18
                                    font.family: StyleTokens.monoFontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: "Quake Scratchpad"
                                        color: StyleTokens.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.family: StyleTokens.fontFamily
                                    }
                                    Text {
                                        text: "Toggle dropdown terminal"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 10
                                        font.family: StyleTokens.fontFamily
                                    }
                                }
                            }

                            MouseArea {
                                id: op7Hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    backend.toggleScratchpad();
                                    CyberState.close();
                                }
                            }
                        }

                        // Operation 8
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 58
                            radius: StyleTokens.buttonRadius
                            color: op8Hover.containsMouse ? StyleTokens.surfaceHover : StyleTokens.cardBackground
                            border.width: 1
                            border.color: op8Hover.containsMouse ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 6
                                    color: StyleTokens.surfaceSubtle
                                    border.width: 1
                                    border.color: StyleTokens.hairlineBorder
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "8"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: StyleTokens.monoFontFamily
                                    }
                                }

                                Text {
                                    text: "󰌾"
                                    color: StyleTokens.textPrimary
                                    font.pixelSize: 18
                                    font.family: StyleTokens.monoFontFamily
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: "Lock Workstation"
                                        color: StyleTokens.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.family: StyleTokens.fontFamily
                                    }
                                    Text {
                                        text: "Engage Hyprlock session"
                                        color: StyleTokens.textSecondary
                                        font.pixelSize: 10
                                        font.family: StyleTokens.fontFamily
                                    }
                                }
                            }

                            MouseArea {
                                id: op8Hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    backend.lockWorkstation();
                                    CyberState.close();
                                }
                            }
                        }
                    }

                    // 5. Action Feedback Banner & Footer Tips
                    Item {
                        width: parent.width
                        height: 24

                        Rectangle {
                            id: feedbackBanner
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            height: 22
                            width: fbRow.implicitWidth + 16
                            radius: StyleTokens.capsuleRadius
                            color: Qt.rgba(10/255, 132/255, 255/255, 0.25)
                            border.width: 1
                            border.color: Qt.rgba(10/255, 132/255, 255/255, 0.55)
                            visible: false

                            property string titleText: ""
                            property string bodyText: ""

                            Row {
                                id: fbRow
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰄬"
                                    color: Qt.rgba(10/255, 132/255, 255/255, 1.0)
                                    font.pixelSize: 11
                                    font.family: StyleTokens.monoFontFamily
                                }

                                Text {
                                    text: feedbackBanner.titleText + ": " + feedbackBanner.bodyText
                                    color: StyleTokens.textPrimary
                                    font.pixelSize: 10
                                    font.family: StyleTokens.monoFontFamily
                                }
                            }

                            Timer {
                                id: feedbackTimer
                                interval: 2800
                                repeat: false
                                onTriggered: feedbackBanner.visible = false
                            }
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
}
