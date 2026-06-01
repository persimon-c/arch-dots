# Arch Linux Manual Installation Guide
**Hardware:** ASUS TUF Gaming FX505DT — AMD Ryzen 5 3550H + NVIDIA GTX 1650  
**Setup:** Dual boot alongside Windows 11, UEFI, no Secure Boot during install

---

## Before You Boot the USB

These must be done in Windows before anything else.

**Create the bootable USB (do this first):**
- Download the Arch ISO from https://archlinux.org/download
- Flash it with rufus, GPT (if UEFI bios), DD mode
- Minimum USB size: 1GB, but 4GB+ recommended
- Download a few wallpapers in Brave before starting Phase 6 — at least one must be in `~/wallpapers/` before the phase begins

**Verify Windows state before touching disk:**
- Confirm BitLocker is OFF on both C: and D: — check in Control Panel → BitLocker Drive Encryption. BitLocker-encrypted partitions can prevent shrinking.
- Check/update BIOS version now while in Windows — easier here than from Arch later. Check the ASUS support page for FX505DT.

**In Windows (run PowerShell as Administrator):**
```powershell
# Disable hypervisor (required — conflicts with Linux boot)
bcdedit /set hypervisorlaunchtype off

# Disable hibernation (required — leaves NTFS dirty, Linux refuses to mount it)
powercfg /hibernate off
```

**Disable Fast Startup** (separate from hibernation — also leaves NTFS partitions dirty):
Control Panel → Power Options → Choose what the power buttons do → Turn on fast startup → **uncheck it**

> **Note — Fast Startup checkbox missing:** If the checkbox does not appear, hibernation is already fully off and Fast Startup is already disabled. This is expected.

**Back up C:\Users to D: before touching any partitions:**

Run in PowerShell as Administrator:
```powershell
robocopy C:\Users D:\Backup\Users /E /COPYALL /R:3 /W:5 /LOG:D:\Backup\robocopy_log.txt
```

After it finishes, verify the backup:
```powershell
robocopy C:\Users D:\Backup\Users /E /L
```

The `/L` flag does a dry run and lists anything missing or different without copying. Skipped locked files during the backup are normal — those are active session files that are not useful in a backup anyway. Check `D:\Backup\robocopy_log.txt` to review what was skipped.

**In Disk Management — HDD only:**
1. ~~Shrink C: (SSD) — this is now done from the Arch live environment (see Step 4)~~
2. Shrink D: (HDD) by 641024MB → creates ~627GB unallocated for home + swap

**In BIOS (F2 on boot):**
- Secure Boot → Disabled
- Fast Boot → Disabled
- SVM Mode → Leave enabled
- Boot order → USB first

---

## Step 1 — Boot the Live Environment

Boot from the Arch USB. You'll land at a root shell (`root@archiso`).

**Verify UEFI mode:**
```bash
ls /sys/firmware/efi/efivars
```
If the directory exists and has files, you're in UEFI mode. If it's empty or missing, you booted in legacy BIOS — go back to BIOS and fix the boot mode.

**Set font (optional, easier to read):**
```bash
setfont ter-132b
```

---

## Step 2 — Connect to the Internet

**Check if you already have a connection (ethernet):**
```bash
ping -c 3 archlinux.org
```

**If using Wi-Fi:**
```bash
iwctl
# Inside iwctl:
device list                        # find your device name (usually wlan0)
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "NetworkName"
exit
```

Then verify:
```bash
ping -c 3 archlinux.org
```

> **Error — no network interface listed in `iwctl`:**  
> The FX505DT uses a Realtek Wi-Fi chip. It is supported in the live ISO kernel, but if the device doesn't appear, try `rfkill unblock all` first.

---

## Step 3 — Update System Clock

```bash
timedatectl set-ntp true
timedatectl status   # verify it says "NTP service: active"
```

---

## Step 4 — Partition the Disks

**Identify your disks first:**
```bash
fdisk -l
```

You should see:
- `nvme0n1` — NVMe SSD (~238GB), contains Windows C:
- `sda` — HDD (~931GB), contains Windows D:

**Current partition layout on nvme0n1 (confirmed before install):**
```
nvme0n1p1   260MB    EFI System         — do not touch
nvme0n1p2   16MB     MSR Reserved       — do not touch
nvme0n1p3   237GB    Windows C: (NTFS)  — will be shrunk
nvme0n1p4   1.07GB   Recovery           — do not touch
```

The Windows C: partition occupies the entire SSD with no unallocated space. Shrinking it from Windows Disk Management is blocked by the recovery partition sitting at the end of the disk. The resize is done here from the live environment instead.

This requires two tools in sequence: `ntfsresize` shrinks the NTFS filesystem inside the partition first, then `parted` shrinks the partition boundary to match. **Do not run parted before ntfsresize — resizing the partition without shrinking the filesystem first will corrupt Windows.**

### Step 4a — Shrink the NTFS filesystem on nvme0n1p3

First, run a dry-run check to confirm ntfsresize sees the partition as safe to resize:
```bash
ntfsresize --no-action --size 187g /dev/nvme0n1p3
```

Expected output ends with: `Schedule chkdsk for NTFS consistency check at Windows boot time? This is STRONGLY RECOMMENDED! You can use the /f option of Windows' chkdsk command to check and fix the filesystem after the resize. Are you sure you want to proceed (y/[n])?`

If it instead reports errors or says the volume is inconsistent, **stop** — do not proceed. Boot back into Windows, run `chkdsk C: /f`, reboot, and try again.

If the dry run succeeds, run the actual resize:
```bash
ntfsresize --size 187g /dev/nvme0n1p3
```

Type `y` when prompted.

> **Why 187GB:** The SSD is 238GB. Subtracting 50GB for Arch root and ~1GB buffer leaves ~187GB for Windows C:. This gives Windows ample room — it currently uses ~123GB.

