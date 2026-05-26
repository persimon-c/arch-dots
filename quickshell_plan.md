# Quickshell Widget Plan

A detailed plan for the Quickshell bar and widget layout for the Arch Linux setup on the ASUS TUF Gaming FX505DT.

---

## Aesthetic

- **Style:** Pill/island layout — each widget group is its own rounded capsule, not one continuous bar
- **Visual effect:** Glassmorphism throughout — frosted glass background, backdrop blur, semi-transparent fills
- **Color theme:** Catppuccin Mocha
- **Reference:** meloworld dotfiles (https://github.com/end-4/dots-hyprland) for QML structure and component patterns

---

## Top Bar

Always visible. Minimal by default — detail on interaction.

### Left Side

Three elements in a row, left to right:

**1. Arch Logo (pill)**
- Clickable Arch Linux logo
- Click opens/closes the left sidebar panel
- Anchored to top-left — sidebar drops down from below this pill

**2. Workspace Indicator (pill)**
- Shows workspace numbers only (no icons)
- Active workspace highlighted, occupied ones dimmed, empty ones hidden or minimal
- Click a number to switch to that workspace

**3. Current Workspace App Icons (pill)**
- Shows icons of all open apps on the currently active workspace
- Updates when workspace changes or a window opens/closes
- Sourced via Hyprland IPC (`hyprctl clients -j`)
- Icons sourced from `.desktop` files in `/usr/share/applications/`
- Clicking an app icon focuses that window and brings it to the top via Hyprland IPC (`hyprctl dispatch focuswindow`)

### Center — Cava + Media Player

**Default state — something is playing:**
- Small Cava audio visualizer inside a pill — compact bar visualizer, always running
- Cava bar color follows Catppuccin accent

**Default state — nothing is playing:**
- Cava pill is replaced with a small GitHub commits pill
- Shows commit count for the current week (e.g. "7 commits this week")
- Sourced from GitHub API — same token used by the right sidebar
- Falls back to "—" if API is unavailable or token is not set
- Click opens the right sidebar Git/Repo panel

**On click (when something is playing):**
- Expands downward as a dropdown anchored to the center pill
- Shows full media player card:
  - Album art (thumbnail, left side)
  - Song title + artist
  - Source indicator (e.g. Spotify)
  - Progress bar with current time / total time
  - Controls: shuffle, previous, play/pause, next, repeat
- Data sourced via playerctl / MPRIS
- Closes on click again or clicking outside

### Right — System Pills (individual capsules)

Each item is its own pill, separated. Left to right:

| Pill | Default display | On click |
|---|---|---|
| Battery | Percentage + charging icon | Dropdown to select performance profile: Silent / Balanced / Performance (via asusctl) — synced with left sidebar quick settings |
| Network | Wi-Fi icon + SSID truncated | Dropdown listing available Wi-Fi networks — connect/disconnect; connecting to a password-protected network opens a separate password prompt dialog |
| Bluetooth | Icon only | Dropdown listing paired devices — connect/disconnect toggle per device; includes a "Scan for new devices" button at the bottom of the list |
| Volume | Icon only | Slider appears inline; icon itself = mute toggle |
| Clock | Time (prominent) + date (smaller) | Dropdown showing current month calendar — static view only, current date highlighted with an indicator |
| Notification bell | Bell icon + unread count badge | Toggles Swaync panel |
| Power button | Icon | Small popup: lock, suspend, reboot, shutdown |

---

## Left Sidebar Panel

Toggled by clicking the Arch logo. Floats anchored below the Arch logo pill — does not take full screen height. Slides down on open.

Glassmorphism card style — each section is its own frosted card inside the panel.

All data is fetched **on panel open only** — nothing polls while the panel is closed, in line with the performance goals of this setup.

### Section 1 — Profile

- Username (`simone`) + hostname (`persmon`)
- Quote: "the moon is beautiful, isn't it?" — hardcoded in QML, not configurable
- Uptime

### Section 2 — System Stats

Fetched fresh each time the panel opens.

- **CPU** — circular gauge, percentage label in center
- **RAM** — circular gauge, used/total label in center
- **GPU** — circular gauge, load percentage; label shows active GPU (AMD/NVIDIA via `supergfxctl -g`)
- **Storage** — horizontal bars, one per drive:
  - `/ (SSD)` — 50GB root, shows used/total and fill percentage
  - `/home (HDD)` — 627GB home, shows used/total and fill percentage
  - Bar color shifts to warning color when usage exceeds 80%

### Section 3 — Quick Settings

- **Performance profile** — three buttons: Silent / Balanced / Performance
  - Calls `asusctl profile -P <name>` on click
  - Active profile is highlighted
- **Bluetooth toggle** — on/off
- **Volume slider** — full slider with percentage label

### Section 4 — Power Actions

At the bottom of the panel.

- Lock (`hyprlock`)
- Suspend
- Reboot
- Shutdown

---

## Right Sidebar — Git / Repo Widget

Standalone panel on the right side of the screen. Width is 25% of the screen (1/4 of 1920px = ~480px) — never exceeds this. Separate from the left sidebar — toggled independently via a keybind (to be decided post-install).

Glassmorphism card style, same aesthetic as left sidebar.

Data is fetched **on panel open** and on **manual refresh** via a refresh button at the top of the panel. No background polling.

### Section 1 — GitHub Contribution Heatmap

- Contribution graph for the past year
- Sourced from GitHub API using a personal access token
- Token stored in `~/.config/quickshell/secrets.env`, sourced at runtime, never committed to the dotfiles repo
- Color intensity follows Catppuccin accent scale

**Fallback behavior (API unavailable or token not set):**
- Shows a muted placeholder grid with a short message: "GitHub unavailable" or "Token not configured"
- Does not crash or leave blank space — degrades gracefully

### Section 2 — Repo List

Scanned from the repo root directory on panel open. The widget looks for any folder containing a `.git` directory.

**Repo root directory:** Not yet decided. Recommendation: use `~/dev` as the single root for all repositories — short, clean, conventional. Subdirectories can separate concerns: `~/dev/personal/`, `~/dev/uni/`, etc. Set one variable `repoRoot: "/home/simone/dev"` in the widget config and everything follows. Confirm on first boot.

Each repo is displayed as a card showing:

- Repo name
- Current branch
- Last commit message + relative time (e.g. "2 hours ago")
- Dirty status indicator — a colored dot if there are uncommitted changes

**Quick action buttons per repo card:**

| Button | Action |
|---|---|
| Folder icon | Opens Thunar to the repo directory |
| GitHub icon | Opens the GitHub repo URL in Brave |
| Editor icon | Opens the repo in Antigravity |

Implemented as `Process` calls in QML:
- Thunar: `thunar /path/to/repo`
- GitHub: `xdg-open https://github.com/username/reponame`
- Editor: `antigravity /path/to/repo`

**Refresh button** at the top of the panel re-runs all data fetches (git log, dirty check, heatmap API call).

---

## Implementation Notes

- **App icons in top bar:** sourced via `hyprctl clients -j` on workspace change; icon looked up from `.desktop` files in `/usr/share/applications/`
- **Cava integration:** run cava as a subprocess, parse stdout bar values, render as QML rectangles
- **Circular gauges:** custom QML Canvas components — no library dependency; values read from `/proc/stat` (CPU), `/proc/meminfo` (RAM), `nvidia-smi` or `radeontop` (GPU)
- **Storage bars:** read from `df -h` via `Process` or directly from `/proc/mounts` + `statvfs`
- **Repo scanning:** `Process { command: ["find", repoRoot, "-maxdepth", "2", "-name", ".git", "-type", "d"] }` then strip `/.git` suffix from each result
- **GitHub API:** fetch `https://api.github.com/users/<username>/contributions` or use the GraphQL contributions API for heatmap data
- **Sidebar open/close:** `visible` binding toggled by a `ShortcutHandler` (right sidebar) or mouse click (left sidebar); panel anchored via Quickshell `Anchor` or `PanelWindow`
- **Performance:** no timers or polling anywhere — all data fetched on open or on manual refresh only

---

## What Is Not Handled Here

These are managed by other tools per the main setup plan:

| Thing | Handled by |
|---|---|
| Wallpaper | swww |
| Notifications panel | Swaync |
| App launcher | Rofi-wayland |
| Clipboard history | cliphist + Rofi |
| Dock | nwg-dock-hyprland |

---

## Open Decisions (resolve post-install)

| Decision | Notes |
|---|---|
| Right sidebar keybind | Pick after base keybinds are settled |
| Cava bar color | Static Catppuccin accent or reactive to album art |
| Repo root directory | Recommended: `~/dev` — confirm on first boot |
| GitHub username | Configure in widget secrets/config file |