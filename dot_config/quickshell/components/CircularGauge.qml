// components/CircularGauge.qml
// Arc gauge for CPU / RAM / GPU percentage display in SystemStatsCard.
//
// Usage:
//   CircularGauge {
//     value:   System.cpuUsage   // 0.0–1.0
//     label:   "CPU"
//     unit:    "%"
//     arcColor: Colors.primary
//   }
//
// Implicit size is square: (size × size).
// Set `size` to control the gauge diameter — parent layouts should NOT
// set width/height directly.

import QtQuick
import "../theme"

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────

    property real   value:    0.0     // 0.0–1.0
    property string label:    ""
    property string unit:     "%"

    property int    size:         72
    property real   arcWidth:     6
    property real   startAngle:  -220  // degrees, 0 = 3 o'clock
    property real   spanAngle:    260  // degrees of travel

    property color  arcColor:     Colors.primary
    property color  trackColor:   Colors.surfaceContainerHighest
    property color  labelColor:   Colors.onSurface
    property color  valueColor:   Colors.onSurface

    property int    labelFontSize: Theme.fontSizeXs
    property int    valueFontSize: Theme.fontSizeSm

    // Whether to animate value changes
    property bool   animated: true

    // ── Implicit size ─────────────────────────────────────────────────────

    implicitWidth:  root.size
    implicitHeight: root.size

    // ── Animated value ────────────────────────────────────────────────────

    property real _displayValue: root.value

    Behavior on _displayValue {
        enabled: root.animated
        NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
    }

    onValueChanged: _displayValue = root.value

    // ── Canvas arc ────────────────────────────────────────────────────────

    Canvas {
        id: canvas
        anchors.fill: parent

        // Redraw when display value changes
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cx = width / 2
            var cy = height / 2
            var r  = Math.min(width, height) / 2 - root.arcWidth / 2 - 2

            // Convert our angle convention (0 = top, clockwise) to canvas (0 = right, clockwise)
            // Our startAngle=-220 with spanAngle=260 gives a bottom-open arc like a speedometer.
            var toRad    = Math.PI / 180
            var startRad = (root.startAngle - 90) * toRad
            var endRad   = startRad + root.spanAngle * toRad

            // Track arc (background)
            ctx.beginPath()
            ctx.arc(cx, cy, r, startRad, endRad, false)
            ctx.strokeStyle = root.trackColor
            ctx.lineWidth   = root.arcWidth
            ctx.lineCap     = "round"
            ctx.stroke()

            // Fill arc (value)
            var fillEnd = startRad + root.spanAngle * root._displayValue * toRad
            if (root._displayValue > 0.001) {
                ctx.beginPath()
                ctx.arc(cx, cy, r, startRad, fillEnd, false)
                ctx.strokeStyle = root.arcColor
                ctx.lineWidth   = root.arcWidth
                ctx.lineCap     = "round"
                ctx.stroke()
            }
        }

        Connections {
            target: root
            function on_DisplayValueChanged() { canvas.requestPaint() }
            function onArcColorChanged()      { canvas.requestPaint() }
            function onTrackColorChanged()    { canvas.requestPaint() }
            function onSizeChanged()          { canvas.requestPaint() }
        }
    }

    // ── Center text ───────────────────────────────────────────────────────

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root._displayValue * 100) + root.unit
            font.pixelSize: root.valueFontSize
            font.weight:    Font.Medium
            color:          root.valueColor
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:            root.label
            font.pixelSize:  root.labelFontSize
            color:           Qt.rgba(root.labelColor.r, root.labelColor.g, root.labelColor.b, 0.7)
        }
    }
}
