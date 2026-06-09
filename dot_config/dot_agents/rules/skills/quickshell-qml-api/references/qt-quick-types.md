# Qt Quick QML Types Reference

For use alongside the Quickshell skill. Covers the `QtQuick` module types most relevant to building desktop shell components.

Import with: `import QtQuick`

Source: https://doc.qt.io/qt-6/qtquick-qmlmodule.html (Qt 6.11)

---

## Notation

- *(readonly)* — cannot be assigned; bind with `on<Prop>Changed`
- *(default)* — property receives unnamed children (e.g. `data` on Item)
- `since X.Y` — minimum Qt version

---

## Item — the universal base

Every visual type inherits from `Item`. All properties below are available on `Rectangle`, `Text`, `MouseArea`, etc.

**Geometry:**
- `x`, `y` : `real` — position relative to parent
- `width`, `height` : `real`
- `implicitWidth`, `implicitHeight` : `real` — natural size hint; set this on custom components
- `z` : `real` — stacking order within parent (higher = on top)

**Anchors** (all `anchors.*`):
- `anchors.fill` : `Item` — stretch to fill another item; use `anchors.fill: parent` constantly
- `anchors.centerIn` : `Item`
- `anchors.top/bottom/left/right` : `AnchorLine`
- `anchors.horizontalCenter`, `anchors.verticalCenter` : `AnchorLine`
- `anchors.margins` : `real` — applies to all sides
- `anchors.topMargin`, `anchors.bottomMargin`, `anchors.leftMargin`, `anchors.rightMargin` : `real`

**Appearance:**
- `visible` : `bool` — hides item and all children from rendering; still occupies space
- `opacity` : `real` — 0.0–1.0; affects item and children
- `clip` : `bool` — clip children to this item's bounding box
- `smooth` : `bool` — smooth sampling on scaled items (default: `true`)
- `antialiasing` : `bool`
- `rotation` : `real` — degrees clockwise
- `scale` : `real` — uniform scale factor
- `transformOrigin` : `enumeration` — pivot for rotation/scale (`Item.Center`, `Item.TopLeft`, …)
- `transform` : `list<Transform>` *(readonly)* — list of `Rotation`, `Scale`, `Translate` transforms

**Focus & Input:**
- `focus` : `bool` — request focus within a focus scope
- `activeFocus` : `bool` *(readonly)* — true when item actually has active focus
- `activeFocusOnTab` : `bool`
- `enabled` : `bool` — disables input events on item and children

**Tree:**
- `parent` : `Item`
- `children` : `list<Item>` *(readonly)*
- `childrenRect` : group *(readonly)* — bounding rect of all children (`x`, `y`, `width`, `height`)
- `data` : `list<QtObject>` *(default)* — items placed directly inside this item land here
- `states` : `list<State>`
- `transitions` : `list<Transition>`
- `state` : `string` — current state name

**Signals:**
- `Component.onCompleted` — fires after the component is fully created (use for init logic)
- `Component.onDestruction` — fires just before destruction

**Functions:**
- `mapToItem(item, x, y)` / `mapFromItem(item, x, y)` — coordinate mapping
- `grabToImage(callback, targetSize)` — capture to image
- `contains(point)` — hit test

---

## Rectangle

Inherits `Item`. Paints a filled rectangle with optional border and rounded corners.

**Properties:**
- `color` : `color` — fill color; default white. Use `"transparent"` for no fill.
- `radius` : `real` — corner radius; applies to all corners
- `topLeftRadius`, `topRightRadius`, `bottomLeftRadius`, `bottomRightRadius` : `real` *(since 6.7)* — per-corner radius; overrides `radius`; set to `0` for a sharp corner, `undefined` to revert to `radius`
- `gradient` : `var` — a `Gradient` object or a `QGradient.Preset` enum value; overrides `color` if set
- `border.width` : `int` — border thickness; use 0 for no border
- `border.color` : `color`
- `border.pixelAligned` : `bool` — rounds border width to whole pixels (default: `true`)
- `antialiasing` : `bool` — recommended when `radius > 0`

**Quick patterns:**
```qml
// Pill-shaped tag
Rectangle {
    color: "#3B82F6"; radius: height / 2
    width: label.implicitWidth + 16; height: 22
    Text { id: label; anchors.centerIn: parent; text: "tag"; color: "white" }
}

// Border-only box
Rectangle { color: "transparent"; border.color: "#555"; border.width: 1 }

// Gradient bar
Rectangle {
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: "#1e3a5f" }
        GradientStop { position: 1.0; color: "#0ea5e9" }
    }
}
```

