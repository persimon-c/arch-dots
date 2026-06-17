// theme/Theme.qml — Static layout and typography constants
// All values are flat properties so QML bindings propagate correctly.
// To change the font family: edit fontFamily (and optionally fontFamilyMono) only.
// To change a size scale: edit only the named property — all consumers update automatically.

pragma Singleton

import QtQuick
import Quickshell

Singleton {

    // ── Typography ────────────────────────────────────────────────────────
    // Change fontFamily here to restyle all text in the shell at once.

    readonly property string fontFamily:      "JetBrainsMono Nerd Font"
    readonly property string fontFamilyMono:  "JetBrainsMono Nerd Font"

    // Font sizes (px)
    readonly property int fontSizeXs:   11
    readonly property int fontSizeSm:   14
    readonly property int fontSizeMd:   15  // default body
    readonly property int fontSizeLg:   17
    readonly property int fontSizeXl:   20
    readonly property int fontSizeXxl:  26
    readonly property int fontSizeHero: 52  // lock screen clock, desktop clock

    // Font weights (Qt weight scale: 400 = Normal, 500 = Medium, 600 = SemiBold, 700 = Bold)
    readonly property int fontWeightNormal:   400
    readonly property int fontWeightMedium:   500
    readonly property int fontWeightSemiBold: 600
    readonly property int fontWeightBold:     700

    // ── Spacing ───────────────────────────────────────────────────────────
    // Used for padding, margins, gaps throughout all panels and components.

    readonly property int spacingXxs: 2
    readonly property int spacingXs:  4
    readonly property int spacingSm:  8
    readonly property int spacingMd:  12  // default inner padding
    readonly property int spacingLg:  16
    readonly property int spacingXl:  24
    readonly property int spacingXxl: 32

    // ── Border radius ─────────────────────────────────────────────────────

    readonly property int radiusSm:   6   // small chips, tags
    readonly property int radiusMd:   10  // pills, buttons, most components
    readonly property int radiusLg:   16  // panels, dropdowns, sidebars
    readonly property int radiusXl:   24  // large cards, wallpaper picker
    readonly property int radiusFull: 999 // fully rounded (circles, pill badges)

    // ── Blur ──────────────────────────────────────────────────────────────
    // Background blur radii for layershell panels.
    // Quickshell/wlroots blur is set per-window via hyprland windowrules;
    // these values are exposed here so Phase QS17 (settings) can read/write them.

    readonly property int blurBar:       8   // top bar background blur
    readonly property int blurPanel:     20  // sidebars, notification center
    readonly property int blurDropdown:  12  // small dropdowns
    readonly property int blurLock:      40  // lock screen heavy blur
    readonly property int blurOsd:       8

    // ── Opacity ───────────────────────────────────────────────────────────
    // Background fill opacity for frosted-glass panels.
    // Applied as: Qt.rgba(r, g, b, Theme.opacityPanel)

    readonly property real opacityBar:      0.75
    readonly property real opacityPanel:    0.80
    readonly property real opacityDropdown: 0.85
    readonly property real opacityLock:     0.60

    // ── Animation ─────────────────────────────────────────────────────────
    readonly property int easingType: Easing.BezierSpline
    readonly property var easingCurve: [0.0, 0.0, 0.15, 1.0] // loft
    readonly property var easingCurveIn: [0.0, 0.0, 0.15, 1.0] // loft
    readonly property var easingCurveOut: [0.4, 0.0, 1.0, 1.0] // throwOut

    readonly property int durationFast:   150
    readonly property int durationNormal: 250
    readonly property int durationSlow:   350

    // ── Component sizes ───────────────────────────────────────────────────
    // Canonical dimensions for recurring components. Keeps bar/panel sizing consistent.

    readonly property int barHeight:          36
    readonly property int pillHeight:         28
    readonly property int iconSize:           18  // standard icon in pills/buttons
    readonly property int iconSizeLg:         24  // sidebar icons, launcher
    readonly property int notifWidth:        380
    readonly property int sidebarWidth:      320
    readonly property int dropdownMinWidth:  200
}