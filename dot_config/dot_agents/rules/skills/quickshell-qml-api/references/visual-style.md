# Quickshell Visual Style Guide

This guide covers layout anatomy, spacing, color usage, and component conventions
for this shell. Colors come from matugen's generated palette (written to
`~/.config/quickshell/theme/colors.json` on wallpaper change) and are exposed
through three singletons — never hardcode hex values in components.

---

## Singleton Architecture

Three files form the color/theme stack. Components import only `PanelColors`
and `Theme` — never `Colors` directly, and never raw hex strings.

```
colors.json  (matugen output)
     ↓
Colors.qml   — parses JSON, exposes all Material You roles as strings,
               falls back to Catppuccin Mocha when file is missing
     ↓
PanelColors.qml — maps roles onto named UI tokens (pillClock, barBackground, …)
                  THIS is what every widget imports for colors
     ↓
Theme.qml    — static layout constants (sizes, radii, spacing, durations)
               no colors here at all
```

### Matugen invocation (recommended)

```bash
matugen --mode dark image /path/to/wallpaper.jpg \
  --config ~/.config/matugen/config.toml
```

Run this in your wallpaper-change hook (e.g. a `swww` post-hook or Hyprland
`exec-once` wrapper). `Colors.qml` watches the file and re-parses automatically —
no shell restart needed.

---

## Design Principles

- **Cards everywhere.** All widgets are self-contained rounded panels floating
  over the wallpaper, never flush rectangles.
- **Semi-transparent backgrounds.** Panels use a slightly transparent fill so
  the wallpaper bleeds through — this is what ties the palette to the wallpaper.
- **Lowercase labels.** Section headers and widget labels use lowercase
  (`quick settings`, `system`, `notifications`) for a calm, non-shouty feel.
- **Consistent corner radius.** Use `Theme.radiusMd` (10px) for pills/buttons
  and `Theme.radiusLg` (16px) for panels and dropdowns.
- **Tight padding.** Inner padding is `Theme.spacingSm` (8px) to `Theme.spacingMd`
  (12px); cards feel compact, not airy.

---

## Spacing & Sizing Constants

All layout values live in `Theme.qml`. Reference them by name — never magic numbers.

| Property | Value | Use |
|---|---|---|
| `spacingXxs` | 2px | micro gaps |
| `spacingXs` | 4px | tight gaps between related items |
| `spacingSm` | 8px | default inner padding, gaps between items |
| `spacingMd` | 12px | default card padding |
| `spacingLg` | 16px | generous padding, section gaps |
| `spacingXl` | 24px | between major layout zones |
| `radiusSm` | 6px | small chips, tags, album art corners |
| `radiusMd` | 10px | pills, buttons, most components |
| `radiusLg` | 16px | panels, dropdowns, sidebars |
| `radiusXl` | 24px | large cards |
| `radiusFull` | 999px | fully rounded circles / pill badges |
| `barHeight` | 36px | top bar |
| `pillHeight` | 28px | bar pills |
| `iconSize` | 18px | standard icon in pills/buttons |
| `iconSizeLg` | 24px | sidebar icons, launcher |
| `notifWidth` | 380px | notification cards |
| `sidebarWidth` | 320px | side panels |

---

## Color Usage Rules

These rules apply in every component. Breaking them is what causes low-contrast
or unreadable UI when the wallpaper changes.

### Two color patterns — panels vs pills

There are two fundamentally different surface types in this shell and they use
color in opposite ways:

**Panels / cards / dropdowns — semi-transparent dark fill, light text**

```
background: Qt.rgba(Qt.color(PanelColors.panelBackground).r,
                    Qt.color(PanelColors.panelBackground).g,
                    Qt.color(PanelColors.panelBackground).b,
                    Theme.opacityPanel)   // 0.80
text color: PanelColors.textPrimary      // near-white onSurface
muted text: PanelColors.textMuted        // onSurfaceVariant
```

