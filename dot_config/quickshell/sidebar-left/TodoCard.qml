import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"
import "../components"
import "../services"

AccentCard {
    id: root
    accent: Colors.tertiary
    label: "tasks"
    Layout.fillWidth: true
    implicitHeight: 280

    headerExtra: Text {
        text: DateTime.dateShort
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeXs
        color: PanelColors.textDim
        anchors.verticalCenter: parent.verticalCenter
    }

    property var tasks: []

    Process {
        id: todoProc
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = this.text.trim()
                if (!raw) return
                try {
                    root.tasks = JSON.parse(raw)
                } catch (e) {
                    console.warn("[Todo] parse error:", e)
                }
            }
        }
    }

    function runTodo(args) {
        var cmd = ["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/todo-helper.sh"]
        for (var i = 0; i < args.length; i++) {
            cmd.push(args[i])
        }
        if (todoProc.running) {
            todoProc.running = false
        }
        todoProc.command = cmd
        todoProc.running = true
    }

    Component.onCompleted: {
        runTodo(["list"])
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 10

        // ── Input field to add tasks ──────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 32
            radius: 6
            color: PanelColors.rowBackground
            border.width: 1
            border.color: addInput.activeFocus ? Colors.tertiary : "transparent"

            Text {
                id: placeholderText
                text: "Add a task..."
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSm
                color: PanelColors.textDim
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                visible: !addInput.text && !addInput.activeFocus
            }

            TextInput {
                id: addInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                verticalAlignment: TextInput.AlignVCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSm
                color: PanelColors.textAccent
                selectByMouse: true

                Keys.onReturnPressed: {
                    var txt = text.trim()
                    if (txt) {
                        root.runTodo(["add", txt])
                        text = ""
                    }
                }
            }
        }

        // ── Empty State ───────────────────────────────────────────────────────
        Text {
            visible: root.tasks.length === 0
            text: "No pending tasks."
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: PanelColors.textDim
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
        }

        // ── Tasks Checklist Scrollable List ───────────────────────────────────
        ListView {
            id: taskListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.tasks
            visible: root.tasks.length > 0

            ScrollBar.vertical: ScrollBar {
                id: scrollBar
                policy: ScrollBar.AsNeeded
                width: 4
                anchors.right: parent.right
                anchors.rightMargin: -12

                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    color: root.accent
                    opacity: scrollBar.active ? 0.8 : 0.4
                    Behavior on opacity { NumberAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                }
            }

            delegate: Rectangle {
                id: taskRow
                required property var modelData
                required property int index

                width: taskListView.width
                height: 32
                radius: 6
                color: PanelColors.rowBackground
                opacity: modelData.done ? 0.6 : 1.0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    // Checkbox status toggle
                    Text {
                        text: modelData.done ? "󰄲" : "󰄱"
                        font.family: Theme.fontFamily
                        font.pixelSize: 16
                        color: modelData.done ? Colors.tertiary : PanelColors.textDim
                        Layout.alignment: Qt.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.runTodo(["toggle", modelData.id])
                        }
                    }

                    // Task item text
                    Text {
                        text: modelData.text || ""
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSm
                        font.strikeout: modelData.done
                        color: modelData.done ? PanelColors.textDim : PanelColors.textAccent
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Delete button
                    Text {
                        text: "󰅖"
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        color: deleteMouse.containsMouse ? PanelColors.error : PanelColors.textDim
                        Layout.alignment: Qt.AlignVCenter

                        MouseArea {
                            id: deleteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.runTodo(["delete", modelData.id])
                        }
                    }
                }
            }
        }
    }
}
