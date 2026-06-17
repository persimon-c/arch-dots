import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../components"
import "../../theme"
import "../../state"

Pill {
    id: root
    visible: SystemTray.items.count > 0
    bgColor: PanelColors.pillTray
    bgOpacity: 0.15
    radius: 5
    horizontalPadding: 4
    verticalPadding: 2

    Row {
        id: row
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property SystemTrayItem modelData
                width: 20
                height: 20

                Image {
                    anchors.fill: parent
                    source: modelData.icon || ""
                    smooth: true
                    mipmap: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: (mouse) => {
                        modelData.activate()
                    }
                }
            }
        }
    }
}
