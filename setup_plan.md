# My Arch Linux Setup Plan

A detailed, hardware-specific plan for installing and configuring Arch Linux as a dual-boot alongside Windows 11 on an ASUS TUF Gaming FX505DT. Intended for personal reference and as a public resource for anyone with similar hardware or goals.

---

## Hardware Specifications

| Component | Details |
|---|---|
| **Device** | ASUS TUF Gaming FX505DT |
| **CPU** | AMD Ryzen 5 3550H (4 cores, 8 threads, 2100MHz) |
| **GPU (iGPU)** | AMD Radeon Vega Mobile (integrated, in CPU) |
| **GPU (dGPU)** | NVIDIA GeForce GTX 1650 (discrete) |
| **RAM** | 8GB |
| **SSD** | 238GB NVMe (TS256GMTE110S) — Windows + Arch root |
| **HDD** | 931GB SATA (ST1000LM035) — Windows storage + Arch home |
| **BIOS Mode** | UEFI |
| **Secure Boot** | Must be disabled before install |

---

## Goals

- Dual boot Arch Linux alongside Windows 11
- Fast, efficient, keyboard-driven developer environment
- Minimal RAM and CPU overhead
- Full web and backend development workflow
- DevOps tooling support
- Aesthetic, customized desktop using Hyprland

---

## Disk Layout

### Before Installing

Two steps must be done in Windows Disk Management before booting the Arch USB:

1. **Shrink C: (SSD)** by 51200MB to create 50GB of unallocated space for Arch root
2. **Shrink D: (HDD)** by 641024MB to create ~627GB of unallocated space for Arch home and swap, leaving 300GB for Windows D: drive

### Final Partition Layout

**Disk 1 — NVMe SSD (nvme0n1)**

| Partition | Size | Filesystem | Mount | Notes |
|---|---|---|---|---|
| nvme0n1p1 | ~100MB | FAT32 | `/efi` | Existing Windows EFI — shared with GRUB |
| nvme0n1p2 | ~16MB | — | — | Existing Windows MSR — do not touch |
| nvme0n1p3 | ~128GB | NTFS | — | Existing Windows C: — do not touch |
| nvme0n1p4 | 50GB | ext4 | `/` | Arch root — NEW |

**Disk 0 — HDD (sda)**

| Partition | Size | Filesystem | Mount | Notes |
|---|---|---|---|---|
| sda1 | 300GB | NTFS | — | Existing Windows D: — do not touch |
| sda2 | 4GB | swap | swap | Arch swap — NEW |
| sda3 | ~627GB | ext4 | `/home` | Arch home — NEW |

### Rationale

- **Root on SSD** — OS, apps, and tools benefit most from SSD speed. Boot time, app launch, and package operations are all faster.
- **Home on HDD** — Projects, Docker data, databases, and media are size-sensitive, not speed-sensitive. 627GB provides ample room.
- **ext4 over btrfs** — ext4 is battle-tested, simpler, and slightly faster for this use case. Snapshot capability of btrfs was considered but deprioritized in favor of raw performance.
- **Swap on HDD** — Swap is a last resort. Speed is irrelevant for swap; putting it on HDD preserves SSD write cycles.
- **Shared EFI partition** — Reusing the existing Windows EFI partition is cleaner and avoids BIOS boot order complications. GRUB installs here and detects both OSes via os-prober.

---

## BIOS Settings

Before booting the Arch USB, configure the following in BIOS (press F2 on boot):

| Setting | Value | Reason |
|---|---|---|
| Secure Boot | Disabled | Required for Arch ISO to boot — re-enabled after install via sbctl (see Dual Boot Protection) |
| Fast Boot | Disabled | Can interfere with dual boot |
| SVM Mode | **Leave enabled** | Required for Docker and local Kubernetes |
| Boot order | USB first | Boot Arch USB before Windows |

### Pre-install Windows Steps

```powershell
# Disable hypervisor launch (run as Administrator)
bcdedit /set hypervisorlaunchtype off

# Disable hibernation (frees ~6GB and removes hiberfil.sys)
powercfg /hibernate off
```

---

## System Configuration

