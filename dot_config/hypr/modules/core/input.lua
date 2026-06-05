-- modules/core/input.lua
-- Input configuration — keyboard, mouse, touchpad.

hl.config({
    input = {
        kb_layout = "us",

        follow_mouse = 1,
        mouse_refocus = true,

        sensitivity = 0,
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
            clickfinger_behavior = false,
        },
    },
})
