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
        if (id > focusedWorkspaceId) {
            Hy.Hyprland.dispatch("hl.animation({leaf='workspacesIn',  enabled=true, speed=5, bezier='loft',     style='slidefade right 15%'})")
            Hy.Hyprland.dispatch("hl.animation({leaf='workspacesOut', enabled=true, speed=5, bezier='throwOut', style='slidefade right 15%'})")
        } else {
            Hy.Hyprland.dispatch("hl.animation({leaf='workspacesIn',  enabled=true, speed=5, bezier='loft',     style='slidefade left 15%'})")
            Hy.Hyprland.dispatch("hl.animation({leaf='workspacesOut', enabled=true, speed=5, bezier='throwOut', style='slidefade left 15%'})")
        }
        var vals = workspaces.values || []
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].id === id) { vals[i].activate(); return }
        }
        Hy.Hyprland.dispatch("workspace " + id)
    }

    function gotoWorkspaceName(name) {
        var vals = workspaces.values || []
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].name === name) { vals[i].activate(); return }
        }
        if (usingLua) Hy.Hyprland.dispatch("hl.dsp.focus({workspace = '" + name + "'})")
        else Hy.Hyprland.dispatch("workspace " + name)
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

    readonly property var focusedWorkspaceToplevels: (focusedWorkspace && focusedWorkspace.toplevels) ? focusedWorkspace.toplevels.values : []
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
        Qt.callLater(function() {
            var vals = workspaces.values || []
            console.log("Hyprland: workspaces:", vals.length,
                        "| focused:", focusedWorkspaceName,
                        "| active:", activeTitle)
            for (var i = 0; i < vals.length; i++) {
                var ws = vals[i]
                console.log("  Workspace", i, ":", ws.name, "(id:", ws.id + ")")
            }
        })
    }
}