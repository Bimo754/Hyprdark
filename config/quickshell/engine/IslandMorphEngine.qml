import QtQuick
import ".."

Item {
    id: engineRoot

    // Target Dimensions & Properties
    property real targetWidth: 110
    property real targetHeight: 42
    property real targetRadius: 21
    property real circleSize: 42

    // State Inputs
    property bool isIslandActive: false
    property bool isPinned: BarState.isPinned

    // Droplet Physics
    property DropletPhysics physics: DropletPhysics {}

    // Nucleation offset (for left or asymmetric islands)
    readonly property real hiddenOriginX: (targetWidth - circleSize) * physics.dropletOriginRatio

    // Output Animated Properties
    property real curW: circleSize
    property real curH: circleSize
    property real curX: hiddenOriginX
    property real curRadius: 21
    property real curY: -52
    property real curOpacity: 0.0
    property real contentOpacity: isPinned ? 1.0 : 0.0
    property real contentScale: isPinned ? 1.0 : 0.88
    property real scaleX: 1.0
    property real scaleY: 1.0
    property bool isFullyDisplayed: false

    // Size-adaptive inertia: Bigger panels (e.g. Notification Center 360x340) have more mass and travel further
    readonly property bool isBigPanel: (targetWidth >= 340 || targetHeight >= 300 || curW >= 340 || curH >= 300)
    readonly property int dynamicMorphWidthDuration: isBigPanel ? 370 : 320
    readonly property int dynamicMorphHeightDuration: isBigPanel ? 350 : 300

    // Reactive Dimension Morphing (Active when fully displayed)
    readonly property bool canMorphDimensions: isFullyDisplayed && !entranceAnimation.running && !retractAnimation.running

    onTargetWidthChanged: {
        if (canMorphDimensions) {
            curW = targetWidth;
        }
    }

    onTargetHeightChanged: {
        if (canMorphDimensions) {
            curH = targetHeight;
        }
    }

    onTargetRadiusChanged: {
        if (canMorphDimensions) {
            curRadius = targetRadius;
        }
    }

    Behavior on curW {
        enabled: engineRoot.canMorphDimensions
        NumberAnimation {
            duration: engineRoot.dynamicMorphWidthDuration
            easing.type: (engineRoot.targetWidth < engineRoot.curW) ? Easing.OutCubic : Easing.OutBack
            easing.overshoot: engineRoot.isBigPanel ? 1.08 : 1.12
        }
    }

    Behavior on curH {
        enabled: engineRoot.canMorphDimensions
        NumberAnimation {
            duration: engineRoot.dynamicMorphHeightDuration
            easing.type: (engineRoot.targetHeight < engineRoot.curH) ? Easing.OutCubic : Easing.OutBack
            easing.overshoot: engineRoot.isBigPanel ? 1.04 : 1.06
        }
    }

    Behavior on curRadius {
        enabled: engineRoot.canMorphDimensions
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutQuad
        }
    }

    // State Synchronization
    onIsIslandActiveChanged: {
        if (isIslandActive) {
            retractAnimation.stop();
            isFullyDisplayed = false;
            entranceAnimation.restart();
        } else {
            entranceAnimation.stop();
            isFullyDisplayed = false;
            retractAnimation.restart();
        }
    }

    function applyPinnedState() {
        entranceAnimation.stop();
        retractAnimation.stop();
        curY = 7;
        curX = 0;
        curOpacity = 1.0;
        contentOpacity = 1.0;
        contentScale = 1.0;
        scaleX = 1.0;
        scaleY = 1.0;
        curW = targetWidth;
        curH = targetHeight;
        curRadius = targetRadius;
        isFullyDisplayed = true;
    }

    // 1. Dynamic Droplet Entrance Animation
    ParallelAnimation {
        id: entranceAnimation

        // Reset starting values
        PropertyAction { target: engineRoot; property: "curOpacity"; value: 0.0 }
        PropertyAction { target: engineRoot; property: "contentOpacity"; value: 0.0 }
        PropertyAction { target: engineRoot; property: "contentScale"; value: 0.88 }
        PropertyAction { target: engineRoot; property: "curY"; value: -52 }
        PropertyAction { target: engineRoot; property: "curX"; value: engineRoot.hiddenOriginX }
        PropertyAction { target: engineRoot; property: "curW"; value: engineRoot.circleSize }
        PropertyAction { target: engineRoot; property: "curH"; value: engineRoot.circleSize }
        PropertyAction { target: engineRoot; property: "curRadius"; value: 21 }
        PropertyAction { target: engineRoot; property: "scaleX"; value: 1.0 }
        PropertyAction { target: engineRoot; property: "scaleY"; value: 1.0 }

        // Fast opacity fade-in
        NumberAnimation {
            target: engineRoot
            property: "curOpacity"
            to: 1.0
            duration: 80
            easing.type: Easing.OutQuad
        }

        // Vertical Droplet Plunge Trajectory
        SequentialAnimation {
            NumberAnimation {
                target: engineRoot
                property: "curY"
                to: engineRoot.physics.dropPlungeY
                duration: 210
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: engineRoot
                property: "curY"
                to: 7
                duration: 120
                easing.type: Easing.OutBack
                easing.overshoot: 1.15
            }
        }

        // Liquid Droplet Wobble (Teardrop stretch -> Splash squash -> Settle)
        SequentialAnimation {
            // Teardrop stretch while falling
            ParallelAnimation {
                NumberAnimation { target: engineRoot; property: "scaleX"; to: engineRoot.physics.teardropScaleX; duration: 150; easing.type: Easing.OutQuad }
                NumberAnimation { target: engineRoot; property: "scaleY"; to: engineRoot.physics.teardropScaleY; duration: 150; easing.type: Easing.OutQuad }
            }
            // Splash squash on touchdown
            ParallelAnimation {
                NumberAnimation { target: engineRoot; property: "scaleX"; to: engineRoot.physics.landingSquashX; duration: 90; easing.type: Easing.OutQuad }
                NumberAnimation { target: engineRoot; property: "scaleY"; to: engineRoot.physics.landingSquashY; duration: 90; easing.type: Easing.OutQuad }
            }
            // Rebound settle
            ParallelAnimation {
                NumberAnimation { target: engineRoot; property: "scaleX"; to: 1.0; duration: 100; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
                NumberAnimation { target: engineRoot; property: "scaleY"; to: 1.0; duration: 100; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
            }
        }

        // Horizontal Bloom into Target Island Capsule
        SequentialAnimation {
            PauseAnimation { duration: engineRoot.physics.morphStartDelay }
            ParallelAnimation {
                NumberAnimation {
                    target: engineRoot
                    property: "curW"
                    to: engineRoot.targetWidth
                    duration: engineRoot.isBigPanel ? 370 : 340
                    easing.type: Easing.OutBack
                    easing.overshoot: engineRoot.physics.morphOvershoot
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curX"
                    to: 0
                    duration: engineRoot.isBigPanel ? 370 : 340
                    easing.type: Easing.OutBack
                    easing.overshoot: engineRoot.physics.morphOvershoot
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curH"
                    to: engineRoot.targetHeight
                    duration: engineRoot.isBigPanel ? 340 : 280
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.08
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curRadius"
                    to: engineRoot.targetRadius
                    duration: 220
                    easing.type: Easing.OutQuad
                }
                // Cascade Content Materialization as capsule blooms
                SequentialAnimation {
                    PauseAnimation { duration: 70 }
                    ParallelAnimation {
                        NumberAnimation {
                            target: engineRoot
                            property: "contentOpacity"
                            to: 1.0
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: engineRoot
                            property: "contentScale"
                            to: 1.0
                            duration: 240
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.10
                        }
                    }
                }
            }
            ScriptAction {
                script: {
                    engineRoot.isFullyDisplayed = true;
                    engineRoot.physics.triggerShimmer();
                }
            }
        }
    }

    // 2. Dynamic Liquid Retract Animation (Weighted for bigger panels)
    ParallelAnimation {
        id: retractAnimation

        // 1. Content Smooth Dissolve
        SequentialAnimation {
            ParallelAnimation {
                NumberAnimation {
                    target: engineRoot
                    property: "contentOpacity"
                    to: 0.0
                    duration: 130
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: engineRoot
                    property: "contentScale"
                    to: 0.88
                    duration: 140
                    easing.type: Easing.InQuad
                }
            }
        }

        // 2. Horizontal & Vertical Compression into Circle
        SequentialAnimation {
            ParallelAnimation {
                NumberAnimation {
                    target: engineRoot
                    property: "curW"
                    to: engineRoot.circleSize
                    duration: 320
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curX"
                    to: engineRoot.hiddenOriginX
                    duration: 320
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curH"
                    to: engineRoot.circleSize
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curRadius"
                    to: 21
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }
        }

        // 3. Overlapping Upward Suction & Liquid Stretch into Bezel
        SequentialAnimation {
            PauseAnimation { duration: 80 }
            ParallelAnimation {
                // Suction into bezel
                NumberAnimation {
                    target: engineRoot
                    property: "curY"
                    to: -52
                    duration: 250
                    easing.type: Easing.InCubic
                }

                // Uniform 1:1 circular aperture shrink
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: engineRoot; property: "scaleX"; to: 1.05; duration: 40; easing.type: Easing.OutQuad }
                        NumberAnimation { target: engineRoot; property: "scaleY"; to: 1.05; duration: 40; easing.type: Easing.OutQuad }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: engineRoot; property: "scaleX"; to: 0.18; duration: 160; easing.type: Easing.InQuad }
                        NumberAnimation { target: engineRoot; property: "scaleY"; to: 0.18; duration: 160; easing.type: Easing.InQuad }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: engineRoot; property: "scaleX"; to: 1.0; duration: 25; easing.type: Easing.Linear }
                        NumberAnimation { target: engineRoot; property: "scaleY"; to: 1.0; duration: 25; easing.type: Easing.Linear }
                    }
                }

                // Fade out as it enters bezel
                SequentialAnimation {
                    PauseAnimation { duration: 80 }
                    NumberAnimation {
                        target: engineRoot
                        property: "curOpacity"
                        to: 0.0
                        duration: 140
                        easing.type: Easing.InQuad
                    }
                }
            }
            ScriptAction {
                script: engineRoot.physics.randomizePhysics()
            }
        }
    }

    Component.onCompleted: {
        if (isPinned) {
            applyPinnedState();
        }
    }
}
