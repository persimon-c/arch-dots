// state/NotificationState.qml — Notification center UI state

pragma Singleton

import Quickshell

Singleton {
    property bool centerVisible: false

    function show() {
        SessionState.closeAllPopups()
        centerVisible = true
    }
    function hide() { centerVisible = false }
    function toggle() { if (centerVisible) hide(); else show() }
}
