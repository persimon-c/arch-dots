// clipboard/ClipboardPanel.qml
// Fullscreen clipboard history overlay — Phase QS12.
//
// Architecture:
//   • ONE PanelWindow (WlrLayer.Overlay, fullscreen, exclusive keyboard)
//   • Visibility driven by SessionState.clipboardVisible
//   • IpcHandler target: "clipboard", function toggle()
//     → keybind: quickshell ipc call clipboard toggle
//   • Data from Clipboard singleton — service internals untouched
//   • isImage detection: preview.startsWith("[[ binary data") — in QML only
//   • Image decode: cliphist decode → /tmp/qs-clip-<id>.png → QtQuick Image
//     (queued serially so multiple visible images don't race)
//   • Filter: pure JS over Clipboard.entries, stored in filteredEntries
//   • Colors: PanelColors tokens only — no hardcoded palette values
//   • No qmldir — feature-folder rule

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"
import "../services"
import "../state"
import "../components"

PanelWindow {
    id: root

    // ── IPC trigger ───────────────────────────────────────────────────────
    // Hyprland keybind (SUPER+SHIFT+V) calls:
    //   quickshell ipc call clipboard toggle
    IpcHandler {
        target: "clipboard"

        function toggle(): void {
            if (SessionState.clipboardVisible) {
                SessionState.clipboardVisible = false
            } else {
                SessionState.closeAllPopups()
                SessionState.clipboardVisible = true
            }
        }
    }

    // ── Window setup ──────────────────────────────────────────────────────
    anchors { top: true; bottom: true; left: true; right: true }
    margins { top: 0; bottom: 0; left: 0; right: 0 }

    visible: SessionState.clipboardVisible || (_card.opacity > 0.01)
    color:   "transparent"

    WlrLayershell.namespace:     "clipboard"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    // ── Filtered entry list (JS array rebuilt on query or model change) ───
    property var filteredEntries: []
    property string searchQuery:  ""
    property bool   isDeleting:   false

    function applyFilter() {
        var q = searchQuery.toLowerCase()
        var result = []
        for (var i = 0; i < Clipboard.entries.count; i++) {
            var e   = Clipboard.entries.get(i)
            var img = e.preview.startsWith("[[ binary data")
            // Images are always shown (no text to match); text entries are filtered by query
            if (q === "" || img || e.preview.toLowerCase().includes(q)) {
                result.push({
                    id:      e.id,
                    preview: e.preview,
                    isImage: img,
                    rawLine: e.id + "\t" + e.preview
                })
            }
        }
        root.filteredEntries = result
        // Clamp selection into range
        if (_list.currentIndex >= result.length)
            _list.currentIndex = Math.max(0, result.length - 1)
    }

    // Re-filter when the underlying model's count changes (append / clear)
    Connections {
        target: Clipboard.entries
        function onCountChanged() { root.applyFilter() }
    }

    // Re-filter when isLoading flips to false (full reload completed)
    Connections {
        target: Clipboard
        function onIsLoadingChanged() {
            if (!Clipboard.isLoading) root.applyFilter()
        }
    }

    // ── Image decode queue ────────────────────────────────────────────────
    // Images are decoded serially to /tmp/qs-clip-<id>.png via cliphist.
    // Delegates watch `decodingId` and `decodeReady` to know when their
    // specific image is ready and reload the Image source from the temp file.

    property var    decodeQueue: []
    property string decodingId:  ""
    property bool   decodeReady: false

    function enqueueImage(itemId, rawLine) {
        for (var i = 0; i < decodeQueue.length; i++)
            if (decodeQueue[i].itemId === itemId) return
        decodeQueue.push({ itemId: itemId, rawLine: rawLine })
        if (!_imgDecodeProc.running && decodingId === "")
            _processNextImage()
    }

    function _processNextImage() {
        if (decodeQueue.length === 0) { decodingId = ""; return }
        var job    = decodeQueue.shift()
        decodingId  = job.itemId
        decodeReady = false
        var esc     = job.rawLine.replace(/'/g, "'\\''")
        _imgDecodeProc.command = [
            "bash", "-c",
            "printf '%s\\n' '" + esc + "' | cliphist decode > '/tmp/qs-clip-" + job.itemId + ".png'"
        ]
        _imgDecodeProc.running = false
        _imgDecodeProc.running = true
    }

    Process {
        id:      _imgDecodeProc
        running: false
        command: ["true"]
        onRunningChanged: {
            if (!running) {
                root.decodeReady = true
                root._processNextImage()
            }
        }
    }

    // ── Navigation helpers ────────────────────────────────────────────────

    function _move(delta) {
        if (root.filteredEntries.length === 0) return
        var next = Math.max(0, Math.min(
            (_list.currentIndex < 0 ? 0 : _list.currentIndex) + delta,
            root.filteredEntries.length - 1))
        _list.currentIndex = next
        _list.positionViewAtIndex(next, ListView.Contain)
    }

    function _confirm() {
        var idx = _list.currentIndex
        if (idx >= 0 && idx < root.filteredEntries.length) {
            Clipboard.pasteEntry(root.filteredEntries[idx].rawLine)
            SessionState.clipboardVisible = false
        }
    }

    function _deleteSelected() {
        if (root.filteredEntries.length > 0 && _list.currentIndex >= 0 && _list.currentItem)
            _list.currentItem.doDelete()
    }

    // ── Open / close lifecycle ────────────────────────────────────────────

    Connections {
        target: SessionState
        function onClipboardVisibleChanged() {
            if (!SessionState.clipboardVisible) {
                // Reset on close
                _searchInput.text  = ""
                root.searchQuery   = ""
                _list.currentIndex = -1
                root.decodeQueue   = []
                _confirmClear.opacity = 0
                return
            }
            // On open: reload + focus search
            Clipboard.reload()
            Qt.callLater(() => {
                _searchInput.forceActiveFocus()
                root.searchQuery = ""
                root.applyFilter()
                if (root.filteredEntries.length > 0)
                    _list.currentIndex = 0
            })
        }
    }

    // ── Dim backdrop ──────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        "#000000"
        opacity:      SessionState.clipboardVisible ? 0.55 : 0.0
        Behavior on opacity { NumberAnimation { duration: SessionState.clipboardVisible ? Theme.durationSlow : Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: SessionState.clipboardVisible ? Theme.easingCurveIn : Theme.easingCurveOut } }

        MouseArea {
            anchors.fill: parent
            onClicked:    SessionState.clipboardVisible = false
        }
    }

    // ── Card ──────────────────────────────────────────────────────────────
    Rectangle {
        id: _card
        anchors.centerIn: parent
        width:  Math.min(parent.width  - 80, 700)
        height: Math.min(parent.height - 80, 580)

        color:        "transparent"
        border.color: PanelColors.border
        border.width: 2
        radius:       Theme.radiusLg

        AmbientSurface {
            anchors.fill: parent
            radius: _card.radius
        }

        // Entry / exit animation
        opacity: SessionState.clipboardVisible ? 1.0 : 0.0
        scale:   SessionState.clipboardVisible ? 1.0 : 0.94
        Behavior on opacity { NumberAnimation { duration: SessionState.clipboardVisible ? Theme.durationSlow : Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: SessionState.clipboardVisible ? Theme.easingCurveIn : Theme.easingCurveOut } }
        Behavior on scale   { NumberAnimation { duration: SessionState.clipboardVisible ? Theme.durationSlow : Theme.durationFast; easing.type: Theme.easingType; easing.bezierCurve: SessionState.clipboardVisible ? Theme.easingCurveIn : Theme.easingCurveOut } }

        // Escape key fallback on the card itself
        focus:              root.visible
        Keys.onEscapePressed: SessionState.clipboardVisible = false

        // ── Header ────────────────────────────────────────────────────────
        Item {
            id: _header
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            height: 46

            // Icon + label
            Row {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                spacing: 7

                Text {
                    text:           "󰅌"
                    font.family:    Theme.fontFamily
                    font.pixelSize: 18
                    color:          PanelColors.accent
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text:           "Clipboard"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    font.weight:    Theme.fontWeightBold
                    color:          PanelColors.textPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Search field
            Rectangle {
                id: _searchBox
                anchors {
                    left:  parent.left;   leftMargin:  114
                    right: _clearBtn.left; rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                height: 32
                radius: Theme.radiusSm
                color:  PanelColors.rowBackground
                border.color: _searchInput.activeFocus
                                  ? PanelColors.accent
                                  : PanelColors.borderSubtle
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                Text {
                    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                    text:           "Search clipboard…"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color:          PanelColors.textMuted
                    visible:        _searchInput.text.length === 0
                }

                TextInput {
                    id: _searchInput
                    anchors {
                        left:  parent.left;  leftMargin:  10
                        right: parent.right; rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color:          PanelColors.textPrimary
                    selectByMouse:  true
                    clip:           true

                    onTextChanged: {
                        root.searchQuery = text
                        root.applyFilter()
                    }

                    Keys.onEscapePressed:   SessionState.clipboardVisible = false
                    Keys.onUpPressed:       root._move(-1)
                    Keys.onDownPressed:     root._move(+1)
                    Keys.onReturnPressed:   root._confirm()
                    Keys.onDeletePressed:   root._deleteSelected()
                }
            }

            // Clear-all button
            Rectangle {
                id: _clearBtn
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                width:  32
                height: 32
                radius: Theme.radiusSm
                color:  _clearMouse.containsMouse
                            ? PanelColors.error
                            : PanelColors.rowBackground
                Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                Text {
                    anchors.centerIn: parent
                    text:           "󰺝"
                    font.family:    Theme.fontFamily
                    font.pixelSize: 14
                    color:          _clearMouse.containsMouse
                                        ? PanelColors.onError
                                        : PanelColors.textMuted
                    Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                }

                MouseArea {
                    id:           _clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        if (root.filteredEntries.length > 0)
                            _confirmClear.opacity = 1
                    }
                }
            }
        }

        // Header / list divider
        Rectangle {
            id: _divider
            anchors {
                top:    _header.bottom
                left:   parent.left;  leftMargin:  16
                right:  parent.right; rightMargin: 16
            }
            height: 1
            color:  PanelColors.borderSubtle
        }

        // ── Entry list ────────────────────────────────────────────────────
        ListView {
            id: _list
            anchors {
                top:    _divider.bottom; topMargin:    8
                bottom: parent.bottom;   bottomMargin: 8
                left:   parent.left;     leftMargin:   8
                right:  parent.right;    rightMargin:  8
            }
            clip:    true
            spacing: 2

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            model: root.filteredEntries

            readonly property int imageRowH: 160

            delegate: Item {
                id: _delegate
                required property var modelData
                required property int index

                readonly property bool isImg:      modelData.isImage
                readonly property bool isSelected: index === _list.currentIndex
                readonly property string tmpPath:  "/tmp/qs-clip-" + modelData.id + ".png"

                // Local deletion state — triggers slide+shrink animation
                property bool isDeletingItem: false
                onModelDataChanged: isDeletingItem = false

                width:  _list.width
                height: isDeletingItem
                            ? 0
                            : (isImg ? _list.imageRowH : _rowText.implicitHeight + 20)
                clip:   true
                Behavior on height {
                    NumberAnimation { duration: 220; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
                }

                // Delay the actual delete call until the slide animation starts
                Timer {
                    id: _itemDeleteTimer
                    interval: 220
                    onTriggered: Clipboard.deleteEntry(modelData.rawLine)
                }

                function doDelete() {
                    root.isDeleting = true
                    isDeletingItem  = true
                    _itemDeleteTimer.start()
                }

                // Enqueue image decode when this delegate is created
                Component.onCompleted: {
                    if (isImg) root.enqueueImage(modelData.id, modelData.rawLine)
                }

                // Slide-left + fade wrapper (contents don't squash)
                Item {
                    id: _contentItem
                    width:  parent.width
                    height: isImg ? _list.imageRowH : _rowText.implicitHeight + 20

                    x:       _delegate.isDeletingItem ? -width : 0
                    opacity: _delegate.isDeletingItem ? 0      : 1
                    Behavior on x       { NumberAnimation { duration: 220; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                    // ── Row background ─────────────────────────────────────
                    Rectangle {
                        id: _rowRect
                        anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
                        radius: Theme.radiusSm
                        color:  isSelected
                                    ? Qt.rgba(1, 1, 1, 0.10)
                                    : _rowHover.containsMouse
                                        ? Qt.rgba(1, 1, 1, 0.06)
                                        : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                        // Left accent bar — only when selected
                        Rectangle {
                            width:  3
                            height: parent.height - 12
                            radius: 2
                            anchors {
                                left:          parent.left; leftMargin: 4
                                verticalCenter: parent.verticalCenter
                            }
                            color:   PanelColors.accent
                            visible: isSelected
                        }

                        // ── Image entry ────────────────────────────────────
                        Item {
                            visible: isImg
                            anchors {
                                top:    parent.top;    topMargin:    8
                                bottom: parent.bottom; bottomMargin: 8
                                left:   parent.left;   leftMargin:   14
                                right:  parent.right;  rightMargin:  12
                            }

                            // Placeholder rectangle while image is decoding
                            Rectangle {
                                anchors.fill: parent
                                color:        PanelColors.rowBackground
                                radius:       Theme.radiusSm
                                visible:      _clipImg.status !== Image.Ready
                            }

                            Image {
                                id:           _clipImg
                                anchors {
                                    left:   parent.left
                                    top:    parent.top
                                    bottom: parent.bottom
                                }
                                width: status === Image.Ready
                                           ? Math.min(implicitWidth, parent.width)
                                           : parent.width
                                fillMode:     Image.PreserveAspectFit
                                asynchronous: true
                                cache:        false
                                smooth:       true
                                mipmap:       true
                                sourceSize:   Qt.size(480, 480)

                                // Reload source once the decode process for this item finishes
                                Connections {
                                    target: root
                                    function onDecodeReadyChanged() {
                                        if (root.decodeReady && root.decodingId === modelData.id) {
                                            _clipImg.source = ""
                                            _clipImg.source = "file://" + _delegate.tmpPath
                                        }
                                    }
                                }
                            }

                            // Thin border overlay drawn on top of the image
                            Rectangle {
                                anchors.centerIn: _clipImg
                                color:        "transparent"
                                border.color: isSelected ? PanelColors.accent : PanelColors.border
                                border.width: 2
                                width:        _clipImg.paintedWidth  + 4
                                height:       _clipImg.paintedHeight + 4
                                radius:       3
                                visible:      _clipImg.status === Image.Ready
                                Behavior on border.color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                            }
                        }

                        // ── Text entry ─────────────────────────────────────
                        Text {
                            id:      _rowText
                            visible: !isImg
                            // Leave room for the delete button on the right
                            width:   parent.width - 14 - 8 - _deleteBtn.width - 12
                            anchors {
                                left:           parent.left; leftMargin: 14
                                verticalCenter: parent.verticalCenter
                            }
                            text:             modelData.preview
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.fontSizeSm
                            color:            PanelColors.textPrimary
                            maximumLineCount: 2
                            wrapMode:         Text.WordWrap
                            elide:            Text.ElideRight
                        }

                        // ── Per-item delete button (×) — shown on hover ────
                        Rectangle {
                            id:      _deleteBtn
                            z:       2
                            visible: _rowHover.containsMouse || _deleteBtnMouse.containsMouse
                            width:   26
                            height:  26
                            radius:  Theme.radiusSm
                            anchors {
                                right:      parent.right; rightMargin: 6
                                top:        parent.top;   topMargin:   8
                            }
                            color: _deleteBtnMouse.containsMouse
                                       ? PanelColors.error
                                       : PanelColors.rowBackground
                            Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                            Text {
                                anchors.centerIn: parent
                                text:           ""
                                font.family:    Theme.fontFamily
                                font.pixelSize: 11
                                color:          _deleteBtnMouse.containsMouse
                                                    ? PanelColors.onError
                                                    : PanelColors.textMuted
                                Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                            }

                            MouseArea {
                                id:           _deleteBtnMouse
                                anchors.fill: parent
                                z:            3
                                hoverEnabled: true
                                enabled:      !_delegate.isDeletingItem
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: (mouse) => {
                                    mouse.accepted = true
                                    _delegate.doDelete()
                                }
                            }
                        }

                        // ── Row hover — sits under the delete button (z:1) ─
                        MouseArea {
                            id:           _rowHover
                            anchors.fill: parent
                            z:            1
                            hoverEnabled: true
                            // Disable hover while a deletion is animating (list shifts)
                            enabled:      !_delegate.isDeletingItem && !root.isDeleting
                            cursorShape:  Qt.PointingHandCursor
                            onEntered: {
                                if (!root.isDeleting)
                                    _list.currentIndex = index
                            }
                            onClicked: (mouse) => {
                                if (_deleteBtnMouse.containsMouse) return
                                Clipboard.pasteEntry(modelData.rawLine)
                                SessionState.clipboardVisible = false
                            }
                        }
                    }
                }
            }
        }

        // ── Empty state ────────────────────────────────────────────────────
        Text {
            anchors.centerIn: _list
            text:           "󰅌  clipboard is empty"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            font.weight:    Theme.fontWeightBold
            color:          PanelColors.textMuted
            visible:        root.filteredEntries.length === 0 && !Clipboard.isLoading
        }

        // ── Dim overlay behind confirmation dialog ─────────────────────────
        Rectangle {
            anchors.fill:        _card
            anchors.margins:     0
            radius:              Theme.radiusLg
            color:               PanelColors.panelBackground
            opacity:             _confirmClear.opacity * 0.55
            visible:             opacity > 0
            z:                   9
        }

        // ── Delete-all confirmation popup ──────────────────────────────────
        Rectangle {
            id:      _confirmClear
            visible: opacity > 0
            opacity: 0
            z:       10
            Behavior on opacity { NumberAnimation { duration: Theme.durationNormal; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

            anchors.centerIn: parent
            width:  320
            height: _confirmCol.implicitHeight + 32
            radius: Theme.radiusMd
            color:  PanelColors.popupBackground
            border.color: PanelColors.border
            border.width: 2

            Column {
                id: _confirmCol
                anchors {
                    top:   parent.top;   left:  parent.left;  right: parent.right
                    margins: 16
                }
                spacing: 12

                Text {
                    width:               parent.width
                    text:                "Clear clipboard history?"
                    font.family:         Theme.fontFamily
                    font.pixelSize:      Theme.fontSizeMd
                    font.weight:         Theme.fontWeightBold
                    color:               PanelColors.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode:            Text.WordWrap
                }

                Text {
                    width:               parent.width
                    text:                "This will permanently delete all clipboard entries."
                    font.family:         Theme.fontFamily
                    font.pixelSize:      Theme.fontSizeSm
                    color:               PanelColors.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode:            Text.WordWrap
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    // Cancel
                    Rectangle {
                        width: 130; height: 34; radius: Theme.radiusSm
                        color: _cancelMouse.containsMouse
                                   ? Qt.lighter(PanelColors.rowBackground, 1.15)
                                   : PanelColors.rowBackground
                        Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                        Text {
                            anchors.centerIn: parent
                            text:        "Cancel"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: Theme.fontWeightBold
                            color:       PanelColors.textPrimary
                        }
                        MouseArea {
                            id: _cancelMouse; anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: _confirmClear.opacity = 0
                        }
                    }

                    // Delete All
                    Rectangle {
                        width: 130; height: 34; radius: Theme.radiusSm
                        color: _wipeMouse.containsMouse ? PanelColors.error : PanelColors.rowBackground
                        Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                        Text {
                            anchors.centerIn: parent
                            text:        "Delete All"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: Theme.fontWeightBold
                            color:       _wipeMouse.containsMouse
                                             ? PanelColors.onError
                                             : PanelColors.error
                            Behavior on color { ColorAnimation { duration: Theme.durationFast ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                        }
                        MouseArea {
                            id: _wipeMouse; anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                _confirmClear.opacity = 0
                                root.isDeleting = true
                                Clipboard.wipeHistory()
                                // isDeleting resets once the model clears (countChanged → applyFilter)
                                Qt.callLater(() => { root.isDeleting = false })
                            }
                        }
                    }
                }
            }
        }
    }
}
