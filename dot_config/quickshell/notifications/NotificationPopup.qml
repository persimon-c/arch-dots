// notifications/NotificationPopup.qml
// On-screen toast notification popups positioned at the top-right of the screen.
//
// Features:
//   - Anchored to the top-right corner of the primary screen.
//   - Stacks notifications downwards (newest at the top).
//   - Window size shrinks/grows dynamically to wrap the list height.
//   - Window is completely hidden when no toasts exist, ensuring zero click interference.
//
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../services"
import "../components"

PanelWindow {
    id: root

    // Position and size properties
    anchors { top: true; right: true }
    margins { top: Theme.barHeight + 28; right: 12 }
    color: "transparent"
    implicitWidth: Theme.notifWidth
    implicitHeight: _listView.contentHeight

    visible: Notifications.hasPopups
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    ListView {
        id: _listView
        anchors.fill: parent
        spacing: Theme.spacingSm
        interactive: false
        model: Notifications.trackedNotifications

        delegate: Item {
            required property var modelData
            required property int index

            width: root.width
            height: innerItem.height

            NotificationItem {
                id: innerItem
                width: parent.width
                notification: modelData
                showProgress: true
                timeoutMs: modelData && modelData.expireTimeout > 0 ? modelData.expireTimeout * 1000 : 5000
                onDismissed: Notifications.dismissPopup(modelData.id)
            }
        }

        // ListView animations
        add: Transition {
            NumberAnimation { property: "x"; from: Theme.notifWidth; to: 0; duration: Theme.durationSlow; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Theme.durationNormal }
        }
        remove: Transition {
            NumberAnimation { property: "x"; to: Theme.notifWidth; duration: Theme.durationSlow; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            NumberAnimation { property: "opacity"; to: 0.0; duration: Theme.durationFast }
        }
        displaced: Transition {
            NumberAnimation { properties: "y"; duration: Theme.durationSlow; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
        }
    }
}
