import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"
import "../components"

AccentCard {
    id: root
    accent: Colors.primary
    label: "weather"
    Layout.fillWidth: true
    implicitHeight: 120

    property string emoji: "❓"
    property string temp: "N/A"
    property string wind: "N/A"
    property string desc: "Loading..."

    Process {
        id: weatherProc
        command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/weather.sh"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = this.text.trim()
                if (!raw) return
                try {
                    var data = JSON.parse(raw)
                    root.emoji = data.emoji || "❓"
                    root.temp = data.temp || "N/A"
                    root.wind = data.wind || "N/A"
                    root.desc = data.desc || "Unknown"
                } catch (e) {
                    console.warn("[Weather] parse error:", e)
                }
            }
        }
    }

    Timer {
        id: weatherTimer
        interval: 900000 // 15 minutes
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: weatherProc.running = true
    }

    RowLayout {
        anchors.fill: parent
        spacing: 16

        // Large Emoji
        Text {
            text: root.emoji
            font.pixelSize: 36
            Layout.alignment: Qt.AlignVCenter
        }

        // Details Column
        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            Text {
                text: root.temp
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLg
                font.weight: Theme.fontWeightBold
                color: PanelColors.textAccent
            }

            Text {
                text: root.desc
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                color: PanelColors.textDim
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: "💨 " + root.wind
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                color: PanelColors.textDim
            }
        }
    }
}
