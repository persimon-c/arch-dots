// notifications/NotificationCenter.qml
// Fullscreen slide-out notification history center drawer.
//
// Features:
//   - Covers the full screen to draw a dark translucent backdrop.
//   - Dismisses when backdrop or Esc is clicked.
//   - Panel slides in from the right edge with a smooth cubic animation.
//   - Includes a 'Clear All' action to purge non-transient history.
//   - Displays a custom empty-state illustration when empty.
//
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../services"
import "../state"
import "../components"

PanelWindow {
    id: root

    // Cover the full screen
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: NotificationState.centerVisible || (panel.opacity > 0.01)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: NotificationState.centerVisible
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    // Reset scroll & unread count on opening
    onVisibleChanged: {
        if (visible && NotificationState.centerVisible) {
            Notifications.markAllRead()
        }
    }

    // ─── Backdrop ─────────────────────────────────────────────────────────────
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "transparent"

        focus: root.visible && NotificationState.centerVisible
        Keys.onEscapePressed: NotificationState.hide()

        MouseArea {
            anchors.fill: parent
            onClicked: NotificationState.hide()
        }
    }

    // ─── Panel Drawer (Floating Center) ───────────────────────────────────────
    Rectangle {
        id: panel
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: 10
            topMargin: 10
            bottomMargin: 10
        }
        width: 400

        color: "transparent"
        border.color: "transparent"
        border.width: 0
        radius: 10

        AmbientSurface {
            anchors.fill: parent
            radius: panel.radius
            borderColor: PanelColors.border
            borderWidth: 1.5
        }

        property real _anim: 0.0
        Component.onCompleted: _anim = NotificationState.centerVisible ? 1.0 : 0.0
        opacity: _anim

        transform: Translate {
            x: (1 - panel._anim) * (panel.width + 20)
        }

        NumberAnimation {
            id: animIn
            target: panel
            property: "_anim"
            to: 1.0
            duration: 250
            easing.type: Theme.easingType
            easing.bezierCurve: Theme.easingCurveIn
        }

        NumberAnimation {
            id: animOut
            target: panel
            property: "_anim"
            to: 0.0
            duration: 200
            easing.type: Theme.easingType
            easing.bezierCurve: Theme.easingCurveOut
        }

        Connections {
            target: NotificationState
            function onCenterVisibleChanged() {
                if (NotificationState.centerVisible) {
                    animOut.stop()
                    animIn.restart()
                } else {
                    animIn.stop()
                    animOut.restart()
                }
            }
        }

        // Intercept clicks on panel
        MouseArea {
            anchors.fill: parent
            onPressed: function(e) { e.accepted = true }
        }

        // Content layout
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingLg
            spacing: Theme.spacingMd

            // Header Section
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: Theme.spacingSm

                Text {
                    text: "NOTIFICATIONS"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    font.weight: Theme.fontWeightBold
                    color: PanelColors.textAccent
                    Layout.fillWidth: true
                }

                // Clear All Button
                Text {
                    text: "Clear All"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: PanelColors.textDim
                    opacity: clearHover.containsMouse ? 1.0 : 0.6
                    visible: Notifications.hasNotifications

                    Behavior on opacity { NumberAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                    MouseArea {
                        id: clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.clearHistory()
                    }
                }
            }

            // Stack container
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Empty State illustration
                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingSm
                    visible: !Notifications.hasNotifications

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰂜"
                        font.pixelSize: 32
                        color: PanelColors.textDim
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No notifications"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSm
                        color: PanelColors.textDim
                    }
                }

                // Notification History Scrollable List
                ListView {
                    anchors.fill: parent
                    spacing: Theme.spacingSm
                    clip: true
                    model: Notifications.history
                    visible: Notifications.hasNotifications

                    delegate: Item {
                        required property var modelData
                        required property int index

                        width: parent.width
                        height: innerItem.height

                        NotificationItem {
                            id: innerItem
                            width: parent.width
                            notification: modelData
                            onDismissed: Notifications.dismissNotification(modelData.id)
                        }
                    }
                }
            }
        }
    }
}
