import QtQuick
import QtQuick.Effects
import Quickshell
import "../theme"
import "../services"

Item {
    id: root

    property real radius: 10
    property color borderColor: "transparent"
    property real borderWidth: 0

    // Smooth transition for color/border changes
    Behavior on borderColor {
        ColorAnimation { duration: Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
    }

    // 1. The Mask Source defining the rounded shape (always invisible)
    Item {
        id: maskContainer
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            radius: root.radius
            color: "black"
            antialiasing: true
        }
    }

    // 2. The Content Layout containing all styling layers
    Item {
        id: contentContainer
        anchors.fill: parent
        visible: false

        // Layer A: Base color — fully opaque, no desktop bleed-through
        Rectangle {
            anchors.fill: parent
            color: Qt.color(PanelColors.popupBackground)
            opacity: 1.0
        }

        // Layer B: Blurred wallpaper underlay — very subtle ambient wash
        Image {
            id: bgWallpaper
            anchors.fill: parent
            source: Wallpaper.currentWallpaper ? "file://" + Wallpaper.currentWallpaper : ""
            fillMode: Image.PreserveAspectCrop
            opacity: 0.07
            smooth: true
            visible: source !== ""

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.4
                blurMax: 32
            }
        }

        // Layer C: Soft ambient tint from quantized colors
        ColorQuantizer {
            id: quantizer
            source: bgWallpaper.source
            depth: 2
            rescaleSize: 64
        }

        Rectangle {
            anchors.fill: parent
            color: (quantizer.colors && quantizer.colors.length > 0) ? quantizer.colors[0] : Qt.color(PanelColors.accent)
            opacity: 0.04
        }

        // Layer D: Tileable noise texture — barely visible grain
        Image {
            anchors.fill: parent
            source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/theme/noise.png"
            fillMode: Image.Tile
            opacity: 0.025
        }
    }

    // 3. MultiEffect performing rounded corner masking on the layered content
    MultiEffect {
        anchors.fill: parent
        source: contentContainer
        maskEnabled: true
        maskSource: maskContainer
    }

    // 4. Border drawn on top of the clipped layers
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.color: root.borderColor
        border.width: root.borderWidth
        antialiasing: true
    }
}
