-- modules/autostart.lua
-- Autostart — all exec-once entries converted to hl.on("hyprland.start").
-- hl.exec_cmd() is async — no need for & or disown.

hl.on("hyprland.start", function()
    -- Wallpaper daemon
    hl.exec_cmd("awww-daemon")

    -- Restore last wallpaper if cached
    hl.exec_cmd("bash -c '[ -f ~/.cache/current_wallpaper ] && ~/.config/quickshell/scripts/wallpaper-change.sh \"$(cat ~/.cache/current_wallpaper)\"'")

    -- Quickshell
    -- NOTE: last line below also launches QS with overview config — remove one once settled
    hl.exec_cmd("quickshell")

    -- Idle daemon
    hl.exec_cmd("hypridle")

    -- Notification daemon
    -- TODO: remove swaync once QS Phase QS6 (notifications) is live
    hl.exec_cmd("swaync")

    -- Polkit agent
    -- TODO: remove hyperpolkitagent once QS Phase QS2b (polkit) is live
    hl.exec_cmd("systemctl --user start hyperpolkitagent")

    -- Removable media tray
    hl.exec_cmd("udiskie --tray")

    -- Clipboard manager
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Cursor
    hl.exec_cmd("hyprctl setcursor Nordzy-cursors 24")

    -- Quickshell overview (AMD GPU forced, 3s delay for compositor readiness)
    -- TODO: verify if this is still needed once main quickshell line above is stable
    hl.exec_cmd("bash -c 'sleep 3 && DRI_PRIME=0 AQ_DRM_DEVICES=/dev/dri/card2 /usr/bin/qs -c overview 2>/dev/null'")
end)
