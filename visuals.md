# Visual Aesthetics Plan

A detailed plan for the visual identity of the Arch Linux desktop setup on the ASUS TUF Gaming FX505DT.

---

## Overall Mood

**Cozy, warm, and dreamy.** The desktop should feel like a soft, lived-in space — not sterile or overly technical. Anime illustrated scenery wallpapers set the tone, and every UI element reinforces that warmth rather than fighting it.

---

## Color Theme

- **Base theme:** Catppuccin Mocha
- **Accent color:** Lavender (`#b4befe`)
- **Secondary accents (used sparingly):** Pink/Flamingo for warnings or highlights, Peach for notifications or energy indicators
- **Philosophy:** A few colors used intentionally — not monochrome, not rainbow. Lavender is the dominant accent; other colors appear only where they carry meaning (e.g. warning states, active states, battery low)

### Catppuccin Mocha Reference Palette

| Name | Hex | Usage |
|---|---|---|
| Base | `#1e1e2e` | Window backgrounds, panel backgrounds |
| Mantle | `#181825` | Deeper backgrounds, sidebar fill |
| Crust | `#11111b` | Outermost layer, bar background |
| Surface 0 | `#313244` | Widget card backgrounds |
| Surface 1 | `#45475a` | Subtle separators, inactive elements |
| Overlay 0 | `#6c7086` | Placeholder text, dimmed labels |
| Text | `#cdd6f4` | Primary text |
| Subtext 1 | `#bac2de` | Secondary text, timestamps |
| Lavender | `#b4befe` | Primary accent — borders, highlights, active states |
| Flamingo | `#f2cdcd` | Secondary accent — warnings, energy |
| Peach | `#fab387` | Tertiary accent — notifications, battery low |

---

## Wallpaper

- **Style:** Anime illustrated scenery — landscapes, nature, atmospheric scenes
- **Mood:** Soft lighting, warm or pastel tones, depth — think Studio Ghibli-adjacent or similar illustrated worlds
- **Avoid:** Dark/gritty art, character-focused illustrations (too busy behind windows), overly saturated neon scenes
- **Tool:** swww — supports smooth crossfade transitions between wallpapers
- **Transition:** Slow crossfade on wallpaper change, consistent with the floaty animation style of the rest of the desktop
- **Wallpaper collection:** Curate a small set of wallpapers in `~/wallpapers/` — swww can cycle through them or a keybind can switch manually

---

## Window Appearance

### Borders

- **Style:** Gradient border on the active window
- **Gradient:** Lavender → Pink/Flamingo (`#b4befe` → `#f2cdcd`) — soft, warm, dreamy
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

- **Theme:** Catppuccin Mocha, Lavender accent
- **Background:** Blurred version of the current wallpaper — not a separate image
- **Clock:** Large, centered, JetBrains Mono
- **Input field:** Rounded pill, glassmorphism style consistent with the rest of the desktop
- **Mood:** Same cozy dreamy feel as the desktop — waking the screen should feel like a gentle return, not a jarring shift

---

## SDDM (Login Screen)

- **Theme:** Pixel art theme sourced from GitHub — warm, anime-adjacent aesthetic
- **Catppuccin colors applied** where the theme supports it
- **Font:** JetBrains Mono Nerd Font
- **Goal:** The login screen sets the first impression — it should already feel like the desktop before you're even in

---

## Kitty Terminal

- **Color scheme:** Catppuccin Mocha
- **Background opacity:** `0.88` — slightly more transparent than windows
- **Font:** JetBrains Mono Nerd Font, 13px
- **Cursor:** Beam style, Lavender color
- **Padding:** Comfortable internal padding — the terminal shouldn't feel cramped

---

## Rofi (App Launcher)

- **Theme:** Catppuccin Mocha, Lavender accent
- **Style:** Centered floating panel, rounded corners, glassmorphism background
- **Width:** Narrow — just wide enough for app names, not full screen
- **Mood:** Should feel like a soft overlay appearing over the wallpaper, not a system dialog

---

## Swaync (Notification Center)

- **Theme:** Catppuccin Mocha
- **Position:** Top-right, slides in from the right edge
- **Notification cards:** Rounded, glassmorphism, consistent with sidebar widget cards
- **Accent:** Lavender for general notifications, Peach for urgent ones

---

## Consistency Rules

These apply across every UI surface:

| Rule | Value |
|---|---|
| Border radius | Large and consistent everywhere — no mixing sharp and round |
| Blur | Light, same strength across all surfaces |
| Opacity | Active `0.92`, inactive `0.80`, terminal `0.88` |
| Accent usage | Lavender primary, Flamingo/Peach only for state (warning, urgent, low battery) |
| Font | JetBrains Mono Nerd Font everywhere |
| Shadows | Subtle, consistent offset and spread across all surfaces |
| Gradient direction | Consistent angle across all gradient borders and accents |