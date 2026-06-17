// osd/MuteOsd.qml
// Visual sub-component for audio mute states in OSD.
//
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../services"

ColumnLayout {
    anchors.fill: parent
    spacing: Theme.spacingMd
    alignment: Qt.AlignVCenter

    Item { Layout.fillHeight: true }

    // Icon
    Image {
        Layout.alignment: Qt.AlignHCenter
        source: OsdService.activeOsd.icon !== ""
            ? Quickshell.iconPath(OsdService.activeOsd.icon)
            : Quickshell.iconPath("audio-volume-muted-symbolic")
        sourceSize: Qt.size(64, 64)
        smooth: true
    }

    // Label
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: OsdService.activeOsd.label
        color: PanelColors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLg
        font.weight: Theme.fontWeightBold
    }

    Item { height: Theme.spacingXs }

    // Status Pill
    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        width: 100
        height: 28
        radius: Theme.radiusFull
        color: Audio.sinkMuted
            ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.15)
            : Qt.rgba(Colors.tertiary.r, Colors.tertiary.g, Colors.tertiary.b, 0.15)
        border.color: Audio.sinkMuted ? Colors.error : Colors.tertiary
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: Audio.sinkMuted ? "MUTED" : "UNMUTED"
            color: Audio.sinkMuted ? Colors.error : Colors.tertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            font.weight: Theme.fontWeightBold
        }
    }

    Item { Layout.fillHeight: true }
}
