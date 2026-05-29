# Post-Install Build Order

What to do after `installation_plan.md` is complete. Work top to bottom — each phase depends on the previous one being stable before moving on.

> **How to use this document:** each item has a checkbox. Work through them in order. Do not jump ahead — skipping phases means later steps will fail or produce incorrect results with no obvious reason why.

---

## Phase 1 — Verify the Base Install

Before touching any desktop config, confirm the foundation is solid.

- [ ] Boot into Arch and log in as `simone`
- [ ] Verify internet: `ping -c 3 archlinux.org`
- [ ] Verify correct timezone: `timedatectl status` — should show `Asia/Manila`
- [ ] Verify zsh is the default shell: `echo $SHELL` — should show `/bin/zsh`
- [ ] Verify yay works: `yay --version`
- [ ] Verify GPU drivers loaded: `lsmod | grep nvidia` — should return entries
- [ ] Verify AMD GPU visible: `ls /dev/dri/by-path/` — note the PCI path for the AMD iGPU; you need this in Phase 3
- [ ] Verify asusctl working: `asusctl profile --list` — should show Silent / Balanced / Performance
- [ ] Verify Docker data root: `docker info | grep "Docker Root Dir"` — should show `/home/docker-data`
- [ ] Verify radeontop works without sudo: `radeontop -d -` — if it fails with permission denied, the udev rule from Step 29 didn't apply; log out and back in and retry

**Do not proceed to Phase 2 until all of these pass.**

---

## Phase 2 — SSH Key and Git Identity

Set this up before cloning anything or initializing Chezmoi.

- [ ] Generate SSH key:
  ```bash
  ssh-keygen -t ed25519 -C "your@email.com"
  ```
