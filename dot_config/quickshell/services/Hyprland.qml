// services/Hyprland.qml — Hyprland IPC service
// Wraps the Hyprland singleton and exposes clean properties for:
//   - Workspaces (bar WorkspacePill)
//   - Toplevels / active window (bar AppIconsPill, launcher, background)
//   - Focused monitor (single monitor setup, but correct for multi too)
//   - dispatch() convenience wrapper (settings, keybind actions)

import Quickshell
import Quickshell.Hyprland as Hy
import QtQuick

Singleton {
    id: root

    // ── Workspaces ────────────────────────────────────────────────────────

    // All workspaces sorted by id (Hyprland already sorts them this way)
    readonly property var workspaces: Hy.Hyprland.workspaces

    // Currently focused workspace
    readonly property var focusedWorkspace: Hy.Hyprland.focusedWorkspace

    // Focused workspace id — convenience for the workspace pill
    readonly property int focusedWorkspaceId: focusedWorkspace ? focusedWorkspace.id : -1

    // Focused workspace name
    readonly property string focusedWorkspaceName: focusedWorkspace ? focusedWorkspace.name : ""

    // Switch to a workspace by id
    function gotoWorkspace(id) {
        dispatch("workspace " + id)
    }

    // Switch to a workspace by name
    function gotoWorkspaceName(name) {
        dispatch("workspace name:" + name)
    }

    // Move active window to workspace
    function moveToWorkspace(id) {
        dispatch("movetoworkspace " + id)
    }

    // ── Monitor ───────────────────────────────────────────────────────────
    // Single monitor setup — focusedMonitor is always the one we care about.

    readonly property var focusedMonitor: Hy.Hyprland.focusedMonitor
    readonly property var monitors:       Hy.Hyprland.monitors

    // ── Toplevels ─────────────────────────────────────────────────────────

    // All toplevels across all workspaces
    readonly property var toplevels: Hy.Hyprland.toplevels

    // Currently active (focused) toplevel — may be null
    readonly property var activeToplevel: Hy.Hyprland.activeToplevel

    // Active window title — for bar or launcher display
    readonly property string activeTitle: activeToplevel ? activeToplevel.title : ""

    // Active window class — derived from lastIpcObject since there's no
    // dedicated property; used for app icon lookup in AppIconsPill.
    // Falls back to empty string safely.
    readonly property string activeClass: {
        if (!activeToplevel) return ""
        var obj = activeToplevel.lastIpcObject
        return obj ? (obj["class"] || "") : ""
    }

    // Toplevels on the focused workspace only — for AppIconsPill and
    // DesktopClock visibility (background layer hides clock when windows exist)
    readonly property var focusedWorkspaceToplevels: {
        if (!focusedWorkspace) return []
        return focusedWorkspace.toplevels
    }

    readonly property bool hasWindows: {
        if (!focusedWorkspace) return false
        return focusedWorkspace.toplevels.count > 0
    }

    // Focus a toplevel by address
    function focusWindow(address) {
        dispatch("focuswindow address:" + address)
    }

    // Focus a toplevel by class
    function focusWindowClass(cls) {
        dispatch("focuswindow class:" + cls)
    }

    // ── Lua mode ──────────────────────────────────────────────────────────
    // Exposed so settings/binds code can branch on dispatcher syntax if needed.

    readonly property bool usingLua: Hy.Hyprland.usingLua

    // ── Dispatch ──────────────────────────────────────────────────────────
    // Central point for all hyprland dispatcher calls.
    // Usage: HyprlandService.dispatch("killactive")
    //        HyprlandService.dispatch("exec kitty")

    function dispatch(request) {
        Hy.Hyprland.dispatch(request)
    }

    // Batch dispatch — fire multiple dispatchers in sequence
    function dispatchAll(requests) {
        for (var i = 0; i < requests.length; i++) {
            Hy.Hyprland.dispatch(requests[i])
        }
    }

    // ── Raw event passthrough ─────────────────────────────────────────────
    // Re-emits rawEvent for any component that needs to react to IPC events
    // not covered by the typed properties above.

    signal rawEvent(var event)

    Connections {
        target: Hy.Hyprland
        function onRawEvent(event) {
            root.rawEvent(event)
        }
    }

    // ── Refresh helpers ───────────────────────────────────────────────────
    // Call these if you suspect state is stale (e.g. after external hyprctl calls).

    function refreshWorkspaces() { Hy.Hyprland.refreshWorkspaces() }
    function refreshToplevels()  { Hy.Hyprland.refreshToplevels()  }
    function refreshMonitors()   { Hy.Hyprland.refreshMonitors()   }

    // ── Debug ─────────────────────────────────────────────────────────────
    Component.onCompleted: {
        console.log("Hyprland: service ready — lua mode:", usingLua)
        console.log("Hyprland: workspaces:", workspaces.count,
                    "| focused:", focusedWorkspaceName)
    }
}
