# Visual Aesthetics Plan

> **For Claude sessions:** paste the relevant app section + the Consistency Rules table + the config file location for that app from the Config File Locations section at the bottom. That is all the context needed.

A detailed plan for the visual identity of the Arch Linux desktop setup on the ASUS TUF Gaming FX505DT.

---

## Overall Mood

**Cozy, warm, and dreamy.** The desktop should feel like a soft, lived-in space — not sterile or overly technical. Anime illustrated scenery wallpapers set the tone, and every UI element reinforces that warmth rather than fighting it.

---

## Color Theme

- **Base theme:** Catppuccin Mocha — used as the permanent base and fallback
- **Dynamic accent:** matugen extracts a palette from the current wallpaper; the dominant warm/cool accent color from that palette overrides the Lavender accent at runtime
- **Blending approach:** Catppuccin Mocha base colors (Base, Mantle, Crust, Surface, Text) are hardcoded and never change — only accent colors (borders, highlights, active states, Cava bars, gauge fills) are dynamically replaced by matugen output
- **Fallback accent:** Lavender (`#b4befe`) — used on first boot before any wallpaper has been processed, and whenever matugen output is unavailable
- **Secondary accents (used sparingly):** Flamingo/Peach for warnings and urgent states — these remain fixed Catppuccin values regardless of wallpaper, since they carry semantic meaning (warning, low battery, urgent notification) and should not shift with the wallpaper mood
- **Philosophy:** The wallpaper influences the accent color, giving each wallpaper its own personality, while the Catppuccin Mocha base keeps the desktop feeling consistent and cozy regardless of which wallpaper is active

### Catppuccin Mocha Reference Palette

| Name | Hex | Usage |
|---|---|---|
| Base | `#1e1e2e` | Window backgrounds, panel backgrounds — hardcoded, never dynamic |
| Mantle | `#181825` | Deeper backgrounds, sidebar fill — hardcoded |
| Crust | `#11111b` | Outermost layer, bar background — hardcoded |
| Surface 0 | `#313244` | Widget card backgrounds — hardcoded |
| Surface 1 | `#45475a` | Subtle separators, inactive elements — hardcoded |
| Overlay 0 | `#6c7086` | Placeholder text, dimmed labels — hardcoded |
| Text | `#cdd6f4` | Primary text — hardcoded |
| Subtext 1 | `#bac2de` | Secondary text, timestamps — hardcoded |
| Lavender | `#b4befe` | Fallback accent — borders, highlights, active states (replaced dynamically by matugen at runtime) |
| Flamingo | `#f2cdcd` | Fixed secondary accent — warnings, energy states |
| Peach | `#fab387` | Fixed tertiary accent — notifications, battery low |

### matugen Integration

- **Tool:** `matugen` (AUR: `matugen`) — generates Material You palettes from wallpaper images
- **Mode:** `matugen image ~/wallpapers/current.jpg --type scheme-tonal-spot`
- **Output:** matugen writes generated colors to a template file; that file is sourced by Quickshell, Hyprland, Kitty, Rofi, and Swaync
- **Template location:** `~/.config/matugen/colors.css` and `~/.config/matugen/colors.sh` — one for CSS-based apps, one for shell-sourced configs
- **Which colors are replaced:** Only accent/primary colors from matugen output — base/surface/text colors remain hardcoded Catppuccin Mocha values
- **Add to package list:** `yay -S matugen`

---

## Wallpaper

- **Style:** Anime illustrated scenery — landscapes, nature, atmospheric scenes
- **Mood:** Soft lighting, warm or pastel tones, depth — think Studio Ghibli-adjacent or similar illustrated worlds
- **Avoid:** Dark/gritty art, character-focused illustrations (too busy behind windows), overly saturated neon scenes
- **Tool:** awww — supports smooth crossfade transitions between wallpapers
- **Transition:** Slow crossfade on wallpaper change, consistent with the floaty animation style of the rest of the desktop
- **Wallpaper directory:** `~/wallpapers/` — curate a small set here; subdirectories are fine (e.g. `~/wallpapers/day/`, `~/wallpapers/night/`)
- **Current wallpaper tracking:** The wallpaper-change script writes the active wallpaper path to `~/.cache/current_wallpaper` — Hyprlock reads from this file so the lock screen always matches the desktop

