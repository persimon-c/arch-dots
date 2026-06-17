// theme/PanelColors.qml — Semantic color tokens
// Maps raw Colors.* palette roles onto named UI roles.
// This is the ONLY color layer that widgets and panels import directly.
// Never reference Colors.* from a widget — go through PanelColors instead.
// When matugen updates Colors.*, all bindings here re-evaluate automatically.

pragma Singleton

import Quickshell

Singleton {

    // ── Bar / panel backgrounds ───────────────────────────────────────────
    // Use Qt.rgba() in the widget itself when you need opacity applied.
    // PanelColors exposes the base color string; opacity comes from Theme.*

    readonly property string barBackground:       Colors.surface
    readonly property string panelBackground:     Colors.surfaceContainer
    readonly property string dropdownBackground:  Colors.surfaceContainerHigh

    // ── Text ──────────────────────────────────────────────────────────────

    readonly property string textPrimary:   Colors.onSurfaceColor
    readonly property string textMuted:     Colors.onSurfaceVariantColor
    readonly property string textOnAccent:  Colors.onPrimaryColor

    // ── Pill foreground (icon + label inside a pill) ───────────────────────
    // Use pillText* properties for per-pill text colors (dark on light accent fills).
    // pillForeground is kept for surface-colored pills (tray, workspace inactive).

    readonly property string pillForeground: Colors.onSurfaceColor

    // ── Per-widget pill background colors ─────────────────────────────────
    // Pills use the accent colors (primary/secondary/tertiary) as fills — light,
    // saturated, and readable. Containers were too dark and low-contrast.
    // Text on these pills must use the corresponding on* role (dark text on light fill).

    readonly property string pillClock:       Colors.primary            // light pink/accent
    readonly property string pillAudio:       Colors.secondary          // light mauve/secondary
    readonly property string pillBattery:     Colors.tertiary           // light peach/tertiary
    readonly property string pillNetwork:     Colors.primary
    readonly property string pillBluetooth:   Colors.secondary
    readonly property string pillBrightness:  Colors.tertiary
    readonly property string pillMedia:       Colors.primary
    readonly property string pillNotif:       Colors.error              // warm red, already light
    readonly property string pillTray:        Colors.surfaceContainerHighest
    readonly property string pillWorkspace:   Colors.surfaceContainerHigh
    readonly property string pillCava:        Colors.primary
    readonly property string pillGithub:      Colors.secondary
    readonly property string pillPower:       Colors.error
    readonly property string pillArch:        Colors.primary

    // ── Pill text colors ──────────────────────────────────────────────────
    // These MUST pair with the pill background above — on* roles are dark,
    // ensuring legibility on the light accent fills.

    readonly property string pillTextClock:       Colors.onPrimaryColor
    readonly property string pillTextAudio:       Colors.onSecondaryColor
    readonly property string pillTextBattery:     Colors.onTertiaryColor
    readonly property string pillTextNetwork:     Colors.onPrimaryColor
    readonly property string pillTextBluetooth:   Colors.onSecondaryColor
    readonly property string pillTextBrightness:  Colors.onTertiaryColor
    readonly property string pillTextMedia:       Colors.onPrimaryColor
    readonly property string pillTextNotif:       Colors.onErrorColor
    readonly property string pillTextTray:        Colors.onSurfaceColor
    readonly property string pillTextWorkspace:   Colors.onSurfaceColor
    readonly property string pillTextCava:        Colors.onPrimaryColor
    readonly property string pillTextGithub:      Colors.onSecondaryColor
    readonly property string pillTextPower:       Colors.onErrorColor
    readonly property string pillTextArch:        Colors.onPrimaryColor

    // ── Accent ────────────────────────────────────────────────────────────

    readonly property string accent:        Colors.primary
    readonly property string accentSubtle:  Colors.primaryContainer
    readonly property string onAccent:      Colors.onPrimaryColor

    // ── Borders / dividers ────────────────────────────────────────────────

    readonly property string border:        Colors.outline
    readonly property string borderSubtle:  Colors.outlineVariant

    // ── State colors ──────────────────────────────────────────────────────

    readonly property string error:    Colors.error
    readonly property string onError:  Colors.onErrorColor
    readonly property string success:  Colors.tertiary
    readonly property string warning:  Colors.secondary

    // ── Workspace pill states ─────────────────────────────────────────────

    readonly property string workspaceActive:    Colors.primary
    readonly property string workspaceOccupied:  Colors.onSurfaceVariantColor
    readonly property string workspaceEmpty:     Colors.surfaceContainerHighest

    // ── Left Sidebar Cards & Dashboard Tokens ──────────────────────────────
    readonly property string popupBackground:     Colors.surfaceContainerHigh
    readonly property string rowBackground:       Colors.surfaceContainerHighest
    readonly property string textDim:             Colors.onSurfaceVariantColor
    readonly property string textAccent:          Colors.onSurfaceColor

    readonly property string profile:             Colors.tertiary
    readonly property string system:              Colors.primary

    // ── ASUS Power Profile Colors ─────────────────────────────────────────
    readonly property string profileQuiet:       "#a5d6a7"
    readonly property string profileBalanced:    Colors.tertiary
    readonly property string profilePerformance: Colors.error

    // ── Bluetooth popup tokens ───────────────────────────────────────────
    readonly property string bluetoothActive:           Colors.primary
    readonly property string bluetoothTextActive:       Colors.onPrimaryColor
    readonly property string bluetoothInactiveAccent:   Colors.primary
    readonly property string bluetoothScanning:         Colors.secondary
    readonly property string bluetoothTextScanning:     Colors.onSecondaryColor
    readonly property string bluetoothPairing:          Colors.tertiary

    // ── Color transition duration (ms) ────────────────────────────────────
    // Behavior on color { ColorAnimation { duration: PanelColors.transitionDuration ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

    readonly property int transitionDuration: Theme.durationNormal
}