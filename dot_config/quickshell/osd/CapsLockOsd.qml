// osd/CapsLockOsd.qml
// Visual sub-component for caps lock changes in OSD.
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
            : Quickshell.iconPath("input-keyboard-symbolic")
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

    // Status Badge
    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        width: 100
        height: 28
        radius: Theme.radiusFull
        color: OsdService.capsLockOn
            ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.15)
            : Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.15)
        border.color: OsdService.capsLockOn ? Colors.error : Colors.outline
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: OsdService.capsLockOn ? "ON" : "OFF"
            color: OsdService.capsLockOn ? Colors.error : PanelColors.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            font.weight: Theme.fontWeightBold
        }
    }

    Item { Layout.fillHeight: true }
}