### Step 4b — Shrink the partition boundary on nvme0n1p3

Now shrink the partition itself to match the filesystem. Open parted:
```bash
parted /dev/nvme0n1
```

Inside parted:
```
(parted) unit MB
(parted) print
```

Note the start position of nvme0n1p3 (will be around 290MB after EFI + MSR). You need it for the next command.

Resize p3 to end at start + 187000MB:
```
(parted) resizepart 3 187290MB
```

> Replace `187290MB` with: the start of p3 (from `print`) + 187000. For example if p3 starts at 290MB, use 187290MB.

Confirm and quit:
```
(parted) quit
```

### Step 4c — Create the Arch root partition (nvme0n1p5)

The freed space now sits between nvme0n1p3 and nvme0n1p4 (recovery). Use cfdisk to create the new partition there:
```bash
cfdisk /dev/nvme0n1
```

Inside cfdisk:
- You'll see p1 (EFI), p2 (MSR), p3 (Windows C: shrunk), `Free space` (~50GB), p4 (Recovery)
- Arrow down to the `Free space` entry
- Select `[ New ]` → accept the default size (entire free space) → Enter
- Select `[ Write ]` → type `yes` to confirm
- Select `[ Quit ]`

This creates `nvme0n1p5`.

### Partition the HDD (sda) — swap + home

```bash
cfdisk /dev/sda
```

Inside cfdisk:
- You'll see sda1 (Windows D:) and a `Free space` entry of ~627GB
- Arrow down to `Free space`
- Select `[ New ]` → type `4G` → Enter → this is swap (sda2)
- Arrow down to the remaining `Free space`
- Select `[ New ]` → accept default size (all remaining space) → Enter → this is home (sda3)
- Arrow to sda2 → select `[ Type ]` → choose `Linux swap`
- Select `[ Write ]` → type `yes` to confirm
- Select `[ Quit ]`

**Verify the result:**
```bash
lsblk
```

Expected:
```
nvme0n1p1   260MB    (Windows EFI — existing)
nvme0n1p2   16MB     (Windows MSR — existing)
nvme0n1p3   ~187GB   (Windows C: — shrunk)
nvme0n1p4   1.07GB   (Windows Recovery — existing, do not touch)
nvme0n1p5   ~50GB    (Arch root — new)
sda1        305GB    (Windows D: — existing)
sda2        4GB      (swap — new)
sda3        ~627GB   (Arch home — new)
```

> **Error — partition table shows wrong sizes or overlaps:**  
> Select `[ Quit ]` without writing. Re-examine with `lsblk` and `fdisk -l /dev/nvme0n1`. If the free space between p3 and p4 is missing, the ntfsresize or parted step may not have committed correctly — recheck Step 4b.

---

## Step 5 — Format the Partitions

```bash
# Arch root
mkfs.ext4 /dev/nvme0n1p5

# Arch home
mkfs.ext4 /dev/sda3

# Swap
mkswap /dev/sda2

# DO NOT format nvme0n1p1 — that is the shared EFI partition with Windows
# DO NOT format nvme0n1p4 — that is the Windows Recovery partition
```

> **Error — `mkfs.ext4: invalid argument` or similar:**  
> Run `lsblk` to confirm the partition actually exists. If it doesn't, the cfdisk write step may not have committed — rerun cfdisk and make sure to select `[ Write ]` and confirm with `yes`.

---

## Step 6 — Mount the Partitions

```bash
mount /dev/nvme0n1p5 /mnt

mkdir -p /mnt/efi
mount /dev/nvme0n1p1 /mnt/efi

mkdir -p /mnt/home
mount /dev/sda3 /mnt/home

swapon /dev/sda2
```

**Verify mounts:**
```bash
lsblk
```
You should see `/mnt`, `/mnt/efi`, and `/mnt/home` as mount points.

> **Error — `mount: /mnt/efi: wrong fs type` or mount fails:**  
> The EFI partition should be FAT32. Verify with `blkid /dev/nvme0n1p1` — it should show `TYPE="vfat"`. If it's not mounting, check that you're targeting the right partition number.

---

## Step 7 — Install the Base System

**Update mirror list first (faster downloads from nearby servers):**
```bash
reflector --country Philippines --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
```

> If `reflector` fails or is slow, skip it — the defaults work fine.

**Install base packages:**
```bash
pacstrap -K /mnt base base-devel linux linux-headers linux-firmware amd-ucode sof-firmware vim
```

This takes a few minutes. It downloads and installs the core system.

> **Error — `error: failed to commit transaction (conflicting files)`:**  
> This is uncommon on a fresh pacstrap. If it happens, add `--overwrite '*'` to the command.

> **Error — `error: failed retrieving file` / download failures:**  
> Your internet connection dropped or mirror is bad. Re-run `reflector` with a different country or just re-run `pacstrap` — it resumes from where it left off.

---

## Step 8 — Generate fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

**Verify it looks correct:**
```bash
cat /mnt/etc/fstab
```

You should see entries for `/`, `/efi`, `/home`, and `swap`. Each should have a UUID, not a device name like `/dev/sda3`.

> **Error — fstab is empty or missing entries:**  
> Means a partition wasn't mounted when you ran genfstab. Go back to Step 6, re-mount anything missing, and re-run genfstab. If you re-run it, entries may duplicate — open `/mnt/etc/fstab` with a text editor and remove duplicates manually.

---

## Step 9 — Chroot into the New System

```bash
arch-chroot /mnt
```

Your prompt changes. You are now operating inside the installed system, not the live ISO.

---

## Step 10 — Time Zone and Locale

```bash
# Set timezone
ln -sf /usr/share/zoneinfo/Asia/Manila /etc/localtime
hwclock --systohc
```

