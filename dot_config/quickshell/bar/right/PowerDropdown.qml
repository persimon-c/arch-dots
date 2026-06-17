import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../theme"
import "../../state"
import "../../components"

PopupWindow {
    id: root

    property bool open: false
    visible: open || (contentCard._anim > 0.01)
    property Item anchorItem: null

    onVisibleChanged: {
        if (!visible) SessionState.sessionVisible = false
    }

    // Anchor below the PowerPill, matching other bar dropdowns
    anchor.item:        anchorItem
    anchor.edges:       Edges.Bottom
    anchor.gravity:     Edges.Bottom
    anchor.margins.top: 40

    grabFocus: false
    color:     "transparent"

    implicitWidth:  contentCard.implicitWidth
    implicitHeight: contentCard.implicitHeight

    // ── Content Card ──────────────────────────────────────────────────────

    Rectangle {
        id: contentCard
        implicitWidth:  200
        implicitHeight: column.implicitHeight + 24   // 12 px padding top & bottom
        radius:         10
        color:          "transparent"

        AmbientSurface {
            anchors.fill: parent
            radius:       contentCard.radius
            borderColor:  Qt.color(PanelColors.pillPower)
            borderWidth:  2
        }

        property real _anim: 0.0
        opacity: _anim

        transform: [
            Translate {
                y: (1 - contentCard._anim) * -8
            },
            Scale {
                xScale:   0.90 + contentCard._anim * 0.10
                yScale:   xScale
                origin.x: contentCard.width  / 2
                origin.y: 0
            }
        ]

        NumberAnimation {
            id: animIn
            target:   contentCard
            property: "_anim"
            to:       1.0
            duration: Theme.durationSlow
            easing.type:        Theme.easingType
            easing.bezierCurve: Theme.easingCurveIn
        }

        NumberAnimation {
            id: animOut
            target:   contentCard
            property: "_anim"
            to:       0.0
            duration: Theme.durationFast
            easing.type:        Theme.easingType
            easing.bezierCurve: Theme.easingCurveOut
        }

        Connections {
            target: root
            function onOpenChanged() {
                if (root.open) {
                    animOut.stop()
                    animIn.restart()
                } else {
                    animIn.stop()
                    animOut.restart()
                }
            }
        }

        // ── Action rows ───────────────────────────────────────────────────

        Column {
            id: column
            anchors {
                fill:    parent
                margins: 12
            }
            spacing: 4

            Repeater {
                // Verbatim commands from the "system" submap in binds.lua.
                // Order: L → S → E → R → Q  (lock, suspend, logout, reboot, poweroff)
                // "escape" bind is mechanics-only and has no button here.
                model: [
                    {
                        label:   qsTr("Lock"),
                        icon:    "󰌾",
                        // binds.lua key L: ~/.config/quickshell/scripts/lock.sh
                        command: Quickshell.env("HOME") + "/.config/quickshell/scripts/lock.sh"
                    },
                    {
                        label:   qsTr("Suspend"),
                        icon:    "󰒲",
                        // binds.lua key S: systemctl suspend
                        command: "systemctl suspend"
                    },
                    {
                        label:   qsTr("Log Out"),
                        icon:    "󰍃",
                        // binds.lua key E: loginctl terminate-user ""
                        // Empty string resolves to the calling user — intentional per binds.lua
                        command: "loginctl terminate-user \"\""
                    },
                    {
                        label:   qsTr("Reboot"),
                        icon:    "󰜉",
                        // binds.lua key R: systemctl reboot
                        command: "systemctl reboot"
                    },
                    {
                        label:   qsTr("Power Off"),
                        icon:    "⏻",
                        // binds.lua key Q: systemctl poweroff
                        command: "systemctl poweroff"
                    }
                ]

                delegate: Rectangle {
                    id: rowItem
                    required property var modelData

                    width:  column.width
                    height: 34
                    radius: 6

                    color: actionMouse.containsMouse
                        ? Qt.rgba(
                            Qt.color(PanelColors.pillPower).r,
                            Qt.color(PanelColors.pillPower).g,
                            Qt.color(PanelColors.pillPower).b,
                            0.18)
                        : Qt.color(PanelColors.rowBackground)

                    Behavior on color {
                        ColorAnimation {
                            duration:           150
                            easing.type:        Theme.easingType
                            easing.bezierCurve: Theme.easingCurve
                        }
                    }

                    // Left accent strip
                    Rectangle {
                        width:  3
                        height: parent.height - 10
                        radius: 2
                        anchors {
                            left:           parent.left
                            leftMargin:     4
                            verticalCenter: parent.verticalCenter
                        }
                        color: Qt.color(PanelColors.pillPower)
                    }

                    Row {
                        anchors {
                            left:           parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin:     14
                        }
                        spacing: 8

                        Text {
                            text:           modelData.icon
                            font.pixelSize: 15
                            font.family:    Theme.fontFamily
                            color:          Qt.color(PanelColors.textAccent)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:           modelData.label
                            font.pixelSize: 13
                            font.bold:      true
                            font.family:    Theme.fontFamily
                            color:          Qt.color(PanelColors.textAccent)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id:           actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            // Close popup first, then fire the action detached
                            SessionState.sessionVisible = false
                            Quickshell.execDetached(["bash", "-c", modelData.command])
                        }
                    }
                }
            }
        }
    }
}
