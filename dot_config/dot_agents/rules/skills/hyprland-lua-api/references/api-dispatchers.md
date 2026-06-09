# Hyprland Lua API — Dispatchers (`hl.dsp.*`)

Source: https://wiki.hypr.land/Configuring/Basics/Dispatchers/

Dispatchers return action tables. They do NOT execute immediately — pass them to `hl.bind()` or `hl.dispatch()`.

## Selectors

Many dispatchers accept selectors. Common types:

**Window selector:**
- `"active"` — current focused window (default if omitted)
- `"class:regex"` — by class
- `"title:regex"` — by title
- address as number

**Workspace selector:**
- `"1"`–`"N"` — by number
- `"name:foo"` — by name
- `"special"` or `"special:name"` — special workspace
- `"prev"`, `"next"` — relative navigation
- `"empty"` — next empty workspace
- `"r+N"`, `"r-N"` — relative +/- N

**Monitor selector:**
- `"current"` (default)
- `"DP-1"` etc. by name
- `"l"`, `"r"`, `"u"`, `"d"` — direction

---

## Exec / System

```lua
hl.dsp.exec_cmd("kitty")                  -- run command
hl.dsp.exec_cmd("notify-send 'hi'")
hl.dsp.exit()                             -- exit Hyprland (avoid with uwsm!)
hl.dsp.global("coolApp:myToggle")         -- trigger global (XDPH only)
hl.dsp.submap("resize")                   -- enter a submap
hl.dsp.submap("reset")                    -- leave submap / return to default
```

---

## Window Dispatchers (`hl.dsp.window.*`)

```lua
-- Focus
hl.dsp.window.focus({ window = "class:kitty" })
hl.dsp.window.cycle_next()                  -- cycle focus to next window
hl.dsp.window.cycle_next({ prev = true })   -- cycle to previous
hl.dsp.window.focus_dir({ dir = "l" })      -- focus in direction l/r/u/d

-- Move / resize
hl.dsp.window.move({ dir = "l" })
hl.dsp.window.move({ dir = "r" })
hl.dsp.window.resize({ dir = "r", amount = 100 })  -- resize by pixels
hl.dsp.window.resize_exact({ width = 800, height = 600 })
hl.dsp.window.move_to({ x = 100, y = 200 })
hl.dsp.window.center()                      -- center floating window

-- Float
hl.dsp.window.float({ action = "toggle" })  -- action: "toggle","set","unset"
hl.dsp.window.float({ action = "set" })

-- Fullscreen / maximize
hl.dsp.window.fullscreen({ mode = "fullscreen" })  -- mode: "fullscreen","maximize","float"
hl.dsp.window.fullscreen({ mode = "maximize" })

-- Pin (keep on all workspaces)
hl.dsp.window.pin()

-- Bring to top (for floating)
hl.dsp.window.bring_to_top()

-- Close
hl.dsp.window.close()
hl.dsp.window.kill_active()                -- force-kill

-- Opacity
hl.dsp.window.opacity({ active = 0.9, inactive = 0.7 })

-- Move to workspace
hl.dsp.window.move_to_workspace({ workspace = "2" })
hl.dsp.window.move_to_workspace({ workspace = "2", silent = true })  -- don't follow

-- Swap
hl.dsp.window.swap({ dir = "r" })
hl.dsp.window.swap({ window = "class:kitty" })

-- Groups (tabs)
hl.dsp.window.group_toggle()
hl.dsp.window.group_change_active({ dir = "f" })   -- f=forward, b=backward
hl.dsp.window.group_set_active({ window = "..." })

-- Misc
hl.dsp.window.split_ratio({ ratio = 0.1 })     -- adjust split ratio
hl.dsp.window.split_ratio({ ratio = -0.1 })
hl.dsp.window.toggle_opaque()
```

---

## Workspace Dispatchers (`hl.dsp.workspace.*`)

```lua
-- Focus workspace
hl.dsp.workspace.focus({ workspace = "1" })
hl.dsp.workspace.focus({ workspace = "prev" })
hl.dsp.workspace.focus({ workspace = "next" })
hl.dsp.workspace.focus({ workspace = "empty" })
hl.dsp.workspace.focus({ workspace = "r+1" })   -- relative +1
hl.dsp.workspace.focus({ workspace = "r-1" })

-- Scroll through workspaces
hl.dsp.workspace.scroll({ dir = "up" })
hl.dsp.workspace.scroll({ dir = "down" })

-- Special workspace
hl.dsp.workspace.special_toggle()
hl.dsp.workspace.special_toggle({ name = "magic" })

-- Move workspace to monitor
hl.dsp.workspace.move_to_monitor({ monitor = "DP-1" })
```

---

## Monitor Dispatchers (`hl.dsp.monitor.*`)

```lua
hl.dsp.monitor.focus({ monitor = "r" })     -- focus monitor to the right
hl.dsp.monitor.focus({ monitor = "DP-1" })
hl.dsp.monitor.swap_active()                -- swap current workspace to next monitor
```

---

## Layout Dispatchers

Layout-specific dispatchers are documented on their respective layout pages.

**Dwindle:**
```lua
hl.dsp.layout_msg("dwindle:togglesplit")
hl.dsp.layout_msg("dwindle:preselect_dir " .. dir)
```

**Master:**
```lua
hl.dsp.layout_msg("master:swapwithmaster")
hl.dsp.layout_msg("master:focusmaster")
hl.dsp.layout_msg("master:addmaster")
hl.dsp.layout_msg("master:removemaster")
hl.dsp.layout_msg("master:orientationleft")
hl.dsp.layout_msg("master:orientationright")
hl.dsp.layout_msg("master:orientationtop")
hl.dsp.layout_msg("master:orientationbottom")
```

---

## Submap Pattern

```lua
-- Enter a resize submap
hl.bind("ALT + R", hl.dsp.submap("resize"))

-- Inside submap (only active while in it)
hl.bind("l", hl.dsp.window.resize({ dir = "r", amount = 30 }), { submap = "resize" })
hl.bind("h", hl.dsp.window.resize({ dir = "l", amount = 30 }), { submap = "resize" })
hl.bind("k", hl.dsp.window.resize({ dir = "u", amount = 30 }), { submap = "resize" })
hl.bind("j", hl.dsp.window.resize({ dir = "d", amount = 30 }), { submap = "resize" })

-- Escape submap
hl.bind("ESCAPE", hl.dsp.submap("reset"), { submap = "resize" })
hl.bind("RETURN", hl.dsp.submap("reset"), { submap = "resize" })
```
