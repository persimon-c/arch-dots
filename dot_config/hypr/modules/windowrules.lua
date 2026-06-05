-- modules/windowrules.lua
-- Window rules. Evaluated top to bottom — order matters.
-- Static effects (float, size, center, workspace) apply once on open.
-- Dynamic effects (opacity, blur, etc.) re-evaluate on property change.

-- ── Floating + Center ────────────────────────────────────────────────────────

hl.window_rule({ match = { class = "pavucontrol" },          float = true, center = true })
hl.window_rule({ match = { class = "blueman-manager" },      float = true, center = true })
hl.window_rule({ match = { class = "org.gnome.Calculator" }, float = true, center = true })
hl.window_rule({ match = { class = "hyprpicker" },           float = true, center = true })

-- ── App Workspace Assignments ────────────────────────────────────────────────

hl.window_rule({ match = { class = "brave-browser" },        workspace = "2" })
hl.window_rule({ match = { class = "discord" },              workspace = "4" })
hl.window_rule({ match = { class = "com.discordapp.Discord" }, workspace = "4" })

-- ── Float + Fixed Size (when switched to floating) ───────────────────────────

-- kitty
hl.window_rule({ match = { class = "kitty", float = true }, size = { 800, 500 }, center = true })

-- thunar
hl.window_rule({ match = { class = "thunar", float = true }, size = { 900, 600 }, center = true })

-- imv
hl.window_rule({ match = { class = "imv", float = true }, size = { 1000, 700 }, center = true })

-- mpv
hl.window_rule({ match = { class = "mpv", float = true }, size = { 1280, 720 }, center = true })

-- obs-studio
hl.window_rule({ match = { class = "com.obsproject.Studio", float = true }, size = { 1280, 800 }, center = true })

-- spotify (flatpak)
hl.window_rule({ match = { class = "com.spotify.Client", float = true }, size = { 1000, 650 }, center = true })

-- ── Layer Rules (Quickshell) ─────────────────────────────────────────────────

-- Enable blur for Quickshell panels
hl.layer_rule({ match = { namespace = "quickshell" }, blur = true, ignore_alpha = 0.5 })
