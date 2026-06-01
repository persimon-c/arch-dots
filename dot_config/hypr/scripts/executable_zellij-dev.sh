#!/usr/bin/env bash
# Pick a repo from ~/Repo and open zellij dev layout in it.

REPO=$(find ~/Repo -maxdepth 2 -name ".git" -type d | sed 's|/.git||' | sort | \
    rofi -dmenu -p "Open repo" -theme ~/.config/rofi/catppuccin-mocha.rasi)

[[ -z "$REPO" ]] && exit 0

exec kitty --directory "$REPO" -e zellij --layout ~/.config/zellij/layouts/dev-layout.kdl
