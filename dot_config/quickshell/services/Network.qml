// services/Network.qml — Network status service
// Uses nmcli via Process for full control over scanning, connecting, and known networks.
// Quickshell.Networking is not used — nmcli gives us everything we need.

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Public state ──────────────────────────────────────────────────────

    property bool   wifiEnabled:      true
    property bool   wifiConnected:    false
    property bool   wiredConnected:   false
    property string ssid:             ""
    property int    signalInt:        0   // 0–100
    property var    networks:         []  // [ { ssid, signal, security, known } ]
    property var    knownSSIDs:       []
    property bool   scanning:         scanProc.running
    property bool   connecting:       false
    property string connectError:     ""

    // ── Derived ───────────────────────────────────────────────────────────

    readonly property bool isConnected: wifiConnected || wiredConnected

    readonly property string connectionType: {
        if (wifiConnected)  return "wifi"
        if (wiredConnected) return "wired"
        return "none"
    }

    readonly property string label: {
        if (wiredConnected)  return "Wired"
        if (wifiConnected)   return ssid
        if (!wifiEnabled)    return "Wi-Fi off"
        return "Disconnected"
    }

    readonly property string signalLevel: {
        if (!wifiConnected)   return "none"
        if (signalInt >= 80)  return "excellent"
        if (signalInt >= 60)  return "good"
        if (signalInt >= 40)  return "fair"
        if (signalInt >= 20)  return "weak"
        return "none"
    }

    // ── Internal scan state ───────────────────────────────────────────────

    property bool _isHardwareScan: false

    // ── Public functions ──────────────────────────────────────────────────

    function checkState() {
        stateProc.running  = false
        stateProc.running  = true
        wifiStatusProc.running = false
        wifiStatusProc.running = true
        if (!knownProc.running) knownProc.running = true
    }

    function refresh() {
        checkState()
        if (!scanProc.running) {
            root._isHardwareScan = false
            scanProc.command = ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY",
                                "dev", "wifi", "list", "--rescan", "no"]
            scanProc.running = true
        }
    }

    function startScan() {
        if (scanProc.running && !root._isHardwareScan) scanProc.running = false
        if (!scanProc.running) {
            root._isHardwareScan = true
            scanProc.command = ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY",
                                "dev", "wifi", "list", "--rescan", "yes"]
            scanProc.running = true
        }
    }

    function stopScan() {
        loopTimer.stop()
    }

    function enableWifi()  {
        Quickshell.execDetached(["nmcli", "radio", "wifi", "on"])
        wifiEnabled = true
        rescanTimer.start()
    }

    function disableWifi() {
        Quickshell.execDetached(["nmcli", "radio", "wifi", "off"])
        wifiEnabled = false
        ssid = ""
        signalInt = 0
        networks = []
    }

    function toggleWifi() {
        if (wifiEnabled) disableWifi()
        else             enableWifi()
    }

    function connectNetwork(ssidStr, password) {
        var pw = password || ""
        connecting   = true
        connectError = ""
        connectProc.targetSsid = ssidStr
        connectProc.pw         = pw
        connectProc.running    = false
        connectProc.running    = true
    }

    function disconnectNetwork() {
        Quickshell.execDetached(["nmcli", "dev", "disconnect", "wlan0"])
    }

    function forgetNetwork(ssidStr) {
        Quickshell.execDetached(["nmcli", "connection", "delete", ssidStr])
    }

    // ── nmcli monitor — reacts to connection changes ──────────────────────

    Process {
        id: monitorProc
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: function(line) { root.checkState() }
        }
    }

    // ── wifi radio state ──────────────────────────────────────────────────

    Process {
        id: wifiStatusProc
        command: ["nmcli", "radio", "wifi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = (text || "").trim() === "enabled"
            }
        }
    }

    // ── device connection state ───────────────────────────────────────────

    Process {
        id: stateProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "dev"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (text || "").trim().split("\n")
                var hasWifi    = false
                var hasEth     = false
                var activeConn = ""
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":")
                    if (parts.length < 2) continue
                    var type  = parts[0].trim()
                    var state = parts[1].trim()
                    if (state.indexOf("connected") !== -1) {
                        if (type === "wifi") {
                            hasWifi    = true
                            activeConn = parts.length > 2 ? parts[2].trim() : ""
                        } else if (type === "ethernet") {
                            hasEth = true
                        }
                    }
                }
                root.wifiConnected  = hasWifi
                root.wiredConnected = hasEth
                root.ssid           = activeConn
            }
        }
    }

    // ── wifi scan ─────────────────────────────────────────────────────────

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY",
                  "dev", "wifi", "list", "--rescan", "no"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root._parseNetworks(text)
                if (root.wifiEnabled) loopTimer.start()
            }
        }
    }

    Timer {
        id: loopTimer
        interval: 4000
        repeat:   false
        onTriggered: {
            if (root.wifiEnabled) root.startScan()
        }
    }

    Timer {
        id: rescanTimer
        interval: 1000
        onTriggered: root.startScan()
    }

    // ── known connections ─────────────────────────────────────────────────

    Process {
        id: knownProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "con", "show"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (text || "").trim().split("\n")
                var ssids = []
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":")
                    if (parts.length >= 2 && parts[1].trim() === "802-11-wireless")
                        ssids.push(parts[0].trim())
                }
                root.knownSSIDs = ssids
            }
        }
    }

    // ── connect ───────────────────────────────────────────────────────────

    Process {
        id: connectProc
        property string targetSsid: ""
        property string pw:         ""

        command: pw !== ""
            ? ["nmcli", "dev", "wifi", "connect", targetSsid, "password", pw]
            : ["nmcli", "dev", "wifi", "connect", targetSsid]

        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.connecting = false
                var out = (text || "").toLowerCase()
                if (out.indexOf("error") !== -1) {
                    root.connectError = (out.indexOf("secrets") !== -1 ||
                                         out.indexOf("password") !== -1)
                                            ? "Password required"
                                            : "Connection failed"
                } else {
                    root.connectError = ""
                    root.refresh()
                }
            }
        }
    }

    // ── background refresh ────────────────────────────────────────────────

    Timer {
        interval: 30000
        running:  true
        repeat:   true
        onTriggered: root.refresh()
    }

    // ── parse nmcli scan output ───────────────────────────────────────────

    function _parseNetworks(rawText) {
        var lines = (rawText || "").trim().split("\n")
        var nets        = []
        var foundActive = false

        for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].split(":")
            if (parts.length < 4) continue

            var active = parts[0].trim() === "yes"
            var sig    = parseInt(parts[parts.length - 2]) || 0
            var sec    = parts[parts.length - 1].trim()
            var name   = parts.slice(1, parts.length - 2).join(":").trim()

            if (name === "") continue

            if (active) {
                root.ssid      = name
                root.signalInt = sig
                foundActive    = true
            } else {
                var exists = false
                for (var j = 0; j < nets.length; j++) {
                    if (nets[j].ssid === name) {
                        if (sig > nets[j].signal) {
                            nets[j].signal   = sig
                            nets[j].security = sec
                        }
                        exists = true
                        break
                    }
                }
                if (!exists) {
                    nets.push({
                        ssid:     name,
                        signal:   sig,
                        security: sec,
                        known:    root.knownSSIDs.indexOf(name) !== -1
                    })
                }
            }
        }

        if (!foundActive) {
            root.signalInt = 0
            if (root._isHardwareScan) root.ssid = ""
        }

        nets.sort(function(a, b) { return b.signal - a.signal })

        // Only reassign if something changed
        if (root.networks.length !== nets.length) {
            root.networks = nets
        } else {
            var changed = false
            for (var k = 0; k < nets.length; k++) {
                if (nets[k].ssid   !== root.networks[k].ssid   ||
                    nets[k].signal !== root.networks[k].signal  ||
                    nets[k].known  !== root.networks[k].known) {
                    changed = true
                    break
                }
            }
            if (changed) root.networks = nets
        }
    }

    Component.onCompleted: {
        root.checkState()
        root.startScan()
    }
}