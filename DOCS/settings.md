# Settings GUI Plan

A Quickshell-based settings panel for tweaking Hyprland and desktop settings visually, without editing config files manually.

> **For Claude sessions:** paste this file + the relevant section of `hyprland_settings.md` + Quickshell API docs for `Process` and `PanelWindow` when building this. The settings GUI is built entirely in Quickshell QML using `Process` calls to write config values and `hyprctl reload` to apply them.

---

## Why Quickshell

Quickshell is the right tool for this because:
- It's already running as your shell — no extra process needed
- `Process` components can write to config files and call `hyprctl reload` directly
- Glassmorphism styling is consistent with the rest of the desktop out of the box
- No Electron, no GTK, no extra dependencies

The tradeoff is that changes write directly to your config files — Chezmoi should be committed after any settings change so your dotfiles stay in sync.

---

## How It Works

Each setting in the GUI maps to a specific line in a Hyprland config file. When you change a value:

1. The QML component updates its displayed value
2. A `Process` call runs a `sed` command to update the value in the relevant config file
3. `hyprctl reload` is called to apply the change live
4. A small toast notification confirms the change was applied

For settings that don't require a full reload (like opacity), `hyprctl keyword` is used instead for instant application without reloading the whole config.

```bash
# Example: change gaps_in live without full reload
hyprctl keyword general:gaps_in 8

# Example: write to file and reload
sed -i 's/gaps_in = .*/gaps_in = 8/' ~/.config/hypr/general.conf
hyprctl reload
```

---

## Trigger

**Keybind:** `Super + Shift + C` (C for Config) — to be added to `keybinds.md`

Opens as a floating centered panel — not anchored to the bar, not a sidebar. Closes on `Escape` or clicking outside.

---

## Layout

Floating centered panel, ~600px wide, scrollable. Glassmorphism card style, same as left sidebar.

Sections are collapsible — collapsed by default, expand on click. Each section is its own frosted card.

```
┌─────────────────────────────┐
│  ⚙ Settings          [×]   │
├─────────────────────────────┤
│  ▶ Windows & Gaps           │
│  ▶ Decoration & Blur        │
│  ▶ Animations               │
│  ▶ Input & Touchpad         │
│  ▶ Performance              │
│  ▶ Miscellaneous            │
└─────────────────────────────┘
```

---

## Sections & Controls

### Windows & Gaps

| Control | Type | Config key | Range |
|---|---|---|---|
| Inner gaps | Slider + number | `general:gaps_in` | 0–20 |
| Outer gaps | Slider + number | `general:gaps_out` | 0–30 |
| Border size | Slider + number | `general:border_size` | 0–5 |
| Border radius | Slider + number | `decoration:rounding` | 0–20 |
| Resize on border | Toggle | `general:resize_on_border` | on/off |

---

### Decoration & Blur

| Control | Type | Config key | Range |
|---|---|---|---|
| Active opacity | Slider (%) | `decoration:active_opacity` | 0.5–1.0 |
| Inactive opacity | Slider (%) | `decoration:inactive_opacity` | 0.5–1.0 |
| Blur enabled | Toggle | `decoration:blur:enabled` | on/off |
| Blur size | Slider + number | `decoration:blur:size` | 1–20 |
| Blur passes | Slider + number | `decoration:blur:passes` | 1–5 |
| Drop shadow | Toggle | `decoration:drop_shadow` | on/off |
| Shadow range | Slider + number | `decoration:shadow_range` | 0–30 |

**Note:** opacity and blur changes use `hyprctl keyword` for instant preview without full reload.

---

### Animations

| Control | Type | Config key |
|---|---|---|
| Animations enabled | Toggle | `animations:enabled` |
| Border angle shimmer | Toggle | `animation:borderangle` on/off |
| Border shimmer speed | Slider + number | borderangle speed value (1–60) |

---

### Input & Touchpad

