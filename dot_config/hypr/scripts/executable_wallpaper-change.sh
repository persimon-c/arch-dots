#!/usr/bin/env bash
# ~/.config/hypr/scripts/wallpaper-change.sh
# Takes a wallpaper path as argument and runs the full wallpaper change sequence.
# Usage: wallpaper-change.sh /path/to/wallpaper.jpg

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

# 1. Apply wallpaper with bubble/grow transition expanding from cursor position.
#    The bezier .43,1.19,1,.4 creates the elastic overshoot that gives the
#    bubble its pop. --invert-y is required for correct cursor mapping on Wayland.
#    Falls back to 0,0 (top-left) if hyprctl cursorpos is unavailable.
CURSOR_POS="$(hyprctl cursorpos 2>/dev/null | grep -E '^[0-9]' || echo '0,0')"

awww img "$WALLPAPER" \
    --transition-bezier .43,1.19,1,.4 \
    --transition-type grow \
    --transition-duration 0.4 \
    --transition-fps 60 \
    --invert-y \
    --transition-pos "$CURSOR_POS" || true

# 2. Write the new wallpaper path to the cache file.
#    Hyprlock reads from this file on each lock so the lock screen wallpaper
#    always matches the desktop.
mkdir -p ~/.cache
ln -sf "$WALLPAPER" ~/.cache/current_wallpaper
echo "$WALLPAPER" > ~/.cache/current_wallpaper_path

# 3. Regenerate the matugen accent palette from the new wallpaper.
#    This writes to the template output files defined in ~/.config/matugen/config.toml
#    (colors.sh, colors.css, hypr/colors.conf, kitty/matugen-colors.conf).
matugen image "$WALLPAPER" --source-color-index 0

# 4. Reload affected apps.

# Hyprland: reloads colors.conf, picking up the new $accent variable for borders.
hyprctl reload

# Quickshell: file watcher handles itself — colors.qml reloads when
# ~/.config/matugen/colors.sh changes (requires Quickshell v0.3.0+).
# No manual reload needed here.

# Kitty: apply new accent colors to all running Kitty instances.
if command -v kitty &>/dev/null; then
    kitty @ set-colors --all ~/.config/kitty/matugen-colors.conf 2>/dev/null || true
fi

# Swaync: reload config to pick up new accent variables.
if command -v swaync-client &>/dev/null; then
    swaync-client --reload-config 2>/dev/null || true
fi

# Rofi and Hyprlock read their color files on each launch — no reload needed.

# Update fastfetch accent color from matugen output
if [[ -f ~/.config/fastfetch/colors.jsonc ]]; then
    ACCENT=$(grep -o '#[a-fA-F0-9]*' ~/.config/fastfetch/colors.jsonc | head -1)
    if [[ -n "$ACCENT" ]]; then
        sed -i "s|\"keys\": \"#[^\"]*\"|\"keys\": \"$ACCENT\"|g" ~/.config/fastfetch/config.jsonc
        sed -i "s|\"title\": \"#[^\"]*\"|\"title\": \"$ACCENT\"|g" ~/.config/fastfetch/config.jsonc
        sed -i "s|\"1\": \"#[^\"]*\"|\"1\": \"$ACCENT\"|g" ~/.config/fastfetch/config.jsonc
    fi

    # Update zathura accent color
    if [[ -f ~/.config/zathura/zathurarc ]]; then
        ACCENT=$(grep -o '#[a-fA-F0-9]*' ~/.config/fastfetch/colors.jsonc | head -1)
        if [[ -n "$ACCENT" ]]; then
            sed -i "s|set highlight-color.*|set highlight-color             \"${ACCENT}\"|" ~/.config/zathura/zathurarc
            sed -i "s|set highlight-active-color.*|set highlight-active-color      \"${ACCENT}\"|" ~/.config/zathura/zathurarc
            sed -i "s|set completion-highlight-fg.*|set completion-highlight-fg     \"${ACCENT}\"|" ~/.config/zathura/zathurarc
        fi
    fi
fi
