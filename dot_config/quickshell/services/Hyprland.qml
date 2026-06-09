// services/Hyprland.qml
pragma Singleton
import Quickshell
import Quickshell.Hyprland as Hy
import QtQuick

Singleton {
    id: root

    // ── Workspaces ────────────────────────────────────────────────────────

    readonly property var workspaces: Hy.Hyprland.workspaces
    readonly property var focusedWorkspace: Hy.Hyprland.focusedWorkspace
    readonly property int focusedWorkspaceId: focusedWorkspace ? focusedWorkspace.id : -1
    readonly property string focusedWorkspaceName: focusedWorkspace ? focusedWorkspace.name : ""

    function gotoWorkspace(id) {
        for (var i = 0; i < workspaces.count; i++) {
            var ws = workspaces.get(i)
            if (ws.id === id) { ws.activate(); return }
        }
    }

    function gotoWorkspaceName(name) {
        for (var i = 0; i < workspaces.count; i++) {
            var ws = workspaces.get(i)
            if (ws.name === name) { ws.activate(); return }
        }
    }

    function workspacePrev() {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.focus({workspace = 'prev'})")
        else
            Hy.Hyprland.dispatch("workspace prev")
    }

    function workspaceNext() {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.focus({workspace = 'next'})")
        else
            Hy.Hyprland.dispatch("workspace next")
    }

    function moveToWorkspace(id) {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.window.move({workspace = " + id + "})")
        else
            Hy.Hyprland.dispatch("movetoworkspace " + id)
    }

    function moveWindowToWorkspace(windowAddress, workspaceId) {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.window.move({workspace = " + workspaceId + ", window = 'address:" + windowAddress + "'})")
        else
            Hy.Hyprland.dispatch("movetoworkspacesilent " + workspaceId + ",address:" + windowAddress)
    }

    // ── Monitors ──────────────────────────────────────────────────────────

    readonly property var focusedMonitor: Hy.Hyprland.focusedMonitor
    readonly property var monitors: Hy.Hyprland.monitors

    function focusMonitor(nameOrId) {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.focus({monitor = '" + nameOrId + "'})")
        else
            Hy.Hyprland.dispatch("focusmonitor " + nameOrId)
    }

    // ── Toplevels & Clients ───────────────────────────────────────────────

    readonly property var toplevels: Hy.Hyprland.toplevels
    readonly property var activeToplevel: Hy.Hyprland.activeToplevel

    readonly property string activeTitle: activeToplevel ? activeToplevel.title : ""
    readonly property string activeAddress: activeToplevel ? activeToplevel.address : ""

    readonly property string activeClass: {
        if (!activeToplevel) return ""
        var obj = activeToplevel.lastIpcObject
        return obj ? (obj.class || obj.appId || "") : ""
    }

    readonly property var focusedWorkspaceToplevels: focusedWorkspace ? focusedWorkspace.toplevels : []
    readonly property bool hasWindows: focusedWorkspace ? focusedWorkspace.toplevels.count > 0 : false

    function focusWindow(address) {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.focus({window = 'address:" + address + "'})")
        else
            Hy.Hyprland.dispatch("focuswindow address:" + address)
    }

    function killActive() {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.window.close()")
        else
            Hy.Hyprland.dispatch("killactive")
    }

    function fullscreen() {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.window.fullscreen({})")
        else
            Hy.Hyprland.dispatch("fullscreen")
    }

    function toggleFloating() {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.window.float({})")
        else
            Hy.Hyprland.dispatch("togglefloating")
    }

    function centerWindow() {
        if (usingLua)
            Hy.Hyprland.dispatch("hl.dsp.window.center({})")
        else
            Hy.Hyprland.dispatch("centerwindow")
    }

    // ── Lua mode ──────────────────────────────────────────────────────────

    readonly property bool usingLua: Hy.Hyprland.usingLua

    function dispatch(request) { Hy.Hyprland.dispatch(request) }

    // ── Raw event passthrough ─────────────────────────────────────────────

    signal rawEvent(var event)

    Connections {
        target: Hy.Hyprland
        function onRawEvent(event) { root.rawEvent(event) }
    }

    // ── Refresh helpers ───────────────────────────────────────────────────

    function refreshWorkspaces() { Hy.Hyprland.refreshWorkspaces() }
    function refreshToplevels()  { Hy.Hyprland.refreshToplevels()  }
    function refreshMonitors()   { Hy.Hyprland.refreshMonitors()   }

    // ── Debug ─────────────────────────────────────────────────────────────

    Component.onCompleted: {
        console.log("Hyprland: service ready — lua mode:", usingLua)
        // workspaces.count may be 0 here as the model populates async
        Qt.callLater(function() {
            console.log("Hyprland: workspaces:", workspaces.count,
                        "| focused:", focusedWorkspaceName,
                        "| active:", activeTitle)
            for (var i = 0; i < workspaces.count; i++) {
                var ws = workspaces.get(i)
                console.log("  Workspace", i, ":", ws.name, "(id:", ws.id + ")")
            }
        })
    }
}