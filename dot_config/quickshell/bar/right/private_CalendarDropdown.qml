import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../components"
import "../../theme"
import "../../services"
import "../../state"

PopupWindow {
    id: root

    property bool open: false
    visible: open || (contentCard._anim > 0.01)
    property Item anchorItem: null
    property var anchorWindow: null

    // Visibility bound to the shared state

    onVisibleChanged: {
        if (!visible) {
            ClockState.calendarVisible = false
        } else {
            // Update today's date state when opening
            var now = new Date()
            root._todayDay   = now.getDate()
            root._todayMonth = now.getMonth()
            root._todayYear  = now.getFullYear()

            root._selectedDay = -1
            root._viewYear  = root._todayYear
            root._viewMonth = root._todayMonth
        }
    }

    // Anchor exactly to the anchorItem to ensure proper window/popup routing and focus
    anchor {
        item: anchorItem
        edges: Edges.Bottom | Edges.Left
        gravity: Edges.Bottom | Edges.Right
        margins.top: 6
        rect.x: {
            if (!anchorWindow || !anchorItem) return 0;
            var _depX = anchorItem.x;
            var _depY = anchorItem.y;
            return anchorWindow.width - 28 - contentCard.implicitWidth - anchorItem.mapToItem(null, 0, 0).x;
        }
        rect.y: {
            if (!anchorWindow || !anchorItem) return 0;
            var _depX = anchorItem.x;
            var _depY = anchorItem.y;
            return anchorWindow.height - anchorItem.mapToItem(null, 0, 0).y;
        }
        rect.width: 0
        rect.height: 0
    }

    grabFocus: false
    color: "transparent"

    // Size driven entirely by the card
    implicitWidth: contentCard.implicitWidth
    implicitHeight: contentCard.implicitHeight

    // ── State ─────────────────────────────────────
    property int _viewYear:  new Date().getFullYear()
    property int _viewMonth: new Date().getMonth()
    property int _selectedDay: -1

    property int _todayDay:   new Date().getDate()
    property int _todayMonth: new Date().getMonth()
    property int _todayYear:  new Date().getFullYear()

    function updateMonth(delta) {
        monthAnim.direction = delta
        monthAnim.restart()
    }

    SequentialAnimation {
        id: monthAnim
        property int direction: 0
        ParallelAnimation {
            NumberAnimation { target: dayGrid; property: "opacity"; to: 0; duration: Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            NumberAnimation { target: gridTrans; property: "x"; to: monthAnim.direction > 0 ? -30 : 30; duration: Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
        }
        ScriptAction {
            script: {
                root._selectedDay = -1
                if (monthAnim.direction > 0) {
                    if (root._viewMonth === 11) { root._viewMonth = 0; root._viewYear++ }
                    else root._viewMonth++
                } else {
                    if (root._viewMonth === 0) { root._viewMonth = 11; root._viewYear-- }
                    else root._viewMonth--
                }
            }
        }
        PropertyAction { target: gridTrans; property: "x"; value: monthAnim.direction > 0 ? 30 : -30 }
        ParallelAnimation {
            NumberAnimation { target: dayGrid; property: "opacity"; to: 1; duration: Theme.durationNormal; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
            NumberAnimation { target: gridTrans; property: "x"; to: 0; duration: Theme.durationNormal; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
        }
    }

    function _monthName(m) {
        return [
            qsTr("January"), qsTr("February"), qsTr("March"), qsTr("April"),
            qsTr("May"), qsTr("June"), qsTr("July"), qsTr("August"),
            qsTr("September"), qsTr("October"), qsTr("November"), qsTr("December")
        ][m]
    }
    function _daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }
    function _firstWeekday(y, m) { return new Date(y, m, 1).getDay() }

    // ── Content Card ──────────────────────────────────────────────────────
    Rectangle {
        id: contentCard
        implicitWidth: 240
        implicitHeight: contentCol.implicitHeight + 24 // 12 margin top & bottom
        radius: 10
        color: "transparent"
        AmbientSurface {
            anchors.fill: parent
            radius: contentCard.radius
            borderColor: PanelColors.pillClock
            borderWidth: 2
        }
        property real _anim: 0.0
        opacity: _anim
        
        transform: [
            Translate {
                y: (1 - contentCard._anim) * -8
            },
            Scale {
                xScale: 0.90 + contentCard._anim * 0.10
                yScale: xScale
                origin.x: contentCard.width / 2
                origin.y: 0
            }
        ]

        NumberAnimation {
            id: animIn
            target: contentCard
            property: "_anim"
            to: 1.0
            duration: Theme.durationSlow
            easing.type: Theme.easingType
            easing.bezierCurve: Theme.easingCurveIn
        }

        NumberAnimation {
            id: animOut
            target: contentCard
            property: "_anim"
            to: 0.0
            duration: Theme.durationFast
            easing.type: Theme.easingType
            easing.bezierCurve: Theme.easingCurveOut
        }

        Connections {
            target: root
            function onOpenChanged() {
                if (root.open) {
                    animOut.stop()
                    animIn.restart()
                } else {
                    animIn.stop()
                    animOut.restart()
                }
            }
        }

        Column {
            id: contentCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 12
            }
            spacing: 6

            // ── Month Nav Row ─────────────────────────────────────────────
            Item {
                width: parent.width
                height: 28

                // Prev Button
                Rectangle {
                    id: prevBtn
                    width: 24
                    height: 24
                    radius: 5
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    color: prevArea.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.15) : PanelColors.rowBackground
                    Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        color: prevArea.containsMouse ? PanelColors.pillClock : PanelColors.textDim
                        Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                    }

                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.updateMonth(-1)
                    }
                }

                // Month + Year
                Text {
                    anchors.centerIn: parent
                    text: root._monthName(root._viewMonth) + " " + root._viewYear
                    font.pixelSize: 13
                    font.bold: true
                    font.family: Theme.fontFamily
                    color: PanelColors.textAccent
                }

                // Next Button
                Rectangle {
                    id: nextBtn
                    width: 24
                    height: 24
                    radius: 5
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    color: nextArea.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.15) : PanelColors.rowBackground
                    Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        color: nextArea.containsMouse ? PanelColors.pillClock : PanelColors.textDim
                        Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                    }

                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.updateMonth(1)
                    }
                }
            }

            // ── Day-of-Week Headers (Sunday-First) ────────────────────────
            Row {
                width: parent.width

                Repeater {
                    model: [qsTr("Su"), qsTr("Mo"), qsTr("Tu"), qsTr("We"), qsTr("Th"), qsTr("Fr"), qsTr("Sa")]
                    delegate: Text {
                        width: contentCol.width / 7
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.pixelSize: 12
                        font.bold: true
                        font.family: Theme.fontFamily
                        color: (index === 0 || index === 6) ? PanelColors.pillClock : PanelColors.textDim
                    }
                }
            }

            // ── Divider ───────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 1
                color: PanelColors.borderSubtle
            }

            // ── Day Grid ──────────────────────────────────────────────────
            Column {
                id: dayGrid
                width: parent.width
                spacing: 2
                transform: Translate { id: gridTrans; x: 0 }

                Repeater {
                    model: Math.ceil((_firstWeekday(root._viewYear, root._viewMonth)
                            + _daysInMonth(root._viewYear, root._viewMonth)) / 7)

                    delegate: Rectangle {
                        id: weekRow
                        required property int index
                        readonly property int weekIndex: index

                        readonly property bool isCurrentWeek: {
                            var todayTotal = root._todayDay + _firstWeekday(root._todayYear, root._todayMonth) - 1
                            return root._viewMonth === root._todayMonth
                                && root._viewYear  === root._todayYear
                                && Math.floor(todayTotal / 7) === weekRow.weekIndex
                        }

                        width: parent.width
                        height: 28
                        radius: 6
                        color: isCurrentWeek ? PanelColors.rowBackground : "transparent"

                        // Left strip — only on current week
                        Rectangle {
                            visible: weekRow.isCurrentWeek
                            width: 3
                            height: parent.height - 10
                            radius: 2
                            anchors { left: parent.left; leftMargin: 0; verticalCenter: parent.verticalCenter }
                            color: PanelColors.pillClock
                        }

                        Row {
                            anchors.fill: parent

                            Repeater {
                                model: 7
                                delegate: Item {
                                    id: dayCell
                                    required property int index
                                    readonly property int cellIndex: weekRow.weekIndex * 7 + index
                                    readonly property int dayNum:    cellIndex - _firstWeekday(root._viewYear, root._viewMonth) + 1
                                    readonly property bool isEmpty:  dayNum < 1 || dayNum > _daysInMonth(root._viewYear, root._viewMonth)
                                    readonly property bool isToday:  !isEmpty
                                                                    && dayNum === root._todayDay
                                                                    && root._viewMonth === root._todayMonth
                                                                    && root._viewYear  === root._todayYear
                                    readonly property bool isSelected: !isEmpty && dayNum === root._selectedDay

                                    width:  contentCol.width / 7
                                    height: parent.height

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 24
                                        height: 24
                                        radius: 6
                                        color: {
                                            if (isEmpty) return "transparent"
                                            let base = isToday ? PanelColors.pillClock : (isSelected ? PanelColors.border : "transparent")
                                            if (dayArea.containsMouse) {
                                                let hoverRef = isToday ? PanelColors.pillClock : (isSelected ? PanelColors.border : PanelColors.rowBackground)
                                                return Qt.lighter(hoverRef, 1.15)
                                            }
                                            return base
                                        }

                                        Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: isEmpty ? "" : dayNum
                                            font.pixelSize: 13
                                            font.bold: isToday || isSelected
                                            font.family: Theme.fontFamily
                                            color: isToday ? PanelColors.pillTextClock : (isSelected ? PanelColors.textAccent : PanelColors.textAccent)
                                            Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                                        }
                                    }

                                    MouseArea {
                                        id: dayArea
                                        anchors.fill: parent
                                        hoverEnabled: !isEmpty
                                        cursorShape: !isEmpty ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if (!isEmpty) root._selectedDay = dayNum
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
