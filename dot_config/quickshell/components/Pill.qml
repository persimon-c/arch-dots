// components/Pill.qml
// Base glassmorphism capsule for all bar pills and containers.
//
// Usage:
//   Pill {
//     // Place your content inline — it becomes the single visual child.
//     // Set implicitWidth/implicitHeight on your content, not x/y/width/height.
//     RowLayout { ... }
//   }
//
// The pill sizes itself to its child via WrapperRectangle (MarginWrapperManager).
// Implicit size flows child → Pill. Actual size flows parent → Pill → child.
//
// Properties to customise per-pill:
//   horizontalPadding / verticalPadding  — override default padding
//   bgColor    — background fill (defaults to Theme surface with opacity)
//   bgOpacity  — background opacity (0.0–1.0)
//   blurRadius — backdrop blur radius
//   radius     — corner radius (defaults to Theme.radiusFull for capsule)

import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import "../theme"

WrapperRectangle {
    id: root

    // ── Public API ────────────────────────────────────────────────────────

    property real horizontalPadding: Theme.spacingMd
    property real verticalPadding:   Theme.spacingXs

    property color bgColor:   Colors.surfaceContainer
    property real  bgOpacity: 0.75
    property real  blurRadius: Theme.blurRadius

    // WrapperRectangle's margin drives the child padding.
    // Use asymmetric margins for different h/v padding.
    leftMargin:   horizontalPadding
    rightMargin:  horizontalPadding
    topMargin:    verticalPadding
    bottomMargin: verticalPadding

    // Capsule radius — override to Theme.radiusMd for non-pill rectangles
    radius: Theme.radiusFull

    // ── Visual styling ────────────────────────────────────────────────────

    color: Qt.rgba(
        root.bgColor.r,
        root.bgColor.g,
        root.bgColor.b,
        root.bgOpacity
    )

    border.color: Qt.rgba(
        Colors.outline.r,
        Colors.outline.g,
        Colors.outline.b,
        0.15
    )
    border.width: 1

    // Backdrop blur via layer effect
    layer.enabled: root.blurRadius > 0
    layer.effect: MultiEffect {
        source: root
        blurEnabled:  true
        blur:         root.blurRadius / 64.0   // MultiEffect blur is 0.0–1.0 normalised
        blurMax:      64
        blurMultiplier: 1.0
    }

    // ── Hover state ───────────────────────────────────────────────────────

    property bool hovered: false

    // Subtle brightness lift on hover.
    // Consumers can connect a MouseArea's entered/exited to this.
    property real _hoverBrightness: hovered ? 1.06 : 1.0

    Behavior on _hoverBrightness {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }

    // Apply brightness via saturation overlay trick — just lighten bg opacity slightly
    // Real brightness shift needs MultiEffect; keep it simple with opacity delta.
    readonly property real _effectiveOpacity: hovered
        ? Math.min(1.0, bgOpacity + 0.08)
        : bgOpacity

    color: Qt.rgba(
        root.bgColor.r,
        root.bgColor.g,
        root.bgColor.b,
        root._effectiveOpacity
    )
}
