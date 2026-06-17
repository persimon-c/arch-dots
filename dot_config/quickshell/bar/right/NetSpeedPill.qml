import QtQuick
import "../../components"
import "../../theme"
import "../../services"
import "../../state"

Item {
    id: root

    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    function shortenSpeed(str) {
        if (!str) return "0B/s"
        return str.replace(" KiB/s", "K/s")
                  .replace(" MiB/s", "M/s")
                  .replace(" GiB/s", "G/s")
                  .replace(" B/s", "B/s")
    }

    StatusChip {
        id: pill
        icon: "󰀂"
        label: " " + root.shortenSpeed(System.netRxStr) + "  " + root.shortenSpeed(System.netTxStr)
        backgroundColor: Colors.secondary
        foregroundColor: Colors.onSecondaryColor
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
