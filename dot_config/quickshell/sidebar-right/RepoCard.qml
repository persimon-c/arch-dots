import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"
import "../components"

AccentCard {
    id: root
    accent: PanelColors.profile
    label: "recent repositories"
    Layout.fillWidth: true
    Layout.fillHeight: true

    ListView {
        id: repoList
        anchors.fill: parent
        spacing: 8
        model: Github.repos
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Text {
            visible: Github.repos.length === 0 && !Github.reposLoading
            anchors.centerIn: parent
            text: "No local repositories found."
            font.pixelSize: Theme.fontSizeSm
            font.family: Theme.fontFamily
            color: PanelColors.textDim
        }

        delegate: Rectangle {
            id: repoItem
            required property var modelData
            required property int index

            width: repoList.width
            height: contentCol.implicitHeight + 16
            radius: Theme.radiusSm
            color: PanelColors.rowBackground

            // Left accent border strip if dirty
            Rectangle {
                width: 3
                height: parent.height - 10
                radius: 1.5
                anchors {
                    left: parent.left
                    leftMargin: 4
                    verticalCenter: parent.verticalCenter
                }
                color: modelData.dirty ? PanelColors.warning : PanelColors.profile
            }

            Column {
                id: contentCol
                anchors {
                    top: parent.top; topMargin: 8
                    left: parent.left; leftMargin: 14
                    right: parent.right; rightMargin: 12
                }
                spacing: 4

                // Top row: name, dirty status, branch, relative time
                RowLayout {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: modelData.name || ""
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSm
                        font.weight: Theme.fontWeightBold
                        color: PanelColors.textAccent
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Dirty tag
                    Rectangle {
                        visible: modelData.dirty
                        color: Qt.rgba(235/255, 160/255, 50/255, 0.15)
                        radius: 4
                        border.color: PanelColors.warning
                        border.width: 1
                        width: dirtyText.implicitWidth + 8
                        height: 18

                        Text {
                            id: dirtyText
                            anchors.centerIn: parent
                            text: "dirty"
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            font.weight: Theme.fontWeightBold
                            color: PanelColors.warning
                        }
                    }

                    // Time
                    Text {
                        text: modelData.last_commit_rel || ""
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeXs
                        color: PanelColors.textDim
                        Layout.alignment: Qt.AlignRight
                    }
                }

                // Metadata row: Language, commits, sync status, dirty files, branches, tags, size
                RowLayout {
                    width: parent.width
                    spacing: 12

                    // Primary Language
                    Row {
                        spacing: 4
                        visible: !!modelData.primary_lang
                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: PanelColors.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData.primary_lang || ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            font.weight: Theme.fontWeightBold
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Commits count
                    Row {
                        spacing: 4
                        Text {
                            text: "󰜘"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData.commits_count !== undefined ? modelData.commits_count : "0"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Ahead/Behind Sync Status
                    Row {
                        spacing: 4
                        visible: (modelData.ahead_count > 0) || (modelData.behind_count > 0)
                        Text {
                            text: "󰛄"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: (modelData.ahead_count > 0 ? "⇡" + modelData.ahead_count : "") +
                                  (modelData.ahead_count > 0 && modelData.behind_count > 0 ? " " : "") +
                                  (modelData.behind_count > 0 ? "⇣" + modelData.behind_count : "")
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Detailed dirty file status
                    Row {
                        spacing: 4
                        visible: (modelData.staged_count > 0) || (modelData.modified_count > 0) || (modelData.untracked_count > 0)
                        Text {
                            text: "󰓗"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: PanelColors.warning
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: (modelData.staged_count > 0 ? "+" + modelData.staged_count : "") +
                                  (modelData.staged_count > 0 && (modelData.modified_count > 0 || modelData.untracked_count > 0) ? " " : "") +
                                  (modelData.modified_count > 0 ? "~" + modelData.modified_count : "") +
                                  ((modelData.staged_count > 0 || modelData.modified_count > 0) && modelData.untracked_count > 0 ? " " : "") +
                                  (modelData.untracked_count > 0 ? "?" + modelData.untracked_count : "")
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            font.weight: Theme.fontWeightBold
                            color: PanelColors.warning
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Branch & active branches count
                    Row {
                        spacing: 4
                        Text {
                            text: ""
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: (modelData.branch || "main") + (modelData.branches_count > 1 ? " (" + modelData.branches_count + ")" : "")
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Tags count
                    Row {
                        spacing: 4
                        visible: modelData.tags_count > 0
                        Text {
                            text: ""
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData.tags_count || "0"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Folder size
                    Row {
                        spacing: 4
                        Text {
                            text: "󰋊"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData.size || "0B"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            color: PanelColors.textDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Spacer
                    Item {
                        Layout.fillWidth: true
                    }
                }

                // Second row: last commit msg
                Text {
                    text: modelData.last_commit_msg || "No commit message"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXs
                    color: PanelColors.textDim
                    width: parent.width
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }
        }
    }
}
