pragma Singleton
import QtQuick

// ColorUtils — pure color math helpers.
//
// All functions are stateless. Input colors can be:
//   - Qt color objects  (Qt.rgba / Qt.hsla)
//   - CSS hex strings   ("#rrggbb" / "#aarrggbb")
//   - CSS color names   ("red", "transparent", …)
//
// Usage:
//   Rectangle { color: ColorUtils.lighten(Colors.surface, 0.12) }
//   Text      { color: ColorUtils.onColor(Colors.accent) }
//   Rectangle { color: ColorUtils.alphaBlend(Colors.accent, 0.15, Colors.surface) }

QtObject {
    id: root

    // -------------------------------------------------------------------------
    // lighten(color, amount)
    // Increases HSL lightness by `amount` (0.0–1.0), clamped to [0, 1].
    // -------------------------------------------------------------------------
    function lighten(color, amount: real) {
        const c = Qt.color(color)
        const h = c.hslHue
        const s = c.hslSaturation
        const l = Math.min(1.0, c.hslLightness + amount)
        return Qt.hsla(h, s, l, c.a)
    }

    // -------------------------------------------------------------------------
    // darken(color, amount)
    // Decreases HSL lightness by `amount` (0.0–1.0), clamped to [0, 1].
    // -------------------------------------------------------------------------
    function darken(color, amount: real) {
        const c = Qt.color(color)
        const h = c.hslHue
        const s = c.hslSaturation
        const l = Math.max(0.0, c.hslLightness - amount)
        return Qt.hsla(h, s, l, c.a)
    }

    // -------------------------------------------------------------------------
    // withAlpha(color, alpha)
    // Returns the same color with a new alpha (0.0–1.0).
    // -------------------------------------------------------------------------
    function withAlpha(color, alpha: real) {
        const c = Qt.color(color)
        return Qt.rgba(c.r, c.g, c.b, Math.max(0.0, Math.min(1.0, alpha)))
    }

    // -------------------------------------------------------------------------
    // toRgba(hex, alpha)
    // Converts a hex string (#rrggbb or #aarrggbb) to a Qt color with the
    // given alpha override. If alpha is omitted or < 0, preserves original alpha.
    // -------------------------------------------------------------------------
    function toRgba(hex: string, alpha: real) {
        const c = Qt.color(hex)
        const a = (alpha >= 0) ? Math.min(1.0, alpha) : c.a
        return Qt.rgba(c.r, c.g, c.b, a)
    }

    // -------------------------------------------------------------------------
    // luminance(color)
    // Returns the WCAG relative luminance of a color (0.0 = black, 1.0 = white).
    // Uses the sRGB linearisation formula from WCAG 2.1.
    // -------------------------------------------------------------------------
    function luminance(color): real {
        const c = Qt.color(color)
        function lin(v) {
            return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b)
    }

    // -------------------------------------------------------------------------
    // contrastRatio(colorA, colorB)
    // Returns the WCAG contrast ratio between two colors (1.0–21.0).
    // -------------------------------------------------------------------------
    function contrastRatio(colorA, colorB): real {
        const lumA = luminance(colorA)
        const lumB = luminance(colorB)
        const lighter = Math.max(lumA, lumB)
        const darker  = Math.min(lumA, lumB)
        return (lighter + 0.05) / (darker + 0.05)
    }

    // -------------------------------------------------------------------------
    // onColor(background, light?, dark?)
    // Returns either `light` or `dark` depending on which has better contrast
    // against `background`. Defaults to white / near-black if not supplied.
    // Useful for deciding text color on dynamic-colored surfaces.
    //
    // Example:
    //   Text { color: ColorUtils.onColor(Colors.accent) }
    // -------------------------------------------------------------------------
    function onColor(background, light, dark) {
        const l = light !== undefined ? Qt.color(light) : Qt.color("#ffffff")
        const d = dark  !== undefined ? Qt.color(dark)  : Qt.color("#1e1e2e")
        return (contrastRatio(background, l) >= contrastRatio(background, d)) ? l : d
    }

    // -------------------------------------------------------------------------
    // isDark(color)
    // Returns true when the color's luminance is below 0.179 (WCAG threshold).
    // -------------------------------------------------------------------------
    function isDark(color): bool {
        return luminance(color) < 0.179
    }

    // -------------------------------------------------------------------------
    // isLight(color)
    // Inverse of isDark.
    // -------------------------------------------------------------------------
    function isLight(color): bool {
        return !isDark(color)
    }

    // -------------------------------------------------------------------------
    // alphaBlend(fg, fgAlpha, bg)
    // Composites a foreground color at the given alpha over a background,
    // returning the fully-opaque resulting color.
    //
    // Equivalent to what the renderer does, but available as a value for
    // cases where you need the blended hex (e.g. for a canvas or shader).
    //
    // fgAlpha: 0.0–1.0
    // -------------------------------------------------------------------------
    function alphaBlend(fg, fgAlpha: real, bg) {
        const f = Qt.color(fg)
        const b = Qt.color(bg)
        const a = Math.max(0.0, Math.min(1.0, fgAlpha))
        const ia = 1.0 - a
        return Qt.rgba(
            f.r * a + b.r * ia,
            f.g * a + b.g * ia,
            f.b * a + b.b * ia,
            1.0
        )
    }

    // -------------------------------------------------------------------------
    // mix(colorA, colorB, t)
    // Linear interpolation between two colors in sRGB space.
    // t = 0.0 → colorA, t = 1.0 → colorB.
    // -------------------------------------------------------------------------
    function mix(colorA, colorB, t: real) {
        const a = Qt.color(colorA)
        const b = Qt.color(colorB)
        const f = Math.max(0.0, Math.min(1.0, t))
        return Qt.rgba(
            a.r + (b.r - a.r) * f,
            a.g + (b.g - a.g) * f,
            a.b + (b.b - a.b) * f,
            a.a + (b.a - a.a) * f
        )
    }

    // -------------------------------------------------------------------------
    // saturate(color, amount) / desaturate(color, amount)
    // Adjusts HSL saturation by amount (0.0–1.0).
    // -------------------------------------------------------------------------
    function saturate(color, amount: real) {
        const c = Qt.color(color)
        return Qt.hsla(c.hslHue, Math.min(1.0, c.hslSaturation + amount), c.hslLightness, c.a)
    }

    function desaturate(color, amount: real) {
        const c = Qt.color(color)
        return Qt.hsla(c.hslHue, Math.max(0.0, c.hslSaturation - amount), c.hslLightness, c.a)
    }

    // -------------------------------------------------------------------------
    // toHex(color)
    // Converts a Qt color to a lowercase #rrggbb hex string (discards alpha).
    // -------------------------------------------------------------------------
    function toHex(color): string {
        const c = Qt.color(color)
        const r = Math.round(c.r * 255).toString(16).padStart(2, "0")
        const g = Math.round(c.g * 255).toString(16).padStart(2, "0")
        const b = Math.round(c.b * 255).toString(16).padStart(2, "0")
        return "#" + r + g + b
    }

    // -------------------------------------------------------------------------
    // toHexAlpha(color)
    // Returns #aarrggbb hex string (Qt convention for hex-with-alpha).
    // -------------------------------------------------------------------------
    function toHexAlpha(color): string {
        const c = Qt.color(color)
        const a = Math.round(c.a * 255).toString(16).padStart(2, "0")
        const r = Math.round(c.r * 255).toString(16).padStart(2, "0")
        const g = Math.round(c.g * 255).toString(16).padStart(2, "0")
        const b = Math.round(c.b * 255).toString(16).padStart(2, "0")
        return "#" + a + r + g + b
    }
}
