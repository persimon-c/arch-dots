import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"
import "../components"

AccentCard {
    id: root
    accent: PanelColors.accent
    label: "github activity"
    implicitHeight: 180

    property string hoverInfo: "Hover a cell to see details"
    property color accentColor: PanelColors.accent

    // 0-4 mapping using PanelColors.accent opacity steps
    readonly property var levelColors: [
        PanelColors.rowBackground,
        Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.25),
        Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.50),
        Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.75),
        accentColor
    ]

    headerExtra: Row {
        spacing: 12
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: Github.username ? "󰊤 " + Github.username : ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            font.weight: Theme.fontWeightBold
            color: PanelColors.textAccent
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Github.totalContributions + " contributions"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: PanelColors.textDim
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Main grid and weekday labels
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Weekday Labels
            Column {
                spacing: 3
                Layout.alignment: Qt.AlignVCenter

                // Offset spacer to align with grid rows
                Item { width: 20; height: 10 }

                Text {
                    text: "Mon"
                    color: PanelColors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    height: 10
                }

                Item { width: 20; height: 10 }

                Text {
                    text: "Wed"
                    color: PanelColors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    height: 10
                }

                Item { width: 20; height: 10 }

                Text {
                    text: "Fri"
                    color: PanelColors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    height: 10
                }

                Item { width: 20; height: 10 }
            }

            // The Graph Grid
            Grid {
                id: graphGrid
                rows: 7
                flow: Grid.TopToBottom
                spacing: 3

                Repeater {
                    model: Github.days.length

                    delegate: Rectangle {
                        readonly property var dayData: Github.days[index]
                        readonly property int level: dayData ? dayData.level : 0
                        readonly property string dateStr: dayData ? dayData.date : ""
                        readonly property int countVal: dayData ? dayData.count : 0

                        width: 10
                        height: 10
                        radius: 2
                        color: root.levelColors[level]
                        border.width: 1
                        border.color: "transparent"

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.border.color = PanelColors.textAccent
                                root.hoverInfo = parent.countVal + " contributions on " + parent.dateStr
                            }
                            onExited: {
                                parent.border.color = "transparent"
                                root.hoverInfo = "Hover a cell to see details"
                            }
                        }
                    }
                }
            }
        }

        // Legend and Hover info
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 2

            Text {
                text: root.hoverInfo
                color: PanelColors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                Layout.fillWidth: true
            }

            Row {
                spacing: 3
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "Less"
                    color: PanelColors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    rightPadding: 4
                }

                Repeater {
                    model: 5
                    delegate: Rectangle {
                        width: 10
                        height: 10
                        radius: 2
                        color: root.levelColors[index]
                    }
                }

                Text {
                    text: "More"
                    color: PanelColors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    leftPadding: 4
                }
            }
        }
    }
}
