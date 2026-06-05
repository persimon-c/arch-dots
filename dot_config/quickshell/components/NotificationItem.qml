// components/NotificationItem.qml
// Single notification card — shared by NotificationPopup and NotificationCenter.
//
// Displays: app icon, app name, summary, body, image (if any), action buttons.
// Urgency=Critical gets an accent-colored left border.
// Inline reply is supported when hasInlineReply is true.
//
// Usage:
//   NotificationItem {
//       notification: notifObject      // Quickshell Notification (required)
//       onDismissed: Notifications.dismissPopup(notification.id)
//   }
//
// implicitWidth must be set by the parent (e.g. width: Theme.notifWidth).
// This component sizes its height to content.

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Notifications
import "../theme"

Item {
    id: root

    // ── Required input ────────────────────────────────────────────────────

    required property var notification   // Quickshell Notification object

    // ── Optional callbacks ────────────────────────────────────────────────

    signal dismissed()
    signal actionInvoked(string actionId)

    // ── Layout ────────────────────────────────────────────────────────────

    implicitWidth:  Theme.notifWidth
    implicitHeight: card.implicitHeight

    // ── Derived helpers ───────────────────────────────────────────────────

    readonly property bool isCritical: notification.urgency === NotificationUrgency.Critical
    readonly property bool hasImage:   notification.image !== ""
    readonly property bool hasBody:    notification.body  !== ""
    readonly property bool hasActions: notification.actions.length > 0

    // ── Card background ───────────────────────────────────────────────────

    Rectangle {
        id: card

        anchors.left:  parent.left
        anchors.right: parent.right
        anchors.top:   parent.top

        implicitHeight: contentColumn.implicitHeight
                        + Theme.spacingMd * 2  // top + bottom padding

        radius: Theme.radiusLg

        color: Qt.rgba(
            Colors.surfaceContainerHigh.r,
            Colors.surfaceContainerHigh.g,
            Colors.surfaceContainerHigh.b,
            Theme.opacityPanel
        )

        border.color: Qt.rgba(
            Colors.outline.r,
            Colors.outline.g,
            Colors.outline.b,
            0.12
        )
        border.width: 1

        // ── Urgency accent stripe ─────────────────────────────────────────

        Rectangle {
            anchors.left:        parent.left
            anchors.top:         parent.top
            anchors.bottom:      parent.bottom
            anchors.topMargin:   Theme.radiusLg
            anchors.bottomMargin: Theme.radiusLg

            width:   3
            visible: root.isCritical

            color: Colors.error

            Rectangle {
                anchors.fill:    parent
                color:           Colors.error
                opacity:         0.6
                radius:          2
            }
        }

        // ── Main content ──────────────────────────────────────────────────

        ColumnLayout {
            id: contentColumn

            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.top:    parent.top
            anchors.margins: Theme.spacingMd
            anchors.leftMargin: root.isCritical ? Theme.spacingMd + 7 : Theme.spacingMd

            spacing: Theme.spacingXs

            // ── Header row: icon + app name + dismiss button ──────────────

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                // App icon
                Item {
                    implicitWidth:  16
                    implicitHeight: 16

                    Image {
                        anchors.fill: parent
                        source:       root.notification.appIcon !== ""
                                          ? ("image://icon/" + root.notification.appIcon)
                                          : ""
                        visible:      root.notification.appIcon !== ""
                        fillMode:     Image.PreserveAspectFit
                        smooth:       true
                        mipmap:       true
                    }

                    // Fallback dot when no icon
                    Rectangle {
                        anchors.centerIn: parent
                        width:  8
                        height: 8
                        radius: 4
                        color:  Colors.primary
                        visible: root.notification.appIcon === ""
                    }
                }

                // App name
                Text {
                    Layout.fillWidth: true
                    text:             root.notification.appName
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSizeXs
                    font.weight:      Theme.fontWeightMedium
                    color:            Colors.textMuted
                    elide:            Text.ElideRight
                }

                // Critical badge
                Rectangle {
                    implicitWidth:  42
                    implicitHeight: 14
                    radius:         7
                    color:          Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.18)
                    border.color:   Colors.error
                    border.width:   1
                    visible:        root.isCritical

                    Text {
                        anchors.centerIn: parent
                        text:             "URGENT"
                        font.family:      Theme.fontFamily
                        font.pixelSize:   8
                        font.weight:      Theme.fontWeightBold
                        color:            Colors.error
                    }
                }

                // Dismiss button
                Item {
                    implicitWidth:  20
                    implicitHeight: 20

                    Rectangle {
                        id: dismissBg
                        anchors.fill: parent
                        radius:       Theme.radiusFull
                        color:        Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b,
                                              dismissArea.containsMouse ? 0.18 : 0.0)

                        Behavior on color {
                            ColorAnimation { duration: Theme.durationFast }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text:             "✕"
                        font.pixelSize:   10
                        color:            dismissArea.containsMouse
                                              ? Colors.textPrimary
                                              : Colors.textMuted

                        Behavior on color {
                            ColorAnimation { duration: Theme.durationFast }
                        }
                    }

                    MouseArea {
                        id:           dismissArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.dismissed()
                    }
                }
            }

            // ── Summary + body ────────────────────────────────────────────

            RowLayout {
                Layout.fillWidth: true
                spacing:          Theme.spacingSm
                visible:          root.notification.summary !== "" || root.hasBody

                // Text column
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing:          Theme.spacingXxs

                    Text {
                        Layout.fillWidth: true
                        text:             root.notification.summary
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSizeMd
                        font.weight:      Theme.fontWeightSemiBold
                        color:            Colors.textPrimary
                        elide:            Text.ElideRight
                        maximumLineCount: 1
                        visible:          root.notification.summary !== ""
                        wrapMode:         Text.NoWrap
                    }

                    Text {
                        Layout.fillWidth: true
                        text:             root.notification.body
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSizeSm
                        color:            Colors.textMuted
                        wrapMode:         Text.WordWrap
                        maximumLineCount: 3
                        elide:            Text.ElideRight
                        visible:          root.hasBody
                        lineHeight:       1.3
                        textFormat:       Text.StyledText   // supports basic HTML from body markup
                    }
                }

                // Notification image (album art, avatar, etc.)
                Item {
                    implicitWidth:  48
                    implicitHeight: 48
                    visible:        root.hasImage

                    Rectangle {
                        anchors.fill: parent
                        radius:       Theme.radiusSm
                        color:        Colors.surfaceContainerHighest
                        clip:         true

                        Image {
                            anchors.fill: parent
                            source:       root.notification.image
                            fillMode:     Image.PreserveAspectCrop
                            smooth:       true
                            mipmap:       true
                        }
                    }
                }
            }

            // ── Action buttons ────────────────────────────────────────────

            RowLayout {
                Layout.fillWidth: true
                spacing:          Theme.spacingXs
                visible:          root.hasActions

                Repeater {
                    model: root.notification.actions

                    delegate: Item {
                        implicitWidth:  actionLabel.implicitWidth + Theme.spacingMd * 2
                        implicitHeight: 26

                        Rectangle {
                            anchors.fill: parent
                            radius:       Theme.radiusMd
                            color:        actionBtnArea.containsMouse
                                              ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.18)
                                              : Qt.rgba(Colors.surfaceContainerHighest.r,
                                                        Colors.surfaceContainerHighest.g,
                                                        Colors.surfaceContainerHighest.b, 0.7)
                            border.color: Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.2)
                            border.width: 1

                            Behavior on color {
                                ColorAnimation { duration: Theme.durationFast }
                            }

                            Text {
                                id:               actionLabel
                                anchors.centerIn: parent
                                text:             modelData.text
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.fontSizeSm
                                font.weight:      Theme.fontWeightMedium
                                color:            actionBtnArea.containsMouse
                                                      ? Colors.primary
                                                      : Colors.textPrimary

                                Behavior on color {
                                    ColorAnimation { duration: Theme.durationFast }
                                }
                            }

                            MouseArea {
                                id:           actionBtnArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    modelData.invoke()
                                    root.actionInvoked(modelData.identifier)
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }   // spacer to left-align action buttons
            }

            // ── Inline reply ──────────────────────────────────────────────

            RowLayout {
                Layout.fillWidth: true
                spacing:          Theme.spacingXs
                visible:          root.notification.hasInlineReply

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight:   30
                    radius:           Theme.radiusMd
                    color:            Qt.rgba(Colors.surfaceContainer.r,
                                             Colors.surfaceContainer.g,
                                             Colors.surfaceContainer.b, 0.9)
                    border.color:     replyField.activeFocus
                                          ? Colors.primary
                                          : Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.25)
                    border.width:     1

                    Behavior on border.color {
                        ColorAnimation { duration: Theme.durationFast }
                    }

                    TextInput {
                        id:             replyField
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin:  Theme.spacingSm
                        anchors.rightMargin: Theme.spacingSm

                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSm
                        color:          Colors.textPrimary
                        clip:           true

                        Keys.onReturnPressed: {
                            if (text.length > 0) {
                                root.notification.sendInlineReply(text)
                                text = ""
                            }
                        }

                        // Placeholder
                        Text {
                            anchors.fill:   parent
                            text:           root.notification.inlineReplyPlaceholder || "Reply…"
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color:          Colors.textMuted
                            visible:        replyField.text.length === 0 && !replyField.activeFocus
                        }
                    }
                }

                // Send button
                Item {
                    implicitWidth:  30
                    implicitHeight: 30

                    Rectangle {
                        anchors.fill: parent
                        radius:       Theme.radiusMd
                        color:        sendArea.containsMouse
                                          ? Colors.primary
                                          : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.25)
                        Behavior on color {
                            ColorAnimation { duration: Theme.durationFast }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text:             "↑"
                        font.pixelSize:   Theme.fontSizeMd
                        font.weight:      Theme.fontWeightBold
                        color:            sendArea.containsMouse ? Colors.onAccent : Colors.primary
                        Behavior on color {
                            ColorAnimation { duration: Theme.durationFast }
                        }
                    }

                    MouseArea {
                        id:           sendArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            if (replyField.text.length > 0) {
                                root.notification.sendInlineReply(replyField.text)
                                replyField.text = ""
                            }
                        }
                    }
                }
            }

            // Bottom spacing row (ensures padding below last element)
            Item { implicitHeight: 0 }
        }

        // ── Hover state ───────────────────────────────────────────────────

        property bool hovered: cardArea.containsMouse

        color: Qt.rgba(
            Colors.surfaceContainerHigh.r,
            Colors.surfaceContainerHigh.g,
            Colors.surfaceContainerHigh.b,
            hovered ? Math.min(1.0, Theme.opacityPanel + 0.06) : Theme.opacityPanel
        )

        Behavior on color {
            ColorAnimation { duration: Theme.durationFast }
        }

        MouseArea {
            id:           cardArea
            anchors.fill: parent
            hoverEnabled: true
            // Don't consume clicks — let child MouseAreas handle actions/dismiss.
            // acceptedButtons: Qt.NoButton would block children; just don't onClicked.
        }
    }
}
