import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Bluetooth as QB
import "../../components"
import "../../theme"
import "../../services"
import "../../state"

PopupWindow {
    id: root

    property bool open: false
    visible: open || (contentCard._anim > 0.01)
    property Item anchorItem: null

    // Visibility bound to the shared state

    onVisibleChanged: {
        if (!visible) BluetoothState.popupVisible = false
    }

    // Anchor exactly to the Bluetooth Pill
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 40

    grabFocus: false
    color: "transparent"

    // Size driven entirely by the card
    implicitWidth: contentCard.implicitWidth
    implicitHeight: contentCard.implicitHeight

    readonly property bool btOn:          Bluetooth.enabled
    readonly property bool scanning:      btOn && Bluetooth.discovering
    readonly property int  maxListHeight: 5 * 34 + 4 * 4

    readonly property var accentColors: [Colors.tertiary, Colors.secondary, Colors.primary]

    // ── Shared animation component ─────────────────────────────────────
    component SpinnerIcon: Text {
        id: spinnerIcon
        required property bool active
        font.pixelSize: 15
        font.family:    Theme.fontFamily
        SequentialAnimation on opacity {
            running:  spinnerIcon.active
            loops:    Animation.Infinite
            NumberAnimation { to: 0.4; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
        }
        onActiveChanged: if (!active) opacity = 1.0
    }

    // ── Shared row button component ────────────────────────────────────
    component RowButton: Rectangle {
        id: btn
        required property color accent
        required property color textAccent
        required property bool  active
        required property bool  busy        // spinner / in-progress state
        property alias  label:  labelText.text
        property alias  icon:   iconText.text

        width: parent.width; height: 34; radius: 6
        color: {
            let base = btn.active ? btn.accent : PanelColors.rowBackground
            return btnMouse.containsMouse && !btn.active && !btn.busy
                ? Qt.lighter(base, 1.15) : base
        }
        Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

        // Left accent bar (shown when inactive)
        Rectangle {
            visible: !btn.active
            width: 3; height: parent.height - 10; radius: 2
            anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
            color: btn.accent
        }

        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
            spacing: 8

            SpinnerIcon {
                id: iconText
                active: btn.busy
                color:  btn.active ? btn.textAccent : PanelColors.textPrimary
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: labelText
                font.pixelSize: 13; font.bold: true; font.family: Theme.fontFamily
                color: btn.active ? btn.textAccent : PanelColors.textPrimary
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        property alias mouseArea: btnMouse
        MouseArea {
            id: btnMouse
            anchors.fill: parent; hoverEnabled: true
        }
    }

    // ── Content Card ──────────────────────────────────────────────────────
    Rectangle {
        id: contentCard
        implicitWidth: 240
        implicitHeight: column.implicitHeight + 24 // 12 padding top & bottom
        radius: 10
        color: "transparent"
        AmbientSurface {
            anchors.fill: parent
            radius: contentCard.radius
            borderColor: Bluetooth.enabled ? PanelColors.bluetoothActive : PanelColors.border
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
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 12
            }
            spacing: 4

            // ── Adapter toggle ─────────────────────────────────────────────
            RowButton {
                accent: PanelColors.bluetoothActive
                textAccent: PanelColors.bluetoothTextActive
                active: root.btOn
                busy:   false
                icon:   root.btOn ? "󰂯" : "󰂲"
                label:  root.btOn ? qsTr("Bluetooth On") : qsTr("Bluetooth Off")
                mouseArea.onClicked: Bluetooth.toggleEnabled()
            }

            // ── Paired devices ─────────────────────────────────────────────
            Repeater {
                model: Bluetooth.devices
                delegate: Item {
                    required property var modelData
                    required property int index
                    visible: modelData.paired
                    width:   parent.width
                    height:  visible ? 34 : 0

                    readonly property bool isConnected:    modelData.state === QB.BluetoothDeviceState.Connected
                    readonly property bool isConnecting:   modelData.state === QB.BluetoothDeviceState.Connecting
                    readonly property bool isDisconnecting: modelData.state === QB.BluetoothDeviceState.Disconnecting
                    readonly property bool isTransitioning: isConnecting || isDisconnecting

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: {
                            let base = isConnected ? PanelColors.bluetoothActive : PanelColors.rowBackground
                            return pairedMouse.containsMouse && !isConnected && !isTransitioning
                                ? Qt.lighter(base, 1.15) : base
                        }
                        Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                        // Left accent bar (shown when disconnected)
                        Rectangle {
                            visible: !isConnected
                            width: 3; height: parent.height - 10; radius: 2
                            anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                            color: root.accentColors[index % root.accentColors.length]
                        }

                        Row {
                            anchors {
                                left: parent.left; verticalCenter: parent.verticalCenter
                                leftMargin: 14; right: parent.right; rightMargin: 10
                            }
                            spacing: 8

                            // Icon — spins while connecting / disconnecting
                            SpinnerIcon {
                                active: isTransitioning
                                text: {
                                    if (isConnected)     return "󰂱"
                                    if (isTransitioning) return "󰑐"
                                    return "󰂯"
                                }
                                color: isConnected ? PanelColors.bluetoothTextActive : PanelColors.textPrimary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.name
                                font.pixelSize: 13; font.bold: true; font.family: Theme.fontFamily
                                color: isConnected ? PanelColors.bluetoothTextActive : PanelColors.textPrimary
                                elide: Text.ElideRight
                                width: parent.width - 23 - 8
                                       - (isConnected && modelData.batteryAvailable ? 36 : 0)
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                visible: isConnected && modelData.batteryAvailable
                                text:    visible ? Math.round(modelData.battery * 100) + "%" : ""
                                font.pixelSize: 12; font.family: Theme.fontFamily
                                color: PanelColors.bluetoothTextActive
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: pairedMouse
                            anchors.fill: parent; hoverEnabled: true
                            // Guard against clicks during transitioning states
                            onClicked: {
                                if (isTransitioning) return
                                if (isConnected) Bluetooth.disconnectDevice(modelData)
                                else             Bluetooth.connectDevice(modelData)
                            }
                        }
                    }
                }
            }

            // ── Divider ────────────────────────────────────────────────────
            Rectangle {
                visible: root.btOn
                width: parent.width; height: visible ? 2 : 0
                color: PanelColors.rowBackground
            }

            // ── Scan toggle ────────────────────────────────────────────────
            RowButton {
                visible: root.btOn
                height:  visible ? 34 : 0
                accent:  PanelColors.bluetoothScanning
                textAccent: PanelColors.bluetoothTextScanning
                active:  root.scanning
                busy:    root.scanning
                icon:    "󰑐"
                label:   root.scanning ? qsTr("Scanning...") : qsTr("Scan")
                mouseArea.onClicked: Bluetooth.toggleDiscovery()
            }

            // ── Pair with PIN ──────────────────────────────────────────────
            Rectangle {
                visible: root.scanning
                width: parent.width; height: visible ? 34 : 0; radius: 6
                color: pinMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.15) : PanelColors.rowBackground
                Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                Rectangle {
                    width: 3; height: parent.height - 10; radius: 2
                    anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                    color: PanelColors.textDim
                }

                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    spacing: 8
                    Text {
                        text: "󰌆"
                        font.pixelSize: 15; font.family: Theme.fontFamily
                        color: PanelColors.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: qsTr("Pair with PIN...")
                        font.pixelSize: 13; font.bold: true; font.family: Theme.fontFamily
                        color: PanelColors.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Process {
                    id: bluetoothctlProc
                    command: ["/usr/bin/kitty", "--title=bluetoothctl", "-e", "bluetoothctl"]
                    running: false
                }

                MouseArea {
                    id: pinMouse
                    anchors.fill: parent; hoverEnabled: true
                    onClicked: {
                        bluetoothctlProc.running = true
                        BluetoothState.popupVisible = false
                    }
                }
            }

            // ── Unpaired scan results ──────────────────────────────────────
            Item {
                visible: root.scanning
                width:   parent.width
                height:  visible ? root.maxListHeight : 0

                Flickable {
                    id: unpairedFlickable
                    anchors.fill: parent
                    contentHeight: unpairedColumn.implicitHeight
                    clip: true
                    interactive: contentHeight > height

                    Column {
                        id: unpairedColumn
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: Bluetooth.devices
                            delegate: Item {
                                required property var modelData
                                required property int index
                                readonly property bool show: !modelData.paired
                                    && modelData.name.trim() !== ""
                                    && !/^([0-9A-Fa-f]{2}[:\-]){5}[0-9A-Fa-f]{2}$/.test(modelData.name.trim())

                                visible: show
                                width:   unpairedColumn.width
                                height:  show ? 34 : 0

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 6
                                    color: {
                                        let base = modelData.pairing ? PanelColors.bluetoothPairing : PanelColors.rowBackground
                                        return unpMouse.containsMouse && !modelData.pairing
                                            ? Qt.lighter(base, 1.15) : base
                                    }
                                    Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                                    // Left accent bar
                                    Rectangle {
                                        visible: !modelData.pairing
                                        width: 3; height: parent.height - 10; radius: 2
                                        anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                                        color: root.accentColors[index % root.accentColors.length]
                                    }

                                    Row {
                                        anchors {
                                            left: parent.left; verticalCenter: parent.verticalCenter
                                            leftMargin: 14; right: parent.right; rightMargin: 10
                                        }
                                        spacing: 8

                                        SpinnerIcon {
                                            active: modelData.pairing
                                            text:   modelData.pairing ? "󰑐" : "󰂯"
                                            color:  modelData.pairing ? PanelColors.bluetoothTextActive : PanelColors.textPrimary
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 13; font.bold: true; font.family: Theme.fontFamily
                                            color: modelData.pairing ? PanelColors.bluetoothTextActive : PanelColors.textPrimary
                                            elide: Text.ElideRight
                                            width: parent.width - 23 - 8
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    MouseArea {
                                        id: unpMouse
                                        anchors.fill: parent; hoverEnabled: true
                                        onClicked: if (!modelData.pairing) Bluetooth.pairDevice(modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Scroll hints ───────────────────────────────────────────
                Rectangle {
                    visible: !unpairedFlickable.atYBeginning
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 22; radius: 6
                    color: PanelColors.rowBackground
                    Row {
                        anchors.centerIn: parent; spacing: 6
                        Text { text: "󰁞"; font.pixelSize: 12; font.family: Theme.fontFamily; color: PanelColors.textDim; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: qsTr("scroll up"); font.pixelSize: 11; font.family: Theme.fontFamily; color: PanelColors.textDim; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                Rectangle {
                    visible: !unpairedFlickable.atYEnd
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height: 22; radius: 6
                    color: PanelColors.rowBackground
                    Row {
                        anchors.centerIn: parent; spacing: 6
                        Text { text: "󰁆"; font.pixelSize: 12; font.family: Theme.fontFamily; color: PanelColors.textDim; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: qsTr("scroll for more"); font.pixelSize: 11; font.family: Theme.fontFamily; color: PanelColors.textDim; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }
    }
}
