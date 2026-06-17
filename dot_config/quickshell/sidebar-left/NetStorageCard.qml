import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"
import "../services"
import "../components"

AccentCard {
    id: root
    accent: Colors.primary
    label: "storage & network"
    Layout.fillWidth: true
    implicitHeight: 200

    function shortenSpeed(str) {
        if (!str) return "0B/s"
        return str.replace(" KiB/s", "K/s")
                  .replace(" MiB/s", "M/s")
                  .replace(" GiB/s", "G/s")
                  .replace(" B/s", "B/s")
    }

    // Force QML reactivity on disk stats using the disksRevision property
    readonly property var currentDisk: {
        System.disksRevision
        if (System.monitoredDisks && System.monitoredDisks.length > 0) {
            return System.disks[System.monitoredDisks[0]]
        }
        return null
    }

    readonly property string diskReadStr: currentDisk ? (currentDisk.readStr || "0 KiB/s") : "0 KiB/s"
    readonly property string diskWriteStr: currentDisk ? (currentDisk.writeStr || "0 KiB/s") : "0 KiB/s"

    property string localIp: "loading..."

    Process {
        id: ipProc
        command: ["/usr/bin/bash", "-c", "ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' || ip -4 addr show scope global | awk '/inet/ {print $2; exit}' | cut -d/ -f1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = this.text.trim()
                if (raw) {
                    root.localIp = raw
                } else {
                    root.localIp = "unknown"
                }
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: ipProc.running = true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // ── Storage Part ──────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: System.monitoredDisks
                delegate: ColumnLayout {
                    id: diskLayout
                    Layout.fillWidth: true
                    spacing: 4
                    visible: !!diskLayout.diskInfo

                    property var diskInfo: {
                        System.disksRevision
                        return System.disks[modelData] || null
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "  " + (diskLayout.diskInfo ? (diskLayout.diskInfo.mount || diskLayout.diskInfo.name) : modelData)
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            font.weight: Theme.fontWeightBold
                            color: PanelColors.textAccent
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: diskLayout.diskInfo ? (diskLayout.diskInfo.usedGiB.toFixed(1) + "/" + diskLayout.diskInfo.totalGiB.toFixed(0) + "G (" + diskLayout.diskInfo.percent + "%)") : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            color: PanelColors.textDim
                        }
                    }

                    // Thicker progress bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: PanelColors.rowBackground

                        Rectangle {
                            width: parent.width * ((diskLayout.diskInfo ? diskLayout.diskInfo.percent : 0) / 100)
                            height: parent.height
                            radius: 3
                            color: Colors.primary
                        }
                    }

                    // Disk details row
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "󰓅  R: " + (diskLayout.diskInfo ? root.shortenSpeed(diskLayout.diskInfo.readStr) : "0K/s") + "  W: " + (diskLayout.diskInfo ? root.shortenSpeed(diskLayout.diskInfo.writeStr) : "0K/s")
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: PanelColors.textDim
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: (diskLayout.diskInfo ? diskLayout.diskInfo.freeGiB.toFixed(1) : "0") + "G free"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: PanelColors.textDim
                        }
                    }
                }
            }
        }

        // ── Network Part ──────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰀂  " + (System.primaryInterface || "down")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXs
                    font.weight: Theme.fontWeightBold
                    color: PanelColors.textAccent
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: root.localIp
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXs
                    color: PanelColors.textDim
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "  " + root.shortenSpeed(System.netRxStr) + "    " + root.shortenSpeed(System.netTxStr)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXs
                    color: PanelColors.textDim
                }
                Item { Layout.fillWidth: true }
                Text {
                    visible: Network.wifiConnected && Network.ssid !== ""
                    text: "SSID: " + Network.ssid
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXs
                    color: PanelColors.textDim
                }
            }
        }
    }
}
