// wallpaper/WallpaperPicker.qml
// Fullscreen wallpaper picker overlay — parallelogram slice carousel.
//
// Architecture notes:
//   • ONE PanelWindow (WlrLayer.Overlay, fullscreen, exclusive keyboard)
//   • Visibility driven by SessionState.wallpaperPickerVisible — no new singleton
//   • Wallpaper data comes from the existing Wallpaper service singleton
//   • setWallpaper() calls Wallpaper.setWallpaper(path) — no shell logic in QML
//   • Colors come from PanelColors only — never Colors.* directly
//   • No qmldir — feature folder rule

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Shapes
import QtQuick.Effects
import "../theme"
import "../services"
import "../state"

PanelWindow {
    id: root

    property bool _suppressWidthAnim: false

    // ── IPC trigger ───────────────────────────────────────────────────────
    // Hyprland keybind (SUPER+W) calls:
    //   quickshell ipc call wallpaper-picker toggle
    IpcHandler {
        target: "wallpaper-picker"
        readonly property bool pickerVisible: SessionState.wallpaperPickerVisible

        function toggle(): void {
            if (SessionState.wallpaperPickerVisible) {
                SessionState.wallpaperPickerVisible = false
            } else {
                SessionState.closeAllPopups()
                SessionState.wallpaperPickerVisible = true
            }
        }
    }

    // ── Window setup ──────────────────────────────────────────────────────
    anchors { top: true; bottom: true; left: true; right: true }
    margins { top: 0; bottom: 0; left: 0; right: 0 }

    visible: SessionState.wallpaperPickerVisible
    color: "transparent"

    WlrLayershell.namespace:     "wallpaper-picker"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    // ── Carousel geometry constants ───────────────────────────────────────
    readonly property int _expandedW:  800   // focused slice width
    readonly property int _sliceW:     130   // collapsed slice width
    readonly property int _sliceH:     520   // height of the carousel track
    readonly property int _skewPx:      35   // parallelogram top-shift in px
    readonly property int _spacing:    -30   // negative spacing to overlap/interlock!

    // ── Dim backdrop (darker dim to improve visibility and contrast) ──────
    Rectangle {
        id: _backdrop
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        opacity: visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.durationSlow ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

        MouseArea {
            anchors.fill: parent
            onClicked: SessionState.wallpaperPickerVisible = false
        }
    }

    // ── Card container ────────────────────────────────────────────────────
    Item {
        id: _card
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: root._sliceH + _toolbar.height + 68

        // Slide/zoom/fade entry animation
        opacity: root.visible ? 1.0 : 0.0
        scale: root.visible ? 1.0 : 0.95

        Behavior on opacity { NumberAnimation { duration: Theme.durationSlow; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        Behavior on scale { NumberAnimation { duration: Theme.durationSlow; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

        // Keyboard dismissal
        focus: root.visible
        Keys.onEscapePressed: SessionState.wallpaperPickerVisible = false

        // ── Toolbar ───────────────────────────────────────────────────────
        Item {
            id: _toolbar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 64

            // Header Title
            Text {
                anchors.centerIn: parent
                text: "WALLPAPERS"
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.fontSizeMd
                font.weight:      Theme.fontWeightBold
                font.letterSpacing: 3
                color:            "#ffffff"
            }
        }

        // ── Carousel ListView ─────────────────────────────────────────────
        ListView {
            id: _listView

            anchors.top:              _toolbar.bottom
            anchors.topMargin:        16
            anchors.bottom:           _statusBar.top
            anchors.bottomMargin:     16
            anchors.left:             parent.left
            anchors.right:            parent.right

            orientation: ListView.Horizontal
            spacing:     root._spacing
            clip:        false

            model: Wallpaper.wallpapers
            cacheBuffer: root._expandedW * 2

            // Center the focused item in the viewport
            preferredHighlightBegin: (width - root._expandedW) / 2
            preferredHighlightEnd:   (width + root._expandedW) / 2
            highlightRangeMode:      ListView.StrictlyEnforceRange
            highlightFollowsCurrentItem: true
            highlightMoveDuration:   Theme.durationSlow
            highlight:               Item {}   // no visual highlight — SliceItem handles focus itself

            // Padding so first/last items can reach center
            header: Item { width: (_listView.width - root._expandedW) / 2; height: 1 }
            footer: Item { width: (_listView.width - root._expandedW) / 2; height: 1 }

            flickDeceleration:    1500
            maximumFlickVelocity: 3000
            boundsBehavior:       Flickable.StopAtBounds

            // Scroll-to-center on init
            Component.onCompleted: {
                if (count > 0) {
                    // Position to the current wallpaper if found, else 0
                    var idx = 0
                    for (var i = 0; i < count; i++) {
                        if (model.get(i).path === Wallpaper.currentWallpaper) {
                            idx = i; break
                        }
                    }
                    currentIndex = idx
                    root._suppressWidthAnim = true
                    positionViewAtIndex(idx, ListView.Center)
                    Qt.callLater(function() {
                        root._suppressWidthAnim = false
                    })
                }
            }

            // Reposition when picker becomes visible
            Connections {
                target: SessionState
                function onWallpaperPickerVisibleChanged() {
                    if (!SessionState.wallpaperPickerVisible) return

                    // Suppress width animation during initial positioning to prevent sliding jumps
                    root._suppressWidthAnim = true

                    var idx = 0
                    for (var i = 0; i < _listView.count; i++) {
                        if (_listView.model.get(i).path === Wallpaper.currentWallpaper) {
                            idx = i; break
                        }
                    }
                    _listView.currentIndex = idx

                    // Position instantly without visual sliding
                    _listView.positionViewAtIndex(idx, ListView.Center)

                    // Force keyboard focus immediately on the ListView so keys work
                    _listView.forceActiveFocus()

                    // Restore width animation on the next tick
                    Qt.callLater(function() {
                        root._suppressWidthAnim = false
                    })
                }
            }

            // Mouse-wheel navigation
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onWheel: function(wheel) {
                    var delta = (wheel.angleDelta.y > 0 || wheel.angleDelta.x > 0) ? -1 : 1
                    _listView.currentIndex = Math.max(0, Math.min(_listView.count - 1, _listView.currentIndex + delta))
                }
                onPressed:  function(e) { e.accepted = false }
                onReleased: function(e) { e.accepted = false }
                onClicked:  function(e) { e.accepted = false }
            }

            // Keyboard navigation
            focus: root.visible
            Keys.onEscapePressed: SessionState.wallpaperPickerVisible = false
            Keys.onLeftPressed:   if (currentIndex > 0) currentIndex--
            Keys.onRightPressed:  if (currentIndex < count - 1) currentIndex++
            Keys.onReturnPressed: {
                if (currentIndex >= 0 && currentIndex < count) {
                    Wallpaper.setWallpaper(Wallpaper.wallpapers.get(currentIndex).path)
                    SessionState.wallpaperPickerVisible = false
                }
            }

            delegate: SliceItem {
                // Geometry
                expandedW: root._expandedW
                sliceW:    root._sliceW
                skewPx:    root._skewPx
                suppressWidthAnim: root._suppressWidthAnim

                // Track current wallpaper for the ✓ badge
                _currentWallpaper: Wallpaper.currentWallpaper

                // Request priority thumbnail generation as items enter view
                onVisibleChanged: {
                    if (visible) Wallpaper.requestThumbnail(path)
                }

                // Click → focus. Second click (via applyRequested) → apply.
                onClicked: function(idx) {
                    _listView.currentIndex = idx
                }
                onApplyRequested: function(wallpaperPath) {
                    Wallpaper.setWallpaper(wallpaperPath)
                    SessionState.wallpaperPickerVisible = false
                }
            }
        }

        // ── Status bar ────────────────────────────────────────────────────
        Row {
            id: _statusBar
            anchors.bottom:           parent.bottom
            anchors.bottomMargin:     16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingSm

            Text {
                text: Wallpaper.isScanning  ? "⟳  Scanning…"  :
                      Wallpaper.isChanging  ? "⟳  Applying…"  : ""
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                color:          PanelColors.accent
                visible:        text !== ""
            }

            Text {
                text: "← →  navigate   ↵  apply   Esc  close"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                color:          "#ffffff"
                visible:        !Wallpaper.isScanning && !Wallpaper.isChanging
            }
        }
    }
}
