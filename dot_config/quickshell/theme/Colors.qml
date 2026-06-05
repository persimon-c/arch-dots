// theme/Colors.qml — Dynamic color palette
// Watches ~/.config/quickshell/theme/colors.json (written by matugen on wallpaper change).
// Falls back to: Lavender accent + Catppuccin Mocha surfaces when the file is missing
// or a key is empty — so the shell is fully usable before the first wallpaper pick.

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── File watcher ──────────────────────────────────────────────────────

    FileView {
        id: colorFile
        path: Quickshell.env("HOME") + "/.config/quickshell/theme/colors.json"
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: root._parse()
        onLoadFailed: console.warn("Colors.qml: failed to load colors.json — using fallback palette")
    }

    // ── Internal parse ────────────────────────────────────────────────────

    // Raw parsed object; updated whenever the file reloads
    property var _raw: ({})

    function _parse() {
        try {
            root._raw = JSON.parse(colorFile.text())
        } catch (e) {
            console.warn("Colors.qml: JSON parse error —", e)
            root._raw = {}
        }
    }

    // Returns value from _raw if non-empty, otherwise the fallback string.
    // Ensures the value always has a leading '#' — matugen hex output omits it.
    function _get(key, fallback) {
        var v = root._raw[key]
        if (!v || v.length === 0) return fallback
        return v.charAt(0) === "#" ? v : "#" + v
    }

    // ── Fallback palette — Catppuccin Mocha ───────────────────────────────
    // Accent: Lavender #b4befe
    // Surfaces / text lifted from Mocha spec.
    // These are ONLY used when matugen has not yet written a valid colors.json.

    readonly property string _fb_primary:                  "#b4befe"  // Lavender
    readonly property string _fb_onPrimary:                "#1e1e2e"  // Base
    readonly property string _fb_primaryContainer:         "#313244"  // Surface0
    readonly property string _fb_onPrimaryContainer:       "#cdd6f4"  // Text
    readonly property string _fb_secondary:                "#cba6f7"  // Mauve
    readonly property string _fb_tertiary:                 "#89b4fa"  // Blue
    readonly property string _fb_error:                    "#f38ba8"  // Red
    readonly property string _fb_onError:                  "#1e1e2e"  // Base
    readonly property string _fb_surface:                  "#1e1e2e"  // Base
    readonly property string _fb_onSurface:                "#cdd6f4"  // Text
    readonly property string _fb_onSurfaceVariant:         "#bac2de"  // Subtext1
    readonly property string _fb_surfaceContainer:         "#181825"  // Mantle
    readonly property string _fb_surfaceContainerHigh:     "#313244"  // Surface0
    readonly property string _fb_surfaceContainerHighest:  "#45475a"  // Surface1
    readonly property string _fb_outline:                  "#6c7086"  // Overlay0
    readonly property string _fb_outlineVariant:           "#45475a"  // Surface1
    readonly property string _fb_shadow:                   "#000000"
    readonly property string _fb_scrim:                    "#000000"

    // ── Public palette ────────────────────────────────────────────────────
    // Bind to these throughout the shell. Never reference _raw or _fb_ directly.

    readonly property string primary:                 _get("primary",                  _fb_primary)
    readonly property string onPrimary:               _get("on_primary",               _fb_onPrimary)
    readonly property string primaryContainer:        _get("primary_container",         _fb_primaryContainer)
    readonly property string onPrimaryContainer:      _get("on_primary_container",      _fb_onPrimaryContainer)
    readonly property string secondary:               _get("secondary",                 _fb_secondary)
    readonly property string tertiary:                _get("tertiary",                  _fb_tertiary)
    readonly property string error:                   _get("error",                     _fb_error)
    readonly property string onError:                 _get("on_error",                  _fb_onError)
    readonly property string surface:                 _get("surface",                   _fb_surface)
    readonly property string onSurface:               _get("on_surface",                _fb_onSurface)
    readonly property string onSurfaceVariant:        _get("on_surface_variant",        _fb_onSurfaceVariant)
    readonly property string surfaceContainer:        _get("surface_container",         _fb_surfaceContainer)
    readonly property string surfaceContainerHigh:    _get("surface_container_high",    _fb_surfaceContainerHigh)
    readonly property string surfaceContainerHighest: _get("surface_container_highest", _fb_surfaceContainerHighest)
    readonly property string outline:                 _get("outline",                   _fb_outline)
    readonly property string outlineVariant:          _get("outline_variant",           _fb_outlineVariant)
    readonly property string shadow:                  _get("shadow",                    _fb_shadow)
    readonly property string scrim:                   _get("scrim",                     _fb_scrim)

    // ── Convenience aliases ───────────────────────────────────────────────
    // These don't add new colors — they map semantic names onto the palette
    // above so callsites read as intent, not role names.

    // Accent — the single most prominent color; use for highlights, active states
    readonly property string accent:       primary
    readonly property string onAccent:     onPrimary
    // Background — behind all panels; usually the darkest surface
    readonly property string background:   surfaceContainer
    // Text shorthands
    readonly property string textPrimary:  onSurface
    readonly property string textMuted:    onSurfaceVariant
    // Border / divider shorthands
    readonly property string border:       outline
    readonly property string borderSubtle: outlineVariant
}