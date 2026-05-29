# Maintenance & Updates Reference

Ongoing maintenance guide for the Arch Linux / Hyprland setup on the ASUS TUF Gaming FX505DT.

---

## Quick Reference — What Needs Doing and How Often

| Task | Frequency | Command / Action |
|---|---|---|
| System update | Weekly | `yay` |
| Re-sign after GRUB/kernel update | After each such update | `sudo sbctl sign -s /efi/EFI/GRUB/grubx64.efi && sudo sbctl sign -s /boot/vmlinuz-linux` |
| Pacman cache cleanup | Automatic (weekly timer) | `paccache.timer` handles it |
| Docker prune | Monthly or when disk fills | `docker system prune` |
| Chezmoi commit after config changes | After any config edit | `chezmoi add <file> && chezmoi git -- commit -m "..."` |
| Check root partition usage | Monthly | `df -h /` |
| Check home partition usage | Monthly | `df -h /home` |
| Verify Secure Boot signatures valid | After kernel/GRUB update | `sudo sbctl verify` |
| Rotate GitHub personal access token | Every 90 days (or per your token expiry) | GitHub → Settings → Developer Settings → Tokens |

---

## System Updates

### Running Updates

`yay` updates both official repo packages and AUR packages in one command:

```bash
yay
```

This is equivalent to `sudo pacman -Syu` for official packages plus checking AUR packages for updates. Run it weekly to stay current.

**If you only want to update official packages:**
```bash
sudo pacman -Syu
```

**If you only want to check AUR packages:**
```bash
yay -Sua
```

### Reading the Update Output

Before confirming any update, scan the package list for anything that needs follow-up:

- `grub` or `linux` in the list → you must re-sign with sbctl after the update (see Secure Boot section)
- `nvidia` or `nvidia-utils` → check that Hyprland still starts after reboot; if not, rebuild initramfs
- `quickshell-git` → test the bar after update; QML API changes occasionally break widgets
- `hyprland` → read the Hyprland changelog before updating (`https://github.com/hyprwm/Hyprland/releases`); breaking changes are flagged there

### Pacman Mirrorlist

The mirrorlist can go stale over time — servers go down or get slower. Refresh it monthly or whenever downloads feel unusually slow:

```bash
sudo reflector --country Philippines --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
```

### Clearing the Package Cache

`paccache.timer` runs weekly automatically and keeps the 3 most recent versions of each package. You don't need to run this manually unless you're low on root space right now:

```bash
# Manual immediate cleanup — keeps last 3 versions
sudo paccache -r

# Aggressive cleanup — keep only 1 version
sudo paccache -rk1

# Remove all cached versions of uninstalled packages
sudo paccache -ruk0
```

Check how much space the cache is currently using:
```bash
du -sh /var/cache/pacman/pkg/
```

### Orphaned Packages

Packages that were installed as dependencies but are no longer needed by anything accumulate over time. Clean them up occasionally:

```bash
# List orphans
pacman -Qtdq

# Remove orphans (only if the list looks safe — review before confirming)
sudo pacman -Rns $(pacman -Qtdq)
```

Don't blindly remove everything listed — sometimes a package looks orphaned but you actually use it directly. Review the list first.

---

## Secure Boot Signatures

### Why This Is Critical

Every time `grub` or the `linux` kernel package is updated, the existing Secure Boot signatures become stale. If you reboot without re-signing, Secure Boot will block the boot and you'll land in the UEFI shell.

The pacman hook at `/etc/pacman.d/hooks/sbctl-sign-reminder.hook` either reminds you or re-signs automatically (depending on which version you set up). Even with the automated hook, it's worth knowing the manual command.

### Re-signing After a GRUB or Kernel Update

```bash
sudo sbctl sign -s /efi/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /boot/vmlinuz-linux
sudo sbctl verify
```

`sbctl verify` should show all files as signed with no failures. If anything shows unsigned, sign it before rebooting.

### Checking What Is Currently Signed

```bash
sudo sbctl verify
```

### If You Boot and Secure Boot Blocks You

Enter BIOS (F2), temporarily disable Secure Boot, boot into Arch, re-sign, verify, then re-enable Secure Boot in BIOS.

If this happens repeatedly after updates, check whether the automated pacman hook is actually running:
```bash
cat /etc/pacman.d/hooks/sbctl-sign-reminder.hook
```

