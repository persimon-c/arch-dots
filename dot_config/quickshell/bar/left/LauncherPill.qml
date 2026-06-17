import QtQuick
import "../../components"
import "../../theme"
import "../../state"

Pill {
    id: root
    
    // 28x28 rounded square matching workspaces
    implicitWidth: 28
    implicitHeight: 28
    radius: 5
    bgColor: PanelColors.pillArch
    bgOpacity: 0.85

    horizontalPadding: 0
    verticalPadding: 0

    // Wrapper Item so Pill has exactly one visual child
    Item {
        anchors.fill: parent

        Text {
            id: iconText
            text: "󰣇" // Nerd Font Arch Linux logo icon
            color: PanelColors.pillTextArch
            font.family: Theme.fontFamily
            font.pixelSize: 19
            font.weight: Theme.fontWeightBold
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: SidebarState.toggleLeft()
        }
    }
}
