# Quickshell v0.3.0 QML API Reference

Extracted from source: https://github.com/quickshell-mirror/quickshell

---

## Quickshell

### AwfulMap
**Module:** `Quickshell`

---

### BoundComponent
**Module:** `Quickshell`
**Inherits:** `QQuickItem`

Component loader that allows setting initial properties.
Component loader that allows setting initial properties, primarily useful for
escaping cyclic dependency errors.

Properties defined on the BoundComponent will be applied to its loaded component,
including required properties, and will remain reactive. Functions created with
the names of signal handlers will also be attached to signals of the loaded component.

```qml {filename="MyComponent.qml"}
MouseArea {
required property color color;
width: 100
height: 100

Rectangle {
anchors.fill: parent
color: parent.color
}
}
```

```qml
BoundComponent {
source: "MyComponent.qml"

// this is the same as assigning to `color` on MyComponent if loaded normally.
property color color: "red";

// this will be triggered when the `clicked` signal from the MouseArea is sent.
function onClicked() {
color = "blue";
}
}
```

**Properties:**
- `item` : `QObject*` — The loaded component. Will be null until it has finished loading.
- `sourceComponent` : `QQmlComponent*` — The source to load, as a Component.
- `source` : `QString` — The source to load, as a Url.
- `bindValues` : `bool` — If property values should be bound after they are initially set. Defaults to `true`.
- `implicitWidth` : `qreal`
- `implicitHeight` : `qreal`

**Signals:**
- `loaded()`
- `sourceComponentChanged()`
- `sourceChanged()`
- `bindValuesChanged()`
- `onComponentDestroyed()`
- `onIncubationCompleted()`
- `onIncubationFailed()`
- `updateSize()`

---

### ColorQuantizer
**Module:** `Quickshell`

Color Quantization Utility
A color quantization utility used for getting prevalent colors in an image, by
averaging out the image's color data recursively.

#### Example
```qml
ColorQuantizer {
id: colorQuantizer
source: Qt.resolvedUrl("./yourImage.png")
depth: 3 // Will produce 8 colors (2³)
rescaleSize: 64 // Rescale to 64x64 for faster processing
}
```

**Properties:**
- `colors` : `QList<QColor>` — Access the colors resulting from the color quantization performed.
> [!NOTE] The amount of colors returned from the quantization is determined by
> the property depth, specifically 2ⁿ where n is the depth.
- `source` : `QUrl` — Path to the image you'd like to run the color quantization on.
- `depth` : `qreal` — Max depth for the color quantization. Each level of depth represents another
binary split of the color space
- `imageRect` : `QRect` — Rectangle that the source image is cropped to.

Can be set to `undefined` to reset.
- `rescaleSize` : `qreal` — The size to rescale the image to, when rescaleSize is 0 then no scaling will be done.
> [!NOTE] Results from color quantization doesn't suffer much when rescaling, it's
> recommended to rescale, otherwise the quantization process will take much longer.

**Signals:**
- `colorsChanged()`
- `sourceChanged()`
- `depthChanged()`
- `imageRectChanged()`
- `rescaleSizeChanged()`
- `operationFinished(const QList<QColor>& result)`

---

### ColorQuantizerOperation
**Module:** `Quickshell`

**Signals:**
- `done(QList<QColor> colors)`
- `finished()`
- `quantizeImage(const QAtomicInteger<bool>& shouldCancel = false)`

---

### DesktopAction
**Module:** `Quickshell`
**Inherits:** `QObject`

An action of a @@DesktopEntry$.

**Properties:**
- `id` : `QString`
- `name` : `QString`
- `icon` : `QString`
- `execString` : `QString` — The raw `Exec` string from the action.

> [!WARNING] This cannot be reliably run as a command. See @@command for one you can run.
- `command` : `QVector<QString>` — The parsed `Exec` command in the action.

The entry can be run with @@execute(), or by using this command in
@@Quickshell.Quickshell.execDetached() or @@Quickshell.Io.Process.
If used in `execDetached` or a `Process`, @@DesktopEntry.workingDirectory should also be passed to
the invoked process.

> [!NOTE]	The provided command does not invoke a terminal even if @@runInTerminal is true.

**Functions:**
- `execute()` — Run the application. Currently ignores @@DesktopEntry.runInTerminal and field codes.

This is equivalent to calling @@Quickshell.Quickshell.execDetached() with @@command
and @@DesktopEntry.workingDirectory.

**Signals:**
- `nameChanged()`
- `iconChanged()`
- `execStringChanged()`
- `commandChanged()`

---

### DesktopEntries
**Module:** `Quickshell`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Desktop entry index.
Index of desktop entries according to the [desktop entry specification].

Primarily useful for looking up icons and metadata from an id, as there is
currently no mechanism for usage based sorting of entries and other launcher niceties.

[desktop entry specification]: https://specifications.freedesktop.org/desktop-entry-spec/latest/

**Properties:**
- `applications` : `UntypedObjectModel*`

**Signals:**
- `applicationsChanged()`

---

### DesktopEntry
**Module:** `Quickshell`
**Inherits:** `QObject`

A desktop entry. See @@DesktopEntries for details.

**Properties:**
- `id` : `QString`
- `name` : `QString` — Name of the specific application, such as "Firefox".
- `genericName` : `QString` — Short description of the application, such as "Web Browser". May be empty.
- `startupClass` : `QString` — Initial class or app id the app intends to use. May be useful for matching running apps
to desktop entries.
- `noDisplay` : `bool` — If true, this application should not be displayed in menus and launchers.
- `comment` : `QString` — Long description of the application, such as "View websites on the internet". May be empty.
- `icon` : `QString` — Name of the icon associated with this application. May be empty.
- `execString` : `QString` — The raw `Exec` string from the desktop entry.

> [!WARNING] This cannot be reliably run as a command. See @@command for one you can run.
- `command` : `QVector<QString>` — The parsed `Exec` command in the desktop entry.

The entry can be run with @@execute(), or by using this command in
@@Quickshell.Quickshell.execDetached() or @@Quickshell.Io.Process.
If used in `execDetached` or a `Process`, @@workingDirectory should also be passed to
the invoked process. See @@execute() for details.

> [!NOTE]	The provided command does not invoke a terminal even if @@runInTerminal is true.
- `workingDirectory` : `QString` — The working directory to execute from.
- `runInTerminal` : `bool` — If the application should run in a terminal.
- `categories` : `QVector<QString>`
- `keywords` : `QVector<QString>`
- `actions` : `QVector<DesktopAction*>`

**Functions:**
- `execute()` — Run the application. Currently ignores @@runInTerminal and field codes.

This is equivalent to calling @@Quickshell.Quickshell.execDetached() with @@command
and @@DesktopEntry.workingDirectory as shown below:

```qml
Quickshell.execDetached({
command: desktopEntry.command,
workingDirectory: desktopEntry.workingDirectory,
});
```

**Signals:**
- `nameChanged()`
- `genericNameChanged()`
- `startupClassChanged()`
- `noDisplayChanged()`
- `commentChanged()`
- `iconChanged()`
- `execStringChanged()`
- `commandChanged()`
- `workingDirectoryChanged()`
- `runInTerminalChanged()`

---

### DesktopEntryManager
**Module:** `Quickshell`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

**Signals:**
- `applicationsChanged()`
- `handleFileChanges()`
- `onScanCompleted(const QList<ParsedDesktopEntryData>& scanResults)`

---

### EasingCurve
**Module:** `Quickshell`
**Inherits:** `QObject`

Easing curve.
Directly accessible easing curve as used in property animations.

