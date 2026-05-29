# Hyprland Settings

All decided values for Hyprland's configuration blocks. This document is the source of truth for every non-keybind, non-windowrule Hyprland setting.

---

## general

Controls window gaps, borders, layout, and cursor behavior.

```ini
general {
    gaps_in = 5               # Gap between windows
    gaps_out = 10             # Gap between windows and screen edge
    border_size = 2           # Border thickness in pixels
    layout = dwindle          # Tiling layout

    # Colors set dynamically via ~/.config/hypr/colors.conf (matugen output)
    # col.active_border = gradient: dynamic accent → Flamingo, angle 45deg
    # col.inactive_border = Surface 1 (#45475a), very faint

    resize_on_border = true   # Click and drag window border to resize
    extend_border_grab_area = 10  # Extra grab area around borders
}
```

**Notes:**
- `gaps_in` and `gaps_out` give the desktop breathing room consistent with the cozy aesthetic
- `resize_on_border` means you don't need to enter resize submap for quick adjustments — just drag the border
- Border colors are written by matugen to `colors.conf` on wallpaper change — do not hardcode here

---

## decoration

Controls blur, opacity, shadows, and rounding.

```ini
decoration {
    rounding = 12             # Border radius — large and soft, consistent everywhere

    active_opacity = 0.92
    inactive_opacity = 0.80
    fullscreen_opacity = 1.0  # Fullscreen windows are always fully opaque

    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = true
        xray = false          # Don't blur through layered surfaces
        ignore_opacity = false
    }

    drop_shadow = true
    shadow_range = 12         # Shadow spread — subtle, not dramatic
    shadow_render_power = 2
    shadow_offset = 2 4       # Slight downward offset to lift windows off wallpaper
    col.shadow = rgba(11111b99) # Crust color at ~60% opacity — dark but not black
    col.shadow_inactive = rgba(11111b55) # Lighter shadow for inactive windows
}
```

**Notes:**
- `rounding = 12` matches the large rounded aesthetic across all surfaces in `visuals.md`
- `fullscreen_opacity = 1.0` — games and fullscreen apps should always be fully opaque
- Shadow color uses Catppuccin Crust (`#11111b`) so it feels native to the theme

---

## animations

```ini
animations {
    enabled = true

    bezier = floaty, 0.05, 0.9, 0.1, 1.05
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    bezier = smoothIn, 0.25, 1, 0.5, 1

    animation = windows, 1, 5, smoothIn, fade
    animation = windowsOut, 1, 5, smoothOut, fade
    animation = windowsMove, 1, 4, floaty
    animation = workspaces, 1, 6, floaty, slide
    animation = fadeIn, 1, 5, smoothIn
    animation = fadeOut, 1, 5, smoothOut
    animation = border, 1, 8, default
    animation = borderangle, 1, 30, default, loop
}
```

**Notes:**
- `borderangle` loop gives the gradient border a slow living shimmer — adjust speed (`30`) to taste post-install
- `smoothOut` bezier has a slight overshoot (`-0.56`) — test on first boot, soften to `0.36, 0, 0.66, 0` if it feels too bouncy
- See `visuals.md` Animations section for full rationale

---

## input

Controls keyboard, touchpad, and mouse behavior.

```ini
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1          # Focus follows mouse — hover to focus, click to raise
    mouse_refocus = true

    sensitivity = 0           # 0 = no acceleration, raw input
    accel_profile = flat      # Flat acceleration — predictable mouse movement

    touchpad {
        natural_scroll = true
        tap-to-click = true
        tap-to-drag = true
        drag_lock = false
        disable_while_typing = true   # Prevent accidental touches while typing
        scroll_factor = 1.0
        clickfinger_behavior = false  # Use button zones, not finger count
    }
}
```

**Notes:**
- `follow_mouse = 1` focuses windows on hover but doesn't raise them — you still click to bring a window to front. Set to `2` if you want click-to-focus only
- `disable_while_typing = true` prevents cursor jumping when your palm grazes the touchpad
- `sensitivity = 0` with `accel_profile = flat` gives raw mouse input — good for gaming and precise work

