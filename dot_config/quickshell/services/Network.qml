// services/Network.qml — Network status service
// Exposes the primary wifi device and wired device separately.
// The bar pill only needs: connected, ssid, signalStrength, wifiEnabled.
// The network dropdown needs: available networks list, scan, connect/disconnect.

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root

    // ── Device discovery ──────────────────────────────────────────────────
    // Walk Networking.devices once and cache the first wifi + wired device.
    // Re-runs whenever the devices list changes (hotplug).

    property WifiDevice  _wifi:  null
    property WiredDevice _wired: null

    function _findDevices() {
        var wifi  = null
        var wired = null
        for (var i = 0; i < Networking.devices.count; i++) {
            var dev = Networking.devices.values[i]
            if (!wifi  && dev.type === DeviceType.Wifi)  wifi  = dev
            if (!wired && dev.type === DeviceType.Wired) wired = dev
            if (wifi && wired) break
        }
        _wifi  = wifi
        _wired = wired
    }

    Connections {
        target: Networking.devices
        function onObjectInsertedPost() { root._findDevices() }
        function onObjectRemovedPost()  { root._findDevices() }
    }

    // ── Wifi — availability ───────────────────────────────────────────────

    readonly property bool wifiAvailable:       _wifi !== null
    readonly property bool wifiEnabled:         Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled

    // ── Wifi — current connection ─────────────────────────────────────────

    readonly property bool wifiConnected: wifiAvailable && _wifi.connected

    // The active WifiNetwork — whichever network on the device is connected.
    readonly property WifiNetwork activeNetwork: {
        if (!wifiAvailable) return null
        for (var i = 0; i < _wifi.networks.count; i++) {
            var n = _wifi.networks.values[i]
            if (n.connected) return n
        }
        return null
    }

    readonly property string ssid:          activeNetwork !== null ? activeNetwork.name           : ""
    readonly property real   signalStrength: activeNetwork !== null ? activeNetwork.signalStrength : 0.0

    // Signal as 0–100 integer for display / icon tier
    readonly property int    signalInt:     Math.round(signalStrength * 100)

    // Icon tier: excellent ≥75, good ≥50, fair ≥25, weak <25
    readonly property string signalLevel: {
        if (!wifiConnected)    return "none"
        if (signalInt >= 75)   return "excellent"
        if (signalInt >= 50)   return "good"
        if (signalInt >= 25)   return "fair"
        return "weak"
    }

    // Security — for showing the lock icon in the dropdown
    readonly property var wifiSecurity: activeNetwork !== null ? activeNetwork.security : null

    // ── Wifi — available networks (for dropdown) ──────────────────────────

    // The full networks list on the wifi device — bind this in the dropdown.
    readonly property var availableNetworks: wifiAvailable ? _wifi.networks : null

    // Whether a scan is currently running
    readonly property bool scanning: wifiAvailable && _wifi.scannerEnabled

    // ── Wifi — actions ────────────────────────────────────────────────────

    function enableWifi()  { Networking.wifiEnabled = true  }
    function disableWifi() { Networking.wifiEnabled = false }
    function toggleWifi()  { Networking.wifiEnabled = !Networking.wifiEnabled }

    function startScan() {
        if (wifiAvailable) _wifi.scannerEnabled = true
    }

    function stopScan() {
        if (wifiAvailable) _wifi.scannerEnabled = false
    }

    // Connect to a WifiNetwork. Tries saved credentials first;
    // if connectionFailed fires with NoSecrets, caller must supply PSK.
    function connectNetwork(network) {
        if (network) network.connect()
    }

    function connectWithPsk(network, psk) {
        if (network) network.connectWithPsk(psk)
    }

    function disconnectNetwork(network) {
        if (network) network.disconnect()
    }

    function forgetNetwork(network) {
        if (network) network.forget()
    }

    // ── Wired ─────────────────────────────────────────────────────────────

    readonly property bool wiredAvailable: _wired !== null
    readonly property bool wiredConnected: wiredAvailable && _wired.connected
    readonly property bool wiredHasLink:   wiredAvailable && _wired.hasLink

    // ── Combined state — for bar pill ─────────────────────────────────────
    // Single property the bar pill binds to decide which icon/text to show.

    readonly property bool isConnected: wifiConnected || wiredConnected

    // "wifi" | "wired" | "none"
    readonly property string connectionType: {
        if (wifiConnected)  return "wifi"
        if (wiredConnected) return "wired"
        return "none"
    }

    // Human-readable label for the bar pill
    readonly property string label: {
        if (wifiConnected)  return ssid
        if (wiredConnected) return "Wired"
        if (!wifiEnabled)   return "Wi-Fi off"
        return "Disconnected"
    }

    // ── Connectivity ──────────────────────────────────────────────────────

    readonly property var connectivity: Networking.connectivity

    function checkConnectivity() {
        Networking.checkConnectivity()
    }

    // ── Debug ─────────────────────────────────────────────────────────────
    Component.onCompleted: {
        _findDevices()
        console.log("Network: service ready — wifi:", wifiAvailable, "| wired:", wiredAvailable)
        console.log("Network: connected:", isConnected, "| type:", connectionType, "| label:", label)
    }
}