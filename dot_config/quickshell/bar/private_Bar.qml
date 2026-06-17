import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import "../theme"
import "left"
import "right"

PanelWindow {
    id: barWindow

    // Full-width, fixed height bar anchored to top edge
    anchors {
        top:   true
        left:  true
        right: true
    }

    implicitHeight:  52
    color:           "transparent"
    WlrLayershell.layer:        WlrLayer.Top
    WlrLayershell.exclusiveZone: 47

    // ── Left Container ────────────────────────────────────────────────────────
    WrapperRectangle {
        id: leftContainer
        color: Qt.rgba(
            Qt.color(PanelColors.barBackground).r,
            Qt.color(PanelColors.barBackground).g,
            Qt.color(PanelColors.barBackground).b,
            Theme.opacityBar
        )
        radius: 9
        border.color: Qt.rgba(
            Qt.color(PanelColors.border).r,
            Qt.color(PanelColors.border).g,
            Qt.color(PanelColors.border).b,
            0.15
        )
        border.width: 1

        leftMargin:   6
        rightMargin:  6
        topMargin:    6
        bottomMargin: 6

        anchors {
            left:           parent.left
            leftMargin:     Theme.spacingMd
            top:            parent.top
            topMargin:      10
        }

        Row {
            id: leftRow
            spacing: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter

            LauncherPill {}
            TrayPill {}
            WorkspacePill {}
        }
    }

    // ── Apps Container (Floating to the right of Left Container) ──────────────
    WrapperRectangle {
        id: appsContainer
        color: Qt.rgba(
            Qt.color(PanelColors.barBackground).r,
            Qt.color(PanelColors.barBackground).g,
            Qt.color(PanelColors.barBackground).b,
            Theme.opacityBar
        )
        radius: 9
        border.color: Qt.rgba(
            Qt.color(PanelColors.border).r,
            Qt.color(PanelColors.border).g,
            Qt.color(PanelColors.border).b,
            0.15
        )
        border.width: 1

        leftMargin:   6
        rightMargin:  6
        topMargin:    6
        bottomMargin: 6

        visible: Hyprland.focusedWorkspaceToplevels && Hyprland.focusedWorkspaceToplevels.length > 0

        anchors {
            left:           leftContainer.right
            leftMargin:     Theme.spacingMd
            top:            parent.top
            topMargin:      10
        }

        Row {
            id: appsRow
            spacing: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter

            AppIconsPill {}
        }
    }

    // ── Center Container ──────────────────────────────────────────────────────
    WrapperRectangle {
        id: centerContainer
        color: Qt.rgba(
            Qt.color(PanelColors.barBackground).r,
            Qt.color(PanelColors.barBackground).g,
            Qt.color(PanelColors.barBackground).b,
            Theme.opacityBar
        )
        radius: 9
        border.color: Qt.rgba(
            Qt.color(PanelColors.border).r,
            Qt.color(PanelColors.border).g,
            Qt.color(PanelColors.border).b,
            0.15
        )
        border.width: 1

        leftMargin:   6
        rightMargin:  6
        topMargin:    6
        bottomMargin: 6

        anchors {
            horizontalCenter: parent.horizontalCenter
            top:              parent.top
            topMargin:        10
        }

        Row {
            id: centerRow
            spacing: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter

            CavaClockPill {}
        }
    }

    // ── Right Container ───────────────────────────────────────────────────────
    WrapperRectangle {
        id: rightContainer
        color: Qt.rgba(
            Qt.color(PanelColors.barBackground).r,
            Qt.color(PanelColors.barBackground).g,
            Qt.color(PanelColors.barBackground).b,
            Theme.opacityBar
        )
        radius: 9
        border.color: Qt.rgba(
            Qt.color(PanelColors.border).r,
            Qt.color(PanelColors.border).g,
            Qt.color(PanelColors.border).b,
            0.15
        )
        border.width: 1

        leftMargin:   6
        rightMargin:  6
        topMargin:    6
        bottomMargin: 6

        anchors {
            right:          parent.right
            rightMargin:    Theme.spacingMd
            top:            parent.top
            topMargin:      10
        }

        Row {
            id: rightRow
            spacing: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter

            BatteryPill      {}
            NetworkPill      {}
            BluetoothPill    {}
            VolumePill       {}
            NotificationPill {}
            ClockPill {
                anchorWindow: barWindow
            } // This displays the date e.g. "May 16"
            PowerPill        {}
        }
    }

    // ── Network Speed Container ───────────────────────────────────────────────
    WrapperRectangle {
        id: networkSpeedContainer
        color: Qt.rgba(
            Qt.color(PanelColors.barBackground).r,
            Qt.color(PanelColors.barBackground).g,
            Qt.color(PanelColors.barBackground).b,
            Theme.opacityBar
        )
        radius: 9
        border.color: Qt.rgba(
            Qt.color(PanelColors.border).r,
            Qt.color(PanelColors.border).g,
            Qt.color(PanelColors.border).b,
            0.15
        )
        border.width: 1

        leftMargin:   6
        rightMargin:  6
        topMargin:    6
        bottomMargin: 6

        anchors {
            right:          rightContainer.left
            rightMargin:    Theme.spacingMd
            top:            parent.top
            topMargin:      10
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            NetSpeedPill {}
        }
    }

    // ── RAM Usage Container ──────────────────────────────────────────────────
    WrapperRectangle {
        id: ramUsageContainer
        color: Qt.rgba(
            Qt.color(PanelColors.barBackground).r,
            Qt.color(PanelColors.barBackground).g,
            Qt.color(PanelColors.barBackground).b,
            Theme.opacityBar
        )
        radius: 9
        border.color: Qt.rgba(
            Qt.color(PanelColors.border).r,
            Qt.color(PanelColors.border).g,
            Qt.color(PanelColors.border).b,
            0.15
        )
        border.width: 1

        leftMargin:   6
        rightMargin:  6
        topMargin:    6
        bottomMargin: 6

        anchors {
            right:          networkSpeedContainer.left
            rightMargin:    Theme.spacingMd
            top:            parent.top
            topMargin:      10
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            RamPill {}
        }
    }
}
