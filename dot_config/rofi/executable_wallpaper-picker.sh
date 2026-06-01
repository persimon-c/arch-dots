#!/usr/bin/env bash
# ~/.config/rofi/wallpaper-picker.sh
# Generates Rofi thumbnail entries from ~/wallpapers/ recursively,
# launches Rofi in icon-grid mode, and passes the selected path to
# wallpaper-change.sh.
#
# Requires: tumbler (thumbnail generation), rofi-wayland, wallpaper-change.sh

set -euo pipefail

WALLPAPER_DIR="${HOME}/wallpapers"
THUMBNAIL_DIR="${HOME}/.cache/thumbnails/large"
CHANGE_SCRIPT="${HOME}/.config/hypr/scripts/wallpaper-change.sh"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify-send "Wallpaper Picker" "Wallpaper directory not found: $WALLPAPER_DIR" --urgency=critical
    exit 1
fi

# Ensure the thumbnail cache directory exists.
mkdir -p "$THUMBNAIL_DIR"

# Build a list of wallpaper files (jpg, jpeg, png, webp) from ~/wallpapers/ recursively.
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
    notify-send "Wallpaper Picker" "No wallpapers found in $WALLPAPER_DIR" --urgency=normal
    exit 0
fi

# Request tumbler to generate thumbnails for all wallpapers.
# tumblerd generates XDG-spec thumbnails in ~/.cache/thumbnails/ which Rofi
# can read directly with the -show-icons flag.
for WP in "${WALLPAPERS[@]}"; do
    tumbler "$WP" 2>/dev/null || true
done

# Build the Rofi entry list.
# Each entry is the filename (display label) with the full path as the icon
# using the XDG thumbnail URI format. Rofi with -show-icons will look up
# ~/.cache/thumbnails/ automatically via the file:// URI.
ROFI_ENTRIES=""
for WP in "${WALLPAPERS[@]}"; do
    BASENAME="$(basename "$WP")"
    ROFI_ENTRIES+="${BASENAME}\0icon\x1f${WP}\n"
done

# Launch Rofi in icon-grid mode.
SELECTED="$(printf "%b" "$ROFI_ENTRIES" | \
    rofi -dmenu \
         -p "Wallpaper" \
         -show-icons \
         -i \
         -theme-str 'listview { columns: 4; lines: 3; }' \
         -theme ~/.config/rofi/catppuccin-mocha.rasi \
    || true)"

if [[ -z "$SELECTED" ]]; then
    # User cancelled — do nothing.
    exit 0
fi

# Map the selected filename back to its full path.
for WP in "${WALLPAPERS[@]}"; do
    if [[ "$(basename "$WP")" == "$SELECTED" ]]; then
        exec "$CHANGE_SCRIPT" "$WP"
    fi
done

notify-send "Wallpaper Picker" "Could not resolve path for: $SELECTED" --urgency=normal
exit 1