---

## Wallpaper Switcher

A Rofi-based wallpaper picker, inspired by HyDE's implementation. Triggered by a keybind (decided post-install).

### How It Works

1. A keybind triggers the wallpaper picker script
2. Rofi opens in a thumbnail grid view showing all wallpapers in `~/wallpapers/`
3. User selects a wallpaper
4. The wallpaper-change script runs in sequence:
   - awww applies the wallpaper with a bubble/grow transition expanding from the cursor position (see Transition Details below)
   - Writes the new path to `~/.cache/current_wallpaper`
   - `matugen image <path>` — regenerates accent palette from new wallpaper
   - Reloads affected apps: Hyprland (border colors), Quickshell (color file reload), Kitty (via kitty @ set-colors), Rofi (reads new colors file), Swaync (restart or reload)

### Scripts

**`~/.config/hypr/scripts/wallpaper-change.sh`**
The main chain script — takes a wallpaper path as argument and runs the full sequence above.

**`~/.config/rofi/wallpaper-picker.sh`**
Generates Rofi thumbnail entries from `~/wallpapers/`, launches Rofi in icon-grid mode, passes the selected path to `wallpaper-change.sh`.

### Thumbnail Generation

Rofi needs image thumbnails to show the grid. Options:
- **tumbler** — generates thumbnails on demand, integrates with Thunar; install with `sudo pacman -S tumbler`
- **Cached thumbnails:** stored in `~/.cache/thumbnails/` per XDG spec — most apps (including Rofi with the right plugin) read from here automatically

### App Reload Strategy Per App

| App | Reload method |
|---|---|
| Hyprland borders | `hyprctl reload` or write colors directly to `~/.config/hypr/colors.conf` and reload |
| Quickshell | Quickshell file watcher auto-reloads on color file change (v0.3.0+) |
| Kitty | `kitty @ set-colors --all ~/.config/kitty/matugen-colors.conf` |
| Rofi | Reads color file on each launch — no reload needed |
| Swaync | `swaync-client --reload-config` |
| Hyprlock | Reads color file on each lock — no reload needed |

### Keybind

Confirmed: `SUPER + W` — Super+W is reserved exclusively for wallpaper switcher across all config files. Super+Q is close window.

### Transition Details

Sourced directly from HyDE's `wallpaper.awww.sh`. The bubble effect comes from the bezier overshoot and grow transition expanding from the cursor.

**Next wallpaper (grow from cursor):**
```bash
awww img <path> \
  --transition-bezier .43,1.19,1,.4 \
  --transition-type grow \
  --transition-duration 0.4 \
  --transition-fps 60 \
  --invert-y \
  --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")"
```

**Previous wallpaper (outer — reverse bubble, shrinks inward):**
```bash
awww img <path> \
  --transition-bezier .43,1.19,1,.4 \
  --transition-type outer \
  --transition-duration 0.4 \
  --transition-fps 60 \
  --invert-y \
  --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")"
```

- **Bezier `.43,1.19,1,.4`** — the `1.19` exceeds 1.0, creating the elastic overshoot that gives the bubble its pop
- **`--invert-y`** — required for correct cursor position mapping on Wayland/Hyprland
- **`--transition-pos` from `hyprctl cursorpos`** — bubble expands from wherever your cursor is; falls back to top-left `0,0` if cursor position is unavailable
- **`grow` vs `outer`** — grow for next, outer for previous; gives directional switching a satisfying visual symmetry

---

## Window Appearance

### Borders

- **Style:** Gradient border on the active window
- **Gradient:** Dynamic accent color → Flamingo (`#f2cdcd`) — the accent end shifts with the wallpaper, the Flamingo end stays warm and fixed
- **Fallback gradient:** Lavender → Flamingo (`#b4befe` → `#f2cdcd`) before first wallpaper is processed
- **Border size:** 2px — present but not heavy
- **Inactive windows:** No border, or a very faint Surface 1 border — attention stays on the active window
- **Border radius:** Large — rounded and soft, consistent with the puffy, cozy feel

### Opacity

- **Active window:** `0.92` — slightly transparent, wallpaper bleeds through subtly
- **Inactive windows:** `0.80` — noticeably dimmed, no desaturation — purely opacity-based distinction
- **Terminal (Kitty):** Slightly more transparent than other windows, around `0.88` — terminals feel more at home with more bleed-through

