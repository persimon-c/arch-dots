import QtQuick
import Quickshell
import "../state"

Item {
    id: root

    property string query: ""
    property int selectedIndex: 0
    property var allApps: []
    property var filteredApps: []
    property int columns: 5 // Grid columns count

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            updateAppsList();
        }
    }

    Component.onCompleted: {
        updateAppsList();
    }

    function updateAppsList() {
        const apps = Array.from(DesktopEntries.applications.values);
        const unique = new Map();
        
        const hiddenApps = new Set([
            "bssh", "bvnc", "avahi-discover", // Avahi
            "assistant", "designer", "linguist", "qdbusviewer", "qv4l2", "qvidcap", // Qt Tools
            "lstopo", "rofi-theme-selector", "xfce4-about" // Utilities
        ]);

        for (const app of apps) {
            if (app.noDisplay) continue;
            if (hiddenApps.has(app.id)) continue;

            if (!unique.has(app.id)) {
                unique.set(app.id, app);
            }
        }

        const sorted = Array.from(unique.values()).sort((a, b) => {
            return a.name.localeCompare(b.name);
        });

        root.allApps = sorted;
        filterApps();
    }

    onQueryChanged: {
        filterApps();
        selectedIndex = 0;
    }

    function filterApps() {
        const trimmed = query.trim().toLowerCase();
        if (trimmed === "") {
            root.filteredApps = root.allApps;
            return;
        }

        const filtered = root.allApps.filter(app => {
            const name = (app.name || "").toLowerCase();
            const id = (app.id || "").toLowerCase();
            const comment = (app.comment || "").toString().toLowerCase();
            const keywords = (app.keywords ? app.keywords.toString() : "").toLowerCase();
            return name.includes(trimmed) || id.includes(trimmed) || comment.includes(trimmed) || keywords.includes(trimmed);
        }).sort((a, b) => {
            const nameA = (a.name || "").toLowerCase();
            const nameB = (b.name || "").toLowerCase();
            const aStarts = nameA.startsWith(trimmed);
            const bStarts = nameB.startsWith(trimmed);
            if (aStarts && !bStarts) return -1;
            if (!aStarts && bStarts) return 1;
            return nameA.localeCompare(nameB);
        });

        root.filteredApps = filtered;
    }

    function moveUp() {
        const count = root.filteredApps.length;
        if (count === 0) return;
        let nextIndex = selectedIndex - columns;
        if (nextIndex < 0) {
            const remainder = selectedIndex % columns;
            const lastRowStart = Math.floor((count - 1) / columns) * columns;
            nextIndex = lastRowStart + remainder;
            if (nextIndex >= count) {
                nextIndex = count - 1;
            }
        }
        selectedIndex = nextIndex;
    }

    function moveDown() {
        const count = root.filteredApps.length;
        if (count === 0) return;
        let nextIndex = selectedIndex + columns;
        if (nextIndex >= count) {
            nextIndex = selectedIndex % columns;
        }
        selectedIndex = nextIndex;
    }

    // Horizontal wrapping navigation
    function moveLeft() {
        const count = root.filteredApps.length;
        if (count === 0) return;
        selectedIndex = (selectedIndex - 1 + count) % count;
    }

    function moveRight() {
        const count = root.filteredApps.length;
        if (count === 0) return;
        selectedIndex = (selectedIndex + 1) % count;
    }

    function executeSelected() {
        const count = root.filteredApps.length;
        if (count === 0 || selectedIndex < 0 || selectedIndex >= count) return;
        const app = root.filteredApps[selectedIndex];
        if (app && app.execute) {
            app.execute();
            SessionState.launcherVisible = false;
            reset();
        }
    }

    function reset() {
        query = "";
        selectedIndex = 0;
    }
}
