// osd/VolumeOsd.qml
// Visual sub-component for volume changes in OSD.
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
            : Quickshell.iconPath("audio-volume-medium-symbolic")
        sourceSize: Qt.size(64, 64)
        smooth: true
    }

    // Value text (e.g. "45%")
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: OsdService.activeOsd.label
        color: PanelColors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLg
        font.weight: Theme.fontWeightBold
    }

    Item { height: Theme.spacingXs }

    // Progress Bar
    Rectangle {
        Layout.fillWidth: true
        height: 6
        radius: Theme.radiusFull
        color: Qt.rgba(Colors.outlineVariant.r, Colors.outlineVariant.g, Colors.outlineVariant.b, 0.3)

        Rectangle {
            width: parent.width * Math.max(0.0, Math.min(1.0, OsdService.activeOsd.value))
            height: parent.height
            radius: parent.radius
            color: PanelColors.accent
            
            Behavior on width {
                NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            }
        }
    }

    Item { Layout.fillHeight: true }
}