| Control | Type | Config key |
|---|---|---|
| Tap-to-click | Toggle | `input:touchpad:tap-to-click` |
| Natural scroll | Toggle | `input:touchpad:natural_scroll` |
| Tap-to-drag | Toggle | `input:touchpad:tap-to-drag` |
| Disable while typing | Toggle | `input:touchpad:disable_while_typing` |
| Scroll factor | Slider | `input:touchpad:scroll_factor` | 0.5–2.0 |
| Mouse sensitivity | Slider | `input:sensitivity` | -1.0–1.0 |
| Follow mouse | Dropdown | `input:follow_mouse` | hover focus / click focus |
| Workspace swipe | Toggle | `gestures:workspace_swipe` |

---

### Performance

| Control | Type | Config key |
|---|---|---|
| Variable frame rate (VFR) | Toggle | `misc:vfr` |
| Variable refresh rate (VRR) | Dropdown | `misc:vrr` | Off / On / Fullscreen only |

---

### Miscellaneous

| Control | Type | Config key |
|---|---|---|
| Focus on activate | Toggle | `misc:focus_on_activate` |
| Terminal swallow | Toggle | `misc:enable_swallow` |
| Animate manual resizes | Toggle | `misc:animate_manual_resizes` |
| Animate window drag | Toggle | `misc:animate_mouse_windowdrag` |

---

## Implementation Notes

- **Reading current values:** on panel open, run `hyprctl getoption <key>` for each setting to populate the controls with current live values — not from the file, so they always reflect actual state
- **Writing values:** two-step — `hyprctl keyword` for instant preview, then write to file with `sed` so the value persists after reload
- **Reload strategy:** debounce — don't call `hyprctl reload` on every slider tick; call it 500ms after the user stops moving the slider
- **Chezmoi reminder:** show a small persistent banner at the bottom of the panel: "Remember to commit your dotfiles after making changes" — with a button that runs `chezmoi add ~/.config/hypr/` in a terminal
- **No undo:** changes are written immediately; if something breaks, revert via `hyprctl reload` with the last known good config from Chezmoi

---

## File Structure

```
~/.config/quickshell/
└── settings/
    ├── SettingsPanel.qml       # Main panel window
    ├── SettingsSection.qml     # Reusable collapsible section card
    ├── SliderControl.qml       # Labeled slider + number display
    ├── ToggleControl.qml       # Labeled toggle switch
    ├── DropdownControl.qml     # Labeled dropdown selector
    └── SettingsApplier.qml     # Process logic — hyprctl keyword + sed + reload
```

---

## Open Decisions (Resolve During Implementation)

| Decision | Notes |
|---|---|
| Keybind | `Super + Shift + C` — confirm not conflicting in keybinds.md before implementing |
| Chezmoi button behavior | Opens Kitty with the chezmoi command, or runs silently in background? |
| Slider precision | Integer sliders for gaps/rounding, decimal for opacity |
| Panel width | ~600px suggested — adjust to feel right on 1920x1080 |

---

## Monitor Settings

Controls display configuration. Writes to `~/.config/hypr/monitors.conf`.

| Control | Type | Config key | Notes |
|---|---|---|---|
| Resolution | Dropdown | `monitor` resolution field | Lists available resolutions from `hyprctl monitors` |
| Refresh rate | Dropdown | `monitor` refresh rate field | Lists available rates for selected resolution |
| Scale | Slider + number | `monitor` scale field | 1.0–2.0, step 0.25 |
| Position | X/Y number inputs | `monitor` position field | For multi-monitor setups |
| Transform/rotation | Dropdown | `monitor` transform field | Normal / 90° / 180° / 270° |

**Implementation note:** read current monitor info from `hyprctl monitors -j` on panel open. Writing monitor changes requires a full Hyprland reload — warn the user before applying since this is more disruptive than other settings.

---

## Bezier Curve Editor

A visual animation curve editor — drag handles to shape the bezier curve, see the easing preview in real time. Replaces typing raw bezier values blindly.

### Layout

```
┌─────────────────────────────────┐
│  Animation Curves               │
│                                 │
│  [  Canvas: curve preview  ]    │
│  • drag handles to reshape      │
│                                 │
│  P1: x [0.05] y [0.90]         │
│  P2: x [0.10] y [1.05]         │
│                                 │
│  Preset curves:                 │
│  [floaty] [smoothIn] [smoothOut]│
│  [linear] [ease] [ease-in-out] ]│
│                                 │
│  Name: [floaty      ] [Save]    │
│                                 │
│  Preview: [● animation ball]    │
└─────────────────────────────────┘
```

