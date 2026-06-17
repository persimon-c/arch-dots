import QtQuick
import "../../components"
import "../../theme"
import "../../services"
import "../../state"

Item {
    id: root

    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    StatusChip {
        id: pill
        icon: "󰍛"
        label: System.ramPercent + "%"
        backgroundColor: Colors.tertiary
        foregroundColor: Colors.onTertiaryColor
        borderColor: "transparent"
        minWidth: 0

        onClicked: {
            if (SidebarState.leftOpen) {
                SidebarState.hideLeft()
            } else {
                SidebarState.showLeft()
            }
        }
    }
}