---

## NVIDIA Driver Maintenance

### After NVIDIA Driver Updates

In most cases, pacman handles the initramfs rebuild automatically via a post-install hook. If Hyprland fails to start after an NVIDIA update, rebuild manually:

```bash
sudo mkinitcpio -P
reboot
```

### If Hyprland Fails to Start After Any Update

Switch to a TTY (`Ctrl+Alt+F2`) and check:

```bash
# Check for errors in the current boot
journalctl -b -p err

# Check specifically if NVIDIA module loaded
lsmod | grep nvidia

# Check Hyprland logs
journalctl --user -u hyprland
```

Common fixes:

```bash
# NVIDIA module not loading — rebuild initramfs
sudo mkinitcpio -P

# Wrong GPU path — check if the DRM device path changed
ls -la /dev/dri/by-path/
# Compare to the path in ~/.config/hypr/env.conf
# Update env.conf if the path changed, then reload Hyprland
```

### Checking NVIDIA Driver Version

```bash
nvidia-smi
```

---

## Hyprland and Desktop Config Updates

### Updating Hyprland

Hyprland updates frequently. Before updating, check the release notes:
```
https://github.com/hyprwm/Hyprland/releases
```

Breaking changes that affect config syntax are always noted. Common things that change between versions: `windowrulev2` syntax, animation curve syntax, IPC command names.

After updating, if anything looks broken:
```bash
hyprctl reload
```

If Hyprland won't start at all:
```bash
# Check for config errors
hyprctl --instance 0 dispatch exit || Hyprland 2>&1 | head -50
```

### Updating Quickshell

`quickshell-git` tracks the git HEAD of the Quickshell repo. Updates can introduce QML API changes. After updating:

1. Test the bar starts: `quickshell`
2. Check for errors: `journalctl --user -u quickshell`
3. If a component is broken, check the Quickshell changelog at `https://quickshell.outfoxxed.me` for API changes

If the bar is broken and you need it working immediately, pin to the previous commit:
```bash
# Find the previous working version
yay -Qi quickshell-git
# Downgrade (yay caches previous versions in /var/cache/pacman/pkg/ or ~/.cache/yay/)
yay -U ~/.cache/yay/quickshell-git/<previous-version>.pkg.tar.zst
```

### Reloading Configs Without Rebooting

| Component | Reload command |
|---|---|
| Hyprland config | `hyprctl reload` or `Super + Shift + R` |
| Quickshell | `quickshell --reload` or `Super + Shift + Q` |
| Swaync | `swaync-client --reload-config` |
| Kitty colors | `kitty @ set-colors --all ~/.config/kitty/matugen-colors.conf` |
| GRUB | `sudo grub-mkconfig -o /boot/grub/grub.cfg` (then re-sign) |

---

## Dotfiles and Chezmoi

### The Habit to Build

Any time you change a config file — whether manually or via the settings GUI — commit it to Chezmoi:

```bash
chezmoi add ~/.config/hypr/
chezmoi git -- commit -m "tweak: adjust gaps and blur passes"
chezmoi git -- push
```

The settings panel in Quickshell has a reminder banner at the bottom for this.

### Viewing What Has Changed Since Last Commit

```bash
chezmoi diff
```

This shows a diff between your current config files and what Chezmoi has tracked. Anything shown here is uncommitted.

### Applying Chezmoi on a New Machine

After a fresh Arch install (following `installation_plan.md`), restore all your dotfiles:

```bash
chezmoi init --apply https://github.com/YOUR_GITHUB_USERNAME/dotfiles.git
```

This pulls your repo and applies every tracked config file to the correct location.

### Secrets (GitHub Token)

`~/.config/quickshell/secrets.env` is gitignored and never committed. On a new machine, recreate it manually:

```bash
cat > ~/.config/quickshell/secrets.env << 'EOF'
GITHUB_TOKEN=your_token_here
EOF
```

Store the token value in a password manager — don't rely on being able to retrieve it from anywhere else.

### Rotating the GitHub Personal Access Token

The token in `secrets.env` is used by the right sidebar for the contribution heatmap and repo data. Rotate it every 90 days or per your token's expiry setting:

