-- modules/binds.lua

local mod = "SUPER"

-- toggle between 60hz and 120hz for battery stuff
hl.bind(mod .. " + K", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-hz.sh"))

-- ── Workspace Animation Helpers ───────────────────────────────────────────────

local function wsForward()
    hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5, bezier = "loft",     style = "slidefade right 15%" })
    hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5, bezier = "throwOut", style = "slidefade right 15%" })
end

local function wsBackward()
    hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5, bezier = "loft",     style = "slidefade left 15%" })
    hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5, bezier = "throwOut", style = "slidefade left 15%" })
end

-- ── Window Management ────────────────────────────────────────────────────────

hl.bind(mod .. " + Q",           hl.dsp.window.close())
hl.bind(mod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + F",   hl.dsp.window.float())
hl.bind(mod .. " + P",           hl.dsp.window.pseudo())
hl.bind(mod .. " + SHIFT + P",   hl.dsp.window.pin())
hl.bind(mod .. " + SHIFT + C", hl.dsp.window.center())

-- Focus
hl.bind(mod .. " + Up",          hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + Down",        hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + Left",        hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + Right",       hl.dsp.focus({ direction = "r" }))

-- Move windows
hl.bind(mod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }))
hl.bind(mod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))

-- Move window to next/prev workspace and follow it
hl.bind(mod .. " + SHIFT + mouse_up", function()
    wsForward()
    hl.dispatch(hl.dsp.window.move({ workspace = "+1", follow = true }))
end, { mouse = true })

hl.bind(mod .. " + SHIFT + mouse_down", function()
    wsBackward()
    hl.dispatch(hl.dsp.window.move({ workspace = "-1", follow = true }))
end, { mouse = true })

