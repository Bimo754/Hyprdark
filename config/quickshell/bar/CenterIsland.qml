import QtQuick
import Quickshell
import ".."
import "../modules/center"

Item {
    id: centerIslandRoot

    readonly property bool hasNotification: NotificationState.hasActiveNotification
    readonly property bool calendarOpen: BarState.calendarOpen && !hasNotification
    property bool isRevealed: false
    readonly property bool isIslandActive: BarState.isPinned || isRevealed || calendarOpen || hasNotification

    readonly property real circleSize: 42
    readonly property real collapsedWidth: Math.max(88, innerRow.implicitWidth + 28)
    readonly property real notificationWidth: 380
    readonly property real expandedWidth: 268
    readonly property real collapsedHeight: 42
    readonly property real notificationHeight: 52
    readonly property real expandedHeight: calendarCard.implicitHeight + 12

    readonly property real targetWidth: hasNotification ? notificationWidth : (calendarOpen ? expandedWidth : collapsedWidth)
    readonly property real targetHeight: hasNotification ? notificationHeight : (calendarOpen ? expandedHeight : collapsedHeight)
    readonly property real targetRadius: hasNotification ? 20 : (calendarOpen ? 18 : 21)
    readonly property real triggerSpanWidth: 420
    readonly property real interactiveWidth: Math.max(targetWidth, triggerSpanWidth)
    readonly property real interactiveHeight: (isIslandActive || capsuleContainer.opacity > 0.01 || capsuleContainer.curY > -50) ? (7 + capsuleContainer.curH + 12) : 5

    implicitWidth: targetWidth
    implicitHeight: targetHeight
    width: implicitWidth
    height: implicitHeight

    function toggleCalendar() {
        if (BarState.calendarOpen) {
            closeCalendar();
        } else {
            BarState.calendarOpen = true;
            calendarCard.resetToToday();
        }
    }

    function closeCalendar() {
        BarState.calendarOpen = false;
        if (!BarState.isPinned) {
            hideTimer.stop();
            centerIslandRoot.isRevealed = false;
        }
    }

    Connections {
        target: BarState
        function onCalendarOpenChanged() {
            if (!BarState.calendarOpen && !BarState.isPinned) {
                hideTimer.stop();
                centerIslandRoot.isRevealed = false;
            }
        }
        function onIsPinnedChanged() {
            if (!BarState.isPinned) {
                if (!centerIslandRoot.hasAnyPointer) {
                    centerIslandRoot.isRevealed = false;
                    centerIslandRoot.isIslandFullyDisplayed = false;
                    BarState.calendarOpen = false;
                } else {
                    centerIslandRoot.isRevealed = true;
                }
            } else {
                centerIslandRoot.isIslandFullyDisplayed = true;
            }
        }
    }

    // 1. Wide screen edge hit trigger (catches mouse hitting top edge around center in dynamic mode)
    Item {
        id: edgeTriggerZone
        anchors.top: parent.top
        width: Math.max(centerIslandRoot.implicitWidth, centerIslandRoot.triggerSpanWidth)
        anchors.horizontalCenter: parent.horizontalCenter
        height: 5

        HoverHandler {
            id: edgeHover
            cursorShape: Qt.ArrowCursor
            onHoveredChanged: {
                if (hovered && !BarState.isPinned) {
                    hideTimer.stop();
                    centerIslandRoot.isRevealed = true;
                }
            }
        }
    }

    // 2. Active capsule hover zone
    Item {
        id: activeHoverZone
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.max(capsuleContainer.curW, centerIslandRoot.triggerSpanWidth)
        height: centerIslandRoot.interactiveHeight
        enabled: centerIslandRoot.isIslandActive

        HoverHandler {
            id: fullHover
            cursorShape: Qt.ArrowCursor
        }
    }

    // 3. Grace close timer to prevent twitching when pointer moves
    Timer {
        id: hideTimer
        interval: 220
        repeat: false
        onTriggered: {
            if (!BarState.isPinned && !edgeHover.hovered && !fullHover.hovered && !centerIslandRoot.isHovered && !centerIslandRoot.calendarOpen) {
                centerIslandRoot.isRevealed = false;
            }
        }
    }

    readonly property bool hasAnyPointer: edgeHover.hovered || fullHover.hovered || isHovered || calendarOpen

    onHasAnyPointerChanged: {
        if (BarState.isPinned) {
            isRevealed = hasAnyPointer;
            return;
        }
        if (hasAnyPointer) {
            hideTimer.stop();
            isRevealed = true;
        } else {
            hideTimer.restart();
        }
    }

    // Dynamic Fluid Physics Randomizer
    property real dropPlungeY: 13.0
    property real morphOvershoot: 1.25
    property real teardropScaleY: 1.40
    property real teardropScaleX: 0.74
    property real landingSquashX: 1.18
    property real landingSquashY: 0.84
    property real shimmerPeak: 1.0
    property int morphStartDelay: 100
    property int retractAscentDelay: 20

    function randomizePhysics() {
        dropPlungeY = Math.round((10.5 + Math.random() * 6.0) * 10) / 10;
        morphOvershoot = Math.round((1.16 + Math.random() * 0.24) * 100) / 100;
        teardropScaleY = Math.round((1.26 + Math.random() * 0.24) * 100) / 100;
        teardropScaleX = Math.round((1.0 / Math.sqrt(teardropScaleY)) * 100) / 100;
        landingSquashX = Math.round((1.10 + Math.random() * 0.18) * 100) / 100;
        landingSquashY = Math.round((1.0 / Math.sqrt(landingSquashX)) * 100) / 100;
        shimmerPeak = Math.round((0.50 + Math.random() * 0.50) * 100) / 100;
        morphStartDelay = Math.round(75 + Math.random() * 40);
        retractAscentDelay = Math.round(10 + Math.random() * 40);
    }

    Timer {
        id: nextCycleRandomizerTimer
        interval: 380
        repeat: false
        onTriggered: centerIslandRoot.randomizePhysics()
    }

    property bool isIslandFullyDisplayed: BarState.isPinned
    property real pulseShimmer: 0.0

    function markIslandFullyDisplayed() {
        if (centerIslandRoot.isRevealed || centerIslandRoot.hasNotification) {
            centerIslandRoot.isIslandFullyDisplayed = true;
        }
    }

    onIsRevealedChanged: {
        if (!isRevealed && !hasNotification) {
            isIslandFullyDisplayed = false;
            BarState.calendarOpen = false;
            nextCycleRandomizerTimer.restart();
        } else {
            isIslandFullyDisplayed = false;
        }
    }

    Component.onCompleted: {
        randomizePhysics();
    }

    // Instant hover detection without duplicate nested animations
    property bool isHovered: islandHover.hovered || clockClickArea.containsMouse

    // Animated Dynamic Island Capsule Container with Iconic Fluid Droplet Physics
    Item {
        id: capsuleContainer

        readonly property real circleSize: 42
        readonly property real fullWidth: centerIslandRoot.targetWidth
        readonly property real fullHeight: centerIslandRoot.targetHeight
        readonly property real fullRadius: centerIslandRoot.targetRadius

        property real curW: centerIslandRoot.isIslandActive ? fullWidth : circleSize
        property real curH: centerIslandRoot.isIslandActive ? fullHeight : circleSize
        property real curRadius: centerIslandRoot.isIslandActive ? fullRadius : 21
        property real curY: centerIslandRoot.isIslandActive ? 7 : -52

        Behavior on curW {
            enabled: centerIslandRoot.isIslandFullyDisplayed
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutBack
                easing.overshoot: 1.15
            }
        }

        Behavior on curH {
            enabled: centerIslandRoot.isIslandFullyDisplayed
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 1.08
            }
        }

        Behavior on curRadius {
            enabled: centerIslandRoot.isIslandFullyDisplayed
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        width: curW
        height: curH
        y: curY
        anchors.horizontalCenter: parent.horizontalCenter

        transform: Scale {
            id: islandScale
            origin.x: capsuleContainer.width / 2
            origin.y: 21
            xScale: 1.0
            yScale: 1.0
        }

        states: [
            State {
                name: "hidden"
                when: !centerIslandRoot.isIslandActive
                PropertyChanges {
                    target: capsuleContainer
                    curY: -52
                    curW: capsuleContainer.circleSize
                    curH: 42
                    curRadius: 21
                    opacity: 0.0
                }
                PropertyChanges {
                    target: innerRow
                    opacity: 0.0
                    scale: 0.85
                }
                PropertyChanges {
                    target: centerIslandRoot
                    pulseShimmer: 0.0
                }
                PropertyChanges {
                    target: islandScale
                    xScale: 1.0
                    yScale: 1.0
                }
            },
            State {
                name: "visible"
                when: centerIslandRoot.isIslandActive
                PropertyChanges {
                    target: capsuleContainer
                    curY: 7
                    curW: capsuleContainer.fullWidth
                    curH: capsuleContainer.fullHeight
                    curRadius: capsuleContainer.fullRadius
                    opacity: 1.0
                }
                PropertyChanges {
                    target: innerRow
                    opacity: (centerIslandRoot.calendarOpen || centerIslandRoot.hasNotification) ? 0.0 : 1.0
                    scale: (centerIslandRoot.calendarOpen || centerIslandRoot.hasNotification) ? 0.85 : 1.0
                }
                PropertyChanges {
                    target: centerIslandRoot
                    pulseShimmer: 0.0
                }
                PropertyChanges {
                    target: islandScale
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
                    // Quick fade in
                    NumberAnimation {
                        target: capsuleContainer
                        property: "opacity"
                        to: 1.0
                        duration: 80
                        easing.type: Easing.OutQuad
                    }

                    // 1. VERTICAL DROP TRAJECTORY: Ball drops out of top bezel and settles
                    SequentialAnimation {
                        NumberAnimation {
                            target: capsuleContainer
                            property: "curY"
                            to: centerIslandRoot.dropPlungeY
                            duration: 260
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: capsuleContainer
                            property: "curY"
                            to: 7
                            duration: 140
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.25
                        }
                    }

                    // 2. LIQUID DROPLET WOBBLE: Symmetrical vertical teardrop stretch -> splash squash -> settle
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation { target: islandScale; property: "xScale"; to: centerIslandRoot.teardropScaleX; duration: 160; easing.type: Easing.OutQuad }
                            NumberAnimation { target: islandScale; property: "yScale"; to: centerIslandRoot.teardropScaleY; duration: 160; easing.type: Easing.OutQuad }
                        }
                        ParallelAnimation {
                            NumberAnimation { target: islandScale; property: "xScale"; to: centerIslandRoot.landingSquashX; duration: 110; easing.type: Easing.OutQuad }
                            NumberAnimation { target: islandScale; property: "yScale"; to: centerIslandRoot.landingSquashY; duration: 110; easing.type: Easing.OutQuad }
                        }
                        ParallelAnimation {
                            NumberAnimation { target: islandScale; property: "xScale"; to: 1.0; duration: 130; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                            NumberAnimation { target: islandScale; property: "yScale"; to: 1.0; duration: 130; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                        }
                    }

                    // 3. OVERLAPPING HORIZONTAL MORPH: Morphs from droplet ball to full capsule
                    SequentialAnimation {
                        PauseAnimation { duration: centerIslandRoot.morphStartDelay }
                        ParallelAnimation {
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curW"
                                to: capsuleContainer.fullWidth
                                duration: 420
                                easing.type: Easing.OutBack
                                easing.overshoot: centerIslandRoot.morphOvershoot
                            }
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curH"
                                to: capsuleContainer.fullHeight
                                duration: 320
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.08
                            }
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curRadius"
                                to: capsuleContainer.fullRadius
                                duration: 220
                                easing.type: Easing.OutQuad
                            }
                        }
                        ScriptAction {
                            script: centerIslandRoot.markIslandFullyDisplayed()
                        }
                    }

                    // 4. CASCADE GLYPH MATERIALIZATION: Fade and pop in while capsule unfurls (only in clock mode)
                    SequentialAnimation {
                        PauseAnimation { duration: centerIslandRoot.morphStartDelay + 100 }
                        ParallelAnimation {
                            NumberAnimation {
                                target: innerRow
                                property: "opacity"
                                to: (!centerIslandRoot.calendarOpen && !centerIslandRoot.hasNotification) ? 1.0 : 0.0
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: innerRow
                                property: "scale"
                                to: (!centerIslandRoot.calendarOpen && !centerIslandRoot.hasNotification) ? 1.0 : 0.85
                                duration: 260
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.25
                            }
                        }
                    }

                    // 5. TACTILE FROSTED GLASS SHIMMER PULSE
                    SequentialAnimation {
                        PauseAnimation { duration: centerIslandRoot.morphStartDelay + 260 }
                        NumberAnimation {
                            target: centerIslandRoot
                            property: "pulseShimmer"
                            to: centerIslandRoot.shimmerPeak
                            duration: 90
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: centerIslandRoot
                            property: "pulseShimmer"
                            to: 0.0
                            duration: 320
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            },
            Transition {
                from: "visible"
                to: "hidden"
                ParallelAnimation {
                    ScriptAction {
                        script: {
                            centerIslandRoot.isIslandFullyDisplayed = false;
                            BarState.calendarOpen = false;
                        }
                    }

                    // 1. Content quick exit (fade out cleanly so only the liquid silhouette is seen)
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: innerRow
                                property: "opacity"
                                to: 0.0
                                duration: 80
                                easing.type: Easing.InQuad
                            }
                            NumberAnimation {
                                target: innerRow
                                property: "scale"
                                to: 0.80
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                        }
                    }

                    // 2. HORIZONTAL COLLAPSE TO BALL: pinches inward symmetrically
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curW"
                                to: capsuleContainer.circleSize
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curH"
                                to: 42
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curRadius"
                                to: 21
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // 3. CONCURRENT OVERLAPPING UPWARD POP-UP & UNIFORM APERTURE SHRINK
                    SequentialAnimation {
                        PauseAnimation { duration: centerIslandRoot.retractAscentDelay }
                        ParallelAnimation {
                            // Upward suction trajectory into top screen bezel
                            NumberAnimation {
                                target: capsuleContainer
                                property: "curY"
                                to: -52
                                duration: 245
                                easing.type: Easing.InCubic
                            }
                            // Uniform 1:1 circular shrink as it shoots up
                            SequentialAnimation {
                                ParallelAnimation {
                                    NumberAnimation { target: islandScale; property: "xScale"; to: 1.04; duration: 45; easing.type: Easing.OutQuad }
                                    NumberAnimation { target: islandScale; property: "yScale"; to: 1.04; duration: 45; easing.type: Easing.OutQuad }
                                }
                                ParallelAnimation {
                                    NumberAnimation { target: islandScale; property: "xScale"; to: 0.18; duration: 175; easing.type: Easing.InQuad }
                                    NumberAnimation { target: islandScale; property: "yScale"; to: 0.18; duration: 175; easing.type: Easing.InQuad }
                                }
                                ParallelAnimation {
                                    NumberAnimation { target: islandScale; property: "xScale"; to: 1.0; duration: 25; easing.type: Easing.Linear }
                                    NumberAnimation { target: islandScale; property: "yScale"; to: 1.0; duration: 25; easing.type: Easing.Linear }
                                }
                            }
                            // Dissolve as it enters the bezel
                            SequentialAnimation {
                                PauseAnimation { duration: 80 }
                                NumberAnimation {
                                    target: capsuleContainer
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

        // Monochromatic Frosted Glass Morphing Capsule Body
        Rectangle {
            id: capsulePill
            anchors.fill: parent
            radius: capsuleContainer.curRadius
            color: StyleTokens.glassBackground
            border.width: 1
            border.color: centerIslandRoot.pulseShimmer > 0.01
                ? Qt.rgba(1, 1, 1, 0.12 + 0.32 * centerIslandRoot.pulseShimmer)
                : ((centerIslandRoot.isHovered || centerIslandRoot.calendarOpen || centerIslandRoot.hasNotification) ? StyleTokens.hairlineBorderHover : StyleTokens.hairlineBorder)

            Behavior on border.color {
                ColorAnimation { duration: StyleTokens.animFast }
            }
        }

        HoverHandler {
            id: islandHover
        }

        // 1. Collapsed Clock View
        Row {
            id: innerRow
            anchors.top: parent.top
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            transformOrigin: Item.Center

            readonly property bool shouldShowClock: (centerIslandRoot.isIslandActive && !centerIslandRoot.calendarOpen && !centerIslandRoot.hasNotification)
            opacity: shouldShowClock ? 1.0 : 0.0
            scale: shouldShowClock ? 1.0 : 0.85
            visible: opacity > 0.01

            Behavior on opacity {
                enabled: centerIslandRoot.isIslandFullyDisplayed
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on scale {
                enabled: centerIslandRoot.isIslandFullyDisplayed
                NumberAnimation {
                    duration: 200
                    easing.type: innerRow.shouldShowClock ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.20
                }
            }

            DateTimeWidget {
                id: dateTimeWidget
            }
        }

        // 2. Click to Expand Clock Area
        MouseArea {
            id: clockClickArea
            anchors.fill: parent
            enabled: !centerIslandRoot.calendarOpen && !centerIslandRoot.hasNotification
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: centerIslandRoot.toggleCalendar()
        }

        // 3. Expanded Morphing Calendar View (Strictly Clipped with Instant Dissolve on Exit)
        Item {
            id: calendarCardContainer
            anchors.fill: parent
            clip: true
            opacity: centerIslandRoot.calendarOpen ? 1.0 : 0.0
            scale: centerIslandRoot.calendarOpen ? 1.0 : 0.94
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: centerIslandRoot.calendarOpen ? 200 : 70
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: centerIslandRoot.calendarOpen ? 260 : 110
                    easing.type: centerIslandRoot.calendarOpen ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.10
                }
            }

            CalendarCard {
                id: calendarCard
                anchors.fill: parent
            }
        }

        // 4. Notification View (Morphing Fluid Dynamic Pill)
        Item {
            id: notificationCardContainer
            anchors.fill: parent
            clip: true
            opacity: centerIslandRoot.hasNotification ? 1.0 : 0.0
            scale: centerIslandRoot.hasNotification ? 1.0 : 0.85
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: centerIslandRoot.hasNotification ? 220 : 120
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: centerIslandRoot.hasNotification ? 280 : 150
                    easing.type: centerIslandRoot.hasNotification ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.12
                }
            }

            NotificationPill {
                id: notificationPill
                anchors.fill: parent
            }
        }
    }
}