1. Go to GitHub → Settings → Developer Settings → Personal access tokens
2. Generate a new token with the same scopes (`read:user`, `repo`)
3. Update the file:
```bash
vim ~/.config/quickshell/secrets.env
```
4. Reload Quickshell: `Super + Shift + Q`

The old token can be deleted from GitHub immediately after replacing it.

---

## Storage Management

### Root Partition (50GB SSD)

Root is the most constrained partition. Check it regularly:

```bash
df -h /
```

**What takes space on root:**
- `/var/cache/pacman/pkg/` — package cache (managed by paccache.timer)
- `/var/log/` — systemd journal logs
- `/var/lib/` — application state (databases, etc.)
- `/usr/` — installed packages

**Checking the biggest consumers:**
```bash
sudo du -sh /var/cache/pacman/pkg/
sudo du -sh /var/log/journal/
sudo du -sh /var/lib/
```

**Trimming journal logs if they're large:**
```bash
# Keep only the last 2 weeks of logs
sudo journalctl --vacuum-time=2weeks

# Or cap journal size to 500MB
sudo journalctl --vacuum-size=500M
```

To prevent journal from growing unbounded, set a permanent cap in `/etc/systemd/journald.conf`:
```ini
[Journal]
SystemMaxUse=500M
```

Then restart journald:
```bash
sudo systemctl restart systemd-journald
```

### Home Partition (627GB HDD)

Home is large but Docker can fill it silently. Check it:

```bash
df -h /home
```

**Docker cleanup:**
```bash
# Show what Docker is using
docker system df

# Remove stopped containers, unused networks, dangling images
docker system prune

# Also remove unused images (not just dangling)
docker system prune -a

# Remove unused volumes (careful — this deletes data)
docker volume prune
```

**Finding large files in home generally:**
```bash
du -sh ~/*/  # top-level directories
du -sh ~/.cache/  # cache can grow large
```

The `.cache/` directory is safe to clear aggressively — apps rebuild it on demand:
```bash
du -sh ~/.cache/
# Clear specific caches, e.g. thumbnails
rm -rf ~/.cache/thumbnails/
```

### SSD Health

The NVMe SSD benefits from periodic TRIM. Enable the weekly TRIM timer if it isn't already:

```bash
sudo systemctl enable --now fstrim.timer
sudo systemctl status fstrim.timer
```

Check SSD health occasionally with `smartctl`:
```bash
sudo pacman -S smartmontools   # install if not present
sudo smartctl -a /dev/nvme0n1
```

Look for: `Critical Warning` (should be `0x00`), `Percentage Used` (should be low), `Available Spare` (should be above threshold).

---

## GRUB Maintenance

### After GRUB Updates

When GRUB is updated by pacman:
1. The pacman hook copies the new `grubx64.efi` to the fallback path automatically (if set up)
2. Re-sign with sbctl (see Secure Boot section)
3. The GRUB config does not need to be regenerated unless you changed kernel parameters

### If Windows Disappears from GRUB