-- Resize (repeatable)
hl.bind(mod .. " + CTRL + Up",    hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + Down",  hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + Left",  hl.dsp.window.resize({ x = -20, y = 0,   relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + Right", hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }), { repeating = true })

-- Mouse window management
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Window Grouping ──────────────────────────────────────────────────────────

hl.bind(mod .. " + SHIFT + G",        hl.dsp.group.toggle())
hl.bind(mod .. " + CTRL + Tab",       hl.dsp.group.next())
hl.bind(mod .. " + CTRL + SHIFT + Tab", hl.dsp.group.prev())

-- ── Workspace Switching ──────────────────────────────────────────────────────

for i = 1, 9 do
    local target = i
    hl.bind(mod .. " + " .. i, function()
        local current = hl.get_active_workspace().id
        if target > current then wsForward() else wsBackward() end
        hl.dispatch(hl.dsp.focus({ workspace = target }))
    end)
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse_up", function()
    wsForward()
    hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
end, { mouse = true })

hl.bind(mod .. " + mouse_down", function()
    wsBackward()
    hl.dispatch(hl.dsp.focus({ workspace = "-1" }))
end, { mouse = true })

-- ── Tab / Cycle ──────────────────────────────────────────────────────────────

hl.bind(mod .. " + Tab",           hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))
hl.bind(mod .. " + SHIFT + Tab",   hl.dsp.window.cycle_next({ next = false }))
hl.bind("ALT + Tab",               hl.dsp.window.cycle_next())
hl.bind("ALT + SHIFT + Tab",       hl.dsp.window.cycle_next({ next = false }))

-- ── Applications ─────────────────────────────────────────────────────────────

hl.bind(mod .. " + Return",        hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + B",             hl.dsp.exec_cmd("brave"))
hl.bind(mod .. " + A",             hl.dsp.exec_cmd("antigravity"))
hl.bind(mod .. " + S",             hl.dsp.exec_cmd("subl"))
hl.bind(mod .. " + O",             hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + T",             hl.dsp.exec_cmd("thunar"))
hl.bind(mod .. " + D", hl.dsp.exec_cmd("flatpak run com.discordapp.Discord"))
hl.bind(mod .. " + V",             hl.dsp.exec_cmd("code"))
hl.bind(mod .. " + E",             hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind(mod .. " + Z",             hl.dsp.exec_cmd("kitty -e zellij"))
hl.bind(mod .. " + SHIFT + Z",     hl.dsp.exec_cmd("~/.config/hypr/scripts/zellij-dev.sh"))
hl.bind(mod .. " + C",             hl.dsp.exec_cmd("hyprpicker -a && notify-send \"Color picked\" \"$(wl-paste)\""))

-- ── Quickshell Panel Triggers ─────────────────────────────────────────────────

hl.bind(mod .. " + Space",         hl.dsp.exec_cmd("quickshell ipc call toggleLauncher"))
hl.bind(mod .. " + N",             hl.dsp.exec_cmd("quickshell ipc call toggleNotificationCenter"))
hl.bind(mod .. " + G",             hl.dsp.exec_cmd("quickshell ipc call toggleRightSidebar"))
hl.bind(mod .. " + X",             hl.dsp.exec_cmd("quickshell ipc call toggleLeftSidebar"))
hl.bind(mod .. " + W",             hl.dsp.exec_cmd("quickshell ipc call toggleWallpaperPicker"))
hl.bind(mod .. " + SHIFT + O",     hl.dsp.exec_cmd("quickshell ipc call toggleSettings"))
hl.bind(mod .. " + SHIFT + V",     hl.dsp.exec_cmd("quickshell ipc call toggleClipboard"))
hl.bind(mod .. " + semicolon",     hl.dsp.exec_cmd("quickshell ipc call toggleEmojiPicker"))

-- ── Screenshots ──────────────────────────────────────────────────────────────

hl.bind("Print",                   hl.dsp.exec_cmd("~/.config/quickshell/scripts/screenshot.sh screen"))
hl.bind(mod .. " + Print",         hl.dsp.exec_cmd("~/.config/quickshell/scripts/screenshot.sh area"))

-- Screenshot submap
hl.bind(mod .. " + SHIFT + Print", hl.dsp.submap("screenshot"))

hl.define_submap("screenshot", function()
    hl.bind("F", function()
        hl.dispatch(hl.dsp.exec_cmd("~/.config/quickshell/scripts/screenshot.sh screen"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("R", function()
        hl.dispatch(hl.dsp.exec_cmd("~/.config/quickshell/scripts/screenshot.sh area"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("W", function()
        hl.dispatch(hl.dsp.exec_cmd("~/.config/quickshell/scripts/screenshot.sh active"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("C", function()
        hl.dispatch(hl.dsp.exec_cmd("grimblast copy area"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- ── Media and Audio ───────────────────────────────────────────────────────────

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  { repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioStop",         hl.dsp.exec_cmd("playerctl stop"))

-- ── Brightness ────────────────────────────────────────────────────────────────

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

-- ── System ────────────────────────────────────────────────────────────────────

hl.bind(mod .. " + L",             hl.dsp.exec_cmd("~/.config/quickshell/scripts/lock.sh"))
hl.bind(mod .. " + SHIFT + R",     hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + Q",     hl.dsp.exec_cmd("quickshell --reload"))

-- System submap
hl.bind(mod .. " + SHIFT + S", hl.dsp.submap("system"))

hl.define_submap("system", function()
    hl.bind("L", function()
        hl.dispatch(hl.dsp.exec_cmd("~/.config/quickshell/scripts/lock.sh"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("S", function()
        hl.dispatch(hl.dsp.exec_cmd("systemctl suspend"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("R", function()
        hl.dispatch(hl.dsp.exec_cmd("systemctl reboot"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("Q", function()
        hl.dispatch(hl.dsp.exec_cmd("systemctl poweroff"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("E", function()
        hl.dispatch(hl.dsp.exec_cmd("loginctl terminate-user \"\""))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- ── Resize submap ─────────────────────────────────────────────────────────────

hl.bind(mod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("right",  hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }), { repeating = true })
    hl.bind("left",   hl.dsp.window.resize({ x = -20, y = 0,   relative = true }), { repeating = true })
    hl.bind("down",   hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })
    hl.bind("up",     hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- ── Gestures ──────────────────────────────────────────────────────────────────

-- 3-finger: workspace switching
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- 4-finger vertical: fullscreen / close
hl.gesture({ fingers = 4, direction = "up",   action = "fullscreen" })
hl.gesture({ fingers = 4, direction = "down",  action = "close" })

-- 4-finger horizontal: float / tile
hl.gesture({ fingers = 4, direction = "left",  action = "float", mode = "float" })
hl.gesture({ fingers = 4, direction = "right", action = "float", mode = "tile" })

-- 2-finger pinch: live zoom
hl.gesture({ fingers = 2, direction = "pinch", action = "cursorZoom", zoom_level = 1, mode = "live" })