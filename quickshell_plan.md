# Quickshell Widget Plan

A detailed plan for the Quickshell bar and widget layout for the Arch Linux setup on the ASUS TUF Gaming FX505DT.

---

## Aesthetic

- **Style:** Pill/island layout — each widget group is its own rounded capsule, not one continuous bar
- **Visual effect:** Glassmorphism throughout — frosted glass background, backdrop blur, semi-transparent fills
- **Color theme:** Catppuccin Mocha base (hardcoded) + matugen dynamic accent (wallpaper-derived); Lavender is the fallback accent before any wallpaper is processed
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
- Cava bar color follows dynamic accent (matugen output); falls back to Lavender (`#b4befe`) before first wallpaper is processed

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
- Color intensity follows dynamic accent scale (matugen output); falls back to Lavender scale before first wallpaper is processed

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
- **Cava integration:** run cava as a subprocess, parse stdout bar values, render as QML rectangles; requires `output_method = raw` or `output_method = csv` in `~/.config/cava/config` for machine-readable output
- **Circular gauges:** custom QML Canvas components — no library dependency; values read from `/proc/stat` (CPU), `/proc/meminfo` (RAM), `nvidia-smi` or `radeontop` (GPU); note: `radeontop` requires root by default — fix with a udev rule granting your user read access to the GPU device, otherwise the Process call will silently fail
- **Storage bars:** read from `df -h` via `Process` or directly from `/proc/mounts` + `statvfs`
- **Repo scanning:** `Process { command: ["find", repoRoot, "-maxdepth", "2", "-name", ".git", "-type", "d"] }` then strip `/.git` suffix from each result
- **GitHub API:** use the GraphQL API (`https://api.github.com/graphql`) with the `contributionsCollection` query for heatmap data — the REST endpoint `api.github.com/users/<username>/contributions` is undocumented and unreliable; GraphQL requires a personal access token but is stable and returns exactly the contribution data needed
- **Wi-Fi pill:** driven entirely by `nmcli` via `Process` calls — no `wifi-menu`, `dialog`, or `network-manager-applet` needed. List networks: `nmcli -t -f SSID,SIGNAL,SECURITY device wifi list`; connect: `nmcli device wifi connect "SSID" password "pw"`; disconnect: `nmcli device disconnect wlan0`. Password prompt is a QML text input field that feeds into the connect command.
- **Sidebar open/close:** `visible` binding toggled by a `ShortcutHandler` (right sidebar) or mouse click (left sidebar); panel anchored via Quickshell `Anchor` or `PanelWindow`
- **Performance:** no timers or polling anywhere — all data fetched on open or on manual refresh only

---

## What Is Not Handled Here

These are managed by other tools per the main setup plan:

| Thing | Handled by |
|---|---|
| Wallpaper | awww |
| Notifications panel | Swaync |
| App launcher | Rofi-wayland |
| Clipboard history | cliphist + Rofi |
| Dock | nwg-dock-hyprland |

---

## Open Decisions (resolve post-install)

| Decision | Notes |
|---|---|
| Right sidebar keybind | Confirmed: `Super + G` |
| Cava bar color | Static Catppuccin accent or reactive to album art |
| Repo root directory | Recommended: `~/dev` — confirm on first boot |
| GitHub username | Configure in widget secrets/config file |

---

## QML Coding Guide (For Fresh Installation)

This section exists because Claude's knowledge of Quickshell may be outdated by the time you start building. Follow this guide at the start of every coding session to make sure Claude is working from your actual installed version, not stale training data.

---

### Step 1 — Gather Your Installed Version Info

Before opening a Claude session, run these commands and keep the output ready to paste:

```bash
# Quickshell version
quickshell --version

# Qt version (Quickshell is built on Qt/QML)
qml --version

# Confirm Hyprland version (affects IPC behavior)
hyprctl version

# Confirm playerctl is installed and working
playerctl --version

# Confirm nmcli is available
nmcli --version

# Confirm asusctl is available
asusctl --version

# Confirm matugen is installed
matugen --version

# Confirm a matugen color file exists (should exist after first wallpaper change)
cat ~/.config/matugen/colors.sh
```

---

### Step 2 — Fetch the Current Quickshell Docs

Quickshell's API changes between versions. Always pull the current docs before coding. You don't need the entire docs site — just the specific component pages for what you're building that session.

