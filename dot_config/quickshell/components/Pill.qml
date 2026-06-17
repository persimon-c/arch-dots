import QtQuick
import Quickshell.Widgets
import "../theme"

// Base glassmorphism capsule.
//
// Sizing: driven entirely by content via WrapperRectangle margins.
// Hover:  set hovered: someMouseArea.containsMouse from the subtype.
// Color:  override bgColor for per-pill tinting (e.g. PanelColors.pillBattery).

WrapperRectangle {
    id: root

    function _safeColor(value, fallback) {
        return (value && value.length > 0) ? value : fallback
    }

    // ── Padding ───────────────────────────────────────────────────────────
    property real horizontalPadding: 6
    property real verticalPadding:   2

    leftMargin:   horizontalPadding
    rightMargin:  horizontalPadding
    topMargin:    verticalPadding
    bottomMargin: verticalPadding

    // ── Appearance ────────────────────────────────────────────────────────
    property string bgColor:   PanelColors.panelBackground
    property real   bgOpacity: Theme.opacityBar

    property bool hovered: false

    radius: 5

    color: Qt.rgba(
        Qt.color(root._safeColor(bgColor, "#181825")).r,
        Qt.color(root._safeColor(bgColor, "#181825")).g,
        Qt.color(root._safeColor(bgColor, "#181825")).b,
        hovered ? Math.min(1.0, bgOpacity + 0.08) : bgOpacity
    )

    Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

    border.color: Qt.rgba(
        Qt.color(root._safeColor(PanelColors.border, "#6c7086")).r,
        Qt.color(root._safeColor(PanelColors.border, "#6c7086")).g,
        Qt.color(root._safeColor(PanelColors.border, "#6c7086")).b,
        0.18
    )
    border.width: 1
}
