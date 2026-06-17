// osd/LayoutOsd.qml
// Visual sub-component for keyboard layout changes in OSD.
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

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: "Keyboard Layout"
        color: PanelColors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSm
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: OsdService.activeOsd.label
        color: PanelColors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLg
        font.weight: Theme.fontWeightBold
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    Item { Layout.fillHeight: true }
}
