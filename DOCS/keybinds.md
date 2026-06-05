# Keybinds Reference

All keybinds for the Arch Linux / Hyprland setup on the ASUS TUF Gaming FX505DT.

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
| `Super + Ctrl + Up` | Resize window up (20px, repeating) |
| `Super + Ctrl + Down` | Resize window down (20px, repeating) |
| `Super + Ctrl + Left` | Resize window left (20px, repeating) |
| `Super + Ctrl + Right` | Resize window right (20px, repeating) |
| `Super + Tab` | Toggle Quickshell overview |
| `Super + Shift + Tab` | Cycle focus to previous window |
| `Alt + Tab` | Cycle to next window |
| `Alt + Shift + Tab` | Cycle to previous window |

---

## Applications

| Keybind | Action |
|---|---|
| `Super + Return` | Kitty terminal |
| `Super + B` | Brave browser |
| `Super + A` | Antigravity editor |
| `Super + S` | Sublime Text |
| `Super + T` | Thunar file manager |
| `Super + D` | Discord |
| `Super + V` | VSCode |
| `Super + E` | Yazi file manager (in Kitty) |
| `Super + Z` | Zellij (plain, no layout) |
| `Super + Shift + Z` | Zellij dev layout (main + logs + lazygit) |
| `Super + C` | Color picker (hyprpicker — hex to clipboard + notification) |

---

## Quickshell Panels

| Keybind | Action |
|---|---|
| `Super + Space` | Toggle app launcher |
| `Super + N` | Toggle notification center |
| `Super + G` | Toggle right sidebar (Git/Repo panel) |
| `Super + X` | Toggle left sidebar |
| `Super + W` | Toggle wallpaper picker |
| `Super + Shift + C` | Toggle settings panel |
| `Super + Shift + V` | Toggle clipboard history panel |
| `Super + semicolon` | Toggle emoji picker |

---

## Workspaces

| Keybind | Action |
|---|---|
| `Super + 1` – `Super + 9` | Switch to workspace 1–9 |
| `Super + Shift + 1` – `Super + Shift + 9` | Move window to workspace 1–9 |
| `Super + Scroll Up` | Cycle to next workspace |
| `Super + Scroll Down` | Cycle to previous workspace |

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
| `XF86AudioRaiseVolume` | Volume up 5% (repeating) |
| `XF86AudioLowerVolume` | Volume down 5% (repeating) |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioPlay` | Play / pause (playerctl) |
| `XF86AudioNext` | Next track (playerctl) |
| `XF86AudioPrev` | Previous track (playerctl) |
| `XF86AudioStop` | Stop playback (playerctl) |

---

## Brightness

| Keybind | Action | Tool |
|---|---|---|
| `XF86MonBrightnessUp` | Brightness up 5% (repeating) | brightnessctl |
| `XF86MonBrightnessDown` | Brightness down 5% (repeating) | brightnessctl |

Add `brightnessctl` to package list — `sudo pacman -S brightnessctl`.

---

## System

| Keybind | Action |
|---|---|
| `Super + L` | Lock screen — also available inside System submap |
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
| Notification bell | Click | Toggle notification center |
| Power button pill | Click | Open lock / suspend / reboot / shutdown popup |
| Right sidebar refresh button | Click | Re-fetch all data (git log, heatmap, dirty check) |
| Repo card folder icon | Click | Open Thunar to repo directory |
| Repo card GitHub icon | Click | Open repo URL in Brave |
| Repo card editor icon | Click | Open repo in Antigravity |

Keybinds that Quickshell also listens for directly:

| Keybind | Action |
|---|---|
| `Super + G` | Toggle right sidebar (Git/Repo panel) |
| `Super + X` | Toggle left sidebar |

---

## Submaps

Submaps are modal keybinding layers. When a submap is active, normal keybinds are suspended and only the submap's keybinds apply. Exit any submap with `Escape`. Keys that should repeat while held use the `{ repeating = true }` bind flag.

---

### Resize Mode

**Trigger:** `Super + R`
**Exit:** `Escape`

Enter this mode to resize the active window with just arrow keys — no need to hold `Super + Ctrl` every press.

| Key | Action |
|---|---|
| `Right` | Grow window right (20px, repeating) |
| `Left` | Shrink window left (20px, repeating) |
| `Down` | Grow window down (20px, repeating) |
| `Up` | Shrink window up (20px, repeating) |
| `Escape` | Exit resize mode |

---

### System Mode

**Trigger:** `Super + Shift + S`
**Exit:** `Escape` or any action (actions auto-exit the submap)

Prevents accidental triggers on destructive actions — you have to consciously enter this mode first.

| Key | Action |
|---|---|
| `L` | Lock screen |
| `S` | Suspend |
| `R` | Reboot |
| `Q` | Shutdown |
| `E` | Exit Hyprland (`loginctl terminate-user ""`) |
| `Escape` | Cancel — exit without doing anything |

Note: `Super + L` still works as a direct lock keybind outside of this submap — system mode is for the destructive actions (reboot, shutdown, suspend).

---

### Screenshot Mode

**Trigger:** `Super + Shift + Print`
**Exit:** `Escape` or any action (actions auto-exit)

Replaces having to remember three separate screenshot combos.

| Key | Action | Saves to |
|---|---|---|
| `F` | Full screen screenshot | `~/Pictures/screenshots/` |
| `R` | Region selection screenshot | `~/Pictures/screenshots/` |
| `W` | Active window screenshot | `~/Pictures/screenshots/` |
| `C` | Region screenshot — clipboard only | Clipboard, no file saved |
| `Escape` | Cancel | — |

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

These windows should always open floating regardless of tiling state. Not everything is here.

| App | Rule | Reason |
|---|---|---|
| Pavucontrol | Float, center | Audio mixer — small utility |
| Blueman | Float, center | Bluetooth manager — small utility |
| Thunar (file picker) | Float, center | When opened as a dialog |
| Calculator | Float, center | Small utility |
| Hyprlock | Fullscreen | Lock screen |
| Password prompt dialogs | Float, center | Auth dialogs |

---

## Notes

- `grimblast` is from the `grimblast` AUR package (`yay -S grimblast`) — wraps `grim` + `slurp` for Hyprland-aware screenshots
- `brightnessctl` must be installed: `sudo pacman -S brightnessctl`
- `playerctl` is already in the package list
- `XF86` keys are the hardware media/function keys — Hyprland binds these directly without needing a separate daemon
- Screenshot directory `~/Pictures/screenshots/` must exist before first use — create it post-install: `mkdir -p ~/Pictures/screenshots`