// state/MediaState.qml — Media popup UI state

pragma Singleton

import Quickshell

Singleton {
    property bool popupVisible: false

    function show() {
        SessionState.closeAllPopups()
        popupVisible = true
    }
    function hide() { popupVisible = false }
    function toggle() { if (popupVisible) hide(); else show() }
}
