## Wallpaper System — Session Reference

### What exists (done this session)

**`services/Wallpaper.qml`** — QS2 service, data only
- Scans `~/wallpapers/` recursively via `find`, populates `ListModel { path, name, thumbnailPath, hasThumbnail }`
- Watches directory via `inotifywait --monitor` with 500ms debounce rescan
- Thumbnail pipeline: one `ls` pass after scan → JS Set → bulk model mark → 4-worker parallel `magick` pool for missing ones
- `requestThumbnail(path)` priority-queues visible carousel items ahead of bulk
- `setWallpaper(path)` calls `wallpaper-change.sh` via Process, exposes `isChanging`
- Tracks current wallpaper via `FileView` on `~/.cache/current_wallpaper_path`

**`scripts/wallpaper-change.sh`** — cleaned up
- `awww img` with grow/bubble transition from cursor position
- `matugen image "$WALLPAPER"` — no extra flags
- Reloads: `hyprctl reload`, `kitty @ set-colors`, `pkill -USR1 cava`
- Writes `~/.cache/current_wallpaper_path` (FileView picks it up) and `~/.cache/current_wallpaper` symlink (lock screen)
- Swaync block removed, sed hacks removed, matugen owns all template outputs

---

### What to build (Phase QS10)

**File structure — locked:**
```
wallpaper/
├── WallpaperPicker.qml         PanelWindow container
├── WallpaperCarousel.qml       PathView-based horizontal carousel
├── WallpaperCarouselItem.qml   Single card with scale/fan falloff by distance
└── TransitionOptions.qml       Overlay for awww transition settings
```
`WallpaperGrid.qml`, `WallpaperPreview.qml`, `FolderBrowser.qml` — removed from Document B.

**Carousel behavior — locked:**
- `PathView` (not `Repeater`, not `ListView`) — only renders visible delegates, handles scale falloff via `PathView.onPath` and `PathView.scale`
- Center item is large and straight. Items left/right progressively narrower, slightly angled inward (fan effect matching skwd-wall screenshot)
- **Click off-center** → scrolls that item to center
- **Item reaches center** → `Wallpaper.setWallpaper(path)` fires automatically (with a short settle delay, ~300ms, so fast scrolling doesn't trigger on every item passed through)
- Center item gets a subtle selection ring/glow border
- `WallpaperCarouselItem` calls `Wallpaper.requestThumbnail(path)` from `Component.onCompleted` — priority queues itself ahead of background bulk generation
- Image source: `hasThumbnail ? thumbnailPath : path` — falls back to full image while thumbnail generates

**`TransitionOptions.qml`** — small settings overlay, triggered by a gear icon on the picker. Writable settings:
- Transition type (grow / wave / fade / outer / wipe)
- Duration (slider, 0.2s–1.5s)
- FPS (30 / 60)
- These write to a small JSON config at `~/.cache/quickshell/wallpaper-transition.json`, read by `wallpaper-change.sh` at runtime via `jq` or simple bash parsing

**`WallpaperPicker.qml`** — PanelWindow details:
- Layer: overlay
- Anchored: center of screen, or full-width strip like the skwd-wall screenshot
- Opens via keybind (decided in Phase H5) and from sidebar-left PowerCard or a dedicated button
- Closes on Escape or clicking outside
- Shows `isScanning` and `isChanging` states (spinner or dimmed carousel)

---

### Dependencies to have installed
- `awww` (was `swww` — renamed Oct 2025, same CLI)
- `inotify-tools` (inotifywait)
- `imagemagick` (magick)
- `matugen`
- `jq` (optional — for TransitionOptions config parsing in bash)

---

### Key implementation note for Phase QS10
`PathView` path definition is the critical piece. The fan/scale effect comes from a `Path` with `PathAttribute` nodes setting `itemScale` and `itemAngle` at specific path positions (0.0 = left edge, 0.5 = center, 1.0 = right edge). Center position gets scale 1.0, edges get ~0.15. This is what produces the deck-of-cards perspective. Worth reading the Qt PathView docs before writing `WallpaperCarousel.qml`.