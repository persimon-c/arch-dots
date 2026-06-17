// components/StorageBar.qml
// Horizontal animated progress bar for storage / memory usage.
//
// Usage — disk:
//   StorageBar {
//       value:      System.diskPercent   // 0–100
//       usedLabel:  System.diskUsedStr   // "42.3 GiB"
//       totalLabel: System.diskTotalStr  // "512.0 GiB"
//   }
//
// Usage — RAM with a different color:
//   StorageBar {
//       value:      System.ramPercent
//       usedLabel:  System.ramUsedStr
//       totalLabel: System.ramTotalStr
//       color:      Colors.secondary
//   }
//
// Design:
//   - Capsule track, animated fill width (OutCubic easing)
//   - Subtle gloss stripe on the filled region
//   - Threshold-aware color: shifts to warning/critical at high fill
//   - Optional used / total text labels below the bar (anchored left/right)
//   - No service imports — pure display primitive

import QtQuick

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────

    // Fill level, 0–100
    property real value: 0

    // Optional text labels below the bar. Leave empty to hide.
    property string usedLabel:  ""
    property string totalLabel: ""

    // Bar geometry
    property real barHeight: 6

    // Primary fill color. Defaults to Lavender; consumers pass Colors.accent etc.
    property color color: "#b4befe"

    // Track background
    property color trackColor: Qt.rgba(1, 1, 1, 0.08)

    // Threshold coloring (overrides `color` when useThresholdColors is true)
    property bool  useThresholdColors: true
    property color warningColor:  "#fab387"  // Peach  — ≥ 75 %
    property color criticalColor: "#f38ba8"  // Red    — ≥ 90 %

    // Label appearance
    property color labelColor:    Qt.rgba(1, 1, 1, 0.55)
    property real  labelFontSize: 10

    // Fill animation duration (ms)
    property int animDuration: 400

    // ── Internal ──────────────────────────────────────────────────────────

    readonly property real  _pct:   Math.max(0, Math.min(100, value))
    readonly property bool  _hasLabels: usedLabel !== "" || totalLabel !== ""

    readonly property color _fillColor: {
        if (!useThresholdColors) return root.color
        if (_pct >= 90)          return criticalColor
        if (_pct >= 75)          return warningColor
        return root.color
    }

    // ── Implicit size — label row adds height when visible ────────────────

    implicitWidth:  200
    implicitHeight: barHeight + (_hasLabels ? labelFontSize + 6 : 0)

    // ── Track ─────────────────────────────────────────────────────────────

    Rectangle {
        id: track
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: root.barHeight
        radius: height / 2
        color:  root.trackColor

        // ── Fill ──────────────────────────────────────────────────────────

        Rectangle {
            id: fill
            height: parent.height
            radius: parent.radius

            // Never wider than track; minimum is a circle when value > 0
            width: root._pct > 0
                ? Math.max(height, track.width * (root._pct / 100))
                : 0

            Behavior on width {
                NumberAnimation { duration: root.animDuration; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            }

            color: root._fillColor
            Behavior on color {
                ColorAnimation { duration: 250 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            }

            // Gloss — lighter strip across top half
            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: Math.ceil(parent.height / 2)
                radius: parent.radius
                color:  Qt.rgba(1, 1, 1, 0.13)
            }
        }
    }

    // ── Labels ────────────────────────────────────────────────────────────

    Text {
        visible: root._hasLabels && root.usedLabel !== ""
        anchors {
            top:      track.bottom
            topMargin: 4
            left:     parent.left
        }
        text:           root.usedLabel
        color:          root.labelColor
        font.pixelSize: root.labelFontSize
    }

    Text {
        visible: root._hasLabels && root.totalLabel !== ""
        anchors {
            top:      track.bottom
            topMargin: 4
            right:    parent.right
        }
        text:           root.totalLabel
        color:          root.labelColor
        font.pixelSize: root.labelFontSize
    }
}
