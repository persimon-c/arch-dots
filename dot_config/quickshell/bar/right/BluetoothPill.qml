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
        icon: "󰂯"
        label: Bluetooth.label
        showLabel: Bluetooth.connectedCount > 0
        backgroundColor: Bluetooth.enabled ? PanelColors.pillBluetooth : "#5d6495"
        foregroundColor: PanelColors.pillTextBluetooth
        borderColor: "transparent"
        minWidth: 34
        maxWidth: 180

        onClicked: BluetoothState.toggle()
    }

    // ── Dropdown ──────────────────────────────────────────────────────────
    BluetoothDropdown {
        open:       BluetoothState.popupVisible
        anchorItem: pill
    }
}