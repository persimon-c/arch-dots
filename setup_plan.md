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
# GRUB_CMDLINE_LINUX_DEFAULT="... nvidia-drm.modeset=1 ibt=off"
# ibt=off disables Intel CET enforcement — required on some kernel versions
# where the NVIDIA driver fails to load without it. Harmless if not needed.
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Hyprland Environment Variables

```bash
# ~/.config/hypr/hyprland.conf
# Do NOT hardcode /dev/dri/card1 — device numbering is not stable across boots.
# After first boot, find the stable AMD GPU path:
#   ls -la /dev/dri/by-path/
# Look for the entry pointing to a cardN device on the AMD PCI address (will contain "amd" or match the iGPU PCI slot).
# Use that full /dev/dri/by-path/... symlink as the value instead.
env = WLR_DRM_DEVICES,/dev/dri/by-path/<amd-pci-path-here>
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
| Power/fan control | asusctl + supergfxctl | ASUS-native control — fan curves, performance profiles, GPU switching. Linux equivalent of GHelper/Armoury Crate |

### Desktop Environment

| Component | Package | Rationale |
|---|---|---|
| Compositor | Hyprland | Wayland-native tiling, low RAM, smooth animations, active development |
| Status bar + widgets | Quickshell | QML-based, very high widget flexibility, native match for meloworld aesthetic — built with it |
| Dock | nwg-dock-hyprland | Quick app access for users transitioning from Windows taskbar |
| App launcher | Rofi-wayland | More powerful and customizable than Wofi |
| Notifications | Swaync | Notification center panel, more functional than Dunst/Mako for daily use |
| Wallpaper | Awww | Supports animated wallpapers and smooth transitions, superset of Hyprpaper |
| Dynamic theming | matugen | Generates Material You accent palette from wallpaper; blended with Catppuccin Mocha base for dynamic theming |
| Wallpaper thumbnails | tumbler | Generates XDG-spec thumbnails for Rofi wallpaper picker |
| Screen locker | Hyprlock | Made by the Hyprland developer, native integration |
| Idle manager | Hypridle | Companion to Hyprlock, handles auto-lock and display timeout |
| Portals | xdg-desktop-portal-hyprland + xdg-desktop-portal-gtk | Required for file picker dialogs and drag-and-drop into browser |

### SDDM Theme

Custom pixel art / anime theme. Target aesthetic: character sprite, clock display, minimal login panel. Theme to be sourced from GitHub community SDDM themes post-install.

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

### Flatpak

Flatpak is used for Electron-heavy apps and anything with known Wayland compatibility issues as native AUR builds. This avoids debugging broken screen share or rendering issues at inconvenient times.

**Install Flatpak:**
```bash
sudo pacman -S flatpak
```

**Flatpak-preferred apps:**

| App | Reason |
|---|---|
| Discord | AUR build has recurring Wayland/screen share issues; Flatpak is more stable |
| Zoom | Native build lags behind upstream; Flatpak stays current |
| Spotify | Either works; Flatpak avoids occasional AUR breakage on updates |

Everything else (Brave, OBS, Blender, dev tools) stays native — Flatpak sandbox overhead isn't worth it for tools you control.

**Wayland flags for Flatpak Electron apps:**
```bash
# Run once per app via Flatseal, or set globally in /etc/environment
ELECTRON_OZONE_PLATFORM_HINT=auto
```

---

### Fonts

| Font | Package | Purpose |
|---|---|---|
| JetBrains Mono Nerd Font | ttf-jetbrains-mono-nerd | Primary coding font, includes icons for terminal/bar/Neovim |
| Noto Fonts Emoji | noto-fonts-emoji | Emoji rendering |
| Noto Fonts CJK | noto-fonts-cjk | Japanese kaomoji and CJK character support |

### Font Rendering

Arch's default font rendering is noticeably worse than Windows — fonts look slightly blurry or uneven without configuration. Fix this post-install:

```bash
sudo pacman -S freetype2 fontconfig
```

Create `/etc/fonts/local.conf`:
```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Enable subpixel rendering (RGB layout for most monitors) -->
  <match target="font">
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
  </match>

  <!-- Enable hinting -->
  <match target="font">
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
  </match>

  <!-- Enable antialiasing -->
  <match target="font">
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
  </match>
