-- modules/env.lua
-- Environment variables — set before display server initialization.
-- AMD primary GPU + NVIDIA PRIME offload setup.

-- AMD primary GPU (card2 = radeonsi)
hl.env("AQ_DRM_DEVICES", "/dev/dri/card2")
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- NVIDIA PRIME offload
hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
hl.env("__NV_PRIME_RENDER_OFFLOAD_PROVIDER", "NVIDIA-GO")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

-- XDG / Wayland session
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")

-- Qt Wayland
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Dark mode preference
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_STYLE_OVERRIDE", "kvantum-dark")

-- GTK / SDL
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")

-- Cursor
hl.env("HYPRCURSOR_THEME", "Nordzy-hyprcursors-catppuccin-mocha-mauve")
hl.env("HYPRCURSOR_SIZE", "24")

-- XCursor fallback for GTK/XWayland apps
hl.env("XCURSOR_THEME", "catppuccin-mocha-mauve-cursors")
hl.env("XCURSOR_SIZE", "24")

-- Flatpak data dirs
hl.env("XDG_DATA_DIRS", "/var/lib/flatpak/exports/share:" .. os.getenv("HOME") .. "/.local/share/flatpak/exports/share:/usr/local/share:/usr/share")