---

## Text

Inherits `Item`. Renders plain or rich (HTML/Markdown) text. Read-only; for editable text use `TextInput` or `TextEdit`.

**Properties (key):**
- `text` : `string`
- `color` : `color`
- `font.family` : `string`
- `font.pixelSize` : `int` — preferred over `pointSize` in shell UIs (pixel-precise)
- `font.pointSize` : `real`
- `font.bold` : `bool`
- `font.italic` : `bool`
- `font.weight` : `int` — 100–900 (400 = normal, 700 = bold)
- `font.letterSpacing` : `real`
- `font.wordSpacing` : `real`
- `font.styleName` : `string` — e.g. `"Regular"`, `"SemiBold"` (prefer over bold/italic flags)
- `horizontalAlignment` : `enumeration` — `Text.AlignLeft`, `Text.AlignHCenter`, `Text.AlignRight`, `Text.AlignJustify`
- `verticalAlignment` : `enumeration` — `Text.AlignTop`, `Text.AlignVCenter`, `Text.AlignBottom`
- `wrapMode` : `enumeration` — `Text.NoWrap` (default), `Text.WordWrap`, `Text.WrapAnywhere`, `Text.Wrap`
- `elide` : `enumeration` — `Text.ElideNone`, `Text.ElideLeft`, `Text.ElideMiddle`, `Text.ElideRight` — requires explicit `width`
- `maximumLineCount` : `int`
- `textFormat` : `enumeration` — `Text.AutoText` (default), `Text.PlainText`, `Text.StyledText`, `Text.RichText`, `Text.MarkdownText`; set `PlainText` for untrusted content
- `renderType` : `enumeration` — `Text.QtRendering` (default), `Text.NativeRendering` (sharper at native size, no transforms)
- `lineHeight` : `real`
- `padding`, `topPadding`, `bottomPadding`, `leftPadding`, `rightPadding` : `real`
- `contentWidth`, `contentHeight` : `real` *(readonly)* — natural size of the laid-out text
- `truncated` : `bool` *(readonly)* — true when elide kicks in
- `fontSizeMode` : `enumeration` — `Text.FixedSize`, `Text.HorizontalFit`, `Text.VerticalFit`, `Text.Fit` — auto-shrink to fit bounds
- `style` : `enumeration` — `Text.Normal`, `Text.Outline`, `Text.Raised`, `Text.Sunken`
- `styleColor` : `color` — shadow/outline color for `style`

**Signals:**
- `linkActivated(string link)` — user clicked a hyperlink in rich text
- `linkHovered(string link)`

**Functions:**
- `forceLayout()` — force re-layout immediately

---

## Image

Inherits `Item`. Displays a raster or SVG image from a URL.

**Properties:**
- `source` : `url` — file path (`"file:///…"`, `"qrc:/…"`) or `""` for none
- `fillMode` : `enumeration`
  - `Image.Stretch` (default) — stretches to item size
  - `Image.PreserveAspectFit` — fits inside, letterboxed
  - `Image.PreserveAspectCrop` — fills, cropped
  - `Image.Tile`, `Image.TileVertically`, `Image.TileHorizontally`
  - `Image.Pad` — no scaling
- `sourceSize` : `size` — request a specific decode size; critical for SVG and large images to control memory
- `smooth` : `bool` — bilinear filtering (default: `true`)
- `mipmap` : `bool` — mipmap for downscaled images
- `asynchronous` : `bool` — load in background thread
- `cache` : `bool` — cache decoded image (default: `true`)
- `status` : `enumeration` *(readonly)* — `Image.Null`, `Image.Ready`, `Image.Loading`, `Image.Error`
- `progress` : `real` *(readonly)* — 0.0–1.0 loading progress
- `paintedWidth`, `paintedHeight` : `real` *(readonly)* — actual rendered dimensions respecting fillMode
- `horizontalAlignment`, `verticalAlignment` : `enumeration` — `Image.AlignLeft`/`AlignHCenter`/`AlignRight`, `Image.AlignTop`/`AlignVCenter`/`AlignBottom`
- `mirror` : `bool` — flip horizontally
- `mirrorVertically` : `bool` *(since 6.2)*

