// services/Notifications.qml — Notification service
// Replaces Swaync. Owns the NotificationServer and manages two lists:
//
//   popups  — active on-screen popups (max 5 simultaneous)
//             auto-expire after expireTimeout (default 5s if app sends 0)
//             Critical urgency stays until manually dismissed
//
//   history — persisted notification center list (max 50, no transients)
//             cleared manually or per-notification
//
// UI components (NotificationPopup, NotificationCenter) bind to these lists.
// They never interact with NotificationServer directly.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // ── Config ────────────────────────────────────────────────────────────

    readonly property int maxPopups:       5
    readonly property int maxHistory:      50
    readonly property int defaultTimeoutMs: 5000  // used when expireTimeout == 0

    // ── Server ────────────────────────────────────────────────────────────

    NotificationServer {
        id: server

        // Advertise full capabilities — we handle everything
        actionsSupported:      true
        actionIconsSupported:  true
        bodySupported:         true
        bodyMarkupSupported:   true
        bodyHyperlinksSupported: true
        imageSupported:        true
        persistenceSupported:  true
        inlineReplySupported:  true
        keepOnReload:          true

        onNotification: function(notif) {
            // Always track so the object isn't destroyed under us
            notif.tracked = true
            root._handleIncoming(notif)
        }
    }

    // ── Popup queue ───────────────────────────────────────────────────────
    // Array of { notification, timerId } objects.
    // Ordered newest-first so the UI can stack them top-to-bottom.

    property var popups: []

    // Emitted when the popup list changes — UI should bind to popups and
    // this signal to refresh (plain JS arrays don't trigger QML bindings).
    // signal popupsChanged()

    function _handleIncoming(notif) {
        // If this is an update to an existing notification (same id),
        // replace it in both lists rather than adding a duplicate.
        _removePopupById(notif.id)

        // Add to popup queue if under the limit
        if (popups.length < maxPopups) {
            _addPopup(notif)
        }

        // Add to history unless transient
        if (!notif.transient) {
            _addHistory(notif)
        }
    }

    function _addPopup(notif) {
        var timeoutMs = notif.expireTimeout > 0
            ? notif.expireTimeout * 1000
            : defaultTimeoutMs

        // Critical notifications don't auto-expire
        var isCritical = notif.urgency === NotificationUrgency.Critical

        var entry = { notification: notif, timerId: null }

        if (!isCritical) {
            entry.timerId = Qt.createQmlObject(
                'import QtQuick; Timer { interval: ' + timeoutMs + '; running: true; repeat: false }',
                root, "popupTimer"
            )
            entry.timerId.triggered.connect(function() {
                root._expirePopup(notif.id)
            })
        }

        // Prepend — newest first
        var updated = [entry].concat(popups)
        popups = updated
        popupsChanged()
    }

    function _expirePopup(notifId) {
        _removePopupById(notifId, true)
    }

    function _removePopupById(notifId, expire) {
        var updated = []
        for (var i = 0; i < popups.length; i++) {
            if (popups[i].notification.id === notifId) {
                // Clean up timer if present
                if (popups[i].timerId) {
                    popups[i].timerId.stop()
                    popups[i].timerId.destroy()
                }
                if (expire) popups[i].notification.expire()
            } else {
                updated.push(popups[i])
            }
        }
        if (updated.length !== popups.length) {
            popups = updated
            popupsChanged()
        }
    }

    // ── History ───────────────────────────────────────────────────────────
    // Array of Notification objects. Newest first. Max 50.
    // Transient notifications are never added here.

    property var history: []

    // signal historyChanged()

    // Unread count — notifications added since last center open
    property int unreadCount: 0

    function _addHistory(notif) {
        // Replace existing entry if same id (notification update)
        var filtered = []
        for (var i = 0; i < history.length; i++) {
            if (history[i].id !== notif.id) filtered.push(history[i])
        }

        // Prepend newest, cap at maxHistory
        filtered.unshift(notif)
        if (filtered.length > maxHistory) filtered = filtered.slice(0, maxHistory)

        history = filtered
        unreadCount++
        historyChanged()
    }

    // ── Public API — popups ───────────────────────────────────────────────

    // Dismiss a popup by notification id (user swipes/clicks dismiss)
    function dismissPopup(notifId) {
        var updated = []
        for (var i = 0; i < popups.length; i++) {
            if (popups[i].notification.id === notifId) {
                if (popups[i].timerId) {
                    popups[i].timerId.stop()
                    popups[i].timerId.destroy()
                }
                popups[i].notification.dismiss()
            } else {
                updated.push(popups[i])
            }
        }
        popups = updated
        popupsChanged()
        _removeFromHistory(notifId)
    }

    function dismissAllPopups() {
        for (var i = 0; i < popups.length; i++) {
            if (popups[i].timerId) {
                popups[i].timerId.stop()
                popups[i].timerId.destroy()
            }
            popups[i].notification.dismiss()
        }
        popups = []
        popupsChanged()
    }

    // ── Public API — history ──────────────────────────────────────────────

    function dismissNotification(notifId) {
        _removeFromHistory(notifId)
        // Also remove from popups if still showing
        _removePopupById(notifId)
        // Find and dismiss the notification object
        for (var i = 0; i < server.trackedNotifications.count; i++) {
            var n = server.trackedNotifications.values[i]
            if (n.id === notifId) { n.dismiss(); break }
        }
    }

    function clearHistory() {
        // Dismiss all tracked non-popup notifications
        for (var i = 0; i < history.length; i++) {
            var inPopup = false
            for (var j = 0; j < popups.length; j++) {
                if (popups[j].notification.id === history[i].id) { inPopup = true; break }
            }
            if (!inPopup) history[i].dismiss()
        }
        history = []
        unreadCount = 0
        historyChanged()
    }

    function _removeFromHistory(notifId) {
        var filtered = []
        for (var i = 0; i < history.length; i++) {
            if (history[i].id !== notifId) filtered.push(history[i])
        }
        if (filtered.length !== history.length) {
            history = filtered
            historyChanged()
        }
    }

    // Call this when the notification center is opened to reset unread count
    function markAllRead() {
        unreadCount = 0
    }

    // ── Convenience: total notification count for bar pill ────────────────

    readonly property int totalCount: history.length
    readonly property bool hasNotifications: history.length > 0
    readonly property bool hasPopups: popups.length > 0

    // ── Handle notification closed by remote app ──────────────────────────
    // When an app requests its notification be closed, clean up our lists.

    Connections {
        target: server.trackedNotifications
        
        function onObjectRemovedPost(notif, index) {
            root._removePopupById(notif.id);
            root._removeFromHistory(notif.id);
        }
    }

    // ── Debug ─────────────────────────────────────────────────────────────
    Component.onCompleted: {
        console.log("Notifications: service ready — keepOnReload: true, maxPopups:", maxPopups)
    }
}
