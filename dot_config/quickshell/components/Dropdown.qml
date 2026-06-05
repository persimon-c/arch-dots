// components/Dropdown.qml
// Base anchored dropdown shell used by bar pills (VolumeDropdown, NetworkDropdown, etc.)
//
// Usage:
//   Dropdown {
//     id: myDropdown
//     anchorItem: somePill       // item to anchor below
//
//     // Your content goes here as the single visual child.
//     // Set implicitWidth/implicitHeight on your content.
//     ColumnLayout { ... }
//   }
//
// The dropdown manages its own open/close state and slide-in animation.
// It renders as a floating WrapperRectangle positioned below (or above, if no room)
// the anchorItem, aligned to its center.
//
// NOTE: This is a component, not a PanelWindow. It should be used inside a
// PanelWindow (the bar). For panels that need their own window, use PopupWindow.
//
// Properties:
//   open          — read/write. Animates in/out.
//   anchorItem    — Item to position below. Required.
//   preferredSide — "bottom" (default) or "top"
//   horizontalAlignment — "center" (default), "left", "right"

import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import "../theme"

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────

    property bool   open:   false
    property Item   anchorItem: null
    property string preferredSide:        "bottom"
    property string horizontalAlignment:  "center"

    // Visual customisation
    property real   dropdownRadius:  Theme.radiusMd
    property real   contentPadding: Theme.spacingMd
    property color  bgColor: Colors.surfaceContainer
    property real   bgOpacity: 0.92

    // Gap between anchorItem and dropdown
    property real anchorGap: Theme.spacingXs

    // ── Visibility ────────────────────────────────────────────────────────

    visible: _anim > 0
    opacity: _anim
    property real _anim: 0

    Behavior on _anim {
        NumberAnimation {
            duration: 200
            easing.type: open ? Easing.OutQuart : Easing.InQuart
        }
    }

    onOpenChanged: _anim = open ? 1 : 0

    // ── Transform — slide + scale from anchor ────────────────────────────

    transform: [
        Translate {
            y: (1 - root._anim) * (root.preferredSide === "bottom" ? -8 : 8)
        },
        Scale {
            xScale: 0.92 + root._anim * 0.08
            yScale: xScale
            origin.x: root.width / 2
            origin.y: root.preferredSide === "bottom" ? 0 : root.height
        }
    ]

    // ── Positioning relative to anchorItem ────────────────────────────────

    // Reposition whenever open or anchorItem geometry changes.
    onOpenChanged:     Qt.callLater(_reposition)
    onWidthChanged:    _reposition()
    onHeightChanged:   _reposition()

    function _reposition() {
        if (!anchorItem) return

        // Map anchorItem's bottom-center to this item's parent coordinate space
        var anchorParent = parent
        var anchorPos = anchorItem.mapToItem(anchorParent, 0, 0)

        // Vertical
        if (preferredSide === "bottom") {
            y = anchorPos.y + anchorItem.height + anchorGap
        } else {
            y = anchorPos.y - height - anchorGap
        }

        // Horizontal alignment
        var anchorCenterX = anchorPos.x + anchorItem.width / 2
        if (horizontalAlignment === "center") {
            x = anchorCenterX - width / 2
        } else if (horizontalAlignment === "left") {
            x = anchorPos.x
        } else {
            x = anchorPos.x + anchorItem.width - width
        }

        // Clamp to parent bounds with a small margin
        var margin = Theme.spacingSm
        x = Math.max(margin, Math.min(anchorParent.width - width - margin, x))
    }

    // ── Background card ───────────────────────────────────────────────────

    WrapperRectangle {
        id: card
        anchors.fill: parent
        margin: root.contentPadding
        radius: root.dropdownRadius
        color:  Qt.rgba(
            root.bgColor.r,
            root.bgColor.g,
            root.bgColor.b,
            root.bgOpacity
        )
        border.color: Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.15)
        border.width: 1

        // Propagate implicit size up so Dropdown knows how big to be
        implicitWidth:  card.child ? card.child.implicitWidth  + root.contentPadding * 2 : 200
        implicitHeight: card.child ? card.child.implicitHeight + root.contentPadding * 2 : 100

        layer.enabled: true
        layer.effect: MultiEffect {
            source: card
            blurEnabled: true
            blur: 0.5
            blurMax: 48
        }
    }

    // ── Implicit size mirrors the card ────────────────────────────────────

    implicitWidth:  card.implicitWidth
    implicitHeight: card.implicitHeight

    // Make the card fill the item
    width:  implicitWidth
    height: implicitHeight

    // ── Click-outside-to-close ────────────────────────────────────────────

    // Consumers should connect their own outside-click logic;
    // this is handled at the PanelWindow level typically.
}
