// osd/Osd.qml
// Centered on-screen display overlay.
//
// Listens to OsdService.osdTriggered and displays a centered, rounded,
// glassmorphic card wrapping the appropriate sub-OSD component.
//
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../theme"

PanelWindow {
    id: root

    // Centered window (no anchors -> compositor centered)
    implicitWidth: 220
    implicitHeight: 220
    color: "transparent"

    // Wayland layer shell properties
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    // Window visibility is bound to the card's opacity transition
    visible: card.opacity > 0.0

    Timer {
        id: dismissTimer
        interval: 1800
        repeat: false
        onTriggered: {
            card.opacity = 0.0
        }
    }

    Connections {
        target: OsdService

        function onOsdTriggered(osd) {
            card.opacity = 1.0
            dismissTimer.restart()
        }
    }

    // Outer card body
    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.radiusLg
        color: Qt.rgba(
            Colors.surfaceContainer.r,
            Colors.surfaceContainer.g,
            Colors.surfaceContainer.b,
            Theme.opacityPanel
        )
        border.color: Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.15)
        border.width: 1

        opacity: 0.0
        Behavior on opacity {
            NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
        }

        // Inner layout loading visual delegates
        Loader {
            id: loader
            anchors.fill: parent
            anchors.margins: Theme.spacingLg

            source: {
                if (!OsdService.activeOsd || OsdService.activeOsd.type === "") return ""
                const type = OsdService.activeOsd.type
                if (type === "capslock") return "CapsLockOsd.qml"
                return type.charAt(0).toUpperCase() + type.slice(1) + "Osd.qml"
            }
        }
    }
}

