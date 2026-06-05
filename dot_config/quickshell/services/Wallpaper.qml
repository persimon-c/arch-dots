// services/Wallpaper.qml
// Wallpaper service — data only, no UI.
//
// Responsibilities:
//   - Scans ~/wallpapers/ recursively for jpg/jpeg/png/webp/gif
//   - Exposes a ListModel of { path, name, thumbnailPath, hasThumbnail }
//   - Watches ~/wallpapers/ for changes via inotifywait (inotify-tools)
//   - Tracks current wallpaper by watching ~/.cache/current_wallpaper_path
//   - Generates XDG thumbnails lazily via ImageMagick (magick)
//   - Applies wallpaper by calling scripts/wallpaper-change.sh via Process
//
// Dependencies:
//   - inotify-tools  (inotifywait — directory watching)
//   - imagemagick    (magick — thumbnail generation)
//   - wallpaper-change.sh must exist at ~/.config/quickshell/scripts/wallpaper-change.sh
//
// XDG thumbnail spec:
//   Path: ~/.cache/thumbnails/large/<md5("file://<abspath)")>.png
//   Size: 256x256 (large spec)

import QtQuick
import QtCore
import Qt.labs.platform
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Public state ──────────────────────────────────────────────────────────

    // ListModel entries: { path: string, name: string, thumbnailPath: string, hasThumbnail: bool }
    readonly property ListModel wallpapers: ListModel { id: wallpaperModel }

    // Full path of the currently active wallpaper. Empty string if not yet set.
    readonly property string currentWallpaper: currentPathView.text().trim()

    // True while wallpaper-change.sh is running.
    property bool isChanging: false

    // True during initial directory scan.
    property bool isScanning: false

    // ── Public API ────────────────────────────────────────────────────────────

    // Apply a wallpaper. Called by the carousel UI when the centered item auto-applies.
    function setWallpaper(path) {
        if (root.isChanging) return
        if (path === root.currentWallpaper) return
        console.log("[Wallpaper] Setting wallpaper:", path)
        root.isChanging = true
        changeProcess.command = [
            "/bin/bash",
            Qt.resolvedUrl("../scripts/wallpaper-change.sh").toString().replace("file://", ""),
            path
        ]
        changeProcess.running = true
    }

    // Request priority thumbnail generation for a single path.
    // UI calls this for items entering the visible carousel window.
    // Inserts at the front of the queue so visible items generate before background bulk.
    // No-op if already generated or already queued at front.
    function requestThumbnail(path) {
        const idx = _indexOfPath(path)
        if (idx < 0) return
        if (wallpaperModel.get(idx).hasThumbnail) return
        _enqueueThumbPriority(path)
    }

    // Pure function — returns the expected XDG thumbnail path for any wallpaper path.
    // UI can call this directly without going through the model.
    function thumbnailPath(path) {
        return _thumbPath(path)
    }

    // ── Paths ─────────────────────────────────────────────────────────────────

    readonly property string wallpaperDir:   Qt.resolvedUrl("file://" + StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/wallpapers").toString().replace("file://", "")
    readonly property string cachePathFile:  StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/current_wallpaper_path"
    readonly property string thumbCacheDir:  StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/thumbnails/large"
    readonly property string changeScript:   Qt.resolvedUrl("../scripts/wallpaper-change.sh").toString().replace("file://", "")

    // ── Current wallpaper watcher ─────────────────────────────────────────────
    // FileView watches ~/.cache/current_wallpaper_path written by wallpaper-change.sh.
    // No signal needed — binding to .text is reactive.

    FileView {
        id: currentPathView
        path: root.cachePathFile
        // watchChanges: true is default in QS 0.3.0
    }

    // ── Directory watcher (inotifywait) ───────────────────────────────────────
    // Watches ~/wallpapers/ for CREATE/DELETE/MOVED events.
    // On any event, triggers a rescan.

    Process {
        id: watchProcess
        command: [
            "inotifywait",
            "--monitor",
            "--quiet",
            "--event", "create",
            "--event", "delete",
            "--event", "moved_to",
            "--event", "moved_from",
            "--format", "%f",
            root.wallpaperDir
        ]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                // Any event in the directory = rescan.
                // Debounce: cancel pending rescan timer and restart it.
                rescanDebounce.restart()
            }
        }

        onExited: function(code, status) {
            // inotifywait exited unexpectedly — retry after a delay.
            if (code !== 0) {
                console.warn("[Wallpaper] inotifywait exited with code", code, "— retrying in 5s")
                watchRestartTimer.start()
            }
        }
    }

    Timer {
        id: watchRestartTimer
        interval: 5000
        repeat: false
        onTriggered: watchProcess.running = true
    }

    // Debounce rescan — if multiple files arrive at once, wait 500ms then scan once.
    Timer {
        id: rescanDebounce
        interval: 500
        repeat: false
        onTriggered: root._scan()
    }

    // ── Directory scanner ─────────────────────────────────────────────────────

    Process {
        id: scanProcess
        // Command built dynamically in _scan()
        stdout: SplitParser {
            onRead: function(line) {
                const trimmed = line.trim()
                if (trimmed.length === 0) return
                _addEntry(trimmed)
            }
        }
        onExited: function(code) {
            root.isScanning = false
            console.log("[Wallpaper] Scan complete —", wallpaperModel.count, "wallpapers found")
            // Check which thumbnails already exist before generating missing ones.
            _checkExistingThumbnails()
        }
    }

    // ── Wallpaper change process ──────────────────────────────────────────────

    Process {
        id: changeProcess
        onExited: function(code) {
            root.isChanging = false
            if (code !== 0) {
                console.warn("[Wallpaper] wallpaper-change.sh exited with code", code)
            } else {
                console.log("[Wallpaper] Wallpaper applied successfully")
            }
        }
    }

    // ── Thumbnail existence check ─────────────────────────────────────────────
    // After scan completes, run ONE find over the thumbnail cache dir and collect
    // all existing hashes into a JS Set. Then mark the entire model in one pass.
    // Zero per-item subprocess overhead.

    property var _existingThumbs: new Set()

    Process {
        id: thumbScanProcess
        // Command set dynamically in _checkExistingThumbnails()
        stdout: SplitParser {
            onRead: function(line) {
                const trimmed = line.trim()
                if (trimmed.length > 0) root._existingThumbs.add(trimmed)
            }
        }
        onExited: function() {
            // Single pass: mark all model entries whose thumbnail already exists.
            let alreadyDone = 0
            for (let i = 0; i < wallpaperModel.count; i++) {
                const entry = wallpaperModel.get(i)
                const hash = entry.thumbnailPath.substring(entry.thumbnailPath.lastIndexOf("/") + 1)
                if (root._existingThumbs.has(hash)) {
                    wallpaperModel.setProperty(i, "hasThumbnail", true)
                    alreadyDone++
                }
            }
            console.log("[Wallpaper] Thumbnails already cached:", alreadyDone, "/ need generation:", wallpaperModel.count - alreadyDone)
            _generateAllThumbnails()
        }
    }

    // ── Thumbnail generation — 4-worker parallel pool ─────────────────────────
    // 4 concurrent magick processes. Fast enough on first run without thrashing.
    // Priority queue: requestThumbnail() inserts at front; bulk scan appends at back.

    readonly property int _thumbWorkerCount: 4
    property var _thumbQueue: []
    property int _thumbActiveWorkers: 0

    // Four workers declared explicitly — Repeater is not valid inside QtObject.
    Process { id: thumbWorker0; onExited: function(code) { root._workerDone(0, code) } }
    Process { id: thumbWorker1; onExited: function(code) { root._workerDone(1, code) } }
    Process { id: thumbWorker2; onExited: function(code) { root._workerDone(2, code) } }
    Process { id: thumbWorker3; onExited: function(code) { root._workerDone(3, code) } }

    readonly property var _workers: [thumbWorker0, thumbWorker1, thumbWorker2, thumbWorker3]

    // ── Private helpers ───────────────────────────────────────────────────────

    function _scan() {
        console.log("[Wallpaper] Scanning", root.wallpaperDir)
        root.isScanning = true
        wallpaperModel.clear()
        scanProcess.command = [
            "find", root.wallpaperDir,
            "-type", "f",
            "(", "-iname", "*.jpg",
            "-o", "-iname", "*.jpeg",
            "-o", "-iname", "*.png",
            "-o", "-iname", "*.webp",
            "-o", "-iname", "*.gif",
            ")",
            "-print"
        ]
        scanProcess.running = true
    }

    function _addEntry(path) {
        const name = path.substring(path.lastIndexOf("/") + 1)
        const thumb = _thumbPath(path)
        wallpaperModel.append({
            "path": path,
            "name": name,
            "thumbnailPath": thumb,
            "hasThumbnail": false   // will be confirmed lazily
        })
    }

    // XDG thumbnail path: ~/.cache/thumbnails/large/<md5("file://<abspath>")>.png
    function _thumbPath(path) {
        const uri = "file://" + path
        const hash = Qt.md5(uri)
        return root.thumbCacheDir + "/" + hash + ".png"
    }

    function _indexOfPath(path) {
        for (let i = 0; i < wallpaperModel.count; i++) {
            if (wallpaperModel.get(i).path === path) return i
        }
        return -1
    }

    function _enqueueThumb(path) {
        if (root._thumbQueue.indexOf(path) >= 0) return
        root._thumbQueue.push(path)
        _drainThumbQueue()
    }

    function _enqueueThumbPriority(path) {
        const existing = root._thumbQueue.indexOf(path)
        if (existing === 0) return  // already at front
        if (existing > 0) root._thumbQueue.splice(existing, 1)
        root._thumbQueue.unshift(path)
        _drainThumbQueue()
    }

    // Try to fill all idle workers from the queue.
    function _drainThumbQueue() {
        for (let w = 0; w < root._thumbWorkerCount; w++) {
            if (root._thumbQueue.length === 0) break
            const worker = root._workers[w]
            if (worker.running) continue
            _startWorker(worker, root._thumbQueue.shift())
            root._thumbActiveWorkers++
        }
    }

    function _startWorker(worker, path) {
        const thumb = _thumbPath(path)
        worker._currentPath = path
        worker.command = [
            "/bin/bash", "-c",
            "mkdir -p \"" + root.thumbCacheDir + "\" && " +
            "magick \"" + path + "\" " +
            "-thumbnail 256x256^ " +
            "-gravity Center " +
            "-extent 256x256 " +
            "\"" + thumb + "\""
        ]
        worker.running = true
    }

    function _workerDone(workerIndex, exitCode) {
        root._thumbActiveWorkers = Math.max(0, root._thumbActiveWorkers - 1)
        const worker = root._workers[workerIndex]
        const path = worker._currentPath || ""
        if (exitCode === 0 && path.length > 0) {
            const idx = _indexOfPath(path)
            if (idx >= 0) wallpaperModel.setProperty(idx, "hasThumbnail", true)
        }
        worker._currentPath = ""
        _drainThumbQueue()
    }

    function _generateAllThumbnails() {
        for (let i = 0; i < wallpaperModel.count; i++) {
            const entry = wallpaperModel.get(i)
            if (!entry.hasThumbnail) _enqueueThumb(entry.path)
        }
        _drainThumbQueue()
    }

    function _checkExistingThumbnails() {
        root._existingThumbs = new Set()
        // List all .png filenames (just the basename) in the large thumbnail cache.
        thumbScanProcess.command = [
            "/bin/bash", "-c",
            "ls \"" + root.thumbCacheDir + "\" 2>/dev/null || true"
        ]
        thumbScanProcess.running = true
    }

    // ── Init ──────────────────────────────────────────────────────────────────

    Component.onCompleted: {
        console.log("[Wallpaper] Initialized")
        console.log("[Wallpaper]   Wallpaper dir:", root.wallpaperDir)
        console.log("[Wallpaper]   Thumb cache:  ", root.thumbCacheDir)
        console.log("[Wallpaper]   Change script:", root.changeScript)
        console.log("[Wallpaper]   Current wall: ", root.currentWallpaper || "(none)")
        root._scan()
    }
}