This sometimes happens after Windows updates. Fix:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Check the output for `Found Windows Boot Manager`. If it's not found:
```bash
# Run os-prober manually to diagnose
sudo os-prober

# If os-prober returns nothing, check that ntfs-3g is installed
sudo pacman -S ntfs-3g
sudo os-prober
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Adding Kernel Parameters Later

Edit `/etc/default/grub`, modify `GRUB_CMDLINE_LINUX_DEFAULT`, then regenerate and re-sign:
```bash
sudo vim /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo sbctl sign -s /efi/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /boot/vmlinuz-linux
```

---

## asusctl and Fan Control

### Checking Current Profile

```bash
asusctl profile --list
asusctl -p   # shows currently active profile
```

### Switching Profiles

```bash
asusctl profile -P Silent
asusctl profile -P Balanced
asusctl profile -P Performance
```

The Quickshell bar battery pill dropdown and left sidebar quick settings do this on click — you shouldn't need to use the terminal for this normally.

### If asusctl Stops Working After an Update

```bash
sudo systemctl restart asusd
journalctl -u asusd -n 50
```

If `asusd` fails to start, check if the `asus_wmi` kernel module is still loaded:
```bash
lsmod | grep asus_wmi
modinfo asus_wmi
```

### Fan Curve Tuning

Fan curves can be adjusted per profile via `asusctl` or the ROG GUI:
```bash
yay -S asusctl-rog-gui   # graphical interface if not already installed
asusctl-rog-gui
```

Or via CLI to view/edit:
```bash
asusctl fan-curve -m Balanced    # view current Balanced fan curve
asusctl fan-curve -e true        # enable custom fan curves
```

---

## Bluetooth and Wi-Fi

### If Bluetooth Stops Working After an Update

```bash
sudo systemctl restart bluetooth
bluetoothctl
# Inside bluetoothctl:
power on
scan on
```

### Pairing a New Device

```bash
bluetoothctl
power on
scan on
# wait for device to appear
pair <MAC>
connect <MAC>
trust <MAC>   # auto-connect on future boots
```

Or use Blueman GUI (`Super + Space` → search Blueman) — easier for one-off pairing.

### If nmcli Stops Seeing Wi-Fi Networks

```bash
nmcli device status
sudo systemctl restart NetworkManager
```

If the interface is hard-blocked:
```bash
rfkill list
rfkill unblock wifi
```

---

## Wallpaper and matugen

### If Dynamic Colors Stop Updating After Wallpaper Change

The wallpaper-change script calls matugen, which regenerates `~/.config/matugen/colors.sh` and `~/.config/hypr/colors.conf`. If accent colors stay stuck at Lavender:

```bash
# Check if the color files exist and have real values
cat ~/.config/matugen/colors.sh
cat ~/.config/hypr/colors.conf

# Run matugen manually against the current wallpaper
cat ~/.cache/current_wallpaper   # check what wallpaper is active
matugen image $(cat ~/.cache/current_wallpaper)

# Then reload Hyprland and Quickshell
hyprctl reload
quickshell --reload
```

### If the Wallpaper Doesn't Persist After Login

The `autostart.conf` entry calls `wallpaper-change.sh ~/.cache/current_wallpaper` on login. If this fails silently:

```bash
cat ~/.cache/current_wallpaper   # should contain a valid path
ls -la $(cat ~/.cache/current_wallpaper)   # the file should exist

# Run the script manually to see errors
~/.config/hypr/scripts/wallpaper-change.sh ~/.cache/current_wallpaper
```

---

## Hyprlock and Hypridle

### Changing Lock/Idle Timeouts

Edit `~/.config/hypr/hypridle.conf`:
```bash
vim ~/.config/hypr/hypridle.conf
```

Current timeouts (from setup plan): 5 minutes to lock, 10 minutes to turn off display. Adjust the `timeout` values (in seconds) to taste.

Reload hypridle after changes:
```bash
pkill hypridle && hypridle &
```

### If the Lock Screen Looks Wrong

Hyprlock reads the current wallpaper from `~/.cache/current_wallpaper`. If the lock screen background is wrong or blank:
```bash
cat ~/.cache/current_wallpaper
ls -la $(cat ~/.cache/current_wallpaper)
```

The Quickshell settings panel (Hyprlock section) also lets you adjust clock format, font size, and input field appearance without touching config files.

---

## Logs and Diagnostics

### Common Log Locations

```bash
# Current boot errors only
journalctl -b -p err

# Hyprland session logs
journalctl --user -u hyprland

# Quickshell logs
journalctl --user -u quickshell

# SDDM (login screen) logs
journalctl -u sddm

# asusd (fan/power control) logs
journalctl -u asusd

# All logs from the current boot, live
journalctl -b -f
```

### Checking What Failed on Last Boot

```bash
systemctl --failed
journalctl -b -1 -p err   # errors from the previous boot
```

### Hyprland-Specific Diagnostics

```bash
# List all open windows and their properties
hyprctl clients

# Check active workspace
hyprctl activeworkspace

# Check monitor info
hyprctl monitors

# Check all keybinds as Hyprland sees them
hyprctl binds