---

## MouseArea

Inherits `Item`. Invisible hit area that catches pointer events.

**Properties:**
- `enabled` : `bool` — disable to pass events through
- `hoverEnabled` : `bool` — track mouse position without button press; required for `containsMouse` updates and `entered`/`exited`/`positionChanged`
- `acceptedButtons` : `Qt::MouseButtons` — default `Qt.LeftButton`; combine with `|`: `Qt.LeftButton | Qt.RightButton`
- `containsMouse` : `bool` *(readonly)*
- `containsPress` : `bool` *(readonly)* — shorthand for `pressed && containsMouse`
- `pressed` : `bool` *(readonly)*
- `pressedButtons` : `MouseButtons` *(readonly)* — which buttons are held
- `mouseX`, `mouseY` : `real` *(readonly)* — cursor position relative to MouseArea
- `cursorShape` : `Qt::CursorShape` — `Qt.PointingHandCursor`, `Qt.ArrowCursor`, `Qt.IBeamCursor`, etc.
- `preventStealing` : `bool` — prevent parent Flickable from stealing touch
- `propagateComposedEvents` : `bool` — let click/doubleClick events propagate to overlapping MouseAreas
- `pressAndHoldInterval` : `int` — ms before `pressAndHold` fires (default: platform value)
- `drag.target` : `Item` — item to drag
- `drag.axis` : `enumeration` — `Drag.XAxis`, `Drag.YAxis`, `Drag.XAndYAxis`
- `drag.minimumX/maximumX/minimumY/maximumY` : `real`

**Signals** (use `on<Signal>:` handlers):
- `clicked(MouseEvent mouse)` — `mouse.button`, `mouse.modifiers`, `mouse.x`, `mouse.y`
- `doubleClicked(MouseEvent mouse)`
- `pressed(MouseEvent mouse)` / `released(MouseEvent mouse)`
- `pressAndHold(MouseEvent mouse)`
- `wheel(WheelEvent wheel)` — `wheel.angleDelta.y` for scroll amount
- `entered()` / `exited()` — requires `hoverEnabled: true`
- `positionChanged(MouseEvent mouse)` — requires `hoverEnabled: true` for non-pressed tracking

**Detecting right-click:**
```qml
MouseArea {
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: (mouse) => {
        if (mouse.button === Qt.RightButton) contextMenu.open()
        else activate()
    }
}
```

---

## Repeater

Inherits `Item`. Instantiates `delegate` once per item in `model`. All instances are inserted as siblings of the Repeater inside its parent (not children of the Repeater itself).

**Properties:**
- `model` : `var` — integer count, JS array, `ListModel`, or any QAbstractListModel
- `delegate` : `Component` *(default)* — template for each instance; has `index` in scope, plus model roles
- `count` : `int` *(readonly)*

**Signals:**
- `itemAdded(int index, Item item)`
- `itemRemoved(int index, Item item)`

**Functions:**
- `itemAt(index)` : `Item` — returns instantiated delegate at index, or null

**Notes:**
- All items created upfront — for large/scrolling lists use `ListView` instead.
- Must be inside a positioner (`Row`, `Column`, `Grid`) or layout to visually arrange items.
- Use `required property var modelData` in Qt 6 delegates for strict mode.

```qml
Row {
    spacing: 6
    Repeater {
        model: ["cpu", "ram", "net"]
        delegate: Text {
            required property string modelData
            text: modelData.toUpperCase()
        }
    }
}
```

---

## ListView

Inherits `Flickable`. Virtualised list — only creates delegates in view. Use for long lists.

**Key Properties:**
- `model` : `model`
- `delegate` : `Component` *(default)*
- `orientation` : `enumeration` — `ListView.Vertical` (default), `ListView.Horizontal`
- `spacing` : `real` — gap between delegates
- `count` : `int` *(readonly)*
- `currentIndex` : `int` — selected item index
- `currentItem` : `Item` *(readonly)*
- `header`, `footer` : `Component` — components prepended/appended outside the list
- `headerItem`, `footerItem` : `Item` *(readonly)*
- `headerPositioning`, `footerPositioning` : `enumeration` — `ListView.InlineHeader`, `ListView.OverlayHeader`, `ListView.PullBackHeader`
- `cacheBuffer` : `int` — pixels outside viewport to keep loaded
- `clip` : `bool` — inherit from Item; usually set `true` on ListView
- `snapMode` : `enumeration` — `ListView.NoSnap`, `ListView.SnapToItem`, `ListView.SnapOneItem`
- `highlight` : `Component` — drawn under the current item
- `highlightFollowsCurrentItem` : `bool`
- `keyNavigationWraps` : `bool`
- `section.property` : `string` — group by this model property
- `section.delegate` : `Component` — header shown for each section

