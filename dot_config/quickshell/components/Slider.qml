// components/Slider.qml
// Styled horizontal slider for volume, brightness, and settings panels.
//
// Usage:
//   Slider {
//     from:  0.0
//     to:    1.0
//     value: Audio.volume
//     onMoved: Audio.setVolume(value)
//   }
//
// `onMoved` fires only on user interaction, not programmatic changes.
// `value` can be set externally to update the visual without triggering onMoved.
//
// Implicit size: implicitWidth must be set by parent (or the container layout).
// implicitHeight is fixed at the track+thumb area (~20px).

import QtQuick
import "../theme"

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────

    property real from:  0.0
    property real to:    1.0
    property real value: 0.0
    property real stepSize: 0.0        // 0 = continuous
    property bool enabled: true

    property color trackColor:      Colors.surfaceContainerHighest
    property color fillColor:       Colors.primary
    property color thumbColor:      Colors.primary
    property color thumbHaloColor:  Colors.primary

    // Height of the filled track (not the full hit area)
    property real trackHeight:  4
    property real thumbRadius:  8     // half of thumb diameter

    signal moved(real value)

    // ── Implicit size ─────────────────────────────────────────────────────

    // Width must be provided by the parent/layout.
    // Height is the hit area — thumb needs room above/below the track.
    implicitHeight: thumbRadius * 2 + 4

    // ── Internal state ────────────────────────────────────────────────────

    // Clamp value to [from, to]
    readonly property real _clamped: Math.max(root.from, Math.min(root.to, root.value))
    readonly property real _range:   root.to - root.from
    readonly property real _ratio:   _range > 0 ? (_clamped - root.from) / _range : 0

    // ── Track background ──────────────────────────────────────────────────

    Rectangle {
        id: trackBg
        anchors.verticalCenter: parent.verticalCenter
        anchors.left:  parent.left
        anchors.right: parent.right
        height: root.trackHeight
        radius: height / 2
        color:  root.trackColor
        opacity: root.enabled ? 1.0 : 0.38
    }

    // ── Track fill ────────────────────────────────────────────────────────

    Rectangle {
        id: trackFill
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: root._ratio * (parent.width - root.thumbRadius * 2) + root.thumbRadius
        height: root.trackHeight
        radius: height / 2
        color:  root.fillColor
        opacity: root.enabled ? 1.0 : 0.38

        Behavior on width {
            // Only animate when not dragging — avoids lag during drag
            enabled: !dragArea.drag.active
            NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
        }
    }

    // ── Thumb ─────────────────────────────────────────────────────────────

    Rectangle {
        id: thumb
        width:  root.thumbRadius * 2
        height: width
        radius: width / 2

        anchors.verticalCenter: parent.verticalCenter
        x: root._ratio * (parent.width - width)

        color:   root.thumbColor
        opacity: root.enabled ? 1.0 : 0.38

        // Scale up on press
        scale: dragArea.drag.active || dragArea.containsMouse ? 1.18 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }

        // Halo
        Rectangle {
            anchors.centerIn: parent
            width:  thumb.width + 16
            height: width
            radius: width / 2
            color:  root.thumbHaloColor
            opacity: dragArea.drag.active ? 0.22
                   : dragArea.containsMouse ? 0.12
                   : 0
            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }
    }

    // ── Input ─────────────────────────────────────────────────────────────

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        enabled:      root.enabled
        cursorShape:  root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        drag.target: null   // We handle position manually

        function _valueFromX(mx) {
            var usable = root.width - root.thumbRadius * 2
            if (usable <= 0) return root.from
            var ratio  = Math.max(0, Math.min(1, (mx - root.thumbRadius) / usable))
            var raw    = root.from + ratio * (root.to - root.from)
            if (root.stepSize > 0) {
                raw = Math.round(raw / root.stepSize) * root.stepSize
            }
            return Math.max(root.from, Math.min(root.to, raw))
        }

        onPressed: function(mouse) {
            if (!root.enabled) return
            var v = _valueFromX(mouse.x)
            root.value = v
            root.moved(v)
        }

        onPositionChanged: function(mouse) {
            if (!pressed) return
            var v = _valueFromX(mouse.x)
            root.value = v
            root.moved(v)
        }

        // Mouse wheel support
        onWheel: function(wheel) {
            if (!root.enabled) return
            var step = root.stepSize > 0 ? root.stepSize : (root.to - root.from) * 0.05
            var v = root.value + (wheel.angleDelta.y > 0 ? step : -step)
            v = Math.max(root.from, Math.min(root.to, v))
            root.value = v
            root.moved(v)
        }
    }
}
