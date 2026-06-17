// state/SessionState.qml — Global popup coordinator
// Every pill calls SessionState.closeAllPopups() before opening its own popup.
// This ensures only one popup is ever visible at a time.

pragma Singleton

import Quickshell
import Quickshell.Io
import "../services"

Singleton {
    id: root

    // ── Popup open flags ──────────────────────────────────────────────────
    // Each pill sets its own flag via its State singleton.
    // SessionState doesn't own these — it just calls closeAll.

    // ── Panel visibility ──────────────────────────────────────────────────

    property bool launcherVisible:       false
    property bool sessionVisible:          false
    property bool leftSidebarOpen:         false
    property bool rightSidebarOpen:        false
    property bool wallpaperPickerVisible:  false
    property bool clipboardVisible:          false

    IpcHandler {
        target: "launcher"
        function toggle() {
            if (root.launcherVisible) {
                root.launcherVisible = false;
            } else {
                root.closeAllPopups();
                root.launcherVisible = true;
            }
        }
    }

    // ── closeAllPopups ────────────────────────────────────────────────────
    // Call this before opening ANY popup or panel.

    function closeAllPopups() {
        AudioState.popupVisible       = false
        BrightnessState.popupVisible  = false
        BluetoothState.popupVisible   = false
        NetworkState.popupVisible     = false
        BatteryState.popupVisible     = false
        ClockState.calendarVisible    = false
        MediaState.popupVisible       = false
        NotificationState.centerVisible = false
        root.sessionVisible           = false
        root.launcherVisible          = false
        root.wallpaperPickerVisible   = false
        root.clipboardVisible          = false
        root.leftSidebarOpen          = false
        root.rightSidebarOpen         = false
        SidebarState.leftOpen = false
        SidebarState.rightOpen = false

        // Clear active dropdown
        DropdownState.closeAll()
    }
}
