-- modules/workspace/rules.lua
-- Workspace rules.

-- ── Single Window Centered ───────────────────────────────────────────────────
-- When only one tiled window exists on a workspace, add large gaps so it
-- appears centered and smaller rather than almost fullscreen.
-- Ignores special workspaces.

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 50, gaps_in = 7 })

-- Remove border and rounding when only one tiled window (clean look)
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 2 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, rounding = 10 })

-- ── Fullscreen workspace (no gaps, no border) ────────────────────────────────

hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, rounding = 0 })
