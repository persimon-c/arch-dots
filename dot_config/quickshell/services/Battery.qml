// services/Battery.qml — Battery status service
// Uses UPower.displayDevice as the primary source — it's UPower's own
// aggregate device intended for exactly this purpose (DE battery display).
// Falls back gracefully when no battery is present (desktop systems).

pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    // ── Internal: primary device ──────────────────────────────────────────
    // displayDevice is never null but may not be ready yet — guard with ready.

    readonly property UPowerDevice _dev: UPower.displayDevice

    // ── Availability ──────────────────────────────────────────────────────

    // True once UPower has initialised and a battery is actually present.
    // UI components should check this before showing battery widgets.
    readonly property bool available: _dev.ready && _dev.percentage > 0

    // True if the system is drawing from battery (not plugged in).
    readonly property bool onBattery: UPower.onBattery

    // ── Charge ────────────────────────────────────────────────────────────

    // 0.0 – 100.0
    readonly property real percentage: available ? _dev.percentage : 0.0

    // Rounded integer for display (e.g. "74%")
    readonly property int  percentInt: Math.round(percentage * 100)
    
    // ── State ─────────────────────────────────────────────────────────────

    readonly property int state: available ? _dev.state : UPowerDeviceState.Unknown

    readonly property bool isCharging:     state === UPowerDeviceState.Charging
    readonly property bool isDischarging:  state === UPowerDeviceState.Discharging
    readonly property bool isFullyCharged: state === UPowerDeviceState.FullyCharged
    readonly property bool isPending:      state === UPowerDeviceState.PendingCharge
                                        || state === UPowerDeviceState.PendingDischarge

    // Plugged in = charging OR full OR pending charge
    readonly property bool isPluggedIn: !onBattery

    // ── Time estimates ────────────────────────────────────────────────────

    // Raw seconds from UPower (0 if not applicable)
    readonly property real timeToEmpty: available ? _dev.timeToEmpty : 0
    readonly property real timeToFull:  available ? _dev.timeToFull  : 0

    // Human-readable strings — "1h 23m", or "" if not available
    readonly property string timeToEmptyString: _formatTime(timeToEmpty)
    readonly property string timeToFullString:  _formatTime(timeToFull)

    function _formatTime(secs) {
        if (secs <= 0) return ""
        var h = Math.floor(secs / 3600)
        var m = Math.floor((secs % 3600) / 60)
        if (h > 0 && m > 0) return h + "h " + m + "m"
        if (h > 0)           return h + "h"
        return m + "m"
    }

    // ── Health ────────────────────────────────────────────────────────────

    readonly property bool healthSupported:  available && _dev.healthSupported
    readonly property real healthPercentage: healthSupported ? _dev.healthPercentage : 0.0

    // ── Icon ──────────────────────────────────────────────────────────────
    // UPower provides an icon name — use it as fallback; we'll override in
    // the bar component with our own icon logic once Icons.qml exists (QS3).

    readonly property string iconName: available ? _dev.iconName : "battery-missing-symbolic"

    // Semantic icon name for our own icon set — resolved in IconButton/bar later.
    // Levels: full ≥90, high ≥60, medium ≥30, low ≥10, critical <10
    readonly property string levelName: {
        if (!available)         return "missing"
        if (isFullyCharged)     return "full"
        if (percentInt >= 90)   return "full"
        if (percentInt >= 60)   return "high"
        if (percentInt >= 30)   return "medium"
        if (percentInt >= 10)   return "low"
        return "critical"
    }
}