**Where to get them:**
Go to https://quickshell.outfoxxed.me/docs/types, Ctrl+F the component name, and copy that component's page into the Claude session. 2-3 component pages per session is usually enough.

**Components needed in almost every session (always paste these):**
- `ShellRoot` — the entry point for every Quickshell config
- `PanelWindow` — how bars and floating panels are created
- `Process` — how shell commands are run (nmcli, asusctl, hyprctl, cava, etc.)

**Additional components per widget (paste only when building that widget):**

| Widget | Extra components to paste |
|---|---|
| Workspace indicator, App icons | `Hyprland` module |
| Volume pill | `PipewireNode`, `PipewireDevice` |
| Media player dropdown | `MprisPlayer` (if Quickshell has a built-in; otherwise Process + playerctl) |
| Network, Bluetooth, Battery, asusctl | Just `Process` — these are all subprocess calls |
| Idle inhibitor | `WaylandIdleInhibitor` |
| Sidebar open/close keybind | `GlobalShortcut` or `ShortcutHandler` |

**If you are unsure what to paste:** tell Claude what you are building at the start of the session and ask "which Quickshell components will I need for this?" — Claude will list them and you can look them up before proceeding.

**Locally installed docs (may or may not exist depending on version):**
```bash
find /usr/share/quickshell -name "*.md" 2>/dev/null
find /usr/share/doc/quickshell -type f 2>/dev/null
```

---

### Step 3 — How to Start a Claude Coding Session

Open every Quickshell coding session with this block of context. Fill in the blanks at install time:

```
I am building a Quickshell widget bar on Arch Linux with Hyprland.

Versions:
- Quickshell: [paste output of quickshell --version]
- Qt: [paste output of qml --version]
- Hyprland: [paste output of hyprctl version]

My setup:
- GPU: AMD iGPU (primary) + NVIDIA GTX 1650 (PRIME offload)
- Display: 1920x1080, single monitor
- Shell: zsh
- Username: simone, Hostname: persmon

Relevant installed tools: playerctl, nmcli, asusctl, supergfxctl, cava, radeontop, matugen, lazygit, fzf, zellij, hyprpicker
Color system: Catppuccin Mocha base (hardcoded) + matugen dynamic accent from ~/.config/matugen/colors.sh; Lavender (#b4befe) is the fallback accent

Current Quickshell API docs (paste relevant sections here):
[paste from quickshell.outfoxxed.me — if unsure which components to paste, ask Claude first: "which Quickshell components will I need to build [widget name]?" then look them up and paste before proceeding]

Here is my full widget plan for context:
[paste this entire quickshell_plan.md]

What I want to build this session:
[describe the specific widget or component]
```

This gives Claude everything it needs to write accurate, version-appropriate QML without guessing.

---

### Step 4 — Build Order (Recommended)

Build in this order. Each step depends on the previous one being stable.

1. **ShellRoot + PanelWindow scaffold** — get a blank bar rendering on screen before adding any content
2. **Color constants file (`colors.qml`)** — hardcode Catppuccin Mocha base colors; set up accent color to read from matugen output file; define Lavender as the hardcoded fallback accent; all other QML files import this one file for every color reference
3. **Pill component** — a reusable rounded glassmorphism capsule; everything else is built inside this
4. **Clock pill** — simplest pill, no external data, good for validating the pill component
5. **Workspace indicator** — first Hyprland IPC integration; validates that `Hyprland` module works on your version
6. **Volume pill** — first Pipewire integration; validates audio stack
7. **Network pill** — first `nmcli` Process call; validates subprocess pattern
8. **Battery pill + performance profile dropdown** — first `asusctl` integration
9. **Bluetooth pill** — builds on the dropdown pattern from battery pill
10. **App icons pill** — more complex IPC; builds on workspace indicator
11. **Cava pill** — subprocess with continuous stdout parsing; most complex top bar component
12. **Media player dropdown** — MPRIS via playerctl; builds on Cava subprocess pattern
13. **Left sidebar** — builds on all pill patterns; add sections one at a time
14. **Right sidebar** — GitHub GraphQL API call is the most complex part; build repo list first, heatmap second
15. **Settings panel** — build last; depends on all other components being stable; see `settings.md` for full spec

---

### Step 5 — Debugging Tips