# Reload config and print errors
hyprctl reload
```

---

## Kernel and Boot Issues

### Booting Into a Previous Kernel

If a kernel update breaks something, GRUB lets you boot an older kernel. At the GRUB menu, select `Advanced options for Arch Linux` → choose the previous kernel entry.

To keep an older kernel installed as a permanent fallback:
```bash
sudo pacman -S linux-lts linux-lts-headers
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo sbctl sign -s /boot/vmlinuz-linux-lts
```

This adds a second `linux-lts` entry to GRUB. Switch to it if the standard kernel breaks.

### Kernel Parameter Changes

If you need to add or test a kernel parameter temporarily (without saving it):

1. At the GRUB menu, press `e` on the Arch entry
2. Find the `linux` line
3. Add the parameter at the end (before the closing `quiet`)
4. Press `Ctrl+X` to boot with that parameter

If it fixes the issue, make it permanent in `/etc/default/grub` and regenerate GRUB config.

---

## Development Environment Maintenance

### Node.js (fnm)

```bash
# List installed Node versions
fnm list

# Install a new version
fnm install 22   # or whatever LTS is current

# Set default
fnm default 22

# Use in current shell
fnm use 22
```

### Python (pyenv)

```bash
# List installed Python versions
pyenv versions

# Install a new version
pyenv install 3.13.0

# Set global default
pyenv global 3.13.0

# Set local (per-project)
pyenv local 3.11.0
```

### Updating Development Tools

Most dev tools are installed via pacman or yay and update with the normal `yay` cycle. Tools installed via their own installers (starship, fnm, pyenv) need manual update:

```bash
# Starship
curl -sS https://starship.rs/install.sh | sh

# fnm — reinstall to update
curl -fsSL https://fnm.vercel.app/install | bash

# pyenv — it's a git repo
cd ~/.pyenv && git pull
```

### Zinit Plugin Updates

```bash
# Inside zsh
zinit update --all
```

---

## Hardware-Specific Checks

### Battery Health

Check battery capacity degradation over time:
```bash
cat /sys/class/power_supply/BAT0/charge_full
cat /sys/class/power_supply/BAT0/charge_full_design
```

`charge_full / charge_full_design * 100` gives you battery health percentage. Under ~80% is worth noting but not urgent for a development machine that's usually plugged in.

`asusctl` can set a battery charge limit (good for longevity when always plugged in):
```bash
asusctl -c 80   # charge to 80% max
asusctl -c 100  # remove limit
```

### Thermal Check

```bash
# CPU temperatures
sensors   # requires lm_sensors: sudo pacman -S lm_sensors && sudo sensors-detect

# GPU temperature (NVIDIA)
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader

# AMD iGPU (via radeontop or sensors)
radeontop -d -
```

Under normal dev workload on the FX505DT: CPU should stay under ~80°C, GPU under ~75°C. Sustained thermals above that suggest the fan curves may need adjustment in asusctl.

### Checking RAM Usage

```bash
free -h
# Or in btop — more readable
btop
```

With 8GB RAM, keep an eye on usage if running Docker containers and a browser simultaneously. The FX505DT supports RAM upgrades to 16GB (two SO-DIMM slots) if it becomes a bottleneck.

---

## Recovery Checklist

If a system update leaves things broken and you need to recover quickly:

1. Boot from Arch USB if the system won't boot at all
2. Mount and chroot (see Recovery Reference in `installation_plan.md`)
3. From inside chroot, diagnose and fix:

```bash
# Downgrade a specific package to last cached version
pacman -U /var/cache/pacman/pkg/<package-old-version>.pkg.tar.zst

# Rebuild initramfs
mkinitcpio -P

# Regenerate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

# Re-sign for Secure Boot
sbctl sign -s /efi/EFI/GRUB/grubx64.efi
sbctl sign -s /boot/vmlinuz-linux
```

If the system boots but Hyprland/desktop is broken, you can work from a TTY:
- `Ctrl+Alt+F2` to switch to TTY2
- Log in as simone
- Edit config files, check logs, fix and retry

---

## Routine Maintenance Checklist (Monthly)

Run through this once a month. Takes about 10 minutes.

```bash
# 1. Update everything
yay

# 2. Check root partition usage
df -h /

# 3. Check home partition usage
df -h /home

# 4. Review orphaned packages
pacman -Qtdq

# 5. Check Docker disk usage
docker system df

# 6. Check SSD health
sudo smartctl -a /dev/nvme0n1 | grep -E "Critical|Percentage|Spare"

# 7. Verify Secure Boot signatures still valid
sudo sbctl verify

# 8. Check for failed systemd units
systemctl --failed

# 9. Check journal size
du -sh /var/log/journal/

# 10. Verify Chezmoi is up to date
chezmoi diff   # should show nothing if you've been committing
```