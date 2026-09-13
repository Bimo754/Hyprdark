import QtQuick
import QtQuick.Shapes
import ".."

Shape {
    id: islandShape
    anchors.top: parent.top
    anchors.left: parent.left
    width: parent.width
    height: 220
    layer.enabled: true
    layer.samples: 4

    required property real w
    required property real hDraw
    required property color borderColor
    required property real targetXL
    required property real targetXR
    required property real vpnXL
    required property bool showVpnShape

    readonly property real hBar: 42
    readonly property real rCap: 21

    // Target drawer geometry
    readonly property real targetCurW: targetXR - targetXL
    readonly property real targetRBottom: Math.min(14.0, Math.min(targetCurW / 2.0, hDraw * 0.58))
    readonly property real targetRFillet: Math.min(8.0, hDraw * 0.38)
    readonly property bool hasTargetDrawer: !showVpnShape && hDraw > 1.0

    // VPN drawer geometry
    readonly property real vpnCurW: w - vpnXL
    readonly property real vpnRBottom: Math.min(16.0, Math.min(vpnCurW / 2.0, hDraw * 0.58))
    readonly property real vpnRFillet: Math.min(6.0, hDraw * 0.3)
    readonly property bool hasVpnDrawer: showVpnShape && hDraw > 1.0

    // 1. Target / Standard Center Morphology
    ShapePath {
        id: targetShapePath
        strokeColor: !islandShape.showVpnShape ? islandShape.borderColor : "transparent"
        strokeWidth: 1
        fillColor: !islandShape.showVpnShape ? StyleTokens.glassBackground : "transparent"
        joinStyle: ShapePath.MiterJoin
        capStyle: ShapePath.FlatCap

        startX: islandShape.rCap
        startY: 0

        PathLine { x: islandShape.w - islandShape.rCap; y: 0 }
        PathArc {
            x: islandShape.w - islandShape.rCap
            y: islandShape.hBar
            radiusX: islandShape.rCap
            radiusY: islandShape.rCap
            direction: PathArc.Clockwise
        }
        PathLine {
            x: islandShape.hasTargetDrawer ? (islandShape.targetXR + islandShape.targetRFillet) : islandShape.rCap
            y: islandShape.hBar
        }
        PathArc {
            x: islandShape.hasTargetDrawer ? islandShape.targetXR : islandShape.rCap
            y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.targetRFillet) : islandShape.hBar
            radiusX: islandShape.hasTargetDrawer ? islandShape.targetRFillet : 0
            radiusY: islandShape.hasTargetDrawer ? islandShape.targetRFillet : 0
            direction: PathArc.Counterclockwise
        }
        PathLine {
            x: islandShape.hasTargetDrawer ? islandShape.targetXR : islandShape.rCap
            y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.hDraw - islandShape.targetRBottom) : islandShape.hBar
        }
        PathArc {
            x: islandShape.hasTargetDrawer ? (islandShape.targetXR - islandShape.targetRBottom) : islandShape.rCap
            y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.hDraw) : islandShape.hBar
            radiusX: islandShape.hasTargetDrawer ? islandShape.targetRBottom : 0
            radiusY: islandShape.hasTargetDrawer ? islandShape.targetRBottom : 0
            direction: PathArc.Clockwise
        }
        PathLine {
            x: islandShape.hasTargetDrawer ? (islandShape.targetXL + islandShape.targetRBottom) : islandShape.rCap
            y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.hDraw) : islandShape.hBar
        }
        PathArc {
            x: islandShape.hasTargetDrawer ? islandShape.targetXL : islandShape.rCap
            y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.hDraw - islandShape.targetRBottom) : islandShape.hBar
            radiusX: islandShape.hasTargetDrawer ? islandShape.targetRBottom : 0
            radiusY: islandShape.hasTargetDrawer ? islandShape.targetRBottom : 0
            direction: PathArc.Clockwise
        }
        PathLine {
            x: islandShape.hasTargetDrawer ? islandShape.targetXL : islandShape.rCap
            y: islandShape.hasTargetDrawer ? (islandShape.hBar + islandShape.targetRFillet) : islandShape.hBar
        }
        PathArc {
            x: islandShape.hasTargetDrawer ? (islandShape.targetXL - islandShape.targetRFillet) : islandShape.rCap
            y: islandShape.hBar
            radiusX: islandShape.hasTargetDrawer ? islandShape.targetRFillet : 0
            radiusY: islandShape.hasTargetDrawer ? islandShape.targetRFillet : 0
            direction: PathArc.Counterclockwise
        }
        PathLine { x: islandShape.rCap; y: islandShape.hBar }
        PathArc {
            x: islandShape.rCap
            y: 0
            radiusX: islandShape.rCap
            radiusY: islandShape.rCap
            direction: PathArc.Clockwise
        }
    }

    // 2. Right-Edge Morph Morphology (VPN Drawer)
    ShapePath {
        id: vpnShapePath
        strokeColor: islandShape.showVpnShape ? islandShape.borderColor : "transparent"
        strokeWidth: 1
        fillColor: islandShape.showVpnShape ? StyleTokens.glassBackground : "transparent"
        joinStyle: ShapePath.MiterJoin
        capStyle: ShapePath.FlatCap

        startX: islandShape.rCap
        startY: 0

        PathLine { x: islandShape.w - islandShape.rCap; y: 0 }
        PathArc {
            x: islandShape.w
            y: islandShape.rCap
            radiusX: islandShape.rCap
            radiusY: islandShape.rCap
            direction: PathArc.Clockwise
        }
        PathLine {
            x: islandShape.w
            y: islandShape.rCap + islandShape.hDraw
        }
        PathArc {
            x: islandShape.w - islandShape.rCap
            y: islandShape.hBar + islandShape.hDraw
            radiusX: islandShape.rCap
            radiusY: islandShape.rCap
            direction: PathArc.Clockwise
        }
        PathLine {
            x: islandShape.hasVpnDrawer ? (islandShape.vpnXL + islandShape.vpnRBottom) : islandShape.rCap
            y: islandShape.hasVpnDrawer ? (islandShape.hBar + islandShape.hDraw) : islandShape.hBar
        }
        PathArc {
            x: islandShape.hasVpnDrawer ? islandShape.vpnXL : islandShape.rCap
            y: islandShape.hasVpnDrawer ? (islandShape.hBar + islandShape.hDraw - islandShape.vpnRBottom) : islandShape.hBar
            radiusX: islandShape.hasVpnDrawer ? islandShape.vpnRBottom : 0
            radiusY: islandShape.hasVpnDrawer ? islandShape.vpnRBottom : 0
            direction: PathArc.Clockwise
        }
        PathLine {
            x: islandShape.hasVpnDrawer ? islandShape.vpnXL : islandShape.rCap
            y: islandShape.hasVpnDrawer ? (islandShape.hBar + islandShape.vpnRFillet) : islandShape.hBar
        }
        PathArc {
            x: islandShape.hasVpnDrawer ? (islandShape.vpnXL - islandShape.vpnRFillet) : islandShape.rCap
            y: islandShape.hBar
            radiusX: islandShape.hasVpnDrawer ? islandShape.vpnRFillet : 0
            radiusY: islandShape.hasVpnDrawer ? islandShape.vpnRFillet : 0
            direction: PathArc.Counterclockwise
        }
        PathLine { x: islandShape.rCap; y: islandShape.hBar }
        PathArc {
            x: islandShape.rCap
            y: 0
            radiusX: islandShape.rCap
            radiusY: islandShape.rCap
            direction: PathArc.Clockwise
        }
    }
}
