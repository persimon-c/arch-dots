import QtQuick
import "../../theme"
import "../../services"
import "../../components"
import "../../state"

Item {
    id: root

    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    StatusChip {
        id:      pill
        icon:    Network.connectionType === "wired" ? "󰈀" : !Network.wifiEnabled ? "󰤮" : "󰤨"
        label:   Network.label
        showLabel: Network.isConnected
        backgroundColor: Network.isConnected ? PanelColors.pillNetwork : "#685d8d"
        foregroundColor: PanelColors.pillTextNetwork
        borderColor: "transparent"

        onClicked: NetworkState.toggle()
        minWidth: 34
        maxWidth: 180
    }

    NetworkDropdown {
        open:       NetworkState.popupVisible
        anchorItem: pill
    }
}
