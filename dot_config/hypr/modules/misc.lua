-- modules/misc.lua
-- Miscellaneous Hyprland settings.

hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = true,
        -- animate_mouse_windowdragging = true,  -- commented out in original
        enable_swallow = true,
        swallow_regex = "^(kitty)$",
        focus_on_activate = false,
        -- vfr = true,  -- commented out in original
        vrr = 0,
    },
})