**If a Process call silently does nothing:**
- Test the command manually in terminal first
- Check if the command needs to be in `$PATH` — Quickshell may have a different environment than your shell
- Try using the full binary path (e.g. `/usr/bin/nmcli` instead of `nmcli`)

**If a panel doesn't appear:**
- Run `quickshell` from terminal to see runtime errors — they don't always show in logs
- Check `journalctl --user -u quickshell` for service errors

**If Hyprland IPC calls fail:**
- Verify `$HYPRLAND_INSTANCE_SIGNATURE` is set in the Quickshell environment
- Test with `hyprctl clients -j` in terminal first to confirm the output format matches what your QML parser expects

**If radeontop fails silently:**
- See Implementation Notes — needs a udev rule for non-root access
- Temporary workaround while testing: prefix with `sudo` to confirm the command itself works, then fix permissions properly

**If dynamic accent colors are not updating after wallpaper change:**
- Check that `~/.config/matugen/colors.sh` exists and contains color values — if not, run `matugen image ~/wallpapers/yourwallpaper.jpg` manually
- Check that `colors.qml` is reading from the correct path
- Quickshell file watcher should auto-reload `colors.qml` when the file changes (v0.3.0+) — if it doesn't, trigger a manual reload with `quickshell --reload`
- Verify the wallpaper-change script is actually calling matugen after awww

**If the GitHub GraphQL call returns nothing:**
- Check that the token in `~/.config/quickshell/secrets.env` is exported correctly
- Test the query with `curl` in terminal first:
```bash
curl -H "Authorization: bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"query": "{ viewer { contributionsCollection { contributionCalendar { weeks { contributionDays { contributionCount date } } } } } }"}' \
     https://api.github.com/graphql
```

---

### Step 6 — File Structure to Use

```
~/.config/quickshell/
├── shell.qml               # ShellRoot entry point — sources everything
├── colors.qml              # Base colors: hardcoded Catppuccin Mocha; accent colors: read from matugen output at ~/.config/matugen/colors.sh; Quickshell file watcher auto-reloads this file when matugen regenerates it
├── bar/
│   ├── Bar.qml             # Top bar PanelWindow
│   ├── PillBase.qml        # Reusable pill/capsule component
│   ├── WorkspacePill.qml
│   ├── AppIconsPill.qml
│   ├── CavaPill.qml
│   ├── MediaDropdown.qml
│   ├── ClockPill.qml
│   ├── VolumePill.qml
│   ├── NetworkPill.qml
│   ├── BluetoothPill.qml
│   ├── BatteryPill.qml
│   └── PowerPill.qml
├── sidebar-left/
│   ├── LeftSidebar.qml
│   ├── ProfileCard.qml
│   ├── StatsCard.qml
│   ├── QuickSettingsCard.qml
│   └── PowerCard.qml
├── sidebar-right/
│   ├── RightSidebar.qml
│   ├── ContributionHeatmap.qml
│   └── RepoCard.qml
└── secrets.env             # GitHub token — never commit this
└── settings/
    ├── SettingsPanel.qml         # Main panel — profile pills + section list
    ├── SettingsSection.qml       # Reusable collapsible section card
    ├── SliderControl.qml         # Labeled slider + number
    ├── ToggleControl.qml         # Labeled toggle switch
    ├── DropdownControl.qml       # Labeled dropdown
    ├── SettingsApplier.qml       # hyprctl keyword + sed + reload logic
    ├── BezierEditor.qml          # Visual curve editor with canvas + preview ball
    ├── ProfileManager.qml        # Profile pill row + save/switch/delete
    ├── WindowRulesEditor.qml     # Window rules list + add/edit/delete
    ├── MonitorSettings.qml       # Monitor resolution/scale/rotation
    ├── HyprlockSettings.qml      # Lock screen settings
    ├── SwayNCSettings.qml        # Notification center settings
    ├── curves.json               # Saved named bezier curves
    └── profiles.json             # Saved setting profiles
```

Keep `secrets.env` in `.gitignore` if the config is tracked in a git repo (Chezmoi will handle this — add it to the ignore list there too).

---

### Step 7 — Chezmoi Integration Note

Once the Quickshell config is stable, add it to Chezmoi like all other dotfiles. The one exception is `secrets.env` — mark it as ignored in `~/.config/chezmoi/chezmoiignore`:

```
.config/quickshell/secrets.env
```

The token itself should be stored separately (e.g. in a password manager) and re-entered manually on a new machine setup.