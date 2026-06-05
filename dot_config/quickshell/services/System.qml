// services/System.qml — System statistics service
// CPU: /proc/stat        — delta between two reads → usage percent
// RAM: /proc/meminfo     — MemTotal, MemAvailable
// Disk: /proc/diskstats  — root partition via FileView on /
// Net:  /proc/net/dev    — rx/tx bytes delta per interval
// All reads are FileView + Timer polling. No external processes.
// Interval is 2s by default — change updateInterval to tune.

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── Poll interval (ms) ────────────────────────────────────────────────
    // 2000ms is a good balance for a sidebar stats card.
    // Set lower (e.g. 1000) for the utilities panel live view.

    property int updateInterval: 2000

    Timer {
        interval: root.updateInterval
        running: true
        repeat: true
        onTriggered: root._poll()
    }

    // ── Initial read on startup ───────────────────────────────────────────

    Component.onCompleted: {
        _poll()
        console.log("System: service ready")
    }

    function _poll() {
        cpuFile.reload()
        memFile.reload()
        diskFile.reload()
        netFile.reload()
    }

    // ─────────────────────────────────────────────────────────────────────
    // CPU
    // /proc/stat first line: "cpu  user nice system idle iowait irq softirq..."
    // Usage = 1 - (idle_delta / total_delta)
    // ─────────────────────────────────────────────────────────────────────

    FileView {
        id: cpuFile
        path: "/proc/stat"
        onLoaded: root._parseCpu()
    }

    // Previous tick values for delta calculation
    property real _cpuPrevIdle:  0
    property real _cpuPrevTotal: 0

    // Public
    property real cpuPercent: 0  // 0.0 – 100.0
    property real _cpuPercent: 0
    // expose via alias so it reads as a clean property
    Binding { target: root; property: "cpuPercent"; value: root._cpuPercent }

    function _parseCpu() {
        var line = cpuFile.text().split("\n")[0]  // "cpu  ..."
        var parts = line.trim().split(/\s+/)
        // parts: ["cpu", user, nice, system, idle, iowait, irq, softirq, steal, ...]
        if (parts.length < 5) return

        var user    = parseFloat(parts[1]) || 0
        var nice    = parseFloat(parts[2]) || 0
        var system  = parseFloat(parts[3]) || 0
        var idle    = parseFloat(parts[4]) || 0
        var iowait  = parseFloat(parts[5]) || 0
        var irq     = parseFloat(parts[6]) || 0
        var softirq = parseFloat(parts[7]) || 0
        var steal   = parseFloat(parts[8]) || 0

        var totalIdle  = idle + iowait
        var totalBusy  = user + nice + system + irq + softirq + steal
        var total      = totalIdle + totalBusy

        var deltaTotal = total - _cpuPrevTotal
        var deltaIdle  = totalIdle - _cpuPrevIdle

        if (deltaTotal > 0) {
            _cpuPercent = Math.round((1 - deltaIdle / deltaTotal) * 100)
        }

        _cpuPrevTotal = total
        _cpuPrevIdle  = totalIdle
    }

    // ─────────────────────────────────────────────────────────────────────
    // RAM
    // /proc/meminfo — MemTotal, MemAvailable (in kB)
    // Used = MemTotal - MemAvailable  (most accurate "actually used" figure)
    // ─────────────────────────────────────────────────────────────────────

    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: root._parseMem()
    }

    // Public — all in MiB for display
    property real ramTotalMiB:    0
    property real ramUsedMiB:     0
    property real ramAvailMiB:    0
    readonly property real ramPercent: ramTotalMiB > 0
        ? Math.round((ramUsedMiB / ramTotalMiB) * 100) : 0

    // Human-readable strings
    readonly property string ramUsedStr:  _mibStr(ramUsedMiB)
    readonly property string ramTotalStr: _mibStr(ramTotalMiB)

    function _parseMem() {
        var text  = memFile.text()
        var total = _memKey(text, "MemTotal")
        var avail = _memKey(text, "MemAvailable")
        if (total <= 0) return
        ramTotalMiB = total / 1024
        ramAvailMiB = avail / 1024
        ramUsedMiB  = ramTotalMiB - ramAvailMiB
    }

    function _memKey(text, key) {
        var re = new RegExp(key + ":\\s+(\\d+)")
        var m  = text.match(re)
        return m ? parseFloat(m[1]) : 0
    }

    function _mibStr(mib) {
        if (mib >= 1024) return (mib / 1024).toFixed(1) + " GiB"
        return Math.round(mib) + " MiB"
    }

    // ─────────────────────────────────────────────────────────────────────
    // Disk — root partition (/)
    // /proc/mounts gives us the device name, but reading usage is easier
    // via `df` — however to avoid a Process we read /proc/diskstats for
    // I/O rates and use statvfs-equivalent via a one-shot df call only
    // at startup for total/used. We refresh disk usage every 30s (it
    // changes slowly) using a separate slower timer.
    // ─────────────────────────────────────────────────────────────────────

    FileView {
        id: diskFile
        path: "/proc/diskstats"
        onLoaded: root._parseDiskIo()
    }

    // Disk usage — updated by df process every 30s
    property real diskTotalGiB: 0
    property real diskUsedGiB:  0
    property real diskFreeGiB:  0
    readonly property real diskPercent: diskTotalGiB > 0
        ? Math.round((diskUsedGiB / diskTotalGiB) * 100) : 0

    readonly property string diskUsedStr:  diskUsedGiB.toFixed(1) + " GiB"
    readonly property string diskTotalStr: diskTotalGiB.toFixed(1) + " GiB"

    // Disk I/O rates (MiB/s)
    property real diskReadMibs:  0
    property real diskWriteMibs: 0

    property real _diskPrevRead:  0
    property real _diskPrevWrite: 0
    property string _rootDevice: ""  // e.g. "sda" or "nvme0n1"

    // Slower timer for disk usage (df) — every 30s
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: dfProcess.running = true
    }

    Process {
        id: dfProcess
        command: ["df", "--output=source,size,used,avail", "/"]
        stdout: StdioCollector {
            onStreamFinished: root._parseDf(this.text)
        }
    }

    function _parseDf(text) {
        var lines = text.trim().split("\n")
        if (lines.length < 2) return
        var parts = lines[1].trim().split(/\s+/)
        // parts: [source, 1K-blocks, used, avail]
        if (parts.length < 4) return
        _rootDevice  = parts[0].replace(/^\/dev\//, "").replace(/p?\d+$/, "")
        diskTotalGiB = parseFloat(parts[1]) / (1024 * 1024)
        diskUsedGiB  = parseFloat(parts[2]) / (1024 * 1024)
        diskFreeGiB  = parseFloat(parts[3]) / (1024 * 1024)
    }

    function _parseDiskIo() {
        if (!_rootDevice) return
        var lines = diskFile.text().split("\n")
        for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].trim().split(/\s+/)
            // field 3 is device name, field 6 is sectors read, field 10 is sectors written
            if (parts.length < 10) continue
            if (parts[2] !== _rootDevice) continue

            var sectorsRead  = parseFloat(parts[5])  || 0
            var sectorsWrite = parseFloat(parts[9])  || 0
            // Linux sector = 512 bytes
            var bytesRead  = sectorsRead  * 512
            var bytesWrite = sectorsWrite * 512

            if (_diskPrevRead > 0) {
                diskReadMibs  = Math.max(0, (bytesRead  - _diskPrevRead)  / (updateInterval / 1000) / (1024 * 1024))
                diskWriteMibs = Math.max(0, (bytesWrite - _diskPrevWrite) / (updateInterval / 1000) / (1024 * 1024))
            }
            _diskPrevRead  = bytesRead
            _diskPrevWrite = bytesWrite
            break
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // Network throughput
    // /proc/net/dev — rx/tx bytes delta per interval
    // Uses the first non-loopback interface that has traffic.
    // ─────────────────────────────────────────────────────────────────────

    FileView {
        id: netFile
        path: "/proc/net/dev"
        onLoaded: root._parseNet()
    }

    // Public — KiB/s
    property real netRxKibs: 0
    property real netTxKibs: 0

    readonly property string netRxStr: _netStr(netRxKibs)
    readonly property string netTxStr: _netStr(netTxKibs)

    property var _netPrev: ({})  // { ifname: { rx, tx } }

    function _parseNet() {
        var lines = netFile.text().split("\n")
        // Skip header lines (first 2)
        var best = null
        var bestRx = -1

        for (var i = 2; i < lines.length; i++) {
            var line = lines[i].trim()
            if (!line) continue
            var colon = line.indexOf(":")
            if (colon < 0) continue
            var iface = line.substring(0, colon).trim()
            if (iface === "lo") continue

            var parts = line.substring(colon + 1).trim().split(/\s+/)
            // fields: rx_bytes, rx_packets, rx_errs, rx_drop, rx_fifo, rx_frame, rx_compressed, rx_multicast,
            //         tx_bytes, tx_packets, ...
            if (parts.length < 9) continue
            var rx = parseFloat(parts[0]) || 0
            var tx = parseFloat(parts[8]) || 0

            var prev = _netPrev[iface] || { rx: rx, tx: tx }
            var deltaRx = Math.max(0, rx - prev.rx)
            var deltaTx = Math.max(0, tx - prev.tx)
            _netPrev[iface] = { rx: rx, tx: tx }

            // Pick the interface with the most traffic as "primary"
            if (deltaRx + deltaTx > bestRx) {
                bestRx = deltaRx + deltaTx
                best = { rx: deltaRx, tx: deltaTx }
            }
        }

        if (best) {
            var interval_s = updateInterval / 1000
            netRxKibs = best.rx / interval_s / 1024
            netTxKibs = best.tx / interval_s / 1024
        }
    }

    function _netStr(kibs) {
        if (kibs >= 1024) return (kibs / 1024).toFixed(1) + " MiB/s"
        return Math.round(kibs) + " KiB/s"
    }

    // ── Uptime ────────────────────────────────────────────────────────────
    // /proc/uptime — first field is seconds since boot

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        watchChanges: false
    }

    Timer {
        interval: 60000  // update uptime display every minute
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            uptimeFile.reload()
            root._parseUptime()
        }
    }

    property string uptimeStr: ""
    property string _uptimeStr: ""
    Binding { target: root; property: "uptimeStr"; value: root._uptimeStr }

    function _parseUptime() {
        var v = parseFloat(uptimeFile.text().split(" ")[0])
        if (isNaN(v)) return
        var d = Math.floor(v / 86400)
        var h = Math.floor((v % 86400) / 3600)
        var m = Math.floor((v % 3600) / 60)
        if (d > 0)      _uptimeStr = d + "d " + h + "h " + m + "m"
        else if (h > 0) _uptimeStr = h + "h " + m + "m"
        else            _uptimeStr = m + "m"
    }
}