// components/CachingImage.qml
// Image component with XDG thumbnail cache support.
//
// Designed for the wallpaper picker — loads from ~/.cache/thumbnails/large/
// (XDG thumbnail spec, MD5-hashed file:// URI filename, .png extension).
// Falls back to the full source path if the thumbnail doesn't exist yet,
// allowing Wallpaper.qml's imagemagick worker pool to generate the thumbnail
// in the background without blocking the UI.
//
// Usage:
//   CachingImage {
//       source:       "/home/user/wallpapers/something.jpg"   // full path
//       implicitWidth:  200
//       implicitHeight: 120
//   }
//
// The component exposes:
//   status          — Image.Ready / Image.Loading / Image.Error / Image.Null
//   hasThumbnail    — true once the thumbnail path is confirmed to exist
//   requestThumbnail() — call in Component.onCompleted to kick off thumb generation
//                        (calls the external wallpaper-change.sh thumbnail helper if needed)
//
// Size/position: follow Quickshell conventions — set implicitWidth/implicitHeight,
// never x/y/width/height directly if placed inside a container.

import QtQuick
import Quickshell.Io
import "../theme"

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────

    // Full path to the source image (e.g. "/home/user/wallpapers/foo.jpg")
    property string source: ""

    // Fill mode forwarded to the underlying Image
    property int fillMode: Image.PreserveAspectCrop

    // Corner radius for the clip rectangle
    property real radius: Theme.radiusSm

    // Whether to show a loading shimmer while the image loads
    property bool showShimmer: true

    // Readonly status mirror from the active Image
    readonly property int status: _activeImage.status

    // True once a valid thumbnail was found or confirmed generated
    readonly property bool hasThumbnail: _thumbExists

    // ── Thumbnail path resolution ─────────────────────────────────────────
    // XDG thumbnail spec: MD5 of the "file://<absolutepath>" URI, stored as
    // ~/.cache/thumbnails/large/<hash>.png
    //
    // Qt doesn't have a built-in MD5 function accessible from QML, so we
    // delegate the hash lookup to a small helper: we store the resolved path
    // in a property set by Wallpaper.qml (via requestThumbnail()) or fall back
    // to the source itself.

    // Set externally by Wallpaper.qml after thumbnail generation completes,
    // or computed locally via the thumb watcher below.
    property string thumbnailPath: ""

    // Internal: whether we've confirmed the thumbnail file exists
    property bool _thumbExists: false

    // Internal: actual path fed to the visible Image
    readonly property string _resolvedSource: {
        if (_thumbExists && thumbnailPath !== "") return thumbnailPath
        return source
    }

    // ── Trigger thumbnail generation ──────────────────────────────────────
    // Call this in Component.onCompleted of the parent delegate.
    // Wallpaper.qml's worker pool handles the actual magick call;
    // this just signals that a thumbnail is wanted.

    signal thumbnailRequested(string sourcePath)

    function requestThumbnail() {
        if (source !== "") {
            root.thumbnailRequested(source)
        }
    }

    // Watch the thumbnailPath file — if it appears/changes, mark as ready.
    FileView {
        id: thumbWatcher
        path:         root.thumbnailPath
        watchChanges: true
        preload:      root.thumbnailPath !== ""
        onLoaded: {
            root._thumbExists = true
        }
        onLoadFailed: {
            root._thumbExists = false
        }
    }

    // Re-watch when thumbnailPath changes
    onThumbnailPathChanged: {
        if (thumbnailPath !== "") {
            thumbWatcher.path = thumbnailPath
        }
    }

    // ── Layout ────────────────────────────────────────────────────────────

    implicitWidth:  200
    implicitHeight: 120

    // ── Clip rectangle ────────────────────────────────────────────────────

    Rectangle {
        id: clipRect
        anchors.fill: parent
        radius:       root.radius
        color:        Colors.surfaceContainerHighest
        clip:         true

        // ── Primary image ─────────────────────────────────────────────────

        Image {
            id:           _activeImage
            anchors.fill: parent
            source:       root._resolvedSource
            fillMode:     root.fillMode
            smooth:       true
            mipmap:       true
            asynchronous: true
            cache:        true    // Qt image cache: avoids re-decode on re-use

            // Fade in when load completes
            opacity: status === Image.Ready ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutQuad }
            }
        }

        // ── Loading shimmer ───────────────────────────────────────────────

        Rectangle {
            anchors.fill: parent
            visible:      root.showShimmer && _activeImage.status !== Image.Ready
            color:        "transparent"

            // Animated shimmer gradient
            Rectangle {
                id: shimmerBar
                width:  parent.width * 0.5
                height: parent.height
                opacity: 0.12

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Colors.onSurface }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                NumberAnimation on x {
                    from:     -shimmerBar.width
                    to:       clipRect.width
                    duration: 1200
                    loops:    Animation.Infinite
                    running:  _activeImage.status !== Image.Ready
                    easing.type: Easing.InOutSine
                }
            }
        }

        // ── Error state ───────────────────────────────────────────────────

        Item {
            anchors.centerIn: parent
            visible:          _activeImage.status === Image.Error
            implicitWidth:    32
            implicitHeight:   32

            Text {
                anchors.centerIn: parent
                text:             "?"
                font.pixelSize:   Theme.fontSizeXl
                font.weight:      Theme.fontWeightBold
                color:            Colors.textMuted
                opacity:          0.4
            }
        }
    }

    // ── Init ──────────────────────────────────────────────────────────────

    Component.onCompleted: {
        // Auto-request thumbnail on instantiation.
        // Parent can also call requestThumbnail() explicitly.
        requestThumbnail()
    }
}
