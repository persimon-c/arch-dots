import QtQuick
import "../theme"

Rectangle {
    id: root

    property color accent: PanelColors.profile
    property string label: ""
    property alias header: cardHeader
    property alias headerExtra: headerExtraSlot.data
    default property alias content: inner.data

    radius: 10
    color: "transparent"
    border.color: "transparent"
    border.width: 0

    AmbientSurface {
        anchors.fill: parent
        radius: root.radius
        borderColor: root.accent
        borderWidth: 1.5
    }

    // Left accent stripe
    Rectangle {
        width: 4
        height: parent.height - 24
        radius: 2
        anchors {
            left: parent.left
            leftMargin: 7
            verticalCenter: parent.verticalCenter
        }
        color: root.accent
        opacity: 0.85
    }

    // Header: label + divider
    Column {
        id: cardHeader
        anchors {
            top: parent.top
            topMargin: 12
            left: parent.left
            leftMargin: 20
            right: parent.right
            rightMargin: 16
        }
        spacing: 6

        Row {
            width: parent.width
            Text {
                text: root.label
                font.pixelSize: Theme.fontSizeSm
                font.bold: true
                font.family: Theme.fontFamily
                color: root.accent
                width: parent.width - headerExtraSlot.implicitWidth
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
            Item {
                id: headerExtraSlot
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Rectangle {
            width: parent.width
            height: 1
            color: PanelColors.rowBackground
            opacity: 0.4
            Behavior on color { ColorAnimation { duration: 250 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        }
        Item {
            width: 1
            height: 6
        }
    }

    // Content slot
    Item {
        id: inner
        anchors {
            top: cardHeader.bottom
            bottom: parent.bottom
            bottomMargin: 12
            left: parent.left
            leftMargin: 20
            right: parent.right
            rightMargin: 16
        }
    }
}