</fontconfig>
```

Then rebuild the font cache:
```bash
fc-cache -fv
```

Log out and back in for changes to take effect. If text still looks off in specific apps, check whether the app respects fontconfig (most GTK/Qt apps do; Electron apps may need additional flags).

This config is tracked in Chezmoi as a system file.

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

### Power Management & Fan Control

The FX505DT is an ASUS laptop, so `asusctl` is the Linux equivalent of GHelper. It controls fan curves, performance profiles (Silent/Balanced/Turbo), and some LED/keyboard settings. `supergfxctl` handles GPU switching if needed.

```bash
# Add asus-linux repo (these packages are not in the main Arch repos)
yay -S asusctl supergfxctl
sudo systemctl enable --now asusd
sudo systemctl enable --now supergfxd

# GPU monitoring for Quickshell stats panel
sudo pacman -S radeontop
# Note: radeontop requires a udev rule for non-root access — add after first boot:
# echo 'SUBSYSTEM=="drm", ACTION=="add", GROUP="video", MODE="0660"' | sudo tee /etc/udev/rules.d/99-drm.rules
# sudo udevadm control --reload && sudo udevadm trigger
# Add your user to the video group: sudo usermod -aG video simone
```

Key asusctl commands:
```bash
asusctl profile --list          # list available profiles
asusctl profile -P Balanced     # switch to Balanced (Silent / Balanced / Performance)
asusctl fan-curve -m Balanced   # view fan curve for a profile
asusctl fan-curve -e true       # enable custom fan curves
```

The ROG Control Center GUI (`asusctl-rog-gui`, available via yay) provides a graphical interface similar to Armoury Crate / GHelper for adjusting fan curves per profile, viewing temps, and switching modes without the terminal.

Quickshell bar widget can call `asusctl profile -P <mode>` via a `Process` component to switch profiles on click — replaces the `power-profiles-daemon` widget originally planned.

**Note:** `power-profiles-daemon` conflicts with `asusctl` and should not be installed alongside it. Remove it from the software stack if present.

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

## Quickshell Bar Layout

> **Note:** The exact bar layout will be designed post-install. The following is the current direction, not a final specification.

**Design inspiration:** The meloworld-dotfiles aesthetic — minimal top bar, click-to-reveal panels, glassmorphism styling. Quickshell is the tool meloworld was built with, so the reference dotfiles serve as a direct implementation reference.

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
System stats are hidden by default and revealed on demand via a clickable button in the bar. The panel shows:
- CPU usage + temperature
- RAM usage
- GPU usage
- Storage (root and home usage)
- Network speed

Implemented as a Quickshell popup component triggered by a bar button click. Shell commands for system data are called via `Quickshell.shell` or `Process`; output is bound to QML properties.

**Music player popup:**
Clicking the now-playing widget in the center of the bar opens a full Spotify player popup with album art, progress bar, and playback controls. Powered by `playerctl`.

```bash
sudo pacman -S playerctl
```

Quickshell reads playerctl output via a `Process` component and exposes it to the QML UI. The meloworld dotfiles include a working reference implementation of this pattern.

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
| `Super + Q` | Close window |
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
| `Super + W` | Wallpaper switcher (Rofi picker) |

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

> **This section is superseded by `visuals.md`**, which contains the full definitive color and aesthetic plan. Refer to `visuals.md` for all color decisions, matugen integration, wallpaper switcher details, and per-app theming. Do not use the description below as a source of truth — it is kept here for historical context only.

**Catppuccin Mocha base + matugen dynamic accent.** Base/surface/text colors are hardcoded Catppuccin Mocha. Accent colors (borders, highlights, active states) are dynamically generated by matugen from the current wallpaper. Lavender (`#b4befe`) is the fallback accent before any wallpaper is processed.

Applied consistently across: Hyprland, Kitty, Rofi, Quickshell, Swaync, Hyprlock, SDDM, Zathura, Btop.

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
    inactive_opacity = 0.80
    drop_shadow = true
    shadow_range = 20
    col.shadow = rgba(00000066)
}
```

Works best with anime landscape wallpapers where background color bleeds through frosted windows.

### Bar & Widget Tool — Quickshell

**Quickshell** (QML-based) is the chosen tool for the bar and all desktop widgets. It is what the meloworld dotfiles were built with, making those dotfiles a direct reference implementation for the target aesthetic.

- Config language: QML (declarative, similar to JS)
- Very high widget flexibility
- `Process` and `Quickshell.shell` for reading system data (playerctl, asusctl, etc.)
- Fewer community resources than Eww, but the meloworld dotfiles cover the exact patterns needed

Install via yay:
```bash
yay -S quickshell-git
```

### Wallpaper Direction

Anime landscape wallpapers — sky, nature, Mt. Fuji style, pastoral scenes. Colors should complement the pastel palette. Awww handles animated wallpapers with smooth transitions if animated wallpapers are desired later.

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

## Pacman Hooks (System Event Notifications)

Certain system updates require manual follow-up that's easy to forget. Pacman hooks automate reminders or actions when specific packages are updated.

### Hook: Remind to re-sign after GRUB or kernel update

When GRUB or the kernel is updated, the sbctl signatures become stale — Secure Boot will fail on next boot unless you re-sign. A pacman hook prints a reminder automatically.

```ini
# /etc/pacman.d/hooks/sbctl-sign-reminder.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = grub
Target = linux

