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
            duration: 320
            easing.type: Easing.OutBack
            easing.overshoot: 1.15
        }
    }

    Behavior on curH {
        enabled: engineRoot.canMorphDimensions
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutBack
            easing.overshoot: 1.08
        }
    }

    Behavior on curRadius {
        enabled: engineRoot.canMorphDimensions
        NumberAnimation {
            duration: 200
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
                    duration: 340
                    easing.type: Easing.OutBack
                    easing.overshoot: engineRoot.physics.morphOvershoot
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curX"
                    to: 0
                    duration: 340
                    easing.type: Easing.OutBack
                    easing.overshoot: engineRoot.physics.morphOvershoot
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curH"
                    to: engineRoot.targetHeight
                    duration: 280
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.08
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curRadius"
                    to: engineRoot.targetRadius
                    duration: 200
                    easing.type: Easing.OutQuad
                }
                // Cascade Content Materialization as capsule blooms
                SequentialAnimation {
                    PauseAnimation { duration: 60 }
                    ParallelAnimation {
                        NumberAnimation {
                            target: engineRoot
                            property: "contentOpacity"
                            to: 1.0
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: engineRoot
                            property: "contentScale"
                            to: 1.0
                            duration: 220
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

    // 2. Dynamic Liquid Retract Animation
    ParallelAnimation {
        id: retractAnimation

        // 1. Immediate Content Quick Dissolve
        SequentialAnimation {
            ParallelAnimation {
                NumberAnimation {
                    target: engineRoot
                    property: "contentOpacity"
                    to: 0.0
                    duration: 60
                    easing.type: Easing.InQuad
                }
                NumberAnimation {
                    target: engineRoot
                    property: "contentScale"
                    to: 0.85
                    duration: 70
                    easing.type: Easing.InQuad
                }
            }
        }

        // 2. Horizontal pinch back to circle
        SequentialAnimation {
            ParallelAnimation {
                NumberAnimation {
                    target: engineRoot
                    property: "curW"
                    to: engineRoot.circleSize
                    duration: 220
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curX"
                    to: engineRoot.hiddenOriginX
                    duration: 220
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curH"
                    to: engineRoot.circleSize
                    duration: 180
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: engineRoot
                    property: "curRadius"
                    to: 21
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }

        // 3. Overlapping Upward Suction & Uniform Aperture Shrink
        SequentialAnimation {
            PauseAnimation { duration: engineRoot.physics.retractAscentDelay }
            ParallelAnimation {
                // Suction into bezel
                NumberAnimation {
                    target: engineRoot
                    property: "curY"
                    to: -52
                    duration: 220
                    easing.type: Easing.InCubic
                }

                // Uniform 1:1 circular aperture shrink
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: engineRoot; property: "scaleX"; to: 1.04; duration: 35; easing.type: Easing.OutQuad }
                        NumberAnimation { target: engineRoot; property: "scaleY"; to: 1.04; duration: 35; easing.type: Easing.OutQuad }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: engineRoot; property: "scaleX"; to: 0.18; duration: 150; easing.type: Easing.InQuad }
                        NumberAnimation { target: engineRoot; property: "scaleY"; to: 0.18; duration: 150; easing.type: Easing.InQuad }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: engineRoot; property: "scaleX"; to: 1.0; duration: 25; easing.type: Easing.Linear }
                        NumberAnimation { target: engineRoot; property: "scaleY"; to: 1.0; duration: 25; easing.type: Easing.Linear }
                    }
                }

                // Fade out as it enters bezel
                SequentialAnimation {
                    PauseAnimation { duration: 60 }
                    NumberAnimation {
                        target: engineRoot
                        property: "curOpacity"
                        to: 0.0
                        duration: 120
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