**Set locale:**
```bash
# Edit /etc/locale.gen and uncomment: en_US.UTF-8 UTF-8
vim /etc/locale.gen
# Find the line, remove the leading #, save and quit with :wq

locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

---

## Step 11 — Hostname and Hosts

```bash
echo "persmon" > /etc/hostname
```

```bash
vim /etc/hosts
```

Add these lines:
```
127.0.0.1   localhost
::1         localhost
127.0.1.1   persmon.localdomain persmon
```

---

## Step 12 — Root Password

```bash
passwd
```

Set a strong root password. You'll need this to recover from mistakes.

---

## Step 13 — Install Essential Packages

```bash
pacman -S grub efibootmgr os-prober ntfs-3g networkmanager sudo git zsh curl
```

- `ntfs-3g` — required for os-prober to detect the Windows partition
- `networkmanager` — handles Wi-Fi and ethernet after reboot
- `efibootmgr` — required by GRUB for UEFI install
- `curl` — required for GitHub API calls in the right sidebar widget and general use

---

## Step 14 — Create Your User

```bash
useradd -m -G wheel -s /bin/zsh simone
passwd simone
```

**Enable sudo for the wheel group:**
```bash
EDITOR=vim visudo
```

Find and uncomment this line (remove the `#`):
```
%wheel ALL=(ALL:ALL) ALL
```

---

## Step 15 — Configure mkinitcpio

This is done now (before installing NVIDIA drivers) since NVIDIA modules must be in the initramfs.

**Edit `/etc/mkinitcpio.conf`:**
```bash
vim /etc/mkinitcpio.conf
```

Find the `MODULES=()` line and change it to:
```
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Do not rebuild yet — that happens after GRUB install.

---

## Step 16 — Install and Configure GRUB

```bash
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
```

> **Error — `EFI variables are not supported on this system`:**  
> You booted the USB in BIOS/legacy mode instead of UEFI. You cannot fix this from inside chroot — you need to reboot, enter BIOS, and ensure the USB is set to boot as UEFI.

**Enable os-prober in GRUB config:**
```bash
vim /etc/default/grub
```

Find and change or add these lines:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1 ibt=off"
GRUB_DISABLE_OS_PROBER=false
```

**Install fuse3 — required for os-prober to work:**

`grub-mount` (used internally by os-prober to probe partitions) depends on `libfuse3.so.3` at runtime, but `fuse3` is only an optional dependency of `grub` and won't be installed automatically. Without it, `grub-mount` silently fails and os-prober never detects Windows.

```bash
pacman -S fuse3
```

**Generate GRUB config:**
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

Check the output — you should see a line like:
```
Found Windows Boot Manager on /dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi
```

> **Error — Windows not found by os-prober:**  
> This is a known issue when running grub-mkconfig inside chroot while the USB is still plugged in. os-prober can confuse the USB drive for a Windows drive, or miss Windows entirely. The fix is:  
> 1. Finish the install, exit chroot, reboot into Arch  
> 2. With the USB removed, run `sudo grub-mkconfig -o /boot/grub/grub.cfg` again  
> 3. Windows should appear this time  
>  
> If it still doesn't appear after reboot, verify the EFI partition is mounted at `/efi` (`lsblk`) and run os-prober manually: `sudo os-prober`. If that returns nothing, install `ntfs-3g` and retry.

**Set GRUB fallback path (protects against Windows resetting boot order):**
```bash
cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/Boot/bootx64.efi
```

---

## Step 17 — Rebuild initramfs

```bash
mkinitcpio -P
```

Watch for errors. Warnings about missing firmware are usually harmless on this hardware. Actual errors (not warnings) must be resolved before rebooting.

---

## Step 18 — Enable NetworkManager

```bash
systemctl enable NetworkManager
```

Without this, you will have no internet after reboot.

---

## Step 19 — Exit and Reboot

```bash
exit          # exit chroot
umount -R /mnt
reboot
```

Remove the USB when the screen goes dark.

---

## Step 20 — First Boot

GRUB should appear. Select Arch Linux.

Log in as `simone` with the password you set.

**Verify internet:**
```bash
ping -c 3 archlinux.org
```

If no internet, start NetworkManager manually and connect:
```bash
sudo systemctl start NetworkManager
nmtui   # text UI for connecting to Wi-Fi
```

---

## Step 21 — Install yay (AUR Helper)

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
```

---

## Step 21b — Install AUR Essentials

Install AUR packages that are needed early or referenced by later steps.

```bash
yay -S matugen lazygit hyprpicker
```

- `matugen` — generates dynamic accent palettes from wallpaper images; needed by the wallpaper switcher
- `lazygit` — terminal Git UI used in the Zellij dev layout (`Super + Shift + Z`)
- `hyprpicker` — Wayland color picker; bound to `Super + C`

Verify each installed correctly:
```bash
matugen --version
lazygit --version
hyprpicker --version
```

---

## Step 22 — Install NVIDIA Drivers

```bash
sudo pacman -S nvidia-dkms nvidia-utils nvidia-settings
```

> **Why nvidia-dkms?** The DKMS variant rebuilds the kernel module automatically against any installed kernel. On Arch with a single kernel it makes no functional difference right now, but it's what the Hyprland wiki recommends and protects you if you ever add a second kernel.

> **egl-wayland:** This is a hard dependency of `nvidia-utils` and will be installed automatically — you do not need to install it separately.

**Enable NVIDIA power management services (required for suspend/resume on laptop):**
```bash
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service
```

> The Hyprland wiki notes these may already be enabled on Arch by the package install scripts. Run `systemctl status nvidia-suspend` to check — if it shows `enabled`, skip the manual enable.

**Add `NVreg_PreserveVideoMemoryAllocations=1` to GRUB kernel parameters:**

Open `/etc/default/grub` and add it to `GRUB_CMDLINE_LINUX_DEFAULT`:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1 ibt=off nvidia.NVreg_PreserveVideoMemoryAllocations=1"
```

Then regenerate:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Blacklist nouveau (open source NVIDIA driver — conflicts with proprietary):**
```bash
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
```