[Action]
Description = Reminder: re-sign GRUB and kernel with sbctl
When = PostTransaction
Exec = /usr/bin/echo "ACTION REQUIRED: Run 'sudo sbctl sign-s /efi/EFI/GRUB/grubx64.efi && sudo sbctl sign -s /boot/vmlinuz-linux' to maintain Secure Boot"
```

Or automate the signing entirely:
```ini
[Action]
Description = Re-signing bootloader and kernel with sbctl
When = PostTransaction
Exec = /bin/sh -c 'sbctl sign -s /efi/EFI/GRUB/grubx64.efi && sbctl sign -s /boot/vmlinuz-linux'
```

### Hook: Remind to copy GRUB fallback after GRUB update

```ini
# /etc/pacman.d/hooks/grub-fallback.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = grub

[Action]
Description = Copying GRUB to UEFI fallback path
When = PostTransaction
Exec = /bin/cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/Boot/bootx64.efi
```

This one can be automated without risk — it's just a file copy.

Both hook files are tracked in Chezmoi as system files.

---

## Hyprland Config Structure

Hyprland config lives in `~/.config/hypr/`. Rather than one large `hyprland.conf`, it's split into focused files sourced from the main config. This keeps things navigable and makes it easy to share or version-control individual pieces.

### File Structure

```
~/.config/hypr/
├── hyprland.conf         # Entry point — sources everything else
├── env.conf              # Environment variables (GPU path, Wayland flags, etc.)
├── monitor.conf          # Monitor layout and resolution
├── input.conf            # Keyboard, touchpad, sensitivity settings
├── keybinds.conf         # All bind = lines
├── windowrules.conf      # Window rules and workspace assignments
├── animations.conf       # Animation curves and speeds
├── decoration.conf       # Blur, rounding, shadows, opacity
├── layout.conf           # Tiling layout settings (gaps, border sizes)
└── autostart.conf        # exec-once lines (Quickshell, awww, hypridle, etc.)
```

### hyprland.conf (entry point)

```ini
# ~/.config/hypr/hyprland.conf
source = ~/.config/hypr/env.conf
source = ~/.config/hypr/colors.conf
source = ~/.config/hypr/monitor.conf
source = ~/.config/hypr/input.conf
source = ~/.config/hypr/decoration.conf
source = ~/.config/hypr/animations.conf
source = ~/.config/hypr/layout.conf
source = ~/.config/hypr/windowrules.conf
source = ~/.config/hypr/keybinds.conf
source = ~/.config/hypr/autostart.conf
```

### Rationale

- **env.conf separate** — GPU path, `LIBVA_DRIVER_NAME`, and Wayland flags are hardware-specific. Keeping them isolated makes it easy to diff or override per machine if Chezmoi templates are used later.
- **keybinds.conf separate** — already has a standalone `keybinds.md` in the repo; the config file mirrors that document.
- **autostart.conf separate** — exec-once lines change often during ricing; isolation reduces noise in git diffs. Must include:
  - `exec-once = awww-daemon` — starts the wallpaper daemon
  - `exec-once = ~/.config/hypr/scripts/wallpaper-change.sh ~/.cache/current_wallpaper` — restores the last wallpaper on login; falls back gracefully if cache file does not exist yet
- **decoration + animations separate** — these are the most frequently tweaked during ricing. Isolation keeps the iteration loop tight.

All files tracked in Chezmoi and mirrored in the `hypr/` folder of the dotfiles repo.

---

## Package List & System Reproducibility

A maintained package list means a full reinstall or new machine setup takes minutes instead of days. The strategy is simple: export the explicit package list regularly and keep it in the dotfiles repo.

**This will be set up after the install is complete and the full software stack is stable.** The plan will be documented at that point, including the export command, Chezmoi integration, and AUR vs official package handling.

---

## Post-Install Manual Configuration Steps

These require manual attention after base install — they cannot be scripted generically:

| Step | Complexity | Notes |
|---|---|---|
| NVIDIA + AMD hybrid GPU config | High | Most critical, black screen risk if wrong |
| Hyprland config (keybinds, rules, animations) | High | Core of the desktop experience — split file structure per Hyprland Config Structure section |
| Quickshell bar layout (QML) | Medium | QML is declarative and JS-like; meloworld dotfiles are a direct reference |
| SDDM pixel art theme | Medium | Source theme from GitHub, configure |
| Secure Boot signing (sbctl) | Medium | Do after first successful boot |
| Font rendering (fontconfig) | Low | `/etc/fonts/local.conf` — subpixel + hinting |
| Pacman hooks (sbctl + GRUB fallback) | Low | Set up after Secure Boot signing is confirmed working |
| GRUB fallback path | Low | One command, run after GRUB install |
| zsh + Zinit plugins | Low | Autosuggestions, syntax highlighting, fzf |
| SSH key generation | Low | `ssh-keygen -t ed25519` |
| Docker data-root to /home | Low | Edit daemon.json before first use |
| Brave profiles | Low | Create university profile |
| Chezmoi dotfiles init | Low | Initialize after configs are working |
| asusctl / supergfxctl setup | Low | Enable asusd and supergfxd services, configure fan curves via asusctl or ROG GUI |
| Bluetooth device pairing | Low | `bluetoothctl` or Blueman GUI |
| ufw rules | Low | Default deny incoming is sufficient |
| Hyprlock appearance | Low | Catppuccin Mocha base + dynamic accent from matugen; background reads from ~/.cache/current_wallpaper |
| Hypridle timeouts | Low | 5min lock, 10min display off |
| Flatpak + Flatseal setup | Low | Install Discord, Zoom, Spotify via Flatpak; set Wayland flags via Flatseal |
| matugen setup | Low | Run once against first wallpaper to generate initial color files; verify ~/.config/matugen/colors.sh exists |
| Wallpaper switcher script | Low | Write wallpaper-change.sh (awww → matugen → app reloads) and Rofi wallpaper picker script; set keybind |

---

## Desktop Widget Plans (Future)

### Git / Repo Stats Widget

A persistent desktop widget showing Git/repo information is planned post-install:

- List of cloned repositories (similar to GitHub Desktop sidebar)
- Last commit per repo
- Open pull requests

Implementation via Quickshell widgets using `Process` components to pull from GitHub API or local git commands. This will be designed after the base environment is stable.

### Onefetch — Terminal Repo Info

[Onefetch](https://github.com/o2sh/onefetch) is a command-line Git information tool that displays project information and code statistics for a local Git repository directly in the terminal — language breakdown, commit count, contributors, license, and more.

```bash
yay -S onefetch
# Run inside any git repo:
onefetch
```

Planned integration: auto-run onefetch when `cd`-ing into a git repository via a zsh hook. Add a guard so it only runs on repos below a certain size — large repos with deep histories make onefetch slow and the output noisy. A simple check on object count works:

```bash
# ~/.zshrc — add to chpwd hook or similar
function chpwd() {
    if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
        local obj_count=$(git count-objects | awk '{print $1}')
        if [[ $obj_count -lt 10000 ]]; then
            onefetch
        fi
    fi
}
```

Adjust the threshold to taste. This keeps onefetch fast and skips it silently on large repos.

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
| VPN | Dropped from plan |
| Office suite | Switching to Windows for document printing |
| Night light filter | Not needed |
| Input method (fcitx) | English only, no IME needed |
| Virtual machine manager | Docker covers containerization needs |
| LTS kernel | Standard kernel has better hardware support for this laptop |
| btrfs | ext4 chosen for performance, simplicity |
| power-profiles-daemon | Conflicts with asusctl — use asusctl for ASUS hardware instead |
| Paru | yay chosen as AUR helper |
| Hyprpaper | Awww is a strict superset |
| Eww | Quickshell chosen — native match for meloworld aesthetic, QML is more familiar than Yuck |

---

## References

- [Arch Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [Hyprland Wiki](https://wiki.hyprland.org)
- [Hyprland NVIDIA Guide](https://wiki.hyprland.org/Nvidia/)
- [Catppuccin Theme](https://github.com/catppuccin)
- [Quickshell](https://quickshell.outfoxxed.me)
- [Antigravity IDE](https://antigravity.google)
- [Onefetch](https://github.com/o2sh/onefetch)
- [nwg-dock-hyprland](https://github.com/nwg-piotr/nwg-dock-hyprland)
- [matugen](https://github.com/InioX/matugen)