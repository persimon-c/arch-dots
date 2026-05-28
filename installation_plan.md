# Arch Linux Manual Installation Guide
**Hardware:** ASUS TUF Gaming FX505DT — AMD Ryzen 5 3550H + NVIDIA GTX 1650  
**Setup:** Dual boot alongside Windows 11, UEFI, no Secure Boot during install

---

## Before You Boot the USB

These must be done in Windows before anything else.

**In Windows (run PowerShell as Administrator):**
```powershell
# Disable hypervisor (required — conflicts with Linux boot)
bcdedit /set hypervisorlaunchtype off

# Disable hibernation (required — leaves NTFS dirty, Linux refuses to mount it)
powercfg /hibernate off
```

**In Disk Management:**
1. Shrink C: (SSD) by 51200MB → creates 50GB unallocated for Arch root
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

**Do not touch the Windows partitions. Only create new partitions in the unallocated space.**

### Partition the SSD (nvme0n1) — Arch root only

```bash
cfdisk /dev/nvme0n1
```

Inside cfdisk:
- You'll see the existing partitions: nvme0n1p1 (EFI), p2 (MSR), p3 (Windows C:), and a `Free space` entry of ~50GB
- Arrow down to the `Free space` entry
- Select `[ New ]` → accept the default size (entire free space) → Enter
- Select `[ Write ]` → type `yes` to confirm
- Select `[ Quit ]`

This creates `nvme0n1p4`.

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
nvme0n1p1   ~100MB   (Windows EFI — existing)
nvme0n1p2   ~16MB    (Windows MSR — existing)
nvme0n1p3   ~128GB   (Windows C: — existing)
nvme0n1p4   50GB     (Arch root — new)
sda1        300GB    (Windows D: — existing)
sda2        4GB      (swap — new)
sda3        ~627GB   (Arch home — new)
```

> **Error — partition table shows wrong sizes or overlaps:**  
> Select `[ Quit ]` without writing. Re-examine with `lsblk` and `fdisk -l /dev/nvme0n1`. If unallocated space is missing, Windows Disk Management may not have actually committed the shrink — reboot Windows and check.

---

## Step 5 — Format the Partitions

```bash
# Arch root
mkfs.ext4 /dev/nvme0n1p4

# Arch home
mkfs.ext4 /dev/sda3

# Swap
mkswap /dev/sda2

# DO NOT format nvme0n1p1 — that is the shared EFI partition with Windows
```

> **Error — `mkfs.ext4: invalid argument` or similar:**  
> Run `lsblk` to confirm the partition actually exists. If it doesn't, the cfdisk write step may not have committed — rerun cfdisk and make sure to select `[ Write ]` and confirm with `yes`.

---

## Step 6 — Mount the Partitions

```bash
mount /dev/nvme0n1p4 /mnt

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
# Find the line, remove the leading #, save (Ctrl+O, Enter, Ctrl+X)

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
pacman -S grub efibootmgr os-prober ntfs-3g networkmanager sudo git zsh
```

- `ntfs-3g` — required for os-prober to detect the Windows partition
- `networkmanager` — handles Wi-Fi and ethernet after reboot
- `efibootmgr` — required by GRUB for UEFI install

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

## Step 21b — Install matugen (AUR)

matugen generates dynamic accent palettes from wallpaper images. Install it now via yay since it is needed for the wallpaper switcher later.

```bash
yay -S matugen
```

Verify it works:
```bash
matugen --version
```

The color output files will be generated later when the wallpaper switcher script is set up. No configuration needed at this stage.

---

## Step 22 — Install NVIDIA Drivers

```bash
sudo pacman -S nvidia nvidia-utils nvidia-settings
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
> Check the WLR_DRM_DEVICES variable — `card1` may not be the AMD card. Run `ls -la /dev/dri/by-path/` and use the stable PCI path instead (see setup_plan.md GPU section).

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
               pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
               pavucontrol bluez bluez-utils blueman ufw

yay -S sddm-git hyprlock hypridle awww rofi-wayland swaync \
       nwg-dock-hyprland hyprshot cliphist wl-clipboard \
       kitty zellij yazi thunar
```

**Enable services:**
```bash
sudo systemctl enable sddm
sudo systemctl enable bluetooth
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo systemctl enable ufw
```

---

## Step 25 — Install Fonts

```bash
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk
```

---

## Step 26 — Configure Hyprland for AMD+NVIDIA

Create the Hyprland config directory and start a minimal config:

```bash
mkdir -p ~/.config/hypr
vim ~/.config/hypr/hyprland.conf
```

Find the stable AMD GPU path first:
```bash
ls -la /dev/dri/by-path/
```

Look for a `pci-*` entry that points to a `cardN` device corresponding to the AMD iGPU PCI address (typically the one with a lower PCI bus number). Use that full path.

Minimal working config to get started:
```ini
# GPU — use stable PCI path, not /dev/dri/card1
env = WLR_DRM_DEVICES,/dev/dri/by-path/<your-amd-pci-path-here>
env = LIBVA_DRIVER_NAME,radeonsi
env = WLR_NO_HARDWARE_CURSORS,1

# Basic input
input {
    kb_layout = us
    touchpad {
        natural_scroll = false
        tap-to-click = true
        disable_while_typing = true
    }
    sensitivity = 0.5
}

# Visuals
decoration {
    rounding = 12
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = true
    }
    active_opacity = 0.92
    inactive_opacity = 0.85
    drop_shadow = true
}

# Keybinds (minimal — add more from setup_plan.md)
$mod = SUPER
bind = $mod, Return, exec, kitty
bind = $mod, W, killactive
bind = $mod, Space, exec, rofi -show drun
bind = $mod, F, fullscreen
bind = $mod, L, exec, hyprlock
```

---

## Step 27 — Storage Management (Keep Root Healthy)

Your root partition is only 50GB. Two things must be done to prevent it from filling up.

**1. Enable automatic pacman cache cleanup:**

The pacman cache lives on root at `/var/cache/pacman/pkg/` and grows unbounded by default. Enable the weekly cleanup timer that ships with pacman:

```bash
sudo systemctl enable --now paccache.timer
```

This automatically keeps only the 3 most recent versions of each package and removes the rest, weekly.

**2. Move Docker data root to /home:**

Docker images, containers, and volumes are stored at `/var/lib/docker/` by default — on root. A single image can be 1–3GB and they accumulate fast. Move the data root to your 627GB home partition:

```bash
sudo mkdir -p /home/docker-data
```

Create or edit the Docker daemon config:
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
sudo systemctl restart docker
```

Verify the data root moved:
```bash
docker info | grep "Docker Root Dir"
# Should show: Docker Root Dir: /home/docker-data
```

> **Note — do this before pulling any Docker images.** If you pull images before moving the data root, they land on root. Moving after the fact requires migrating existing data manually.

---

## Step 28 — Post-Install: Secure Boot Signing (After Everything Works)

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
| radeontop permission denied | GPU gauge shows nothing in Quickshell | Add udev rule and add user to video group — see setup_plan.md radeontop note |
| `card1` not stable | Hyprland fails to start with wrong GPU | Use `/dev/dri/by-path/` path instead |
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
mount /dev/nvme0n1p4 /mnt
mount /dev/nvme0n1p1 /mnt/efi
mount /dev/sda3 /mnt/home
swapon /dev/sda2

# Chroot back in
arch-chroot /mnt

# From here you can fix configs, reinstall packages, regenerate GRUB, etc.
```

This is your recovery path for almost any post-install problem.