#!/bin/bash
# ~/.config/quickshell/scripts/cliphist-decode.sh

line="$1"
if [ -z "$line" ]; then
    echo "Usage: cliphist-decode.sh <cliphist-line>" >&2
    exit 1
fi

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

if ! printf "%s" "$line" | cliphist decode > "$tmpfile" 2>/dev/null; then
    id=$(printf "%s" "$line" | cut -f1)
    if ! cliphist decode "$id" > "$tmpfile" 2>/dev/null; then
        echo "Error: Failed to decode cliphist entry" >&2
        exit 1
    fi
fi

# Detect MIME type
mime_type=$(file -b --mime-type "$tmpfile")

if [ -z "$mime_type" ] || [ "$mime_type" = "cannot open" ]; then
    mime_type="text/plain"
fi

# Copy to clipboard
if [[ "$mime_type" == image/* ]]; then
    wl-copy -t "$mime_type" < "$tmpfile"
    exit 2
else
    wl-copy -t "$mime_type" < "$tmpfile"
    sleep 0.05
    hyprctl dispatch sendshortcut "CONTROL, V, activewindow"
    exit 0
fi
