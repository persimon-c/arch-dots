import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    property string icon: ""
    property string label: ""
    property color backgroundColor: "#e8e2c6"
    property color foregroundColor: "#1f1b17"
    property color borderColor: "#2c2722"
    property bool showLabel: true
    property real minWidth: 0
    property real maxWidth: 0
    property int iconSize: Theme.fontSizeMd
    property int labelSize: Theme.fontSizeSm
    property real horizontalPadding: 4
    property real verticalPadding: 2
    property real gap: Theme.spacingXs

    signal clicked()

    implicitWidth:  root.maxWidth > 0
                        ? Math.min(root.maxWidth, Math.max(minWidth, chip.implicitWidth))
                        : Math.max(minWidth, chip.implicitWidth)
    implicitHeight: chip.implicitHeight

    Rectangle {
        id: chip
        anchors.fill: parent
        radius: 5
        color: root.backgroundColor
        border.width: 0

        implicitWidth:  content.implicitWidth + root.horizontalPadding * 2
        implicitHeight: content.implicitHeight + root.verticalPadding * 2

        RowLayout {
            id: content
            anchors.centerIn: parent
            spacing: root.gap

            Text {
                text: root.icon
                color: root.foregroundColor
                font.family: Theme.fontFamily
                font.pixelSize: root.iconSize
                font.weight: Theme.fontWeightBold
            }

            Text {
                visible: root.showLabel && root.label !== ""
                text: root.label
                color: root.foregroundColor
                font.family: Theme.fontFamily
                font.pixelSize: root.labelSize
                font.weight: Theme.fontWeightSemiBold
                elide: Text.ElideRight
                Layout.maximumWidth: root.maxWidth > 0
                    ? (root.maxWidth - root.horizontalPadding * 2 - root.iconSize - root.gap - 8)
                    : 1000
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}