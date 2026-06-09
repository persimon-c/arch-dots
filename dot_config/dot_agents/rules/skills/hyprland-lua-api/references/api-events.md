# Hyprland Lua API — Events (`hl.on`)

Source: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Expanding-functionality/

## Usage

```lua
local handle = hl.on("event.name", function(arg1, arg2, ...)
  -- callback body
end)

-- To remove:
hl.off(handle)
```

Max recursion depth: 5. Callbacks have a 100ms timeout guard.

---

## Hyprland Lifecycle Events

| Event | Callback signature | Notes |
|---|---|---|
| `hyprland.start` | `function()` | Fires once on compositor start. Use for autostart. |
| `hyprland.config_reloaded` | `function()` | After config reload. |

**Autostart pattern:**
```lua
hl.on("hyprland.start", function()
  hl.dispatch(hl.dsp.exec_cmd("waybar"))
  hl.dispatch(hl.dsp.exec_cmd("dunst"))
  hl.dispatch(hl.dsp.exec_cmd("hyprpaper"))
end)
```

---

## Window Events

| Event | Callback signature | Notes |
|---|---|---|
| `window.active` | `function(w: HL.Window)` | Window focused |
| `window.opened` | `function(w: HL.Window)` | New window created |
| `window.closed` | `function(w: HL.Window)` | Window closed |
| `window.moved` | `function(w: HL.Window)` | Window moved |
| `window.fullscreen` | `function(w: HL.Window)` | Fullscreen state changed |
| `window.float` | `function(w: HL.Window)` | Float state changed |
| `window.title_changed` | `function(w: HL.Window)` | Title changed |
| `window.workspace_changed` | `function(w: HL.Window)` | Window moved to different workspace |

---

## Workspace Events

| Event | Callback signature | Notes |
|---|---|---|
| `workspace.active` | `function(ws: HL.Workspace)` | Workspace focused |
| `workspace.created` | `function(ws: HL.Workspace)` | New workspace |
| `workspace.destroyed` | `function(ws: HL.Workspace)` | Workspace removed |
| `workspace.move_to_monitor` | `function(ws: HL.Workspace, m: HL.Monitor)` | WS moved to monitor |

---

## Monitor Events

| Event | Callback signature | Notes |
|---|---|---|
| `monitor.added` | `function(m: HL.Monitor)` | Monitor connected |
| `monitor.removed` | `function(m: HL.Monitor)` | Monitor disconnected |
| `monitor.active` | `function(m: HL.Monitor)` | Monitor focused |

---

## Input Events

| Event | Callback signature | Notes |
|---|---|---|
| `submap` | `function(name: string)` | Submap changed; name = "" for default |

---

## Notes

- The full authoritative event list is in the LSP stubs at `/usr/share/hypr/stubs/hl.meta.lua`
- Use `hl.get_config("general.layout")` to read config values at runtime
- `m.position.x` and `m.position.y` give monitor position (as seen in the wiki example)
- Events fire on every config reload — don't double-register in re-run code paths (or use `hyprland.start` which fires only once)
