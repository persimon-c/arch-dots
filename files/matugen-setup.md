# Missing Setup Step: Matugen Template Configuration

Without template files in `~/.config/matugen/`, running `matugen image <path>` generates colors internally but writes nothing to disk. Every downstream tool (Quickshell, Hyprland, Kitty, Rofi, Swaync) will silently continue using fallback/hardcoded colors. This is the most likely silent failure point in the entire color pipeline.

---

## Steps

1. **Create the matugen config and template directories:**

   ```bash
   mkdir -p ~/.config/matugen/templates
   ```

2. **Write `~/.config/matugen/config.toml`** (the file produced in this session as `matugen-config.toml`):

   ```bash
   # Copy the config.toml produced in this session
   cp matugen-config.toml ~/.config/matugen/config.toml
   ```

   This file tells matugen which template files to render and where to write each output. It defines four outputs: `colors.sh`, `colors.css`, `~/.config/hypr/colors.conf`, and `~/.config/kitty/matugen-colors.conf`.

3. **Write the four template files:**

   ```bash
   cp matugen-template-colors.sh     ~/.config/matugen/templates/colors.sh
   cp matugen-template-colors.css    ~/.config/matugen/templates/colors.css
   cp matugen-template-hypr-colors.conf ~/.config/matugen/templates/hypr-colors.conf
   cp matugen-template-kitty-colors.conf ~/.config/matugen/templates/kitty-colors.conf
   ```

   Template syntax uses `{{ colors.primary.default.hex }}` (double-braces, Jinja-like). The `.default` variant always resolves to the dark-mode color since config.toml sets `mode = "dark"`. Do not change `default` to `dark` — they are equivalent when mode is dark, and `default` is the portable form.

4. **Run matugen for the first time against a wallpaper to verify everything works:**

   You need at least one wallpaper in `~/wallpapers/` before doing this.

   ```bash
   matugen image ~/wallpapers/yourwallpaper.jpg
   ```

5. **Verify each output file was created and contains actual color values:**

   ```bash
   # Should contain lines like: export MATUGEN_ACCENT="#a89bce"
   cat ~/.config/matugen/colors.sh

   # Should contain CSS custom properties like: --accent: #a89bce;
   cat ~/.config/matugen/colors.css

   # Should contain: $accent = a89bce (hex without the # for Hyprland variables)
   cat ~/.config/hypr/colors.conf

   # Should contain: cursor  #a89bce
   cat ~/.config/kitty/matugen-colors.conf
   ```

   If any file is missing or empty, the most likely cause is a typo in the template `input_path` in `config.toml`. Check that the paths resolve correctly: `~` is expanded by matugen, so `~/.config/matugen/templates/colors.sh` is valid.

6. **Reload Hyprland to pick up the new colors.conf:**

   ```bash
   hyprctl reload
   ```

   After reload, active window borders should shift from the Lavender fallback (`#b4befe`) to the wallpaper-derived accent color. If borders do not change, check that `hyprland.conf` sources `colors.conf`:

   ```bash
   grep colors.conf ~/.config/hypr/hyprland.conf
   # Expected output: source = ~/.config/hypr/colors.conf
   ```

> **Error recovery:** If matugen exits with a template error mentioning an unknown color key, the color name used in the template is not part of matugen's Material You output for this version. Run `matugen image <path> --json hex` to dump all available color names and verify the template key exists in that output.
