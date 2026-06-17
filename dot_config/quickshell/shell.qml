// shell.qml — ShellRoot entry point
// Imports are added progressively each phase.

//@ pragma NativeTextRendering
//@ pragma DropExpensiveFonts
//@ pragma CacheDir $BASE/quickshell
//@ pragma IconTheme Papirus-Dark

import Quickshell
import Quickshell.Io
import "theme"
import "services"
import "state"
import "./polkit"
import "./notifications"
import "bar"
import "wallpaper"
import "./clipboard"
import "./osd"
import "./launcher"
import "sidebar-left"
import "./sidebar-right"

ShellRoot {
    // ── Bluetooth Pairing Agent ───────────────────────────────────────────
    Process {
        id: bluetoothAgent
        command: ["python", Quickshell.env("HOME") + "/.config/quickshell/scripts/bt-agent.py"]
        running: true
    }

    // ── Phase QS2b — polkit ───────────────────────────────────────────────
    PolkitDialog {}

    // ── Phase QS4 — bar ───────────────────────────────────────────────────
    Bar {}

    // ── Phase QS6 — notifications ─────────────────────────────────────────
    NotificationPopup {}
    NotificationCenter {}

    // ── Phase QS7 — OSD ───────────────────────────────────────────────────
    Osd {}

    // ── Phase QS8 — launcher ──────────────────────────────────────────────
    Launcher {}

    // ── Phase QS9 — sidebars ──────────────────────────────────────────────
    SidebarLeft {}
    RightSidebar {}

    // ── Phase QS10 — wallpaper picker ─────────────────────────────────────
    WallpaperPicker {}

    // ── Phase QS11 — background ───────────────────────────────────────────
    // Background {}

    // ── Phase QS12 — clipboard ────────────────────────────────────────────
    ClipboardPanel {}

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