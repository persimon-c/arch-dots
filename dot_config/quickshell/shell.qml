// shell.qml — ShellRoot skeleton
// Imports are added progressively each phase.

//@ pragma NativeTextRendering
//@ pragma DropExpensiveFonts

import Quickshell
import "./theme"
import "./services"
import "./components"
import "./utils"
import "./polkit"

ShellRoot {

    // ── Phase QS2b — polkit ───────────────────────────────────────────────
    PolkitDialog {}

    // ── Phase QS4 — bar ───────────────────────────────────────────────────
    // Bar {}

    // ── Phase QS6 — notifications ─────────────────────────────────────────
    // NotificationPopup {}
    // NotificationCenter {}

    // ── Phase QS7 — OSD ───────────────────────────────────────────────────
    // Osd {}

    // ── Phase QS8 — launcher ──────────────────────────────────────────────
    // Launcher {}

    // ── Phase QS9 — sidebars ──────────────────────────────────────────────
    // LeftSidebar {}
    // RightSidebar {}

    // ── Phase QS10 — wallpaper picker ─────────────────────────────────────
    // WallpaperPicker {}

    // ── Phase QS11 — background ───────────────────────────────────────────
    // Background {}

    // ── Phase QS12 — clipboard ────────────────────────────────────────────
    // ClipboardPanel {}

    // ── Phase QS13 — emoji picker ─────────────────────────────────────────
    // EmojiPicker {}

    // ── Phase QS14 — lock screen ──────────────────────────────────────────
    // Lock {}

    // ── Phase QS15 — session ──────────────────────────────────────────────
    // SessionPanel {}

    // ── Phase QS16 — utilities ────────────────────────────────────────────
    // Utilities {}

    // ── Phase QS17 — settings ─────────────────────────────────────────────
    // SettingsPanel {}
}