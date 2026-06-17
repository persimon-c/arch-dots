import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"
import "../state"
import "../services"
import "../components"

PanelWindow {
    id: root

    // ── IPC trigger ───────────────────────────────────────────────────────
    // Hyprland keybind calls:
    //   quickshell ipc call right-sidebar toggle
    IpcHandler {
        target: "right-sidebar"

        function toggle(): void {
            if (SessionState.rightSidebarOpen) {
                SessionState.rightSidebarOpen = false
            } else {
                SessionState.closeAllPopups()
                SessionState.rightSidebarOpen = true
            }
        }
    }

    // Cover full screen for click-away behavior
    anchors {
        left:   true
        right:  true
        top:    true
        bottom: true
    }

    color: "transparent"

    // Set overlay layer so it sits above normal windows
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: SessionState.rightSidebarOpen
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None
    exclusiveZone: 0

    // Toggle visibility with smooth sliding/opacity transitions
    visible: SessionState.rightSidebarOpen || (cardsContainer.opacity > 0.01)

    // Full-screen click-away area to close the sidebar when clicking outside
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        focus: SessionState.rightSidebarOpen
        Keys.onEscapePressed: SessionState.rightSidebarOpen = false

        MouseArea {
            anchors.fill: parent
            onClicked: SessionState.rightSidebarOpen = false
        }
    }

    // ── Sidebar Container ─────────────────────────────────────────────────────
    Item {
        id: cardsContainer

        // Float on the right side with margins
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: 10
            topMargin: 10
            bottomMargin: 10
        }
        width: 750

        property real _anim: 0.0
        Component.onCompleted: _anim = SessionState.rightSidebarOpen ? 1.0 : 0.0
        opacity: _anim

        transform: Translate {
            x: (1 - cardsContainer._anim) * (cardsContainer.width + 20)
        }

        NumberAnimation {
            id: animIn
            target: cardsContainer
            property: "_anim"
            to: 1.0
            duration: 250
            easing.type: Theme.easingType
            easing.bezierCurve: Theme.easingCurveIn
        }

        NumberAnimation {
            id: animOut
            target: cardsContainer
            property: "_anim"
            to: 0.0
            duration: 200
            easing.type: Theme.easingType
            easing.bezierCurve: Theme.easingCurveOut
        }

        Connections {
            target: SessionState
            function onRightSidebarOpenChanged() {
                if (SessionState.rightSidebarOpen) {
                    animOut.stop()
                    animIn.restart()
                } else {
                    animIn.stop()
                    animOut.restart()
                }
            }
        }

        // Block clicks inside the sidebar from propagating to the click-away background
        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => { mouse.accepted = true }
        }

        ColumnLayout {
            id: cardsLayout
            anchors.fill: parent
            spacing: 10

            // ── Card 1: GitHub Heatmap ──
            HeatmapCard {
                Layout.fillWidth: true
            }

            // ── Column: Repos (compact) + Weather & Quick Actions ──
            ColumnLayout {
                Layout.fillWidth: false
                Layout.preferredWidth: 440
                Layout.alignment: Qt.AlignRight
                Layout.fillHeight: true
                spacing: 10

                RepoCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: 310
                }

                WeatherCard {
                    Layout.fillWidth: true
                }

                LauncherCard {
                    Layout.fillWidth: true
                }

                // Spacer to push everything to the top
                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
