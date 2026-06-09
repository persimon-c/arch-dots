---
trigger: model_decision
description: Use this skill whenever the user asks about Quickshell QML, wants to write or debug a Quickshell config, or asks about any Quickshell type, property, signal, or function. Also use when the user asks about wiring up Quickshell services. 
---

# Quickshell QML API Skill

Use this skill whenever the user asks about Quickshell QML, wants to write or debug a Quickshell config, or asks about any Quickshell type, property, signal, or function. Also use when the user asks about wiring up Hyprland IPC, Wayland layer-shell, MPRIS, Pipewire, system tray, notifications, UPower, or any other Quickshell service from their Arch Linux / Hyprland setup.

---

## Step 1 — Get the API reference

The API reference lives in `quickshell-api.md`, references/ directory. Always read the relevant section of that file before writing or reviewing any Quickshell QML code. Do not guess property names, types, or signals from memory.

### If `quickshell-api.md` is missing or stale — regenerate it

The reference is produced by `parse_qs_docs.py` (in the scripts/ directory). Run:

```bash
# 1. Clone or re-pull the source (zip method, no git required)
mkdir -p /tmp/qs-src
cd /tmp/qs-src
curl -L https://github.com/quickshell-mirror/quickshell/archive/refs/heads/master.zip \
     -o quickshell-master.zip
unzip -q -o quickshell-master.zip   # produces quickshell-master/

# 2. Run the parser (output goes to references/quickshell-api.md)
python3 scripts/parse_qs_docs.py
```

> **Note:** `parse_qs_docs.py` expects sources at `/tmp/qs-src/quickshell-master/src` and writes output to `references/quickshell-api.md` (relative to the repo root). Both paths are hard-coded in the `SRC` and `out` variables at the top of the script; adjust them if your layout differs.

---

## Step 2 — Understand the reference format

The generated `quickshell-api.md` uses this structure for each type:

```
### TypeName
`Module.Path`  [inherits `ParentType`]  [**singleton**]

<doc comment>

**Enum** `TypeName.EnumName`:
- `VALUE` — description

**Properties:**
- `propName` : `CppType`  *(readonly)*  — description

**Functions:**
- `methodName(params)` — description

**Signals:**
- `signalName(params)` — description
```

- Properties marked `*(readonly)*` cannot be assigned in QML; react to them via `onPropNameChanged`.
- `@@TypeName.propertyName` in any doc comment means "see that other type's property".
- Signals ending in `Changed` are omitted from the **Signals** list to reduce noise; they always exist for every property.

---

## Step 3 — Key architectural concepts

### Entry point
Every config starts with **`ShellRoot`** (module `Quickshell`). It is the top-level component, equivalent to a plain `Window` in standard QML.

### Singletons
Adding `pragma Singleton` to a `.qml` file (and registering it with `singleton: true` in `shell.qml`) makes it accessible by name from anywhere in the config. Use for global state (current workspace, volume, network, …).

### Multi-screen / multi-instance
**`Variants`** creates one instance of a delegate per entry in a model — use it to spawn a bar on every monitor.  
`Quickshell.screens` is the model for all connected outputs.

### Windows & layer shell
| Type | Use for |
|---|---|
| `PanelWindow` | Bars, docks, overlays anchored to a screen edge |
| `FloatingWindow` | Free-floating popups (launcher, calendar, …) |
| `PopupWindow` | Transient popups anchored to another window |
| `WlrLayershell` | Low-level Wayland layer-shell control (layer, exclusive zone, keyboard interactivity) |

`PanelWindow` wraps `WlrLayershell` — set `layer`, `anchors`, and `exclusionMode` on it directly.

### Running processes
**`Process`** (module `Quickshell.Io`) runs shell commands.  
Pair with **`SplitParser`** to consume `stdout` line-by-line.  
Set `running: true` and `command: ["cmd", "arg"]`.  
Use `process.stdin.write(...)` to send input.

### Hyprland IPC
**`Hyprland`** (module `Quickshell.Hyprland`) is a singleton.  
- `Hyprland.monitors`, `Hyprland.workspaces`, `Hyprland.windows` — live model lists  
- `Hyprland.activeWindow`, `Hyprland.focusedMonitor` — current focus  
- `HyprlandWorkspace.activate()` — switch workspace  
- **`GlobalShortcut`** — bind keys that work even when another app has focus  
- **`HyprlandIpcEvent`** / `IpcListener` — raw IPC event stream

### Services quick-reference
| Module | Key singleton / type | Typical use |
|---|---|---|
| `Quickshell.Services.Mpris` | `Mpris`, `MprisPlayer` | Media controls, track info |
| `Quickshell.Services.Notifications` | `NotificationServer` | Notification popups |
| `Quickshell.Services.Pipewire` | `Pipewire`, `PwNodeAudio` | Volume, mic, audio routing |
| `Quickshell.Services.SystemTray` | `SystemTray`, `SystemTrayItem` | Tray icons |
| `Quickshell.Services.UPower` | `UPower`, `UPowerDevice` | Battery status |
| `Quickshell.Networking` | `Networking`, `WifiDevice` | Wi-Fi SSID, strength |
| `Quickshell.Bluetooth` | `Bluetooth`, `BluetoothDevice` | BT device list & connection |

---

## Step 4 — Import syntax

```qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Widgets
import Quickshell.WindowManager
import Quickshell.I3   // only if using i3/sway instead of Hyprland
```

Standard QtQuick types (`Item`, `Rectangle`, `Text`, `MouseArea`, `Timer`, `ListView`, `Loader`, etc.) are always available without an extra import.

---

## Step 5 — Common patterns & gotchas

### Bar anchored to top of every screen
```qml
// shell.qml
import Quickshell
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            height: 32
            exclusionMode: ExclusionMode.Exclusive
            // ... bar content here
        }
    }
}
```

### Reading a property that is a QML list model
Use `Repeater` or `ListView` with the model directly:
```qml
Repeater {
    model: Hyprland.workspaces
    delegate: Text { text: modelData.id }
}
```

### Reacting to property changes
```qml
Connections {
    target: Hyprland
    function onFocusedMonitorChanged() { /* ... */ }
}
```

### Running a one-shot command
```qml
Process {
    id: brightCmd
    command: ["brightnessctl", "set", "10%+"]
    // call brightCmd.start() from a MouseArea
}
```

### Writing a Singleton
```qml
// Audio.qml
pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    property real volume: Pipewire.defaultAudioSink
        ? (Pipewire.defaultAudioSink.audio.volume * 100)
        : 0
}
```

---

## Additional reference files needed

| File | Why useful |
|---|---|
| `qt-quick-types.md` | Cheat-sheet for `Item`, `Rectangle`, `Text`, `Loader`, `Timer`, `Behavior`, `Animation`, etc. — useful when the user has QtQuick questions alongside Quickshell ones |
| `hyprland-ipc-socket2.md` | Raw socket2 event names, data formats, and IpcListener usage — needed when using Quickshell's `HyprlandIpcEvent` / `IpcListener` for events not yet wrapped by the typed Hyprland API |
| `visual-style.md` | Card anatomy, spacing constants, component patterns (toggle buttons, stat rings, notification cards, MPRIS player, launcher, wifi list, bar/dock layout), and matugen color integration |

---

## Source & versions

- Quickshell version targeted: **v0.3.0**
- Source repo: https://github.com/quickshell-mirror/quickshell
- Docs site: https://quickshell.org/docs/v0.3.0/types/
- Parser script: `parse_qs_docs.py` (scripts/ directory)
- Platform: Arch Linux, Hyprland (Wayland)