**Rebuild initramfs:**
```bash
sudo mkinitcpio -P
```

**Reboot:**
```bash
reboot
```

> **Error — black screen after NVIDIA driver install:**  
> This is the most common hardware-specific issue on the FX505DT. Recovery steps:  
> 1. At boot, switch to a TTY: `Ctrl+Alt+F2` (try F2 through F6)  
> 2. Log in as root or simone  
> 3. Check what failed: `journalctl -b -p err`  
> 4. Check if NVIDIA module loaded: `lsmod | grep nvidia`  
>  
> **If NVIDIA module failed to load:**  
> Edit GRUB at boot — press `e` on the Arch entry, find the `linux` line, add `nomodeset` temporarily at the end, press `Ctrl+X` to boot. Once in, verify `nvidia-drm.modeset=1` and `ibt=off` are in `/etc/default/grub` and re-run `grub-mkconfig`.  
>  
> **If the system boots but Hyprland won't start later:**  
> Check the AQ_DRM_DEVICES variable — `card1` may not be the AMD card. Run `ls -la /dev/dri/by-path/` and use the stable PCI path instead (see setup_plan.md GPU section).

> **Error — `nouveau` is still loading despite blacklist:**  
> Add `nouveau.modeset=0` to GRUB_CMDLINE_LINUX_DEFAULT in `/etc/default/grub` and re-run `grub-mkconfig`.

---

## Step 23 — Install asusctl and supergfxctl

These are in the asus-linux community repo — not in the main Arch repos.

```bash
yay -S asusctl supergfxctl
sudo systemctl enable --now asusd
sudo systemctl enable --now supergfxd
```

**Verify asusctl works:**
```bash
asusctl profile --list
```

You should see Silent, Balanced, Performance profiles.

> **Error — `asusd.service` fails to start:**  
> Check `journalctl -u asusd`. If it says the asus-wmi kernel module isn't loaded, your kernel may be missing it — run `modinfo asus_wmi` to check. This module is included in the standard Arch `linux` kernel package.

---

## Step 24 — Install Hyprland and Desktop Stack

```bash
sudo pacman -S hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
               tumbler \
               fzf zellij \
               pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
               pavucontrol bluez bluez-utils blueman ufw \
               brightnessctl radeontop docker \
               qt5-wayland qt6-wayland udiskie

yay -S sddm-git hyprlock hypridle awww rofi-wayland swaync \
       cliphist wl-clipboard \
       kitty yazi thunar grimblast quickshell-git \
       catppuccin-cursors-mocha hyprpolkitagent
```

- `brightnessctl` — required for brightness keybinds (`XF86MonBrightnessUp/Down`)
- `radeontop` — GPU usage monitor for the Quickshell stats panel; requires a udev rule for non-root access (configured in Step 29)
- `docker` — container runtime; data directory configured to `/home` in Step 27
- `grimblast` — screenshot tool used by all screenshot keybinds; wraps `grim` + `slurp` for Hyprland-aware region selection
- `quickshell-git` — bar and widget system; QML-based
- `catppuccin-cursors-mocha` — cursor theme set in `hyprland_settings.md`

**Enable services:**
```bash
sudo systemctl enable sddm
sudo systemctl enable bluetooth
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo systemctl enable ufw
```

**Enable PipeWire as a user service (required for audio to work after login):**
```bash
systemctl --user enable pipewire pipewire-pulse wireplumber
```

---

## Step 25 — Install Fonts

```bash
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk
```

---

## Step 26 — Configure Hyprland (Full Split Config)

This step creates the full Hyprland config using the split file structure from `setup_plan.md` and the decided values from `hyprland_settings.md`. Do not leave the minimal placeholder config in place — replace it entirely now.

**Create the config directory:**
```bash
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/Pictures/screenshots
```

**Find the stable AMD GPU path first:**
```bash
ls -la /dev/dri/by-path/
```

Look for the `pci-*` entry pointing to the AMD iGPU (typically the lower PCI bus number). Copy the full path — you'll need it in `env.conf` below.

---

### `~/.config/hypr/hyprland.conf` (entry point)

```bash
cat > ~/.config/hypr/hyprland.conf << 'EOF'
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
EOF
```

---

### `~/.config/hypr/env.conf`

Replace `<your-amd-pci-path-here>` with the full path you found with `ls -la /dev/dri/by-path/`.

```bash
cat > ~/.config/hypr/env.conf << 'EOF'
# GPU — AMD iGPU as primary display; use stable PCI path, not /dev/dri/card1
# AQ_DRM_DEVICES is the correct variable for current Hyprland (Aquamarine backend, post-0.41).
# WLR_DRM_DEVICES is the legacy wlroots variable — no longer used.
env = AQ_DRM_DEVICES,/dev/dri/by-path/<your-amd-pci-path-here>
env = LIBVA_DRIVER_NAME,radeonsi
env = WLR_NO_HARDWARE_CURSORS,1

# NVIDIA PRIME offload — prefix any app with these to run it on the NVIDIA dGPU
env = __NV_PRIME_RENDER_OFFLOAD,1
env = __NV_PRIME_RENDER_OFFLOAD_PROVIDER,NVIDIA-G0
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = __VK_LAYER_NV_optimus,NVIDIA_only

# Wayland session
env = WAYLAND_DISPLAY,wayland-0
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = XDG_CURRENT_DESKTOP,Hyprland

# Qt Wayland
env = QT_QPA_PLATFORM,wayland
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

# GTK / SDL
env = GDK_BACKEND,wayland,x11
env = SDL_VIDEODRIVER,wayland

# Cursor
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,Catppuccin-Mocha-Dark
EOF
```

---

### `~/.config/hypr/colors.conf`

This file is generated and overwritten by matugen on each wallpaper change. Create it now with Lavender as the fallback accent so Hyprland has valid colors before the first wallpaper is processed.

