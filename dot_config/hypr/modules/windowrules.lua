-- modules/windowrules.lua
-- Window rules. Evaluated top to bottom — order matters.
-- Static effects (float, size, center, workspace) apply once on open.
-- Dynamic effects (opacity, blur, etc.) re-evaluate on property change.

-- ── Floating + Center ────────────────────────────────────────────────────────

hl.window_rule({ match = { class = "pavucontrol" },          float = true, center = true })
hl.window_rule({ match = { class = "blueman-manager" },      float = true, center = true })
hl.window_rule({ match = { class = "org.gnome.Calculator" }, float = true, center = true })
hl.window_rule({ match = { class = "hyprpicker" },           float = true, center = true })

-- ── Float + Fixed Size (when switched to floating) ───────────────────────────

-- kitty
hl.window_rule({ match = { class = "kitty", float = true }, size = { 800, 500 }, center = true })

-- thunar
hl.window_rule({ match = { class = "thunar", float = true }, size = { 900, 600 }, center = true })

-- imv
hl.window_rule({ match = { class = "imv" }, float = true, center = true })
hl.window_rule({ match = { class = "imv" }, max_size = { 800, 600 } })

-- mpv
hl.window_rule({ match = { class = "mpv", float = true }, size = { 1280, 720 }, center = true })

-- obs-studio
hl.window_rule({ match = { class = "com.obsproject.Studio", float = true }, size = { 1280, 800 }, center = true })

-- spotify (flatpak)
hl.window_rule({ match = { class = "com.spotify.Client", float = true }, size = { 1000, 650 }, center = true })

-- ── Layer Rules (Quickshell) ─────────────────────────────────────────────────

-- Enable blur for all Quickshell panels (regex matches quickshell-bar, quickshell-*, etc.)
hl.layer_rule({ match = { namespace = "quickshell.*" }, blur = true, ignore_alpha = 0.5 })

-- Disable Hyprland animations for Quickshell popups so our buttery QML animations can run uninterrupted
hl.layer_rule({ match = { namespace = "dropdown" }, no_anim = true })
hl.layer_rule({ match = { namespace = "launcher" }, no_anim = true })
hl.layer_rule({ match = { namespace = "polkit" }, no_anim = true })


-- ── Forced Opaque (blur/transparency on these is just noise + GPU waste) ────

hl.window_rule({ match = { class = "mpv" },                   opacity = 1.0 })
hl.window_rule({ match = { class = "imv" },                   opacity = 1.0 })
hl.window_rule({ match = { class = "com.spotify.Client" },    opacity = 1.0 })
hl.window_rule({ match = { class = "brave-browser" },         opacity = 1.0 })
hl.window_rule({ match = { class = "com.obsproject.Studio" }, opacity = 1.0 })

-- ── Browser Auth Popups ──────────────────────────────────────────────────────

-- Google OAuth — matches "Sign in - Google Accounts - Brave", "Choose an account - Google Accounts - Brave", etc.
hl.window_rule({ match = { initial_title = "Untitled - Brave", initial_class = "brave-browser" }, float = true, center = true, size = { 500, 620 }, workspace = "current" })