- [ ] Add public key to GitHub: `cat ~/.ssh/id_ed25519.pub` → GitHub → Settings → SSH Keys → New
- [ ] Test GitHub connection: `ssh -T git@github.com` — should say "Hi username!"
- [ ] Set global Git identity:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your@email.com"
  git config --global init.defaultBranch main
  ```
- [ ] Create your repo root directory: `mkdir -p ~/dev`

---

## Phase 3 — Hyprland First Boot

Get a working Hyprland session before configuring anything else. The config was written in Step 26 of the installation plan — this phase is just about confirming it actually works.

- [ ] Confirm the AMD GPU path in `~/.config/hypr/env.conf` matches what you see in `ls /dev/dri/by-path/` — update it if it doesn't
- [ ] Start Hyprland from TTY: type `Hyprland` and press Enter
- [ ] Verify Hyprland launches without errors
- [ ] Verify a terminal opens: `Super + Return` → Kitty should appear
- [ ] Verify `Super + Q` closes the window
- [ ] Verify workspace switching: `Super + 2`, `Super + 1`
- [ ] Verify rofi opens: `Super + Space`
- [ ] Verify screen lock works: `Super + L` → hyprlock should appear; type password to unlock
- [ ] Exit Hyprland: enter the system submap (`Super + Shift + S`) → press `E`

If Hyprland fails to start, check `journalctl --user -xe` for errors before proceeding. Common causes: wrong GPU path in `env.conf`, NVIDIA module not loaded, config syntax error.

**Do not proceed to Phase 4 until Hyprland starts cleanly.**

---

## Phase 4 — SDDM and Display Manager

- [ ] Enable SDDM if not already enabled: `sudo systemctl enable sddm`
- [ ] Reboot: `reboot`
- [ ] Verify SDDM login screen appears
- [ ] Log in as `simone` — Hyprland should start automatically via SDDM
- [ ] Install the sddm-astronaut-theme:
  ```bash
  yay -S sddm-astronaut-theme
  ```
- [ ] Pick a theme variant by editing the metadata file:
  ```bash
  sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/astronaut.conf|' \
    /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
  ```
  Available variants are in `/usr/share/sddm/themes/sddm-astronaut-theme/Themes/` — swap `astronaut.conf` for any other config file in that directory to try a different look.
- [ ] Set SDDM to use the theme via a drop-in config (do not edit `/etc/sddm.conf` directly):
  ```bash
  sudo mkdir -p /etc/sddm.conf.d
  echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee /etc/sddm.conf.d/theme.conf
  ```
- [ ] Preview without logging out:
  ```bash
  sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/
  ```
- [ ] Verify the themed login screen appears on next reboot

---

## Phase 5 — Font Rendering

Do this before theming anything — font rendering affects how every app looks.

> **File to deploy:** `font-rendering.md` contains the exact shell steps for writing `/etc/fonts/local.conf` and rebuilding the font cache. The XML content is in `setup_plan.md`; `font-rendering.md` adds the missing shell commands around it.

- [ ] Install freetype2 and fontconfig if not already present:
  ```bash
  sudo pacman -S freetype2 fontconfig
  ```
- [ ] Follow `font-rendering.md` to write `/etc/fonts/local.conf` and run the write command
- [ ] Rebuild font cache: `fc-cache -fv`
- [ ] Log out and back in
- [ ] Verify fonts look sharper in Kitty and rofi compared to before

---

## Phase 6 — Wallpaper and matugen

Wallpaper and color generation must be working before theming any app — matugen output is the source of truth for accent colors everywhere.

> **Files to deploy before starting this phase:**
> - `matugen-config.toml` → `~/.config/matugen/config.toml`
> - `matugen-template-colors.sh` → `~/.config/matugen/templates/colors.sh`
> - `matugen-template-colors.css` → `~/.config/matugen/templates/colors.css`
> - `matugen-template-hypr-colors.conf` → `~/.config/matugen/templates/hypr-colors.conf`
> - `matugen-template-kitty-colors.conf` → `~/.config/matugen/templates/kitty-colors.conf`
>
> See `matugen-setup.md` for the full template configuration, directory structure, verification commands, and what to check if matugen runs but writes nothing.

- [ ] Create the matugen config directory and deploy the files above:
  ```bash
  mkdir -p ~/.config/matugen/templates
  ```
- [ ] Verify the matugen config and templates are in place: `cat ~/.config/matugen/config.toml`
- [ ] Add at least one wallpaper to `~/wallpapers/` (anime scenery, soft tones — see `visuals.md`)
- [ ] Deploy `wallpaper-change.sh` → `~/.config/hypr/scripts/wallpaper-change.sh`
- [ ] Make it executable: `chmod +x ~/.config/hypr/scripts/wallpaper-change.sh`
- [ ] Run it manually against your first wallpaper:
  ```bash
  ~/.config/hypr/scripts/wallpaper-change.sh ~/wallpapers/yourwallpaper.jpg
  ```
- [ ] Verify `~/.cache/current_wallpaper` now contains the wallpaper path
- [ ] Verify `~/.config/matugen/colors.sh` exists and contains color values: `cat ~/.config/matugen/colors.sh`
- [ ] Verify `~/.config/hypr/colors.conf` was updated by matugen with a real accent color (not just the Lavender fallback)
- [ ] Reload Hyprland: `hyprctl reload` — window borders should now reflect the wallpaper-derived accent color
- [ ] Deploy `wallpaper-picker.sh` → `~/.config/rofi/wallpaper-picker.sh`
- [ ] Make it executable: `chmod +x ~/.config/rofi/wallpaper-picker.sh`
- [ ] Test the wallpaper switcher keybind: `Super + W` → Rofi grid should appear with wallpaper thumbnails → select one → wallpaper changes with bubble transition
- [ ] Verify the bubble transition plays correctly (grow from cursor on next, outer shrink on previous)
- [ ] Add more wallpapers to `~/wallpapers/` and verify the picker shows all of them

---

## Phase 7 — Per-App Theming

Apply Catppuccin Mocha + matugen accent theming to each app. Work through these one at a time — each is independent.

### Kitty

> **Files to deploy:**
> - `kitty.conf` → `~/.config/kitty/kitty.conf`
> - `matugen-template-kitty-colors.conf` is already in place from Phase 6 — matugen writes the output to `~/.config/kitty/matugen-colors.conf` on each wallpaper change

- [ ] Deploy `kitty.conf` → `~/.config/kitty/kitty.conf`
- [ ] Verify `~/.config/kitty/matugen-colors.conf` exists and has color values (written by matugen in Phase 6)
- [ ] Reload Kitty colors: `kitty @ set-colors --all ~/.config/kitty/matugen-colors.conf`
- [ ] Verify Kitty looks correct: Catppuccin Mocha base, accent cursor, slight transparency

### Rofi

- [ ] Create `~/.config/rofi/catppuccin-mocha.rasi` — Catppuccin Mocha base theme with matugen accent, centered floating panel, rounded corners, glassmorphism background (see `visuals.md` Rofi section)
- [ ] Test: `Super + Space` → rofi should appear themed

### Swaync

- [ ] Configure `~/.config/swaync/style.css` — Catppuccin Mocha base, dynamic accent, rounded notification cards, glassmorphism (see `visuals.md` Swaync section)
- [ ] Configure `~/.config/swaync/config.json` — position top-right, reasonable timeout and max notification count
- [ ] Reload: `swaync-client --reload-config`
- [ ] Test: `Super + N` → notification panel should slide in from the right, styled correctly

### Hyprlock

> **File to deploy:** `hyprlock.conf` → `~/.config/hypr/hyprlock.conf`
> Note: this file uses `$HOME/.cache/current_wallpaper` for the background path — Hyprlock does not expand `~`, so `$HOME` is used instead.

- [ ] Deploy `hyprlock.conf` → `~/.config/hypr/hyprlock.conf`
- [ ] Test: `Super + L` — lock screen should appear with correct wallpaper and styling

### Hypridle

> **File to deploy:** `hypridle.conf` → `~/.config/hypr/hypridle.conf`

- [ ] Deploy `hypridle.conf` → `~/.config/hypr/hypridle.conf`
- [ ] Set lid-close behavior: edit `/etc/systemd/logind.conf`, add `HandleLidSwitch=lock`
- [ ] Start hypridle: `hypridle &`
- [ ] Verify it's added to `~/.config/hypr/autostart.conf` so it starts on login

### Zellij

> **Files to deploy:**
> - `zellij-config.kdl` → `~/.config/zellij/config.kdl`
> - `dev-layout.kdl` → `~/.config/zellij/layouts/dev-layout.kdl`

- [ ] Create the layouts directory: `mkdir -p ~/.config/zellij/layouts`
- [ ] Deploy `zellij-config.kdl` → `~/.config/zellij/config.kdl`
- [ ] Deploy `dev-layout.kdl` → `~/.config/zellij/layouts/dev-layout.kdl`
- [ ] Test plain launch: `Super + Z` → clean Zellij session
- [ ] Test dev layout: `Super + Shift + Z` → three-pane layout with lazygit in top-right

### lazygit

- [ ] Create `~/.config/lazygit/config.yml` — apply official Catppuccin Mocha theme from `github.com/catppuccin/lazygit`
- [ ] Test: open lazygit inside a git repo, verify it looks correct

### Zathura (PDF viewer)

- [ ] Install if not already present: `sudo pacman -S zathura zathura-pdf-mupdf`
- [ ] Apply Catppuccin Mocha theme to `~/.config/zathura/zathurarc`
- [ ] Test: open a PDF

### Btop

- [ ] Install if not already present: `sudo pacman -S btop`
- [ ] Apply Catppuccin Mocha theme — available in the btop themes list, select in btop settings (`Esc` → Preferences → Color theme)
- [ ] Test: `btop` — should show CPU, RAM, GPU, network, disk all themed

### Cursor

> **File to deploy:** `gtk-3.0-settings.ini` → `~/.config/gtk-3.0/settings.ini`

- [ ] Verify `catppuccin-cursors-mocha` is installed (installed in Step 24 of installation plan)
- [ ] Verify `XCURSOR_THEME=Catppuccin-Mocha-Dark` is set in `~/.config/hypr/env.conf`
- [ ] Deploy `gtk-3.0-settings.ini` → `~/.config/gtk-3.0/settings.ini`
- [ ] Reload Hyprland: `hyprctl reload`
- [ ] Verify cursor looks correct in both Hyprland and GTK apps

---

## Phase 8 — Flatpak Apps

- [ ] Install Flatpak if not already present: `sudo pacman -S flatpak`
- [ ] Install Discord: `flatpak install flathub com.discordapp.Discord`
- [ ] Install Zoom: `flatpak install flathub us.zoom.Zoom`
- [ ] Install Spotify: `flatpak install flathub com.spotify.Client`
- [ ] Install Flatseal for managing Flatpak permissions: `flatpak install flathub com.github.tchx84.Flatseal`
- [ ] Via Flatseal, set `ELECTRON_OZONE_PLATFORM_HINT=auto` for Discord and Zoom so they render on Wayland natively
- [ ] Test each app launches and screen sharing works in Discord

---

## Phase 9 — Brave Browser

- [ ] Install Brave:
  ```bash
  yay -S brave-bin
  ```
- [ ] Create Profile 1 (Personal) — GitHub, Discord web, Figma, Canva, Claude
- [ ] Create Profile 2 (University) — Google Classroom, university accounts
- [ ] Test `Super + B` opens Brave

---

## Phase 10 — Development Tools

Install and verify each development tool. These are independent — order within this phase doesn't matter.

- [ ] Install fnm (Node version manager):
  ```bash
  curl -fsSL https://fnm.vercel.app/install | bash
  ```
  Add to `~/.zshrc`: `eval "$(fnm env --use-on-cd)"`
  Install current LTS: `fnm install --lts && fnm default lts-latest`

- [ ] Install pyenv (Python version manager):
  ```bash
  yay -S pyenv
  ```
  Add to `~/.zshrc`:
  ```bash
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  ```
  Install a Python version: `pyenv install 3.13.0 && pyenv global 3.13.0`

- [ ] Install Helix editor: `sudo pacman -S helix`
- [ ] Install Antigravity (Google IDE): `yay -S antigravity-ide` — the AUR package's wrapper script reads `~/.config/antigravity-flags.conf` automatically; the Wayland flag (`--ozone-platform-hint=auto`) is already set in that file
- [ ] Install VSCode: `yay -S visual-studio-code-bin`
- [ ] Install Sublime Text: `yay -S sublime-text-4`
- [ ] Install Btop (if not done in Phase 7): `sudo pacman -S btop`
- [ ] Install imv (image viewer): `sudo pacman -S imv`
- [ ] Install OBS Studio: `sudo pacman -S obs-studio` — note: launch with `OBS_USE_EGL=1 obs` for Wayland
- [ ] Install Blender: `sudo pacman -S blender`

---

## Phase 11 — Chezmoi Initialization

Do this once all config files from Phases 3–10 are stable and you're happy with how things look. Committing half-finished configs to Chezmoi creates noise.

> **Before this phase:** set up the pacman hooks. See `pacman-hooks.md` for both hooks with exact `tee` commands, the hooks directory creation, and Chezmoi tracking instructions. Do this now so the hooks are in place before your first post-setup `yay` run.

- [ ] Follow `pacman-hooks.md` to create both hooks (sbctl-sign-reminder and grub-fallback) and add them to Chezmoi
- [ ] Initialize Chezmoi: `chezmoi init`
- [ ] Add all config directories:
  ```bash
  chezmoi add ~/.config/hypr/
  chezmoi add ~/.config/kitty/
  chezmoi add ~/.config/rofi/
  chezmoi add ~/.config/quickshell/
  chezmoi add ~/.config/zellij/
  chezmoi add ~/.config/lazygit/
  chezmoi add ~/.config/cava/
  chezmoi add ~/.config/swaync/
  chezmoi add ~/.config/zathura/
  chezmoi add ~/.config/btop/
  chezmoi add ~/.config/matugen/
  chezmoi add ~/.zshrc
  chezmoi add /etc/fonts/local.conf
  ```
- [ ] Add `secrets.env` to `.chezmoiignore`:
  ```bash
  echo ".config/quickshell/secrets.env" >> ~/.local/share/chezmoi/.chezmoiignore
  ```
- [ ] Create a remote repo on GitHub (name it `dotfiles` or similar)
- [ ] Push:
  ```bash
  chezmoi git -- remote add origin git@github.com:yourusername/dotfiles.git
  chezmoi git -- push -u origin main
  ```
- [ ] Verify the repo on GitHub looks correct and `secrets.env` is absent

---

## Phase 12 — Quickshell Bar

Build the bar in this order. Each component depends on the previous ones being stable. Start every Claude coding session by pasting the context block from `quickshell_plan.md` Step 3.

**Before starting:** gather your installed version info and have it ready:
```bash
quickshell --version
qml --version
hyprctl version
```

### 12.1 — Scaffold

- [ ] Create `~/.config/quickshell/shell.qml` — ShellRoot entry point, sources everything
- [ ] Create `~/.config/quickshell/bar/Bar.qml` — blank PanelWindow anchored to the top
- [ ] Verify the bar renders: `quickshell` — a blank bar at the top of the screen should appear
- [ ] Verify `journalctl --user -u quickshell` shows no errors

### 12.2 — Color System

- [ ] Create `~/.config/quickshell/colors.qml` — hardcode all Catppuccin Mocha base colors; read accent from `~/.config/matugen/colors.sh`; set Lavender as hardcoded fallback
- [ ] Verify all other QML files import this one file for every color reference — no hardcoded hex values anywhere else

### 12.3 — Pill Base Component

- [ ] Create `~/.config/quickshell/bar/PillBase.qml` — reusable rounded glassmorphism capsule; all other pills are built inside this
- [ ] Verify it renders correctly (background blur, correct rounding, correct opacity)

### 12.4 — Clock Pill

- [ ] Create `~/.config/quickshell/bar/ClockPill.qml` — time prominent, date smaller; no external data
- [ ] Click → calendar dropdown appears showing current month with today highlighted
- [ ] Verify accent color is applied correctly from `colors.qml`

### 12.5 — Workspace Indicator

- [ ] Create `~/.config/quickshell/bar/WorkspacePill.qml` — numbers only, active highlighted, occupied dimmed, empty hidden
- [ ] Click a number → switches to that workspace via Hyprland IPC
- [ ] Verify it updates when you switch workspaces with keybinds

### 12.6 — Volume Pill

- [ ] Create `~/.config/quickshell/bar/VolumePill.qml` — icon only by default; click icon = mute toggle; drag = inline slider
- [ ] Verify it reflects current system volume and updates when you use hardware keys

### 12.7 — Network Pill

- [ ] Create `~/.config/quickshell/bar/NetworkPill.qml` — Wi-Fi icon + truncated SSID
- [ ] Click → dropdown lists available networks; click to connect; password prompt for secured networks
- [ ] Verify `nmcli` Process calls work correctly

### 12.8 — Battery Pill + Performance Profile Dropdown

- [ ] Create `~/.config/quickshell/bar/BatteryPill.qml` — percentage + charging icon
- [ ] Click → dropdown with Silent / Balanced / Performance; clicking each calls `asusctl profile -P <name>`
- [ ] Verify active profile is highlighted and switches correctly
- [ ] Verify syncs with left sidebar quick settings (Phase 12.15)

### 12.9 — Bluetooth Pill

- [ ] Create `~/.config/quickshell/bar/BluetoothPill.qml` — icon only
- [ ] Click → dropdown lists paired devices with connect/disconnect toggle per device; scan button at bottom
- [ ] Verify connect/disconnect calls work

### 12.10 — Notification Bell + Power Pill

- [ ] Create `~/.config/quickshell/bar/PowerPill.qml` — power icon; click → small popup with lock / suspend / reboot / shutdown
- [ ] Verify notification bell click toggles Swaync panel (`swaync-client -t`)
- [ ] Verify unread count badge appears on the bell

### 12.11 — App Icons Pill

- [ ] Create `~/.config/quickshell/bar/AppIconsPill.qml` — icons of all open apps on the active workspace
- [ ] Sourced via `hyprctl clients -j`; icons from `.desktop` files in `/usr/share/applications/`
- [ ] Click an icon → focuses that window (`hyprctl dispatch focuswindow`)
- [ ] Verify it updates when windows open, close, or workspace changes

### 12.12 — Arch Logo Pill

- [ ] Create the Arch logo pill — click opens/closes left sidebar
- [ ] Anchored to top-left; sidebar drops down from below it

### 12.13 — Cava Pill

> **File to deploy:** `cava.config` → `~/.config/cava/config`
> This file sets `output_method` to the correct value for machine-readable output. Deploy it before installing cava so the config is ready immediately.

- [ ] Install cava: `sudo pacman -S cava`
- [ ] Deploy `cava.config` → `~/.config/cava/config`
- [ ] Create `~/.config/quickshell/bar/CavaPill.qml` — compact bar visualizer; color follows dynamic accent
- [ ] When nothing is playing: replace with GitHub commits pill showing commit count for current week (sourced from GitHub API using the token in `secrets.env`)
- [ ] Verify Cava bars animate when audio plays; verify GitHub pill appears when audio stops

### 12.14 — Media Player Dropdown

- [ ] Create `~/.config/quickshell/bar/MediaDropdown.qml` — expands downward from center pill
- [ ] Shows: album art, song title, artist, source, progress bar with time, shuffle/prev/play/next/repeat controls
- [ ] Sourced via playerctl / MPRIS
- [ ] Click outside or pill again → closes
- [ ] Verify it appears when Spotify or any MPRIS source is playing

### 12.15 — Left Sidebar

Build sections one at a time. Don't move to the next section until the previous one is working.

- [ ] Create `~/.config/quickshell/sidebar-left/LeftSidebar.qml` — glassmorphism panel, slides down from Arch logo pill on click; data fetched on open only
- [ ] **Section 1 — Profile:** username (`simone`), hostname (`persmon`), hardcoded quote ("the moon is beautiful, isn't it?"), uptime
- [ ] **Section 2 — System Stats:** CPU circular gauge, RAM circular gauge, GPU circular gauge (load % + active GPU label via `supergfxctl -g`), storage horizontal bars for `/` and `/home` with warning color above 80%
- [ ] **Section 3 — Quick Settings:** Silent / Balanced / Performance profile buttons (synced with battery pill dropdown); Bluetooth toggle; volume slider
- [ ] **Section 4 — Power Actions:** lock, suspend, reboot, shutdown at the bottom of the panel
- [ ] Verify panel opens and closes smoothly; verify all data is fetched fresh on open

### 12.16 — Right Sidebar

> **Note:** `repoRoot` in the QML config must be set as `property string repoRoot: "/home/simone/dev"` — QML does not expand `~`, so the full path is required.

- [ ] Create `~/.config/quickshell/sidebar-right/RightSidebar.qml` — 25% screen width (~480px); toggled by `Super + G` and by clicking the GitHub commits pill when nothing is playing
- [ ] **Section 1 — Contribution Heatmap:** GitHub GraphQL API call using token from `secrets.env`; color intensity follows dynamic accent scale; graceful fallback message if API unavailable
- [ ] **Section 2 — Repo List:** scans `~/dev` for `.git` directories; each repo card shows name, branch, last commit + relative time, dirty status dot; action buttons: folder (Thunar), GitHub icon (open in Brave), editor icon (open in Antigravity)
- [ ] Refresh button at top re-fetches all data
- [ ] Verify `Super + G` toggles the panel

### 12.17 — Settings Panel

- [ ] Build the settings panel per `settings.md` — this is the most complex component; build sections one at a time
- [ ] **Scaffold:** floating centered panel (~600px wide), scrollable, profile pill row at top, section list below, Chezmoi reminder banner at bottom
- [ ] **Profile manager:** Default / Battery / Gaming / Ricing profiles; save/switch/delete
- [ ] **Windows & Gaps section:** sliders for gaps_in, gaps_out, border_size, rounding; toggle for resize_on_border
- [ ] **Decoration & Blur section:** opacity sliders, blur toggles and sliders, shadow controls
- [ ] **Animations & Curves section:** enabled toggle, borderangle toggle and speed; bezier curve editor with canvas, draggable handles, preview ball, preset buttons, save to curves.json
- [ ] **Input & Touchpad section:** all touchpad toggles and sliders, mouse sensitivity, follow_mouse dropdown, workspace swipe toggle
- [ ] **Monitor section:** resolution/refresh rate dropdowns, scale slider, transform dropdown
- [ ] **Performance section:** VFR toggle, VRR dropdown
- [ ] **Window Rules editor:** list of rules with edit/delete per rule, add new rule button
- [ ] **Hyprlock section:** clock format, font size, input field width, blur strength, fade duration
- [ ] **Notifications section:** Swaync position, timeout, max shown, DND toggle
- [ ] **Miscellaneous section:** focus_on_activate, enable_swallow, animate_manual_resizes, animate_mouse_windowdrag
- [ ] Verify `Super + Shift + C` opens the panel; `Escape` closes it
- [ ] Verify `hyprctl keyword` is used for instant preview; `sed` + `hyprctl reload` for persistence
- [ ] Verify Chezmoi reminder banner is visible at the bottom

---

## Phase 13 — Final Checks and Chezmoi Commit

- [ ] Test every keybind in `keybinds.md` end to end — open the document and go through it line by line
- [ ] Test all three screenshot modes: `Print`, `Super + Print`, and the screenshot submap (`Super + Shift + Print`)
- [ ] Test all three submaps: resize (`Super + R`), system (`Super + Shift + S`), screenshot (`Super + Shift + Print`)
- [ ] Test Zellij dev layout: `Super + Shift + Z` → three panes, lazygit in top-right
- [ ] Test Yazi: `Super + E` → Kitty opens with Yazi; verify it's themed
- [ ] Test color picker: `Super + C` → hyprpicker → click a pixel → verify hex is copied to clipboard and a notification appears
- [ ] Test clipboard history: copy a few things, then `Super + Shift + V` → Rofi shows history
- [ ] Reboot and verify everything starts correctly from SDDM login
- [ ] Do a final `chezmoi diff` — should be empty if you've been committing as you go; add anything that drifted
- [ ] Final Chezmoi commit and push:
  ```bash
  chezmoi add ~/.config/
  chezmoi add ~/.zshrc
  chezmoi git -- commit -m "feat: complete desktop setup"
  chezmoi git -- push
  ```

---

## Dependency Map

This is what each phase depends on. If something in a later phase isn't working, trace back to the phase it depends on.

```
Phase 1 (base verify)
  └── Phase 2 (SSH + git)
        └── Phase 3 (Hyprland first boot)
              └── Phase 4 (SDDM)
              └── Phase 5 (font rendering)         ← font-rendering.md
              └── Phase 6 (wallpaper + matugen)    ← matugen-setup.md, wallpaper-change.sh, wallpaper-picker.sh, all matugen templates
                    └── Phase 7 (per-app theming)  ← kitty.conf, hyprlock.conf, hypridle.conf, zellij-config.kdl, dev-layout.kdl, gtk-3.0-settings.ini
                    └── Phase 12 (Quickshell bar)  ← colors.qml reads matugen output; cava.config at 12.13
              └── Phase 8 (Flatpak apps)
              └── Phase 9 (Brave)
              └── Phase 10 (dev tools)
              └── Phase 11 (Chezmoi init)          ← pacman-hooks.md; do after Phases 3–10 are stable
              └── Phase 12 (Quickshell bar)
                    └── Phase 13 (final checks)
```

---

## Reference Documents

| What you're building | Document to open |
|---|---|
| Hyprland config values | `hyprland_settings.md` |
| Keybinds | `keybinds.md` |
| Visual style, wallpaper, per-app theming | `visuals.md` |
| Quickshell bar layout and component spec | `quickshell_plan.md` |
| Settings panel spec | `settings.md` |
| Full software stack and rationale | `setup_plan.md` |
| System install steps | `installation_plan.md` |
| Ongoing maintenance | `maintenance.md` |
| matugen template setup and verification | `matugen-setup.md` |
| Pacman hooks (sbctl + GRUB fallback) | `pacman-hooks.md` |
| Font rendering shell steps | `font-rendering.md` |