```bash
cat > ~/.config/hypr/colors.conf << 'EOF'
# Generated by matugen on wallpaper change.
# Fallback: Catppuccin Mocha Lavender accent + Flamingo secondary.
# Do not edit manually — changes will be overwritten on next wallpaper change.

$accent    = rgb(b4befe)
$accentAlt = rgb(f2cdcd)
$inactive  = rgb(45475a)
EOF
```

---

### `~/.config/hypr/monitor.conf`

```bash
cat > ~/.config/hypr/monitor.conf << 'EOF'
# 1920x1080 @ 60Hz, single monitor, no scaling
monitor = , 1920x1080@60, 0x0, 1
EOF
```

---

### `~/.config/hypr/input.conf`

```bash
cat > ~/.config/hypr/input.conf << 'EOF'
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1
    mouse_refocus = true

    sensitivity = 0
    accel_profile = flat

    touchpad {
        natural_scroll = true
        tap-to-click = true
        tap-to-drag = true
        drag_lock = false
        disable_while_typing = true
        scroll_factor = 1.0
        clickfinger_behavior = false
    }
}

gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
    workspace_swipe_invert = true
    workspace_swipe_min_speed_to_force = 30
    workspace_swipe_cancel_ratio = 0.5
    workspace_swipe_create_new = false
}
EOF
```

---

### `~/.config/hypr/decoration.conf`

```bash
cat > ~/.config/hypr/decoration.conf << 'EOF'
decoration {
    rounding = 12

    active_opacity = 0.92
    inactive_opacity = 0.80
    fullscreen_opacity = 1.0

    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = true
        xray = false
        ignore_opacity = false
    }

    drop_shadow = true
    shadow_range = 12
    shadow_render_power = 2
    shadow_offset = 2 4
    col.shadow = rgba(11111b99)
    col.shadow_inactive = rgba(11111b55)
}
EOF
```

---

### `~/.config/hypr/animations.conf`

```bash
cat > ~/.config/hypr/animations.conf << 'EOF'
animations {
    enabled = true

    bezier = floaty, 0.05, 0.9, 0.1, 1.05
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    bezier = smoothIn, 0.25, 1, 0.5, 1

    animation = windows, 1, 5, smoothIn, fade
    animation = windowsOut, 1, 5, smoothOut, fade
    animation = windowsMove, 1, 4, floaty
    animation = workspaces, 1, 6, floaty, slide
    animation = fadeIn, 1, 5, smoothIn
    animation = fadeOut, 1, 5, smoothOut
    animation = border, 1, 8, default
    animation = borderangle, 1, 30, default, loop
}
EOF
```

---

### `~/.config/hypr/layout.conf`

```bash
cat > ~/.config/hypr/layout.conf << 'EOF'
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    layout = dwindle

    col.active_border = rgba(b4befeff) rgba(f2cdcdff) 45deg
    col.inactive_border = rgba(45475aaa)

    resize_on_border = true
    extend_border_grab_area = 10
}

dwindle {
    pseudotile = true
    preserve_split = true
    smart_split = false
    smart_resizing = true
}

binds {
    allow_workspace_cycles = true
    workspace_back_and_forth = true
}

misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    mouse_move_enables_dpms = true
    key_press_enables_dpms = true
    animate_manual_resizes = true
    animate_mouse_windowdrag = true
    enable_swallow = true
    swallow_regex = ^(kitty)$
    focus_on_activate = false
    vfr = true
    vrr = 0
}
EOF
```

---

### `~/.config/hypr/windowrules.conf`

```bash
cat > ~/.config/hypr/windowrules.conf << 'EOF'
# Floating windows
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = center, class:^(pavucontrol)$
windowrulev2 = float, class:^(blueman-manager)$
windowrulev2 = center, class:^(blueman-manager)$
windowrulev2 = float, class:^(thunar)$, title:^(File Operation)
windowrulev2 = float, class:^(org.gnome.Calculator)$
windowrulev2 = center, class:^(org.gnome.Calculator)$

# Workspace assignments
windowrulev2 = workspace 2, class:^(brave-browser)$
windowrulev2 = workspace 4, class:^(discord)$
EOF
```

---

### `~/.config/hypr/keybinds.conf`