| Setting | Value |
|---|---|
| **Username** | simone |
| **Hostname** | persmon |
| **Timezone** | Asia/Manila |
| **Locale** | en_US.UTF-8 |
| **Keyboard** | US (English only) |
| **Shell** | zsh |
| **Kernel** | linux (standard, not LTS) |
| **Filesystem** | ext4 |
| **Bootloader** | GRUB |

### Rationale

- **Standard kernel over LTS** — The Ryzen 5 3550H and GTX 1650 benefit from newer kernel patches, particularly for hybrid GPU support and AMD power management improvements.
- **zsh over bash** — Better autocompletion, history search, and plugin ecosystem. Essential for a developer workflow.

---

## GPU Setup (Hybrid Graphics)

The FX505DT uses AMD+NVIDIA hybrid graphics (NVIDIA Optimus). This requires manual configuration on Linux.

### Strategy

Run Hyprland on the AMD iGPU by default. Use the NVIDIA dGPU for GPU-intensive tasks (games, rendering) via PRIME offload. This maximizes battery life while preserving gaming capability.

### Driver Installation

```bash
# AMD (primary, runs Hyprland)
sudo pacman -S mesa vulkan-radeon libva-mesa-driver

# NVIDIA (discrete, for offload)
sudo pacman -S nvidia nvidia-utils nvidia-settings

# Add NVIDIA modules to initramfs
# Edit /etc/mkinitcpio.conf:
# MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
sudo mkinitcpio -P

# Add to GRUB kernel parameters in /etc/default/grub:
# GRUB_CMDLINE_LINUX_DEFAULT="... nvidia-drm.modeset=1"
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Hyprland Environment Variables

```bash
# ~/.config/hypr/hyprland.conf
env = WLR_DRM_DEVICES,/dev/dri/card1
env = LIBVA_DRIVER_NAME,radeonsi
env = WLR_NO_HARDWARE_CURSORS,1
```

### PRIME Offload (Running apps on NVIDIA)

```bash
# Prefix any app to run on NVIDIA dGPU
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia appname
```

### Rationale

- **AMD as primary** — Running the compositor on AMD iGPU dramatically reduces power consumption for daily dev work. The NVIDIA GPU would drain the battery in ~1.5 hours if used full-time.
- **PRIME offload** — Allows selective use of NVIDIA for games or GPU-intensive tasks without a permanent switch.

---

## Complete Software Stack

### Core System

| Component | Package | Rationale |
|---|---|---|
| Bootloader | GRUB + os-prober | Best dual-boot Windows detection |
| Display manager | SDDM | Supports custom anime/pixel art themes, Wayland compatible |
| Init system | systemd | Arch default, no reason to change |
| AUR helper | yay | Most popular, well maintained |
| Microcode | amd-ucode | CPU stability and security patches |

### Desktop Environment

| Component | Package | Rationale |
|---|---|---|
| Compositor | Hyprland | Wayland-native tiling, low RAM, smooth animations, active development |
| Status bar + widgets | Eww | More flexible than Waybar — supports custom widgets beyond a status bar using Yuck (Lisp-like) config |
| Dock | nwg-dock-hyprland | Quick app access for users transitioning from Windows taskbar |
| App launcher | Rofi-wayland | More powerful and customizable than Wofi |
| Notifications | Swaync | Notification center panel, more functional than Dunst/Mako for daily use |
| Wallpaper | Swww | Supports animated wallpapers and smooth transitions, superset of Hyprpaper |
| Screen locker | Hyprlock | Made by the Hyprland developer, native integration |
| Idle manager | Hypridle | Companion to Hyprlock, handles auto-lock and display timeout |
| Portals | xdg-desktop-portal-hyprland + xdg-desktop-portal-gtk | Required for file picker dialogs and drag-and-drop into browser |

### SDDM Theme

Custom pixel art / anime theme. Target aesthetic: character sprite, clock display, minimal login panel. Theme to be sourced from GitHub community SDDM themes post-install.

Auto-login configuration:
```ini
# /etc/sddm.conf.d/autologin.conf
[Autologin]
User=simone
Session=hyprland
```

### Terminal & Shell

| Component | Package | Rationale |
|---|---|---|
| Terminal | Kitty | GPU-accelerated, excellent font rendering, feature-rich, large community |
| Multiplexer | Zellij | Modern Rust-based multiplexer, persists sessions, more intuitive than tmux |
| Shell | zsh | Better than bash for developers |
| Plugin manager | Zinit | Faster than Oh My Zsh via lazy loading, same plugin ecosystem |
| Quick editor | Helix | Modern modal editor, built-in LSP, no plugin configuration needed |

### Development Tools

| Component | Package | Rationale |
|---|---|---|
| Main IDE | Antigravity (Google) | AI-native agentic IDE, VS Code fork, free, Gemini 3 Pro powered |
| Secondary IDE | VSCode | Backup and familiarity |
| Markdown/docs editor | Sublime Text 4 | Visual tabs, separate from project context, familiar |
| Node version manager | fnm | Faster than nvm, written in Rust |
| Python version manager | pyenv | Standard for web/backend Python development |
| Git UI | Lazygit | Terminal UI, shows diffs, changed files, file paths — replaces GitHub Desktop |
| Dotfiles manager | Chezmoi | Templating, secrets support, works across machines |
| Containers | Docker | Most compatibility with dev tooling |
| System monitor | Btop | Shows CPU, RAM, GPU, network, disk in one beautiful TUI |

Docker data directory must be configured to `/home` to avoid filling the root partition:
```json
// /etc/docker/daemon.json
{
  "data-root": "/home/docker-data"
}
```

DevOps tools (kubectl, helm, terraform, ansible) are **intentionally not installed at setup**. They will be installed when projects require them to avoid unnecessary bloat.

### File Management

| Component | Package | Rationale |
|---|---|---|
| Terminal file manager | Yazi | Rust-based, extremely fast, keyboard-driven, path yanking |
| GUI file manager | Thunar | Lightweight, drag-and-drop to browser, essential for attaching files |
| Screenshot | Hyprshot | Wrapper around grim, simplest for Hyprland |
| Clipboard | Cliphist + wl-clipboard | Lightweight Wayland-native clipboard history |

### Applications

| Component | Package | Rationale |
|---|---|---|
| Browser | Brave | Fastest modern browser, lowest RAM, built-in ad blocking, familiar from Windows |
| Music | Spotify + mpv | Spotify for streaming, mpv for local audio/video files and voice recordings |
| Image viewer | Imv | Wayland-native, minimal, instant launch |
| PDF viewer | Zathura | Keyboard-driven, minimal, Catppuccin theme available |
| Recording | OBS Studio | Wayland flag required: `OBS_USE_EGL=1 obs` |
| Communication | Discord + Zoom | Standard tools, both available on Arch |
| 3D | Blender | Runs better on Linux than Windows |
| Version control UI | Lazygit | Terminal-based, replaces GitHub Desktop |

### Brave Browser Setup

Two separate profiles:
- **Profile 1** — Personal (GitHub, Discord, Figma, Canva, Claude)
- **Profile 2** — University (Google Classroom, university accounts)

### Fonts

| Font | Package | Purpose |
|---|---|---|
| JetBrains Mono Nerd Font | ttf-jetbrains-mono-nerd | Primary coding font, includes icons for terminal/bar/Neovim |
| Noto Fonts Emoji | noto-fonts-emoji | Emoji rendering |
| Noto Fonts CJK | noto-fonts-cjk | Japanese kaomoji and CJK character support |

### Audio

```bash
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
sudo pacman -S pavucontrol  # GUI mixer for Zoom mic routing
```

### Bluetooth

```bash
sudo pacman -S bluez bluez-utils blueman
sudo systemctl enable bluetooth
```

### Power Management

```bash
sudo pacman -S power-profiles-daemon
sudo systemctl enable power-profiles-daemon
```

Three switchable modes via Eww bar widget:
- `performance` — default, max CPU
- `balanced` — smart switching
- `power-saver` — battery priority

### Firewall

```bash
sudo pacman -S ufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo systemctl enable ufw
```

### Screen Lock & Idle

```bash
# ~/.config/hypridle/hypridle.conf
listener {
    timeout = 300
    on-timeout = hyprlock
}
listener {
    timeout = 600
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}
```

Lid close triggers lock:
```ini
# /etc/systemd/logind.conf
HandleLidSwitch=lock
```

---

## Eww Bar Layout

> **Note:** The exact bar layout will be designed post-install. The following is the current direction, not a final specification.

**Design inspiration:** The knight armor desktop aesthetic (Image 2/3 references) — minimal top bar, click-to-reveal panels, glassmorphism styling.

**Confirmed bar elements:**

```
LEFT:   [arch button]  [workspace indicators 1-4]  [active window title]
CENTER: [Spotify now playing — click to open full music player popup]
RIGHT:  [power mode]  [battery %]  [volume]  [network]  [bluetooth]  [tray]  [clock + date]
```

**Arch button** — clickable Arch Linux logo on the far left of the bar. Clicking it opens the system stats panel (CPU, RAM, GPU, temp, storage). Inspired by the reference desktop aesthetic.

**Intentionally excluded from bar:**
- CPU % and RAM % — too noisy for constant display
- Mic toggle — mute handled inside Zoom/Discord directly
- Calendar in bar — undecided, revisit post-install

**Stats panel (click-to-reveal):**
System stats are hidden by default and revealed on demand via a clickable button in the bar (similar to clicking the Arch logo in reference images). The panel shows:
- CPU usage + temperature
- RAM usage
- GPU usage
- Storage (root and home usage)
- Network speed

Implemented as an Eww popup widget triggered by a bar button click.

**Music player popup:**
Clicking the now-playing widget in the center of the bar opens a full Spotify player popup with album art, progress bar, and playback controls. Powered by `playerctl`.

```bash
sudo pacman -S playerctl
```

**Taskbar (active windows):**
`nwg-dock-hyprland` configured to show currently open windows only, autohides until hovered. Appears at the bottom of the screen. Replaces the need for a persistent taskbar while keeping Windows-like app visibility on demand.

---

## Workspace Layout

| Workspace | Purpose | Notes |
|---|---|---|
| 1 | Main | Everything — primary daily workspace |
| 2 | Terminal | Running tests, dev servers, long-running processes |
| 3 | Overflow | When workspace 1 gets crowded |
| 4 | Communication | Discord, Zoom during calls |

No rigid app assignments. No automatic app launch on login. Apps open manually and move between workspaces freely. Workspace 2 exists specifically so test runners and servers don't clutter the main workspace.

---

## Keybindings

### Window Management

| Keybind | Action |
|---|---|
| `Super + W` | Close window |
| `Super + F` | Fullscreen |
| `Super + Shift + F` | Toggle floating |
| `Super + Left/Right/Up/Down` | Move focus |
| `Super + Shift + Left/Right/Up/Down` | Move window |
| `Super + Ctrl + Left/Right/Up/Down` | Resize window |
| `Super + L` | Lock screen |
| `Super + M` | Exit Hyprland |

### Applications

| Keybind | Action |
|---|---|
| `Super + Return` | Kitty terminal |
| `Super + Space` | Rofi launcher |
| `Super + B` | Brave browser |
| `Super + A` | Antigravity |
| `Super + S` | Sublime Text |
| `Super + T` | Thunar |
| `Super + D` | Discord |
| `Super + Shift + V` | Clipboard history |

### Workspaces

| Keybind | Action |
|---|---|
| `Super + 1-4` | Switch to workspace |
| `Super + Shift + 1-4` | Move window to workspace |
| `Super + Scroll` | Cycle workspaces |

### Screenshots

| Keybind | Action |
|---|---|
| `Print` | Full screen screenshot |
| `Super + Print` | Selected area screenshot |
| `Super + Shift + Print` | Active window screenshot |

### Media & System

| Keybind | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Mute toggle |
| `XF86AudioMicMute` | Mic mute toggle |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |

---

## Touchpad Configuration

```bash
# ~/.config/hypr/hyprland.conf
input {
    touchpad {
        natural_scroll = false
        tap-to-click = true
        scroll_factor = 1.0
        disable_while_typing = true
    }
    sensitivity = 0.5
}

gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
    workspace_swipe_cancel_ratio = 0.5
}
```

---

## Visual Style & Color Scheme

### Aesthetic Direction

Primary inspiration: **Image 1** — blue anime landscape (Mt. Fuji style), glassmorphism terminal windows, minimal top bar, bottom dock, neofetch in terminal. Clean, uncluttered, dark with frosted glass elements.

Secondary inspiration: **Image 2** — meloworld-dotfiles by melatonia (https://github.com/melatonia/meloworld-dotfiles), featuring left side widget panel, Spotify music player popup in center bar, system stats panel, colorful pastel accents on dark background, rounded cards.

Both desktops use different window managers (awesomewm and mangowm respectively) — the aesthetic is the inspiration, not the config files. Everything will be rebuilt for Hyprland.

### Color Scheme

**Colorful pastel on dark background** — soft, muted, vibrant without being harsh. Not a single theme but a direction:
- Dark background panels (~#1e1e2e range)
- Pastel colored accents — purples, pinks, greens, yellows
- No harsh whites or blacks
- Colors inspired by meloworld/crylia aesthetic

Closest named theme: **Catppuccin Mocha** with custom pastel accent overrides. Exact palette to be finalized during ricing post-install.

Applied consistently across:
- Hyprland borders and animations
- Kitty terminal
- Rofi launcher
- Quickshell/Eww bar
- Zathura PDF viewer
- SDDM theme
- Sublime Text
- Btop

### Glassmorphism

Windows use blur, transparency, and rounded corners — frosted glass effect with wallpaper bleeding through.

```bash
# ~/.config/hypr/hyprland.conf
decoration {
    rounding = 12
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = true
        xray = false
    }
    active_opacity = 0.92
    inactive_opacity = 0.85
    drop_shadow = true
    shadow_range = 20
    col.shadow = rgba(00000066)
}
```

Works best with anime landscape wallpapers where background color bleeds through frosted windows.

### Bar & Widget Tool — Eww vs Quickshell

The meloworld aesthetic (primary inspiration for bar/widgets) was built using **Quickshell** (QML-based). Quickshell is newer, actively developed, and produces the exact widget style desired.

| | Eww | Quickshell |
|---|---|---|
| Config language | Yuck (Lisp-like) | QML (declarative, similar to JS) |
| Widget flexibility | High | Very high |
| Community resources | More | Less but growing |
| meloworld aesthetic | Achievable | Native — built with it |
| Learning curve | Steep | Moderate for devs |

**Decision:** To be finalized post-install. Quickshell is worth evaluating given the direct aesthetic match. The meloworld dotfiles serve as a reference implementation regardless of which tool is chosen.

### Wallpaper Direction

Anime landscape wallpapers — sky, nature, Mt. Fuji style, pastoral scenes. Colors should complement the pastel palette. Swww handles animated wallpapers with smooth transitions if animated wallpapers are desired later.

---

## Dual Boot Protection

### The Problem

Two known issues affect dual boot stability over time:

1. **Windows Update resets UEFI boot order** — Windows periodically sets itself as the default boot entry, bypassing GRUB. GRUB files remain intact but the system boots straight into Windows.
2. **Secure Boot conflicts** — Valorant requires Secure Boot ON. Arch (without signing) requires Secure Boot OFF. Toggling this manually every time is error-prone and increases the chance of Windows overwriting the boot order.

Both issues have permanent solutions that eliminate the need for any manual BIOS intervention after setup.

### Solution 1 — GRUB at UEFI Fallback Path

Place GRUB at the UEFI fallback boot path. Even if Windows resets the boot order, UEFI falls back to this file and loads GRUB automatically.

```bash
sudo cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/Boot/bootx64.efi
```

This is a one-time step after GRUB is installed. Re-run after any GRUB update.

### Solution 2 — Secure Boot Signing with sbctl

Sign the Arch bootloader and kernel with your own Secure Boot keys. This allows Secure Boot to remain ON permanently, satisfying Valorant's requirement while allowing Arch to boot normally.

```bash
# Install sbctl
sudo pacman -S sbctl