`panelBackground` maps to `Colors.surfaceContainer` — a near-black dark with
a faint hue tint. Applying opacity lets the wallpaper bleed through while
keeping the card readable. Never use it at full opacity or the frosted-glass
effect is lost.

**Pills / badges (top bar) — solid accent fill, dark text**

```
background: PanelColors.pillClock        // solid Colors.primary (light accent)
text color: PanelColors.pillTextClock    // Colors.onPrimary (dark, for contrast)
```

Pills are small opaque badges. They use the accent colors (`primary`,
`secondary`, `tertiary`) as solid fills — these are the light saturated values
matugen generates (e.g. light pink, mauve, peach). Text uses the corresponding
`on*` role which is always a dark color, giving the pill strong contrast.

**Never mix these patterns.** Using a `*Container` color (dark tinted) as a
pill background gives a low-contrast muddy look. Using a light accent as a
panel background loses the frosted-glass effect and may not read over the
wallpaper.

### PanelColors token reference

**Bar / panel backgrounds**

| Token | Source | Use |
|---|---|---|
| `barBackground` | `Colors.surface` | top bar fill |
| `panelBackground` | `Colors.surfaceContainer` | card/sidebar fill |
| `dropdownBackground` | `Colors.surfaceContainerHigh` | popup/dropdown fill |

**Text**

| Token | Source | Use |
|---|---|---|
| `textPrimary` | `Colors.onSurface` | main body text |
| `textMuted` | `Colors.onSurfaceVariant` | secondary/dim text |
| `textOnAccent` | `Colors.onPrimary` | text on accent-filled surfaces |
| `pillForeground` | `Colors.onSurface` | text on surface-colored pills (tray, inactive workspace) |

**Pill backgrounds (solid accent fills)**

| Token | Accent source | Paired text token |
|---|---|---|
| `pillClock` | `Colors.primary` | `pillTextClock` → `Colors.onPrimary` |
| `pillAudio` | `Colors.secondary` | `pillTextAudio` → `Colors.onSecondary` |
| `pillBattery` | `Colors.tertiary` | `pillTextBattery` → `Colors.onTertiary` |
| `pillNetwork` | `Colors.primary` | `pillTextNetwork` → `Colors.onPrimary` |
| `pillBluetooth` | `Colors.secondary` | `pillTextBluetooth` → `Colors.onSecondary` |
| `pillBrightness` | `Colors.tertiary` | `pillTextBrightness` → `Colors.onTertiary` |
| `pillMedia` | `Colors.primary` | `pillTextMedia` → `Colors.onPrimary` |
| `pillNotif` | `Colors.error` | `pillTextNotif` → `Colors.onError` |
| `pillTray` | `Colors.surfaceContainerHighest` | `pillForeground` |
| `pillWorkspace` | `Colors.surfaceContainerHigh` | `pillForeground` |
| `pillPower` | `Colors.error` | `pillTextPower` → `Colors.onError` |
| `pillArch` | `Colors.primary` | `pillTextArch` → `Colors.onPrimary` |

**Accent**

| Token | Source | Use |
|---|---|---|
| `accent` | `Colors.primary` | highlight color, active indicators |
| `accentSubtle` | `Colors.primaryContainer` | dim tinted bg behind accent icons |
| `onAccent` | `Colors.onPrimary` | text/icons on accent surfaces |

**Workspace pill states**

| Token | Source |
|---|---|
| `workspaceActive` | `Colors.primary` (solid accent fill) |
| `workspaceOccupied` | `Colors.onSurfaceVariant` |
| `workspaceEmpty` | `Colors.surfaceContainerHighest` |

**State**

| Token | Source |
|---|---|
| `error` | `Colors.error` |
| `success` | `Colors.tertiary` |
| `warning` | `Colors.secondary` |

**Borders**

| Token | Source |
|---|---|
| `border` | `Colors.outline` |
| `borderSubtle` | `Colors.outlineVariant` |

---

## Opacity Constants

