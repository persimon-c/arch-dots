// services/Brightness.qml — Brightness service
// Reads from sysfs via FileView (watchChanges) — zero polling, kernel-driven updates.
// Writes via brightnessctl (execDetached) — keeps brightnessctl as the system authority.
// The sysfs watcher picks up writes automatically regardless of source (keybind, slider, OSD).
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── Sysfs paths ───────────────────────────────────────────────────────

    readonly property string _backlightDir: "/sys/class/backlight/amdgpu_bl2/"

    // ── Max brightness — read once at startup ─────────────────────────────
    // max_brightness never changes, so blockLoading is safe and correct here.

    FileView {
        id: maxFile
        path: root._backlightDir + "max_brightness"
        blockLoading: true
        onLoadFailed: console.warn("Brightness: failed to read max_brightness")
    }

    readonly property int _maxRaw: {
        var v = parseInt(maxFile.text().trim(), 10)
        return isNaN(v) || v <= 0 ? 255 : v  // 255 sane fallback
    }

    // ── Current brightness — watch for changes ────────────────────────────

    FileView {
        id: brightnessFile
        path: root._backlightDir + "brightness"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root._update()
        onLoadFailed: console.warn("Brightness: failed to read brightness")
    }

    property int _currentRaw: 0

    function _update() {
        var v = parseInt(brightnessFile.text().trim(), 10)
        if (!isNaN(v)) root._currentRaw = v
    }

    // ── Public — read ─────────────────────────────────────────────────────

    // 0.0 – 1.0
    readonly property real percent: _maxRaw > 0 ? Math.max(0.0, Math.min(1.0, _currentRaw / _maxRaw)) : 0.0

    // 0 – 100 integer for display and slider
    readonly property int percentInt: Math.round(percent * 100)

    // ── Public — write ────────────────────────────────────────────────────
    // All writes go through brightnessctl so it remains the system authority.
    // The sysfs watcher picks up the result automatically — no manual sync needed.

    function setPercent(pct) {
        // pct: 0 – 100 integer
        var clamped = Math.max(1, Math.min(100, Math.round(pct)))
        Quickshell.execDetached(["brightnessctl", "set", clamped + "%"])
    }

    function raise(step) {
        // step: percent integer, default 5 (matches Hyprland keybinds)
        Quickshell.execDetached(["brightnessctl", "set", (step || 5) + "%+"])
    }

    function lower(step) {
        Quickshell.execDetached(["brightnessctl", "set", (step || 5) + "%-"])
    }

    // ── Debug ─────────────────────────────────────────────────────────────
    Component.onCompleted: {
        brightnessFile.reload()  // Force initial read
        console.log("Brightness: service ready — max:", _maxRaw,
                    "| current:", _currentRaw,
                    "| percent:", percentInt + "%")
    }
}
