import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland as Hy
import "../../components"
import "../../theme"
import "../../services"

Row {
    id: root
    spacing: 6

    function _workspaceLabel(workspace) {
        if (!workspace) return ""
        if (workspace.name && workspace.name.length > 0) return workspace.name
        return String(workspace.id)
    }

    Repeater {
        model: Hyprland.workspaces

        delegate: Pill {
            required property var modelData

            readonly property bool active: Hyprland.focusedWorkspaceId === modelData.id
            readonly property bool occupied: modelData.toplevels && modelData.toplevels.count > 0

            readonly property var activeBgColors: [Colors.primary, Colors.secondary, Colors.tertiary]
            readonly property var activeTextColors: ["#000000", "#000000", "#000000"]

            readonly property int colorIdx: (modelData.id - 1) >= 0 ? (modelData.id - 1) % activeBgColors.length : index % activeBgColors.length

            // 28x28 rounded squares
            implicitWidth: 28
            implicitHeight: 28
            radius: 5

            bgColor: active
                ? activeBgColors[colorIdx]
                : Colors.surfaceContainerHighest

            bgOpacity: 0.85

            horizontalPadding: 0
            verticalPadding: 0

            // Wrapper Item so Pill has exactly one visual child
            Item {
                anchors.fill: parent

                Text {
                    anchors.centerIn: parent
                    text: root._workspaceLabel(modelData)
                    color: active
                        ? activeTextColors[colorIdx]
                        : Colors.outline
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: Theme.fontSizeSm
                    font.weight: Theme.fontWeightBold
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.gotoWorkspace(modelData.id)
                }
            }
        }
    }
}