# Create personal Secure Boot keys
sudo sbctl create-keys

# Enroll keys — keep Microsoft keys for Windows compatibility
sudo sbctl enroll-keys --microsoft

# Sign GRUB and kernel
sudo sbctl sign -s /efi/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /boot/vmlinuz-linux

# Verify all signed correctly
sudo sbctl verify
```

After this, re-enable Secure Boot in BIOS. Both Windows and Arch will boot normally with Secure Boot permanently on.

### Combined Protection Summary

| Problem | Solution | Result |
|---|---|---|
| Windows resets boot order | GRUB at fallback EFI path | GRUB always loads |
| Secure Boot blocks Arch | sbctl signing | Arch boots with Secure Boot ON |
| Valorant needs Secure Boot | Stays enabled permanently | No toggling required |
| Windows Update overwrites GRUB | Fallback path protects it | Transparent to user |

Both steps are done **after** base Arch install and first successful boot, before re-enabling Secure Boot.

---

## Post-Install Manual Configuration Steps

These require manual attention after base install — they cannot be scripted generically:

| Step | Complexity | Notes |
|---|---|---|
| NVIDIA + AMD hybrid GPU config | High | Most critical, black screen risk if wrong |
| Hyprland config (keybinds, rules, animations) | High | Core of the desktop experience |
| Eww bar layout (Yuck syntax) | Medium | Requires learning Yuck config language |
| SDDM pixel art theme | Medium | Source theme from GitHub, configure |
| Secure Boot signing (sbctl) | Medium | Do after first successful boot |
| GRUB fallback path | Low | One command, run after GRUB install |
| zsh + Zinit plugins | Low | Autosuggestions, syntax highlighting, fzf |
| SSH key generation | Low | `ssh-keygen -t ed25519` |
| Docker data-root to /home | Low | Edit daemon.json before first use |
| Brave profiles | Low | Create university profile |
| Chezmoi dotfiles init | Low | Initialize after configs are working |
| power-profiles-daemon default | Low | Set to performance by default |
| Bluetooth device pairing | Low | `bluetoothctl` or Blueman GUI |
| ufw rules | Low | Default deny incoming is sufficient |
| Hyprlock appearance | Low | Catppuccin themed |
| Hypridle timeouts | Low | 5min lock, 10min display off |

---

## Desktop Widget Plans (Future)

### Git / Repo Stats Widget

A persistent desktop widget showing Git/repo information is planned post-install:

- List of cloned repositories (similar to GitHub Desktop sidebar)
- Last commit per repo
- Open pull requests

Implementation via Eww widgets pulling from GitHub API or local git commands. This will be designed after the base environment is stable.

### Onefetch — Terminal Repo Info

[Onefetch](https://github.com/o2sh/onefetch) is a command-line Git information tool that displays project information and code statistics for a local Git repository directly in the terminal — language breakdown, commit count, contributors, license, and more.

```bash
yay -S onefetch
# Run inside any git repo:
onefetch
```

Planned integration: auto-run onefetch when `cd`-ing into a git repository via a zsh hook. This gives instant project context every time you enter a project directory.

## Keybinding Submaps (Planned)

Hyprland supports **submaps** — modal keybinding layers similar to Vim modes. When a submap is active, a different set of keybinds applies until you exit the submap.

Planned use cases:
- **Resize submap** — enter a mode where arrow keys resize windows instead of moving focus
- **Screenshot submap** — grouped screenshot actions under one entry key
- **System submap** — power off, reboot, suspend, lock under one entry key

Exact submap keybinds will be designed post-install once the base workflow is established.

---

## Intentionally Excluded

| Thing | Reason |
|---|---|
| Gitea | Not needed — joining others' repos via GitHub |
| VPN | Dropped from plan |
| Office suite | Switching to Windows for document printing |
| Night light filter | Not needed |
| Input method (fcitx) | English only, no IME needed |
| Virtual machine manager | Docker covers containerization needs |
| LTS kernel | Standard kernel has better hardware support for this laptop |
| btrfs | ext4 chosen for performance, simplicity |
| Waybar | Eww chosen for full widget flexibility |
| Paru | yay chosen as AUR helper |
| Hyprpaper | Swww is a strict superset |

---

## References

- [Arch Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [Hyprland Wiki](https://wiki.hyprland.org)
- [Hyprland NVIDIA Guide](https://wiki.hyprland.org/Nvidia/)
- [ASUS TUF FX505 ArchWiki](https://wiki.archlinux.org/title/ASUS_TUF_Gaming_FX505)
- [Catppuccin Theme](https://github.com/catppuccin)
- [Eww Widgets](https://github.com/elkowar/eww)
- [Antigravity IDE](https://antigravity.google)
- [Onefetch](https://github.com/o2sh/onefetch)
- [nwg-dock-hyprland](https://github.com/nwg-piotr/nwg-dock-hyprland)