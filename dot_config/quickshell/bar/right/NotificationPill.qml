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
        icon: Notifications.totalCount > 0 ? "󰂚" : "󰂜"
        label: Notifications.totalCount > 0 ? Notifications.totalCount + "" : ""
        showLabel: Notifications.totalCount > 0
        backgroundColor: PanelColors.pillNotif
        foregroundColor: PanelColors.pillTextNotif
        borderColor: "transparent"
        minWidth: Notifications.totalCount > 0 ? 56 : 34

        onClicked: NotificationState.toggle()
    }
}