**Attached to delegates:**
- `ListView.isCurrentItem` : `bool`
- `ListView.view` : `ListView`
- `ListView.delayRemove` : `bool` — hold item alive during remove animation

**Functions:**
- `positionViewAtIndex(index, mode)` — `ListView.Beginning`, `ListView.Center`, `ListView.End`, `ListView.Visible`, `ListView.Contain`
- `positionViewAtBeginning()` / `positionViewAtEnd()`
- `indexAt(x, y)`, `itemAt(x, y)`, `itemAtIndex(index)`
- `forceLayout()`
- `incrementCurrentIndex()` / `decrementCurrentIndex()`

---

## Loader

Inherits `Item`. Dynamically loads a QML component from a URL or Component on demand. Destroys old content when source changes. Sizes to loaded item by default.

**Properties:**
- `source` : `url` — QML file to load; set to `""` to unload
- `sourceComponent` : `Component` — inline component; set to `undefined` to unload
- `active` : `bool` — when `false`, pauses loading; unloads current item (default: `true`)
- `asynchronous` : `bool` — load in background thread to avoid frame stutter
- `item` : `QtObject` *(readonly)* — the loaded object (null until loaded)
- `status` : `enumeration` *(readonly)* — `Loader.Null`, `Loader.Ready`, `Loader.Loading`, `Loader.Error`
- `progress` : `real` *(readonly)*

**Signals:**
- `loaded()` — fires when `item` becomes available

**Functions:**
- `setSource(url, properties)` — load with initial property values

**Notes:**
- Set properties on Loader before source to pass them into the loaded component.
- Use `Connections { target: loader.item }` to receive signals from the loaded object.
- `active: false` is the idiomatic way to toggle expensive components (popups, overlays).

```qml
Loader {
    id: popup
    active: false
    source: "CalendarPopup.qml"
    onLoaded: item.open()
}
// Show popup:
popup.active = true
```

---

## Behavior

Defines a default animation that runs whenever a specified property changes value. Applied with `Behavior on <property> { }`.

**Properties:**
- `animation` : `Animation` *(default)* — the animation to run
- `enabled` : `bool` — toggle the behavior on/off (default: `true`)

```qml
Rectangle {
    color: active ? "#3B82F6" : "#1e293b"
    Behavior on color { ColorAnimation { duration: 150 } }

    width: expanded ? 200 : 80
    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
}
```

> A `Transition` on state change overrides a `Behavior` for that change. One `Behavior` per property only; wrap multiple animations in `SequentialAnimation` or `ParallelAnimation`.

---

## Animation types

All animations share these base properties:
- `duration` : `int` — milliseconds
- `easing.type` : `enumeration` — see Easing table below
- `easing.amplitude`, `easing.overshoot`, `easing.period` : `real` — for elastic/bounce easings
- `loops` : `int` — `Animation.Infinite` for looping
- `running` : `bool` — start/stop imperatively
- `paused` : `bool`
- `alwaysRunToEnd` : `bool`

**Signals:**
- `started()`, `stopped()`, `finished()`

**Functions:**
- `start()`, `stop()`, `pause()`, `resume()`, `restart()`
- `complete()` — jump to end state

### NumberAnimation
Animates `real`/`int` values.
- `from`, `to` : `real` — explicit values; omit to animate from/to current
- `properties` : `string` — comma-separated list of property names to animate (e.g. `"x,y"`)
- `target` : `Item`

### ColorAnimation
Animates `color` values. Same `from`/`to`/`properties` pattern.

### PropertyAnimation
Base type; animates any interpolatable property.

### SequentialAnimation
Runs child animations one after another.

### ParallelAnimation
Runs child animations simultaneously.

### ScriptAction
Runs a JS snippet at a point in an animation sequence.
- `script` : `script` — JS to execute

### PauseAnimation
Inserts a delay in a sequence.
- `duration` : `int`

### Transition
Applied between states — attach to `Item.transitions`:
- `from`, `to` : `string` — state names; `"*"` matches any
- `reversible` : `bool`

