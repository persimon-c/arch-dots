-- modules/decorations.lua
-- Window decorations — rounding, opacity, blur, shadow.

hl.config({
    decoration = {
        rounding = 16,          -- slightly rounder to sell the glass shape

        active_opacity   = 0.87,
        inactive_opacity = 0.76,  -- inactive drops further so active ones "pop"
        fullscreen_opacity = 1.0,

        blur = {
            enabled           = true,
            size              = 4,    -- smaller size = sharper, more refractive edge
            passes            = 4,    -- more passes = smoother gradient without mush
            new_optimizations = true,
            xray              = false,

            -- The liquid glass trio:
            noise             = 0.02,   -- subtle film grain — breaks up the flatness
            contrast          = 1.1,    -- punches up contrast through the glass
            brightness        = 1.05,   -- slight glow, like light bending through glass
            vibrancy          = 0.15,   -- key one — saturates what's behind the window
            vibrancy_darkness = 0.5,    -- keeps darks from washing out with vibrancy

            ignore_opacity    = true,   -- blur applies even to transparent areas (critical)
            popups            = true,   -- menus/tooltips get the same treatment
        },

        shadow = {
            enabled        = false,
            -- range          = 8,
            -- render_power   = 2,
            -- color          = "rgba(0, 0, 0, 0.25)",
            -- color_inactive = "rgba(0, 0, 0, 0.10)",
            -- offset         = { 0, 4 },
        },
    },
})