// components/Toggle.qml
// Styled Material-style toggle switch.
//
// Usage:
//   Toggle {
//     checked: someService.enabled
//     onToggled: someService.enabled = checked
//   }
//
// Implicit size is fixed (width: 44, height: 24 by default).
// Never set width/height externally — parent layouts should use implicit size.

import QtQuick
import "../theme"

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────

    property bool   checked:  false
    property bool   enabled:  true
    property color  activeColor:   Colors.primary
    property color  inactiveColor: Colors.surfaceContainerHighest
    property color  thumbColor:    checked ? Colors.onPrimary : Colors.outline

    signal toggled()

    // ── Implicit size ─────────────────────────────────────────────────────

    implicitWidth:  44
    implicitHeight: 24

    // ── Track ─────────────────────────────────────────────────────────────

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2

        color: root.checked ? root.activeColor : root.inactiveColor

        opacity: root.enabled ? 1.0 : 0.38

        Behavior on color {
            ColorAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        border.color: root.checked
            ? "transparent"
            : Colors.outline
        border.width: root.checked ? 0 : 1.5

        Behavior on border.color {
            ColorAnimation { duration: 180 }
        }
    }

    // ── Thumb ─────────────────────────────────────────────────────────────

    Rectangle {
        id: thumb

        // Size: smaller when unchecked, larger when checked (Material 3 spec)
        readonly property real _size: root.checked ? 20 : 16

        width:  _size
        height: _size
        radius: width / 2

        // Position: anchored vertically centered, x slides between ends
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked
            ? parent.width - width - 2
            : 2

        color: root.thumbColor

        // Drop shadow for depth
        layer.enabled: true
        layer.effect: ShaderEffect {
            // Minimal shadow — avoids heavy effect import
        }

        opacity: root.enabled ? 1.0 : 0.38

        Behavior on x {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }
        Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }
        Behavior on color {
            ColorAnimation { duration: 180 }
        }
    }

    // ── Hover highlight ───────────────────────────────────────────────────

    Rectangle {
        anchors.centerIn: thumb
        width:  thumb.width + 16
        height: width
        radius: width / 2
        color:  root.checked ? root.activeColor : Colors.onSurface
        opacity: {
            if (!root.enabled)            return 0
            if (mouseArea.pressed)        return 0.18
            if (mouseArea.containsMouse)  return 0.08
            return 0
        }
        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    // ── Input ─────────────────────────────────────────────────────────────

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        enabled:      root.enabled
        cursorShape:  root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            root.checked = !root.checked
            root.toggled()
        }
    }
}