### Common easing types
| Enum | Curve |
|---|---|
| `Easing.Linear` | Constant speed |
| `Easing.InOutCubic` | Smooth start and end |
| `Easing.OutCubic` | Fast start, slow end |
| `Easing.InCubic` | Slow start, fast end |
| `Easing.OutQuart` / `OutQuint` | More aggressive deceleration |
| `Easing.OutBounce` | Bounces at end |
| `Easing.OutElastic` | Overshoot with spring |
| `Easing.InOutQuad` | Gentle S-curve |

---

## State / States

Represent configurations of properties; switch with `state: "name"`.

**State properties:**
- `name` : `string`
- `when` : `bool` — condition-based auto-switching
- `PropertyChanges { target: item; prop: value }` — change values in state
- `AnchorChanges { target: item; anchors.top: … }` — change anchors in state

```qml
Item {
    states: [
        State {
            name: "active"
            when: isActive
            PropertyChanges { target: highlight; opacity: 1 }
            PropertyChanges { target: label; color: "white" }
        }
    ]
    transitions: [
        Transition {
            from: ""; to: "active"
            NumberAnimation { property: "opacity"; duration: 150 }
        }
    ]
}
```

---

## Row / Column / Grid / Flow — positioners

Simple positioners that arrange children automatically. Children do not need explicit x/y.

**Shared properties:**
- `spacing` : `real` — gap between items
- `padding`, `topPadding`, etc. : `real`
- `layoutDirection` : `enumeration` — `Qt.LeftToRight` / `Qt.RightToLeft`
- `add`, `move` : `Transition` — animate items added/moved

**Row** — horizontal
- `spacing` is the main knob

**Column** — vertical

**Grid** — rows × columns
- `columns` : `int` — if set, rows calculated automatically
- `rows` : `int`
- `columnSpacing`, `rowSpacing` : `real` *(since 5.6)*
- `horizontalItemAlignment`, `verticalItemAlignment` : `enumeration`
- `flow` : `enumeration` — `Grid.LeftToRight` (default), `Grid.TopToBottom`

**Flow** — wraps onto new rows/columns
- `flow` : `enumeration` — `Flow.LeftToRight`, `Flow.TopToBottom`

> Positioners are for static or simply-modelled lists. For model-driven content use `Repeater` (inside a positioner) or `ListView`.

---

## Timer

Non-visual. Fires `triggered()` after `interval` ms.

**Properties:**
- `interval` : `int` — ms (default: 1000)
- `repeat` : `bool` — fire repeatedly (default: `false`)
- `running` : `bool` — start/stop
- `triggeredOnStart` : `bool` — fire immediately when started

**Signals:**
- `triggered()`

**Functions:**
- `start()`, `stop()`, `restart()`

```qml
Timer {
    interval: 1000; repeat: true; running: true
    onTriggered: clock.update()
}
```

---

## Connections

Connects to signals of a `target` object — safe to use even when the target changes or is null.

**Properties:**
- `target` : `Object`
- `enabled` : `bool`
- `ignoreUnknownSignals` : `bool` — suppress warnings for signals that don't exist (useful during init)

```qml
Connections {
    target: Hyprland
    function onFocusedMonitorChanged() { bar.update() }
    function onActiveWindowChanged() { titleLabel.text = Hyprland.activeWindow?.title ?? "" }
}
```

---

## FontLoader

Loads a font from a file or URL, making it available as `font.family`.

**Properties:**
- `source` : `url` — path to font file
- `name` : `string` *(readonly)* — resolved family name to use in `font.family`
- `status` : `enumeration` *(readonly)* — `FontLoader.Null`, `FontLoader.Ready`, `FontLoader.Loading`, `FontLoader.Error`

```qml
FontLoader { id: icons; source: "qrc:/fonts/MaterialIcons.ttf" }
Text { font.family: icons.name; text: "\uE88A" }  // icon glyph
```

---

## Keys / Shortcut

### Keys (attached to any Item)
Attach to any item that has `focus: true` or `activeFocus`.

```qml
Item {
    focus: true
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) close()
        event.accepted = true  // stop propagation
    }
    Keys.onReturnPressed: submit()
}
```

### Shortcut
Global keyboard shortcut — fires even without focus.

