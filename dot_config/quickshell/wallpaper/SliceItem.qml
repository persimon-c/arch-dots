// wallpaper/SliceItem.qml
// One parallelogram slice in the wallpaper carousel.
//
// Technique summary (derived from studying skwd-wall SliceDelegate.qml):
//   • The "slice" shape is a trapezoid, not a true parallelogram. Four corner
//     X coordinates (_tlX, _trX, _blX, _brX) are computed from a single
//     `skewPx` value:  top-edge is shifted right by +skewPx, bottom-edge is
//     not shifted. This produces the characteristic leaning-right appearance.
//   • The shape is drawn using QtQuick.Shapes ShapePath so that antialiased
//     diagonal edges are rendered by Qt's curve renderer (GPU path).
//   • Image content is clipped to the same polygon by rendering the shape into
//     an offscreen Item (layer.enabled) and feeding it as a mask to MultiEffect
//     (maskEnabled). This avoids any fragment-shader custom GLSL.
//   • Width (not scale) drives the accordion: isCurrent items are `expandedW`
//     wide; others are `sliceW`. A NumberAnimation on width gives the smooth
//     expand/collapse.
//   • Opacity fades items far from the viewport edge so the list ends gracefully.
//   • Z ordering: current item is always on top, hovered next, far items behind.

import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "../theme"

