import QtQuick
import "../../theme"
import "../../services"
import "../../components"
import "../../state"

Item {
    id: root

    property var anchorWindow: null

    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    StatusChip {
        id:      pill
        icon:    "󰃭"
        label:   Qt.formatDateTime(DateTime.date, "MMM d")
        backgroundColor: PanelColors.pillClock
        foregroundColor: PanelColors.pillTextClock
        borderColor: "transparent"
        showLabel: true

        minWidth: 90

        onClicked: ClockState.toggle()
    }

    CalendarDropdown {
        open:         ClockState.calendarVisible
        anchorItem:   pill
        anchorWindow: root.anchorWindow
    }
}
