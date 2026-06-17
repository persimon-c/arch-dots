import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../components"
import "../../theme"
import "../../services"

Row {
    id: root
    spacing: 6
    visible: Hyprland.focusedWorkspaceToplevels && Hyprland.focusedWorkspaceToplevels.length > 0

    function _getIcon(toplevel) {
        if (!toplevel || !toplevel.lastIpcObject) return ""
        var cls = toplevel.lastIpcObject.class || toplevel.lastIpcObject.appId || ""
        return cls.toLowerCase()
    }

    Repeater {
        model: Hyprland.focusedWorkspaceToplevels

        delegate: Pill {
            required property var modelData
            required property int index

            readonly property var bgColors: [Colors.primaryContainer, Colors.secondaryContainer, Colors.tertiaryContainer]

            // 28x28 rounded squares matching the workspaces
            implicitWidth: 28
            implicitHeight: 28
            radius: 5

            bgColor: bgColors[index % bgColors.length]
            bgOpacity: 0.85

            horizontalPadding: 0
            verticalPadding: 0

            IconImage {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: Quickshell.iconPath(root._getIcon(modelData))
                smooth: true
            }
        }
    }
}
