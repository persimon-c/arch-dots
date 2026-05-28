# Keybinds Reference

All keybinds for the Arch Linux / Hyprland setup on the ASUS TUF Gaming FX505DT.

> **For Claude sessions:** paste this entire file when writing `keybinds.conf` or any config that references keybinds. This is the single source of truth — `keybinds.conf` must mirror this document exactly.

---

## Conventions

- `Super` = Windows key
- `Print` = PrtSc key
- Directional keys = arrow keys only (no vim h/j/k/l)
- All workspace binds cover 1–9
- Submaps are modal layers — a submap stays active until explicitly exited with `Escape`

---

## Window Management

| Keybind | Action |
|---|---|
| `Super + Q` | Close active window |
| `Super + F` | Toggle fullscreen |
| `Super + Shift + F` | Toggle floating |
| `Super + P` | Toggle pseudo-tiling |
| `Super + Up` | Focus window above |
| `Super + Down` | Focus window below |
| `Super + Left` | Focus window left |
| `Super + Right` | Focus window right |
| `Super + Shift + Up` | Move window up |
| `Super + Shift + Down` | Move window down |
| `Super + Shift + Left` | Move window left |
| `Super + Shift + Right` | Move window right |
| `Super + Ctrl + Up` | Resize window up |
| `Super + Ctrl + Down` | Resize window down |
| `Super + Ctrl + Left` | Resize window left |
| `Super + Ctrl + Right` | Resize window right |
| `Super + Tab` | Cycle focus to next window |
| `Super + Shift + Tab` | Cycle focus to previous window |
| `Alt + Tab` | Cycle to next window (current workspace) |
| `Alt + Shift + Tab` | Cycle to previous window (current workspace) |

---

## Applications

| Keybind | Action |
|---|---|
| `Super + Return` | Kitty terminal |
| `Super + Space` | Rofi app launcher |
| `Super + B` | Brave browser |
| `Super + A` | Antigravity editor |
| `Super + S` | Sublime Text |
| `Super + T` | Thunar file manager |
| `Super + D` | Discord |
| `Super + V` | VSCode |
| `Super + Shift + V` | Clipboard history (cliphist + Rofi) |
| `Super + W` | Wallpaper switcher (Rofi picker) |
| `Super + N` | Toggle Swaync notification panel |
| `Super + G` | Toggle right sidebar (Git/Repo panel) |
| `Super + E` | Yazi file manager (in Kitty) |
| `Super + Z` | Zellij (plain, no layout) |
| `Super + Shift + Z` | Zellij dev layout (main + logs + lazygit) |
| `Super + C` | Color picker (hyprpicker — hex to clipboard + notification) |

---

## Workspaces

| Keybind | Action |
|---|---|
| `Super + 1` | Switch to workspace 1 |
| `Super + 2` | Switch to workspace 2 |
| `Super + 3` | Switch to workspace 3 |
| `Super + 4` | Switch to workspace 4 |
| `Super + 5` | Switch to workspace 5 |
| `Super + 6` | Switch to workspace 6 |
| `Super + 7` | Switch to workspace 7 |
| `Super + 8` | Switch to workspace 8 |
| `Super + 9` | Switch to workspace 9 |
| `Super + Shift + 1` | Move window to workspace 1 |
| `Super + Shift + 2` | Move window to workspace 2 |
| `Super + Shift + 3` | Move window to workspace 3 |
| `Super + Shift + 4` | Move window to workspace 4 |
| `Super + Shift + 5` | Move window to workspace 5 |
| `Super + Shift + 6` | Move window to workspace 6 |
| `Super + Shift + 7` | Move window to workspace 7 |
| `Super + Shift + 8` | Move window to workspace 8 |
| `Super + Shift + 9` | Move window to workspace 9 |
| `Super + Scroll Up` | Cycle to next workspace |
| `Super + Scroll Down` | Cycle to previous workspace |
| `Super + Ctrl + Right` | Move to next workspace |
| `Super + Ctrl + Left` | Move to previous workspace |

---

## Screenshots

