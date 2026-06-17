// Service: asusctl — implemented 2026-06-17
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ─── Power Profile ────────────────────────────────────────────────────────
    // "Quiet" | "Balanced" | "Performance" | ""
    property string powerProfile: ""

    function setProfile(profile) {
        setProfileProc.command = ["asusctl", "profile", "set", profile]
        setProfileProc.running = true
    }

    // Toggle to next profile in list (Quiet -> Balanced -> Performance)
    function nextProfile() {
        nextProfileProc.running = true
    }

    // ─── Aura / RGB ───────────────────────────────────────────────────────────
    // Known modes from `asusctl aura effect --help` subcommands:
    property var auraModes: [
        "static", "breathe", "rainbow-cycle", "rainbow-wave",
        "stars", "rain", "highlight", "laser", "ripple",
        "pulse", "comet", "flash"
    ]
    property string auraMode: ""
    property int _auraModeIndex: -1

    function nextAuraMode() {
        nextAuraProc.running = true
    }

    function prevAuraMode() {
        prevAuraProc.running = true
    }

    // Dynamic file-based Aura mode tracking
    FileView {
        id: auraConfig
        path: "/etc/asusd/aura_tuf.ron"
        watchChanges: true
        onLoaded: {
            root._parseAuraConfig(text())
        }
        onLoadFailed: {
            if (path === "/etc/asusd/aura_tuf.ron") {
                console.log("[AsusCtl] aura_tuf.ron not found, trying aura.ron...")
                path = "/etc/asusd/aura.ron"
            } else {
                console.warn("[AsusCtl] Failed to load both aura_tuf.ron and aura.ron")
            }
        }
    }

    function _parseAuraConfig(content) {
        const match = content.match(/current_mode:\s*(\w+)/)
        if (match) {
            const rawMode = match[1]
            // Convert CamelCase to kebab-case (e.g. RainbowCycle -> rainbow-cycle)
            const mode = rawMode.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()
            
            if (root.auraMode !== mode) {
                root.auraMode = mode
                const idx = root.auraModes.indexOf(mode)
                if (idx !== -1) {
                    root._auraModeIndex = idx
                }
                console.log("[AsusCtl] Aura mode updated from system config:", mode)
            }
        }
    }

    // ─── Panel Overdrive ──────────────────────────────────────────────────────
    // true = enabled, false = disabled
    property bool panelOverdrive: false

    function setPanelOverdrive(enabled) {
        setOverdriveProc.command = [
            "asusctl", "armoury", "set", "panel_overdrive",
            enabled ? "1" : "0"
        ]
        setOverdriveProc.running = true
    }

    function togglePanelOverdrive() {
        setPanelOverdrive(!root.panelOverdrive)
    }

    // ─── Polling timer ────────────────────────────────────────────────────────
    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            queryProfileProc.running = true
            queryOverdriveProc.running = true
        }
    }

    // ─── Query: power profile ─────────────────────────────────────────────────
    Process {
        id: queryProfileProc
        command: ["asusctl", "profile", "get"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const match = data.trim().match(/^Active profile:\s*(\w+)/)
                if (match) root.powerProfile = match[1]
            }
        }
    }

    // ─── Set: power profile ───────────────────────────────────────────────────
    Process {
        id: setProfileProc
        command: []
        running: false
        onExited: (code, _) => { if (code === 0) queryProfileProc.running = true }
    }

    // ─── Next: power profile ──────────────────────────────────────────────────
    Process {
        id: nextProfileProc
        command: ["asusctl", "profile", "next"]
        running: false
        onExited: (code, _) => { if (code === 0) queryProfileProc.running = true }
    }

    // ─── Next: aura mode ─────────────────────────────────────────────────────
    Process {
        id: nextAuraProc
        command: ["asusctl", "aura", "effect", "--next-mode"]
        running: false
        onExited: (code, status) => {
            console.log("[AsusCtl] nextAuraProc exited with code:", code, "status:", status)
            if (code === 0) auraConfig.reload()
        }
    }

    // ─── Prev: aura mode ─────────────────────────────────────────────────────
    Process {
        id: prevAuraProc
        command: ["asusctl", "aura", "effect", "--prev-mode"]
        running: false
        onExited: (code, status) => {
            console.log("[AsusCtl] prevAuraProc exited with code:", code, "status:", status)
            if (code === 0) auraConfig.reload()
        }
    }

    // ─── Query: panel overdrive ───────────────────────────────────────────────
    property string _overdriveBuffer: ""

    Process {
        id: queryOverdriveProc
        command: ["asusctl", "armoury", "get", "panel_overdrive"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                root._overdriveBuffer += data
                const match = root._overdriveBuffer.match(/\((\d)\)/)
                if (match) {
                    root.panelOverdrive = match[1] === "1"
                    root._overdriveBuffer = ""
                }
            }
        }
        onExited: (_, __) => { root._overdriveBuffer = "" }
    }

    // ─── Set: panel overdrive ─────────────────────────────────────────────────
    Process {
        id: setOverdriveProc
        command: []
        running: false
        onExited: (code, _) => { if (code === 0) queryOverdriveProc.running = true }
    }
}