```bash
cat > ~/.config/hypr/keybinds.conf << 'EOF'
$mod = SUPER

# --- Window Management ---
bind = $mod, Q, killactive
bind = $mod, F, fullscreen
bind = $mod SHIFT, F, togglefloating
bind = $mod, P, pseudo

bind = $mod, Up, movefocus, u
bind = $mod, Down, movefocus, d
bind = $mod, Left, movefocus, l
bind = $mod, Right, movefocus, r

bind = $mod SHIFT, Up, movewindow, u
bind = $mod SHIFT, Down, movewindow, d
bind = $mod SHIFT, Left, movewindow, l
bind = $mod SHIFT, Right, movewindow, r

binde = $mod CTRL, Up, resizeactive, 0 -20
binde = $mod CTRL, Down, resizeactive, 0 20
binde = $mod CTRL, Left, resizeactive, -20 0
binde = $mod CTRL, Right, resizeactive, 20 0

bind = $mod, Tab, cyclenext
bind = $mod SHIFT, Tab, cyclenext, prev
bind = ALT, Tab, cyclenext
bind = ALT SHIFT, Tab, cyclenext, prev

# --- Applications ---
bind = $mod, Return, exec, kitty
bind = $mod, Space, exec, rofi -show drun
bind = $mod, B, exec, brave
bind = $mod, A, exec, antigravity
bind = $mod, S, exec, subl
bind = $mod, T, exec, thunar
bind = $mod, D, exec, discord
bind = $mod, V, exec, code
bind = $mod SHIFT, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy
bind = $mod, W, exec, ~/.config/rofi/wallpaper-picker.sh
bind = $mod, N, exec, swaync-client -t
bind = $mod, G, exec, quickshell ipc call toggleRightSidebar
bind = $mod, E, exec, kitty -e yazi
bind = $mod, Z, exec, zellij
bind = $mod SHIFT, Z, exec, zellij --layout ~/.config/zellij/layouts/dev-layout.kdl
bind = $mod, C, exec, hyprpicker -a && notify-send "Color picked" "$(wl-paste)"

# --- Workspaces ---
bind = $mod, 1, workspace, 1
bind = $mod, 2, workspace, 2
bind = $mod, 3, workspace, 3
bind = $mod, 4, workspace, 4
bind = $mod, 5, workspace, 5
bind = $mod, 6, workspace, 6
bind = $mod, 7, workspace, 7
bind = $mod, 8, workspace, 8
bind = $mod, 9, workspace, 9

bind = $mod SHIFT, 1, movetoworkspace, 1
bind = $mod SHIFT, 2, movetoworkspace, 2
bind = $mod SHIFT, 3, movetoworkspace, 3
bind = $mod SHIFT, 4, movetoworkspace, 4
bind = $mod SHIFT, 5, movetoworkspace, 5
bind = $mod SHIFT, 6, movetoworkspace, 6
bind = $mod SHIFT, 7, movetoworkspace, 7
bind = $mod SHIFT, 8, movetoworkspace, 8
bind = $mod SHIFT, 9, movetoworkspace, 9

bind = $mod, mouse_up, workspace, e+1
bind = $mod, mouse_down, workspace, e-1

# --- Screenshots ---
bind = , Print, exec, grimblast save screen ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png
bind = $mod, Print, exec, grimblast save area ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png

# Screenshot submap
bind = $mod SHIFT, Print, submap, screenshot

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

# --- Media and Audio ---
binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous
bind = , XF86AudioStop, exec, playerctl stop

# --- Brightness ---
binde = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# --- System ---
bind = $mod, L, exec, hyprlock
bind = $mod SHIFT, R, exec, hyprctl reload
bind = $mod SHIFT, Q, exec, quickshell --reload
bind = $mod SHIFT, C, exec, quickshell ipc call toggleSettings

# System submap
bind = $mod SHIFT, S, submap, system

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

# Resize submap
bind = $mod, R, submap, resize

submap = resize
binde = , right, resizeactive, 20 0
binde = , left, resizeactive, -20 0
binde = , down, resizeactive, 0 20
binde = , up, resizeactive, 0 -20
bind = , escape, submap, reset
submap = reset
EOF
```

---

### `~/.config/hypr/autostart.conf`

```bash
cat > ~/.config/hypr/autostart.conf << 'EOF'
exec-once = awww-daemon
exec-once = bash -c '[ -f ~/.cache/current_wallpaper ] && ~/.config/hypr/scripts/wallpaper-change.sh "$(cat ~/.cache/current_wallpaper)"'
exec-once = quickshell
exec-once = hypridle
exec-once = swaync
exec-once = udiskie --tray
exec-once = systemctl --user start hyprpolkitagent
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
EOF
```

**Test the config before doing anything else:**
```bash
Hyprland
```

If Hyprland starts and renders correctly, exit and continue. If it fails, check `journalctl --user -xe` for errors.

---

## Step 27 — Storage Management (Keep Root Healthy)

Your root partition is only 50GB. Two things must be done to prevent it from filling up.

**1. Enable automatic pacman cache cleanup:**

The pacman cache lives on root at `/var/cache/pacman/pkg/` and grows unbounded by default. Enable the weekly cleanup timer that ships with pacman:

```bash
sudo systemctl enable --now paccache.timer
```

This automatically keeps only the 3 most recent versions of each package and removes the rest, weekly.

**2. Configure Docker data root to /home:**

Docker was installed in Step 24. Before pulling any images, move its data root to your 627GB home partition so images, containers, and volumes don't land on the 50GB root.

```bash
sudo mkdir -p /home/docker-data
```

Create the Docker daemon config:
```bash
sudo vim /etc/docker/daemon.json
```

Add:
```json
{
  "data-root": "/home/docker-data"
}
```

Then enable and start Docker:
```bash
sudo systemctl enable --now docker
sudo usermod -aG docker simone
```

Log out and back in for the group change to take effect, then verify:
```bash
docker info | grep "Docker Root Dir"
# Should show: Docker Root Dir: /home/docker-data
```

> **Note — do this before pulling any Docker images.** If you pull images before moving the data root, they land on root. Moving after the fact requires migrating existing data manually.

---

## Step 28 — zsh Setup

Configure zsh with Zinit plugin manager, plugins, starship prompt, and fzf keybindings.

**Install Zinit:**
```bash
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

**Install starship prompt:**
```bash
curl -sS https://starship.rs/install.sh | sh
```

**Install onefetch (used in the chpwd hook below):**
```bash
yay -S onefetch
```

**Configure `~/.zshrc`:**
```bash
cat > ~/.zshrc << 'EOF'
# Zinit
source ~/.local/share/zinit/zinit.git/zinit.zsh

# Plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# fzf keybindings — Ctrl+R for fuzzy history, Ctrl+T for fuzzy file search
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Starship prompt
eval "$(starship init zsh)"