| Keybind | Action | Tool |
|---|---|---|
| `Print` | Full screen screenshot (direct) | grimblast |
| `Super + Print` | Region screenshot (direct) | grimblast |
| `Super + Shift + Print` | Enter screenshot submap — choose type interactively | see Submaps section |

Direct binds save to `~/Pictures/screenshots/` with a timestamp filename. Clipboard-only option is inside the submap (`C` key).

---

## Media and Audio

| Keybind | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume up 5% |
| `XF86AudioLowerVolume` | Volume down 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioPlay` | Play / pause (playerctl) |
| `XF86AudioNext` | Next track (playerctl) |
| `XF86AudioPrev` | Previous track (playerctl) |
| `XF86AudioStop` | Stop playback (playerctl) |

---

## Brightness

| Keybind | Action | Tool |
|---|---|---|
| `XF86MonBrightnessUp` | Brightness up | brightnessctl |
| `XF86MonBrightnessDown` | Brightness down | brightnessctl |

Add `brightnessctl` to package list — `sudo pacman -S brightnessctl`.

---

## System

| Keybind | Action |
|---|---|
| `Super + L` | Lock screen (hyprlock) — also available inside System submap |
| `Super + Shift + R` | Reload Hyprland config |
| `Super + Shift + Q` | Quickshell reload |
| `Super + Shift + S` | Enter System submap (suspend / reboot / shutdown / exit Hyprland) |

---

## Quickshell Interactions

These are not Hyprland keybinds — they are mouse interactions handled entirely within Quickshell. Documented here for reference so nothing is missed during implementation.

| Element | Interaction | Action |
|---|---|---|
| Arch logo pill | Click | Open / close left sidebar |
| Workspace number | Click | Switch to that workspace |
| App icon in bar | Click | Focus that window |
| Cava / GitHub commits pill | Click | Expand media player dropdown (or open right sidebar if nothing playing) |
| Media player dropdown | Click outside or pill again | Close dropdown |
| Clock pill | Click | Expand calendar dropdown |
| Volume pill | Click icon | Mute / unmute toggle |
| Volume pill | Drag | Adjust volume inline |
| Battery pill | Click | Open performance profile dropdown (Silent / Balanced / Performance) |
| Network pill | Click | Open Wi-Fi network list dropdown |
| Bluetooth pill | Click | Open paired device list dropdown |
| Notification bell | Click | Toggle Swaync panel |
| Power button pill | Click | Open lock / suspend / reboot / shutdown popup |
| Right sidebar refresh button | Click | Re-fetch all data (git log, heatmap, dirty check) |
| Repo card folder icon | Click | Open Thunar to repo directory |
| Repo card GitHub icon | Click | Open repo URL in Brave |
| Repo card editor icon | Click | Open repo in Antigravity |

Global keybind that Quickshell listens for directly (via `GlobalShortcut` or `ShortcutHandler`):

| Keybind | Action |
|---|---|
| `Super + G` | Toggle right sidebar (Git/Repo panel) |

Note: the left sidebar is mouse-only (Arch logo click). The right sidebar has both a keybind and is togglable via the GitHub commits pill in the top bar when nothing is playing.

---

## Submaps

Submaps are modal keybinding layers. When a submap is active, normal keybinds are suspended and only the submap's keybinds apply. Exit any submap with `Escape`.

Use `binde` (not `bind`) inside submaps for actions that should repeat while the key is held.

---

### Resize Mode

**Trigger:** `Super + R`
**Exit:** `Escape`

Enter this mode to resize the active window with just arrow keys — no need to hold Super + Ctrl every press.

| Key | Action |
|---|---|
| `Right` | Grow window right (20px) |
| `Left` | Shrink window right (-20px) |
| `Down` | Grow window down (20px) |
| `Up` | Shrink window down (-20px) |
| `Escape` | Exit resize mode |

```ini
# Enter resize submap
bind = SUPER, R, submap, resize

