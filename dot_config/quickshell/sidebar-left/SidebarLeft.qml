import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"
import "../state"
import "../services"
import "../components"

PanelWindow {
    id: root

    // ── IPC trigger ───────────────────────────────────────────────────────
    IpcHandler {
        target: "left-sidebar"

        function toggle(): void {
            if (SidebarState.leftOpen) {
                SidebarState.hideLeft()
            } else {
                SidebarState.showLeft()
            }
        }
    }

    // Full-screen window to capture click-away events
    anchors {
        left:   true
        right:  true
        top:    true
        bottom: true
    }

    color: "transparent"

    // Set overlay layer so it sits above normal windows
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: SidebarState.leftOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusiveZone: 0

    // Toggle visibility with smooth sliding/opacity transitions
    visible: SidebarState.leftOpen || (cardsContainer.opacity > 0.01)

    // Full-screen click-away area to close the sidebar when clicking outside
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        focus: SidebarState.leftOpen
        Keys.onEscapePressed: SidebarState.hideLeft()

        MouseArea {
            anchors.fill: parent
            onClicked: SidebarState.hideLeft()
        }
    }

    // ── Sidebar Container ─────────────────────────────────────────────────────
    Item {
        id: cardsContainer
        
        // Float on the left side with margins
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            leftMargin: 10
            topMargin: 10
            bottomMargin: 10
        }
        width: 300

        property real _anim: 0.0
        Component.onCompleted: _anim = SidebarState.leftOpen ? 1.0 : 0.0
        opacity: _anim

        transform: Translate {
            x: -(1 - cardsContainer._anim) * (cardsContainer.width + 20)
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
            target: SidebarState
            function onLeftOpenChanged() {
                if (SidebarState.leftOpen) {
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

        Flickable {
            id: flickable
            anchors.fill: parent
            contentWidth: width
            contentHeight: cardsLayout.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: cardsLayout
                width: flickable.width
                height: Math.max(flickable.height, cardsLayout.implicitHeight)
                spacing: 10

                // ── Card 1: Profile ──
                AccentCard {
                    id: profileCard
                    accent: PanelColors.profile
                    label: "meow"
                    Layout.fillWidth: true
                    implicitHeight: 110

                    Row {
                        anchors.fill: parent
                        spacing: 16

                        // Avatar container
                        Item {
                            width: 56
                            height: 56
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: avatarImg
                                anchors.fill: parent
                                source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/avatar.png"
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                mipmap: true
                                visible: status === Image.Ready

                                onStatusChanged: {
                                    if (status === Image.Error && source !== "file://" + Quickshell.env("HOME") + "/.face") {
                                        source = "file://" + Quickshell.env("HOME") + "/.face"
                                    }
                                }
                            }

                            // Fallback avatar icon if image fails to load
                            Text {
                                visible: avatarImg.status !== Image.Ready
                                anchors.centerIn: parent
                                text: ""
                                font.pixelSize: 32
                                font.family: Theme.fontFamily
                                color: PanelColors.textDim
                            }

                            // Styled border overlay
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.width: 1.5
                                border.color: profileCard.accent
                                radius: 8
                            }
                        }

                        // Profile Info
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: Quickshell.env("USER") || "user"
                                font.pixelSize: Theme.fontSizeLg
                                font.bold: true
                                font.family: Theme.fontFamily
                                color: PanelColors.textAccent
                            }
                            Text {
                                text: "for the love of the game"
                                font.pixelSize: Theme.fontSizeXs
                                font.family: Theme.fontFamily
                                color: PanelColors.textDim
                            }
                            Text {
                                text: "uptime: " + System.uptimeStr
                                font.pixelSize: Theme.fontSizeXs
                                font.family: Theme.fontFamily
                                color: profileCard.accent
                                opacity: 0.9
                            }
                        }
                    }
                }

                // ── Card 2: System Controls (Volume & Brightness) ──
                SystemControlsCard {
                    Layout.fillWidth: true
                }

                // ── Card 5: System Status Monitors ──
                AccentCard {
                    id: systemCard
                    accent: Colors.primary
                    label: "system status"
                    Layout.fillWidth: true
                    implicitHeight: 120

                    Row {
                        anchors.centerIn: parent
                        spacing: 20

                        CircularGauge {
                            size: 68
                            value: System.cpuPercent / 100
                            label: "CPU"
                            arcColor: Colors.error
                        }

                        CircularGauge {
                            size: 68
                            value: System.ramPercent / 100
                            label: "RAM"
                            arcColor: Colors.primary
                        }

                        CircularGauge {
                            size: 68
                            value: System.gpuPercent / 100
                            label: "GPU"
                            arcColor: Colors.tertiary
                        }
                    }
                }

                // ── Card 6: Storage & Network Bandwidth ──
                NetStorageCard {
                    Layout.fillWidth: true
                }

                // ── Card 7: Todo Checklist ──
                TodoCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
