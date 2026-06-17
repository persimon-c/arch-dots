// Service: powerprofile — implemented 2026-06-17
// services/PowerProfileService.qml
// Power profile management via power-profiles-daemon (UPower)
// Exposes: active profile (readable + writable), available profiles,
//          performance availability, degradation reason, and holds from other apps.
//
// NOTE: Requires power-profiles-daemon to be installed and running.
//       UPower alone is NOT sufficient — they are separate packages.
//       If the daemon is absent, PowerProfiles properties will be undefined/null.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    // ── Active profile ────────────────────────────────────────────────────────
    // Read:  current profile as PowerProfile enum (Balanced / PowerSaver / Performance)
    // Write: setting this changes the system profile (via helper functions).
    readonly property var profile: PowerProfiles ? PowerProfiles.profile : null

    onProfileChanged: {
        if (PowerProfiles) {
            console.log("[PowerProfileService] Active profile:", PowerProfile.toString(PowerProfiles.profile))
        }
    }

    // ── Profile availability ──────────────────────────────────────────────────
    // True only if the hardware exposes a performance profile to power-profiles-daemon.
    // Gate any Performance UI on this — do not show Performance toggle if false.
    readonly property bool hasPerformanceProfile: PowerProfiles ? PowerProfiles.hasPerformanceProfile : false

    // ── Performance degradation ───────────────────────────────────────────────
    // PerformanceDegradationReason enum: None / LapDetected / HighTemperature
    // Useful for showing a warning badge when Performance is active but throttled.
    readonly property var degradationReason: PowerProfiles ? PowerProfiles.degradationReason : null

    readonly property bool isDegraded: PowerProfiles ? (PowerProfiles.degradationReason !== PerformanceDegradationReason.None) : false

    // ── Third-party holds ─────────────────────────────────────────────────────
    // List of { profile, applicationId, reason } objects set by other processes.
    // e.g. a game holding Performance, or a power daemon holding PowerSaver.
    // If any hold is active, the user's explicit profile change will clear them all.
    readonly property var holds: PowerProfiles ? PowerProfiles.holds : []

    readonly property bool hasActiveHolds: PowerProfiles ? (PowerProfiles.holds.length > 0) : false

    // ── Convenience booleans (for binding to UI toggle states) ────────────────
    readonly property bool isPerformance: PowerProfiles ? (PowerProfiles.profile === PowerProfile.Performance) : false
    readonly property bool isBalanced:    PowerProfiles ? (PowerProfiles.profile === PowerProfile.Balanced) : false
    readonly property bool isPowerSaver:  PowerProfiles ? (PowerProfiles.profile === PowerProfile.PowerSaver) : false

    // ── Human-readable label for current profile ─────────────────────────────
    readonly property string profileLabel: PowerProfiles ? PowerProfile.toString(PowerProfiles.profile) : ""

    // ── Degradation reason label ──────────────────────────────────────────────
    readonly property string degradationLabel: {
        if (!PowerProfiles) return ""
        switch (PowerProfiles.degradationReason) {
            case PerformanceDegradationReason.LapDetected:   return "Lap detected"
            case PerformanceDegradationReason.HighTemperature: return "High temperature"
            default: return ""
        }
    }

    // ── Write helpers ─────────────────────────────────────────────────────────
    // Call these from UI rather than writing PowerProfiles.profile directly,
    // so the guard on hasPerformanceProfile is enforced in one place.

    function setPerformance() {
        if (!PowerProfiles) return
        if (root.hasPerformanceProfile) {
            PowerProfiles.profile = PowerProfile.Performance
        } else {
            console.warn("[PowerProfileService] setPerformance() called but hardware has no Performance profile")
        }
    }

    function setBalanced() {
        if (!PowerProfiles) return
        PowerProfiles.profile = PowerProfile.Balanced
    }

    function setPowerSaver() {
        if (!PowerProfiles) return
        PowerProfiles.profile = PowerProfile.PowerSaver
    }

    // ── Startup log ───────────────────────────────────────────────────────────
    Component.onCompleted: {
        console.log("[PowerProfileService] Initialized")
        if (PowerProfiles) {
            console.log("[PowerProfileService]   Active profile:        ", PowerProfile.toString(PowerProfiles.profile))
            console.log("[PowerProfileService]   Has Performance profile:", PowerProfiles.hasPerformanceProfile)
            console.log("[PowerProfileService]   Degradation reason:    ", PerformanceDegradationReason.toString(PowerProfiles.degradationReason))
            console.log("[PowerProfileService]   Active holds:          ", PowerProfiles.holds.length)

            if (PowerProfiles.holds.length > 0) {
                for (let i = 0; i < PowerProfiles.holds.length; i++) {
                    const h = PowerProfiles.holds[i]
                    console.log("[PowerProfileService]     Hold", i, "— app:", h.applicationId,
                                "| profile:", PowerProfile.toString(h.profile),
                                "| reason:", h.reason)
                }
            }
        } else {
            console.warn("[PowerProfileService]   power-profiles-daemon is NOT available on the system.")
        }
    }
}
