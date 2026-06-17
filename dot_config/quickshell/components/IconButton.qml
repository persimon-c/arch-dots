// components/IconButton.qml
// Styled icon button with hover highlight and press ripple.
//
// Usage:
//   IconButton {
//     icon:     "audio-volume-high"   // XDG icon name or path
//     iconSize: 18
//     onClicked: { ... }
//   }
//
// Size: the button's implicit size is (iconSize + padding*2) square.
// Never set width/height on this item — let the container manage it.
//
// States:
//   normal    — transparent bg
//   hovered   — surface highlight at Theme.stateHoverOpacity
//   pressed   — deeper highlight + scale down 0.92
//   disabled  — icon at 38% opacity, no interaction

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../theme"

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────

    property string icon:     ""
    property int    iconSize: 18
    property real   padding:  Theme.spacingSm
    property bool   enabled:  true
    property bool   checkable: false
    property bool   checked:  false

    // Tint the icon. Defaults to onSurface. Set to Colors.primary for accent buttons.
    property color  iconColor: Colors.onSurfaceColor

    // Background shape: "circle" or "rounded"
    property string shape: "circle"

    signal clicked()
    signal rightClicked()

    // ── Implicit size — drives parent layout ──────────────────────────────
    // Flows child → parent as per Item Size and Position guidelines.

    implicitWidth:  iconSize + padding * 2
    implicitHeight: iconSize + padding * 2

    // ── Background ────────────────────────────────────────────────────────

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.shape === "circle"
            ? width / 2
            : Theme.radiusSm
        color: Colors.onSurfaceColor

        opacity: {
            if (!root.enabled)          return 0
            if (mouseArea.pressed)      return Theme.statePressedOpacity
            if (mouseArea.containsMouse) return Theme.stateHoverOpacity
            if (root.checked)           return Theme.stateHoverOpacity * 1.5
            return 0
        }

        Behavior on opacity {
            NumberAnimation { duration: 100; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
        }
    }

    // ── Ripple ────────────────────────────────────────────────────────────

    Rectangle {
        id: ripple
        anchors.centerIn: parent
        width:  0
        height: width
        radius: width / 2
        color:  Colors.primary
        opacity: 0
        clip:   false   // ripple expands beyond bounds intentionally

        NumberAnimation on width {
            id: rippleExpand
            to:       root.implicitWidth * 2.2
            duration: 350
            easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve
        }
        NumberAnimation on opacity {
            id: rippleFade
            to:       0
            duration: 350
            easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve
        }

        function trigger() {
            ripple.width   = 0
            ripple.opacity = 0.28
            rippleExpand.restart()
            rippleFade.restart()
        }
    }

    // ── Icon ──────────────────────────────────────────────────────────────

    // Using Image instead of IconImage since we don't have IconImage docs yet.
    // Swap to IconImage when available — same source property applies.
    Image {
        id: iconImg
        anchors.centerIn: parent
        width:  root.iconSize
        height: root.iconSize
        source: root.icon.startsWith("/") || root.icon.startsWith("qrc:")
            ? root.icon
            : "image://icon/" + root.icon
        sourceSize.width:  root.iconSize * 2   // HiDPI
        sourceSize.height: root.iconSize * 2
        fillMode: Image.PreserveAspectFit
        smooth:   true

        opacity: root.enabled ? 1.0 : 0.38

        // Colour tint via ColorOverlay equivalent — multiply layer
        layer.enabled: true
        layer.effect: ShaderEffect {
            property color tintColor: root.iconColor
            fragmentShader: "
                uniform lowp sampler2D source;
                uniform lowp vec4 tintColor;
                varying highp vec2 qt_TexCoord0;
                void main() {
                    lowp vec4 tex = texture2D(source, qt_TexCoord0);
                    gl_FragColor = vec4(tintColor.rgb, 1.0) * tex.a * tintColor.a;
                }
            "
        }

        Behavior on opacity {
            NumberAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
        }
    }

    // ── Scale on press ────────────────────────────────────────────────────

    scale: mouseArea.pressed ? 0.88 : 1.0
    Behavior on scale {
        NumberAnimation { duration: 100; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
    }

    // ── Input ─────────────────────────────────────────────────────────────

    MouseArea {
        id: mouseArea
        anchors.fill:  parent
        hoverEnabled:  root.enabled
        enabled:       root.enabled
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked()
                return
            }
            ripple.trigger()
            if (root.checkable) root.checked = !root.checked
            root.clicked()
        }

        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
