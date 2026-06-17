// theme/Colors.qml — Dynamic color palette
// Watches ~/.config/quickshell/theme/colors.json (written by matugen on wallpaper change).
// Falls back to Lavender accent + Catppuccin Mocha surfaces when the file is missing
// or a key is empty — so the shell is fully usable before the first wallpaper pick.

pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── File watcher ──────────────────────────────────────────────────────

    FileView {
        id: colorFile
        path: Quickshell.env("HOME") + "/.config/quickshell/theme/colors.json"
        watchChanges: true
        onFileChanged: colorFile.reload()
        onLoaded: root._parse()
        onLoadFailed: console.warn("Colors.qml: failed to load colors.json — using fallback palette")
    }

    // ── Internal parse ────────────────────────────────────────────────────

    property var _raw: ({})

    function _parse() {
        try {
            var txt = colorFile.text()   // ← call it
            if (!txt || txt.trim().length === 0) return
            root._raw = JSON.parse(txt.trim())
        } catch (e) {
            console.warn("Colors.qml: JSON parse error —", e)
            root._raw = {}
        }
    }

    // Returns value from _raw if non-empty, otherwise the fallback string.
    // Ensures the value always has a leading '#' — matugen hex output may omit it.
    // raw_data is passed to make the binding reactive to changes in _raw.
    function _get(key, fallback, raw_data) {
        var v = raw_data[key]
        if (!v || v.length === 0) return fallback
        return v.charAt(0) === "#" ? v : "#" + v
    }

    // ── Fallback palette — Catppuccin Mocha ───────────────────────────────
    // Used ONLY before matugen has written a valid colors.json.

    readonly property string _fb_primary:                   "#b4befe"  // Lavender
    readonly property string _fb_onPrimary:                 "#1e1e2e"  // Base
    readonly property string _fb_primaryContainer:          "#313244"  // Surface0
    readonly property string _fb_onPrimaryContainer:        "#cdd6f4"  // Text
    readonly property string _fb_secondary:                 "#cba6f7"  // Mauve
    readonly property string _fb_onSecondary:               "#1e1e2e"  // Base
    readonly property string _fb_secondaryContainer:        "#45475a"  // Surface1
    readonly property string _fb_onSecondaryContainer:      "#cdd6f4"  // Text
    readonly property string _fb_tertiary:                  "#89b4fa"  // Blue
    readonly property string _fb_onTertiary:                "#1e1e2e"  // Base
    readonly property string _fb_tertiaryContainer:         "#313244"  // Surface0
    readonly property string _fb_onTertiaryContainer:       "#cdd6f4"  // Text
    readonly property string _fb_error:                     "#f38ba8"  // Red
    readonly property string _fb_onError:                   "#1e1e2e"  // Base
    readonly property string _fb_errorContainer:            "#45475a"  // Surface1 (muted red stand-in)
    readonly property string _fb_onErrorContainer:          "#f38ba8"  // Red
    readonly property string _fb_surface:                   "#1e1e2e"  // Base
    readonly property string _fb_onSurface:                 "#cdd6f4"  // Text
    readonly property string _fb_onSurfaceVariant:          "#bac2de"  // Subtext1
    readonly property string _fb_surfaceContainer:          "#181825"  // Mantle
    readonly property string _fb_surfaceContainerHigh:      "#313244"  // Surface0
    readonly property string _fb_surfaceContainerHighest:   "#45475a"  // Surface1
    readonly property string _fb_surfaceContainerLow:       "#11111b"  // Crust
    readonly property string _fb_surfaceContainerLowest:    "#0a0a14"  // Below crust (near black)
    readonly property string _fb_outline:                   "#6c7086"  // Overlay0
    readonly property string _fb_outlineVariant:            "#45475a"  // Surface1
    readonly property string _fb_shadow:                    "#000000"
    readonly property string _fb_scrim:                     "#000000"

    // ── Public palette ────────────────────────────────────────────────────
    // Bind to these throughout the shell. Never reference _raw or _fb_ directly.
    // Properties renamed from on* to on*Color to prevent name clashing with QML signal handlers.

    readonly property string primary:                  _get("primary",                   _fb_primary, _raw)
    readonly property string onPrimaryColor:           _get("on_primary",                _fb_onPrimary, _raw)
    readonly property string primaryContainer:         _get("primary_container",          _fb_primaryContainer, _raw)
    readonly property string onPrimaryContainer:       _get("on_primary_container",       _fb_onPrimaryContainer, _raw)
    readonly property string secondary:                _get("secondary",                  _fb_secondary, _raw)
    readonly property string onSecondaryColor:         _get("on_secondary",               _fb_onSecondary, _raw)
    readonly property string secondaryContainer:       _get("secondary_container",        _fb_secondaryContainer, _raw)
    readonly property string onSecondaryContainer:     _get("on_secondary_container",     _fb_onSecondaryContainer, _raw)
    readonly property string tertiary:                 _get("tertiary",                   _fb_tertiary, _raw)
    readonly property string onTertiaryColor:          _get("on_tertiary",                _fb_onTertiary, _raw)
    readonly property string tertiaryContainer:        _get("tertiary_container",         _fb_tertiaryContainer, _raw)
    readonly property string onTertiaryContainer:      _get("on_tertiary_container",      _fb_onTertiaryContainer, _raw)
    readonly property string error:                    _get("error",                      _fb_error, _raw)
    readonly property string onErrorColor:             _get("on_error",                   _fb_onError, _raw)
    readonly property string errorContainer:           _get("error_container",            _fb_errorContainer, _raw)
    readonly property string onErrorContainer:         _get("on_error_container",         _fb_onErrorContainer, _raw)
    readonly property string surface:                  _get("surface",                    _fb_surface, _raw)
    readonly property string onSurfaceColor:           _get("on_surface",                 _fb_onSurface, _raw)
    readonly property string onSurfaceVariantColor:    _get("on_surface_variant",         _fb_onSurfaceVariant, _raw)
    readonly property string surfaceContainer:         _get("surface_container",          _fb_surfaceContainer, _raw)
    readonly property string surfaceContainerHigh:     _get("surface_container_high",     _fb_surfaceContainerHigh, _raw)
    readonly property string surfaceContainerHighest:  _get("surface_container_highest",  _fb_surfaceContainerHighest, _raw)
    readonly property string surfaceContainerLow:      _get("surface_container_low",      _fb_surfaceContainerLow, _raw)
    readonly property string surfaceContainerLowest:   _get("surface_container_lowest",   _fb_surfaceContainerLowest, _raw)
    readonly property string outline:                  _get("outline",                    _fb_outline, _raw)
    readonly property string outlineVariant:           _get("outline_variant",            _fb_outlineVariant, _raw)
    readonly property string shadow:                   _get("shadow",                     _fb_shadow, _raw)
    readonly property string scrim:                    _get("scrim",                      _fb_scrim, _raw)

    // ── Convenience aliases ───────────────────────────────────────────────
    // Semantic shorthands — don't add new colors, just rename for callsite clarity.

    readonly property string accent:        primary
    readonly property string onAccentColor: onPrimaryColor
    readonly property string background:    surfaceContainer
    readonly property string textPrimary:   onSurfaceColor
    readonly property string textMuted:     onSurfaceVariantColor
    readonly property string border:        outline
    readonly property string borderSubtle:  outlineVariant
}