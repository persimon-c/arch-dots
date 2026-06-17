import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../services"
import "../components"

AccentCard {
    id: root
    accent: Colors.secondary
    label: "controls"
    Layout.fillWidth: true
    implicitHeight: 124

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // ── Volume Row ────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Volume Icon Button (with dynamic icons and mute toggle)
            Item {
                width: 24
                height: 24
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: volIcon
                    anchors.centerIn: parent
                    text: {
                        if (Audio.sinkEffMuted) return "󰝟"
                        if (Audio.sinkVolumeInt >= 66) return "󰕾"
                        if (Audio.sinkVolumeInt >= 33) return "󰖀"
                        return "󰕿"
                    }
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: Audio.sinkEffMuted ? PanelColors.warning : PanelColors.textAccent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.toggleSinkMuted()
                }
            }

            Slider {
                Layout.fillWidth: true
                from: 0.0
                to: 1.0
                value: Audio.sinkVolume
                enabled: Audio.sinkReady
                fillColor: Colors.secondary
                thumbColor: Colors.secondary
                thumbHaloColor: Colors.secondary
                onMoved: function(v) {
                    Audio.setSinkVolume(v)
                }
            }

            Text {
                text: Audio.sinkReady ? Audio.sinkVolumeInt + "%" : "0%"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                font.weight: Theme.fontWeightBold
                color: PanelColors.textDim
                width: 32
                horizontalAlignment: Text.AlignRight
            }
        }

        // ── Brightness Row ───────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item {
                width: 24
                height: 24
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: "󰃠"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: PanelColors.textAccent
                }
            }

            Slider {
                Layout.fillWidth: true
                from: 0.0
                to: 1.0
                value: Brightness.percent
                fillColor: Colors.tertiary
                thumbColor: Colors.tertiary
                thumbHaloColor: Colors.tertiary
                onMoved: function(v) {
                    Brightness.setPercent(v * 100)
                }
            }

            Text {
                text: Brightness.percentInt + "%"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                font.weight: Theme.fontWeightBold
                color: PanelColors.textDim
                width: 32
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