# onefetch on cd into git repos (skips large repos)
function chpwd() {
    if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
        local obj_count=$(git count-objects | awk '{print $1}')
        if [[ $obj_count -lt 10000 ]]; then
            onefetch
        fi
    fi
}

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
EOF
```

Reload zsh:
```bash
source ~/.zshrc
```

---

## Step 29 — radeontop udev Rule

`radeontop` (installed in Step 24) requires a udev rule for non-root access. Without this, the GPU gauge in the Quickshell stats panel will silently show nothing.

```bash
echo 'SUBSYSTEM=="drm", ACTION=="add", GROUP="video", MODE="0660"' | sudo tee /etc/udev/rules.d/99-drm.rules
sudo udevadm control --reload
sudo udevadm trigger
sudo usermod -aG video simone
```

Log out and back in for the group change to take effect. Verify:
```bash
radeontop -d -
```

You should see GPU load data without sudo.

---

## Step 30 — Wallpaper Directory

```bash
mkdir -p ~/wallpapers
```

Add your wallpapers here before running the wallpaper switcher. Subdirectories are fine (e.g. `~/wallpapers/day/`, `~/wallpapers/night/`). The wallpaper switcher script (`Super + W`) scans this directory.

---

## Step 31 — Chezmoi Initialization

Chezmoi is initialized in **Phase 11 of `build_order.md`**, after all configs from Phases 3–10 are stable. Do not initialize it here — your configs are not finalized yet at this point in the install.

Continue to Step 32.

---

## Step 32 — Post-Install: Secure Boot Signing (After Everything Works)

Do this only after confirming Arch boots correctly and all hardware works.

```bash
sudo pacman -S sbctl

sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft

sudo sbctl sign -s /efi/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /boot/vmlinuz-linux

sudo sbctl verify   # all files should show as signed
```

Then re-enable Secure Boot in BIOS. Both Windows and Arch will boot normally.

> **Error — `sbctl enroll-keys` fails or BIOS rejects keys:**  
> Some ASUS BIOS versions have a quirk where they require keys to be enrolled via the BIOS firmware interface, not from the OS. If sbctl fails at enroll, enter BIOS → Secure Boot → Key Management and manually import the keys sbctl generated in `/usr/share/secureboot/keys/`.

---

## Known Issues on FX505DT

| Issue | Symptom | Fix |
|---|---|---|
| Black screen after NVIDIA install | No display after reboot | See Step 22 error section |
| Windows missing from GRUB | Only Arch in boot menu | Reboot without USB, re-run grub-mkconfig |
| matugen colors not loading | Accent stays at Lavender fallback | Run `matugen image ~/wallpapers/yourwallpaper.jpg` manually to generate ~/.config/matugen/colors.sh |
| radeontop permission denied | GPU gauge shows nothing in Quickshell | See Step 29 — udev rule + video group |
| fzf keybinds not working in zsh | Ctrl+R still uses default history | Verify `source /usr/share/fzf/key-bindings.zsh` is in .zshrc |
| `card1` not stable | Hyprland fails to start with wrong GPU | Use `/dev/dri/by-path/` path instead — see Step 26 |
| Unplugged battery causes black screen | Screen goes dark when charger removed | Add `iommu=pt` to GRUB kernel parameters |
| asusd won't start | Fan control unavailable | Check `modinfo asus_wmi`, verify kernel module is present |
| Nouveau conflicts with NVIDIA | Intermittent crashes or boot failures | Blacklist nouveau + add `nouveau.modeset=0` kernel param |
| os-prober misses Windows in chroot | Windows not in GRUB menu on first install | Normal — re-run grub-mkconfig after first reboot without USB; also verify fuse3 is installed |
| GRUB overwritten by Windows Update | System boots straight to Windows | GRUB fallback path (Step 16) prevents this |

---

## Recovery Reference

If a reboot results in a broken system, boot from the Arch USB and:

```bash
# Mount your installed system
mount /dev/nvme0n1p5 /mnt
mount /dev/nvme0n1p1 /mnt/efi
mount /dev/sda3 /mnt/home
swapon /dev/sda2

# Chroot back in
arch-chroot /mnt

# From here you can fix configs, reinstall packages, regenerate GRUB, etc.
```

This is your recovery path for almost any post-install problem.







----------------------------------------------------------------------------


POST INSTALLATION FIXES MADE:

# Installation Plan — Patch Document

Corrections and additions based on the Step 32 (Secure Boot) session.

---

## Step 4 — Partition Resize: Boot Windows After Resizing

**Addition to Step 4c**, after creating nvme0n1p5:

After completing the partition resize (ntfsresize + parted), boot into Windows **before** proceeding with Arch installation. Windows will run a consistency check on the NTFS filesystem on the first boot. Let it complete.

If you skip this step, the NTFS boot sector may retain an incorrect sector count from the resize, causing Windows to show "Unmountable Boot Volume" later.

> **If Windows shows "Unmountable Boot Volume" after the fact:**
> Boot the Arch USB and run:
> ```bash
> ntfsfix /dev/nvme0n1p3
> ```
> ntfsfix will detect and rewrite the corrupt boot sector (wrong sector count), repair the MFT, and mark the volume clean. Then remove the USB and reboot into Windows. Windows will run its own chkdsk on first boot — let it finish.
>
> Note: Windows recovery `chkdsk /f` will not work if the partition shows as RAW. ntfsfix from Linux is the correct tool in that state. `blkid /dev/nvme0n1p3` showing `TYPE="ntfs"` confirms the data is intact even when Windows shows RAW.

---

## Step 32 — Secure Boot Signing: Corrected Procedure

The original Step 32 is incorrect. Replace it entirely with the following.

### Why the original fails

Arch's GRUB package (`grub 2:2.14-1`) has the shim lock verifier compiled in. When Secure Boot is enabled, GRUB checks for shim protocols and refuses to load the kernel if they are absent. The original `grub-install` command does not disable this, causing:

```
error: kern/efi/sb.c:shim_lock_verifier_init:177:prohibited by secure boot policy.
Entering rescue mode...
grub rescue>
```

Additionally, Arch's GRUB binary has no SBAT section by default. Shim 15.3+ refuses to launch EFI binaries without SBAT, so adding shim to the boot chain without addressing SBAT also fails.

The fix is `--disable-shim-lock` in the grub-install command, which is the documented Arch Wiki approach for use with sbctl (custom keys, no shim).

### Corrected Step 32

Do this only after confirming Arch boots correctly and all hardware works.

**1. Install sbctl:**
```bash
sudo pacman -S sbctl
```

**2. Enter BIOS Setup Mode:**

Reboot → F2 → Security → Secure Boot → enable Secure Boot control (to reveal Key Management) → Key Management → Delete All Secure Boot Keys / Reset to Setup Mode → **disable Secure Boot again** → Save & Exit.

Boot back into Arch and confirm Setup Mode is active:
```bash
sudo sbctl status
# Setup Mode: ✓ Enabled
# Secure Boot: ✗ Disabled
```

**3. Create and enroll keys:**
```bash
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
```

**4. Reinstall GRUB with shim lock disabled:**
```bash
sudo grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

