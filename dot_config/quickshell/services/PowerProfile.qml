// services/PowerProfile.qml
// Power profile management via power-profiles-daemon (UPower)
// Exposes: active profile (readable + writable), available profiles,
//          performance availability, degradation reason, and holds from other apps.
//
// NOTE: Requires power-profiles-daemon to be installed and running.
//       UPower alone is NOT sufficient — they are separate packages.
//       If the daemon is absent, PowerProfiles properties will be undefined/null.
pragma Singleton
import QtQuick
import Quickshell.Services.UPower

QtObject {
    id: root

    // ── Active profile ────────────────────────────────────────────────────────
    // Read:  current profile as PowerProfile enum (Balanced / PowerSaver / Performance)
    // Write: setting this changes the system profile.
    //        Setting Performance when hasPerformanceProfile is false is a no-op (daemon rejects it).
    //        Setting any profile explicitly clears all third-party holds.
    property var profile: PowerProfiles.profile

    onProfileChanged: {
        console.log("[PowerProfile] Active profile:", PowerProfile.toString(PowerProfiles.profile))
    }

    // ── Profile availability ──────────────────────────────────────────────────
    // True only if the hardware exposes a performance profile to power-profiles-daemon.
    // Gate any Performance UI on this — do not show Performance toggle if false.
    readonly property bool hasPerformanceProfile: PowerProfiles.hasPerformanceProfile

    // ── Performance degradation ───────────────────────────────────────────────
    // PerformanceDegradationReason enum: None / LapDetected / HighTemperature
    // Useful for showing a warning badge when Performance is active but throttled.
    readonly property var degradationReason: PowerProfiles.degradationReason

    readonly property bool isDegraded: PowerProfiles.degradationReason !== PerformanceDegradationReason.None

    // ── Third-party holds ─────────────────────────────────────────────────────
    // List of { profile, applicationId, reason } objects set by other processes.
    // e.g. a game holding Performance, or a power daemon holding PowerSaver.
    // If any hold is active, the user's explicit profile change will clear them all.
    readonly property var holds: PowerProfiles.holds

    readonly property bool hasActiveHolds: PowerProfiles.holds.length > 0

    // ── Convenience booleans (for binding to UI toggle states) ────────────────
    readonly property bool isPerformance: PowerProfiles.profile === PowerProfile.Performance
    readonly property bool isBalanced:    PowerProfiles.profile === PowerProfile.Balanced
    readonly property bool isPowerSaver:  PowerProfiles.profile === PowerProfile.PowerSaver

    // ── Human-readable label for current profile ─────────────────────────────
    readonly property string profileLabel: PowerProfile.toString(PowerProfiles.profile)

    // ── Degradation reason label ──────────────────────────────────────────────
    readonly property string degradationLabel: {
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
        if (root.hasPerformanceProfile) {
            PowerProfiles.profile = PowerProfile.Performance
        } else {
            console.warn("[PowerProfile] setPerformance() called but hardware has no Performance profile")
        }
    }

    function setBalanced() {
        PowerProfiles.profile = PowerProfile.Balanced
    }

    function setPowerSaver() {
        PowerProfiles.profile = PowerProfile.PowerSaver
    }

    // ── Startup log ───────────────────────────────────────────────────────────
    Component.onCompleted: {
        console.log("[PowerProfile] Initialized")
        console.log("[PowerProfile]   Active profile:        ", PowerProfile.toString(PowerProfiles.profile))
        console.log("[PowerProfile]   Has Performance profile:", PowerProfiles.hasPerformanceProfile)
        console.log("[PowerProfile]   Degradation reason:    ", PerformanceDegradationReason.toString(PowerProfiles.degradationReason))
        console.log("[PowerProfile]   Active holds:          ", PowerProfiles.holds.length)

        if (PowerProfiles.holds.length > 0) {
            for (let i = 0; i < PowerProfiles.holds.length; i++) {
                const h = PowerProfiles.holds[i]
                console.log("[PowerProfile]     Hold", i, "— app:", h.applicationId,
                            "| profile:", PowerProfile.toString(h.profile),
                            "| reason:", h.reason)
            }
        }
    }
}
