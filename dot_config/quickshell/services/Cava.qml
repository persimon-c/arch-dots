// Service: cava — implemented 2026-06-17
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Cava.qml — Audio visualizer service
 *
 * Spawns cava in raw output mode and parses stdout into a bar array.
 * Consumers (CavaPill, Visualiser) bind to the `bars` property.
 *
 * Startup sequence:
 *   1. homeProbe reads $HOME from the environment (one-shot, exits immediately)
 *   2. writeConfig writes ~/.cache/quickshell/cava.ini
 *   3. cavaProcess starts with -p pointing at that file
 *
 * Colors are NOT managed here — matugen writes the [color] section to
 * ~/.config/cava/config, and wallpaper-change.sh sends SIGUSR1 to
 * reload cava's colors in-place. This service only manages the raw
 * output subprocess.
 *
 * Bar count: 20 (matches CavaPill width budget; Visualiser can interpolate)
 * Channels: mono
 * Output: integers 0–1000 separated by ";" per line via stdout
 */
Singleton {
    id: root

    // ─── Public API ─────────────────────────────────────────────────────────

    /** Array of bar amplitudes, length == barCount, values 0.0–1.0 */
    property var bars: Array(barCount).fill(0.0)

    /** Number of bars cava outputs. Change here and in the written config. */
    readonly property int barCount: 10

    /** Whether the cava process is currently running */
    readonly property bool running: cavaProcess.running

    /** Restart cava (e.g. after manually editing cava config). */
    function restart() {
        cavaProcess.running = false
        // onRunningChanged → restartTimer → cavaProcess.running = true
    }

    // ─── Internal ────────────────────────────────────────────────────────────

    // Resolved absolute path to the cache config — set once homeProbe finishes.
    property string _configPath: ""

    Component.onCompleted: {
        homeProbe.running = true
    }

    // Step 1 — resolve $HOME
    // "sh -c 'echo $HOME'" is the simplest cross-env way to get the home dir
    // without hardcoding a username or relying on QML ~ expansion.
    Process {
        id: homeProbe
        running: false
        command: ["sh", "-c", "echo $HOME"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const home = text.trim()
                if (home.length === 0) {
                    console.error("[Cava] Could not resolve $HOME — aborting")
                    return
                }
                root._configPath = home + "/.cache/quickshell/cava.ini"
                writeConfig.running = true
            }
        }
    }

    // Step 2 — write the raw-mode config to cache
    // Only writes [general], [input], [output]. The [color] section lives in
    // ~/.config/cava/config and is owned by matugen + wallpaper-change.sh.
    Process {
        id: writeConfig
        running: false
        command: [
            "sh", "-c",
            `mkdir -p "$(dirname '${root._configPath}')" && cat > '${root._configPath}' << 'CAVAEOF'
[general]
bars = ${root.barCount}
sleep_timer = 5
autosens = 1
sensitivity = 100
lower_cutoff_freq = 50
higher_cutoff_freq = 10000

[input]
method = pipewire
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 1000
channels = mono
mono_option = average
CAVAEOF`
        ]

        onRunningChanged: {
            if (!writeConfig.running) cavaProcess.running = true
        }
    }

    // Step 3 — run cava
    Process {
        id: cavaProcess
        running: false

        command: ["cava", "-p", root._configPath]

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                const trimmed = data.trim()
                if (trimmed.length === 0) return

                // cava raw ascii outputs integers 0–ascii_max_range separated by ";"
                // e.g. "512;233;800;100;..."
                // Normalise to 0.0–1.0
                const parts = trimmed.split(";")
                const maxRange = 1000.0
                const parsed = []

                for (let i = 0; i < root.barCount; i++) {
                    const raw = parseInt(parts[i] ?? "0", 10)
                    parsed.push(isNaN(raw) ? 0.0 : Math.min(raw / maxRange, 1.0))
                }

                root.bars = parsed
            }
        }

        stderr: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (data.trim().length > 0)
                    console.warn("[Cava] stderr:", data.trim())
            }
        }

        // Auto-restart on exit (cava exits on audio device change / pipewire restart)
        onRunningChanged: {
            if (!cavaProcess.running) {
                console.log("[Cava] process exited — restarting in 2s")
                restartTimer.start()
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 2000
        repeat: false
        onTriggered: cavaProcess.running = true
    }
}
