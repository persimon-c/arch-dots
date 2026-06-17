// state/ClockState.qml — Calendar popup UI state

pragma Singleton

import Quickshell

Singleton {
    property bool calendarVisible: false

    function show() {
        SessionState.closeAllPopups()
        calendarVisible = true
    }
    function hide() { calendarVisible = false }
    function toggle() { if (calendarVisible) hide(); else show() }
}