---

## gestures

Touchpad swipe gestures.

```ini
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
    workspace_swipe_invert = true
    workspace_swipe_min_speed_to_force = 30
    workspace_swipe_cancel_ratio = 0.5
    workspace_swipe_create_new = false  # Don't create new workspaces by swiping past the last one
}
```

**Notes:**
- 3-finger swipe left/right switches workspaces — natural and consistent with the natural scroll direction
- `workspace_swipe_create_new = false` prevents accidentally creating empty workspaces

---

## misc

Various Hyprland behaviors.

```ini
misc {
    disable_hyprland_logo = true        # Remove Hyprland logo from empty workspaces
    disable_splash_rendering = true     # Remove random quote on startup
    mouse_move_enables_dpms = true      # Moving mouse wakes display
    key_press_enables_dpms = true       # Keypresses also wake display
    animate_manual_resizes = true       # Resizes play the animation
    animate_mouse_windowdrag = true     # Window drag plays the animation
    enable_swallow = true               # Terminal swallows child GUI apps
    swallow_regex = ^(kitty)$           # Only Kitty swallows
    focus_on_activate = false           # Don't steal focus when an app requests it
    vfr = true                          # Variable frame rate — reduces GPU usage when idle; good for battery
    vrr = 0                             # Variable refresh rate — 0 = off, 1 = on, 2 = fullscreen only
}
```

**Notes:**
- `enable_swallow` with `swallow_regex = ^(kitty)$` means when you open a GUI app from Kitty (e.g. `thunar .`), the terminal window hides and reappears when you close the app — clean behavior
- `focus_on_activate = false` prevents apps like Discord or browser notifications from stealing your focus mid-typing
- `vfr = true` is important for battery life on the FX505DT — reduces GPU polling when the screen is idle
- `vrr = 0` — leave off for now; enable later if you notice screen tearing in games (set to `2` for fullscreen only)

---

## dwindle (layout)

```ini
dwindle {
    pseudotile = true         # Super+P toggles pseudotile — window acts tiled but respects its own size hints
    preserve_split = true     # Remember split direction when closing windows
    smart_split = false
    smart_resizing = true
}
```

---

## binds

Behavior settings for keybinds (not the binds themselves — those are in keybinds.md).

```ini
binds {
    allow_workspace_cycles = true   # Super+Scroll wraps around from last to first workspace
    workspace_back_and_forth = true # Pressing current workspace number goes back to previous
}
```

**Notes:**
- `workspace_back_and_forth = true` means pressing `Super + 2` when already on workspace 2 jumps back to wherever you were before — very handy

---

## env

Environment variables sourced by Hyprland on startup. These go in `env.conf`.

```ini
# Wayland
env = WAYLAND_DISPLAY,wayland-0
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = XDG_CURRENT_DESKTOP,Hyprland

# NVIDIA PRIME offload
env = __NV_PRIME_RENDER_OFFLOAD,1
env = __NV_PRIME_RENDER_OFFLOAD_PROVIDER,NVIDIA-G0
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = __VK_LAYER_NV_optimus,NVIDIA_only

# Qt Wayland
env = QT_QPA_PLATFORM,wayland
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

# GTK
env = GDK_BACKEND,wayland,x11
env = SDL_VIDEODRIVER,wayland

# Cursor
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,Catppuccin-Mocha-Dark
```

---

## Open Decisions (Resolve Post-Install)

| Setting | Notes |
|---|---|
| `gaps_in` / `gaps_out` exact values | Start with 5/10 — adjust to taste visually |
| `rounding` exact value | Start with 12 — increase if it looks too sharp, decrease if too round |
| `shadow_range` and `shadow_offset` | Tune visually after first boot |
| `follow_mouse` value | Try `1` first; switch to `2` (click-to-focus) if hover focus feels annoying |
| `vrr` | Leave `0`; enable `2` (fullscreen only) if screen tearing appears in games |
| `borderangle` speed | `30` is a starting point — tune to taste |
| Cursor theme | `Catppuccin-Mocha-Dark` — install via AUR: `yay -S catppuccin-cursors-mocha` |