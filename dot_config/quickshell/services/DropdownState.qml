// Service: dropdownstate — implemented 2026-06-17
pragma Singleton
import QtQuick
import Quickshell
import "../state"

Singleton {
    id: root

    // Reference to the active dropdown instance, or null if none
    property var activeDropdown: null

    // Guard to prevent recursion between DropdownState and SessionState
    property bool _syncing: false

    onActiveDropdownChanged: {
        if (_syncing) return;
        if (activeDropdown !== null) {
            _syncing = true;
            // Close other UI elements like sidebars and popups
            SessionState.closeAllPopups();
            _syncing = false;
        }
    }

    function open(dropdown) {
        if (activeDropdown === dropdown) return;
        activeDropdown = dropdown;
    }

    function close(dropdown) {
        if (_syncing) return;
        if (activeDropdown === dropdown) {
            activeDropdown = null;
        }
    }

    function toggle(dropdown) {
        if (activeDropdown === dropdown) {
            close(dropdown);
        } else {
            open(dropdown);
        }
    }

    function closeAll() {
        if (_syncing) return;
        activeDropdown = null;
    }
}
