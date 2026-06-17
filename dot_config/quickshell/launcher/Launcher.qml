import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../state"

PanelWindow {
    id: root

    visible: SessionState.launcherVisible || (content.opacity > 0)
    anchors { left: true; right: true; top: true; bottom: true }
    color: "transparent"
    
    // We want the launcher to overlap everything
    WlrLayershell.namespace: "launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: SessionState.launcherVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [root]
        active: SessionState.launcherVisible
    }

    AppLauncherService {
        id: appService
    }

    // Click-away area (Dim removed)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        
        MouseArea {
            anchors.fill: parent
            onClicked: SessionState.launcherVisible = false
        }
    }

    Item {
        id: content
        width: 720
        height: 580
        anchors.centerIn: parent
        opacity: 0
        scale: 0.95

        states: [
            State {
                name: "active"
                when: SessionState.launcherVisible
                PropertyChanges {
                    target: content
                    opacity: 1
                    scale: 1
                }
            }
        ]

        transitions: [
            Transition {
                from: ""
                to: "active"
                ParallelAnimation {
                    NumberAnimation { properties: "opacity"; duration: Theme.durationNormal; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurveIn }
                    NumberAnimation { properties: "scale"; duration: Theme.durationNormal; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurveIn }
                }
            },
            Transition {
                from: "active"
                to: ""
                ParallelAnimation {
                    NumberAnimation { properties: "opacity"; duration: Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurveOut }
                    NumberAnimation { properties: "scale"; duration: Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurveOut }
                }
            }
        ]

        Keys.onEscapePressed: SessionState.launcherVisible = false

        // Panel background removed so the orbital dial floats over the screen

        OrbitalDial {
            anchors.fill: parent
            service: appService
        }
    }
}
