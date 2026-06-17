#!/usr/bin/env bash
# ~/.config/quickshell/scripts/wallpaper-change.sh
# Applies a wallpaper and runs the full palette + reload chain.
# Usage: wallpaper-change.sh /path/to/wallpaper.jpg
#
# Called by: Wallpaper.qml (setWallpaper), hypridle fallback
# Requires:  swww (awww), matugen, hyprctl, kitty (optional)

set -euo pipefail

WALLPAPER="${1:-}"

if [[ -z "$WALLPAPER" ]]; then
    echo "Usage: wallpaper-change.sh <path-to-wallpaper>" >&2
    exit 1
fi

if [[ ! -f "$WALLPAPER" ]]; then
    echo "Error: wallpaper file not found: $WALLPAPER" >&2
    exit 1
fi

# ── 1. Apply wallpaper ────────────────────────────────────────────────────────
# Bubble/grow transition expanding from cursor position.
# Bezier .43,1.19,1,.4 gives the elastic overshoot pop.
# --invert-y is required for correct cursor mapping on Wayland.
# Falls back to 0,0 (top-left) if hyprctl cursorpos is unavailable.

CURSOR_POS="$(hyprctl cursorpos 2>/dev/null | grep -E '^[0-9]' || echo '0,0')"

awww img "$WALLPAPER" \
    --transition-bezier .43,1.19,1,.4 \
    --transition-type grow \
    --transition-duration 0.4 \
    --transition-fps 60 \
    --invert-y \
    --transition-pos "$CURSOR_POS" || true

# ── 2. Write current wallpaper path to cache ──────────────────────────────────
# Wallpaper.qml watches this file via FileView — no signal needed.
# QS lock screen reads current_wallpaper symlink at lock time.

mkdir -p ~/.cache
ln -sf "$WALLPAPER" ~/.cache/current_wallpaper
echo "$WALLPAPER" > ~/.cache/current_wallpaper_path

# ── 3. Regenerate matugen palette ─────────────────────────────────────────────
# Writes all template outputs defined in ~/.config/matugen/config.toml:
#   → ~/.config/quickshell/theme/colors.json   (Colors.qml FileView picks this up automatically)
#   → ~/.config/hypr/modules/colors.conf
#   → ~/.config/kitty/matugen-colors.conf
#   → ~/.config/gtk-3.0/colors.css             (gtk3-thunar.css template; @import'd by gtk.css)
#   → ~/.config/gtk-4.0/colors.css             (gtk.css template; libadwaita named colors)
#   → ~/.config/cava/config
#   → ~/.config/zathura/zathurarc
#   → ~/.config/fastfetch/colors.jsonc

matugen image "$WALLPAPER" \
    --config "$HOME/.config/matugen/config.toml" \
    --source-color-index 0

# ── 4. Reload affected apps ───────────────────────────────────────────────────

# Hyprland: picks up new colors.conf (accent color for borders, shadows).
hyprctl reload

# Kitty: apply new palette to all running instances.
if command -v kitty &>/dev/null; then
    kitty @ set-colors --all ~/.config/kitty/matugen-colors.conf 2>/dev/null || true
fi

# Cava: SIGUSR1 causes in-place config reload (color section only).
pkill -USR1 cava 2>/dev/null || true

# Quickshell Colors.qml: FileView watcher on colors.json handles itself — no action needed.
# Zathura: reads zathurarc on open — no reload needed.
# Fastfetch: reads colors.jsonc on open — no reload needed.
# Thunar (GTK3): colors.css is written above; ~/.config/gtk-3.0/gtk.css @import's it.
#   GTK3 does not hot-reload CSS in a running process — close and reopen Thunar to see
#   the new palette. No automatic restart: user elected to handle this manually.