### Blur

- **Strength:** Light — enough to frost the glass effect, not so heavy that it looks muddy
- **Blur size:** `8`
- **Blur passes:** `3`
- **New optimizations:** Enabled
- **Philosophy:** The wallpaper should be recognizable through the blur, not completely obscured — the scenery is part of the aesthetic

### Drop Shadow

- **Enabled:** Yes
- **Color:** Dark, low opacity — subtle depth, not dramatic
- **Offset:** Small — just enough to lift windows off the wallpaper

---

## Animations

### Philosophy

Smooth and slow with a floaty feel — every motion should feel like it has gentle weight. Nothing snaps or jerks. The desktop breathes.

### Window Open / Close

- **Style:** Fade in / fade out
- **Duration:** Medium-slow — around `250–300ms`
- **Curve:** `ease-out` on open (starts fast, settles softly), `ease-in` on close (accelerates gently out)

### Workspace Switching

- **Style:** Slide horizontally
- **Duration:** `300–350ms`
- **Curve:** `ease-in-out` — symmetrical, smooth slide

### Window Move / Resize

- **Duration:** `200ms`
- **Curve:** `ease-out`

### Hyprland Animation Config Reference

```ini
# ~/.config/hypr/animations.conf
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

Note: `borderangle` with `loop` animates the gradient border angle continuously — gives the active window border a slow, living shimmer. Adjust the speed (currently `30`) to taste.

Note: `smoothOut` bezier (`0.36, 0, 0.66, -0.56`) has a negative Y value causing a slight overshoot on close — test this after first boot and soften to `0.36, 0, 0.66, 0` if it feels too bouncy against the "nothing jerks" philosophy.

---

## Fonts

| Usage | Font | Size |
|---|---|---|
| UI / system | JetBrains Mono Nerd Font | 11–12px |
| Terminal | JetBrains Mono Nerd Font | 13px |
| Bar (Quickshell) | JetBrains Mono Nerd Font | 11px |
| Emoji fallback | Noto Emoji | — |
| CJK fallback | Noto Sans CJK | — |

- **Font rendering:** Subpixel antialiasing, slight hinting — configured via `/etc/fonts/local.conf`
- **Rationale:** JetBrains Mono is already planned for the terminal; using it system-wide keeps the aesthetic consistent and avoids mixing typefaces

---

## Hyprlock (Lock Screen)

- **Theme:** Catppuccin Mocha base, dynamic accent from matugen
- **Background:** Blurred version of the current wallpaper — reads path from `~/.cache/current_wallpaper`
- **Clock:** Large, centered, JetBrains Mono
- **Input field:** Rounded pill, glassmorphism style consistent with the rest of the desktop
- **Mood:** Same cozy dreamy feel as the desktop — waking the screen should feel like a gentle return, not a jarring shift

---

## SDDM (Login Screen)

- **Theme:** Pixel art theme sourced from GitHub — warm, anime-adjacent aesthetic
- **Catppuccin colors applied** where the theme supports it
- **Font:** JetBrains Mono Nerd Font
- **Goal:** The login screen sets the first impression — it should already feel like the desktop before you're even in
- **Note:** SDDM runs before login so it does not participate in dynamic theming — Catppuccin Mocha colors are hardcoded here

---

## Kitty Terminal

- **Color scheme:** Catppuccin Mocha base + dynamic accent from matugen
- **Background opacity:** `0.88` — slightly more transparent than windows
- **Font:** JetBrains Mono Nerd Font, 13px
- **Cursor:** Beam style, dynamic accent color (Lavender fallback)
- **Cursor trail:** Enabled (`cursor_trail 1`)
- **Padding:** Comfortable internal padding — the terminal shouldn't feel cramped
- **Dynamic reload:** `kitty @ set-colors --all ~/.config/kitty/matugen-colors.conf` called by wallpaper-change script

---

## Rofi (App Launcher)

- **Theme:** Catppuccin Mocha base + dynamic accent from matugen color file
- **Style:** Centered floating panel, rounded corners, glassmorphism background
- **Width:** Narrow — just wide enough for app names, not full screen
- **Mood:** Should feel like a soft overlay appearing over the wallpaper, not a system dialog
- **Wallpaper picker mode:** Separate Rofi invocation in icon-grid mode — triggered by wallpaper keybind, not the app launcher keybind

---

## Swaync (Notification Center)

- **Theme:** Catppuccin Mocha base + dynamic accent from matugen
- **Position:** Top-right, slides in from the right edge
- **Notification cards:** Rounded, glassmorphism, consistent with sidebar widget cards
- **Accent:** Dynamic accent for general notifications, Peach (`#fab387`) for urgent ones — Peach stays fixed since it carries semantic meaning
- **Reload:** `swaync-client --reload-config` called by wallpaper-change script