Defined in `Theme.qml`. Always apply opacity at the component level via
`Qt.rgba(...)` — `PanelColors` exposes base color strings, not pre-opacified values.

| Property | Value | Use |
|---|---|---|
| `opacityBar` | 0.75 | top bar background |
| `opacityPanel` | 0.80 | card / sidebar backgrounds |
| `opacityDropdown` | 0.85 | dropdown backgrounds (slightly more opaque) |
| `opacityLock` | 0.60 | lock screen heavy blur |

```qml
// Correct pattern — apply opacity at the Rectangle level
Rectangle {
    color: Qt.rgba(
        Qt.color(PanelColors.panelBackground).r,
        Qt.color(PanelColors.panelBackground).g,
        Qt.color(PanelColors.panelBackground).b,
        Theme.opacityPanel
    )
    radius: Theme.radiusLg
}
```

---

## Card Anatomy

Every widget panel (left column cards, notification center, dropdowns) follows
this structure:

```
┌─────────────────────────────┐  ← Rectangle, radiusLg, panelBackground + opacityPanel
│ section label               │  ← Text, fontSizeSm, textMuted, lowercase
│ ─────────────────────────── │  ← optional 1px separator, borderSubtle, opacity 0.15
│                             │
│   [content]                 │
│                             │
└─────────────────────────────┘
```

```qml
// Card.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    property string label: ""
    default property alias content: inner.data

    color: Qt.rgba(
        Qt.color(PanelColors.panelBackground).r,
        Qt.color(PanelColors.panelBackground).g,
        Qt.color(PanelColors.panelBackground).b,
        Theme.opacityPanel
    )
    radius: Theme.radiusLg

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingSm

        Text {
            text: label
            font.pixelSize: Theme.fontSizeSm
            font.family: Theme.fontFamily
            color: PanelColors.textMuted
            visible: label !== ""
        }

        Item {
            id: inner
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
```

---

## Component Patterns

### Bar Pill

Small solid-accent badge. The single most important pattern to get right — this
is what makes the bar look like the inspiration screenshots.

```qml
// e.g. clock pill
Rectangle {
    height: Theme.pillHeight
    radius: Theme.radiusMd
    color: PanelColors.pillClock          // solid Colors.primary — light accent

    Row {
        anchors.centerIn: parent
        spacing: Theme.spacingXs
        Text {
            text: "󰥔"
            font.pixelSize: Theme.iconSize
            color: PanelColors.pillTextClock  // Colors.onPrimary — dark text
        }
        Text {
            text: "06:12 AM"
            font.pixelSize: Theme.fontSizeSm
            font.family: Theme.fontFamilyMono
            color: PanelColors.pillTextClock
        }
    }
}
```

Rules:
- Always pair `pill*` background with its `pillText*` counterpart. Never use
  `textPrimary` (near-white) as text on an accent-filled pill — it will fail
  contrast on light accents.
- Inactive / surface-colored pills (tray, empty workspace) use `pillForeground`
  (near-white `onSurface`) because their background is dark.
- Never apply opacity to pill backgrounds — they are fully opaque solid fills.

### Toggle Button (quick settings style)

Pill-shaped button, active state uses solid accent, inactive uses panel surface.

```qml
Rectangle {
    property bool active: false
    property string icon: "󰖨"
    property string label: "Night Light"

    height: Theme.pillHeight
    radius: Theme.radiusMd
    color: active
        ? PanelColors.accent   // solid Colors.primary when on
        : Qt.rgba(
            Qt.color(PanelColors.panelBackground).r,
            Qt.color(PanelColors.panelBackground).g,
            Qt.color(PanelColors.panelBackground).b,
            Theme.opacityPanel
          )

    Row {
        anchors.centerIn: parent
        spacing: Theme.spacingXs
        Text {
            text: icon
            font.pixelSize: Theme.iconSize
            color: active ? PanelColors.onAccent : PanelColors.textPrimary
        }
        Text {
            text: label
            font.pixelSize: Theme.fontSizeSm
            color: active ? PanelColors.onAccent : PanelColors.textPrimary
        }
    }

    MouseArea { anchors.fill: parent; onClicked: active = !active }
}
```

