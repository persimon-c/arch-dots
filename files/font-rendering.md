# Missing Setup Step: Font Rendering Configuration

`setup_plan.md` has the full `/etc/fonts/local.conf` XML, but neither `installation_plan.md` nor `build_order.md` include the actual write command. This step produces that file and rebuilds the font cache.

Do this in Phase 5 of `build_order.md`, before theming any app.

---

## Steps

1. **Install freetype2 and fontconfig** if not already present:

   ```bash
   sudo pacman -S --needed freetype2 fontconfig
   ```

2. **Write `/etc/fonts/local.conf`:**

   ```bash
   sudo tee /etc/fonts/local.conf > /dev/null << 'EOF'
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
   EOF
   ```

3. **Rebuild the font cache:**

   ```bash
   fc-cache -fv
   ```

   The `-f` flag forces a full rebuild even if cached data appears current. The `-v` flag shows which directories are being scanned — verify that `/usr/share/fonts` and `~/.local/share/fonts` are included.

4. **Log out and back in** (or reboot) for the rendering changes to take effect. A Hyprland reload alone is not sufficient — fontconfig changes require a new login session.

5. **Verify the rendering improved:**

   Open Kitty and Rofi and compare text sharpness. Subtext and UI labels should look noticeably crisper than the Arch default rendering.

> **Chezmoi note:** Track this file as a system file:
> ```bash
> chezmoi add /etc/fonts/local.conf
> ```

> **Error recovery:** If text looks pixelated or broken after this change, the `rgba = rgb` subpixel setting assumes an RGB-stripe display (standard for most laptops). If your display uses BGR or VRGB stripes (unusual), change `rgb` to `bgr` or `vrgb` respectively. To check: `cat /sys/class/graphics/fb0/device/subsystem_device` or look up your display model's panel spec.
