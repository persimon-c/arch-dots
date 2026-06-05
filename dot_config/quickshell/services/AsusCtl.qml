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

    function nextProfile() {
        nextProfileProc.running = true
    }

    // ─── Aura / RGB ───────────────────────────────────────────────────────────
    // No query command exists — mode is tracked in-session after next/prev calls.
    // auraMode starts as "" until the user cycles modes this session.
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
        _auraModeIndex = (_auraModeIndex + 1) % auraModes.length
        auraMode = auraModes[_auraModeIndex]
    }

    function prevAuraMode() {
        prevAuraProc.running = true
        _auraModeIndex = (_auraModeIndex - 1 + auraModes.length) % auraModes.length
        auraMode = auraModes[_auraModeIndex]
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
    // `asusctl profile get` output:
    //   Active profile: Quiet
    //   AC profile Performance
    //   Battery profile Quiet
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
    }

    // ─── Prev: aura mode ─────────────────────────────────────────────────────
    Process {
        id: prevAuraProc
        command: ["asusctl", "aura", "effect", "--prev-mode"]
        running: false
    }

    // ─── Query: panel overdrive ───────────────────────────────────────────────
    // `asusctl armoury get panel_overdrive` output:
    //   panel_overdrive:
    //     current: [0,(1)]
    // The value in () is the currently active one.
    // [0,(1)] → active is 1 → overdrive ON
    // [(0),1] → active is 0 → overdrive OFF
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
