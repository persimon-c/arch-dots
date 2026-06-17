// Service: notifications — implemented 2026-06-17
// services/Notifications.qml — Notification service
//
// Uses server.trackedNotifications directly as the popup model so that
// QML's modelData binding works correctly (JS arrays lose QObject refs).
//
// Two lists:
//   server.trackedNotifications — live popup model (QML-native, modelData works)
//   history                     — notification center list (max 50)
//
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // ── Config ────────────────────────────────────────────────────────────

    readonly property int maxPopups:        5
    readonly property int maxHistory:       50
    readonly property int defaultTimeoutMs: 5000

    // ── Server ────────────────────────────────────────────────────────────

    NotificationServer {
        id: server

        actionsSupported:        true
        actionIconsSupported:    true
        bodySupported:           true
        bodyMarkupSupported:     false   // plain text only — avoids StyledText render bugs
        bodyHyperlinksSupported: false
        imageSupported:          true
        persistenceSupported:    true
        inlineReplySupported:    false
        keepOnReload:            true

        onNotification: function(notif) {
            notif.tracked = true
            root._handleIncoming(notif)
        }
    }

    // ── Expose trackedNotifications for the popup ListView ─────────────────
    // Use this as the model in NotificationPopup — modelData will be the
    // Notification object with .summary, .body, .appName, etc.

    readonly property var trackedNotifications: server.trackedNotifications

    // ── Timer tracking (keyed by notification id) ─────────────────────────

    property var _timers: ({})

    // ── Incoming ──────────────────────────────────────────────────────────

    function _handleIncoming(notif) {
        console.log("[Notifications] Incoming: id=" + notif.id
            + " | appName='" + notif.appName
            + "' | summary='" + notif.summary
            + "' | body='" + notif.body + "'")

        // Cancel any previous timer for this id (notification update)
        _cancelTimer(notif.id)

        // Don't auto-expire Critical urgency
        var isCritical = notif.urgency === NotificationUrgency.Critical
        if (!isCritical) {
            var ms = notif.expireTimeout > 0 ? notif.expireTimeout * 1000 : defaultTimeoutMs
            var timer = Qt.createQmlObject(
                'import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false }',
                root, "notifTimer_" + notif.id
            )
            timer.triggered.connect((function(id) {
                return function() { root._expireById(id) }
            })(notif.id))
            _timers[notif.id] = timer
        }

        // Add to history (always store, including transient screenshot events)
        _addHistory(notif)
    }

    function _cancelTimer(notifId) {
        if (_timers[notifId]) {
            _timers[notifId].stop()
            _timers[notifId].destroy()
            delete _timers[notifId]
        }
    }

    function _expireById(notifId) {
        _cancelTimer(notifId)
        // Find and expire the notification via trackedNotifications
        var vals = server.trackedNotifications.values
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].id === notifId) {
                vals[i].expire()
                break
            }
        }
    }

    // ── Public API — popups ───────────────────────────────────────────────

    // Call from popup delegate onDismissed
    function dismissPopup(notifId) {
        _cancelTimer(notifId)
        var vals = server.trackedNotifications.values
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].id === notifId) {
                vals[i].dismiss()
                break
            }
        }
    }

    function dismissAllPopups() {
        _timers = {}
        var vals = server.trackedNotifications.values
        for (var i = 0; i < vals.length; i++) {
            vals[i].dismiss()
        }
    }

    // ── History ───────────────────────────────────────────────────────────

    property var history: []
    property int unreadCount: 0

    function _addHistory(notif) {
        var filtered = []
        for (var i = 0; i < history.length; i++) {
            if (history[i].id !== notif.id) filtered.push(history[i])
        }
        filtered.unshift(notif)
        if (filtered.length > maxHistory) filtered = filtered.slice(0, maxHistory)
        history = filtered
        unreadCount++
    }

    // ── Public API — history ──────────────────────────────────────────────

    function dismissNotification(notifId) {
        _removeFromHistory(notifId)
        _expireById(notifId)
    }

    function clearHistory() {
        history = []
        unreadCount = 0
    }

    function _removeFromHistory(notifId) {
        var filtered = []
        for (var i = 0; i < history.length; i++) {
            if (history[i].id !== notifId) filtered.push(history[i])
        }
        if (filtered.length !== history.length) {
            history = filtered
        }
    }

    function markAllRead() {
        unreadCount = 0
    }

    // ── Convenience ───────────────────────────────────────────────────────

    readonly property int  totalCount:       history.length
    readonly property bool hasNotifications: history.length > 0
    readonly property bool hasPopups:        server.trackedNotifications.values.length > 0

    // ── Cleanup when notification closed remotely ─────────────────────────

    Connections {
        target: server.trackedNotifications
        function onObjectRemovedPost(notif) {
            root._cancelTimer(notif.id)
        }
    }

    Component.onCompleted: {
        console.log("Notifications: service ready")
    }
}
