// services/DateTime.qml — Date and time service
// Wraps SystemClock and exposes pre-formatted strings so UI components
// never format dates themselves — change format here, updates everywhere.

import Quickshell
import QtQuick

Singleton {
    id: root

    // ── Clock ─────────────────────────────────────────────────────────────

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // ── Raw values ────────────────────────────────────────────────────────

    readonly property int    hours:   clock.hours
    readonly property int    minutes: clock.minutes
    readonly property int    seconds: clock.seconds
    readonly property date   date:    clock.date

    // ── Formatted strings ─────────────────────────────────────────────────
    // Bar / pill display
    readonly property string timeShort:    Qt.formatDateTime(clock.date, "hh:mm")        // 14:35
    readonly property string timeFull:     Qt.formatDateTime(clock.date, "hh:mm:ss")     // 14:35:07
    readonly property string timePeriod:   Qt.formatDateTime(clock.date, "hh:mm AP")     // 02:35 PM

    // Date display
    readonly property string dateShort:    Qt.formatDateTime(clock.date, "ddd d MMM")    // Mon 5 Jun
    readonly property string dateFull:     Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy") // Monday, 5 June 2026
    readonly property string dateIso:      Qt.formatDateTime(clock.date, "yyyy-MM-dd")   // 2026-06-05

    // Lock screen / desktop clock — large display
    readonly property string timeHero:     Qt.formatDateTime(clock.date, "hh:mm")        // 14:35
    readonly property string dateHero:     Qt.formatDateTime(clock.date, "dddd, d MMMM")  // Monday, 5 June

    // Calendar dropdown — month/year header
    readonly property string monthYear:    Qt.formatDateTime(clock.date, "MMMM yyyy")    // June 2026

    // Notification timestamps — exposed as a function since notifications
    // need to format arbitrary past times, not just now.
    function formatTime(d) {
        return Qt.formatDateTime(d, "hh:mm")
    }
    function formatDateTime(d) {
        return Qt.formatDateTime(d, "ddd hh:mm")
    }

    // ── Debug ─────────────────────────────────────────────────────────────
    Component.onCompleted: {
        console.log("DateTime: service ready —", timeFull, dateShort)
    }
}
