# Replacement for build_order.md Phase 10 — Antigravity IDE Install

**Where to put this:** Replace the bullet point that reads "Install Antigravity (Google IDE): install per instructions at `antigravity.google`" with the steps below.

---

## Antigravity IDE on Arch Linux

**Clarification on the URL:** `build_order.md` references `antigravity.google` — this URL is correct and live. The earlier planning note mentioning Project IDX is outdated. Antigravity is the current product name, launched November 2025, available at `antigravity.google`. There is no AUR package for the full IDE in the official AUR under a stable, high-trust package as of May 2026 — the recommended method is via the `antigravity-ide` AUR package, which repackages Google's official binary.

**Note on Wayland:** Antigravity is Electron/Chromium-based. Without the Ozone flag, it will render via XWayland and may show a blank window on some Hyprland setups. The steps below include the Wayland fix.

---

## Install Steps

1. **Install the `antigravity-ide` AUR package:**

   ```bash
   yay -S antigravity-ide
   ```

   This installs the IDE to `/opt/Antigravity/` and creates `/usr/bin/antigravity`.

2. **Configure the Wayland flag to prevent blank-window issues on Hyprland:**

   The AUR package (as of May 2026) reads flags from `~/.config/antigravity-flags.conf`:

   ```bash
   mkdir -p ~/.config
   cat > ~/.config/antigravity-flags.conf << 'EOF'
   --ozone-platform-hint=auto
   --enable-features=WaylandWindowDecorations
   EOF
   ```

   `--ozone-platform-hint=auto` tells Chromium to use the native Wayland backend when running under Wayland, falling back to XWayland otherwise. This is the correct flag — it handles both environments.

3. **Verify the install:**

   ```bash
   antigravity --version
   ```

4. **Launch Antigravity and sign in:**

   ```bash
   antigravity
   ```

   On first launch, it opens a browser-backed Google sign-in flow. Sign in with your Google account to activate Gemini Pro features.

5. **Verify the `Super + A` keybind works:**

   The keybind in `keybinds.conf` should be:
   ```ini
   bind = SUPER, A, exec, antigravity
   ```
   Confirm this is present in `~/.config/hypr/keybinds.conf`, then test `Super + A`.

> **If a blank window appears despite the flags:** Add `--disable-gpu` to `~/.config/antigravity-flags.conf` as a temporary workaround while debugging. This disables GPU compositing, which solves rendering issues on some AMD setups under Wayland. Once confirmed working, remove `--disable-gpu` and test again — GPU acceleration is preferred for performance.

> **Screen sharing in Antigravity:** Requires `xdg-desktop-portal-hyprland` to be running. Verify it is in your `autostart.conf`: `exec-once = /usr/lib/xdg-desktop-portal-hyprland`. It should already be there from the base Hyprland setup.