**Properties:**
- `curve` : `QEasingCurve` — Easing curve settings. Works exactly the same as
[PropertyAnimation.easing](https://doc.qt.io/qt-6/qml-qtquick-propertyanimation.html#easing-prop).

**Signals:**
- `curveChanged()`

---

### Edges
**Module:** `Quickshell`

**Properties:**
- `left` : `qint32`
- `right` : `qint32`
- `top` : `qint32`
- `bottom` : `qint32`

---

### ElapsedTimer
**Module:** `Quickshell`
**Inherits:** `QObject`

Measures time between events
The ElapsedTimer measures time since its last restart, and is useful
for determining the time between events that don't supply it.

**Functions:**
- `elapsed()` — Return the number of seconds since the timer was last
started or restarted, with nanosecond precision.
- `restart()` — Restart the timer, returning the number of seconds since
the timer was last started or restarted, with nanosecond precision.
- `elapsedMs()` — Return the number of milliseconds since the timer was last
started or restarted.
- `restartMs()` — Restart the timer, returning the number of milliseconds since
the timer was last started or restarted.
- `elapsedNs()` — Return the number of nanoseconds since the timer was last
started or restarted.
- `restartNs()` — Restart the timer, returning the number of nanoseconds since
the timer was last started or restarted.

---

### LazyLoader
**Module:** `Quickshell`
**Inherits:** `Reloadable`

Asynchronous component loader.
The LazyLoader can be used to prepare components that don't need to be
created immediately, such as windows that aren't visible until triggered
by another action. It works on creating the component in the gaps between
frame rendering to prevent blocking the interface thread.
It can also be used to preserve memory by loading components only
when you need them and unloading them afterward.

Note that when reloading the UI due to changes, lazy loaders will always
load synchronously so windows can be reused.

#### Example
The following example creates a PopupWindow asynchronously as the bar loads.
This means the bar can be shown onscreen before the popup is ready, however
trying to show the popup before it has finished loading in the background
will cause the UI thread to block.

```qml
import QtQuick
import QtQuick.Controls
import Quickshell

ShellRoot {
PanelWindow {
id: window
height: 50

anchors {
bottom: true
left: true
right: true
}

LazyLoader {
id: popupLoader

// start loading immediately
loading: true

// this window will be loaded in the background during spare
// frame time unless active is set to true, where it will be
// loaded in the foreground
PopupWindow {
// position the popup above the button
parentWindow: window
relativeX: window.width / 2 - width / 2
relativeY: -height

// some heavy component here

width: 200
height: 200
}
}

Button {
anchors.centerIn: parent
text: "show popup"

// accessing popupLoader.item will force the loader to
// finish loading on the UI thread if it isn't finished yet.
onClicked: popupLoader.item.visible = !popupLoader.item.visible
}
}
}
```

> [!WARNING] Components that internally load other components must explicitly
> support asynchronous loading to avoid blocking.
>
> Notably, @@Variants does not corrently support asynchronous
> loading, meaning using it inside a LazyLoader will block similarly to not
> having a loader to start with.

**Properties:**
- `item` : `QObject*` — The fully loaded item if the loader is @@loading or @@active, or `null`
if neither @@loading nor @@active.

Note that the item is owned by the LazyLoader, and destroying the LazyLoader
will destroy the item.

> [!WARNING] If you access the `item` of a loader that is currently loading,
> it will block as if you had set `active` to true immediately beforehand.
>
> You can instead set @@loading and listen to @@activeChanged(s) signal to
> ensure loading happens asynchronously.
- `loading` : `bool` — If the loader is actively loading.

If the component is not loaded, setting this property to true will start
loading it asynchronously. If the component is already loaded, setting
this property has no effect.

See also: @@activeAsync.
- `active` : `bool` — If the component is fully loaded.

Setting this property to `true` will force the component to load to completion,
blocking the UI, and setting it to `false` will destroy the component, requiring
it to be loaded again.

See also: @@activeAsync.
- `activeAsync` : `bool` — If the component is fully loaded.

Setting this property to true will asynchronously load the component similarly to
@@loading. Reading it or setting it to false will behanve
the same as @@active.
- `component` : `QQmlComponent*` — The component to load. Mutually exclusive to @@source.
- `source` : `QString` — The URI to load the component from. Mutually exclusive to @@component.

**Signals:**
- `activeChanged()`
- `loadingChanged()`
- `itemChanged()`
- `sourceChanged()`
- `componentChanged()`
- `onIncubationCompleted()`
- `onIncubationFailed()`
- `onComponentDestroyed()`

---

### ObjectModel
**Module:** `Quickshell`
**Inherits:** `QAbstractListModel`

View into a list of objets
Typed view into a list of objects.

An ObjectModel works as a QML [Data Model], allowing efficient interaction with
components that act on models. It has a single role named `modelData`, to match the
behavior of lists.
The same information contained in the list model is available as a normal list
via the `values` property.

#### Differences from a list
Unlike with a list, the following property binding will never be updated when `model[3]` changes.
```qml
// will not update reactively
property var foo: model[3]
```

You can work around this limitation using the @@values property of the model to view it as a list.
```qml
// will update reactively
property var foo: model.values[3]
```

[Data Model]: https://doc.qt.io/qt-6/qtquick-modelviewsdata-modelview.html#qml-data-models

**Properties:**
- `values` : `QList<QObject*>` — The content of the object model, as a QML list.
The values of this property will always be of the type of the model.

**Signals:**
- `valuesChanged()`
- `objectInsertedPre(QObject* object, qsizetype index)` — Sent immediately before an object is inserted into the list.
- `objectInsertedPost(QObject* object, qsizetype index)` — Sent immediately after an object is inserted into the list.
- `objectRemovedPre(QObject* object, qsizetype index)` — Sent immediately before an object is removed from the list.
- `objectRemovedPost(QObject* object, qsizetype index)` — Sent immediately after an object is removed from the list.

---

### ParsedDesktopEntryData
**Module:** `Quickshell`

---

### PersistentProperties
**Module:** `Quickshell`
**Inherits:** `Reloadable`

Object that holds properties that can persist across a config reload.
PersistentProperties holds properties declated in it across a reload, which is
often useful for things like keeping expandable popups open and styling them.

Below is an example of using `PersistentProperties` to keep track of the state
of an expandable panel. When the configuration is reloaded, the `expanderOpen` property
will be saved and the expandable panel will stay in the open/closed state.

```qml
PersistentProperties {
id: persist
reloadableId: "persistedStates"

property bool expanderOpen: false
}

Button {
id: expanderButton
anchors.centerIn: parent
text: "toggle expander"
onClicked: persist.expanderOpen = !persist.expanderOpen
}

Rectangle {
anchors.top: expanderButton.bottom
anchors.left: expanderButton.left
anchors.right: expanderButton.right
height: 100

color: "lightblue"
visible: persist.expanderOpen
}
```

**Signals:**
- `loaded()` — Called every time the reload stage completes.
Will be called every time, including when nothing was loaded from an old instance.
- `reloaded()` — Called every time the properties are reloaded.
Will not be called if no old instance was loaded.

---

### PopupAnchor
**Module:** `Quickshell`
**Inherits:** `QObject`

Anchorpoint or positioner for popup windows.

**Properties:**
- `window` : `QObject*` — The window to anchor / attach the popup to. Setting this property unsets @@item.
- `item` : `QQuickItem*` — The item to anchor / attach the popup to. Setting this property unsets @@window.

The popup's position relative to its parent window is only calculated when it is
initially shown (directly before @@anchoring(s) is emitted), meaning its anchor
rectangle will be set relative to the item's position in the window at that time.
@@updateAnchor() can be called to update the anchor rectangle if the item's position
has changed.

> [!NOTE] If a more flexible way to position a popup relative to an item is needed,
> set @@window to the item's parent window, and handle the @@anchoring signal to
> position the popup relative to the window's contentItem.
- `rect` : `Box` — The anchorpoints the popup will attach to, relative to @@item or @@window.
Which anchors will be used is determined by the @@edges, @@gravity, and @@adjustment.

If using @@item, the default anchor rectangle matches the dimensions of the item.

If you leave @@edges, @@gravity and @@adjustment at their default values,
setting more than `x` and `y` does not matter. The anchor rect cannot
be smaller than 1x1 pixels.

[coordinate mapping functions]: https://doc.qt.io/qt-6/qml-qtquick-item.html#mapFromItem-method
- `margins` : `Margins` — A margin applied to the anchor rect.

This is most useful when @@item is used and @@rect is left at its default
value (matching the Item's dimensions).
- `edges` : `Edges::Flags` — The point on the anchor rectangle the popup should anchor to.
Opposing edges suchs as `Edges.Left | Edges.Right` are not allowed.

Defaults to `Edges.Top | Edges.Left`.
- `gravity` : `Edges::Flags` — The direction the popup should expand towards, relative to the anchorpoint.
Opposing edges suchs as `Edges.Left | Edges.Right` are not allowed.

Defaults to `Edges.Bottom | Edges.Right`.
- `adjustment` : `PopupAdjustment::Flags` — The strategy used to adjust the popup's position if it would otherwise not fit on screen,
based on the anchor @@rect, preferred @@edges, and @@gravity.

See the documentation for @@PopupAdjustment for details.

**Functions:**
- `updateAnchor()` — Update the popup's anchor rect relative to its parent window.

If anchored to an item, popups anchors will not automatically follow
the item if its position changes. This function can be called to
recalculate the anchors.

**Signals:**
- `anchoring()` — Emitted when this anchor is about to be used. Mostly useful for modifying
the anchor @@rect using [coordinate mapping functions], which are not reactive.

[coordinate mapping functions]: https://doc.qt.io/qt-6/qml-qtquick-item.html#mapFromItem-method
- `windowChanged()`
- `itemChanged()`

---

### QsMenuAnchor
**Module:** `Quickshell`
**Inherits:** `QObject`

Display anchor for platform menus.

**Properties:**
- `anchor` : `PopupAnchor*` — The menu's anchor / positioner relative to another window. The menu will not be
shown until it has a valid anchor.

> [!INFO] *The following is subject to change and NOT a guarantee of future behavior.*
>
> A snapshot of the anchor at the time @@opened(s) is emitted will be
> used to position the menu. Additional changes to the anchor after this point
> will not affect the placement of the menu.

You can set properties of the anchor like so:
```qml
QsMenuAnchor {
anchor.window: parentwindow
// or
anchor {
window: parentwindow
}
}
```
- `menu` : `qs::menu::QsMenuHandle*` — The menu that should be displayed on this anchor.

See also: @@Quickshell.Services.SystemTray.SystemTrayItem.menu.
- `visible` : `bool` — If the menu is currently open and visible.

See also: @@open(), @@close().

**Functions:**
- `open()` — Open the given menu on this menu Requires that @@anchor is valid.
- `close()` — Close the open menu.

**Signals:**
- `opened()` — Sent when the menu is displayed onscreen which may be after @@visible
becomes true.
- `closed()` — Sent when the menu is closed.
- `menuChanged()`
- `visibleChanged()`

---

### QsMenuButtonType
**Module:** `Quickshell`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Button type associated with a QsMenuEntry.
See @@QsMenuEntry.buttonType.

---

### QsMenuEntry
**Module:** `Quickshell`
**Inherits:** `QsMenuHandle`

**Properties:**
- `isSeparator` : `bool` — If this menu item should be rendered as a separator between other items.

No other properties have a meaningful value when @@isSeparator is true.
- `enabled` : `bool`
- `text` : `QString` — Text of the menu item.
- `icon` : `QString` — Url of the menu item's icon or `""` if it doesn't have one.

This can be passed to [Image.source](https://doc.qt.io/qt-6/qml-qtquick-image.html#source-prop)
as shown below.

```qml
Image {
source: menuItem.icon
// To get the best image quality, set the image source size to the same size
// as the rendered image.
sourceSize.width: width
sourceSize.height: height
}
```
- `buttonType` : `qs::menu::QsMenuButtonType::Enum` — If this menu item has an associated checkbox or radiobutton.
- `checkState` : `Qt::CheckState` — The check state of the checkbox or radiobutton if applicable, as a
[Qt.CheckState](https://doc.qt.io/qt-6/qt.html#CheckState-enum).
- `hasChildren` : `bool` — If this menu item has children that can be accessed through a @@QsMenuOpener$.

**Functions:**
- `display(QObject* parentWindow, qint32 relativeX, qint32 relativeY)` — Display a platform menu at the given location relative to the parent window.

**Signals:**
- `triggered()` — Send a trigger/click signal to the menu entry.
- `isSeparatorChanged()`
- `enabledChanged()`
- `textChanged()`
- `iconChanged()`

---

### QsMenuHandle
**Module:** `Quickshell`
**Inherits:** `QObject`

Menu handle for QsMenuOpener
See @@QsMenuOpener.

**Signals:**
- `menuChanged()`

---

### QsMenuOpener
**Module:** `Quickshell`
**Inherits:** `QObject`

Provides access to children of a QsMenuEntry

**Properties:**
- `menu` : `qs::menu::QsMenuHandle*` — The menu to retrieve children from.
- `children` : `UntypedObjectModel*`

**Signals:**
- `menuChanged()`
- `childrenChanged()`
- `onMenuDestroyed()`

---

### QuickshellSettings
**Module:** `Quickshell`
**Inherits:** `QObject`

Accessor for some options under the Quickshell type.

**Properties:**
- `workingDirectory` : `QString` — Quickshell's working directory. Defaults to whereever quickshell was launched from.
- `watchFiles` : `bool` — If true then the configuration will be reloaded whenever any files change.
Defaults to true.
- `processId` : `qint32` — Quickshell's process id.
- `instanceId` : `QString` — A unique identifier for this Quickshell instance
- `shellId` : `QString` — The shell ID, used to differentiate between different shell configurations.

Defaults to a stable value derived from the config path.
Can be overridden with `//@ pragma ShellId <id>` in the root qml file.
- `appId` : `QString` — The desktop application ID.

Defaults to `org.quickshell`.
Can be overridden with `//@ pragma AppId <id>` in the root qml file
or the `QS_APP_ID` environment variable.
- `launchTime` : `QDateTime` — The time at which this Quickshell instance was launched.
- `screens` : `QQmlListProperty<QuickshellScreenInfo>` — All currently connected screens.

This property updates as connected screens change.

#### Reusing a window on every screen
```qml
ShellRoot {
Variants {
// see Variants for details
variants: Quickshell.screens
PanelWindow {
property var modelData
screen: modelData
}
}
}
```

This creates an instance of your window once on every screen.
As screens are added or removed your window will be created or destroyed on those screens.
- `shellDir` : `QString` — The full path to the root directory of your shell.

The root directory is the folder containing the entrypoint to your shell, often referred
to as `shell.qml`.
- `configDir` : `QString` — > [!WARNING] Deprecated: Renamed to @@shellDir for clarity.
- `shellRoot` : `QString` — > [!WARNING] Deprecated: Renamed to @@shellDir for consistency.
- `workingDirectory` : `QString` — Quickshell's working directory. Defaults to whereever quickshell was launched from.
- `watchFiles` : `bool` — If true then the configuration will be reloaded whenever any files change.
Defaults to true.
- `clipboardText` : `QString` — The system clipboard.

> [!WARNING] Under wayland the clipboard will be empty unless a quickshell window is focused.
- `dataDir` : `QString` — The per-shell data directory.

Usually `~/.local/share/quickshell/by-shell/<shell-id>`

Can be overridden using `//@ pragma DataDir $BASE/path` in the root qml file, where `$BASE`
corresponds to `$XDG_DATA_HOME` (usually `~/.local/share`).
- `stateDir` : `QString` — The per-shell state directory.

Usually `~/.local/state/quickshell/by-shell/<shell-id>`

Can be overridden using `//@ pragma StateDir $BASE/path` in the root qml file, where `$BASE`
corresponds to `$XDG_STATE_HOME` (usually `~/.local/state`).
- `cacheDir` : `QString` — The per-shell cache directory.

Usually `~/.cache/quickshell/by-shell/<shell-id>`

Can be overridden using `//@ pragma CacheDir $BASE/path` in the root qml file, where `$BASE`
corresponds to `$XDG_CACHE_HOME` (usually `~/.cache`).

**Functions:**
- `reload(bool hard)` — Reload the shell.

`hard` - perform a hard reload. If this is false, Quickshell will attempt to reuse windows
that already exist. If true windows will be recreated.

See @@Reloadable for more information on what can be reloaded and how.
- `env(const QString& variable)` — Returns the string value of an environment variable or null if it is not set.
- `inhibitReloadPopup()` — When called from @@reloadCompleted() or @@reloadFailed(), prevents the
default reload popup from displaying.

The popup can also be blocked by setting `QS_NO_RELOAD_POPUP=1`.

**Signals:**
- `lastWindowClosed()` — Sent when the last window is closed.

To make the application exit when the last window is closed run `Qt.quit()`.
- `workingDirectoryChanged()`
- `watchFilesChanged()`
- `screensChanged()`
- `lastWindowClosed()` — Sent when the last window is closed.

To make the application exit when the last window is closed run `Qt.quit()`.
- `reloadCompleted()` — The reload sequence has completed successfully.
- `reloadFailed(QString errorString)` — The reload sequence has failed.
- `screensChanged()`

---

### ReloadPopupInfo
**Module:** `Quickshell`
**Inherits:** `QObject`

**Properties:**
- `instanceId` : `QString`
- `failed` : `bool`
- `errorString` : `QString`

**Functions:**
- `closed()`

---

### Reloadable
**Module:** `Quickshell`

The base class of all types that can be reloaded.
Reloadables will attempt to take specific state from previous config revisions if possible.
Some examples are @@ProxyWindowBase and @@PersistentProperties

**Properties:**
- `reloadableId` : `QString` — An additional identifier that can be used to try to match a reloadable object to its
previous state.

Simply keeping a stable identifier across config versions (saves) is
enough to help the reloader figure out which object in the old revision corresponds to
this object in the current revision, and facilitate smoother reloading.

Note that identifiers are scoped, and will try to do the right thing in context.
For example if you have a @@Variants wrapping an object with an identified element inside,
a scope is created at the variant level.

```qml
Variants {
// multiple variants of the same object tree
variants: [ { foo: 1 }, { foo: 2 } ]

// any non `Reloadable` object
QtObject {
FloatingWindow {
// this FloatingWindow will now be matched to the same one in the previous
// widget tree for its variant. "myFloatingWindow" refers to both the variant in
// `foo: 1` and `foo: 2` for each tree.
reloadableId: "myFloatingWindow"

// ...
}
}
}
```

---

### Retainable
**Module:** `Quickshell`
**Inherits:** `QObject`

Attached object for types that can have delayed destruction.
Retainable works as an attached property that allows objects to be
kept around (retained) after they would normally be destroyed, which
is especially useful for things like exit transitions.

An object that is retainable will have @@Retainable as an attached property.
All retainable objects will say that they are retainable on their respective
typeinfo pages.

> [!INFO] Working directly with @@Retainable is often overly complicated and
> error prone. For this reason @@RetainableLock should
> usually be used instead.

**Properties:**
- `retained` : `bool` — If the object is currently in a retained state.

**Functions:**
- `lock()` — Hold a lock on the object so it cannot be destroyed.

A counter is used to ensure you can lock the object from multiple places
and it will not be unlocked until the same number of unlocks as locks have occurred.

> [!WARNING] It is easy to forget to unlock a locked object.
> Doing so will create what is effectively a memory leak.
>
> Using @@RetainableLock is recommended as it will help
> avoid this scenario and make misuse more obvious.
- `unlock()` — Remove a lock on the object. See @@lock() for more information.
- `forceUnlock()` — Forcibly remove all locks, destroying the object.

@@unlock() should usually be preferred.

**Signals:**
- `dropped()` — This signal is sent when the object would normally be destroyed.

If all signal handlers return and no locks are in place, the object will be destroyed.
If at least one lock is present the object will be retained until all are removed.
- `aboutToDestroy()` — This signal is sent immediately before the object is destroyed.
At this point destruction cannot be interrupted.
- `retainedChanged()`

---

### Retainable
**Module:** `Quickshell`

---

### RetainableLock
**Module:** `Quickshell`
**Inherits:** `QObject`

A helper for easily using Retainable.
A RetainableLock provides extra safety and ease of use for locking
@@Retainable objects. A retainable object can be locked by multiple
locks at once, and each lock re-exposes relevant properties
of the retained objects.

#### Example
The code below will keep a retainable object alive for as long as the
RetainableLock exists.

```qml
RetainableLock {
object: aRetainableObject
locked: true
}
```

**Properties:**
- `object` : `QObject*` — The object to lock. Must be @@Retainable.
- `locked` : `bool` — If the object should be locked.
- `retained` : `bool` — If the object is currently in a retained state.

**Signals:**
- `dropped()` — Rebroadcast of the object's @@Retainable.dropped(s).
- `aboutToDestroy()` — Rebroadcast of the object's @@Retainable.aboutToDestroy(s).
- `retainedChanged()`
- `objectChanged()`
- `lockedChanged()`

---

### Scope
**Module:** `Quickshell`
**Inherits:** `Reloadable`

Scope that propagates reloads to child items in order.
Convenience type equivalent to setting @@Reloadable.reloadableId for all children.

Note that this does not work for visible @@QtQuick.Item$s (all widgets).

```qml
ShellRoot {
Variants {
variants: ...

Scope {
// everything in here behaves the same as if it was defined
// directly in `Variants` reload-wise.
}
}
}

**Properties:**
- `children` : `QQmlListProperty<QObject>`

---

### ScriptModel
**Module:** `Quickshell`
**Inherits:** `QAbstractListModel`

QML model reflecting a javascript expression
ScriptModel is a QML [Data Model] that generates model operations based on changes
to a javascript expression attached to @@values.

### When should I use this
ScriptModel should be used when you would otherwise use a javascript expression as a model,
[QAbstractItemModel] is accepted, and the data is likely to change over the lifetime of the program.

When directly using a javascript expression as a model, types like @@QtQuick.Repeater or @@QtQuick.ListView
will destroy all created delegates, and re-create the entire list. In the case of @@QtQuick.ListView this
will also prevent animations from working. If you wrap your expression with ScriptModel, only new items
will be created, and ListView animations will work as expected.

### Example
```qml
// Will cause all delegates to be re-created every time filterText changes.
@@QtQuick.Repeater {
model: myList.filter(entry => entry.name.startsWith(filterText))
delegate: // ...
}

// Will add and remove delegates only when required.
@@QtQuick.Repeater {
model: ScriptModel {
values: myList.filter(entry => entry.name.startsWith(filterText))
}

delegate: // ...
}
```
[QAbstractItemModel]: https://doc.qt.io/qt-6/qabstractitemmodel.html
[Data Model]: https://doc.qt.io/qt-6/qtquick-modelviewsdata-modelview.html#qml-data-models

**Properties:**
- `values` : `QVariantList` — The list of values to reflect in the model.
> [!WARNING] ScriptModel currently only works with lists of *unique* values.
> There must not be any duplicates in the given list, or behavior of the model is undefined.

> [!TIP] @@ObjectModel$s supplied by Quickshell types will only contain unique values,
> and can be used like so:
>
> ```qml
> ScriptModel {
>   values: DesktopEntries.applications.values.filter(...)
> }
> ```
>
> Note that we are using @@ObjectModel.values because it will cause @@ScriptModel.values
> to receive an update on change.

> [!TIP] Most lists exposed by Quickshell are read-only. Some operations like `sort()`
> act on a list in-place and cannot be used directly on a list exposed by Quickshell.
> You can copy a list using spread syntax: `[...variable]` instead of `variable`.
>
> For example:
> ```qml
> ScriptModel {
>   values: [...DesktopEntries.applications.values].sort(...)
> }
> ```
- `objectProp` : `QString` — The property that javascript objects passed into the model will be compared with.

For example, if `objectProp` is `"myprop"` then `{ myprop: "a", other: "y" }` and
`{ myprop: "a", other: "z" }` will be considered equal.

Defaults to `""`, meaning no key.

**Signals:**
- `valuesChanged()`
- `objectPropChanged()`
- `updateValuesUnique(const QVariantList& newValues)`

---

### ShellRoot
**Module:** `Quickshell`
**Inherits:** `ReloadPropagator`

Optional root config element, allowing some settings to be specified inline.

**Properties:**
- `settings` : `QuickshellSettings*`

---

### ShellScreen
**Module:** `Quickshell`
**Inherits:** `QObject`

Monitor object useful for setting the monitor for a @@QsWindow
or querying information about the monitor.

> [!WARNING] If the monitor is disconnected, then any stored copies of its ShellMonitor will
> be marked as dangling and all properties will return default values.
> Reconnecting the monitor will not reconnect it to the ShellMonitor object.

Due to some technical limitations, it was not possible to reuse the native qml @@QtQuick.Screen type.

**Properties:**
- `name` : `QString` — The name of the screen as seen by the operating system.

Usually something like `DP-1`, `HDMI-1`, `eDP-1`.
- `model` : `QString` — The model of the screen as seen by the operating system.
- `serialNumber` : `QString` — The serial number of the screen as seen by the operating system.
- `x` : `qint32`
- `y` : `qint32`
- `width` : `qint32`
- `height` : `qint32`
- `physicalPixelDensity` : `qreal` — The number of physical pixels per millimeter.
- `logicalPixelDensity` : `qreal` — The number of device-independent (scaled) pixels per millimeter.
- `devicePixelRatio` : `qreal` — The ratio between physical pixels and device-independent (scaled) pixels.
- `orientation` : `Qt::ScreenOrientation`
- `primaryOrientation` : `Qt::ScreenOrientation`

**Signals:**
- `geometryChanged()`
- `physicalPixelDensityChanged()`
- `logicalPixelDensityChanged()`
- `orientationChanged()`
- `primaryOrientationChanged()`
- `screenDestroyed()`

---

### Singleton
**Module:** `Quickshell`
**Inherits:** `ReloadPropagator`

The root component for reloadable singletons.
All singletons should inherit from this type.

---

### SystemClock
**Module:** `Quickshell`
**Inherits:** `QObject`

System clock accessor.
SystemClock is a view into the system's clock.
It updates at hour, minute, or second intervals depending on @@precision.

# Examples
```qml
SystemClock {
id: clock
precision: SystemClock.Seconds
}

@@QtQuick.Text {
text: Qt.formatDateTime(clock.date, "hh:mm:ss - yyyy-MM-dd")
}
```

> [!WARNING] Clock updates will trigger within 50ms of the system clock changing,
> however this can be either before or after the clock changes (+-50ms). If you
> need a date object, use @@date instead of constructing a new one, or the time
> of the constructed object could be off by up to a second.

**Properties:**
- `enabled` : `bool` — If the clock should update. Defaults to true.

Setting enabled to false pauses the clock.
- `precision` : `SystemClock::Enum` — The precision the clock should measure at. Defaults to `SystemClock.Seconds`.
- `date` : `QDateTime` — The current date and time.

> [!TIP] You can use @@QtQml.Qt.formatDateTime() to get the time as a string in
> your format of choice.
- `hours` : `quint32` — The current hour.
- `minutes` : `quint32` — The current minute, or 0 if @@precision is `SystemClock.Hours`.
- `seconds` : `quint32` — The current second, or 0 if @@precision is `SystemClock.Hours` or `SystemClock.Minutes`.

**Signals:**
- `enabledChanged()`
- `precisionChanged()`
- `dateChanged()`
- `onTimeout()`

---

### SystemTray
**Module:** `Quickshell`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

System tray
Referencing the SystemTray singleton will make quickshell start tracking
system tray contents, which are updated as the tray changes, and can be
accessed via the @@items property.

**Properties:**
- `items` : `UntypedObjectModel*`

---

### SystemTrayItem
**Module:** `Quickshell`
**Inherits:** `QsImageHandle`

---

### SystemTrayItem
**Module:** `Quickshell`
**Inherits:** `QObject`

An item in the system tray.
A system tray item, roughly conforming to the [kde/freedesktop spec]
(there is no real spec, we just implemented whatever seemed to actually be used).

[kde/freedesktop spec]: https://www.freedesktop.org/wiki/Specifications/StatusNotifierItem/StatusNotifierItem/

**Properties:**
- `id` : `QString` — A name unique to the application, such as its name.
- `title` : `QString` — Text that describes the application.
- `status` : `qs::service::sni::Status::Enum`
- `category` : `qs::service::sni::Category::Enum`
- `icon` : `QString` — Icon source string, usable as an Image source.
- `tooltipTitle` : `QString`
- `tooltipDescription` : `QString`
- `hasMenu` : `bool` — If this tray item has an associated menu accessible via @@display() or @@menu.
- `menu` : `qs::dbus::dbusmenu::DBusMenuHandle*` — A handle to the menu associated with this tray item, if any.

Can be displayed with @@Quickshell.QsMenuAnchor or @@Quickshell.QsMenuOpener.
- `onlyMenu` : `bool` — If this tray item only offers a menu and activation will do nothing.

**Functions:**
- `activate()` — Primary activation action, generally triggered via a left click.
- `secondaryActivate()` — Secondary activation action, generally triggered via a middle click.
- `scroll(qint32 delta, bool horizontal)` — Scroll action, such as changing volume on a mixer.
- `display(QObject* parentWindow, qint32 relativeX, qint32 relativeY)` — Display a platform menu at the given location relative to the parent window.

**Signals:**
- `ready()`
- `idChanged()`
- `titleChanged()`
- `iconChanged()`
- `statusChanged()`
- `categoryChanged()`
- `tooltipTitleChanged()`
- `tooltipDescriptionChanged()`
- `hasMenuChanged()`

---

### TransformWatcher
**Module:** `Quickshell`
**Inherits:** `QObject`

Monitor of all geometry changes between two objects.
The TransformWatcher monitors all properties that affect the geometry
of two @@QtQuick.Item$s relative to eachother.

> [!INFO] The algorithm responsible for determining the relationship
> between `a` and `b` is biased towards `a` being a parent of `b`,
> or `a` being closer to the common parent of `a` and `b` than `b`.

**Properties:**
- `a` : `QQuickItem*`
- `b` : `QQuickItem*`
- `commonParent` : `QQuickItem*` — Known common parent of both `a` and `b`. Defaults to `null`.

This property can be used to optimize the algorithm that figures out
the relationship between `a` and `b`. Setting it to something that is not
a common parent of both `a` and `b` will prevent the path from being determined
correctly, and setting it to `null` will disable the optimization.
- `transform` : `QObject*` — This property is updated whenever the geometry of any item in the path from `a` to `b` changes.

Its value is undefined, and is intended to trigger an expression update.

**Signals:**
- `transformChanged()`
- `aChanged()`
- `bChanged()`
- `commonParentChanged()`
- `recalcChains()`
- `itemDestroyed()`
- `aDestroyed()`

---

### Variants
**Module:** `Quickshell`
**Inherits:** `Reloadable`

Creates instances of a component based on a given model.
Creates and destroys instances of the given component when the given property changes.

`Variants` is similar to @@QtQuick.Repeater except it is for *non @@QtQuick.Item$* objects, and acts as
a reload scope.

Each non duplicate value passed to @@model will create a new instance of
@@delegate with a `modelData` property set to that value.

See @@Quickshell.screens for an example of using `Variants` to create copies of a window per
screen.

> [!WARNING] BUG: Variants currently fails to reload children if the variant set is changed as
> it is instantiated. (usually due to a mutation during variant creation)

**Properties:**
- `delegate` : `QQmlComponent*` — The component to create instances of.

The delegate should define a `modelData` property that will be populated with a value
from the @@model.
- `instances` : `QQmlListProperty<QObject>` — Current instances of the delegate.

**Signals:**
- `modelChanged()`
- `instancesChanged()`
- `updateVariants()`

---

### XPanelEventFilter
**Module:** `Quickshell`
**Inherits:** `PanelWindowInterface`

**Signals:**
- `surfaceCreated()`

---

### XPanelWindow
**Module:** `Quickshell`
**Inherits:** `PanelWindowInterface`

**Signals:**
- `xInit()`
- `updatePanelStack()`

---

## Quickshell.Bluetooth

### BatteryPercentage
**Module:** `Quickshell.Bluetooth`

---

### Bluetooth
**Module:** `Quickshell.Bluetooth`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

**Signals:**
- `defaultAdapterChanged()`
- `onInterfacesRemoved(const QDBusObjectPath& path, const QStringList& interfaces)`
- `updateDefaultAdapter()`

---

### Bluetooth
**Module:** `Quickshell.Bluetooth`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Bluetooth manager
Provides access to bluetooth devices and adapters.

**Properties:**
- `defaultAdapter` : `BluetoothAdapter*` — The default bluetooth adapter. Usually there is only one.
- `adapters` : `UntypedObjectModel*` — A list of all bluetooth adapters. See @@defaultAdapter for the default.
- `devices` : `UntypedObjectModel*` — A list of all connected bluetooth devices across all adapters.
See @@BluetoothAdapter.devices for the devices connected to a single adapter.

**Signals:**
- `defaultAdapterChanged()`

---

### BluetoothAdapter
**Module:** `Quickshell.Bluetooth`
**Inherits:** `QObject`

A Bluetooth adapter

**Properties:**
- `name` : `QString` — System provided name of the adapter. See @@adapterId for the internal identifier.
- `enabled` : `bool` — True if the adapter is currently enabled. More detailed state is available from @@state.
- `state` : `BluetoothAdapterState::Enum` — Detailed power state of the adapter.
- `discoverable` : `bool` — True if the adapter can be discovered by other bluetooth devices.
- `discoverableTimeout` : `quint32` — Timeout in seconds for how long the adapter stays discoverable after @@discoverable is set to true.
A value of 0 means the adapter stays discoverable forever.
- `discovering` : `bool` — True if the adapter is scanning for new devices.
- `pairable` : `bool` — True if the adapter is accepting incoming pairing requests.

This only affects incoming pairing requests and should typically only be changed
by system settings applications. Defaults to true.
- `pairableTimeout` : `quint32` — Timeout in seconds for how long the adapter stays pairable after @@pairable is set to true.
A value of 0 means the adapter stays pairable forever. Defaults to 0.
- `devices` : `UntypedObjectModel*`
- `adapterId` : `QString` — The internal ID of the adapter (e.g., "hci0").
- `dbusPath` : `QString` — DBus path of the adapter under the `org.bluez` system service.

**Signals:**
- `nameChanged()`
- `enabledChanged()`
- `stateChanged()`
- `discoverableChanged()`
- `discoverableTimeoutChanged()`
- `discoveringChanged()`
- `pairableChanged()`
- `pairableTimeoutChanged()`

---

### BluetoothAdapterState
**Module:** `Quickshell.Bluetooth`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Power state of a Bluetooth adapter.

---

### BluetoothDevice
**Module:** `Quickshell.Bluetooth`
**Inherits:** `QObject`

A tracked Bluetooth device.

**Properties:**
- `address` : `QString` — MAC address of the device.
- `name` : `QString` — The name of the Bluetooth device. This property may be written to create an alias, or set to
an empty string to fall back to the device provided name.

See @@deviceName for the name provided by the device.
- `deviceName` : `QString` — The name of the Bluetooth device, ignoring user provided aliases. See also @@name
which returns a user provided alias if set.
- `icon` : `QString` — System icon representing the device type. Use @@Quickshell.Quickshell.iconPath() to display this in an image.
- `state` : `BluetoothDeviceState::Enum` — Connection state of the device.
- `connected` : `bool` — True if the device is currently connected to the computer.

Setting this property is equivalent to calling @@connect() and @@disconnect().

> [!NOTE] @@state provides more detailed information if required.
- `paired` : `bool` — True if the device is paired to the computer.

> [!NOTE] @@pair() can be used to pair a device, however you must @@forget() the device to unpair it.
- `bonded` : `bool` — True if pairing information is stored for future connections.
- `pairing` : `bool` — True if the device is currently being paired.

> [!NOTE] @@cancelPair() can be used to cancel the pairing process.
- `trusted` : `bool` — True if the device is considered to be trusted by the system.
Trusted devices are allowed to reconnect themselves to the system without intervention.
- `blocked` : `bool` — True if the device is blocked from connecting.
If a device is blocked, any connection attempts will be immediately rejected by the system.
- `wakeAllowed` : `bool` — True if the device is allowed to wake up the host system from suspend.
- `batteryAvailable` : `bool` — True if the connected device reports its battery level. Battery level can be accessed via @@battery.
- `battery` : `qreal` — Battery level of the connected device, from `0.0` to `1.0`. Only valid if @@batteryAvailable is true.
- `adapter` : `BluetoothAdapter*` — The Bluetooth adapter this device belongs to.
- `dbusPath` : `QString` — DBus path of the device under the `org.bluez` system service.

**Functions:**
- `connect()` — Attempt to connect to the device.
- `disconnect()` — Disconnect from the device.
- `pair()` — Attempt to pair the device.

> [!NOTE] @@paired and @@pairing return the current pairing status of the device.
- `cancelPair()` — Cancel an active pairing attempt.
- `forget()` — Forget the device.

**Signals:**
- `addressChanged()`
- `deviceNameChanged()`
- `nameChanged()`
- `connectedChanged()`
- `stateChanged()`
- `pairedChanged()`
- `bondedChanged()`
- `pairingChanged()`
- `trustedChanged()`
- `blockedChanged()`

---

### BluetoothDeviceState
**Module:** `Quickshell.Bluetooth`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Connection state of a Bluetooth device.

---

## Quickshell.DBusMenu

### DBusMenuHandle
**Module:** `Quickshell.DBusMenu`
**Inherits:** `QObject`

Handle to a DBusMenu tree.
Handle to a menu tree provided by a remote process.

**Properties:**
- `menu` : `qs::dbus::dbusmenu::DBusMenuItem*`

**Signals:**
- `prepareToShow(qint32 item, qint32 depth)`
- `updateLayout(qint32 parent, qint32 depth)`
- `removeRecursive(qint32 id)`
- `sendEvent(qint32 item, const QString& event)`

---

### DBusMenuItem
**Module:** `Quickshell.DBusMenu`
**Inherits:** `QsMenuEntry`

Menu item shared by an external program.
Menu item shared by an external program via the
[DBusMenu specification](https://github.com/AyatanaIndicators/libdbusmenu/blob/master/libdbusmenu-glib/dbus-menu.xml).

**Properties:**
- `menuHandle` : `qs::dbus::dbusmenu::DBusMenu*` — Handle to the root of this menu.

**Functions:**
- `updateLayout()` — Refreshes the menu contents.

Usually you shouldn't need to call this manually but some applications providing
menus do not update them correctly. Call this if menus don't update their state.

The @@layoutUpdated(s) signal will be sent when a response is received.

**Signals:**
- `layoutUpdated()`
- `sendOpened()`
- `sendClosed()`
- `sendTriggered()`

---

### DBusMenuPngImage
**Module:** `Quickshell.DBusMenu`
**Inherits:** `QsIndexedImageHandle`

---

## Quickshell.Hyprland

### GlobalShortcut
**Module:** `Quickshell.Hyprland`
**Inherits:** `PostReloadHook`

Hyprland global shortcut.
Global shortcut implemented with [hyprland_global_shortcuts_v1].

You can use this within hyprland as a global shortcut:
```
bind = <modifiers>, <key>, global, <appid>:<name>
```
See [the wiki] for details.

> [!WARNING] The shortcuts protocol does not allow duplicate appid + name pairs.
> Within a single instance of quickshell this is handled internally, and both
> users will be notified, but multiple instances of quickshell or XDPH may collide.
>
> If that happens, whichever client that tries to register the shortcuts last will crash.

> [!INFO] This type does *not* use the xdg-desktop-portal global shortcuts protocol,
> as it is not fully functional without flatpak and would cause a considerably worse
> user experience from other limitations. It will only work with Hyprland.
> Note that, as this type bypasses xdg-desktop-portal, XDPH is not required.

[hyprland_global_shortcuts_v1]: https://github.com/hyprwm/hyprland-protocols/blob/main/protocols/hyprland-global-shortcuts-v1.xml
[the wiki]: https://wiki.hyprland.org/Configuring/Binds/#dbus-global-shortcuts

**Properties:**
- `pressed` : `bool` — If the keybind is currently pressed.
- `appid` : `QString` — The appid of the shortcut. Defaults to `quickshell`.
You cannot change this at runtime.

If you have more than one shortcut we recommend subclassing
GlobalShortcut to set this.
- `name` : `QString` — The name of the shortcut.
You cannot change this at runtime.
- `description` : `QString` — The description of the shortcut that appears in `hyprctl globalshortcuts`.
You cannot change this at runtime.
- `triggerDescription` : `QString` — Have not seen this used ever, but included for completeness. Safe to ignore.

**Signals:**
- `pressed()` — Fired when the keybind is pressed.
- `released()` — Fired when the keybind is released.
- `pressedChanged()`
- `appidChanged()`
- `nameChanged()`
- `descriptionChanged()`
- `triggerDescriptionChanged()`

---

### Hyprland
**Module:** `Quickshell.Hyprland`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

**Properties:**
- `usingLua` : `bool` — True if Hyprland is running in lua mode. Dispatcher syntax changes when using lua.

This property will be false until the Hyprland module is initialized.
- `requestSocketPath` : `QString` — Path to the request socket (.socket.sock)
- `eventSocketPath` : `QString` — Path to the event socket (.socket2.sock)
- `focusedMonitor` : `qs::hyprland::ipc::HyprlandMonitor*` — The currently focused hyprland monitor. May be null.
- `focusedWorkspace` : `qs::hyprland::ipc::HyprlandWorkspace*` — The currently focused hyprland workspace. May be null.
- `activeToplevel` : `qs::hyprland::ipc::HyprlandToplevel*` — Currently active toplevel (might be null)
- `monitors` : `UntypedObjectModel*`
- `workspaces` : `UntypedObjectModel*`
- `toplevels` : `UntypedObjectModel*`

**Signals:**
- `rawEvent(qs::hyprland::ipc::HyprlandIpcEvent* event)` — Emitted for every event that comes in through the hyprland event socket (socket2).

See [Hyprland Wiki: IPC](https://wiki.hyprland.org/IPC/) for a list of events.
- `usingLuaChanged()`
- `focusedMonitorChanged()`
- `focusedWorkspaceChanged()`
- `activeToplevelChanged()`

---

### HyprlandEvent
**Module:** `Quickshell.Hyprland`
**Inherits:** `QObject`

Live Hyprland IPC event.
Live Hyprland IPC event. Holding this object after the
signal handler exits is undefined as the event instance
is reused.

Emitted by @@Hyprland.rawEvent(s).

**Properties:**
- `name` : `QString` — The name of the event.

See [Hyprland Wiki: IPC](https://wiki.hyprland.org/IPC/) for a list of events.
- `data` : `QString` — The unparsed data of the event.

**Signals:**
- `connected()`
- `rawEvent(HyprlandIpcEvent* event)`
- `usingLuaChanged()`
- `focusedMonitorChanged()`
- `focusedWorkspaceChanged()`
- `activeToplevelChanged()`
- `eventSocketError(QLocalSocket::LocalSocketError error)`

---

### HyprlandFocusGrab
**Module:** `Quickshell.Hyprland`

Input focus grabber
Object for managing input focus grabs via the [hyprland_focus_grab_v1]
wayland protocol.

When enabled, all of the windows listed in the `windows` property will
receive input normally, and will retain keyboard focus even if the mouse
is moved off of them. When areas of the screen that are not part of a listed
window are clicked or touched, the grab will become inactive and emit the
cleared signal.

This is useful for implementing dismissal of popup type windows.
```qml
import Quickshell
import Quickshell.Hyprland
import QtQuick.Controls

ShellRoot {
FloatingWindow {
id: window

Button {
anchors.centerIn: parent
text: grab.active ? "Remove exclusive focus" : "Take exclusive focus"
onClicked: grab.active = !grab.active
}

HyprlandFocusGrab {
id: grab
windows: [ window ]
}
}
}
```

[hyprland_focus_grab_v1]: https://github.com/hyprwm/hyprland-protocols/blob/main/protocols/hyprland-global-shortcuts-v1.xml

**Properties:**
- `active` : `bool` — If the focus grab is active. Defaults to false.

When set to true, an input grab will be created for the listed windows.

This property will change to false once the grab is dismissed.
It will not change to true until the grab begins, which requires
at least one visible window.
- `windows` : `QList<QObject*>` — The list of windows to whitelist for input.

**Signals:**
- `cleared()` — Sent whenever the compositor clears the focus grab.

This may be in response to all windows being removed
from the list or simultaneously hidden, in addition to
a normal clear.
- `activeChanged()`
- `windowsChanged()`

---

### HyprlandMonitor
**Module:** `Quickshell.Hyprland`
**Inherits:** `QObject`

**Properties:**
- `id` : `qint32`
- `name` : `QString`
- `description` : `QString`
- `x` : `qint32`
- `y` : `qint32`
- `width` : `qint32`
- `height` : `qint32`
- `scale` : `qreal`
- `lastIpcObject` : `QVariantMap` — Last json returned for this monitor, as a javascript object.

> [!WARNING] This is *not* updated unless the monitor object is fetched again from
> Hyprland. If you need a value that is subject to change and does not have a dedicated
> property, run @@Hyprland.refreshMonitors() and wait for this property to update.
- `activeWorkspace` : `qs::hyprland::ipc::HyprlandWorkspace*` — The currently active workspace on this monitor. May be null.
- `focused` : `bool` — If the monitor is currently focused.

**Signals:**
- `idChanged()`
- `nameChanged()`
- `descriptionChanged()`
- `xChanged()`
- `yChanged()`
- `widthChanged()`
- `heightChanged()`
- `scaleChanged()`
- `lastIpcObjectChanged()`
- `activeWorkspaceChanged()`

---

### HyprlandToplevel
**Module:** `Quickshell.Hyprland`
**Inherits:** `QObject`

Represents a window as Hyprland exposes it.
Can also be used as an attached object of a @@Quickshell.Wayland.Toplevel,
to resolve a handle to an Hyprland toplevel.

**Properties:**
- `address` : `QString` — Hexadecimal Hyprland window address. Will be an empty string until
the address is reported.
- `handle` : `HyprlandToplevel*` — The toplevel handle, exposing the Hyprland toplevel.
Will be null until the address is reported
- `wayland` : `qs::wayland::toplevel::Toplevel*` — The wayland toplevel handle. Will be null intil the address is reported
- `title` : `QString` — The title of the toplevel
- `activated` : `bool` — Whether the toplevel is active or not
- `urgent` : `bool` — Whether the client is urgent or not
- `lastIpcObject` : `QVariantMap` — Last json returned for this toplevel, as a javascript object.

> [!WARNING] This is *not* updated unless the toplevel object is fetched again from
> Hyprland. If you need a value that is subject to change and does not have a dedicated
> property, run @@Hyprland.refreshToplevels() and wait for this property to update.
- `workspace` : `qs::hyprland::ipc::HyprlandWorkspace*` — The current workspace of the toplevel (might be null)
- `monitor` : `qs::hyprland::ipc::HyprlandMonitor*` — The current monitor of the toplevel (might be null)

**Signals:**
- `addressChanged()`
- `titleChanged()`
- `activatedChanged()`
- `urgentChanged()`
- `workspaceChanged()`
- `monitorChanged()`
- `lastIpcObjectChanged()`

---

### HyprlandWindow
**Module:** `Quickshell.Hyprland`
**Inherits:** `QObject`

Hyprland specific QsWindow properties.
Allows setting hyprland specific window properties on a @@Quickshell.QsWindow or subclass,
as an attached object.

#### Example
```qml
@@Quickshell.PopupWindow {
// ...
HyprlandWindow.opacity: 0.6 // any number or binding
}
```

> [!NOTE] Requires at least hyprland 0.47.0, or [hyprland-surface-v1] support.

[hyprland-surface-v1]: https://github.com/hyprwm/hyprland-protocols/blob/main/protocols/hyprland-surface-v1.xml

**Properties:**
- `opacity` : `qreal` — A multiplier for the window's overall opacity, ranging from 1.0 to 0.0. Overall opacity includes the opacity of
both the window content *and* visual effects such as blur that apply to it.

Default: 1.0
- `visibleMask` : `PendingRegion*` — A hint to the compositor that only certain regions of the surface should be rendered.
This can be used to avoid rendering large empty regions of a window which can increase
performance, especially if the window is blurred. The mask should include all pixels
of the window that do not have an alpha value of 0.

**Signals:**
- `opacityChanged()`
- `visibleMaskChanged()`
- `onWindowConnected()`
- `onWindowVisibleChanged()`
- `onWaylandWindowDestroyed()`
- `onWaylandSurfaceCreated()`
- `onWaylandSurfaceDestroyed()`
- `onProxyWindowDestroyed()`

---

### HyprlandWorkspace
**Module:** `Quickshell.Hyprland`
**Inherits:** `QObject`

**Properties:**
- `id` : `qint32`
- `name` : `QString`
- `active` : `bool` — If this workspace is currently active on its monitor. See also @@focused.
- `focused` : `bool` — If this workspace is currently active on a monitor and that monitor is currently
focused. See also @@active.
- `urgent` : `bool` — If this workspace has a window that is urgent.
Becomes always falsed after the workspace is @@focused.
- `hasFullscreen` : `bool` — If this workspace currently has a fullscreen client.
- `lastIpcObject` : `QVariantMap` — Last json returned for this workspace, as a javascript object.

> [!WARNING] This is *not* updated unless the workspace object is fetched again from
> Hyprland. If you need a value that is subject to change and does not have a dedicated
> property, run @@Hyprland.refreshWorkspaces() and wait for this property to update.
- `monitor` : `qs::hyprland::ipc::HyprlandMonitor*`
- `toplevels` : `UntypedObjectModel*`

**Functions:**
- `activate()` — Activate the workspace.

> [!NOTE] This is equivalent to running
> ```qml
> HyprlandIpc.dispatch(`workspace ${workspace.name}`);
> ```

**Signals:**
- `idChanged()`
- `nameChanged()`
- `activeChanged()`
- `focusedChanged()`
- `urgentChanged()`
- `hasFullscreenChanged()`
- `lastIpcObjectChanged()`
- `monitorChanged()`

---

## Quickshell.I3

### I3
**Module:** `Quickshell.I3`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

I3/Sway IPC integration

**Properties:**
- `socketPath` : `QString` — Path to the I3 socket
- `focusedWorkspace` : `qs::i3::ipc::I3Workspace*`
- `focusedMonitor` : `qs::i3::ipc::I3Monitor*`
- `monitors` : `UntypedObjectModel*`
- `workspaces` : `UntypedObjectModel*`

**Signals:**
- `rawEvent(I3IpcEvent* event)`
- `connected()`
- `focusedWorkspaceChanged()`
- `focusedMonitorChanged()`

---

### I3Event
**Module:** `Quickshell.I3`
**Inherits:** `QObject`

I3/Sway IPC Events
Emitted by @@I3.rawEvent(s)

**Properties:**
- `type` : `QString`
- `data` : `QString`

**Signals:**
- `connected()`
- `rawEvent(I3IpcEvent* event)`
- `eventSocketError(QLocalSocket::LocalSocketError error)`
- `eventSocketStateChanged(QLocalSocket::LocalSocketState state)`
- `eventSocketReady()`
- `subscribe()`

---

### I3IpcListener
**Module:** `Quickshell.I3`
**Inherits:** `PostReloadHook`

I3/Sway IPC event listener
#### Example
```qml
I3IpcListener {
subscriptions: ["input"]
onIpcEvent: function (event) {
handleInputEvent(event.data)
}
}
```

**Properties:**
- `subscriptions` : `QList<QString>` — List of [I3/Sway events](https://man.archlinux.org/man/sway-ipc.7.en#EVENTS) to subscribe to.

**Signals:**
- `ipcEvent(I3IpcEvent* event)`
- `subscriptionsChanged()`
- `startListening()`
- `receiveEvent(I3IpcEvent* event)`
- `freeI3Ipc()`

---

### I3Monitor
**Module:** `Quickshell.I3`
**Inherits:** `QObject`

I3/Sway monitors

**Properties:**
- `id` : `qint32` — The ID of this monitor
- `name` : `QString` — The name of this monitor
- `power` : `bool` — Whether this monitor is turned on or not
- `activeWorkspace` : `qs::i3::ipc::I3Workspace*` — The currently active workspace on this monitor, May be null.
- `focusedWorkspace` : `qs::i3::ipc::I3Workspace*` — Deprecated: See @@activeWorkspace.
- `x` : `qint32` — The X coordinate of this monitor inside the monitor layout
- `y` : `qint32` — The Y coordinate of this monitor inside the monitor layout
- `width` : `qint32` — The width in pixels of this monitor
- `height` : `qint32` — The height in pixels of this monitor
- `scale` : `qreal` — The scaling factor of this monitor, 1 means it runs at native resolution
- `focused` : `bool` — Whether this monitor is currently in focus
- `lastIpcObject` : `QVariantMap` — Last JSON returned for this monitor, as a JavaScript object.

This updates every time Quickshell receives an `output` event from i3/Sway

**Signals:**
- `idChanged()`
- `nameChanged()`
- `powerChanged()`
- `activeWorkspaceChanged()`
- `xChanged()`
- `yChanged()`
- `widthChanged()`
- `heightChanged()`
- `scaleChanged()`
- `lastIpcObjectChanged()`

---

### I3Workspace
**Module:** `Quickshell.I3`
**Inherits:** `QObject`

I3/Sway workspaces

**Properties:**
- `id` : `qint32` — The ID of this workspace, it is unique for i3/Sway launch
- `name` : `QString` — The name of this workspace
- `number` : `qint32` — The number of this workspace
- `num` : `qint32` — Deprecated: use @@number
- `urgent` : `bool` — If a window in this workspace has an urgent notification
- `active` : `bool` — If this workspace is currently active on its monitor. See also @@focused.
- `focused` : `bool` — If this workspace is currently active on a monitor and that monitor is currently
focused. See also @@active.
- `monitor` : `qs::i3::ipc::I3Monitor*` — The monitor this workspace is being displayed on
- `lastIpcObject` : `QVariantMap` — Last JSON returned for this workspace, as a JavaScript object.

This updates every time we receive a `workspace` event from i3/Sway

**Functions:**
- `activate()` — Activate the workspace.

> [!NOTE] This is equivalent to running
> ```qml
> I3.dispatch(`workspace number ${workspace.number}`);
> ```

**Signals:**
- `idChanged()`
- `nameChanged()`
- `urgentChanged()`
- `activeChanged()`
- `focusedChanged()`
- `numberChanged()`
- `monitorChanged()`
- `lastIpcObjectChanged()`

---

## Quickshell.Io

### DataStream
**Module:** `Quickshell.Io`
**Inherits:** `QObject`

Data source that can be streamed into a parser.
See also: @@DataStreamParser

**Properties:**
- `parser` : `DataStreamParser*` — The parser to stream data from this source into.
If the parser is null no data will be read.

**Signals:**
- `readerChanged()`
- `onBytesAvailable()`
- `onReaderDestroyed()`

---

### DataStreamParser
**Module:** `Quickshell.Io`
**Inherits:** `QObject`

Parser for streamed input data.
See also: @@DataStream, @@SplitParser.

**Signals:**
- `read(QString data)` — Emitted when data is read from the stream.

---

### FileViewAdapter
**Module:** `Quickshell.Io`
**Inherits:** `QObject`

See @@FileView.adapter.

**Signals:**
- `adapterUpdated()` — This signal is fired when data in the adapter changes, and triggers @@FileView.adapterUpdated(s).
- `onDataChanged()`

---

### FileViewError
**Module:** `Quickshell.Io`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

**Properties:**
- `blockWrites` : `bool` — If true (default false), all calls to @@setText() or @@setData() will block the
UI thread until the write succeeds or fails.

> [!WARNING] Blocking operations should be used carefully to avoid stutters and other performance
> degradations. Blocking means that your interface **WILL NOT FUNCTION** during the call.
- `atomicWrites` : `bool` — If true (default), all calls to @@setText() or @@setData() will be performed atomically,
meaning if the write fails for any reason, the file will not be modified.

> [!NOTE] This works by creating another file with the desired content, and renaming
> it over the existing file if successful.
- `watchChanges` : `bool` — If true (defaule false), @@fileChanged() will be called whenever the content of the file
changes on disk, including when @@setText() or @@setData() are used.

> [!NOTE] You can reload the file's content whenever it changes on disk like so:
> ```qml
> FileView {
>   // ...
>   watchChanges: true
>   onFileChanged: this.reload()
> }
> ```
- `adapter` : `FileViewAdapter*` — In addition to directly reading/writing the file as text, *adapters* can be used to
expose a file's content in new ways.

An adapter will automatically be given the loaded file's content.
Its state may be saved with @@writeAdapter().

Currently the only adapter is @@JsonAdapter.
- `loaded` : `bool` — If a file is currently loaded, which may or may not be the one currently specified by @@path.

> [!INFO] If a file is loaded, @@path is changed, and a new file is loaded,
> this property will stay true the whole time.
> If @@path is set to an empty string to unload the file it will become false.

**Functions:**
- `waitForJob()` — Returns the data of the file specified by @@path as text.

If @@blockAllReads is true, all changes to @@path will cause the program to block
when this function is called.

If @@blockLoading is true, reading this property before the file has been loaded
will block, but changing @@path or calling @@reload() will return the old data
until the load completes.

If neither is true, an empty string will be returned if no file is loaded,
otherwise it will behave as in the case above.

> [!INFO] Due to technical limitations, @@text() could not be a property,
> however you can treat it like a property, it will trigger property updates
> as a property would, and the signal `textChanged()` is present.
Returns the data of the file specified by @@path as an [ArrayBuffer].

If @@blockAllReads is true, all changes to @@path will cause the program to block
when this function is called.

If @@blockLoading is true, reading this property before the file has been loaded
will block, but changing @@path or calling @@reload() will return the old data
until the load completes.

If neither is true, an empty buffer will be returned if no file is loaded,
otherwise it will behave as in the case above.

> [!INFO] Due to technical limitations, @@data() could not be a property,
> however you can treat it like a property, it will trigger property updates
> as a property would, and the signal `dataChanged()` is present.

[ArrayBuffer]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer
Block all operations until the currently running load completes.

> [!WARNING] See @@blockLoading for an explanation and warning about blocking.
- `reload()` — Unload the loaded file and reload it, usually in response to changes.

This will not block if @@blockLoading is set, only if @@blockAllReads is true.
It acts the same as changing @@path to a new file, except loading the same file.
- `writeAdapter()` — Write the content of the current @@adapter to the selected file.
- `setData(const QByteArray& data)` — Sets the content of the file specified by @@path as an [ArrayBuffer].

@@atomicWrites and @@blockWrites affect the behavior of this function.

@@saved(s) or @@saveFailed(s) will be emitted on completion.
- `setText(const QString& text)` — Sets the content of the file specified by @@path as text.

@@atomicWrites and @@blockWrites affect the behavior of this function.

@@saved(s) or @@saveFailed(s) will be emitted on completion.

[ArrayBuffer]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer

**Signals:**
- `done()`
- `finished()`
- `loaded()` — Emitted if the file was loaded successfully.
- `loadFailed(qs::io::FileViewError::Enum error)` — Emitted if the file failed to load.
- `saved()` — Emitted if the file was saved successfully.
- `saveFailed(qs::io::FileViewError::Enum error)` — Emitted if the file failed to save.
- `fileChanged()` — Emitted if the file changes on disk and @@watchChanges is true.

---

### IpcHandler
**Module:** `Quickshell.Io`
**Inherits:** `PostReloadHook`

Handler for IPC message calls.
Each IpcHandler is registered into a per-instance map by its unique @@target.
Functions and properties defined on the IpcHandler can be accessed via `qs ipc`.

#### Handler Functions
IPC handler functions can be called by `qs ipc call` as long as they have at most 10
arguments, and all argument types along with the return type are listed below.

**Argument and return types must be explicitly specified or they will not
be registered.**

##### Arguments
- `string` will be passed to the parameter as is.
- `int` will only accept parameters that can be parsed as an integer.
- `bool` will only accept parameters that are "true", "false", or an integer,
where 0 will be converted to false, and anything else to true.
- `real` will only accept parameters that can be parsed as a number with
or without a decimal.
- `color` will accept [named colors] or hex strings (RGB, RRGGBB, AARRGGBB) with
an optional `#` prefix.

[named colors]: https://doc.qt.io/qt-6/qml-color.html#svg-color-reference

##### Return Type
- `void` will return nothing.
- `string` will be returned as is.
- `int` will be converted to a string and returned.
- `bool` will be converted to "true" or "false" and returned.
- `real` will be converted to a string and returned.
- `color` will be converted to a hex string in the form `#AARRGGBB` and returned.

#### Signals
IPC handler signals can be observed remotely using `qs ipc wait` (one call)
and `qs ipc listen` (many calls). IPC signals may have zero or one argument, where
the argument is one of the types listed above, or no arguments for void.

#### Example
The following example creates ipc functions to control and retrieve the appearance
of a Rectangle.

```qml
FloatingWindow {
Rectangle {
id: rect
anchors.centerIn: parent
width: 100
height: 100
color: "red"
}

IpcHandler {
target: "rect"

function setColor(color: color): void { rect.color = color; }
function getColor(): color { return rect.color; }

function setAngle(angle: real): void { rect.rotation = angle; }
function getAngle(): real { return rect.rotation; }

function setRadius(radius: int): void {
rect.radius = radius;
this.radiusChanged(radius);
}

function getRadius(): int { return rect.radius; }

signal radiusChanged(newRadius: int);
}
}
```
The list of registered targets can be inspected using `qs ipc show`.
```sh
$ qs ipc show
target rect
function setColor(color: color): void
function getColor(): color
function setAngle(angle: real): void
function getAngle(): real
function setRadius(radius: int): void
function getRadius(): int
signal radiusChanged(newRadius: int)
```

and then invoked using `qs ipc call`.
```sh
$ qs ipc call rect setColor orange
$ qs ipc call rect setAngle 40.5
$ qs ipc call rect setRadius 30
$ qs ipc call rect getColor
#ffffa500
$ qs ipc call rect getAngle
40.5
$ qs ipc call rect getRadius
30
```

#### Properties
Properties of an IpcHanlder can be read using `qs ipc prop get` as long as they are
of an IPC compatible type. See the table above for compatible types.

**Properties:**
- `enabled` : `bool` — If the handler should be able to receive calls. Defaults to true.
- `target` : `QString` — The target this handler should be accessible from.
Required and must be unique. May be changed at runtime.

**Signals:**
- `enabledChanged()`
- `targetChanged()`
- `onSignalTriggered(const QString& signal, const QString& value)`
- `updateRegistration(bool destroying = false)`
- `triggered(const QString& target, const QString& signal, const QString& value)`

---

### JsonAdapter
**Module:** `Quickshell.Io`

FileView adapter for accessing JSON files.
JsonAdapter is a @@FileView adapter that exposes a JSON file as a set of QML
properties that can be read and written to.

Each property defined in a JsonAdapter corresponds to a key in the JSON file.
Supported property types are:
- Primitves (`int`, `bool`, `string`, `real`)
- Sub-object adapters (@@JsonObject$)
- JSON objects and arrays, as a `var` type
- Lists of any of the above (`list<string>` etc)

When the @@FileView$'s data is loaded, properties of a JsonAdapter or
sub-object adapter (@@JsonObject$) are updated if their values have changed.

When properties of a JsonAdapter or sub-object adapter are changed from QML,
@@FileView.adapterUpdated(s) is emitted, which may be used to save the file's new
state (see @@FileView.writeAdapter()$).

### Example
```qml
@@FileView {
path: "/path/to/file"

// when changes are made on disk, reload the file's content
watchChanges: true
onFileChanged: reload()

// when changes are made to properties in the adapter, save them
onAdapterUpdated: writeAdapter()

JsonAdapter {
property string myStringProperty: "default value"
onMyStringPropertyChanged: {
console.log("myStringProperty was changed via qml or on disk")
}

property list<string> stringList: [ "default", "value" ]

property JsonObject subObject: JsonObject {
property string subObjectProperty: "default value"
onSubObjectPropertyChanged: console.log("same as above")
}

// works the same way as subObject
property var inlineJson: { "a": "b" }
}
}
```

The above snippet produces the JSON document below:
```json
{
"myStringProperty": "default value",
"stringList": [
"default",
"value"
],
"subObject": {
"subObjectProperty": "default value"
},
"inlineJson": {
"a": "b"
}
}
```

---

### JsonObject
**Module:** `Quickshell.Io`
**Inherits:** `QObject`

See @@JsonAdapter.

---

### Socket
**Module:** `Quickshell.Io`
**Inherits:** `DataStream`

Unix socket listener.

**Properties:**
- `connected` : `bool` — Returns if the socket is currently connected.

Writing to this property will set the target connection state and will not
update the property immediately. Setting the property to false will begin disconnecting
the socket, and setting it to true will begin connecting the socket if path is not empty.
- `path` : `QString` — The path to connect this socket to when @@connected is set to true.

Changing this property will have no effect while the connection is active.

**Functions:**
- `write(const QString& data)` — Write data to the socket. Does nothing if not connected.

Remember to call flush after your last write.
- `flush()` — Flush any queued writes to the socket.

**Signals:**
- `error(QLocalSocket::LocalSocketError error)` — This signal is sent whenever a socket error is encountered.
- `connectionStateChanged()`
- `pathChanged()`

---

### SocketServer
**Module:** `Quickshell.Io`
**Inherits:** `Reloadable`

Unix socket server.
#### Example
```qml
SocketServer {
active: true
path: "/path/too/socket.sock"
handler: Socket {
onConnectedChanged: {
console.log(connected ? "new connection!" : "connection dropped!")
}
parser: SplitParser {
onRead: message => console.log(`read message from socket: ${message}`)
}
}
}
```

**Properties:**
- `active` : `bool` — If the socket server is currently active. Defaults to false.

Setting this to false will destroy all active connections and delete
the socket file on disk.

If path is empty setting this property will have no effect.
- `path` : `QString` — The path to create the socket server at.

Setting this property while the server is active will have no effect.
- `handler` : `QQmlComponent*` — Connection handler component. Must create a @@Socket.

The created socket should not set @@connected or @@path or the incoming
socket connection will be dropped (they will be set by the socket server.)
Setting `connected` to false on the created socket after connection will
close and delete it.

**Signals:**
- `activeStatusChanged()`
- `pathChanged()`
- `handlerChanged()`
- `onNewConnection()`
- `enableServer()`

---

### SplitParser
**Module:** `Quickshell.Io`
**Inherits:** `DataStreamParser`

DataStreamParser for delimited data streams.
DataStreamParser for delimited data streams. @@DataStreamParser.read(s) is emitted once per delimited chunk of the stream.

**Properties:**
- `splitMarker` : `QString` — The delimiter for parsed data. May be multiple characters. Defaults to `\n`.

If the delimiter is empty read lengths may be arbitrary (whatever is returned by the
underlying read call.)

**Signals:**
- `splitMarkerChanged()`

---

### StdioCollector
**Module:** `Quickshell.Io`
**Inherits:** `DataStreamParser`

DataStreamParser that collects all output into a buffer
StdioCollector collects all process output into a buffer exposed as @@text or @@data.

**Properties:**
- `text` : `QString` — The stdio buffer exposed as text. if @@waitForEnd is true, this will not change
until the stream ends.
- `data` : `QByteArray` — The stdio buffer exposed as an [ArrayBuffer]. if @@waitForEnd is true, this will not change
until the stream ends.

[ArrayBuffer]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer
- `waitForEnd` : `bool` — If true, @@text and @@data will not be updated until the stream ends. Defaults to true.

**Signals:**
- `waitForEndChanged()`
- `dataChanged()`
- `streamFinished()`

---

## Quickshell.Networking

### ConnectionFailReason
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The reason a connection failed.

---

### ConnectionState
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The connection state of a device or network.

---

### DeviceType
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Type of a @@NetworkDevice.

---

### NM80211ApSecurityFlags
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

---

### NMConnectionState
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

---

### NMConnectionStateReason
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

In sync with https://networkmanager.dev/docs/api/latest/nm-dbus-types.html#NMActiveConnectionStateReason.

---

### NMDeviceState
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

---

### NMDeviceStateReason
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

---

### NMDeviceType
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

---

### NMSettings
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`

A NetworkManager connection settings profile.

**Properties:**
- `id` : `QString` — The human-readable unique identifier for the connection.
- `uuid` : `QString` — A universally unique identifier for the connection.

**Functions:**
- `clearSecrets()` — Clear all of the secrets belonging to the settings.
- `forget()` — Delete the settings.
- `write(const QVariantMap& settings)` — Update the connection with new settings and save the connection to disk.
Only changed fields need to be included.
Writing a setting to `null` will remove the setting or reset it to its default.

> [!NOTE] Secrets may be part of the update request,
> and will be either stored in persistent storage or sent to a Secret Agent for storage,
> depending on the flags associated with each secret.
- `read()` — Get the settings map describing this network configuration.

> [!NOTE] This will never include any secrets required for connection to the network, as those are often protected.

**Signals:**
- `loaded()`
- `settingsChanged(NMSettingsMap settings)`
- `idChanged(QString id)`
- `uuidChanged(QString uuid)`
- `getSettings()`

---

### Network
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`

A network.
A network. Networks derived from a @@WifiDevice are @@WifiNetwork instances.

**Properties:**
- `name` : `QString` — The name of the network.
- `device` : `NetworkDevice*` — The device this network belongs to.
- `nmSettings` : `QList<NMSettings*>` — A list of NetworkManager connection settings profiles for this network.

> [!WARNING] Only valid for the NetworkManager backend.
- `connected` : `bool` — True if the network is connected.
- `known` : `bool` — True if the wifi network has known connection settings saved.
- `state` : `ConnectionState::Enum` — The connectivity state of the network.
- `stateChanging` : `bool` — If the network is currently connecting or disconnecting. Shorthand for checking @@state.

**Functions:**
- `connect()` — Attempt to connect to the network.

> [!NOTE] If the network is a @@WifiNetwork and requires secrets, a @@connectionFailed(s)
> signal will be emitted with `NoSecrets`.
> @@WifiNetwork.connectWithPsk() can be used to provide secrets.
- `connectWithSettings(NMSettings* settings)` — Attempt to connect to the network with a specific @@nmSettings entry.

> [!WARNING] Only valid for the NetworkManager backend.
- `disconnect()` — Disconnect from the network.
- `forget()` — Forget all connection settings for this network.

**Signals:**
- `connectionFailed(ConnectionFailReason::Enum reason)` — Signals that a connection to the network has failed because of the given @@ConnectionFailReason.
- `nameChanged()`
- `connectedChanged()`
- `knownChanged()`
- `stateChanged()`
- `stateChangingChanged()`
- `nmSettingsChanged()`

---

### NetworkBackendType
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The backend supplying the Network service.

---

### NetworkConnectivity
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The degree to which the host can reach the internet.

---

### NetworkDevice
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`

A network device.
The @@type property may be used to determine if this device is a @@WifiDevice or @@WiredDevice.

**Properties:**
- `type` : `DeviceType::Enum` — The device type.

When the device type is `Wifi`, the device object is a @@WifiDevice.
When the device type is `Wired`, the device object is a @@WiredDevice.
connection and scanning.
- `name` : `QString` — The name of the device's control interface.
- `networks` : `UntypedObjectModel*`
- `address` : `QString` — The hardware address of the device in the XX:XX:XX:XX:XX:XX format.
- `connected` : `bool` — True if the device is connected.
- `state` : `qs::network::ConnectionState::Enum` — Connection state of the device.
- `nmManaged` : `bool` — True if the device is managed by NetworkManager.

> [!WARNING] Only valid for the NetworkManager backend.
- `autoconnect` : `bool` — True if the device is allowed to autoconnect to a network.

**Functions:**
- `disconnect()` — Disconnects the device and prevents it from automatically activating further connections.

**Signals:**
- `nameChanged()`
- `addressChanged()`
- `connectedChanged()`
- `stateChanged()`
- `nmManagedChanged()`
- `autoconnectChanged()`

---

### Networking
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

**Signals:**
- `requestSetWifiEnabled(bool enabled)`
- `requestSetConnectivityCheckEnabled(bool enabled)`
- `requestCheckConnectivity()`
- `wifiEnabledChanged()`
- `wifiHardwareEnabledChanged()`
- `canCheckConnectivityChanged()`
- `connectivityCheckEnabledChanged()`
- `connectivityChanged()`

---

### Networking
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The Network service.
An interface to a network backend (currently only NetworkManager),
which can be used to view, configure, and connect to various networks.

**Properties:**
- `devices` : `UntypedObjectModel*`
- `backend` : `qs::network::NetworkBackendType::Enum` — The backend being used to power the Network service.
- `wifiEnabled` : `bool` — Switch for the rfkill software block of all wireless devices.
- `wifiHardwareEnabled` : `bool` — State of the rfkill hardware block of all wireless devices.
- `canCheckConnectivity` : `bool` — True if the @@backend supports connectivity checks.
- `connectivityCheckEnabled` : `bool` — True if connectivity checking is enabled.
- `connectivity` : `qs::network::NetworkConnectivity::Enum` — The result of the last connectivity check.

Connectivity checks may require additional configuration depending on your distro.

> [!NOTE] This property can be used to determine if network access is restricted
> or gated behind a captive portal.
>
> If checking for captive portals, @@checkConnectivity() should be called after
> the portal is dismissed to update this property.

**Signals:**
- `wifiEnabledChanged()`
- `wifiHardwareEnabledChanged()`
- `canCheckConnectivityChanged()`
- `connectivityCheckEnabledChanged()`
- `connectivityChanged()`

---

### WifiDevice
**Module:** `Quickshell.Networking`
**Inherits:** `NetworkDevice`

WiFi variant of a @@NetworkDevice.

**Properties:**
- `scannerEnabled` : `bool` — True when currently scanning for networks.
When enabled, the scanner populates the device with an active list of available wifi networks.
- `mode` : `WifiDeviceMode::Enum` — The 802.11 mode the device is in.

**Signals:**
- `modeChanged()`
- `scannerEnabledChanged(bool enabled)`

---

### WifiDeviceMode
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The 802.11 mode of a @@WifiDevice.

---

### WifiNetwork
**Module:** `Quickshell.Networking`
**Inherits:** `Network`

WiFi subtype of @@Network.

**Properties:**
- `signalStrength` : `qreal` — The current signal strength of the network, from 0.0 to 1.0.
- `security` : `WifiSecurityType::Enum` — The security type of the wifi network.

**Functions:**
- `connectWithPsk(const QString& psk)` — Attempt to connect to the network with the given PSK. If the PSK is wrong,
a @@Network.connectionFailed(s) signal will be emitted with `NoSecrets`.

The networking backend may store the PSK for future use with @@Network.connect().
As such, calling that function first is recommended to avoid having to show a
prompt if not required.

> [!NOTE] PSKs should only be provided when the @@security is one of
> `WpaPsk`, `Wpa2Psk`, or `Sae`.

**Signals:**
- `signalStrengthChanged()`
- `securityChanged()`

---

### WifiSecurityType
**Module:** `Quickshell.Networking`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The security type of a @@WifiNetwork.

---

### WiredDevice
**Module:** `Quickshell.Networking`
**Inherits:** `NetworkDevice`

Wired variant of a @@NetworkDevice.

**Properties:**
- `network` : `Network*` — The wired network for this device or `null`.

> [!NOTE] This network is only available when @@hasLink is `true`.
- `linkSpeed` : `quint32` — The maximum speed of the physical device link, in megabits per second.
- `hasLink` : `bool` — True if the wired device has a physical link (cable plugged in).

**Signals:**
- `networkChanged()`
- `linkSpeedChanged()`
- `hasLinkChanged()`

---

## Quickshell.Services.Greetd

### Greetd
**Module:** `Quickshell.Services.Greetd`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

This object provides access to a running greetd instance if present.
With it you can authenticate a user and launch a session.

See [the greetd wiki] for instructions on how to set up a graphical greeter.

[the greetd wiki]: https://man.sr.ht/~kennylevinsen/greetd/#setting-up-greetd-with-gtkgreet

**Properties:**
- `available` : `bool` — If the greetd socket is available.
- `state` : `GreetdState::Enum` — The current state of the greetd connection.
- `user` : `QString` — The currently authenticating user.

---

### GreetdState
**Module:** `Quickshell.Services.Greetd`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

State of the Greetd connection.
See @@Greetd.state.

**Signals:**
- `authMessage(QString message, bool error, bool responseRequired, bool echoResponse)`
- `authFailure(QString message)`
- `readyToLaunch()`
- `launched()`
- `error(QString error)`
- `stateChanged()`
- `userChanged()`

---

## Quickshell.Services.Mpris

### Mpris
**Module:** `Quickshell.Services.Mpris`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Provides access to MprisPlayers.

---

### Mpris
**Module:** `Quickshell.Services.Mpris`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

**Properties:**
- `players` : `UntypedObjectModel*`

---

### MprisLoopState
**Module:** `Quickshell.Services.Mpris`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Loop state of an MprisPlayer
See @@MprisPlayer.loopState.

**Properties:**
- `canControl` : `bool`
- `canPlay` : `bool`
- `canPause` : `bool`
- `canTogglePlaying` : `bool`
- `canSeek` : `bool`
- `canGoNext` : `bool`
- `canGoPrevious` : `bool`
- `canQuit` : `bool`
- `canRaise` : `bool`
- `canSetFullscreen` : `bool`
- `identity` : `QString` — The human readable name of the media player.
- `desktopEntry` : `QString` — The name of the desktop entry for the media player, or an empty string if not provided.
- `dbusName` : `QString` — The DBus service name of the player.
- `position` : `qreal` — The current position in the playing track, as seconds, with millisecond precision,
or `0` if @@positionSupported is false.

May only be written to if @@canSeek and @@positionSupported are true.

> [!WARNING] To avoid excessive property updates wasting CPU while `position` is not
> actively monitored, `position` usually will not update reactively, unless a nonlinear
> change in position occurs, however reading it will always return the current position.
>
> If you want to actively monitor the position, the simplest way it to emit the @@positionChanged(s)
> signal manually for the duration you are monitoring it, Using a @@QtQuick.FrameAnimation if you need
> the value to update smoothly, such as on a slider, or a @@QtQuick.Timer if not, as shown below.
>
> ```qml {filename="Using a FrameAnimation"}
> FrameAnimation {
>   // only emit the signal when the position is actually changing.
>   running: player.playbackState == MprisPlaybackState.Playing
>   // emit the positionChanged signal every frame.
>   onTriggered: player.positionChanged()
> }
> ```
>
> ```qml {filename="Using a Timer"}
> Timer {
>   // only emit the signal when the position is actually changing.
>   running: player.playbackState == MprisPlaybackState.Playing
>   // Make sure the position updates at least once per second.
>   interval: 1000
>   repeat: true
>   // emit the positionChanged signal every second.
>   onTriggered: player.positionChanged()
> }
> ```
- `positionSupported` : `bool`
- `length` : `qreal` — The length of the playing track, as seconds, with millisecond precision,
or the value of @@position if @@lengthSupported is false.
- `lengthSupported` : `bool`
- `volume` : `qreal` — The volume of the playing track from 0.0 to 1.0, or 1.0 if @@volumeSupported is false.

May only be written to if @@canControl and @@volumeSupported are true.
- `volumeSupported` : `bool`
- `metadata` : `QVariantMap` — Metadata of the current track.

A map of common properties is available [here](https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata).
Do not count on any of them actually being present.

Note that the @@trackTitle, @@trackAlbum, @@trackAlbumArtist, @@trackArtist and @@trackArtUrl
properties have extra logic to guard against bad players sending weird metadata, and should
be used over grabbing the properties directly from the metadata.
- `uniqueId` : `quint32` — An opaque identifier for the current track unique within the current player.

> [!WARNING] This is NOT `mpris:trackid` as that is sometimes missing or nonunique
> in some players.
- `trackTitle` : `QString` — The title of the current track, or `""` if none was provided.

> [!TIP] Use `player.trackTitle || "Unknown Title"` to provide a message
> when no title is available.
- `trackArtist` : `QString` — The current track's artist, or an `""` if none was provided.

> [!TIP] Use `player.trackArtist || "Unknown Artist"` to provide a message
> when no artist is available.
- `trackArtists` : `QString` — > [!ERROR] deprecated in favor of @@trackArtist.
- `trackAlbum` : `QString` — The current track's album, or `""` if none was provided.

> [!TIP] Use `player.trackAlbum || "Unknown Album"` to provide a message
> when no album is available.
- `trackAlbumArtist` : `QString` — The current track's album artist, or `""` if none was provided.

> [!TIP] Use `player.trackAlbumArtist || "Unknown Album"` to provide a message
> when no album artist is available.
- `trackArtUrl` : `QString` — The current track's art url, or `""` if none was provided.
- `playbackState` : `qs::service::mpris::MprisPlaybackState::Enum` — The playback state of the media player.

- If @@canPlay is false, you cannot assign the `Playing` state.
- If @@canPause is false, you cannot assign the `Paused` state.
- If @@canControl is false, you cannot assign the `Stopped` state.
(or any of the others, though their repsective properties will also be false)
- `isPlaying` : `bool` — True if @@playbackState == `MprisPlaybackState.Playing`.

Setting this property is equivalent to calling @@play() or @@pause().
You cannot set this property if @@canTogglePlaying is false.
- `loopState` : `qs::service::mpris::MprisLoopState::Enum` — The loop state of the media player, or `None` if @@loopSupported is false.

May only be written to if @@canControl and @@loopSupported are true.
- `loopSupported` : `bool`
- `rate` : `qreal` — The speed the song is playing at, as a multiplier.

Only values between @@minRate and @@maxRate (inclusive) may be written to the property.
Additionally, It is recommended that you only write common values such as `0.25`, `0.5`, `1.0`, `2.0`
to the property, as media players are free to ignore the value, and are more likely to
accept common ones.
- `minRate` : `qreal`
- `maxRate` : `qreal`
- `shuffle` : `bool` — If the play queue is currently being shuffled, or false if @@shuffleSupported is false.

May only be written if @@canControl and @@shuffleSupported are true.
- `shuffleSupported` : `bool`
- `fullscreen` : `bool` — If the player is currently shown in fullscreen.

May only be written to if @@canSetFullscreen is true.
- `supportedUriSchemes` : `QList<QString>` — Uri schemes supported by @@openUri().
- `supportedMimeTypes` : `QList<QString>` — Mime types supported by @@openUri().

**Functions:**
- `raise()` — Bring the media player to the front of the window stack.

May only be called if @@canRaise is true.
- `quit()` — Quit the media player.

May only be called if @@canQuit is true.
- `openUri(const QString& uri)` — Open the given URI in the media player.

Many players will silently ignore this, especially if the uri
does not match @@supportedUriSchemes and @@supportedMimeTypes.
- `next()` — Play the next song.

May only be called if @@canGoNext is true.
- `previous()` — Play the previous song, or go back to the beginning of the current one.

May only be called if @@canGoPrevious is true.
- `seek(qreal offset)` — Change `position` by an offset.

Even if @@positionSupported is false and you cannot set `position`,
this function may work.

May only be called if @@canSeek is true.
- `play()` — Equivalent to setting @@playbackState to `Playing`.
- `pause()` — Equivalent to setting @@playbackState to `Paused`.
- `stop()` — Equivalent to setting @@playbackState to `Stopped`.
- `togglePlaying()` — Equivalent to calling @@play() if not playing or @@pause() if playing.

May only be called if @@canTogglePlaying is true, which is equivalent to
@@canPlay or @@canPause depending on the current playback state.

---

### MprisPlaybackState
**Module:** `Quickshell.Services.Mpris`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Playback state of an MprisPlayer
See @@MprisPlayer.playbackState.

---

## Quickshell.Services.Notifications

### Notification
**Module:** `Quickshell.Services.Notifications`

A notification emitted by a NotificationServer.
A notification emitted by a NotificationServer.

> [!INFO] This type is @@Quickshell.Retainable. It
> can be retained after destruction if necessary.

**Properties:**
- `id` : `quint32` — Id of the notification as given to the client.
- `tracked` : `bool` — If the notification is tracked by the notification server.

Setting this property to false is equivalent to calling @@dismiss().
- `lastGeneration` : `bool` — If this notification was carried over from the last generation
when quickshell reloaded.

Notifications from the last generation will only be emitted
if @@NotificationServer.keepOnReload is true.
- `expireTimeout` : `qreal` — Time in seconds the notification should be valid for
- `appName` : `QString` — The sending application's name.
- `appIcon` : `QString` — The sending application's icon. If none was provided, then the icon from an associated
desktop entry will be retrieved. If none was found then "".
- `summary` : `QString` — The image associated with this notification, or "" if none.
- `body` : `QString`
- `urgency` : `qs::service::notifications::NotificationUrgency::Enum`
- `actions` : `QList<qs::service::notifications::NotificationAction*>` — Actions that can be taken for this notification.
- `hasActionIcons` : `bool` — If actions associated with this notification have icons available.

See @@NotificationAction.identifier for details.
- `resident` : `bool` — If true, the notification will not be destroyed after an action is invoked.
- `transient` : `bool` — If true, the notification should skip any kind of persistence function like a notification area.
- `desktopEntry` : `QString` — The name of the sender's desktop entry or "" if none was supplied.
- `image` : `QString` — An image associated with the notification.

This image is often something like a profile picture in instant messaging applications.
- `hasInlineReply` : `bool` — If true, the notification has an inline reply action.

A quick reply text field should be displayed and the reply can be sent using @@sendInlineReply().
- `inlineReplyPlaceholder` : `QString` — The placeholder text/button caption for the inline reply.
- `hints` : `QVariantMap` — All hints sent by the client application as a javascript object.
Many common hints are exposed via other properties.

**Functions:**
- `expire()` — Destroy the notification and hint to the remote application that it has
timed out an expired.
- `dismiss()` — Destroy the notification and hint to the remote application that it was
explicitly closed by the user.
- `sendInlineReply(const QString& replyText)` — Send an inline reply to the notification with an inline reply action.
> [!WARNING] This method can only be called if
> @@hasInlineReply is true
> and the server has @@NotificationServer.inlineReplySupported set to true.

**Signals:**
- `closed(qs::service::notifications::NotificationCloseReason::Enum reason)` — Sent when a notification has been closed.

The notification object will be destroyed as soon as all signal handlers exit.
- `trackedChanged()`
- `expireTimeoutChanged()`
- `appNameChanged()`
- `appIconChanged()`
- `summaryChanged()`

---

### NotificationAction
**Module:** `Quickshell.Services.Notifications`
**Inherits:** `QObject`

An action associated with a Notification.
See @@Notification.actions.

**Properties:**
- `identifier` : `QString` — The identifier of the action.

When @@Notification.hasActionIcons is true, this property will be an icon name.
When it is false, this property is irrelevant.
- `text` : `QString` — The localized text that should be displayed on a button.

**Functions:**
- `invoke()` — Invoke the action. If @@Notification.resident is false it will be dismissed.

**Signals:**
- `textChanged()`

---

### NotificationCloseReason
**Module:** `Quickshell.Services.Notifications`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The reason a Notification was closed.
See @@Notification.closed(s).

---

### NotificationServer
**Module:** `Quickshell.Services.Notifications`
**Inherits:** `PostReloadHook`

Desktop Notifications Server.
An implementation of the [Desktop Notifications Specification] for receiving notifications
from external applications.

The server does not advertise most capabilities by default. See the individual properties for details.

[Desktop Notifications Specification]: https://specifications.freedesktop.org/notification-spec/notification-spec-latest.html

**Properties:**
- `keepOnReload` : `bool` — If notifications should be re-emitted when quickshell reloads. Defaults to true.

The @@Notification.lastGeneration flag will be
set on notifications from the prior generation for further filtering/handling.
- `persistenceSupported` : `bool` — If the notification server should advertise that it can persist notifications in the background
after going offscreen. Defaults to false.
- `bodySupported` : `bool` — If notification body text should be advertised as supported by the notification server.
Defaults to true.

Note that returned notifications are likely to return body text even if this property is false,
as it is only a hint.
- `bodyMarkupSupported` : `bool` — If notification body text should be advertised as supporting markup as described in [the specification]
Defaults to false.

Note that returned notifications may still contain markup if this property is false,
as it is only a hint. By default Text objects will try to render markup. To avoid this
if any is sent, change @@QtQuick.Text.textFormat to `PlainText`.
- `bodyHyperlinksSupported` : `bool` — If notification body text should be advertised as supporting hyperlinks as described in [the specification]
Defaults to false.

Note that returned notifications may still contain hyperlinks if this property is false, as it is only a hint.

[the specification]: https://specifications.freedesktop.org/notification-spec/notification-spec-latest.html#hyperlinks
- `bodyImagesSupported` : `bool` — If notification body text should be advertised as supporting images as described in [the specification]
Defaults to false.

Note that returned notifications may still contain images if this property is false, as it is only a hint.

[the specification]: https://specifications.freedesktop.org/notification-spec/notification-spec-latest.html#images
- `actionsSupported` : `bool` — If notification actions should be advertised as supported by the notification server. Defaults to false.
- `actionIconsSupported` : `bool` — If notification actions should be advertised as supporting the display of icons. Defaults to false.
- `imageSupported` : `bool` — If the notification server should advertise that it supports images. Defaults to false.
- `inlineReplySupported` : `bool` — If the notification server should advertise that it supports inline replies. Defaults to false.
- `trackedNotifications` : `UntypedObjectModel*`
- `extraHints` : `QVector<QString>` — Extra hints to expose to notification clients.

**Signals:**
- `notification(qs::service::notifications::Notification* notification)` — Sent when a notification is received by the server.

If this notification should not be discarded, set its `tracked` property to true.
- `keepOnReloadChanged()`
- `persistenceSupportedChanged()`
- `bodySupportedChanged()`
- `bodyMarkupSupportedChanged()`
- `bodyHyperlinksSupportedChanged()`

---

### NotificationUrgency
**Module:** `Quickshell.Services.Notifications`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The urgency level of a Notification.
See @@Notification.urgency.

---

## Quickshell.Services.Pam

### PamContext
**Module:** `Quickshell.Services.Pam`

Connection to pam.
Connection to pam. See [the module documentation](../) for pam configuration advice.

**Properties:**
- `active` : `bool` — If the pam context is actively performing an authentication.

Setting this value behaves exactly the same as calling @@start() and @@abort().
- `config` : `QString` — The pam configuration to use. Defaults to "login".

The configuration should name a file inside @@configDirectory.

This property may not be set while @@active is true.
- `configDirectory` : `QString` — The pam configuration directory to use. Defaults to "/etc/pam.d".

The configuration directory is resolved relative to the current file if not an absolute path.

On FreeBSD this property is ignored as the pam configuration directory cannot be changed.

This property may not be set while @@active is true.
- `user` : `QString` — The user to authenticate as. If unset the current user will be used.

This property may not be set while @@active is true.
- `message` : `QString` — The last message sent by pam.
- `messageIsError` : `bool` — If the last message should be shown as an error.
- `responseRequired` : `bool` — If pam currently wants a response.

Responses can be returned with the @@respond() function.
- `responseVisible` : `bool` — If the user's response should be visible. Only valid when @@responseRequired is true.

**Functions:**
- `start()` — Start an authentication session. Returns if the session was started successfully.
- `abort()` — Abort a running authentication session.
- `respond(const QString& response)` — Respond to pam.

May not be called unless @@responseRequired is true.

**Signals:**
- `completed(PamResult::Enum result)` — Emitted whenever authentication completes.
- `error(PamError::Enum error)` — Emitted if pam fails to perform authentication normally.

A `completed(PamResult.Error)` will be emitted after this event.
- `pamMessage()` — Emitted whenever pam sends a new message, after the change signals for
`message`, `messageIsError`, and `responseRequired`.

---

### PamError
**Module:** `Quickshell.Services.Pam`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

An error that occurred during an authentication.
See @@PamContext.error(s).

**Signals:**
- `completed(PamResult::Enum result)`
- `error(PamError::Enum error)`
- `message(QString message, bool messageChanged, bool isError, bool responseRequired)`
- `onMessage()`

---

### PamResult
**Module:** `Quickshell.Services.Pam`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The result of an authentication.
See @@PamContext.completed(s).

---

## Quickshell.Services.Pipewire

### PwAudioChannel
**Module:** `Quickshell.Services.Pipewire`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Audio channel of a pipewire node.
See @@PwNodeAudio.channels.

---

### PwLink
**Module:** `Quickshell.Services.Pipewire`
**Inherits:** `PwObjectIface`

A connection between pipewire nodes.
Note that there is one link per *channel* of a connection between nodes.
You usually want @@PwLinkGroup.

**Properties:**
- `id` : `quint32` — The pipewire object id of the link.

Mainly useful for debugging. you can inspect the link directly
with `pw-cli i <id>`.
- `target` : `qs::service::pipewire::PwNodeIface*` — The node that is *receiving* information. (the sink)
- `source` : `qs::service::pipewire::PwNodeIface*` — The node that is *sending* information. (the source)
- `state` : `PwLinkState::Enum` — The current state of the link.

> [!WARNING] This property is invalid unless the node is bound using @@PwObjectTracker.

**Signals:**
- `stateChanged()`

---

### PwLinkGroup
**Module:** `Quickshell.Services.Pipewire`

A group of connections between pipewire nodes.
A group of connections between pipewire nodes, one per source->target pair.

**Properties:**
- `target` : `qs::service::pipewire::PwNodeIface*` — The node that is *receiving* information. (the sink)
- `source` : `qs::service::pipewire::PwNodeIface*` — The node that is *sending* information. (the source)
- `state` : `qs::service::pipewire::PwLinkState::Enum` — The current state of the link group.

> [!WARNING] This property is invalid unless the node is bound using @@PwObjectTracker.

**Signals:**
- `stateChanged()`

---

### PwLinkState
**Module:** `Quickshell.Services.Pipewire`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

State of a pipewire link.
See @@PwLink.state.

**Signals:**
- `stateChanged()`
- `setOutputNode(quint32 outputNode)`
- `setInputNode(quint32 inputNode)`
- `setState(pw_link_state state)`
- `stateChanged()`
- `onLinkRemoved(QObject* object)`

---

### PwNode
**Module:** `Quickshell.Services.Pipewire`
**Inherits:** `PwObjectIface`

A node in the pipewire connection graph.

**Properties:**
- `id` : `quint32` — The pipewire object id of the node.

Mainly useful for debugging. You can inspect the node directly
with `pw-cli i <id>`.
- `name` : `QString` — The node's name, corresponding to the object's `node.name` property.
- `description` : `QString` — The node's description, corresponding to the object's `node.description` property.

May be empty. Generally more human readable than @@name.
- `nickname` : `QString` — The node's nickname, corresponding to the object's `node.nickname` property.

May be empty. Generally but not always more human readable than @@description.
- `isSink` : `bool` — If `true`, then the node accepts audio input from other nodes,
if `false` the node outputs audio to other nodes.
- `isStream` : `bool` — If `true` then the node is likely to be a program, if `false` it is likely to be
a hardware device.
- `type` : `qs::service::pipewire::PwNodeType::Flags` — The type of this node. Reflects Pipewire's [media.class](https://docs.pipewire.org/page_man_pipewire-props_7.html).
- `properties` : `QVariantMap` — The property set present on the node, as an object containing key-value pairs.
You can inspect this directly with `pw-cli i <id>`.

A few properties of note, which may or may not be present:
- `application.name` - A suggested human readable name for the node.
- `application.icon-name` - The name of an icon recommended to display for the node.
- `media.name` - A description of the currently playing media.
(more likely to be present than `media.title` and `media.artist`)
- `media.title` - The title of the currently playing media.
- `media.artist` - The artist of the currently playing media.

> [!WARNING] This property is invalid unless the node is bound using @@PwObjectTracker.
- `audio` : `qs::service::pipewire::PwNodeAudioIface*` — Extra information present only if the node sends or receives audio.

The presence or absence of this property can be used to determine if a node
manages audio, regardless of if it is bound. If non null, the node is an audio node.
- `ready` : `bool` — True if the node is fully bound and ready to use.

> [!NOTE] The node may be used before it is fully bound, but some data
> may be missing or incorrect.

**Signals:**
- `propertiesChanged()`
- `readyChanged()`

---

### PwNodeAudio
**Module:** `Quickshell.Services.Pipewire`
**Inherits:** `QObject`

Audio specific properties of pipewire nodes.
Extra properties of a @@PwNode if the node is an audio node.

See @@PwNode.audio.

**Properties:**
- `muted` : `bool` — If the node is currently muted. Setting this property changes the mute state.

> [!WARNING] This property is invalid unless the node is bound using @@PwObjectTracker.
- `volume` : `float` — The average volume over all channels of the node.
Setting this property modifies the volume of all channels proportionately.

> [!WARNING] This property is invalid unless the node is bound using @@PwObjectTracker.
- `channels` : `QVector<qs::service::pipewire::PwAudioChannel::Enum>` — The audio channels present on the node.

> [!WARNING] This property is invalid unless the node is bound using @@PwObjectTracker.
- `volumes` : `QVector<float>` — The volumes of each audio channel individually. Each entry corresponds to
the volume of the channel at the same index in @@channels. @@volumes and @@channels
will always be the same length.

> [!WARNING] This property is invalid unless the node is bound using @@PwObjectTracker.

**Signals:**
- `mutedChanged()`
- `channelsChanged()`
- `volumesChanged()`

---

### PwNodeLinkTracker
**Module:** `Quickshell.Services.Pipewire`
**Inherits:** `QObject`

Tracks non-monitor link connections to a given node.

**Properties:**
- `node` : `qs::service::pipewire::PwNodeIface*` — The node to track connections to.
- `linkGroups` : `QQmlListProperty<qs::service::pipewire::PwLinkGroupIface>` — Link groups connected to the given node, excluding monitors.

If the node is a sink, links which target the node will be tracked.
If the node is a source, links which source the node will be tracked.

**Signals:**
- `nodeChanged()`
- `linkGroupsChanged()`
- `onNodeDestroyed()`
- `onLinkGroupCreated(PwLinkGroup* linkGroup)`
- `onLinkGroupDestroyed(QObject* object)`

---

### PwNodePeakMonitor
**Module:** `Quickshell.Services.Pipewire`
**Inherits:** `QObject`

Monitors peak levels of an audio node.
Tracks volume peaks for a node across all its channels.

The peak monitor binds nodes similarly to @@PwObjectTracker when enabled.

**Properties:**
- `node` : `qs::service::pipewire::PwNodeIface*` — The node to monitor. Must be an audio node.
- `enabled` : `bool` — If true, the monitor is actively capturing and computing peaks. Defaults to true.
- `peaks` : `QVector<float>` — Per-channel peak noise levels (0.0-1.0). Length matches @@channels.

The channel's volume does not affect this property.
- `peak` : `float` — Maximum value of @@peaks.
- `channels` : `QVector<qs::service::pipewire::PwAudioChannel::Enum>` — Channel positions for the captured format. Length matches @@peaks.

**Signals:**
- `nodeChanged()`
- `enabledChanged()`
- `peaksChanged()`
- `peakChanged()`
- `channelsChanged()`
- `onNodeDestroyed()`

---

### PwNodeType
**Module:** `Quickshell.Services.Pipewire`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

The type of a pipewire node.
Use bitwise comparisons to filter for audio, video, sink, source or stream nodes

**Signals:**
- `volumesChanged()`
- `channelsChanged()`
- `mutedChanged()`
- `onDeviceReady()`
- `onDeviceVolumesChanged(qint32 routeDevice, const PwVolumeProps& props)`
- `updateVolumeProps(const PwVolumeProps& volumeProps)`
- `propertiesChanged()`
- `readyChanged()`
- `onCoreSync(quint32 id, qint32 seq)`

---

### PwObjectTracker
**Module:** `Quickshell.Services.Pipewire`
**Inherits:** `QObject`

Binds pipewire objects.
PwObjectTracker binds every node given in its @@objects list.

#### Object Binding
By default, pipewire objects are unbound. Unbound objects only have a subset of
information available for use or modification. **Binding an object makes all of its
properties available for use or modification if applicable.**

Properties that require their object be bound to use are clearly marked. You do not
need to bind the object unless mentioned in the description of the property you
want to use.

**Properties:**
- `objects` : `QList<QObject*>` — The list of objects to bind. May contain nulls.

**Signals:**
- `objectsChanged()`
- `objectDestroyed(QObject* object)`
- `clearList()`

---

## Quickshell.Services.Polkit

### AuthFlow
**Module:** `Quickshell.Services.Polkit`

**Properties:**
- `message` : `QString` — The main message to present to the user.
- `iconName` : `QString` — The icon to present to the user in association with the message.

The icon name follows the [FreeDesktop icon naming specification](https://specifications.freedesktop.org/icon-naming-spec/icon-naming-spec-latest.html).
Use @@Quickshell.Quickshell.iconPath() to resolve the icon name to an
actual file path for display.
- `actionId` : `QString` — The action ID represents the action that is being authorized.

This is a machine-readable identifier.
- `cookie` : `QString` — A cookie that identifies this authentication request.

This is an internal identifier and not recommended to show to users.
- `identities` : `QList<Identity*>` — The list of identities that may be used to authenticate.

Each identity may be a user or a group. You may select any of them to
authenticate by setting @@selectedIdentity. By default, the first identity
in the list is selected.
- `selectedIdentity` : `Identity*` — The identity that will be used to authenticate.

Changing this will abort any ongoing authentication conversations and start a new one.
- `isResponseRequired` : `bool` — Indicates that a response from the user is required from the user,
typically a password.
- `inputPrompt` : `QString` — This message is used to prompt the user for required input.
- `responseVisible` : `bool` — Indicates whether the user's response should be visible. (e.g. for passwords this should be false)
- `supplementaryMessage` : `QString` — An additional message to present to the user.

This may be used to show errors or supplementary information.
See @@supplementaryIsError to determine if this is an error message.
- `supplementaryIsError` : `bool` — Indicates whether the supplementary message is an error.
- `isCompleted` : `bool` — Has the authentication request been completed.
- `isSuccessful` : `bool` — Indicates whether the authentication request was successful.
- `isCancelled` : `bool` — Indicates whether the current authentication request was cancelled.
- `failed` : `bool` — Indicates whether an authentication attempt has failed at least once during this authentication flow.

**Functions:**
- `submit(const QString& value)` — Submit a response to a request that was previously emitted. Typically the password.
- `cancelAuthenticationRequest()` — Cancel the ongoing authentication request from the user side.

**Signals:**
- `authenticationSucceeded()` — Emitted whenever an authentication request completes successfully.

---

### PolkitAgent
**Module:** `Quickshell.Services.Polkit`

**Properties:**
- `path` : `QString` — The D-Bus path that this agent listener will use.

If not set, a default of /org/quickshell/Polkit will be used.
- `isRegistered` : `bool` — Indicates whether the agent registered successfully and is in use.
- `isActive` : `bool` — Indicates an ongoing authentication request.

If this is true, other properties such as @@message and @@iconName will
also be populated with relevant information.
- `flow` : `AuthFlow*` — The current authentication state if an authentication request is active.

Null when no authentication request is active.

**Signals:**
- `authenticationRequestStarted()` — Emitted when an application makes a request that requires authentication.

At this point, @@state will be populated with relevant information.
Note that signals for conversation outcome are emitted from the @@AuthFlow instance.
- `isRegisteredChanged()`
- `isActiveChanged()`
- `flowChanged()`

---

## Quickshell.Services.UPower

### PerformanceDegradationReason
**Module:** `Quickshell.Services.UPower`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Reason for performance degradation exposed by the PowerProfiles service.
See @@PowerProfiles.degradationReason for more information.

**Properties:**
- `profile` : `qs::service::upower::PowerProfile::Enum`
- `applicationId` : `QString`
- `reason` : `QString`

---

### PowerProfile
**Module:** `Quickshell.Services.UPower`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Power profile exposed by the PowerProfiles service.
See @@PowerProfiles.

---

### PowerProfiles
**Module:** `Quickshell.Services.UPower`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

---

### PowerProfiles
**Module:** `Quickshell.Services.UPower`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Provides access to the Power Profiles service.
An interface to the UPower [power profiles daemon], which can be
used to view and manage power profiles.

> [!NOTE] The power profiles daemon must be installed to use this service.
> Installing UPower does not necessarily install the power profiles daemon.

[power profiles daemon]: https://gitlab.freedesktop.org/upower/power-profiles-daemon

**Properties:**
- `profile` : `qs::service::upower::PowerProfile::Enum` — The current power profile.

This property may be set to change the system's power profile, however
it cannot be set to `Performance` unless @@hasPerformanceProfile is true.
- `hasPerformanceProfile` : `bool` — If the system has a performance profile.

If this property is false, your system does not have a performance
profile known to power-profiles-daemon.
- `degradationReason` : `qs::service::upower::PerformanceDegradationReason::Enum` — If power-profiles-daemon detects degraded system performance, the reason
for the degradation will be present here.
- `holds` : `QList<qs::service::upower::PowerProfileHold>` — Power profile holds created by other applications.

This property returns a `powerProfileHold` object, which has the following properties.
- `profile` - The @@PowerProfile held by the application.
- `applicationId` - A string identifying the application
- `reason` - The reason the application has given for holding the profile.

Applications may "hold" a power profile in place for their lifetime, such
as a game holding Performance mode or a system daemon holding Power Saver mode
when reaching a battery threshold. If the user selects a different profile explicitly
(e.g. by setting @@profile$) all holds will be removed.

Multiple applications may hold a power profile, however if multiple applications request
profiles than `PowerSaver` will win over `Performance`. Only `Performance` and `PowerSaver`
profiles may be held.

**Signals:**
- `profileChanged()`
- `hasPerformanceProfileChanged()`
- `degradationReasonChanged()`
- `holdsChanged()`

---

### UPower
**Module:** `Quickshell.Services.UPower`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

**Signals:**
- `onBatteryChanged()`
- `onDeviceAdded(const QDBusObjectPath& path)`
- `onDeviceRemoved(const QDBusObjectPath& path)`
- `onDeviceReady()`

---

### UPower
**Module:** `Quickshell.Services.UPower`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Provides access to the UPower service.
An interface to the [UPower daemon], which can be used to
view battery and power statistics for your computer and
connected devices.

> [!NOTE] The UPower daemon must be installed to use this service.

[UPower daemon]: https://upower.freedesktop.org

**Properties:**
- `displayDevice` : `qs::service::upower::UPowerDevice*` — UPower's DisplayDevice for your system. Cannot be null,
but might not be initialized (check @@UPowerDevice.ready if you need to know).

This is an aggregate device and not a physical one, meaning you will not find it in @@devices.
It is typically the device that is used for displaying information in desktop environments.
- `devices` : `UntypedObjectModel*`
- `onBattery` : `bool` — If the system is currently running on battery power, or discharging.

**Signals:**
- `onBatteryChanged()`

---

### UPowerDevice
**Module:** `Quickshell.Services.UPower`
**Inherits:** `QObject`

A device exposed through the UPower system service.

**Properties:**
- `type` : `qs::service::upower::UPowerDeviceType::Enum` — The type of device.
- `powerSupply` : `bool` — If the device is a power supply for your computer and can provide charge.
- `energy` : `qreal` — Current energy level of the device in watt-hours.
- `energyCapacity` : `qreal` — Maximum energy capacity of the device in watt-hours
- `changeRate` : `qreal` — Rate of energy change in watts (positive when charging, negative when discharging).
- `timeToEmpty` : `qreal` — Estimated time until the device is fully discharged, in seconds.

Will be set to `0` if charging.
- `timeToFull` : `qreal` — Estimated time until the device is fully charged, in seconds.

Will be set to `0` if discharging.
- `percentage` : `qreal` — Current charge level as a percentage.

This would be equivalent to @@energy / @@energyCapacity.
- `isPresent` : `bool` — If the power source is present in the bay or slot, useful for hot-removable batteries.

If the device `type` is not `Battery`, then the property will be invalid.
- `state` : `qs::service::upower::UPowerDeviceState::Enum` — Current state of the device.
- `healthPercentage` : `qreal` — Health of the device as a percentage of its original health.
- `healthSupported` : `bool`
- `iconName` : `QString` — Name of the icon representing the current state of the device, or an empty string if not provided.
- `isLaptopBattery` : `bool` — If the device is a laptop battery or not. Use this to check if your device is a valid battery.

This will be equivalent to @@type == Battery && @@powerSupply == true.
- `nativePath` : `QString` — Native path of the device specific to your OS.
- `model` : `QString` — Model name of the device. Unlikely to be useful for internal devices.
- `ready` : `bool` — If device statistics have been queried for this device yet.
This will be true for all devices returned from @@UPower.devices, but not the default
device, which may be returned before it is ready to avoid returning null.

**Signals:**
- `typeChanged()`
- `powerSupplyChanged()`
- `energyChanged()`
- `energyCapacityChanged()`
- `changeRateChanged()`
- `timeToEmptyChanged()`
- `timeToFullChanged()`
- `percentageChanged()`

---

### UPowerDeviceState
**Module:** `Quickshell.Services.UPower`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Power state of a UPower device.
See @@UPowerDevice.state.

---

### UPowerDeviceType
**Module:** `Quickshell.Services.UPower`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Type of a UPower device.
See @@UPowerDevice.type.

---

## Quickshell.Wayland

### BackgroundEffect
**Module:** `Quickshell.Wayland`
**Inherits:** `QObject`

Background blur effect for Wayland surfaces.
Applies background blur behind a @@Quickshell.QsWindow or subclass,
as an attached object, using the [ext-background-effect-v1] Wayland protocol.

> [!NOTE] Using a background effect requires the compositor support the
> [ext-background-effect-v1] protocol.

[ext-background-effect-v1]: https://wayland.app/protocols/ext-background-effect-v1

#### Example
```qml
@@Quickshell.PanelWindow {
id: root
color: "#80000000"

BackgroundEffect.blurRegion: Region { item: root.contentItem }
}
```

**Properties:**
- `blurRegion` : `PendingRegion*` — Region to blur behind the surface. Set to null to remove blur.

**Signals:**
- `blurRegionChanged()`
- `onWindowConnected()`
- `onWindowVisibleChanged()`
- `onWaylandWindowDestroyed()`
- `onWaylandSurfaceCreated()`
- `onWaylandSurfaceDestroyed()`
- `onProxyWindowDestroyed()`
- `onBlurRegionDestroyed()`

---

### IdleInhibitor
**Module:** `Quickshell.Wayland`
**Inherits:** `QObject`

Prevents a wayland session from idling
If an idle daemon is running, it may perform actions such as locking the screen
or putting the computer to sleep.

An idle inhibitor prevents a wayland session from being marked as idle, if compositor
defined heuristics determine the window the inhibitor is attached to is important.

A compositor will usually consider a @@Quickshell.PanelWindow or
a focused @@Quickshell.FloatingWindow to be important.

> [!NOTE] Using an idle inhibitor requires the compositor support the [idle-inhibit-unstable-v1] protocol.

[idle-inhibit-unstable-v1]: https://wayland.app/protocols/idle-inhibit-unstable-v1

**Properties:**
- `enabled` : `bool` — If the idle inhibitor should be enabled. Defaults to false.
- `window` : `QObject*` — The window to associate the idle inhibitor with. This may be used by the compositor
to determine if the inhibitor should be respected.

Must be set to a non null value to enable the inhibitor.

**Signals:**
- `enabledChanged()`
- `windowChanged()`
- `onWindowDestroyed()`
- `onWindowVisibilityChanged()`
- `onWaylandWindowDestroyed()`
- `onWaylandSurfaceCreated()`
- `onWaylandSurfaceDestroyed()`

---

### IdleMonitor
**Module:** `Quickshell.Wayland`
**Inherits:** `PostReloadHook`

Provides a notification when a wayland session is makred idle
An idle monitor detects when the user stops providing input for a period of time.

> [!NOTE] Using an idle monitor requires the compositor support the [ext-idle-notify-v1] protocol.

[ext-idle-notify-v1]: https://wayland.app/protocols/ext-idle-notify-v1

**Properties:**
- `enabled` : `bool` — If the idle monitor should be enabled. Defaults to true.
- `timeout` : `qreal` — The amount of time in seconds the idle monitor should wait before reporting an idle state.

Defaults to zero, which reports idle status immediately.
- `respectInhibitors` : `bool` — When set to true, @@isIdle will depend on both user interaction and active idle inhibitors.
When false, the value will depend solely on user interaction. Defaults to true.
- `isIdle` : `bool` — This property is true if the user has been idle for at least @@timeout.
What is considered to be idle is influenced by @@respectInhibitors.

**Signals:**
- `enabledChanged()`
- `timeoutChanged()`
- `respectInhibitorsChanged()`
- `isIdleChanged()`
- `updateNotification()`

---

### ScreencopyView
**Module:** `Quickshell.Wayland`
**Inherits:** `QQuickItem`

Displays a video stream from other windows or a monitor.
ScreencopyView displays live video streams or single captured frames from valid
capture sources. See @@captureSource for details on which objects are accepted.

**Properties:**
- `captureSource` : `QObject*` — The object to capture from. Accepts any of the following:
- `null` - Clears the displayed image.
- @@Quickshell.ShellScreen - A monitor.
Requires a compositor that supports `wlr-screencopy-unstable`
or both `ext-image-copy-capture-v1` and `ext-capture-source-v1`.
- @@Quickshell.Wayland.Toplevel - A toplevel window.
Requires a compositor that supports `hyprland-toplevel-export-v1`.
- `paintCursor` : `bool` — If true, the system cursor will be painted on the image. Defaults to false.
- `live` : `bool` — If true, a live video feed from the capture source will be displayed instead of a still image.
Defaults to false.
- `hasContent` : `bool` — If true, the view has content ready to display. Content is not always immediately available,
and this property can be used to avoid displaying it until ready.
- `sourceSize` : `QSize` — The size of the source image. Valid when @@hasContent is true.
- `constraintSize` : `QSizeF` — If nonzero, the width and height constraints set for this property will constrain those
dimensions of the ScreencopyView's implicit size, maintaining the image's aspect ratio.

**Functions:**
- `captureFrame()` — Capture a single frame. Has no effect if @@live is true.

**Signals:**
- `stopped()` — The compositor has ended the video stream. Attempting to restart it may or may not work.
- `captureSourceChanged()`
- `paintCursorsChanged()`
- `liveChanged()`
- `hasContentChanged()`
- `sourceSizeChanged()`
- `constraintSizeChanged()`

---

### ShortcutInhibitor
**Module:** `Quickshell.Wayland`
**Inherits:** `QObject`

Prevents compositor keyboard shortcuts from being triggered
A shortcuts inhibitor prevents the compositor from processing its own keyboard shortcuts
for the focused surface. This allows applications to receive key events for shortcuts
that would normally be handled by the compositor.

The inhibitor only takes effect when the associated window is focused and the inhibitor
is enabled. The compositor may choose to ignore inhibitor requests based on its policy.

> [!NOTE] Using a shortcuts inhibitor requires the compositor support the [keyboard-shortcuts-inhibit-unstable-v1] protocol.

[keyboard-shortcuts-inhibit-unstable-v1]: https://wayland.app/protocols/keyboard-shortcuts-inhibit-unstable-v1

**Properties:**
- `enabled` : `bool` — If the shortcuts inhibitor should be enabled. Defaults to false.
- `window` : `QObject*` — The window to associate the shortcuts inhibitor with.
The inhibitor will only inhibit shortcuts pressed while this window has keyboard focus.

Must be set to a non null value to enable the inhibitor.
- `active` : `bool` — Whether the inhibitor is currently active. The inhibitor is only active if @@enabled is true,
@@window has keyboard focus, and the compositor grants the inhibit request.

The compositor may deactivate the inhibitor at any time (for example, if the user requests
normal shortcuts to be restored). When deactivated by the compositor, the inhibitor cannot be
programmatically reactivated.

**Signals:**
- `enabledChanged()`
- `windowChanged()`
- `activeChanged()`
- `cancelled()` — Sent if the compositor cancels the inhibitor while it is active.
- `onWindowDestroyed()`
- `onWindowVisibilityChanged()`
- `onWaylandWindowDestroyed()`

---

### Toplevel
**Module:** `Quickshell.Wayland`
**Inherits:** `QObject`

Window from another application.
A window/toplevel from another application, retrievable from
the @@ToplevelManager.

**Properties:**
- `appId` : `QString`
- `title` : `QString`
- `parent` : `qs::wayland::toplevel::Toplevel*` — Parent toplevel if this toplevel is a modal/dialog, otherwise null.
- `activated` : `bool` — If the window is currently activated or focused.

Activation can be requested with the @@activate() function.
- `screens` : `QList<QuickshellScreenInfo*>` — Screens the toplevel is currently visible on.
Screens are listed in the order they have been added by the compositor.

> [!NOTE]	Some compositors only list a single screen, even if a window is visible on multiple.
- `maximized` : `bool` — If the window is currently maximized.

Maximization can be requested by setting this property, though it may
be ignored by the compositor.
- `minimized` : `bool` — If the window is currently minimized.

Minimization can be requested by setting this property, though it may
be ignored by the compositor.
- `fullscreen` : `bool` — If the window is currently fullscreen.

Fullscreen can be requested by setting this property, though it may
be ignored by the compositor.
Fullscreen can be requested on a specific screen with the @@fullscreenOn() function.

**Functions:**
- `activate()` — Request that this toplevel is activated.
The request may be ignored by the compositor.
- `close()` — Request that this toplevel is closed.
The request may be ignored by the compositor or the application.
- `fullscreenOn(QuickshellScreenInfo* screen)` — Request that this toplevel is fullscreened on a specific screen.
The request may be ignored by the compositor.
- `setRectangle(QObject* window, QRect rect)` — Provide a hint to the compositor where the visual representation
of this toplevel is relative to a quickshell window.
This hint can be used visually in operations like minimization.
- `unsetRectangle()`

**Signals:**
- `closed()`
- `appIdChanged()`
- `titleChanged()`
- `parentChanged()`
- `activatedChanged()`
- `screensChanged()`
- `maximizedChanged()`
- `minimizedChanged()`
- `fullscreenChanged()`

---

### ToplevelManager
**Module:** `Quickshell.Wayland`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

**Signals:**
- `activeToplevelChanged()`
- `onToplevelReady(wlr::ToplevelHandle* handle)`
- `onToplevelActiveChanged()`
- `onToplevelClosed()`

---

### ToplevelManager
**Module:** `Quickshell.Wayland`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Exposes a list of Toplevels.
Exposes a list of windows from other applications as @@Toplevel$s via the
[zwlr-foreign-toplevel-management-v1](https://wayland.app/protocols/wlr-foreign-toplevel-management-unstable-v1)
wayland protocol.

**Properties:**
- `toplevels` : `UntypedObjectModel*`
- `activeToplevel` : `qs::wayland::toplevel::Toplevel*` — Active toplevel or null.

> [!INFO] If multiple are active, this will be the most recently activated one.
> Usually compositors will not report more than one toplevel as active at a time.

**Signals:**
- `activeToplevelChanged()`

---

### WlSessionLock
**Module:** `Quickshell.Wayland`
**Inherits:** `Reloadable`

Wayland session locker.
Wayland session lock implemented using the [ext_session_lock_v1] protocol.

WlSessionLock will create an instance of its `surface` component for every screen when
`locked` is set to true. The `surface` component must create a @@WlSessionLockSurface
which will be displayed on each screen.

The below example will create a session lock that disappears when the button is clicked.
```qml
WlSessionLock {
id: lock

WlSessionLockSurface {
Button {
text: "unlock me"
onClicked: lock.locked = false
}
}
}

// ...
lock.locked = true
```

> [!WARNING] If the WlSessionLock is destroyed or quickshell exits without setting `locked`
> to false, conformant compositors will leave the screen locked and painted with a solid
> color.
>
> This is what makes the session lock secure. The lock dying will not expose your session,
> but it will render it inoperable.

[ext_session_lock_v1]: https://wayland.app/protocols/ext-session-lock-v1

**Properties:**
- `locked` : `bool` — Controls the lock state.

> [!WARNING] Only one WlSessionLock may be locked at a time. Attempting to enable a lock while
> another lock is enabled will do nothing.
- `secure` : `bool` — The compositor lock state.

This is set to true once the compositor has confirmed all screens are covered with locks.
- `surface` : `QQmlComponent*` — The surface that will be created for each screen. Must create a @@WlSessionLockSurface$.

**Signals:**
- `lockStateChanged()`
- `secureStateChanged()`
- `surfaceComponentChanged()`
- `unlock()`
- `onScreensChanged()`
- `updateSurfaces(bool show, WlSessionLock* old = nullptr)`

---

### WlSessionLockSurface
**Module:** `Quickshell.Wayland`
**Inherits:** `Reloadable`

Surface to display with a `WlSessionLock`.
Surface displayed by a @@WlSessionLock when it is locked.

**Properties:**
- `contentItem` : `QQuickItem*`
- `visible` : `bool` — If the surface has been made visible.

Note: SessionLockSurfaces will never become invisible, they will only be destroyed.
- `width` : `qint32`
- `height` : `qint32`
- `screen` : `QuickshellScreenInfo*` — The screen that the surface is displayed on.
- `color` : `QColor` — The background color of the window. Defaults to white.

> [!WARNING] This seems to behave weirdly when using transparent colors on some systems.
> Using a colored content item over a transparent window is the recommended way to work around this:
> ```qml
> ProxyWindow {
>   Rectangle {
>     anchors.fill: parent
>     color: "#20ffffff"
>
>     // your content here
>   }
> }
> ```
> ... but you probably shouldn't make a transparent lock,
> and most compositors will ignore an attempt to do so.
- `data` : `QQmlListProperty<QObject>`

**Signals:**
- `visibleChanged()`
- `widthChanged()`
- `heightChanged()`
- `screenChanged()`
- `colorChanged()`
- `onScreenDestroyed()`
- `onWidthChanged()`
- `onHeightChanged()`

---

### WlrLayershell
**Module:** `Quickshell.Wayland`
**Inherits:** `PanelWindowInterface`

Wlroots layershell window
Decorationless window that can be attached to the screen edges using the [zwlr_layer_shell_v1] protocol.

#### Attached object
`WlrLayershell` works as an attached object of @@Quickshell.PanelWindow which you should use instead if you can,
as it is platform independent.

```qml
PanelWindow {
// When PanelWindow is backed with WlrLayershell this will work
WlrLayershell.layer: WlrLayer.Bottom
}
```

To maintain platform compatibility you can dynamically set layershell specific properties.
```qml
PanelWindow {
Component.onCompleted: {
if (this.WlrLayershell != null) {
this.WlrLayershell.layer = WlrLayer.Bottom;
}
}
}
```

[zwlr_layer_shell_v1]: https://wayland.app/protocols/wlr-layer-shell-unstable-v1

**Properties:**
- `layer` : `qs::wayland::layershell::WlrLayer::Enum` — The shell layer the window sits in. Defaults to `WlrLayer.Top`.
- `namespace` : `QString` — Similar to the class property of windows. Can be used to identify the window to external tools.

Cannot be set after windowConnected.
- `keyboardFocus` : `qs::wayland::layershell::WlrKeyboardFocus::Enum` — The degree of keyboard focus taken. Defaults to `KeyboardFocus.None`.

**Signals:**
- `layerChanged()`
- `namespaceChanged()`
- `keyboardFocusChanged()`
- `updateAutoExclusion()`

---

## Quickshell.Widgets

### MarginWrapperManager
**Module:** `Quickshell.Widgets`
**Inherits:** `WrapperManager`

Helper object for applying sizes and margins to a single child item.
> [!NOTE] MarginWrapperManager is an extension of @@WrapperManager.
> You should read its documentation to understand wrapper types.

MarginWrapperManager can be used to apply margins to a child item,
in addition to handling the size / implicit size relationship
between the parent and the child. @@WrapperItem and @@WrapperRectangle
exist for Item and Rectangle implementations respectively.

> [!WARNING] MarginWrapperManager based types set the child item's
> @@QtQuick.Item.x, @@QtQuick.Item.y, @@QtQuick.Item.width, @@QtQuick.Item.height
> or @@QtQuick.Item.anchors properties. Do not set them yourself,
> instead set @@Item.implicitWidth and @@Item.implicitHeight.

### Implementing a margin wrapper type
Follow the directions in @@WrapperManager$'s documentation, and or
alias the @@margin property if you wish to expose it.

## Margin calculation
The margin of the content item is calculated based on @@topMargin, @@bottomMargin,
@@leftMargin, @@rightMargin, @@extraMargin and @@resizeChild.

If @@resizeChild is `true`, each side's margin will be the value of `<side>Margin`
plus @@extraMargin, and the content item will be stretched to match the given margin
if the wrapper is not at its implicit size.

If @@resizeChild is `false`, the `<side>Margin` properties will be interpreted as a
ratio and the content item will not be stretched if the wrapper is not at its implicit side.

The implicit size of the wrapper is the implicit size of the content item
plus all margins.

**Properties:**
- `margin` : `qreal` — The default for @@topMargin, @@bottomMargin, @@leftMargin and @@rightMargin.
Defaults to 0.
- `extraMargin` : `qreal` — An extra margin applied in addition to @@topMargin, @@bottomMargin,
@@leftMargin, and @@rightMargin. Defaults to 0.
- `topMargin` : `qreal` — The requested top margin of the content item, not counting @@extraMargin.

Defaults to @@margin, and may be reset by assigning `undefined`.
- `bottomMargin` : `qreal` — The requested bottom margin of the content item, not counting @@extraMargin.

Defaults to @@margin, and may be reset by assigning `undefined`.
- `leftMargin` : `qreal` — The requested left margin of the content item, not counting @@extraMargin.

Defaults to @@margin, and may be reset by assigning `undefined`.
- `rightMargin` : `qreal` — The requested right margin of the content item, not counting @@extraMargin.

Defaults to @@margin, and may be reset by assigning `undefined`.
- `resizeChild` : `bool` — Determines if child item should be resized larger than its implicit size if
the parent is resized larger than its implicit size. Defaults to true.
- `implicitWidth` : `qreal` — Overrides the implicit width of the wrapper.

Defaults to the implicit width of the content item plus its left and right margin,
and may be reset by assigning `undefined`.
- `implicitHeight` : `qreal` — Overrides the implicit height of the wrapper.

Defaults to the implicit width of the content item plus its top and bottom margin,
and may be reset by assigning `undefined`.

**Signals:**
- `marginChanged()`
- `extraMarginChanged()`
- `topMarginChanged()`
- `bottomMarginChanged()`
- `leftMarginChanged()`
- `rightMarginChanged()`
- `resizeChildChanged()`
- `implicitWidthChanged()`
- `implicitHeightChanged()`

---

### WrapperManager
**Module:** `Quickshell.Widgets`

Helper object for creating components with a single visual child.
WrapperManager determines which child of an Item should be its visual
child, and exposes it for further operations. See @@MarginWrapperManager
for a subclass that implements automatic sizing and margins.

### Using wrapper types
WrapperManager based types have a single visual child item.
You can specify the child item using the default property, or by
setting the @@child property. You must use the @@child property if
the widget has more than one @@QtQuick.Item based child.

#### Example using the default property
```qml
WrapperWidget { // a widget that uses WrapperManager
// Putting the item inline uses the default property of WrapperWidget.
@@QtQuick.Text { text: "Hello" }

// Scope does not extend Item, so it can be placed in the
// default property without issue.
@@Quickshell.Scope {}
}
```

#### Example using the child property
```qml
WrapperWidget {
@@QtQuick.Text {
id: text
text: "Hello"
}

@@QtQuick.Text {
id: otherText
text: "Other Text"
}

// Both text and otherText extend Item, so one must be specified.
child: text
}
```

See @@child for more details on how the child property can be used.

### Implementing wrapper types
In addition to the bundled wrapper types, you can make your own using
WrapperManager. To implement a wrapper, create a WrapperManager inside
your wrapper component 's default property, then alias a new property
to the WrapperManager's @@child property.

#### Example
```qml
Item { // your wrapper component
WrapperManager { id: wrapperManager }

// Allows consumers of your wrapper component to use the child property.
property alias child: wrapperManager.child

// The rest of your component logic. You can use
// `wrapperManager.child` or `this.child` to refer to the selected child.
}
```

### See also
- @@WrapperItem - A @@MarginWrapperManager based component that sizes itself
to its child.
- @@WrapperRectangle - A @@MarginWrapperManager based component that sizes
itself to its child, and provides an option to use its border as an inset.

**Properties:**
- `child` : `QQuickItem*` — The wrapper component's selected child.

Setting this property override's WrapperManager's default selection,
and resolve ambiguity when more than one visual child is present.
The property can additionally be defined inline or reference a component
that is not already a child of the wrapper, in which case it will be
reparented to the wrapper. Setting child to `null` will select no child,
and `undefined` will restore the default child.

When read, `child` will always return the (potentially null) selected child,
and not `undefined`.
- `wrapper` : `QQuickItem*` — The wrapper managed by this manager. Defaults to the manager's parent.
This property may not be changed after Component.onCompleted.

**Signals:**
- `childChanged()`
- `wrapperChanged()`
- `onChildDestroyed()`

---

## Quickshell.WindowManager

### Anchors
**Module:** `Quickshell.WindowManager`

**Properties:**
- `left` : `bool`
- `right` : `bool`
- `top` : `bool`
- `bottom` : `bool`

---

### FloatingWindow
**Module:** `Quickshell.WindowManager`
**Inherits:** `WindowInterface`

Standard toplevel operating system window that looks like any other application.

**Properties:**
- `title` : `QString` — Window title.
- `minimumSize` : `QSize` — Minimum window size given to the window system.
- `maximumSize` : `QSize` — Maximum window size given to the window system.
- `minimized` : `bool` — Whether the window is currently minimized.
- `maximized` : `bool` — Whether the window is currently maximized.
- `fullscreen` : `bool` — Whether the window is currently fullscreen.
- `parentWindow` : `QObject*` — The parent window of this window. Setting this makes the window a child of the parent,
which affects window stacking behavior.

> [!NOTE] This property cannot be changed after the window is visible.

**Signals:**
- `minimumSizeChanged()`
- `maximumSizeChanged()`
- `titleChanged()`
- `minimizedChanged()`
- `maximizedChanged()`
- `fullscreenChanged()`
- `parentWindowChanged()`
- `onWindowConnected()`

---

### PanelWindow
**Module:** `Quickshell.WindowManager`
**Inherits:** `WindowInterface`

Decorationless window attached to screen edges by anchors.
Decorationless window attached to screen edges by anchors.

#### Example
The following snippet creates a white bar attached to the bottom of the screen.

```qml
PanelWindow {
anchors {
left: true
bottom: true
right: true
}

Text {
anchors.centerIn: parent
text: "Hello!"
}
}
```

**Properties:**
- `anchors` : `Anchors` — Anchors attach a shell window to the sides of the screen.
By default all anchors are disabled to avoid blocking the entire screen due to a misconfiguration.

> [!INFO] When two opposite anchors are attached at the same time, the corresponding dimension
> (width or height) will be forced to equal the screen width/height.
> Margins can be used to create anchored windows that are also disconnected from the monitor sides.
- `margins` : `Margins` — Offsets from the sides of the screen.

> [!INFO] Only applies to edges with anchors
- `exclusiveZone` : `qint32` — The amount of space reserved for the shell layer relative to its anchors.
Setting this property sets @@exclusionMode to `ExclusionMode.Normal`.

> [!INFO] Either 1 or 3 anchors are required for the zone to take effect.
- `exclusionMode` : `ExclusionMode::Enum` — Defaults to `ExclusionMode.Auto`.
- `aboveWindows` : `bool` — If the panel should render above standard windows. Defaults to true.

Note: On Wayland this property corresponds to @@Quickshell.Wayland.WlrLayershell.layer.
- `focusable` : `bool` — If the panel should accept keyboard focus. Defaults to false.

Note: On Wayland this property corresponds to @@Quickshell.Wayland.WlrLayershell.keyboardFocus.

**Signals:**
- `anchorsChanged()`
- `marginsChanged()`
- `exclusiveZoneChanged()`
- `exclusionModeChanged()`
- `aboveWindowsChanged()`
- `focusableChanged()`

---

### PopupWindow
**Module:** `Quickshell.WindowManager`
**Inherits:** `WindowInterface`

Popup window.
Popup window that can display in a position relative to a floating
or panel window.

#### Example
The following snippet creates a panel with a popup centered over it.

```qml
PanelWindow {
id: toplevel

anchors {
bottom: true
left: true
right: true
}

PopupWindow {
anchor.window: toplevel
anchor.rect.x: parentWindow.width / 2 - width / 2
anchor.rect.y: parentWindow.height
width: 500
height: 500
visible: true
}
}
```

**Properties:**
- `parentWindow` : `QObject*` — > [!ERROR] Deprecated in favor of `anchor.window`.

The parent window of this popup.

Changing this property reparents the popup.
- `relativeX` : `qint32` — > [!ERROR] Deprecated in favor of `anchor.rect.x`.

The X position of the popup relative to the parent window.
- `relativeY` : `qint32` — > [!ERROR] Deprecated in favor of `anchor.rect.y`.

The Y position of the popup relative to the parent window.
- `anchor` : `PopupAnchor*` — The popup's anchor / positioner relative to another item or window. The popup will
not be shown until it has a valid anchor relative to a window and @@visible is true.

You can set properties of the anchor like so:
```qml
PopupWindow {
anchor.window: parentwindow
// or
anchor {
window: parentwindow
}
}
```
- `grabFocus` : `bool` — If true, the popup window will be dismissed and @@visible will change to false
if the user clicks outside of the popup or it is otherwise closed.

> [!WARNING] Changes to this property while the window is open will only take
> effect after the window is hidden and shown again.

> [!NOTE] Under Hyprland, @@Quickshell.Hyprland.HyprlandFocusGrab provides more advanced
> functionality such as detecting clicks outside without closing the popup.

**Signals:**
- `parentWindowChanged()`
- `relativeXChanged()`
- `relativeYChanged()`
- `grabFocusChanged()`
- `onParentWindowChanged()`
- `onClosed()`
- `reposition()`

---

### ScreenProjection
**Module:** `Quickshell.WindowManager`
**Inherits:** `WindowsetProjection`

WindowsetProjection covering one specific screen.
A ScreenProjection is a special type of @@WindowsetProjection which aggregates
all windowsets across all projections covering a specific screen.

When used with @@Windowset.setProjection(), an arbitrary projection on the screen
will be picked. Usually there is only one.

Use @@WindowManager.screenProjection() to get a ScreenProjection for a given screen.

---

### WindowManager
**Module:** `Quickshell.WindowManager`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

**Functions:**
- `screenProjection(QuickshellScreenInfo* screen)`

**Signals:**
- `windowsetsChanged()`
- `windowsetProjectionsChanged()`

---

### WindowManager
**Module:** `Quickshell.WindowManager`
**Inherits:** `QObject`
**Singleton** (access via type name, do not instantiate)

Window management interfaces exposed by the window manager.

**Properties:**
- `windowsets` : `QList<Windowset*>` — All windowsets tracked by the WM across all projections.
- `windowsetProjections` : `QList<WindowsetProjection*>` — All windowset projections tracked by the WM. Does not include
internal projections from @@screenProjection().

---

### Windowset
**Module:** `Quickshell.WindowManager`
**Inherits:** `QObject`

A group of windows worked with by a user, usually known as a Workspace or Tag.
A Windowset is a generic type that encompasses both "Workspaces" and "Tags" in window managers.
Because the definition encompasses both you may not necessarily need all features.

**Properties:**
- `id` : `QString` — A persistent internal identifier for the windowset. This property should be identical
across restarts and destruction/recreation of a windowset.
- `name` : `QString` — Human readable name of the windowset.
- `coordinates` : `QList<qint32>` — Coordinates of the workspace, represented as an N-dimensional array. Most WMs
will only expose one coordinate. If more than one is exposed, the first is
conventionally X, the second Y, and the third Z.
- `active` : `bool` — True if the windowset is currently active. In a workspace based WM, this means the
represented workspace is current. In a tag based WM, this means the represented tag
is active.
- `projection` : `WindowsetProjection*` — The projection this windowset is a member of. A projection is the set of screens covered by
a windowset.
- `shouldDisplay` : `bool` — If false, this windowset should generally be hidden from workspace pickers.
- `urgent` : `bool` — If true, a window in this windowset has been marked as urgent.
- `canActivate` : `bool` — If true, the windowset can be activated. In a workspace based WM, this will make the workspace
current, in a tag based wm, the tag will be activated.
- `canDeactivate` : `bool` — If true, the windowset can be deactivated. In a workspace based WM, deactivation is usually implicit
and based on activation of another workspace.
- `canRemove` : `bool` — If true, the windowset can be removed. This may be done implicitly by the WM as well.
- `canSetProjection` : `bool` — If true, the windowset can be moved to a different projection.

**Signals:**
- `idChanged()`
- `nameChanged()`
- `coordinatesChanged()`
- `activeChanged()`
- `projectionChanged()`
- `shouldDisplayChanged()`
- `urgentChanged()`
- `canActivateChanged()`
- `canDeactivateChanged()`
- `canRemoveChanged()`

---

### WindowsetProjection
**Module:** `Quickshell.WindowManager`
**Inherits:** `QObject`

A space occupiable by a Windowset.
A WindowsetProjection represents a space that can be occupied by one or more @@Windowset$s.
The space is one or more screens. Multiple projections may occupy the same screens.

@@WindowManager.screenProjection() can be used to get a projection representing all
@@Windowset$s on a given screen regardless of the WM's actual projection layout.

**Properties:**
- `screens` : `QList<QuickshellScreenInfo*>` — Screens the windowset projection spans, often a single screen or all screens.
- `windowsets` : `QList<Windowset*>` — Windowsets that are currently present on the projection.

**Signals:**
- `screensChanged()`
- `windowsetsChanged()`

---