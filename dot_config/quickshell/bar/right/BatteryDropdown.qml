import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../theme"
import "../../services"
import "../../components"
import "../../state"

PopupWindow {
    id: root

    property bool open: false
    visible: open || (contentCard._anim > 0.01)
    property Item anchorItem: null

    // Visibility bound to the shared state

    onVisibleChanged: {
        if (!visible) BatteryState.popupVisible = false
    }

    // Anchor exactly to the Battery Pill
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 40

    grabFocus: false
    color: "transparent"

    // Size driven entirely by the card
    implicitWidth: contentCard.implicitWidth
    implicitHeight: contentCard.implicitHeight

    readonly property color batteryColor: Battery.isCharging ? "#f6c177" : Battery.available && Battery.percentInt <= 15 ? "#eb6f92" : PanelColors.pillBattery


    // ── Content Card ──────────────────────────────────────────────────────
    Rectangle {
        id: contentCard
        implicitWidth: 210
        implicitHeight: column.implicitHeight + 24 // 12 padding top & bottom
        radius: 10
        color: "transparent"
        AmbientSurface {
            anchors.fill: parent
            radius: contentCard.radius
            borderColor: root.batteryColor
            borderWidth: 2
        }
        property real _anim: 0.0
        opacity: _anim
        
        transform: [
            Translate {
                y: (1 - contentCard._anim) * -8
            },
            Scale {
                xScale: 0.90 + contentCard._anim * 0.10
                yScale: xScale
                origin.x: contentCard.width / 2
                origin.y: 0
            }
        ]

        NumberAnimation {
            id: animIn
            target: contentCard
            property: "_anim"
            to: 1.0
            duration: Theme.durationSlow
            easing.type: Theme.easingType
            easing.bezierCurve: Theme.easingCurveIn
        }

        NumberAnimation {
            id: animOut
            target: contentCard
            property: "_anim"
            to: 0.0
            duration: Theme.durationFast
            easing.type: Theme.easingType
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

        Column {
            id: column
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 4

            Repeater {
                model: [
                    { profile: "Quiet",        icon: "󰌪", label: qsTr("Power Saver"),  color: PanelColors.profileQuiet },
                    { profile: "Balanced",     icon: "󰗑", label: qsTr("Balanced"),     color: PanelColors.profileBalanced },
                    { profile: "Performance",  icon: "󰓅", label: qsTr("Performance"),  color: PanelColors.profilePerformance }
                ]

                delegate: Rectangle {
                    id: rowItem
                    required property var modelData
                    readonly property bool isActive: AsusCtl.powerProfile === modelData.profile

                    width: parent.width
                    height: 34
                    radius: 6

                    color: {
                        let bg = isActive ? root.batteryColor : PanelColors.rowBackground
                        return profileMouse.containsMouse && !isActive ? Qt.lighter(bg, 1.15) : bg
                    }

                    Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                    // Left strip — only on inactive profiles
                    Rectangle {
                        visible: !rowItem.isActive
                        width: 3
                        height: parent.height - 10
                        radius: 2
                        anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                        color: modelData.color
                    }

                    Row {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                        spacing: 8

                        Text {
                            text: modelData.icon
                            font.pixelSize: 15
                            font.family: Theme.fontFamily
                            color: rowItem.isActive ? PanelColors.pillTextBattery : PanelColors.textAccent
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.label
                            font.pixelSize: 13
                            font.bold: true
                            font.family: Theme.fontFamily
                            color: rowItem.isActive ? PanelColors.pillTextBattery : PanelColors.textAccent
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: profileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            AsusCtl.setProfile(modelData.profile)
                            BatteryState.popupVisible = false
                        }
                    }
                }
            }
        }
    }
}