**Properties:**
- `sequence` : `keysequence` — e.g. `"Ctrl+K"`, `StandardKey.Copy`
- `enabled` : `bool`
- `autoRepeat` : `bool`
- `context` : `enumeration` — `Qt.WindowShortcut` (default), `Qt.ApplicationShortcut`

**Signals:**
- `activated()`
- `activatedAmbiguously()`

---

## Canvas

HTML5-style 2D drawing surface via JavaScript. Useful for custom graphs or sparklines in shell widgets.

**Properties:**
- `width`, `height` : `real`
- `renderTarget` : `enumeration` — `Canvas.Image` (default), `Canvas.FramebufferObject`
- `renderStrategy` : `enumeration` — `Canvas.Immediate`, `Canvas.Threaded`, `Canvas.Cooperative`
- `canvasSize` : `size`
- `available` : `bool` *(readonly)*

**Signals:**
- `paint(rect region)` — redraw handler; called when `requestPaint()` is invoked

**Functions:**
- `requestPaint()` — schedule a repaint
- `getContext("2d")` — returns `Context2D` for drawing

```qml
Canvas {
    width: 100; height: 40
    onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        ctx.strokeStyle = "#3B82F6"
        ctx.lineWidth = 2
        ctx.beginPath()
        for (let i = 0; i < data.length; i++) {
            const x = i * (width / data.length)
            const y = height - (data[i] * height)
            i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y)
        }
        ctx.stroke()
    }
}
```

---

## Value types

These are not components but types used in property values.

| Type | Usage |
|---|---|
| `color` | `"#rrggbb"`, `"#aarrggbb"`, named SVG colors (`"transparent"`, `"white"`, …), `Qt.rgba(r,g,b,a)` |
| `font` | Group property on Text/TextInput — access via `font.family`, `font.pixelSize`, etc. |
| `size` | `Qt.size(w, h)` |
| `rect` | `Qt.rect(x, y, w, h)` |
| `point` | `Qt.point(x, y)` |
| `vector2d` | `Qt.vector2d(x, y)` — also returned by some pointer events |

---

## Submodules (separate imports)

| Import | Contains |
|---|---|
| `import QtQuick.Layouts` | `RowLayout`, `ColumnLayout`, `GridLayout`, `StackLayout` — flexible size-aware layouts |
| `import QtQuick.Controls` | `Button`, `Slider`, `Switch`, `ScrollView`, `Popup`, `Menu`, `ToolTip`, etc. |
| `import QtQuick.Controls.Material` | Material style for Controls |

### QtQuick.Layouts quick-reference

All items in a layout get `Layout.*` attached properties:

- `Layout.fillWidth` / `Layout.fillHeight` : `bool` — stretch to fill available space
- `Layout.preferredWidth` / `Layout.preferredHeight` : `real`
- `Layout.minimumWidth` / `Layout.minimumHeight` : `real`
- `Layout.maximumWidth` / `Layout.maximumHeight` : `real`
- `Layout.alignment` : `enumeration` — `Qt.AlignLeft`, `Qt.AlignVCenter`, etc.
- `Layout.margins`, `Layout.topMargin`, etc. : `real`
- `Layout.columnSpan`, `Layout.rowSpan` : `int` — for GridLayout only

**RowLayout / ColumnLayout:** like Row/Column but respects implicit and min/max sizes, and can redistribute space.

**GridLayout:**
- `columns` or `rows` : `int`
- `columnSpacing`, `rowSpacing` : `real`
- `flow` : `enumeration`

---

## Common gotchas

- **Anchors vs Layouts:** Do not mix anchors and Layout attached properties on the same item — pick one system.
- **`visible: false` vs `opacity: 0`:** Invisible items still exist and handle `Component.onCompleted`; they just don't render. Opacity-zero items still receive mouse events unless `enabled: false`.
- **`clip: true` cost:** Clipping introduces an extra render pass. Only clip when necessary.
- **`implicitWidth/Height`:** Always set these on reusable components so parent positioners/layouts can size them correctly.
- **`id` scope:** IDs are file-scoped — visible anywhere in the same QML file.
- **`required property`:** Qt 6 strict mode. Delegates accessed via Repeater/ListView models should declare `required property var modelData` (or the specific role type) to avoid the deprecated implicit context property.
- **`Component.onCompleted` timing:** Fires bottom-up — child components complete before parents.
- **Anchor loops:** Setting `anchors.top` on an item whose height depends on that anchor causes a binding loop warning. Use `height` explicitly instead.