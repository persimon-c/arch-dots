# Hyprland IPC — Socket2 Event Reference

Source: https://wiki.hypr.land/ (last updated June 5, 2026)

Hyprland exposes two UNIX sockets under `$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/`:

| Socket | Purpose |
|---|---|
| `.socket.sock` | hyprctl-like requests (write `[flag(s)]/command args`) |
| `.socket2.sock` | Live event stream (read-only) |

> **Warning:** Hyprland evaluates `.socket.sock` connections synchronously. An unclosed connection will freeze Hyprland until the 5-second timeout. Always open immediately before writing and close right after.

---

## Socket2 Event Format

```
EVENT>>DATA\n
```

Example: `workspace>>2`

In Quickshell, these are consumed via `HyprlandIpcEvent` / `IpcListener` (module `Quickshell.Hyprland`).

---

## Events List

### Workspace Events

| Event | Data | Description |
|---|---|---|
| `workspace` | `WORKSPACENAME` | Workspace changed (user request only, not mouse movement) |
| `workspacev2` | `WORKSPACEID,WORKSPACENAME` | Same, with ID |
| `createworkspace` | `WORKSPACENAME` | Workspace created |
| `createworkspacev2` | `WORKSPACEID,WORKSPACENAME` | Same, with ID |
| `destroyworkspace` | `WORKSPACENAME` | Workspace destroyed |
| `destroyworkspacev2` | `WORKSPACEID,WORKSPACENAME` | Same, with ID |
| `moveworkspace` | `WORKSPACENAME,MONNAME` | Workspace moved to different monitor |
| `moveworkspacev2` | `WORKSPACEID,WORKSPACENAME,MONNAME` | Same, with ID |
| `renameworkspace` | `WORKSPACEID,NEWNAME` | Workspace renamed |
| `activespecial` | `WORKSPACENAME,MONNAME` | Special workspace opened/closed on monitor (empty name = closed) |
| `activespecialv2` | `WORKSPACEID,WORKSPACENAME,MONNAME` | Same, with ID (empty ID and name = closed) |

### Monitor Events

| Event | Data | Description |
|---|---|---|
| `focusedmon` | `MONNAME,WORKSPACENAME` | Active monitor changed |
| `focusedmonv2` | `MONNAME,WORKSPACEID` | Same, with workspace ID |
| `monitoradded` | `MONITORNAME` | Monitor connected |
| `monitoraddedv2` | `MONITORID,MONITORNAME,MONITORDESCRIPTION` | Same, with ID and description |
| `monitorremoved` | `MONITORNAME` | Monitor disconnected |
| `monitorremovedv2` | `MONITORID,MONITORNAME,MONITORDESCRIPTION` | Same, with ID and description |

### Window Events

| Event | Data | Description |
|---|---|---|
| `activewindow` | `WINDOWCLASS,WINDOWTITLE` | Active window changed |
| `activewindowv2` | `WINDOWADDRESS` | Same, address only |
| `openwindow` | `WINDOWADDRESS,WORKSPACENAME,WINDOWCLASS,WINDOWTITLE` | Window opened |
| `closewindow` | `WINDOWADDRESS` | Window closed |
| `kill` | `WINDOWADDRESS` | Window killed via `hyprctl kill` |
| `movewindow` | `WINDOWADDRESS,WORKSPACENAME` | Window moved to workspace |
| `movewindowv2` | `WINDOWADDRESS,WORKSPACEID,WORKSPACENAME` | Same, with workspace ID |
| `windowtitle` | `WINDOWADDRESS` | Window title changed |
| `windowtitlev2` | `WINDOWADDRESS,WINDOWTITLE` | Same, with new title |
| `fullscreen` | `0` or `1` | Window fullscreen state changed (0=exit, 1=enter) |
| `changefloatingmode` | `WINDOWADDRESS,FLOATING` | Window float state changed (FLOATING: 0 or 1) |
| `urgent` | `WINDOWADDRESS` | Window requested urgent state |
| `pin` | `WINDOWADDRESS,PINSTATE` | Window pinned/unpinned |
| `minimized` | `WINDOWADDRESS,0/1` | External taskbar requested minimize/unminimize |

> **Warning:** `fullscreen` is not guaranteed to fire exactly once per on/off transition. Some windows fire multiple fullscreen requests.

### Layer Surface Events

| Event | Data | Description |
|---|---|---|
| `openlayer` | `NAMESPACE` | Layer surface mapped |
| `closelayer` | `NAMESPACE` | Layer surface unmapped |

### Group Events

| Event | Data | Description |
|---|---|---|
| `togglegroup` | `0/1,WINDOWADDRESS(ES)` | Group toggled. State 0=destroyed, 1=created. Addresses comma-separated. e.g. `0,64cea2525760,64cea2522380` |
| `moveintogroup` | `WINDOWADDRESS` | Window merged into a group |
| `moveoutofgroup` | `WINDOWADDRESS` | Window removed from a group |
| `ignoregrouplock` | `0/1` | `ignoregrouplock` toggled |
| `lockgroups` | `0/1` | `lockgroups` toggled |

### Misc Events

| Event | Data | Description |
|---|---|---|
| `activelayout` | `KEYBOARDNAME,LAYOUTNAME` | Active keyboard layout changed |
| `submap` | `SUBMAPNAME` | Keybind submap changed (empty = default) |
| `screencast` | `STATE,OWNER` | Screencopy client state changed. STATE: 0/1, OWNER: monitor/window/region |
| `screencastv2` | `STATE,OWNER,NAME` | Same, with identifier of shared target (monitor name or window title) |
| `configreloaded` | *(empty)* | Config finished reloading |
| `bell` | `WINDOWADDRESS` | App rang system bell via `xdg-system-bell-v1` (address may be empty) |

---

## Quickshell Usage

In Quickshell, socket2 events are surfaced through the `Quickshell.Hyprland` module. Prefer the typed API (`Hyprland.workspaces`, `Hyprland.activeWindow`, etc.) over raw IPC where possible. Use raw IPC for events not yet wrapped by Quickshell.

```qml
import Quickshell.Hyprland

// Typed API (preferred) — no raw parsing needed
Connections {
    target: Hyprland
    function onFocusedMonitorChanged() { /* ... */ }
}

// Raw IPC event stream
IpcListener {
    // receives every socket2 event as a string "EVENT>>DATA"
}
```

---

## Bash Example (socat)

```sh
#!/bin/sh
handle() {
    case $1 in
        monitoradded*)  do_something ;;
        focusedmon*)    do_something_else ;;
    esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock \
    | while read -r line; do handle "$line"; done
```
