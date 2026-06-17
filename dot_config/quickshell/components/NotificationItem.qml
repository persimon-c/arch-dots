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
import QtQuick.Shapes
import Quickshell.Services.Notifications
import "../theme"

Item {
    id: root

    // ── Timer/Progress properties ─────────────────────────────────────────

    property bool showProgress: false
    property int timeoutMs: 5000
    property real progressValue: 1.0

    readonly property real progress: showProgress ? progressValue : 1.0

    NumberAnimation {
        id: progressAnimator
        target: root
        property: "progressValue"
        from: 1.0
        to: 0.0
        duration: root.timeoutMs
        running: root.showProgress && root.timeoutMs > 0
    }


    // ── Colors ────────────────────────────────────────────────────────────

    readonly property color cPrimary:                  Qt.color(PanelColors.accent)
    readonly property color cSurfaceContainerHigh:     Qt.color(PanelColors.popupBackground)
    readonly property color cSurfaceContainerHighest:  Qt.color(PanelColors.rowBackground)
    readonly property color cSurfaceContainer:         Qt.color(PanelColors.popupBackground)
    readonly property color cOutline:                  Qt.color(PanelColors.border)
    readonly property color cError:                    Qt.color(PanelColors.error)
    readonly property color cTextPrimary:              Qt.color(PanelColors.textAccent)
    readonly property color cTextMuted:                Qt.color(PanelColors.textDim)
    readonly property color cOnAccentColor:            Qt.color(PanelColors.onAccent)

    // ── Required input ────────────────────────────────────────────────────

    required property var notification   // Quickshell Notification object

    // ── Optional callbacks ────────────────────────────────────────────────

    signal dismissed()
    signal actionInvoked(string actionId)

    implicitWidth:  Theme.notifWidth
    implicitHeight: card.implicitHeight
    height:         implicitHeight

    // ── Derived helpers ───────────────────────────────────────────────────

    readonly property bool isCritical: notification ? notification.urgency === NotificationUrgency.Critical : false
    readonly property bool hasImage:   notification ? notification.image   !== "" : false
    readonly property bool hasBody:    notification ? notification.body    !== "" : false
    readonly property bool hasActions: notification ? notification.actions.length > 0 : false

    readonly property string notifAppIcon: notification ? notification.appIcon : ""
    readonly property string notifAppName: notification ? notification.appName : ""
    readonly property string notifSummary: notification ? notification.summary : ""
    readonly property string notifBody:    notification ? notification.body : ""
    readonly property string notifImage:   notification ? notification.image : ""
    readonly property var    notifActions: notification ? notification.actions : []

    // ── Card background ───────────────────────────────────────────────────

    Rectangle {
        id: card

        anchors.left:  parent.left
        anchors.right: parent.right
        anchors.top:   parent.top

        implicitHeight: contentColumn.implicitHeight
                        + Theme.spacingMd * 2  // top + bottom padding
        height:         implicitHeight

        radius: 10

        property bool hovered: cardArea.containsMouse

        color: "transparent"

        AmbientSurface {
            anchors.fill: parent
            radius: card.radius
        }

        // Hover highlight overlay
        Rectangle {
            anchors.fill: parent
            radius: card.radius
            color: "white"
            opacity: card.hovered ? 0.05 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            }
        }

        border.color: root.isCritical ? cError : cPrimary
        border.width: 1.5

        // ── Left Accent Stripe ────────────────────────────────────────────

        Rectangle {
            width: 4
            height: parent.height - 24
            radius: 2
            anchors {
                left: parent.left
                leftMargin: 7
                verticalCenter: parent.verticalCenter
            }
            color: root.isCritical ? cError : cPrimary
            opacity: 0.85
        }

        // ── Main content ──────────────────────────────────────────────────

        ColumnLayout {
            id: contentColumn

            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.top:    parent.top
            anchors.margins: Theme.spacingMd
            anchors.leftMargin: Theme.spacingMd + 6

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
                        source:       root.notifAppIcon !== ""
                                          ? ("image://icon/" + root.notifAppIcon)
                                          : ""
                        visible:      root.notifAppIcon !== ""
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
                        color:  cPrimary
                        visible: root.notifAppIcon === ""
                    }
                }

                // App name
                Text {
                    Layout.fillWidth: true
                    text:             root.notifAppName
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSizeXs
                    font.weight:      Theme.fontWeightMedium
                    color:            PanelColors.textDim
                    elide:            Text.ElideRight
                    textFormat:       Text.PlainText
                }

                // Critical badge
                Rectangle {
                    implicitWidth:  42
                    implicitHeight: 14
                    radius:         7
                    color:          Qt.rgba(cError.r, cError.g, cError.b, 0.18)
                    border.color:   cError
                    border.width:   1
                    visible:        root.isCritical

                    Text {
                        anchors.centerIn: parent
                        text:             "URGENT"
                        font.family:      Theme.fontFamily
                        font.pixelSize:   8
                        font.weight:      Theme.fontWeightBold
                        color:            Colors.error
                        textFormat:       Text.PlainText
                    }
                }

                // Progress/Dismiss button container
                Item {
                    implicitWidth:  20
                    implicitHeight: 20

                    // Circular Progress Ring
                    Shape {
                        id: progressRing
                        anchors.fill: parent
                        visible:      root.showProgress && root.timeoutMs > 0
                        opacity:      card.hovered ? 0.0 : 1.0

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
                        }
                        
                        ShapePath {
                            strokeWidth: 2
                            strokeColor: cPrimary
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            
                            PathAngleArc {
                                centerX: 10
                                centerY: 10
                                radiusX: 7
                                radiusY: 7
                                startAngle: -90
                                sweepAngle: 360 * root.progress
                            }
                        }
                    }

                    // Dismiss button "✕"
                    Item {
                        anchors.fill: parent
                        opacity:      !root.showProgress || card.hovered ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
                        }

                        Rectangle {
                            id: dismissBg
                            anchors.fill: parent
                            radius:       Theme.radiusFull
                            color:        Qt.rgba(cOutline.r, cOutline.g, cOutline.b,
                                                  dismissArea.containsMouse ? 0.18 : 0.0)

                            Behavior on color {
                                ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text:             "✕"
                            font.pixelSize:   10
                            color:            dismissArea.containsMouse
                                                  ? cTextPrimary
                                                  : cTextMuted
                            textFormat:       Text.PlainText

                            Behavior on color {
                                ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
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
            }

            // Divider line
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: cOutline
                opacity: 0.15
                Layout.topMargin: 2
                Layout.bottomMargin: 4
            }

            // ── Summary + body ────────────────────────────────────────────

            RowLayout {
                Layout.fillWidth: true
                spacing:          Theme.spacingSm
                visible:          root.notifSummary !== "" || root.hasBody

                // Text column
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing:          Theme.spacingXxs

                    Text {
                        Layout.fillWidth: true
                        text:             root.notifSummary
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSizeMd
                        font.weight:      Theme.fontWeightSemiBold
                        color:            PanelColors.textAccent
                        elide:            Text.ElideRight
                        maximumLineCount: 1
                        visible:          root.notifSummary !== ""
                        textFormat:       Text.PlainText
                        wrapMode:         Text.NoWrap
                    }

                    Text {
                        Layout.fillWidth: true
                        text:             root.notifBody
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSizeSm
                        color:            PanelColors.textDim
                        wrapMode:         Text.WordWrap
                        maximumLineCount: 3
                        elide:            Text.ElideRight
                        visible:          root.hasBody
                        lineHeight:       1.3
                        textFormat:       Text.PlainText
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
                        color:        Qt.color(PanelColors.rowBackground)
                        clip:         true

                        Image {
                            anchors.fill: parent
                            source:       root.notifImage
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
                    model: root.notifActions

                    delegate: Item {
                        implicitWidth:  actionLabel.implicitWidth + Theme.spacingMd * 2
                        implicitHeight: 26

                        Rectangle {
                            anchors.fill: parent
                            radius:       Theme.radiusMd
                            color:        actionBtnArea.containsMouse
                                              ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.18)
                                              : Qt.rgba(cSurfaceContainerHighest.r,
                                                        cSurfaceContainerHighest.g,
                                                        cSurfaceContainerHighest.b, 0.7)
                            border.color: Qt.rgba(cOutline.r, cOutline.g, cOutline.b, 0.2)
                            border.width: 1

                            Behavior on color {
                                ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
                            }

                            Text {
                                id:               actionLabel
                                anchors.centerIn: parent
                                text:             modelData.text
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.fontSizeSm
                                font.weight:      Theme.fontWeightMedium
                                color:            actionBtnArea.containsMouse
                                                      ? cPrimary
                                                      : cTextPrimary

                                Behavior on color {
                                    ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
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

            // Bottom spacing row (ensures padding below last element)
            Item { implicitHeight: 0 }
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