### Workspace Tags

```qml
Repeater {
    model: Hyprland.workspaces
    delegate: Rectangle {
        required property var modelData
        property bool isActive: modelData.id === Hyprland.focusedMonitor.activeWorkspace.id

        height: Theme.pillHeight
        radius: Theme.radiusMd
        color: isActive
            ? PanelColors.workspaceActive          // solid accent
            : PanelColors.workspaceEmpty           // dark surface pill

        Text {
            anchors.centerIn: parent
            text: modelData.id
            font.pixelSize: Theme.fontSizeSm
            color: isActive ? PanelColors.onAccent : PanelColors.pillForeground
        }
    }
}
```

### Stat Ring (CPU / RAM / GPU)

Circular arc progress with label underneath.

```qml
// StatRing.qml
import QtQuick
import QtQuick.Shapes

Item {
    property string label: "CPU"
    property real value: 0.0   // 0.0 – 1.0
    property color ringColor: Qt.color(PanelColors.accent)

    width: 56; height: 68

    Shape {
        anchors.centerIn: parent
        width: 48; height: 48

        ShapePath {
            strokeWidth: 4
            strokeColor: Qt.rgba(ringColor.r, ringColor.g, ringColor.b, 0.25)
            fillColor: "transparent"
            PathAngleArc { centerX: 24; centerY: 24; radiusX: 22; radiusY: 22
                           startAngle: 0; sweepAngle: 360 }
        }
        ShapePath {
            strokeWidth: 4
            strokeColor: ringColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: 24; centerY: 24; radiusX: 22; radiusY: 22
                           startAngle: -90; sweepAngle: 360 * value }
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: label
        font.pixelSize: Theme.fontSizeXs
        color: PanelColors.textMuted
    }
}
```

### Notification Card

Each notification is a card with: app name + timestamp in the header, title,
body text, and a dismiss ×.

```
┌──────────────────────────────┐
│ app-name           23:40  ×  │  ← textMuted + dismiss button
│ title                        │  ← textPrimary, fontWeightBold
│ body text that wraps across  │  ← textMuted, wrapping
│ multiple lines naturally     │
│                 ~ Collapse   │  ← if body > ~3 lines
└──────────────────────────────┘
```

- Background: `panelBackground` at `opacityDropdown` (0.85) — slightly more
  opaque than cards so it reads when floating bottom-right over the wallpaper.
- Left border accent: 2px `accent` color strip on the left edge.
- Collapse/expand: `clip: true` + `Behavior on height { NumberAnimation {} }`

### MPRIS Player Card

```
┌──────────────────────────────────┐
│ [art]  Track Title               │  ← art 48×48 radiusSm, textPrimary bold
│        Artist Name               │  ← textMuted
│        ● Spotify                 │  ← small dot accent color + textMuted
│        ───────●────────────────  │  ← progress bar, accent fill, 4px height
│        2:09              4:32    │  ← textMuted fontSizeXs
│   ⇌  ⏮  ⏸  ⏭  ↺            │  ← icon buttons, textPrimary, hover → accent
└──────────────────────────────────┘
```

- Progress bar track: `borderSubtle` at 20% opacity; fill: `accent`.
- Control buttons: icon-only, `textPrimary` default, `accent` on hover.
- Source badge dot color: `accent`.

### Pipewire Audio Dropdown

Two sections (Output / Input) as labeled lists. Active device row uses solid
`accent` fill with `onAccent` text. Inactive rows use `dropdownBackground`.
Volume/mic sliders at the bottom: track `borderSubtle`, fill `accent`,
thumb circle `accent`.