Item {
    id: root

    // ── Inputs from ListView delegate ─────────────────────────────────────
    required property int   index
    required property string path
    required property string name
    required property string thumbnailPath
    required property bool   hasThumbnail

    // ── Carousel geometry (passed in from parent ListView) ────────────────
    property int  expandedW: 700
    property int  sliceW:    110
    property int  skewPx:    28       // how many px the top edge shifts right
    property bool suppressWidthAnim: false

    // ── Signals ───────────────────────────────────────────────────────────
    signal clicked(int idx)
    signal applyRequested(string wallpaperPath)

    // ── Computed parallelogram corners ────────────────────────────────────
    // Top edge is shifted right by +skewPx relative to the bottom edge.
    //   top-left  X = skewPx   (pushes top-left corner rightward)
    //   top-right X = width     (= sliceW or expandedW)
    //   bot-right X = width - skewPx
    //   bot-left  X = 0
    readonly property real _tlX: skewPx
    readonly property real _trX: width
    readonly property real _brX: width - skewPx
    readonly property real _blX: 0

    // ── Delegate state ────────────────────────────────────────────────────
    property bool isCurrent:  ListView.isCurrentItem
    property bool isHovered:  _hover.containsMouse
    readonly property var _lv: ListView.view

    // Width: expanded for the focused item, sliceW for all others.
    width:  isCurrent ? expandedW : sliceW
    height: _lv ? _lv.height : 0

    Behavior on width {
        enabled: !suppressWidthAnim
        NumberAnimation { duration: Theme.durationSlow; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
    }

    // Z: current on top so its shadow/glow isn't clipped by neighbours.
    z: isCurrent ? 100 : (isHovered ? 90 : 50 - Math.min(Math.abs(index - (_lv ? _lv.currentIndex : 0)), 50))

    // Fade items far past the visible band.
    readonly property real _viewCenterX: _lv ? (_lv.contentX + _lv.width / 2) : 0
    readonly property real _itemCenterX: x + width / 2
    readonly property real _halfView:    _lv ? _lv.width / 2 : 1
    readonly property real _normDist:    Math.abs(_itemCenterX - _viewCenterX) / _halfView
    opacity: _normDist <= 0.7 ? 1.0 : Math.max(0, 1.0 - (_normDist - 0.7) / 0.5)
    readonly property bool _inView: opacity > 0.02

    // ── Parallelogram hit-test ─────────────────────────────────────────────
    // Without this, clicks in the top-left triangular "notch" of the left
    // neighbour would register on this item's rectangular bounding box.
    containmentMask: Item {
        function contains(pt) {
            if (root.height <= 0 || root.width <= 0) return false
            var t  = pt.y / root.height
            var lx = root._tlX * (1 - t) + root._blX * t
            var rx = root._trX * (1 - t) + root._brX * t
            return pt.x >= lx && pt.x <= rx && pt.y >= 0 && pt.y <= root.height
        }
    }

    // ── Offscreen mask shape (shared by image and border) ────────────────
    // Rendered once into a layer, then referenced by MultiEffect.
    Item {
        id: _maskShape
        width:   root.width
        height:  root.height
        visible: false
        layer.enabled: root._inView
        layer.smooth:  true

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true
            ShapePath {
                fillColor:   "white"
                strokeColor: "transparent"
                startX: root._tlX; startY: 0
                PathLine { x: root._trX; y: 0 }
                PathLine { x: root._brX; y: root.height }
                PathLine { x: root._blX; y: root.height }
                PathLine { x: root._tlX; y: 0 }
            }
        }
    }

    // ── Drop shadow ───────────────────────────────────────────────────────
    Shape {
        id: _shadow
        z: -1
        x: root.isCurrent ? 5 : 2
        y: root.isCurrent ? 12 : 5
        width:   root.width
        height:  root.height
        opacity: root.isCurrent ? 0.55 : 0.28
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        Behavior on x      { NumberAnimation { duration: Theme.durationNormal ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        Behavior on y      { NumberAnimation { duration: Theme.durationNormal ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        ShapePath {
            fillColor:   "#000000"
            strokeColor: "transparent"
            startX: root._tlX; startY: 0
            PathLine { x: root._trX; y: 0 }
            PathLine { x: root._brX; y: root.height }
            PathLine { x: root._blX; y: root.height }
            PathLine { x: root._tlX; y: 0 }
        }
    }

    // ── Thumbnail image (clipped to parallelogram via MultiEffect mask) ───
    Item {
        id: _imgContainer
        anchors.fill: parent
        layer.enabled: root._inView
        layer.smooth:  true
        layer.effect: MultiEffect {
            maskEnabled:      true
            maskSource:       _maskShape
            maskThresholdMin: 0.3
            maskSpreadAtMin:  0.3
        }

        // Thumbnail/Wallpaper image
        AnimatedImage {
            id: _thumb
            anchors.fill: parent
            playing:      root.isCurrent
            property bool _triedOriginal: true
            source: _triedOriginal ? (root.path !== "" ? ("file://" + root.path) : "") : (root.hasThumbnail && root.thumbnailPath !== "" ? ("file://" + root.thumbnailPath) : "")
            fillMode:     Image.PreserveAspectCrop
            smooth:       true
            asynchronous: true
            cache:        true
            sourceSize.height: 1024
            opacity: status === Image.Ready ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

            onStatusChanged: {
                if (status === Image.Error && _triedOriginal) {
                    if (root.hasThumbnail && root.thumbnailPath !== "") {
                        console.log("[SliceItem] Failed to load original image: " + root.path + ", trying thumbnail: " + root.thumbnailPath)
                        _triedOriginal = false // forces source to load the PNG thumbnail
                    }
                }
            }
        }

        // Placeholder while thumbnail loads
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0.12, 0.10, 0.14, 0.9)
            visible: _thumb.status !== Image.Ready
        }

        // Dim overlay: full dim when collapsed, subtle when hovered, clear when current
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0,
                root.isCurrent ? 0.0 :
                root.isHovered ? 0.18 : 0.45)
            Behavior on color { ColorAnimation { duration: Theme.durationNormal ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        }
    }

    // ── Accent border ─────────────────────────────────────────────────────
    Shape {
        id: _border
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        antialiasing: true
        ShapePath {
            fillColor:   "transparent"
            strokeColor: root.isCurrent
                             ? PanelColors.accent
                             : (root.isHovered
                                    ? Qt.rgba(0.9, 0.9, 0.9, 0.35)
                                    : Qt.rgba(0, 0, 0, 0.55))
            Behavior on strokeColor { ColorAnimation { duration: Theme.durationNormal ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
            strokeWidth: root.isCurrent ? 2.5 : 1.0
            startX: root._tlX; startY: 0
            PathLine { x: root._trX; y: 0 }
            PathLine { x: root._brX; y: root.height }
            PathLine { x: root._blX; y: root.height }
            PathLine { x: root._tlX; y: 0 }
        }
    }

    // ── Name label (visible only on focused item) ─────────────────────────
    Item {
        id: _label
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.skewPx / 2

        width: Math.min(root.width - root.skewPx * 2 - 24, _nameText.implicitWidth + 32)
        height: 36
        opacity: root.isCurrent ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

        // Premium glassmorphic capsule background
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Qt.rgba(0, 0, 0, 0.65)
            border.color: Qt.rgba(255, 255, 255, 0.15)
            border.width: 1
        }

        Text {
            id: _nameText
            anchors.centerIn: parent
            width: parent.width - 24
            text: root.name.replace(/\.[^/.]+$/, "")
            font.family:      Theme.fontFamily
            font.pixelSize:   Theme.fontSizeSm
            font.weight:      Theme.fontWeightMedium
            font.letterSpacing: 0.5
            color:            "#ffffff"
            elide:            Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ── "Active" checkmark badge ──────────────────────────────────────────
    Rectangle {
        id: _activeBadge
        anchors.top:        parent.top
        anchors.topMargin:  14
        anchors.right:      parent.right
        anchors.rightMargin: root.skewPx + 10
        width:  22; height: 22; radius: 11
        color:   PanelColors.accent
        opacity: (root.path !== "" && root.path === _currentWallpaper) ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        Text {
            anchors.centerIn: parent
            text: "✓"
            font.pixelSize: 12
            font.weight: Font.Bold
            color: PanelColors.onAccent
        }
    }

    // Expose currentWallpaper from parent scope via property alias.
    // WallpaperPicker sets this via `currentWallpaper: Wallpaper.currentWallpaper`.
    property string _currentWallpaper: ""

    // ── Mouse interaction ─────────────────────────────────────────────────
    MouseArea {
        id: _hover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onClicked: {
            if (root.isCurrent) {
                // Second click on focused item → apply
                root.applyRequested(root.path)
            } else {
                // First click → focus (expand)
                root.clicked(root.index)
            }
        }
    }
}
