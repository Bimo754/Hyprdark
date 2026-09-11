import QtQuick

QtObject {
    id: physicsRoot

    // Organic Physics Parameters
    property real dropPlungeY: 13.0
    property real morphOvershoot: 1.25
    property real teardropScaleY: 1.40
    property real teardropScaleX: 0.74
    property real landingSquashX: 1.18
    property real landingSquashY: 0.84
    property real dropletOriginRatio: 0.50
    property real shimmerPeak: 1.0
    property int morphStartDelay: 120
    property int retractAscentDelay: 20

    // Tactile Shimmer Property
    property real pulseShimmer: 0.0

    function randomizePhysics() {
        // 1. Plunge depth variation (resting is 7.0; varies between 10.5px shallow snap and 16.5px deep plunge)
        dropPlungeY = Math.round((10.5 + Math.random() * 6.0) * 10) / 10;

        // 2. Jelly spring overshoot (1.16 taut luxury glide to 1.40 bouncy jello)
        morphOvershoot = Math.round((1.16 + Math.random() * 0.24) * 100) / 100;

        // 3. Teardrop elongation & volume-preserving splash squash (x = 1/sqrt(y))
        teardropScaleY = Math.round((1.26 + Math.random() * 0.24) * 100) / 100;
        teardropScaleX = Math.round((1.0 / Math.sqrt(teardropScaleY)) * 100) / 100;

        landingSquashX = Math.round((1.10 + Math.random() * 0.18) * 100) / 100;
        landingSquashY = Math.round((1.0 / Math.sqrt(landingSquashX)) * 100) / 100;

        // 4. Subtle organic horizontal nucleation drift (0.40 to 0.60 across top margin)
        dropletOriginRatio = Math.round((0.40 + Math.random() * 0.20) * 100) / 100;

        // 5. Border shimmer highlight intensity (0.50 soft glow to 1.0 bright white hairline pulse)
        shimmerPeak = Math.round((0.50 + Math.random() * 0.50) * 100) / 100;

        // 6. Timing offsets
        morphStartDelay = Math.round(85 + Math.random() * 90);
        retractAscentDelay = Math.round(10 + Math.random() * 50);
    }

    function triggerShimmer() {
        shimmerAnimation.restart();
    }

    property SequentialAnimation shimmerAnimation: SequentialAnimation {
        NumberAnimation {
            target: physicsRoot
            property: "pulseShimmer"
            to: physicsRoot.shimmerPeak
            duration: 90
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: physicsRoot
            property: "pulseShimmer"
            to: 0.0
            duration: 320
            easing.type: Easing.OutQuad
        }
    }

    Component.onCompleted: {
        randomizePhysics();
    }
}
