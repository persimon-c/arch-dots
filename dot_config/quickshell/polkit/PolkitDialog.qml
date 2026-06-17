import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland 
import "../theme"
import "../services"

/**
 * PolkitDialog.qml — Polkit authentication dialog
 *
 * PanelWindow that covers the full screen with a dimmed backdrop,
 * presenting a centered auth card. Instantiates Polkit.qml as a
 * child object — this is the single owner of PolkitAgent.
 *
 * Visibility: shown when polkit.active is true.
 * Input grab: HyprlandFocusGrab locks all input to this window while visible.
 */
PanelWindow {
    id: root

    // ─── Layout: full screen overlay ─────────────────────────────────────────
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Transparent window — backdrop drawn by the Rectangle inside
    color: "transparent"

    // Only process input when visible
    visible: polkit.active || (card.opacity > 0.01)
    focusable: polkit.active

    // WlrLayershell: sit above everything including other panels
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: polkit.active
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    // ─── Polkit service ───────────────────────────────────────────────────────
    Polkit {
        id: polkit
        onAuthRequestStarted: {
            passwordField.text = ""
            passwordField.forceActiveFocus()
            shakeAnim.stop()
        }
        onAuthFailed: {
            passwordField.text = ""
            shakeAnim.restart()
            passwordField.forceActiveFocus()
        }
        onAuthSucceeded: {
            // Visibility drops automatically via polkit.active → false
        }
        onAuthCancelled: {
            // Same — active goes false, window hides
        }
    }

    // ─── Focus grab (Hyprland) ────────────────────────────────────────────────
    HyprlandFocusGrab {
        id: focusGrab
        active: polkit.active
        windows: [root]
    }

    // ─── Backdrop ─────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)

        focus: root.visible
        Keys.onEscapePressed: polkit.cancel()

        // Dismiss on backdrop click (user-side cancel)
        MouseArea {
            anchors.fill: parent
            onClicked: polkit.cancel()
        }

        // ─── Auth card ────────────────────────────────────────────────────────
        Rectangle {
            id: card
            anchors.centerIn: parent
            width: 420
            // Height is dynamic — grows if identity picker or supplementary message appears
            height: cardLayout.implicitHeight + Theme.spacingMd * 6
            radius: Theme.radiusMd

            color: Colors.surfaceContainer
            layer.enabled: true
            layer.effect: null  // placeholder — blur effect can be added later

            opacity: polkit.active ? 1.0 : 0.0
            scale: polkit.active ? 1.0 : 0.90

            Behavior on opacity {
                NumberAnimation { duration: Theme.durationSlow; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            }
            Behavior on scale {
                NumberAnimation { duration: Theme.durationSlow; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            }


            // Subtle border
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: Qt.rgba(
                    Qt.lighter(Qt.color(Colors.outline), 1.2).r,
                    Qt.lighter(Qt.color(Colors.outline), 1.2).g,
                    Qt.lighter(Qt.color(Colors.outline), 1.2).b,
                    0.4
                )
                border.width: 1
            }

            // Shake animation on failed auth
            SequentialAnimation {
                id: shakeAnim
                loops: 1
                PropertyAnimation { target: card; property: "x"; to: card.x - 12; duration: 40; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: card; property: "x"; to: card.x + 12; duration: 40; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: card; property: "x"; to: card.x - 8;  duration: 40; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: card; property: "x"; to: card.x + 8;  duration: 40; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: card; property: "x"; to: card.x - 4;  duration: 40; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: card; property: "x"; to: card.x;      duration: 40; easing.type: Easing.InOutQuad }
            }

            ColumnLayout {
                id: cardLayout
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Theme.spacingMd * 3
                }
                spacing: Theme.spacingMd * 2

                // ── Icon + title ──────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingMd * 1.5

                    // Lock icon (dialog-password from FreeDesktop)
                    Image {
                        source: polkit.iconName !== ""
                            ? Quickshell.iconPath(polkit.iconName)
                            : Quickshell.iconPath("dialog-password")
                        width: 28
                        height: 28
                        sourceSize: Qt.size(28, 28)
                        smooth: true
                        visible: status === Image.Ready
                    }

                    Text {
                        text: polkit.message !== "" ? polkit.message : "Authentication Required"
                        color: Colors.onSurfaceColor
                        font.pixelSize: Theme.fontSizeLg
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // ── Action ID (subtle, machine-readable) ──────────────────────
                Text {
                    text: polkit.actionId
                    color: Colors.onSurfaceVariantColor
                    font.pixelSize: Theme.fontSizeSm
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: polkit.actionId !== ""
                    opacity: 0.7
                }

                // ── Identity picker (only if more than one identity) ───────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingMd
                    visible: polkit.identities.length > 1

                    Text {
                        text: "Authenticate as:"
                        color: Colors.onSurfaceVariantColor
                        font.pixelSize: Theme.fontSizeSm
                    }

                    Repeater {
                        model: polkit.identities
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 36
                            radius: Theme.radiusMd / 2
                            color: polkit.selectedIdentity === modelData
                                ? Qt.rgba(Qt.color(Colors.accent).r, Qt.color(Colors.accent).g, Qt.color(Colors.accent).b, 0.15)
                                : "transparent"
                            border.color: polkit.selectedIdentity === modelData
                                ? Colors.accent
                                : Colors.outline
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: Colors.onSurfaceColor
                                font.pixelSize: Theme.fontSizeMd
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: polkit.selectIdentity(modelData)
                            }
                        }
                    }
                }

                // ── Supplementary message (PAM info / error) ──────────────────
                Text {
                    text: polkit.supplementaryMessage
                    color: polkit.supplementaryIsError ? Colors.error : Colors.onSurfaceVariantColor
                    font.pixelSize: Theme.fontSizeSm
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    visible: polkit.supplementaryMessage !== ""
                }

                // ── Password / input field ────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: Theme.radiusMd / 2
                    color: Colors.surface
                    border.color: passwordField.activeFocus ? Colors.accent : Colors.outline
                    border.width: passwordField.activeFocus ? 2 : 1
                    visible: polkit.isResponseRequired

                    Behavior on border.color {
                        ColorAnimation { duration: 120 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: Theme.spacingMd * 1.5
                            rightMargin: Theme.spacingMd
                        }
                        spacing: Theme.spacingMd

                        TextInput {
                            id: passwordField
                            Layout.fillWidth: true
                            color: Colors.onSurfaceColor
                            font.pixelSize: Theme.fontSizeMd
                            echoMode: polkit.responseVisible
                                ? TextInput.Normal
                                : TextInput.Password
                            clip: true
                            onAccepted: {
                                if (text.length > 0) {
                                    polkit.submit(text)
                                    text = ""
                                }
                            }

                            // Placeholder overlay
                            Text {
                                anchors.fill: parent
                                text: polkit.inputPrompt !== "" ? polkit.inputPrompt : "Password"
                                color: Colors.onSurfaceVariantColor
                                font: passwordField.font
                                visible: passwordField.text.length === 0 && !passwordField.activeFocus
                                opacity: 0.6
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Visibility toggle (only relevant when responseVisible = true)
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: visToggleArea.containsMouse
                                ? Qt.rgba(Qt.color(Colors.onSurfaceColor).r, Qt.color(Colors.onSurfaceColor).g, Qt.color(Colors.onSurfaceColor).b, 0.08)
                                : "transparent"
                            visible: polkit.responseVisible

                            Image {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                source: passwordField.echoMode === TextInput.Normal
                                    ? Quickshell.iconPath("view-conceal")
                                    : Quickshell.iconPath("view-reveal")
                                sourceSize: Qt.size(18, 18)
                                smooth: true
                            }

                            MouseArea {
                                id: visToggleArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: passwordField.echoMode =
                                    passwordField.echoMode === TextInput.Normal
                                        ? TextInput.Password
                                        : TextInput.Normal
                            }
                        }
                    }
                }

                // ── Error badge (failed attempt) ──────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: Theme.radiusMd / 2
                    color: Qt.rgba(Qt.color(Colors.error).r, Qt.color(Colors.error).g, Qt.color(Colors.error).b, 0.12)
                    visible: polkit.failed && !polkit.isResponseRequired === false

                    Text {
                        anchors.centerIn: parent
                        text: "Incorrect password — try again"
                        color: Colors.error
                        font.pixelSize: Theme.fontSizeSm
                    }
                }

                // ── Buttons ───────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingMd

                    // Spacer
                    Item { Layout.fillWidth: true }

                    // Cancel
                    Rectangle {
                        width: 96
                        height: 38
                        radius: Theme.radiusMd / 2
                        color: cancelArea.containsMouse
                            ? Qt.rgba(Qt.color(Colors.onSurfaceColor).r, Qt.color(Colors.onSurfaceColor).g, Qt.color(Colors.onSurfaceColor).b, 0.08)
                            : "transparent"
                        border.color: Colors.outline
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: Colors.onSurfaceColor
                            font.pixelSize: Theme.fontSizeMd
                        }

                        MouseArea {
                            id: cancelArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: polkit.cancel()
                        }
                    }

                    // Authenticate
                    Rectangle {
                        width: 128
                        height: 38
                        radius: Theme.radiusMd / 2
                        color: authArea.containsMouse
                            ? Qt.rgba(Qt.color(Colors.accent).r, Qt.color(Colors.accent).g, Qt.color(Colors.accent).b, 0.85)
                            : Colors.accent
                        opacity: passwordField.text.length > 0 ? 1.0 : 0.5

                        Behavior on color { ColorAnimation { duration: 120 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                        Behavior on opacity { NumberAnimation { duration: 120 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                        Text {
                            anchors.centerIn: parent
                            text: "Authenticate"
                            color: Colors.onAccentColor
                            font.pixelSize: Theme.fontSizeMd
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: authArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: passwordField.text.length > 0
                            onClicked: {
                                polkit.submit(passwordField.text)
                                passwordField.text = ""
                            }
                        }
                    }
                }

                // Bottom spacer to pad the layout inside the card
                Item { height: 0 }
            }
        }
    }

}