import QtQuick
import Quickshell
import "../../components"
import "../../theme"
import "../../services"
import "../../state"
import "."

Item {
    id: root

    implicitWidth: Media.isPlaying ? cavaPill.implicitWidth : pill.implicitWidth
    implicitHeight: Theme.pillHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    StatusChip {
        id: pill
        visible: !Media.isPlaying
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        backgroundColor: PanelColors.pillClock
        foregroundColor: PanelColors.pillTextClock
        borderColor: "transparent"
        showLabel: true
        minWidth: 100

        icon: "󰃭"
        label: Qt.formatTime(clock.date, "HH:mm")

        onClicked: {
            MediaState.toggle()
        }
    }

    Pill {
        id: cavaPill
        visible: Media.isPlaying
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        bgColor: PanelColors.pillClock
        bgOpacity: 0.85
        radius: 5

        implicitWidth: visualizerRow.implicitWidth + 24

        Item {
            anchors.fill: parent

            Row {
                id: visualizerRow
                anchors.centerIn: parent
                spacing: 2
                height: 16

                Repeater {
                    model: Cava.bars

                    delegate: Rectangle {
                        width: 4
                        height: Math.max(2, modelData * 15)
                        radius: 2
                        color: PanelColors.pillTextClock
                        anchors.bottom: parent.bottom
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    MediaState.toggle()
                }
            }
        }
    }

    // ── Media Dropdown ────────────────────────────────────────────────────
    MediaDropdown {
        open:       MediaState.popupVisible
        anchorItem: root
    }
}
