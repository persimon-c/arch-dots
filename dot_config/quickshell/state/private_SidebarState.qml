// state/SidebarState.qml — Sidebar panel UI state

pragma Singleton

import Quickshell

Singleton {
    property bool leftOpen:  false
    property bool rightOpen: false

    // Quick Settings toggles (in-memory state with shell command stubs)
    property bool nightLight: false
    property bool caffeine:   false
    property bool dnd:        false
    property bool darkMode:   false

    function toggleNightLight() {
        nightLight = !nightLight
        // Stub: run shell commands here if desired, e.g.:
        // Quickshell.execDetached(["hyprshade", "toggle", "blue-light"])
        console.log("Night Light toggled:", nightLight)
    }

    function toggleCaffeine() {
        caffeine = !caffeine
        // Stub: run shell commands here if desired
        console.log("Caffeine toggled:", caffeine)
    }

    function toggleDnd() {
        dnd = !dnd
        // Stub: run shell commands here if desired
        console.log("DND toggled:", dnd)
    }

    function toggleDarkMode() {
        darkMode = !darkMode
        // Stub: run shell commands here if desired
        console.log("Dark Mode toggled:", darkMode)
    }

    function showLeft() {
        SessionState.closeAllPopups()
        leftOpen = true
    }
    function showRight() {
        SessionState.closeAllPopups()
        rightOpen = true
    }
    function hideAll() { leftOpen = false; rightOpen = false }
    function hideLeft()  { leftOpen  = false }
    function hideRight() { rightOpen = false }
    function toggleLeft()  { if (leftOpen)  hideLeft();  else showLeft()  }
    function toggleRight() { if (rightOpen) hideRight(); else showRight() }
}
