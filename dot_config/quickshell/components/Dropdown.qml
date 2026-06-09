import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import "../theme"

PopupWindow {
    id: root

    property bool   open:           false
    property Item   anchorItem:     null
    property string preferredSide:  "bottom"
    property real   contentPadding: Theme.spacingMd
    property color  bgColor:        Colors.surfaceContainer
    property real   bgOpacity:      0.92
    property real   dropdownRadius: Theme.radiusMd
    property real   anchorGap:      Theme.spacingXs

    // ── Anchor setup ──────────────────────────────────────────────────────

    anchor.item:             anchorItem
    anchor.edges:            preferredSide === "bottom"
                                 ? Edges.Bottom | Edges.Left
                                 : Edges.Top    | Edges.Left
    anchor.gravity:          preferredSide === "bottom"
                                 ? Edges.Bottom | Edges.Right
                                 : Edges.Top    | Edges.Right
    anchor.adjustment:       PopupAdjustment.Flip | PopupAdjustment.Slide
    anchor.margins.top:      preferredSide === "bottom" ? anchorGap : 0
    anchor.margins.bottom:   preferredSide === "top"    ? anchorGap : 0

    // ── Visibility ────────────────────────────────────────────────────────

    visible:   open && anchorItem !== null
    grabFocus: false

    // ── Size driven by content ────────────────────────────────────────────

    implicitWidth:  card.implicitWidth
    implicitHeight: card.implicitHeight

    // ── Background card ───────────────────────────────────────────────────

    WrapperRectangle {
        id:     card
        margin: root.contentPadding
        radius: root.dropdownRadius
        color: Qt.rgba(
            root.bgColor.r,
            root.bgColor.g,
            root.bgColor.b,
            root.bgOpacity
        )
        border.color: Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.15)
        border.width: 1

        implicitWidth:  child ? child.implicitWidth  + root.contentPadding * 2 : 200
        implicitHeight: child ? child.implicitHeight + root.contentPadding * 2 : 100

        opacity: _anim
        property real _anim: 0

        onVisibleChanged: _anim = visible ? 1 : 0

        Behavior on _anim {
            NumberAnimation {
                duration:    Theme.durationNormal
                easing.type: card._anim === 1 ? Easing.OutQuart : Easing.InQuart
            }
        }

        transform: [
            Translate {
                y: (1 - card._anim) * (root.preferredSide === "bottom" ? -8 : 8)
            },
            Scale {
                xScale:   0.92 + card._anim * 0.08
                yScale:   xScale
                origin.x: card.width / 2
                origin.y: root.preferredSide === "bottom" ? 0 : card.height
            }
        ]

        layer.enabled: true
        layer.effect: MultiEffect {
            source:      card
            blurEnabled: true
            blur:        0.5
            blurMax:     48
        }
    }
}