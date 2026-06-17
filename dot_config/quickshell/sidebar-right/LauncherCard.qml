import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../state"
import "../components"

AccentCard {
    id: root
    accent: Colors.tertiary
    label: "quick actions"
    Layout.fillWidth: true
    implicitHeight: 144

    GridLayout {
        anchors.fill: parent
        columns: 3
        rows: 2
        columnSpacing: 10
        rowSpacing: 10

        // ── Action 1: Screenshot ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: screenshotMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainer

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "󰹑"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: Colors.tertiary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "Screenshot"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: PanelColors.textAccent
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: screenshotMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    SidebarState.leftOpen = false
                    Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/screenshot.sh"])
                }
            }
        }

        // ── Action 2: Lock Screen ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: lockMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainer

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "󰌾"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: Colors.tertiary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "Lock"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: PanelColors.textAccent
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: lockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    SidebarState.leftOpen = false
                    Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/lock.sh"])
                }
            }
        }

        // ── Action 3: Color Picker ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: colorMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainer

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "󰏘"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: Colors.tertiary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "Color Picker"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: PanelColors.textAccent
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: colorMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    SidebarState.leftOpen = false
                    Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/color-picker.sh"])
                }
            }
        }

        // ── Action 4: Wallpapers ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: wallMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainer

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "󰸉"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: Colors.tertiary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "Wallpaper"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: PanelColors.textAccent
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: wallMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    SessionState.closeAllPopups()
                    SessionState.wallpaperPickerVisible = true
                }
            }
        }

        // ── Action 5: Clipboard ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: clipMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainer

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "󰅍"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: Colors.tertiary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "Clipboard"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: PanelColors.textAccent
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: clipMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    SessionState.closeAllPopups()
                    SessionState.clipboardVisible = true
                }
            }
        }

        // ── Action 6: Launcher ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: launchMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainer

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "🚀"
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "App Grid"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: PanelColors.textAccent
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: launchMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    SessionState.closeAllPopups()
                    SessionState.launcherVisible = true
                }
            }
        }
    }
}