```qml
Rectangle {
    property bool isActive: false
    height: 36; radius: Theme.radiusMd
    color: isActive ? PanelColors.accent : PanelColors.dropdownBackground

    Text {
        anchors { left: parent.left; leftMargin: Theme.spacingSm; verticalCenter: parent.verticalCenter }
        text: deviceName
        color: isActive ? PanelColors.onAccent : PanelColors.textPrimary
        font.pixelSize: Theme.fontSizeSm
    }
}
```

### Wifi / Network List

Each network row: signal icon | SSID | lock icon (if secured) | strength %.
Active network: solid `accent` fill + `onAccent` text (same pattern as audio
device above). Inactive rows: `dropdownBackground`. Scanning row: spinner glyph
with `NumberAnimation on rotation`.

### App Launcher Row

Full-width rows, icon (20px) + name, `panelBackground` default. Hover/selected
row uses `accent` at full opacity with `onAccent` text.

### Volume / Brightness OSD Slider

Thin track (4px height), rounded ends, `accent` fill, `borderSubtle` track.
Label (icon) left, value right. Whole component at `pillHeight` (28px).

```qml
Rectangle {
    height: 4; radius: Theme.radiusFull
    color: Qt.rgba(Qt.color(PanelColors.border).r,
                   Qt.color(PanelColors.border).g,
                   Qt.color(PanelColors.border).b, 0.20)

    Rectangle {
        width: parent.width * value
        height: parent.height; radius: parent.radius
        color: PanelColors.accent
    }
}
```

### Power Mode Selector

Vertical list of three options (Power Saver / Balanced / Performance) in a
dropdown card. Active option: solid `tertiary` fill + `onTertiary` text
(warm peach — visually distinct from the pink primary accent).
Inactive: `dropdownBackground`.

### Calendar Dropdown

Month/year header with `<` `>` nav arrows in `textMuted`. Day-of-week headers
in `textMuted`. Date cells plain `textPrimary`. Today's date: `accent` fill
circle, `onAccent` text. Selected date: `accentSubtle` fill.

### Clipboard History

Search bar at top: `dropdownBackground` fill, `border` outline, `textPrimary`
input text, `textMuted` placeholder. Each entry is a row — text entries show
one line truncated, image entries show a small thumbnail. Selected/active row:
`accentSubtle` left border (2px) + slightly lighter background. Delete button
`error` color on hover.

---

## Top Bar Layout

`PanelWindow` anchored top, full width, `exclusionMode: ExclusionMode.Exclusive`.
Three zones in a `RowLayout`:

```
[ arch pill | workspace pills ]  [ clock | media pill ]  [ tray | audio | battery | network | … ]
```

- Bar background: `barBackground` at `opacityBar` (0.75).
- All pills at `pillHeight` (28px), `radiusMd` (10px).
- Left zone: arch pill (`pillArch`/`pillTextArch`), then workspace pills.
- Center zone: clock pill (`pillClock`/`pillTextClock`), media pill when playing.
- Right zone: tray icons, then stat pills each with their own color token.
- Spacing between pills: `spacingXs` (4px).

## Taskbar / Dock

`PanelWindow` anchored bottom, centered (no left/right anchor). App icons in a
`Row`, `spacingSm` (8px) gap. Active app: small `accent` dot indicator below
the icon. Hover: icon brightens slightly (`opacity: 0.85` → `1.0`).

---

## Animation Durations

| Property | Value | Use |
|---|---|---|
| `durationFast` | 120ms | hover states, opacity flicks |
| `durationNormal` | 200ms | panel open/close, color transitions |
| `durationSlow` | 350ms | notification slide-in, launcher fade |

Color transitions: wrap bindings in `Behavior on color { ColorAnimation { duration: PanelColors.transitionDuration } }`.

---

## Layer / Z-order

| Layer | Use |
|---|---|
| `WlrLayer.Background` | Wallpaper |
| `WlrLayer.Bottom` | Passive info panels (left column cards) |
| `WlrLayer.Top` | Bar, dock, active popups |
| `WlrLayer.Overlay` | Notifications, launcher, lock screen |