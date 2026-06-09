// services/System.qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── Poll interval (ms) ────────────────────────────────────────────────
    property int updateInterval: 2000

    Timer {
        interval: root.updateInterval
        running: true
        repeat: true
        onTriggered: root._poll()
    }

    Component.onCompleted: {
        _poll()
        console.log("System: service ready")
    }

    function _poll() {
        cpuFile.reload()
        memFile.reload()
        netFile.reload()
        diskStatsFile.reload()
    }

    // ─────────────────────────────────────────────────────────────────────
    // CPU
    // ─────────────────────────────────────────────────────────────────────

    FileView {
        id: cpuFile
        path: "/proc/stat"
        onLoaded: root._parseCpu()
    }

    property real _cpuPrevIdle:  0
    property real _cpuPrevTotal: 0
    property real cpuPercent:    0

    function _parseCpu() {
        var line = cpuFile.text().split("\n")[0]
        if (!line || !line.startsWith("cpu ")) return

        var parts = line.trim().split(/\s+/)
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

        if (deltaTotal > 0)
            cpuPercent = Math.round((1 - deltaIdle / deltaTotal) * 100)

        _cpuPrevTotal = total
        _cpuPrevIdle  = totalIdle
    }

    // ─────────────────────────────────────────────────────────────────────
    // RAM
    // ─────────────────────────────────────────────────────────────────────

    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: root._parseMem()
    }

    property real ramTotalMiB: 0
    property real ramUsedMiB:  0
    property real ramAvailMiB: 0

    readonly property real   ramPercent:  ramTotalMiB > 0 ? Math.round((ramUsedMiB / ramTotalMiB) * 100) : 0
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
        var m = text.match(new RegExp(key + ":\\s+(\\d+)"))
        return m ? parseFloat(m[1]) : 0
    }

    function _mibStr(mib) {
        if (mib >= 1024) return (mib / 1024).toFixed(1) + " GiB"
        return Math.round(mib) + " MiB"
    }

    // ─────────────────────────────────────────────────────────────────────
    // Disk — usage via df (one process, all mounts at once)
    // ─────────────────────────────────────────────────────────────────────

    property var monitoredDisks: ["nvme0n1p5", "sda3"]
    property var disks: ({})
    property int disksRevision: 0

    // Disk usage: one df process, slower poll
    Process {
        id: dfProc
        command: ["df", "--output=source,size,used,avail,target"]
        stdout: StdioCollector {
            onStreamFinished: root._parseDf(this.text)
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: dfProc.running = true
    }

    function _parseDf(output) {
        var lines = output.trim().split("\n")
        for (var i = 1; i < lines.length; ++i) {
            var parts = lines[i].trim().split(/\s+/)
            if (parts.length < 5) continue
            var source = parts[0].replace(/^\/dev\//, "")

            for (var d = 0; d < monitoredDisks.length; ++d) {
                var diskName = monitoredDisks[d]
                if (source !== diskName && !source.startsWith(diskName)) continue

                var totalGiB = parseFloat(parts[1]) / (1024 * 1024)
                var usedGiB  = parseFloat(parts[2]) / (1024 * 1024)
                var freeGiB  = parseFloat(parts[3]) / (1024 * 1024)
                var mount    = parts[4]
                var existing = disks[diskName] || {}

                var updated = Object.assign({}, existing, {
                    name:      diskName,
                    mount:     mount,
                    totalGiB:  totalGiB,
                    usedGiB:   usedGiB,
                    freeGiB:   freeGiB,
                    percent:   Math.round((usedGiB / totalGiB) * 100),
                    usedStr:   usedGiB.toFixed(1) + " GiB",
                    totalStr:  totalGiB.toFixed(1) + " GiB"
                })
                disks[diskName] = updated
            }
        }
        disksRevision++
    }

    // Disk I/O: /proc/diskstats, every poll interval
    FileView {
        id: diskStatsFile
        path: "/proc/diskstats"
        onLoaded: root._parseAllDiskIo()
    }

    property var _diskPrevIo: ({})

    function _parseAllDiskIo() {
        var lines = diskStatsFile.text().split("\n")
        var changed = false

        for (var d = 0; d < monitoredDisks.length; ++d) {
            var diskName = monitoredDisks[d]

            for (var i = 0; i < lines.length; ++i) {
                var parts = lines[i].trim().split(/\s+/)
                if (parts.length < 10 || parts[2] !== diskName) continue

                var bytesRead  = (parseFloat(parts[5])  || 0) * 512
                var bytesWrite = (parseFloat(parts[9])  || 0) * 512
                var prev       = _diskPrevIo[diskName]

                if (prev) {
                    var secs      = updateInterval / 1000
                    var readMibs  = Math.max(0, (bytesRead  - prev.read)  / secs / (1024 * 1024))
                    var writeMibs = Math.max(0, (bytesWrite - prev.write) / secs / (1024 * 1024))

                    if (disks[diskName]) {
                        var d2 = Object.assign({}, disks[diskName], {
                            readMibs:  readMibs,
                            writeMibs: writeMibs,
                            readStr:   _diskIoStr(readMibs),
                            writeStr:  _diskIoStr(writeMibs)
                        })
                        disks[diskName] = d2
                        changed = true
                    }
                }

                _diskPrevIo[diskName] = { read: bytesRead, write: bytesWrite }
                break
            }
        }

        if (changed) disksRevision++
    }

    function _diskIoStr(mibs) {
        if (mibs >= 1024) return (mibs / 1024).toFixed(1) + " GiB/s"
        if (mibs >= 1)    return mibs.toFixed(1) + " MiB/s"
        return (mibs * 1024).toFixed(0) + " KiB/s"
    }

    // Convenience: first disk (disksRevision dependency forces re-evaluation on update)
    readonly property real   diskTotalGiB:  { disksRevision; return _firstDisk("totalGiB",  0) }
    readonly property real   diskUsedGiB:   { disksRevision; return _firstDisk("usedGiB",   0) }
    readonly property real   diskFreeGiB:   { disksRevision; return _firstDisk("freeGiB",   0) }
    readonly property real   diskPercent:   { disksRevision; return _firstDisk("percent",   0) }
    readonly property string diskUsedStr:   { disksRevision; return _firstDisk("usedStr",   "") }
    readonly property string diskTotalStr:  { disksRevision; return _firstDisk("totalStr",  "") }

    function _firstDisk(key, fallback) {
        if (monitoredDisks.length === 0) return fallback
        var d = disks[monitoredDisks[0]]
        return d ? (d[key] ?? fallback) : fallback
    }

    // ─────────────────────────────────────────────────────────────────────
    // Network
    // ─────────────────────────────────────────────────────────────────────

    FileView {
        id: netFile
        path: "/proc/net/dev"
        onLoaded: root._parseNet()
    }

    property real   netRxKibs: 0
    property real   netTxKibs: 0
    property string primaryInterface: ""

    readonly property string netRxStr: _netStr(netRxKibs)
    readonly property string netTxStr: _netStr(netTxKibs)

    property var _netPrev: ({})

    function _parseNet() {
        var lines = netFile.text().split("\n")
        var best = null
        var bestTotal = -1

        for (var i = 2; i < lines.length; ++i) {
            var line = lines[i].trim()
            if (!line) continue
            var colon = line.indexOf(":")
            if (colon < 0) continue
            var iface = line.substring(0, colon).trim()
            if (iface === "lo") continue

            var parts = line.substring(colon + 1).trim().split(/\s+/)
            if (parts.length < 9) continue
            var rx = parseFloat(parts[0]) || 0
            var tx = parseFloat(parts[8]) || 0

            var prev   = _netPrev[iface] || { rx: rx, tx: tx }
            var deltaRx = Math.max(0, rx - prev.rx)
            var deltaTx = Math.max(0, tx - prev.tx)
            _netPrev[iface] = { rx: rx, tx: tx }

            if (deltaRx + deltaTx > bestTotal) {
                bestTotal = deltaRx + deltaTx
                best      = { rx: deltaRx, tx: deltaTx }
                primaryInterface = iface
            }
        }

        if (best) {
            var secs   = updateInterval / 1000
            netRxKibs = best.rx / secs / 1024
            netTxKibs = best.tx / secs / 1024
        }
    }

    function _netStr(kibs) {
        if (kibs >= 1024) return (kibs / 1024).toFixed(1) + " MiB/s"
        return Math.round(kibs) + " KiB/s"
    }

    // ─────────────────────────────────────────────────────────────────────
    // Uptime
    // ─────────────────────────────────────────────────────────────────────

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onLoaded: root._parseUptime()
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: uptimeFile.reload()
    }

    property string uptimeStr: ""

    function _parseUptime() {
        var text = uptimeFile.text()
        if (!text) return
        var v = parseFloat(text.split(" ")[0])
        if (isNaN(v)) return

        var d = Math.floor(v / 86400)
        var h = Math.floor((v % 86400) / 3600)
        var m = Math.floor((v % 3600) / 60)

        if (d > 0)      uptimeStr = d + "d " + h + "h " + m + "m"
        else if (h > 0) uptimeStr = h + "h " + m + "m"
        else            uptimeStr = m + "m"
    }
}