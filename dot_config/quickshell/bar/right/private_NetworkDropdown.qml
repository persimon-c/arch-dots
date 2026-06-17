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

    onOpenChanged: {
        if (open) Network.startScan()
        else      Network.stopScan()
    }

    // Visibility bound to the shared state

    onVisibleChanged: {
        if (!visible) NetworkState.popupVisible = false
    }

    // Anchor exactly to the Network Pill
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 40

    grabFocus: false
    color: "transparent"

    // Size driven entirely by the card
    implicitWidth: contentCard.implicitWidth
    implicitHeight: contentCard.implicitHeight

    // ── Content Card ──────────────────────────────────────────────────────
    Rectangle {
        id: contentCard
        implicitWidth: 268
        implicitHeight: col.implicitHeight + 28
        radius: 10
        color: "transparent"
        AmbientSurface {
            anchors.fill: parent
            radius: contentCard.radius
            borderColor: PanelColors.pillNetwork
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

        ColumnLayout {
            id: col
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            spacing:       2

            // ── Wired row ─────────────────────────────────────────────────────
            Item {
                visible:        Network.wiredConnected
                Layout.fillWidth: true
                implicitHeight: 36

                Rectangle {
                    anchors.fill: parent
                    radius:       Theme.radiusSm
                    color:        Qt.rgba(
                                      Qt.color(PanelColors.accent).r,
                                      Qt.color(PanelColors.accent).g,
                                      Qt.color(PanelColors.accent).b,
                                      0.18
                                  )
                }

                RowLayout {
                    anchors {
                        fill:        parent
                        leftMargin:  Theme.spacingSm
                        rightMargin: Theme.spacingSm
                    }
                    spacing: Theme.spacingXs

                    Text {
                        text:           "󰈀"
                        color:          PanelColors.accent
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                    }
                    Text {
                        text:             qsTr("Wired")
                        color:            PanelColors.accent
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSizeSm
                        font.weight:      Theme.fontWeightSemiBold
                        Layout.fillWidth: true
                    }
                    Text {
                        text:           "󰸞"
                        color:          PanelColors.accent
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSm
                    }
                }
            }

            // ── Divider ───────────────────────────────────────────────────────
            Rectangle {
                visible:             Network.wiredConnected && Network.wifiEnabled
                Layout.fillWidth:    true
                Layout.topMargin:    2
                Layout.bottomMargin: 2
                height:              1
                color:               PanelColors.borderSubtle
            }

            // ── Wi-Fi header + toggle ─────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:    true
                Layout.bottomMargin: 4

                Text {
                    text:             Network.wifiEnabled ? qsTr("Wi-Fi On") : qsTr("Wi-Fi Off")
                    color:            PanelColors.textPrimary
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSizeSm
                    font.weight:      Theme.fontWeightSemiBold
                    Layout.fillWidth: true
                }

                // Toggle switch
                Item {
                    implicitWidth:  36
                    implicitHeight: 20

                    Rectangle {
                        anchors.fill: parent
                        radius:       Theme.radiusFull
                        color:        Network.wifiEnabled ? PanelColors.accent : PanelColors.border

                        Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                        Rectangle {
                            width:   16
                            height:  16
                            radius:  Theme.radiusFull
                            color:   PanelColors.onAccent
                            anchors.verticalCenter: parent.verticalCenter
                            x:       Network.wifiEnabled ? parent.width - width - 2 : 2

                            Behavior on x { NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    Network.toggleWifi()
                    }
                }
            }

            // ── Scanning indicator ────────────────────────────────────────────
            RowLayout {
                visible:          Network.scanning && Network.wifiEnabled
                Layout.fillWidth: true

                Text {
                    id:             scanIcon
                    text:           "󰑐"
                    color:          PanelColors.textMuted
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm

                    RotationAnimator on rotation {
                        running:  Network.scanning
                        from:     0
                        to:       360
                        duration: 1000
                        loops:    Animation.Infinite
                    }
                }

                Text {
                    text:           qsTr("Scanning...")
                    color:          PanelColors.textMuted
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                }
            }

            // ── Network list ──────────────────────────────────────────────────
            ListView {
                id:               netList
                visible:          Network.wifiEnabled
                Layout.fillWidth: true
                implicitHeight:   Math.min(contentHeight, 220)
                clip:             true
                model:            Network.networks
                spacing:          2

                delegate: Item {
                    id:    netRow
                    width: netList.width
                    implicitHeight: 36

                    required property var modelData

                    readonly property bool   isActive: netRow.modelData.ssid === Network.ssid
                    readonly property bool   hasLock:  (netRow.modelData.security || "") !== ""
                                                        && netRow.modelData.security !== "--"

                    Rectangle {
                        anchors.fill: parent
                        radius:       Theme.radiusSm
                        color:        netRow.isActive
                                          ? Qt.rgba(Qt.color(PanelColors.accent).r, Qt.color(PanelColors.accent).g, Qt.color(PanelColors.accent).b, 0.18)
                                          : rowMA.containsMouse
                                              ? Qt.rgba(Qt.color(PanelColors.accent).r, Qt.color(PanelColors.accent).g, Qt.color(PanelColors.accent).b, 0.08)
                                              : "transparent"

                        Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                    }

                    RowLayout {
                        anchors {
                            fill:        parent
                            leftMargin:  Theme.spacingSm
                            rightMargin: Theme.spacingSm
                        }
                        spacing: Theme.spacingXs

                        Text {
                            text: {
                                var s = netRow.modelData.signal
                                if (s >= 80) return "󰤨"
                                if (s >= 60) return "󰤥"
                                if (s >= 40) return "󰤢"
                                if (s >= 20) return "󰤟"
                                return "󰤯"
                            }
                            color:          netRow.isActive ? PanelColors.accent : PanelColors.textMuted
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                        }

                        Text {
                            text:             netRow.modelData.ssid
                            color:            netRow.isActive ? PanelColors.accent : PanelColors.textPrimary
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.fontSizeSm
                            font.weight:      netRow.isActive ? Theme.fontWeightSemiBold : Theme.fontWeightNormal
                            elide:            Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            visible:        netRow.hasLock
                            text:           "󰌾"
                            color:          netRow.isActive ? PanelColors.accent : PanelColors.textMuted
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                        }

                        Text {
                            visible:        netRow.isActive
                            text:           "󰸞"
                            color:          PanelColors.accent
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                        }
                    }

                    MouseArea {
                        id:           rowMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    if (!netRow.isActive) Network.connectNetwork(netRow.modelData.ssid)
                    }
                }
            }

            // ── Empty states ──────────────────────────────────────────────────
            Text {
                visible:          Network.wifiEnabled && !Network.scanning && Network.networks.length === 0
                Layout.alignment: Qt.AlignHCenter
                text:             qsTr("No networks found")
                color:            PanelColors.textMuted
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.fontSizeSm
            }

            Text {
                visible:          !Network.wifiEnabled && !Network.wiredConnected
                Layout.alignment: Qt.AlignHCenter
                text:             qsTr("Wi-Fi is disabled")
                color:            PanelColors.textMuted
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.fontSizeSm
            }
        }
    }
}
