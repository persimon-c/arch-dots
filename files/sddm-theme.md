# Replacement for build_order.md Phase 4 — SDDM Theme

**Where to put this:** Replace the bullet point in Phase 4 that reads "Source a pixel art / anime SDDM theme from GitHub community themes, install it, and set it in `/etc/sddm.conf`" with the steps below.

> **Note:** Phase 4 in `build_order.md` has already been updated to reflect these steps. This file exists as a standalone reference.

---

## SDDM Theme: sddm-astronaut-theme

**Chosen theme:** `sddm-astronaut-theme` by Keyitdev (`github.com/Keyitdev/sddm-astronaut-theme`).

**Why this theme:** It is actively maintained, written in Qt6 (matching `sddm-git`), ships ten pre-made variants selectable by swapping a single config file, supports animated wallpapers, and has a working AUR package. The anime/space aesthetic matches the visual direction in `visuals.md`. All variants were designed for 1080p.

---

## Install Steps

1. **Install the theme from the AUR:**

   ```bash
   yay -S sddm-astronaut-theme
   ```

   This pulls in all required Qt6 dependencies (`qt6-5compat`, `qt6-declarative`, `qt6-multimedia-ffmpeg`, `qt6-svg`, `qt6-virtualkeyboard`) automatically.

2. **Pick a theme variant:**

   Available variants are config files inside `/usr/share/sddm/themes/sddm-astronaut-theme/Themes/`. List them:

   ```bash
   ls /usr/share/sddm/themes/sddm-astronaut-theme/Themes/
   ```

   Select one by editing the metadata file:

   ```bash
   sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/astronaut.conf|' \
     /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
   ```

   Replace `astronaut.conf` with whichever variant you want. Preview first (see step 3) before committing.

3. **Preview the theme without logging out:**

   ```bash
   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/
   ```

   Run this after changing the variant in step 2 to confirm it looks correct before rebooting.

4. **Set SDDM to use the theme via a drop-in config:**

   ```bash
   sudo mkdir -p /etc/sddm.conf.d
   echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee /etc/sddm.conf.d/theme.conf
   ```

   Using `/etc/sddm.conf.d/` rather than editing `/etc/sddm.conf` directly is the Arch-recommended approach — it avoids conflicts if the `sddm` package ever ships a default `/etc/sddm.conf`.

5. **Reboot and verify:**

   ```bash
   reboot
   ```

   The themed login screen should appear. If you want to try a different variant afterwards, repeat steps 2–3 and reboot again.

> **Error recovery:** If SDDM fails to start and drops to a blank screen, switch to a TTY (`Ctrl+Alt+F2`) and check the journal:
> ```bash
> journalctl -u sddm --since "5 minutes ago"
> ```
> To temporarily reset to the SDDM default while you diagnose:
> ```bash
> sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << 'EOF'
> [Theme]
> Current=
> EOF
> sudo systemctl restart sddm
> ```