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
| `Print` | Full screen screenshot | grimblast |
| `Super + Print` | Selected region screenshot | grimblast |
| `Super + Shift + Print` | Active window screenshot | grimblast |
| `Super + Ctrl + Print` | Screenshot + copy to clipboard | grimblast |

All screenshots saved to `~/Pictures/screenshots/` with a timestamp filename.

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
| `Super + L` | Lock screen (hyprlock) |
| `Super + M` | Exit Hyprland |
| `Super + Shift + R` | Reload Hyprland config |
| `Super + Shift + Q` | Quickshell reload |

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

## Submaps (Planned — Post-Install)

Submaps are modal keybinding layers. When active, normal keybinds are suspended and the submap's keybinds apply instead. Exit any submap with `Escape`.

> **These are not yet defined.** Submap design will be done post-install once the base workflow is established and it becomes clear which actions benefit from a modal layer.

### Potential Submaps to Consider

| Submap | Trigger | Purpose |
|---|---|---|
| Resize mode | `Super + R` | Resize windows with arrow keys without holding Super |
| System mode | `Super + Shift + S` | Lock / suspend / reboot / shutdown in one layer |
| Screenshot mode | `Super + Shift + Print` | Choose screenshot type interactively |
| Layout mode | `Super + Shift + L` | Change tiling layout, toggle gaps, etc. |

### Submap Template (for keybinds.conf)

```ini
# Enter submap
bind = SUPER, R, submap, resize

# Inside resize submap
submap = resize
binde = , right, resizeactive, 20 0
binde = , left, resizeactive, -20 0
binde = , up, resizeactive, 0 -20
binde = , down, resizeactive, 0 20
bind = , escape, submap, reset
submap = reset
```

Use `binde` (not `bind`) inside submaps for actions that should repeat while the key is held.

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