// Service: osdservice — implemented 2026-06-17
// services/OsdService.qml
// OSD aggregator — data only, no UI, no timers.
//
// Watches Audio, Brightness, and Hyprland IPC for changes that should
// trigger an on-screen display. Exposes a single `activeOsd` object and
// emits `osdTriggered` whenever a new OSD should appear.
//
// Osd.qml (Phase QS7) binds to `osdTriggered` and owns all dismiss logic.
//
// OSD types:
//   "volume"      — sink volume changed (not from mute toggle)
//   "mute"        — sink mute state toggled
//   "brightness"  — display brightness changed
//   "capslock"    — caps lock toggled (via Hyprland keybind → IpcHandler)
//   "layout"      — keyboard layout changed (via Hyprland IPC activelayout event)
//
// Caps lock note:
//   Hyprland does not emit a caps lock IPC event from socket2. The state is
//   exposed via `hyprctl devices` but there is no push notification.
//   Solution: add a Hyprland keybind that calls `qs ipc osd capslock <state>`
//   on Caps_Lock press. OsdService listens via IpcHandler. See binds.lua note below.
//
//   Required entry in modules/binds.lua:
//     bind = , Caps_Lock, exec, qs ipc --instance quickshell osd capslock on
//     bind = SHIFT, Caps_Lock, exec, qs ipc --instance quickshell osd capslock off
//   (or use a toggle script that reads current state from hyprctl devices)
//
// Layout note:
//   activelayout>>KEYBOARDNAME,LAYOUTNAME
//   parse(2) gives [keyboardName, layoutName] — keyboard name is ignored,
//   only layoutName is surfaced to the OSD.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    // ── Signal ────────────────────────────────────────────────────────────────
    // Emitted whenever a new OSD should be shown or updated.
    // Osd.qml connects to this and resets its dismiss timer on each emission.

    signal osdTriggered(var osd)

    // ── Active OSD state ──────────────────────────────────────────────────────
    // Last triggered OSD. Osd.qml reads this after osdTriggered fires.
    //
    // Shape:
    //   { type: string, value: real, max: real, icon: string, label: string }
    //
    // type      — one of: "volume" | "mute" | "brightness" | "capslock" | "layout"
    // value     — 0.0–1.0 fill fraction for bar OSDs (volume, brightness); 0|1 for toggle OSDs
    // max       — always 1.0 (reserved for future non-100% max brightness)
    // icon      — icon name string for OSD display
    // label     — human-readable string (layout name, "Caps Lock On/Off", etc.)

    readonly property var activeOsd: _activeOsd
    property var _activeOsd: ({ type: "", value: 0, max: 1.0, icon: "", label: "" })

    // ── Caps lock state ───────────────────────────────────────────────────────
    // Maintained here so Osd.qml and bar indicators can read it without
    // needing their own IPC handler.

    property bool capsLockOn: false

    property alias ipchandler: ipc

    // ── Layout state ──────────────────────────────────────────────────────────

    property string activeLayout: ""

    // ── Volume watcher ────────────────────────────────────────────────────────
    // Watches Audio.sinkVolumeInt and Audio.sinkMuted.
    // Volume changes trigger "volume" OSD.
    // Mute toggles trigger "mute" OSD.
    // Both can fire on the same action (e.g. muting also changes effective volume),
    // so mute is checked first — if sinkMuted just changed, emit "mute" and skip "volume".

    property int  _lastVolumeInt: -1
    property bool _lastMuted:     false
    property bool _audioReady:    false

    Connections {
        target: Audio

        function onSinkMutedChanged() {
            if (!root._audioReady) return
            const muted = Audio.sinkMuted
            if (muted === root._lastMuted) return
            root._lastMuted = muted
            root._emit({
                type:  "mute",
                value: muted ? 0.0 : Audio.sinkVolume,
                max:   1.0,
                icon:  muted ? "audio-volume-muted-symbolic" : _volumeIcon(Audio.sinkVolumeInt),
                label: muted ? "Muted" : "Unmuted"
            })
        }

        function onSinkVolumeIntChanged() {
            if (!root._audioReady) return
            const v = Audio.sinkVolumeInt
            if (v === root._lastVolumeInt) return
            root._lastVolumeInt = v
            // Skip volume OSD if mute state is also changing this tick —
            // the mute handler fires first and takes priority.
            if (Audio.sinkMuted !== root._lastMuted) return
            root._emit({
                type:  "volume",
                value: Audio.sinkVolume,
                max:   1.0,
                icon:  Audio.sinkEffMuted ? "audio-volume-muted-symbolic" : _volumeIcon(v),
                label: v + "%"
            })
        }

        function onSinkReadyChanged() {
            if (Audio.sinkReady && !root._audioReady) {
                // Seed initial values without triggering OSD on startup.
                root._lastVolumeInt = Audio.sinkVolumeInt
                root._lastMuted     = Audio.sinkMuted
                root._audioReady    = true
                console.log("[OsdService] Audio ready — vol:", Audio.sinkVolumeInt + "%", "muted:", Audio.sinkMuted)
            }
        }
    }

    // ── Brightness watcher ────────────────────────────────────────────────────

    property int  _lastBrightnessInt: -1
    property bool _brightnessReady:   false

    Connections {
        target: Brightness

        function onPercentIntChanged() {
            if (!root._brightnessReady) return
            const v = Brightness.percentInt
            if (v === root._lastBrightnessInt) return
            root._lastBrightnessInt = v
            root._emit({
                type:  "brightness",
                value: Brightness.percent,
                max:   1.0,
                icon:  _brightnessIcon(v),
                label: v + "%"
            })
        }
    }

    // Seed brightness initial value after first load.
    // Brightness.qml uses watchChanges on a FileView, so it's ready at startup.

    // ── Hyprland IPC — activelayout ───────────────────────────────────────────
    // Fires on every keyboard layout change.

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name !== "activelayout") return
            // parse(2): [keyboardName, layoutName]
            // argumentCount=2 handles commas in keyboard names correctly.
            const parts = event.parse(2)
            if (!parts || parts.length < 2) return
            const layout = parts[1].trim()
            if (layout === root.activeLayout) return
            root.activeLayout = layout
            root._emit({
                type:  "layout",
                value: 0,
                max:   1.0,
                icon:  "input-keyboard-symbolic",
                label: layout
            })
        }
    }

    // ── IPC handler — capslock ────────────────────────────────────────────────
    // Hyprland binds.lua calls:
    //   bind = , Caps_Lock, exec, qs ipc --instance quickshell osd capslock toggle
    //
    // The IpcHandler receives the message and updates capsLockOn.

    IpcHandler {
        id: ipc
        target: "osd"

        function capslock(state: string) {
            // state: "on" | "off" | "toggle"
            let newState
            if (state === "toggle") {
                newState = !root.capsLockOn
            } else {
                newState = (state === "on")
            }
            if (newState === root.capsLockOn) return
            root.capsLockOn = newState
            root._emit({
                type:  "capslock",
                value: newState ? 1.0 : 0.0,
                max:   1.0,
                icon:  newState ? "input-caps-lock-symbolic" : "input-keyboard-symbolic",
                label: newState ? "Caps Lock On" : "Caps Lock Off"
            })
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    function _emit(osd) {
        root._activeOsd = osd
        root.osdTriggered(osd)
        console.log("[OsdService] OSD triggered — type:", osd.type, "| label:", osd.label)
    }

    function _volumeIcon(pct) {
        if (pct === 0)   return "audio-volume-muted-symbolic"
        if (pct < 33)    return "audio-volume-low-symbolic"
        if (pct < 66)    return "audio-volume-medium-symbolic"
        return "audio-volume-high-symbolic"
    }

    function _brightnessIcon(pct) {
        if (pct < 33)    return "display-brightness-low-symbolic"
        if (pct < 66)    return "display-brightness-medium-symbolic"
        return "display-brightness-high-symbolic"
    }

    // ── Startup log ───────────────────────────────────────────────────────────

    Component.onCompleted: {
        // Seed audio if it is already ready at startup
        if (Audio.sinkReady) {
            root._lastVolumeInt = Audio.sinkVolumeInt
            root._lastMuted     = Audio.sinkMuted
            root._audioReady    = true
            console.log("[OsdService] Audio seeded on startup — vol:", Audio.sinkVolumeInt + "%", "muted:", Audio.sinkMuted)
        }

        // Seed brightness unconditionally
        root._lastBrightnessInt = Brightness.percentInt
        root._brightnessReady   = true
        console.log("[OsdService] Brightness seeded unconditionally —", Brightness.percentInt + "%")

        console.log("[OsdService] Initialized")
        console.log("[OsdService]   Watching: volume, mute, brightness, capslock (IPC), layout (Hyprland event)")
    }
}
