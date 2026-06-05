// services/Clipboard.qml
// Clipboard history service — data only, no UI.
//
// Responsibilities:
//   - Loads cliphist history into a ListModel via `cliphist list`
//   - Watches the cliphist DB file for changes via inotifywait → auto-reload
//   - Exposes paste, delete, wipe, and search operations
//   - Calls cliphist-decode.sh for paste (handles text/image split there)
//
// ListModel entry shape:
//   { id: string, preview: string, isImage: bool }
//   isImage is always false for now — deferred to Phase QS12.
//
// Dependencies:
//   - cliphist
//   - wl-copy  (called by cliphist-decode.sh)
//   - inotify-tools (inotifywait)
//   - file (from file/libmagic — for MIME detection in decode script)
//   - wl-paste --watch cliphist store  must be running (managed by autostart.lua)
//
// DB path:  $XDG_CACHE_HOME/cliphist/db  (default: ~/.cache/cliphist/db)
// Note: inotifywait watches the db file's parent directory because the db
//       file is replaced atomically by cliphist (rename), which inotifywait
//       on the file itself would miss after the first write.

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Public state ──────────────────────────────────────────────────────────

    // ListModel entries: { id: string, preview: string, isImage: bool }
    readonly property ListModel entries: ListModel { id: entryModel }

    // True while a cliphist list reload is running.
    property bool isLoading: false

    // Search filter — set this from UI to filter visible entries.
    // Filtering is done client-side in the UI's DelegateModel/ProxyModel.
    // The service exposes the full unfiltered list; UI applies fuzzysort.
    property string searchQuery: ""

    // ── Public API ────────────────────────────────────────────────────────────

    // Paste an entry by its list-line string ("id\tpreview").
    // Calls cliphist-decode.sh which copies to clipboard via wl-copy.
    // exitCode 0 = success, 2 = skipped (image, not an error), other = error.
    function pasteEntry(line) {
        if (line.length === 0) return
        console.log("[Clipboard] Pasting entry:", line.substring(0, 40))
        decodeProcess.command = [
            "/bin/bash",
            _scriptPath,
            line
        ]
        decodeProcess.running = true
    }

    // Delete a single entry by its list-line string.
    function deleteEntry(line) {
        if (line.length === 0) return
        console.log("[Clipboard] Deleting entry:", line.substring(0, 40))
        deleteProcess.command = [
            "/bin/bash", "-c",
            "printf '%s' " + _shellQuote(line) + " | cliphist delete"
        ]
        deleteProcess.running = true
    }

    // Delete entry by id directly (convenience for UI).
    function deleteById(id) {
        const idx = _indexOfId(id)
        if (idx < 0) return
        const entry = entryModel.get(idx)
        deleteEntry(id + "\t" + entry.preview)
    }

    // Wipe entire history.
    function wipeHistory() {
        console.log("[Clipboard] Wiping history")
        wipeProcess.running = true
    }

    // Force a manual reload (e.g. when clipboard panel opens).
    function reload() {
        _load()
    }

    // ── Paths ─────────────────────────────────────────────────────────────────

    readonly property string _dbDir: {
        const xdgCache = StandardPaths.writableLocation(StandardPaths.CacheLocation)
            .toString().replace(/\/quickshell$/, "")   // QS appends its own name; strip it
        return xdgCache + "/cliphist"
    }

    readonly property string _dbPath: root._dbDir + "/db"

    readonly property string _scriptPath: {
        const home = StandardPaths.writableLocation(StandardPaths.HomeLocation)
        return home + "/.config/quickshell/scripts/cliphist-decode.sh"
    }

    // ── DB watcher (inotifywait) ──────────────────────────────────────────────
    // Watches the cliphist db directory for CLOSE_WRITE/MOVED_TO events.
    // cliphist writes the db atomically (temp file + rename), so watching
    // the directory for MOVED_TO catches every write reliably.

    Process {
        id: watchProcess
        command: [
            "inotifywait",
            "--monitor",
            "--quiet",
            "--event", "moved_to",
            "--event", "close_write",
            "--format", "%f",
            root._dbDir
        ]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                // Only react to the db file itself, not unrelated files.
                if (line.trim() === "db") {
                    reloadDebounce.restart()
                }
            }
        }

        onExited: function(code) {
            if (code !== 0) {
                console.warn("[Clipboard] inotifywait exited with code", code, "— retrying in 5s")
                watchRestartTimer.start()
            }
        }
    }

    Timer {
        id: watchRestartTimer
        interval: 5000
        repeat: false
        onTriggered: watchProcess.running = true
    }

    // Debounce — cliphist may write multiple times quickly on large pastes.
    Timer {
        id: reloadDebounce
        interval: 150
        repeat: false
        onTriggered: root._load()
    }

    // ── History loader ────────────────────────────────────────────────────────

    Process {
        id: listProcess
        command: ["cliphist", "list"]

        stdout: SplitParser {
            onRead: function(line) {
                const trimmed = line.trim()
                if (trimmed.length === 0) return

                // Format: "<id>\t<preview>"
                const tabIdx = trimmed.indexOf("\t")
                if (tabIdx < 0) return

                const id      = trimmed.substring(0, tabIdx)
                const preview = trimmed.substring(tabIdx + 1)

                entryModel.append({
                    "id":      id,
                    "preview": preview,
                    "isImage": false    // Phase QS12: detect via MIME prefix in preview
                })
            }
        }

        onExited: function(code) {
            root.isLoading = false
            if (code !== 0) {
                console.warn("[Clipboard] cliphist list exited with code", code)
            } else {
                console.log("[Clipboard] Loaded", entryModel.count, "entries")
            }
        }
    }

    // ── Paste process ─────────────────────────────────────────────────────────

    Process {
        id: decodeProcess
        onExited: function(code) {
            if (code === 0) {
                console.log("[Clipboard] Paste successful")
            } else if (code === 2) {
                console.log("[Clipboard] Entry skipped (image/binary — Phase QS12)")
            } else {
                console.warn("[Clipboard] cliphist-decode.sh exited with code", code)
            }
        }
    }

    // ── Delete process ────────────────────────────────────────────────────────

    Process {
        id: deleteProcess
        onExited: function(code) {
            if (code === 0) {
                // Reload will fire from inotifywait naturally.
                // Belt-and-suspenders: if it doesn't within 300ms, force reload.
                deleteReloadTimer.start()
            } else {
                console.warn("[Clipboard] cliphist delete exited with code", code)
            }
        }
    }

    Timer {
        id: deleteReloadTimer
        interval: 300
        repeat: false
        onTriggered: root._load()
    }

    // ── Wipe process ──────────────────────────────────────────────────────────

    Process {
        id: wipeProcess
        command: ["cliphist", "wipe"]
        onExited: function(code) {
            if (code === 0) {
                entryModel.clear()
                console.log("[Clipboard] History wiped")
            } else {
                console.warn("[Clipboard] cliphist wipe exited with code", code)
            }
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    function _load() {
        root.isLoading = true
        entryModel.clear()
        listProcess.running = true
    }

    function _indexOfId(id) {
        for (let i = 0; i < entryModel.count; i++) {
            if (entryModel.get(i).id === id) return i
        }
        return -1
    }

    // Minimal shell quoting for single argument — wraps in single quotes,
    // escapes any single quotes inside the string.
    function _shellQuote(s) {
        return "'" + s.replace(/'/g, "'\\''") + "'"
    }

    // ── Init ──────────────────────────────────────────────────────────────────

    Component.onCompleted: {
        console.log("[Clipboard] Initialized")
        console.log("[Clipboard]   DB dir:    ", root._dbDir)
        console.log("[Clipboard]   DB path:   ", root._dbPath)
        console.log("[Clipboard]   Script:    ", root._scriptPath)
        root._load()
    }
}
