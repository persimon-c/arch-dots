-- modules/animations.lua
-- Bezier curves and animation rules.

hl.config({
    animations = {
        enabled = true,
    },
})

-- Curves
hl.curve("floaty",    { type = "bezier", points = { { 0.05, 0.09 }, { 0.1, 1.05 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 },    { 0.66, -0.56 } } })
hl.curve("smoothIn",  { type = "bezier", points = { { 0.25, 1 },    { 0.5, 1 } } })

-- Animations
hl.animation({ leaf = "windows",      enabled = true,  speed = 5,  bezier = "smoothIn",  style = "popin" })
hl.animation({ leaf = "windowsOut",   enabled = true,  speed = 5,  bezier = "smoothOut", style = "popin" })
hl.animation({ leaf = "windowsMove",  enabled = true,  speed = 4,  bezier = "floaty" })
hl.animation({ leaf = "workspaces",   enabled = true,  speed = 6,  bezier = "floaty",    style = "slide" })
hl.animation({ leaf = "fadeIn",       enabled = true,  speed = 5,  bezier = "smoothIn" })
hl.animation({ leaf = "fadeOut",      enabled = true,  speed = 5,  bezier = "smoothOut" })
hl.animation({ leaf = "border",       enabled = true,  speed = 8,  bezier = "default" })
hl.animation({ leaf = "borderangle",  enabled = true,  speed = 30, bezier = "default",   style = "loop" })