submap = resize
binde = , right, resizeactive, 20 0
binde = , left, resizeactive, -20 0
binde = , down, resizeactive, 0 20
binde = , up, resizeactive, 0 -20
bind = , escape, submap, reset
submap = reset
```

---

### System Mode

**Trigger:** `Super + Shift + S`
**Exit:** `Escape` or any action (actions auto-exit the submap)

Prevents accidental triggers on destructive actions — you have to consciously enter this mode first.

| Key | Action |
|---|---|
| `L` | Lock screen (hyprlock) |
| `S` | Suspend |
| `R` | Reboot |
| `Q` | Shutdown |
| `E` | Exit Hyprland |
| `Escape` | Cancel — exit without doing anything |

```ini
# Enter system submap
bind = SUPER SHIFT, S, submap, system

submap = system
bind = , L, exec, hyprlock
bind = , L, submap, reset
bind = , S, exec, systemctl suspend
bind = , S, submap, reset
bind = , R, exec, systemctl reboot
bind = , R, submap, reset
bind = , Q, exec, systemctl poweroff
bind = , Q, submap, reset
bind = , E, exit
bind = , escape, submap, reset
submap = reset
```

Note: `Super + L` still works as a direct lock keybind outside of this submap — system mode is for the destructive actions (reboot, shutdown, suspend).

---

### Screenshot Mode

**Trigger:** `Super + Shift + Print` (replaces the old direct bind for active window screenshot — that bind moves into this submap)
**Exit:** `Escape` or any action (actions auto-exit)

Replaces having to remember three separate screenshot combos.

| Key | Action | Saves to |
|---|---|---|
| `F` | Full screen screenshot | `~/Pictures/screenshots/` |
| `R` | Region selection screenshot | `~/Pictures/screenshots/` |
| `W` | Active window screenshot | `~/Pictures/screenshots/` |
| `C` | Region screenshot — clipboard only | Clipboard, no file saved |
| `Escape` | Cancel | — |

```ini
# Enter screenshot submap
bind = SUPER SHIFT, Print, submap, screenshot

submap = screenshot
bind = , F, exec, grimblast save screen ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png
bind = , F, submap, reset
bind = , R, exec, grimblast save area ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png
bind = , R, submap, reset
bind = , W, exec, grimblast save active ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png
bind = , W, submap, reset
bind = , C, exec, grimblast copy area
bind = , C, submap, reset
bind = , escape, submap, reset
submap = reset
```

Note: `Print` alone (full screenshot, direct) and `Super + Print` (region, direct) are kept as standalone binds outside this submap for quick one-shot use. The submap is for when you want to choose the type interactively.

---

### Future Submaps (Undecided)

These may be added post-install once the base workflow is established:

| Submap | Trigger | Purpose |
|---|---|---|
| Performance profile | `Super + P` | Silent / Balanced / Turbo via asusctl |
| Layout mode | `Super + Shift + L` | Tiling layout changes, gap toggles |
| Passthrough | `Super + F2` | Forward all keys to active app (for gaming) |

---

## Window Rules (Floating by Default)

These windows should always open floating regardless of tiling state. Define in `windowrules.conf`.

| App | Rule | Reason |
|---|---|---|
| Pavucontrol | Float, center | Audio mixer — small utility |
| Blueman | Float, center | Bluetooth manager — small utility |
| Thunar (file picker) | Float, center | When opened as a dialog |
| Calculator | Float, center | Small utility |
| Hyprlock | Fullscreen | Lock screen |
| nwg-dock | Float | Dock behavior |
| Password prompt dialogs | Float, center | Auth dialogs |

---

## Workspace Assignments (Default)

Define in `windowrules.conf`. These are starting suggestions — adjust post-install.

| Workspace | App | Rule |
|---|---|---|
| 1 | Kitty | Default terminal workspace |
| 2 | Brave | Browser always opens on 2 |
| 3 | Antigravity / Sublime Text | Editor workspace |
| 4 | Discord | Communication |

---

## Notes

- `grimblast` is from the `grimblast` AUR package (`yay -S grimblast`) — wraps `grim` + `slurp` for Hyprland-aware screenshots
- `brightnessctl` must be installed: `sudo pacman -S brightnessctl`
- `playerctl` is already in the package list
- `XF86` keys are the hardware media/function keys — Hyprland binds these directly without needing a separate daemon
- Screenshot directory `~/Pictures/screenshots/` must exist before first use — create it post-install: `mkdir -p ~/Pictures/screenshots`