# Hyprland Lua API — Object Types

## HL.Window

Fields exposed on window objects (e.g., from `hl.get_active_window()`, event callbacks):

```
.title          string    — window title
.class          string    — window class (app_id)
.address        number    — window memory address (unique ID)
.pid            number    — process ID
.workspace      HL.Workspace
.monitor        HL.Monitor
.floating       boolean
.fullscreen     boolean   — true if fullscreen
.maximized      boolean
.pinned         boolean   — pinned to all workspaces
.grouped        boolean
.x, .y          number    — position (screen coords)
.width, .height number    — size
.xwayland       boolean   — true if XWayland window
.tags           table     — array of tag strings
```

## HL.Workspace

```
.id             number    — workspace ID
.name           string    — workspace name (usually same as id as string)
.monitor        HL.Monitor
.window_count   number
.has_fullscreen boolean
.persistent     boolean
.special        boolean   — true if special workspace
```

## HL.Monitor

```
.id             number
.name           string    — e.g. "DP-1", "HDMI-A-1"
.description    string
.make           string
.model          string
.serial         string
.width, .height number    — resolution
.refresh_rate   number    — Hz
.x, .y          number    — position in layout
.scale          number
.transform      number    — 0-7
.active         boolean
.focused        boolean
.dpms           boolean
.vrr            boolean
.active_workspace HL.Workspace
```

## HL.Notification

```
.text           string
.timeout        number    — ms remaining
.icon           string

:dismiss()               — method: dismiss the notification
```

## HL.LayoutContext (in `hl.layout.register`)

```
.targets        table     — array of layout targets
.area           HL.Box    — work area

:column(i, n)            — returns i-th column box out of n
:row(i, n)               — returns i-th row box out of n
:grid_cell(x, y, w, h)   — returns grid cell box
:split(box, ratio, dir)  — split box; dir = "h" or "v"
```

## Layout Target

```
.window         HL.Window or nil  — the primary window
:place(box)                       — place this target in a box
```

## HL.Box

```
.x, .y          number    — position
.width, .height number    — size
```
