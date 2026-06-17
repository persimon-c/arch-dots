import QtQuick
import "../../components"
import "../../theme"
import "../../state"

Item {
    id: root

    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    StatusChip {
        id: pill
        icon:            "⏻"
        backgroundColor: PanelColors.pillPower
        foregroundColor: PanelColors.pillTextPower
        borderColor:     "transparent"
        showLabel:       false
        minWidth:        34

        onClicked: {
            if (SessionState.sessionVisible) {
                SessionState.sessionVisible = false
            } else {
                SessionState.closeAllPopups()
                SessionState.sessionVisible = true
            }
        }
    }

    // ── Power / Session Dropdown ───────────────────────────────────────────
    PowerDropdown {
        open:       SessionState.sessionVisible
        anchorItem: pill
    }
}
