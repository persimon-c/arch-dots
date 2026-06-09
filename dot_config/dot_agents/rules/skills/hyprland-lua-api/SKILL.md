---
trigger: model_decision
description: Use this skill whenever the user is writing, editing, or asking about hyprland.lua config, the hl.* Lua API, Hyprland keybinds, window rules, monitors, dispatchers, or events.
---

# Hyprland Lua API (v0.55+)

Since Hyprland 0.55 (released May 9, 2026), the config format is **Lua** (`~/.config/hypr/hyprland.lua`).

## Key Facts

- Config file: `$XDG_CONFIG_HOME/hypr/hyprland.lua` (usually `~/.config/hypr/hyprland.lua`)
- Use `--config` / `-c` flag to specify a custom path
- Auto-reloads on save; also `hyprctl reload` to reload manually
- `hyprctl reload full-reset` recreates entire config context (rarely needed; allows switching between lua/hyprlang)
- Config can be split across files: `require("awesomeconf/keybinds")` or `require("awesomeconf.keybinds")` (/ and . both work as separators)
- Each `require()` call is a separate Lua scope — errors in one file don't stop others
- LSP stubs at `/usr/share/hypr/stubs/` — point `luarc.json` there for editor completions
- The Lua standard libraries are loaded by default
- Hyprland auto-generates an example config at `/usr/share/hypr/hyprland.lua` if none exists

## Error Handling

- Runtime Lua syntax errors → abort current file + popup notification
- Runtime Hyprland type errors (e.g. wrong arg type to `hl.*`) → continue + popup
- Runtime errors in async callbacks (keybinds, events) → popup notification
- Emergency keybinds always available: `SUPER+Q` (terminal), `SUPER+R` (run), `SUPER+M` (exit)
- Callbacks have a 100ms timeout guard; max recursion depth: 5

## The `hl` Global

Everything is accessed via the `hl` global table injected by Hyprland.

## IMPORTANT: API Differences from Your Reference Files

Several APIs in your reference files use **incorrect/outdated syntax**. Key corrections:
- `hl.rule()` → **actually `hl.window_rule()`** with a `match` table (not `window =` / `rule =`)
- `hl.animation()` is a **separate top-level function**, not inside `hl.config({ animations = { animation = ... } })`
- `hl.dsp.layout_msg()` → **actually `hl.dsp.layout(string)`**
- `hl.dsp.workspace.special_toggle()` → **actually `hl.dsp.workspace.toggle_special(name)`**
- `hl.env()` takes two positional args: `hl.env("KEY", "VALUE")`, not a table

---

## Reference Files

For detailed API reference, read the relevant file:

- **`references/api-core.md`** — `hl.config`, `hl.monitor`, `hl.bind`, `hl.dispatch`, `hl.on`, `hl.window_rule`, `hl.layer_rule`, `hl.workspace_rule`, `hl.permission`, `hl.curve`, `hl.animation`, `hl.layout`, `hl.timer`, `hl.env`, `hl.get_config`
- **`references/api-dispatchers.md`** — Full `hl.dsp.*` dispatcher reference
- **`references/api-objects.md`** — HL.Window, HL.Workspace, HL.Monitor, HL.Notification object fields
- **`references/api-events.md`** — All events usable with `hl.on()`
- **`references/example-config.md`** — Annotated example `hyprland.lua`

Read **all relevant** reference files before generating config code. For a full config rewrite or migration, read all of them.

---

## Quick Patterns

```lua
-- Keybind
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("kitty"))

-- Keybind with Lua function
hl.bind("SUPER + X", function()
  local w = hl.get_active_window()
  if w ~= nil and w.title == "htop" then
    hl.dispatch(hl.dsp.window.float({ action = "set" }))
  else
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  end
end)

-- Event listener
hl.on("window.active", function(w)
  hl.notification.create({ text = "Focused: " .. w.title, timeout = 3000 })
end)

-- Window rule (correct syntax: hl.window_rule with match table)
hl.window_rule({ match = { class = "kitty" }, float = true })

-- Monitor
hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "0x0", scale = 1 })

-- Read config at runtime
local gaps = hl.get_config("general.gaps_in")

-- Timer
local t = hl.timer(function() print("tick") end, { timeout = 1000, type = "repeat" })

-- Env var
hl.env("XCURSOR_SIZE", "24")

-- Animation (top-level, not inside hl.config)
hl.animation({ leaf = "windows", enabled = true, speed = 10, bezier = "easeOutQuint", style = "slide" })