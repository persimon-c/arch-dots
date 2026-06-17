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

    visible:   (open && anchorItem !== null) || (card._anim > 0.01)
    grabFocus: false

    // ── Size driven by content ────────────────────────────────────────────

    implicitWidth:  card.implicitWidth
    implicitHeight: card.implicitHeight

    // ── Background card ───────────────────────────────────────────────────

    WrapperRectangle {
        id:     card
        margin: root.contentPadding
        radius: root.dropdownRadius
        color: "transparent"
        border.color: "transparent"
        border.width: 0

        AmbientSurface {
            anchors.fill: parent
            radius: card.radius
            borderColor: Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.35)
            borderWidth: 1
        }

        implicitWidth:  child ? child.implicitWidth  + root.contentPadding * 2 : 200
        implicitHeight: child ? child.implicitHeight + root.contentPadding * 2 : 100

        opacity: _anim
        property real _anim: (root.open && root.anchorItem !== null) ? 1 : 0

        Behavior on _anim {
            NumberAnimation { 
                duration: (root.open && root.anchorItem !== null) ? Theme.durationSlow : Theme.durationFast
                easing.type: Theme.easingType
                easing.bezierCurve: (root.open && root.anchorItem !== null) ? Theme.easingCurveIn : Theme.easingCurveOut 
            }
        }

        transform: [
            Translate {
                y: (1 - card._anim) * (root.preferredSide === "bottom" ? -8 : 8)
            },
            Scale {
                xScale:   0.90 + card._anim * 0.10
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