### Controls

| Control | Type | Notes |
|---|---|---|
| Curve canvas | QML Canvas, draggable handles | P1 and P2 control points, constrained to valid bezier range |
| P1 / P2 coordinate inputs | Number inputs | Sync with canvas drag; allow typing exact values |
| Preset buttons | Clickable pills | Load named presets — floaty, smoothIn, smoothOut, linear |
| Name field + Save button | Text input + button | Save current curve as a named preset to `~/.config/quickshell/settings/curves.json` |
| Animation preview ball | QML animation | A small ball that plays the curve animation so you can see exactly how it feels |
| Apply to dropdown | Dropdown | Pick which animation to apply this curve to (windows, workspaces, border, etc.) |

### Implementation Notes

- Canvas is a `QML Canvas` component — draw the bezier path using `ctx.bezierCurveTo`
- Handles are draggable `Rectangle` items anchored to the control point positions
- Preview ball uses `NumberAnimation` with the current curve values — replays on every curve change
- Saved curves written to `~/.config/quickshell/settings/curves.json` and referenced by name in `animations.conf`
- Writing a curve to config: `sed -i 's/bezier = floaty,.*/bezier = floaty, P1x, P1y, P2x, P2y/' ~/.config/hypr/animations.conf` then `hyprctl reload`

---

## Setting Profiles

Save and switch between named configuration presets. Each profile is a snapshot of all current settings.

### Layout

Appears as a pill row at the top of the settings panel, always visible regardless of which section is open:

```
┌─────────────────────────────────────┐
│  ⚙ Settings                   [×]  │
│  [Default] [Battery] [Gaming] [+]  │  ← profile pills
├─────────────────────────────────────┤
│  ▶ Windows & Gaps                   │
│  ...                                │
```

### Controls

| Control | Type | Notes |
|---|---|---|
| Profile pills | Clickable, active one highlighted | Switch instantly applies that profile's values |
| `+` button | Opens name input popup | Create new profile from current settings |
| Long-press or right-click pill | Context menu | Rename / Delete profile |

### Suggested Default Profiles

| Profile | Key differences |
|---|---|
| Default | Your standard values from `hyprland_settings.md` |
| Battery saver | VFR on, lower blur passes (1), animations disabled, lower opacity |
| Gaming | VRR fullscreen only, animations disabled, fullscreen opacity 1.0 |
| Ricing | Max blur, max rounding, slower animations for showing off |

### Implementation Notes

- Profiles stored as JSON in `~/.config/quickshell/settings/profiles.json`
- Each profile is a flat key-value map of every setting the GUI controls
- Switching a profile: iterate all values, run `hyprctl keyword` for each, then write to file, then `hyprctl reload` once at the end
- Active profile name persisted in `~/.cache/quickshell/active_profile` so it survives restarts

---

## Hyprlock Settings

Controls lock screen appearance. Writes to `~/.config/hypr/hyprlock.conf`.

| Control | Type | Notes |
|---|---|---|
| Clock format | Text input | e.g. `%H:%M` for 24hr, `%I:%M %p` for 12hr |
| Clock font size | Slider + number | 48–120px |
| Input field width | Slider + number | 200–600px |
| Input field rounding | Slider + number | 0–20 |
| Blur strength | Slider + number | Applied to wallpaper background |
| Fade in duration | Slider + number | ms |

**Implementation note:** Hyprlock changes don't apply live — they take effect on next lock. Show a note: "Changes apply on next lock."

---

## Swaync Settings

Controls notification center appearance and behavior. Writes to `~/.config/swaync/config.json` and `~/.config/swaync/style.css`, then calls `swaync-client --reload-config`.