The `--disable-shim-lock` flag disables the shim lock verifier so GRUB loads the kernel directly using your enrolled sbctl keys. The `--modules="tpm"` flag is required for sbctl's signing database integration.

**5. Sign all EFI binaries:**
```bash
sudo sbctl sign -s /efi/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /efi/EFI/Boot/bootx64.efi
sudo sbctl sign -s /boot/vmlinuz-linux
```

The `-s` flag registers each file in sbctl's database so it is automatically re-signed on kernel and bootloader updates via the pacman hook.

**6. Verify:**
```bash
sudo sbctl verify 2>/dev/null | grep -E "grubx64|bootx64|vmlinuz"
```

All three should show as signed. The Microsoft files in `/efi/EFI/Microsoft/` will show unsigned — this is expected and correct. They are signed by Microsoft's key which was enrolled via `--microsoft`.

**7. Enable Secure Boot:**

Reboot → F2 → Security → Secure Boot → Enable → Save & Exit.

Boot into Arch and confirm:
```bash
sudo sbctl status
# Secure Boot: ✓ Enabled
```

---

## Recovery: Broken GRUB from grub-mkimage

If GRUB drops to a `grub>` prompt with no boot menu after Secure Boot changes, the cause is a broken prefix path from a manual `grub-mkimage` invocation. Boot the Arch USB and chroot in:

```bash
mount /dev/nvme0n1p5 /mnt
mount /dev/nvme0n1p1 /mnt/efi
mount /dev/sda3 /mnt/home
swapon /dev/sda2
arch-chroot /mnt
```

Then reinstall GRUB correctly:
```bash
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg
```

Re-sign and proceed from Step 5 of the corrected Secure Boot procedure above.

---

## Notes

- Do not use `grub-mkimage` manually. `grub-install` with `--disable-shim-lock` handles everything correctly.
- `shim-signed` (AUR) is not needed for this setup. sbctl with custom keys and `--disable-shim-lock` is the correct approach for Arch without shim.
- The `ESP_PATH=/efi` environment variable (in `/etc/environment`) may be needed if sbctl cannot locate the EFI partition. Add it and reboot if `sbctl verify` shows unexpected behavior post-install.






----------------------------------------------------------------------------

# Next Steps — Secure Boot Setup

Current state: Windows is healthy. Arch is installed and intact. GRUB is broken (drops to grub> prompt). Secure Boot is disabled. sbctl keys are enrolled.

---

## Step 1 — Flash Arch ISO to USB

Flash the Arch Linux ISO to your USB drive using Rufus (GPT, DD mode).

---

## Step 2 — Boot Arch Live USB

Reboot → F2 → set USB as first boot device → Save & Exit.

---

## Step 3 — Mount and Chroot

At the live shell (`root@archiso`), run these in order:

```bash
mount /dev/nvme0n1p5 /mnt
mount /dev/nvme0n1p1 /mnt/efi
mount /dev/sda3 /mnt/home
swapon /dev/sda2
arch-chroot /mnt
```

lsblk will show no mountpoints before these commands — that is normal. The live environment never auto-mounts your internal partitions.

---

## Step 4 — Reinstall GRUB

```bash
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg
```

`--disable-shim-lock` disables the shim lock verifier that was causing the original boot failure. `--modules="tpm"` is required for sbctl integration.

Verify grub-install reports no errors before continuing.

---

## Step 5 — Re-sign EFI Binaries

```bash
sbctl sign -s /efi/EFI/GRUB/grubx64.efi
sbctl sign -s /efi/EFI/Boot/bootx64.efi
sbctl sign -s /boot/vmlinuz-linux
```

Verify all three are signed:

```bash
sbctl verify 2>/dev/null | grep -E "grubx64|bootx64|vmlinuz"
```

Expected output:
```
✓ /boot/vmlinuz-linux is signed
✓ /efi/EFI/Boot/bootx64.efi is signed
✓ /efi/EFI/GRUB/grubx64.efi is signed
```

---

## Step 6 — Exit and Unmount

```bash
exit
umount -R /mnt
reboot
```

Remove the USB when the screen goes dark.

---

## Step 7 — Enable Secure Boot in BIOS

Reboot → F2 → Security → Secure Boot → Enable → Save & Exit.

---

## Step 8 — Confirm Secure Boot is Working

Boot into Arch normally. At the terminal run:

```bash
sudo sbctl status
```

Expected output:
```
Installed:    ✓ sbctl is installed
Setup Mode:   ✓ Disabled
Secure Boot:  ✓ Enabled
Vendor Keys:  microsoft
```

If Secure Boot shows Enabled, Step 32 is complete.

---

## If Something Goes Wrong

**GRUB drops to grub> prompt again:**
Boot the Arch USB, chroot in (Step 3), and re-run Step 4 and Step 5.

**Secure Boot blocks boot:**
Disable Secure Boot in BIOS, boot Arch USB, chroot in, and re-run Step 4 and Step 5. Then re-enable Secure Boot.

**Windows won't boot after enabling Secure Boot:**
Windows boot files are signed by Microsoft's key which was enrolled via `--microsoft`. Windows should boot fine. If it doesn't, disable Secure Boot temporarily, boot Windows, then re-enable.