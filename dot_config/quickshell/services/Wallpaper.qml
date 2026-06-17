// Service: wallpaper — implemented 2026-06-17
pragma Singleton
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
//   - imagemagick    (magick — thumbnail generation, optional)
//   - wallpaper-change.sh must exist at ~/.config/quickshell/scripts/wallpaper-change.sh

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

    // Queued path — applied once the current change finishes.
    property string _pendingPath: ""

    // True during initial directory scan.
    property bool isScanning: false

    // Configurable wallpaper directory
    property string wallpaperDir: (StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/wallpapers").replace(/^file:\/\//, "")

    onWallpaperDirChanged: {
        if (wallpaperDir.indexOf("file://") === 0) {
            wallpaperDir = wallpaperDir.replace(/^file:\/\//, "")
            return
        }
        console.log("[Wallpaper] wallpaperDir changed to:", wallpaperDir)
        watchProcess.running = false
        watchProcess.command = [
            "inotifywait",
            "--monitor",
            "--quiet",
            "--event", "create",
            "--event", "delete",
            "--event", "moved_to",
            "--event", "moved_from",
            "--format", "%f",
            wallpaperDir
        ]
        watchProcess.running = true
        root._scan()
    }

    // ── Public API ────────────────────────────────────────────────────────────

    // Apply a wallpaper. Called by the carousel UI when the centered item auto-applies.
    function setWallpaper(path) {
        if (path === root.currentWallpaper && root._pendingPath === "") return
        if (root.isChanging) {
            // Queue it — applied as soon as the current change finishes.
            root._pendingPath = path
            console.log("[Wallpaper] Queued (busy):", path)
            return
        }
        root._pendingPath = ""
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

    readonly property string cachePathFile:  (StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/current_wallpaper_path").replace(/^file:\/\//, "")
    readonly property string thumbCacheDir:  (StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/thumbnails/large").replace(/^file:\/\//, "")
    readonly property string changeScript:   (StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/quickshell/scripts/wallpaper-change.sh").replace(/^file:\/\//, "")

    // ── Current wallpaper watcher ─────────────────────────────────────────────
    // FileView watches ~/.cache/current_wallpaper_path written by wallpaper-change.sh.
    FileView {
        id: currentPathView
        path: root.cachePathFile
        watchChanges: true
        onFileChanged: reload()  // watchChanges only emits; we must reload() to refresh text()
    }

    // ── Directory watcher (inotifywait) ───────────────────────────────────────
    // Watches root.wallpaperDir for CREATE/DELETE/MOVED events.
    Process {
        id: watchProcess
        command: []
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                rescanDebounce.restart()
            }
        }

        onExited: function(code, status) {
            if (code !== 0 && root.wallpaperDir !== "") {
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
            // Apply any queued change
            if (root._pendingPath !== "") {
                var next = root._pendingPath
                root._pendingPath = ""
                root.setWallpaper(next)
            }
        }
    }

    // ── ImageMagick presence checks ───────────────────────────────────────────
    property bool _hasMagick: false
    property string _magickCmd: "magick"

    Process {
        id: checkMagickProc
        command: ["which", "magick"]
        running: true
        onExited: (code) => {
            if (code === 0) {
                root._hasMagick = true
                root._magickCmd = "magick"
                console.log("[Wallpaper] ImageMagick (magick) support verified")
            } else {
                checkConvertProc.running = true
            }
        }
    }

    Process {
        id: checkConvertProc
        command: ["which", "convert"]
        running: false
        onExited: (code) => {
            if (code === 0) {
                root._hasMagick = true
                root._magickCmd = "convert"
                console.log("[Wallpaper] ImageMagick (convert) support verified")
            } else {
                console.log("[Wallpaper] ImageMagick not found. Falling back to original image scaling.")
            }
        }
    }

    // ── Thumbnail existence check ─────────────────────────────────────────────
    property var _existingThumbs: new Set()

    Process {
        id: thumbScanProcess
        stdout: SplitParser {
            onRead: function(line) {
                const trimmed = line.trim()
                if (trimmed.length > 0) root._existingThumbs.add(trimmed)
            }
        }
        onExited: function() {
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
    readonly property int _thumbWorkerCount: 4
    property var _thumbQueue: []
    property int _thumbActiveWorkers: 0

    Process { id: thumbWorker0; property string _currentPath: ""; onExited: function(code) { root._workerDone(0, code) } }
    Process { id: thumbWorker1; property string _currentPath: ""; onExited: function(code) { root._workerDone(1, code) } }
    Process { id: thumbWorker2; property string _currentPath: ""; onExited: function(code) { root._workerDone(2, code) } }
    Process { id: thumbWorker3; property string _currentPath: ""; onExited: function(code) { root._workerDone(3, code) } }

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
            "hasThumbnail": false
        })
    }

    // XDG thumbnail path: ~/.cache/thumbnails/large/<md5("file://<abspath>")>.png
    function _thumbPath(path) {
        if (!root._hasMagick) return path // Fallback: use original path
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
        if (existing === 0) return
        if (existing > 0) root._thumbQueue.splice(existing, 1)
        root._thumbQueue.unshift(path)
        _drainThumbQueue()
    }

    function _drainThumbQueue() {
        if (!root._hasMagick) return
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
            root._magickCmd + " \"" + path + "[0]\" " +
            "-thumbnail 1024x1024^ " +
            "-gravity Center " +
            "-extent 1024x1024 " +
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
        if (!root._hasMagick) return
        for (let i = 0; i < wallpaperModel.count; i++) {
            const entry = wallpaperModel.get(i)
            if (!entry.hasThumbnail) _enqueueThumb(entry.path)
        }
        _drainThumbQueue()
    }

    function _checkExistingThumbnails() {
        if (!root._hasMagick) {
            // Force fallback values: set all as having thumbnails immediately
            for (let i = 0; i < wallpaperModel.count; i++) {
                const entry = wallpaperModel.get(i)
                wallpaperModel.setProperty(i, "hasThumbnail", true)
                wallpaperModel.setProperty(i, "thumbnailPath", entry.path)
            }
            console.log("[Wallpaper] Using original images as fallback thumbnails")
            return
        }

        root._existingThumbs = new Set()
        thumbScanProcess.command = [
            "/bin/bash", "-c",
            "ls \"" + root.thumbCacheDir + "\" 2>/dev/null || true"
        ]
        thumbScanProcess.running = true
    }

    // ── Init ──────────────────────────────────────────────────────────────────

    Component.onCompleted: {
        console.log("[Wallpaper] Initializing...")
        console.log("[Wallpaper]   Wallpaper dir:", root.wallpaperDir)
        console.log("[Wallpaper]   Thumb cache:  ", root.thumbCacheDir)
        console.log("[Wallpaper]   Change script:", root.changeScript)
        
        // Start watching the wallpaperDir
        watchProcess.command = [
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
        watchProcess.running = true
        root._scan()
    }
}
