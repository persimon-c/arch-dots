-- modules/decorations.lua
-- Window decorations — rounding, opacity, blur, shadow.

hl.config({
    decoration = {
        rounding = 12,

        active_opacity = 0.92,
        inactive_opacity = 0.80,
        fullscreen_opacity = 1.0,

        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            new_optimizations = true,
            xray = false,
            ignore_opacity = false,
        },
    },
})