---

## Zellij

- **Theme:** Catppuccin Mocha — official theme at `github.com/catppuccin/zellij`
- **Status bar:** minimal — show current mode, tab name, session name only
- **Font:** JetBrains Mono Nerd Font (inherits from Kitty)
- **Config file:** `~/.config/zellij/config.kdl`

### Layouts

**Plain layout** (`Super + Z`) — no pre-split panes, just a clean terminal. Default session.

**Dev layout** (`Super + Shift + Z`) — three panes:
- Left/main: full-height terminal (editor or shell)
- Bottom-right: logs / command output pane
- Top-right: lazygit pane

Layout file: `~/.config/zellij/layouts/dev-layout.kdl`

---

## lazygit

- **Theme:** Catppuccin Mocha — set in `~/.config/lazygit/config.yml`; official theme at `github.com/catppuccin/lazygit`
- **Lives inside:** Zellij top-right pane in dev layout, or standalone in any terminal
- **Config file:** `~/.config/lazygit/config.yml`

---

## Consistency Rules

These apply across every UI surface:

| Rule | Value |
|---|---|
| Border radius | Large and consistent everywhere — no mixing sharp and round |
| Blur | Light, same strength across all surfaces |
| Opacity | Active `0.92`, inactive `0.80`, terminal `0.88` |
| Accent usage | Dynamic accent primary (Lavender fallback), Flamingo/Peach only for fixed semantic states |
| Font | JetBrains Mono Nerd Font everywhere |
| Shadows | Subtle, consistent offset and spread across all surfaces |
| Gradient direction | Consistent angle across all gradient borders and accents |
| Base colors | Catppuccin Mocha Base/Mantle/Crust/Surface/Text — never dynamic, always hardcoded |

---

## Config File Locations

| App | Config path |
|---|---|
| Hyprland | `~/.config/hypr/` |
| Hyprland colors | `~/.config/hypr/colors.conf` — generated by matugen, sourced by hyprland.conf |
| Kitty | `~/.config/kitty/kitty.conf` |
| Kitty dynamic colors | `~/.config/kitty/matugen-colors.conf` — generated by matugen |
| Rofi | `~/.config/rofi/catppuccin-mocha.rasi` |
| Rofi wallpaper picker | `~/.config/rofi/wallpaper-picker.sh` |
| Zellij | `~/.config/zellij/config.kdl` |
| Zellij dev layout | `~/.config/zellij/layouts/dev-layout.kdl` |
| lazygit | `~/.config/lazygit/config.yml` |
| Yazi | `~/.config/yazi/yazi.toml` |
| Hyprlock | `~/.config/hypr/hyprlock.conf` |
| Hypridle | `~/.config/hypr/hypridle.conf` |
| Swaync | `~/.config/swaync/style.css` |
| SDDM | `/usr/share/sddm/themes/<theme-name>/` |
| Quickshell | `~/.config/quickshell/` |
| Quickshell colors | `~/.config/quickshell/colors.qml` — generated by matugen |
| Cava | `~/.config/cava/config` |
| matugen templates | `~/.config/matugen/` |
| matugen output (CSS) | `~/.config/matugen/colors.css` |
| matugen output (shell) | `~/.config/matugen/colors.sh` |
| Wallpaper change script | `~/.config/hypr/scripts/wallpaper-change.sh` |
| Wallpaper picker script | `~/.config/rofi/wallpaper-picker.sh` |
| Current wallpaper cache | `~/.cache/current_wallpaper` |
| Wallpaper directory | `~/wallpapers/` |
| Chezmoi | `~/.local/share/chezmoi/` |