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
        id:      pill
        icon:    Battery.isCharging ? "󰂄" : Battery.available && Battery.percentInt <= 15 ? "󰂎" : "󰁹"
        label:   Battery.available ? (Battery.percentInt + "%") : qsTr("AC")
        showLabel: true
        backgroundColor: Battery.isCharging ? "#f6c177" : Battery.available && Battery.percentInt <= 15 ? "#eb6f92" : PanelColors.pillBattery
        foregroundColor: PanelColors.pillTextBattery
        borderColor: "transparent"

        onClicked: BatteryState.toggle()
        minWidth: 0

    }

    // ── Dropdown ──────────────────────────────────────────────────────────
    BatteryDropdown {
        open:       BatteryState.popupVisible
        anchorItem: pill
    }
}
