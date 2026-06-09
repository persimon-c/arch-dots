// services/Bluetooth.qml — Bluetooth service
// Wraps the default adapter and exposes connected devices.
// The bar pill needs: enabled, connectedCount, primary device name/icon.
// The dropdown needs: all devices list, connect/disconnect/pair/forget.
pragma Singleton
import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    // ── Adapter ───────────────────────────────────────────────────────────

    readonly property BluetoothAdapter _adapter: Bluetooth.defaultAdapter

    readonly property bool adapterAvailable: _adapter !== null

    // Enabled state — writable, toggles the adapter on/off
    readonly property bool enabled: adapterAvailable && _adapter.enabled

    function setEnabled(on) {
        if (adapterAvailable) _adapter.enabled = on
    }

    function toggleEnabled() {
        setEnabled(!enabled)
    }

    // Whether the adapter is currently scanning for new devices
    readonly property bool discovering: adapterAvailable && _adapter.discovering

    function startDiscovery() {
        if (adapterAvailable) _adapter.discovering = true
    }

    function stopDiscovery() {
        if (adapterAvailable) _adapter.discovering = false
    }

    function toggleDiscovery() {
        if (discovering) stopDiscovery()
        else startDiscovery()
    }

    // Adapter name — for the dropdown header
    readonly property string adapterName: adapterAvailable ? _adapter.name : ""

    // ── Devices — full list (for dropdown) ────────────────────────────────
    // Bluetooth.devices is all connected devices across all adapters.
    // Adapter.devices is devices on the default adapter — use this for
    // the dropdown so we only show devices relevant to our adapter.

    readonly property var devices: adapterAvailable ? _adapter.devices : null

    // ── Connected devices ─────────────────────────────────────────────────

    // Count of currently connected devices — for the bar pill badge
    readonly property int connectedCount: {
        if (!adapterAvailable) return 0
        var count = 0
        for (var i = 0; i < _adapter.devices.count; i++) {
            if (_adapter.devices.values[i].connected) count++
        }
        return count
    }

    readonly property bool hasConnectedDevices: connectedCount > 0

    // Primary device — first connected device, used for bar pill label
    readonly property BluetoothDevice primaryDevice: {
        if (!adapterAvailable) return null
        for (var i = 0; i < _adapter.devices.count; i++) {
            var d = _adapter.devices.values[i]
            if (d.connected) return d
        }
        return null
    }

    // Bar pill label: device name if one connected, count if multiple, else ""
    readonly property string label: {
        if (!enabled)              return "Off"
        if (connectedCount === 0)  return "On"
        if (connectedCount === 1)  return primaryDevice.name
        return connectedCount + " connected"
    }

    // ── Device actions ────────────────────────────────────────────────────

    function connectDevice(device) {
        if (device) device.connect()
    }

    function disconnectDevice(device) {
        if (device) device.disconnect()
    }

    function pairDevice(device) {
        if (device) device.pair()
    }

    function cancelPairDevice(device) {
        if (device) device.cancelPair()
    }

    function forgetDevice(device) {
        if (device) device.forget()
    }

    function setDeviceTrusted(device, trusted) {
        if (device) device.trusted = trusted
    }

    function setDeviceBlocked(device, blocked) {
        if (device) device.blocked = blocked
    }

    // ── Debug ─────────────────────────────────────────────────────────────
    Component.onCompleted: {
        console.log("Bluetooth: service ready — adapter:", adapterAvailable)
        if (adapterAvailable) {
            console.log("Bluetooth: adapter:", adapterName,
                        "| enabled:", enabled,
                        "| connected devices:", connectedCount)
        }
    }
}