| Control | Type | Notes |
|---|---|---|
| Position | Dropdown | Top-right / Top-left / Bottom-right / Bottom-left |
| Notification timeout | Slider + number | Seconds before auto-dismiss (1–30) |
| Max notifications shown | Slider + number | 1–10 |
| Do not disturb toggle | Toggle | Calls `swaync-client --dnd-on` / `--dnd-off` |

---

## Window Rules Editor

Visual editor for Hyprland window rules. Reads from and writes to `~/.config/hypr/windowrules.conf`.

### Layout

```
┌─────────────────────────────────────┐
│  Window Rules                       │
│  [+ Add rule]                       │
├─────────────────────────────────────┤
│  pavucontrol    float, center  [✎] [✕] │
│  blueman        float, center  [✎] [✕] │
│  thunar         float, center  [✎] [✕] │
└─────────────────────────────────────┘
```

### Controls

| Control | Type | Notes |
|---|---|---|
| Rule list | Scrollable list of cards | Each card shows app name + rules applied |
| Edit button per card | Opens edit popup | Change app name, rule type, parameters |
| Delete button per card | Removes rule | Writes updated file, reloads |
| Add rule button | Opens add popup | App name input + rule type dropdown + parameters |

### Rule Types Supported

- `float` — window always floats
- `workspace` — assign to specific workspace
- `size` — set default size
- `center` — center on screen
- `opacity` — per-app opacity override
- `noblur` — disable blur for this app
- `noborder` — disable border for this app

**Implementation note:** read existing rules from `windowrules.conf` on panel open; parse into a list of `{app, rule, value}` objects; write back as formatted `windowrulev2` lines on change.

---

## Updated File Structure

```
~/.config/quickshell/
└── settings/
    ├── SettingsPanel.qml         # Main panel — profile pills + section list
    ├── SettingsSection.qml       # Reusable collapsible section card
    ├── SliderControl.qml         # Labeled slider + number display
    ├── ToggleControl.qml         # Labeled toggle switch
    ├── DropdownControl.qml       # Labeled dropdown selector
    ├── SettingsApplier.qml       # Process logic — hyprctl keyword + sed + reload
    ├── BezierEditor.qml          # Visual curve editor with canvas + preview ball
    ├── ProfileManager.qml        # Profile pill row + save/switch/delete logic
    ├── WindowRulesEditor.qml     # Window rules list + add/edit/delete
    ├── MonitorSettings.qml       # Monitor resolution/scale/rotation
    ├── HyprlockSettings.qml      # Lock screen settings
    ├── SwayNCSettings.qml        # Notification center settings
    ├── curves.json               # Saved named bezier curves
    └── profiles.json             # Saved setting profiles
```

---

## Updated Layout

```
┌─────────────────────────────────────┐
│  ⚙ Settings                   [×]  │
│  [Default] [Battery] [Gaming] [+]  │
├─────────────────────────────────────┤
│  ▶ Windows & Gaps                   │
│  ▶ Decoration & Blur                │
│  ▶ Animations & Curves              │
│  ▶ Input & Touchpad                 │
│  ▶ Monitor                          │
│  ▶ Performance                      │
│  ▶ Window Rules                     │
│  ▶ Hyprlock                         │
│  ▶ Notifications (Swaync)           │
│  ▶ Miscellaneous                    │
├─────────────────────────────────────┤
│  ⚠ Remember to commit dotfiles      │
│  [chezmoi add ~/.config/hypr/]      │
└─────────────────────────────────────┘
```

---

## Updated Open Decisions

| Decision | Notes |
|---|---|
| Keybind | `Super + Shift + C` — confirmed in keybinds.md |
| Chezmoi button behavior | Opens Kitty with the chezmoi command, or runs silently? |
| Slider precision | Integer for gaps/rounding, decimal (0.01 step) for opacity |
| Panel width | ~600px — adjust to feel right on 1920x1080; may need ~700px with new sections |
| Profile switching animation | Instant or a brief crossfade between values? |
| Bezier curve canvas size | ~250x250px suggested |
| Window rules parser robustness | Handle both `windowrule` and `windowrulev2` syntax in existing configs |
| Swaync style.css editing | Simple variable substitution vs full CSS parsing — start with variables only |