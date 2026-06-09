-- modules/animations.lua
-- Bezier curves and animation rules.

hl.config({
    animations = {
        enabled = true,
    },
})

-- ── Curves ────────────────────────────────────────────────────────────────────

-- silky: smooth ease-out deceleration — the gold standard for "feels good"
hl.curve("silky",     { type = "bezier", points = { { 0.16, 1 },    { 0.3, 1 } } })

-- decay: sharp fast exit, no tail drag — windows disappear cleanly
hl.curve("decay",     { type = "bezier", points = { { 0.4, 0 },     { 0.6, 0 } } })

-- overshoot: very subtle elastic for window moves/drags — alive, not bouncy
hl.curve("overshoot", { type = "bezier", points = { { 0.34, 1.3 },  { 0.64, 1 } } })

-- snap: spring with good stiffness — snappy workspace lands
hl.curve("snap",      { type = "spring", mass = 1, stiffness = 200, dampening = 28 })

-- loft: eases in softly — used for workspace entry
hl.curve("loft",      { type = "bezier", points = { { 0.0, 0.0 },   { 0.15, 1 } } })

-- throwOut: fast launch for exits — same as before, it works
hl.curve("throwOut",  { type = "bezier", points = { { 0.4, 0 },     { 1, 1 } } })

-- ── Animations ────────────────────────────────────────────────────────────────

-- Windows — popin 85% gives a satisfying bloom-in without looking gimmicky
hl.animation({ leaf = "windows",     enabled = true, speed = 4,  bezier = "silky",    style = "popin 85%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3,  bezier = "decay",    style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "silky" })

-- Layers — slide left, silky in, snappy out
hl.animation({ leaf = "layersIn",  enabled = true, speed = 3.5, bezier = "silky",   style = "slide left" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3,   bezier = "decay",   style = "slide left" })

-- Fade — subtle and fast; nothing should linger
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 4,   bezier = "silky" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 3,   bezier = "decay" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 3,   bezier = "decay" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 3.5, bezier = "silky" })
hl.animation({ leaf = "fadePopups", enabled = true, speed = 3,   bezier = "silky" })

-- Workspaces — 15% slidefade feels 1:1 with your finger, not floaty
-- Direction is set dynamically from binds.lua before each switch.
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5, bezier = "loft",     style = "slidefade 15%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5, bezier = "throwOut", style = "slidefade 15%" })

-- Border
hl.animation({ leaf = "border",      enabled = true, speed = 8,  bezier = "silky" })
hl.animation({ leaf = "borderangle", enabled = false })