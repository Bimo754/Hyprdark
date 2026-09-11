import QtQuick

QtObject {
    id: physicsRoot

    // Organic Physics Parameters
    property real dropPlungeY: 12.0
    property real morphOvershoot: 1.16
    property real teardropScaleY: 1.32
    property real teardropScaleX: 0.78
    property real landingSquashX: 1.15
    property real landingSquashY: 0.86
    property real dropletOriginRatio: 0.50
    property real shimmerPeak: 1.0
    property int morphStartDelay: 220
    property int retractAscentDelay: 20

    // Tactile Shimmer Property
    property real pulseShimmer: 0.0

    function randomizePhysics() {
        // 1. Plunge depth variation (resting is 7.0; varies between 10.0px shallow snap and 13.5px controlled plunge)
        dropPlungeY = Math.round((10.0 + Math.random() * 3.5) * 10) / 10;

        // 2. Controlled spring overshoot (1.12 subtle taut snap to 1.20 responsive spring)
        morphOvershoot = Math.round((1.12 + Math.random() * 0.08) * 100) / 100;

        // 3. Teardrop elongation & volume-preserving splash squash (x = 1/sqrt(y))
        teardropScaleY = Math.round((1.24 + Math.random() * 0.12) * 100) / 100;
        teardropScaleX = Math.round((1.0 / Math.sqrt(teardropScaleY)) * 100) / 100;

        landingSquashX = Math.round((1.10 + Math.random() * 0.10) * 100) / 100;
        landingSquashY = Math.round((1.0 / Math.sqrt(landingSquashX)) * 100) / 100;

        // 4. Subtle organic horizontal nucleation drift (0.42 to 0.58 across top margin)
        dropletOriginRatio = Math.round((0.42 + Math.random() * 0.16) * 100) / 100;

        // 5. Border shimmer highlight intensity (0.50 soft glow to 1.0 bright white hairline pulse)
        shimmerPeak = Math.round((0.50 + Math.random() * 0.50) * 100) / 100;

        // 6. Timing offsets (Touchdown occurs at ~210ms; upward suction overlaps concurrently with ball collapse at 15-35ms)
        morphStartDelay = Math.round(200 + Math.random() * 35);
        retractAscentDelay = Math.round(15 + Math.random() * 20);
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
