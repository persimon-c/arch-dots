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

    // Inheriting directly from PopupWindow gives us total control over the sizing.
    // Quickshell's default generic Dropdown wrapper forced the cut-off.

    property bool open: false
    visible: open || (contentCard._anim > 0.01)
    property Item anchorItem: null

    // Visibility bound to the shared state

    onVisibleChanged: {
        if (!visible) MediaState.popupVisible = false
    }

    // Anchor exactly to the parent Pill
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 40

    // Click anywhere outside the PopupWindow to close it (Disabled to allow screenshots)
    grabFocus: false

    // Make the popup window itself transparent so corners aren't filled with white
    color: "transparent"

    // Size driven entirely by the content Row
    implicitWidth: mainRow.implicitWidth
    implicitHeight: mainRow.implicitHeight

    // Live position tracking for progress bar
    property real livePosition: 0
    property bool userSeeking: false

    Timer {
        id: positionTimer
        interval: 1000
        repeat: true
        running: Media.isPlaying && !root.userSeeking && Media.positionSupported
        onTriggered: {
            root.livePosition = Media.getPosition()
        }
    }

    // Reset position when track changes or active player changes
    Connections {
        target: Media
        function onTitleChanged() {
            root.livePosition = 0
            root.userSeeking = false
        }
        function onActivePlayerChanged() {
            root.livePosition = Media.getPosition()
            root.userSeeking = false
        }
    }

    Timer {
        id: seekReleaseTimer
        interval: 1200
        onTriggered: root.userSeeking = false
    }

    function getPlayerIcon(identity) {
        const id = (identity || "").toLowerCase();
        if (id.includes("spotify")) return "󰓇";
        if (id.includes("firefox")) return "󰈹";
        if (id.includes("zen"))     return "󰈹";
        if (id.includes("chrome"))  return "󰊯";
        if (id.includes("vlc"))     return "󰕼";
        return "󰎆";
    }

    function fmtTime(secs) {
        if (secs <= 0) return "0:00"
        var m = Math.floor(secs / 60)
        var s = Math.floor(secs % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    // ── Content ───────────────────────────────────────────────────────────
    Row {
        id: mainRow
        spacing: 6

        PlayerNavButton {
            visible: Media.playerList.length > 1
            icon: ""
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                var list = Media.playerList;
                var idx = list.indexOf(Media.activePlayer);
                if (idx !== -1) {
                    idx = (idx - 1 + list.length) % list.length;
                    Media.setActivePlayer(list[idx]);
                }
            }
        }

        Rectangle {
            id: contentCard
            implicitWidth: 300
            implicitHeight: col.implicitHeight + 28
            width: 300
            height: implicitHeight
            radius: 10
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
        color: "transparent"
        AmbientSurface {
            anchors.fill: parent
            radius: contentCard.radius
            borderColor: PanelColors.pillClock
            borderWidth: 2
        }

            Column {
                id: col
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 14
                spacing: 14

                // ── Top Row: Art + Info ───────────────────────────────────────────
                Row {
                    width: parent.width
                    spacing: 14

                    // Album Art
                    Item {
                        id: artContainer
                        width: 80
                        height: 80

                        Rectangle {
                            anchors.fill: parent
                            color: PanelColors.rowBackground
                            radius: 4
                            clip: true

                            Image {
                                id: artImage
                                anchors.fill: parent
                                source: Media.artUrl || ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                mipmap: true
                                smooth: true
                                visible: Media.artUrl !== ""
                            }

                            Text {
                                visible: Media.artUrl === ""
                                anchors.centerIn: parent
                                text: ""
                                font.pixelSize: 28
                                font.family: Theme.fontFamily
                                color: PanelColors.textMuted
                            }
                        }

                        // Art border frame
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: 2
                            border.color: PanelColors.pillClock
                            radius: 4
                        }
                    }

                    // Title + Artist + Source Badge
                    Column {
                        width: parent.width - artContainer.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        // Scrolling Title
                        Item {
                            width: parent.width
                            height: 20
                            clip: true

                            Text {
                                id: titleText
                                text: Media.title || "No Media Playing"
                                font.pixelSize: Theme.fontSizeMd
                                font.bold: true
                                font.family: Theme.fontFamily
                                // Forced to exact target accent color
                                color: PanelColors.pillClock
                                width: implicitWidth

                                readonly property bool overflow: implicitWidth > parent.width
                                onOverflowChanged: { marqueeAnim.stop(); titleText.x = 0; if (overflow) marqueeAnim.start() }
                                onTextChanged: { marqueeAnim.stop(); titleText.x = 0; if (overflow) marqueeAnim.start() }

                                SequentialAnimation {
                                    id: marqueeAnim
                                    running: false
                                    loops: Animation.Infinite
                                    PauseAnimation { duration: 1500 }
                                    NumberAnimation {
                                        target: titleText
                                        property: "x"
                                        from: 0
                                        to: -titleText.implicitWidth
                                        duration: titleText.implicitWidth * 16
                                        easing.type: Easing.Linear
                                    }
                                    PropertyAction { target: titleText; property: "x"; value: titleText.parent.width }
                                    NumberAnimation {
                                        target: titleText
                                        property: "x"
                                        from: titleText.parent.width
                                        to: 0
                                        duration: titleText.implicitWidth * 12
                                        easing.type: Easing.Linear
                                    }
                                    PauseAnimation { duration: 1500 }
                                }
                            }
                        }

                        // Artist
                        Text {
                            width: parent.width
                            text: Media.artist || "Unknown Artist"
                            font.pixelSize: Theme.fontSizeSm
                            font.family: Theme.fontFamily
                            color: PanelColors.textDim
                            elide: Text.ElideRight
                        }

                        // Source badge
                        Rectangle {
                            visible: Media.playerName !== ""
                            height: 18
                            width: badgeRow.implicitWidth + 12
                            radius: 9
                            color: Qt.rgba(Qt.color(PanelColors.pillClock).r, Qt.color(PanelColors.pillClock).g, Qt.color(PanelColors.pillClock).b, 0.12)
                            border.color: Qt.rgba(Qt.color(PanelColors.pillClock).r, Qt.color(PanelColors.pillClock).g, Qt.color(PanelColors.pillClock).b, 0.15)
                            border.width: 1

                            Row {
                                id: badgeRow
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: root.getPlayerIcon(Media.playerName)
                                    font.pixelSize: 10
                                    font.family: Theme.fontFamily
                                    color: PanelColors.pillClock
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: Media.playerName
                                    font.pixelSize: Theme.fontSizeXs
                                    font.bold: true
                                    font.family: Theme.fontFamily
                                    color: PanelColors.pillClock
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }

                // ── Wavy Progress Bar ─────────────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 4
                    visible: Media.hasPlayers

                    WaveBar {
                        id: waveBar
                        width: parent.width
                        accentColor: PanelColors.pillClock
                        from: 0
                        to: Math.max(1, Media.length)
                        value: Math.min(root.livePosition, Math.max(1, Media.length))
                        playing: Media.isPlaying
                        seekable: Media.canSeek && Media.positionSupported

                        onSeeked: (v) => {
                            root.userSeeking = true
                            const targetPos = Math.max(0, Math.min(v, Media.length))
                            Media.setPosition(targetPos)
                            root.livePosition = targetPos
                            seekReleaseTimer.restart()
                        }
                    }

                    // Elapsed / Total time
                    Row {
                        width: parent.width

                        Text {
                            id: posLeft
                            text: Media.positionSupported ? root.fmtTime(root.livePosition) : "--:--"
                            font.pixelSize: Theme.fontSizeXs
                            font.family: Theme.fontFamilyMono
                            color: PanelColors.textDim
                        }

                        Item {
                            width: parent.width - posLeft.implicitWidth - posRight.implicitWidth
                            height: 1
                        }

                        Text {
                            id: posRight
                            text: Media.positionSupported ? root.fmtTime(Media.length) : "--:--"
                            font.pixelSize: Theme.fontSizeXs
                            font.family: Theme.fontFamilyMono
                            color: PanelColors.textDim
                        }
                    }
                }

                // ── Bottom Control Row ────────────────────────────────────────────
                Item {
                    width: parent.width
                    height: playPauseBtn.height
                    visible: Media.hasPlayers

                    // Shuffle Button (Left)
                    MediaButton {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Media.shuffleSupported
                        icon: ""
                        accentColor: PanelColors.pillClock
                        highlighted: Media.shuffle
                        onClicked: Media.toggleShuffle()
                    }

                    // Central Navigation Controls
                    Row {
                        anchors.centerIn: parent
                        spacing: 6

                        // Previous
                        MediaButton {
                            icon: ""
                            accentColor: PanelColors.pillClock
                            enabled: Media.canGoPrevious
                            opacity: enabled ? 1.0 : 0.45
                            onClicked: Media.previous()
                        }

                        // Play / Pause (Highlighted)
                        MediaButton {
                            id: playPauseBtn
                            icon: Media.isPlaying ? "" : ""
                            highlighted: true
                            accentColor: PanelColors.pillClock
                            enabled: Media.canPlay || Media.canPause
                            onClicked: Media.togglePlaying()
                        }

                        // Next
                        MediaButton {
                            icon: ""
                            accentColor: PanelColors.pillClock
                            enabled: Media.canGoNext
                            opacity: enabled ? 1.0 : 0.45
                            onClicked: Media.next()
                        }
                    }

                    // Repeat Button (Right)
                    MediaButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Media.loopSupported
                        icon: Media.loopState === 2 ? "" : ""
                        accentColor: PanelColors.pillClock
                        highlighted: Media.loopState !== 0
                        onClicked: Media.cycleLoop()
                    }
                }
            }
        }

        PlayerNavButton {
            visible: Media.playerList.length > 1
            icon: ""
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                var list = Media.playerList;
                var idx = list.indexOf(Media.activePlayer);
                if (idx !== -1) {
                    idx = (idx + 1) % list.length;
                    Media.setActivePlayer(list[idx]);
                }
            }
        }
    }

    // ── Squiggly Wave Progress Bar Component ──────────────────────────────
    component WaveBar: Item {
        id: bar
        property real value: 0
        property real from: 0
        property real to: 100
        property color accentColor: PanelColors.accent
        property bool playing: false
        property bool seekable: true
        signal seeked(real value)

        implicitWidth: 120
        implicitHeight: 28

        property bool dragging: barMouse.pressed
        property real internalValue: 0
        readonly property bool activeInteraction: dragging
        readonly property bool isNeedle: (activeInteraction || playing) && seekable
        readonly property bool hovered: barMouse.containsMouse || barMouse.pressed
        readonly property real targetValue: activeInteraction ? internalValue : value

        property real animValue: targetValue
        Behavior on animValue {
            enabled: !bar.dragging
            NumberAnimation { duration: 80; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
        }

        readonly property real _fillWidth: {
            if (!Media.positionSupported) return bar.width
            return ((bar.animValue - bar.from) / (bar.to - bar.from)) * bar.width
        }

        function _updateFromMouse(mouseX) {
            var newVal = Math.max(bar.from, Math.min(bar.to, bar.from + (mouseX / bar.width) * (bar.to - bar.from)))
            bar.internalValue = newVal
            bar.seeked(newVal)
        }

        property real _phase: 0
        NumberAnimation on _phase {
            from: 0
            to: Math.PI * 2
            duration: 1200
            loops: Animation.Infinite
            running: bar.playing && !bar.activeInteraction
        }

        property real _waveAmount: 0.0
        Behavior on _waveAmount { NumberAnimation { duration: 400; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        onPlayingChanged: _waveAmount = (playing && !activeInteraction) ? 1.0 : 0.0
        onActiveInteractionChanged: _waveAmount = (playing && !activeInteraction) ? 1.0 : 0.0

        property color _strokeColor: hovered ? Qt.lighter(bar.accentColor, 1.15) : bar.accentColor
        Behavior on _strokeColor { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

        // Background track Rectangle
        Rectangle {
            x: Math.max(0, bar._fillWidth - 3)
            width: Math.max(0, parent.width - x - 3)
            height: 4
            radius: 2
            anchors.verticalCenter: parent.verticalCenter
            color: bar.hovered
                ? Qt.rgba(Qt.color(PanelColors.border).r, Qt.color(PanelColors.border).g, Qt.color(PanelColors.border).b, 0.35)
                : Qt.rgba(Qt.color(PanelColors.border).r, Qt.color(PanelColors.border).g, Qt.color(PanelColors.border).b, 0.15)
            Behavior on color { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        }

        // Canvas for wavy waveform progress
        Canvas {
            id: waveCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                if (bar._fillWidth <= 0) return

                const cy = height / 2
                const amp = 3.5 * bar._waveAmount
                const freq = 0.16
                ctx.beginPath()
                ctx.lineWidth = 4
                ctx.lineCap = "round"
                ctx.strokeStyle = bar._strokeColor

                const startX = 2
                const endX = Math.min(bar._fillWidth, width - 2)

                if (bar._waveAmount > 0) {
                    for (let x = startX; x <= endX; x++) {
                        const y = cy + Math.sin(x * freq + bar._phase) * amp
                        if (x === startX) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                    }
                } else {
                    ctx.moveTo(startX, cy)
                    ctx.lineTo(endX, cy)
                }
                ctx.stroke()
            }

            Connections {
                target: bar
                function onAnimValueChanged()    { waveCanvas.requestPaint() }
                function on_PhaseChanged()       { waveCanvas.requestPaint() }
                function on_WaveAmountChanged()  { waveCanvas.requestPaint() }
                function onHoveredChanged()      { waveCanvas.requestPaint() }
                function on_StrokeColorChanged() { waveCanvas.requestPaint() }
            }
        }

        // Playhead indicator
        Item {
            visible: Media.positionSupported
            width: 0
            height: 0
            anchors.verticalCenter: parent.verticalCenter
            x: bar._fillWidth

            Rectangle {
                anchors.centerIn: parent
                width: bar.isNeedle ? 4 : (bar.hovered ? 14 : 10)
                height: bar.isNeedle ? 20 : (bar.hovered ? 14 : 10)
                radius: width / 2
                color: bar.hovered ? Qt.lighter(bar.accentColor, 1.15) : bar.accentColor

                Behavior on width  { NumberAnimation { duration: 300; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                Behavior on height { NumberAnimation { duration: 300; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                Behavior on color  { ColorAnimation { duration: 150 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
            }
        }

        // Seeking MouseArea
        MouseArea {
            id: barMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: bar.seekable

            property bool _hasDragged: false

            onPressed: (mouse) => {
                bar.internalValue = bar.animValue
                _hasDragged = false
            }
            onPositionChanged: (mouse) => {
                if (pressed) {
                    _hasDragged = true
                    bar._updateFromMouse(mouse.x)
                }
            }
            onClicked: (mouse) => {
                if (!_hasDragged) {
                    bar._updateFromMouse(mouse.x)
                }
            }
        }
    }

    // ── Media Button Component ────────────────────────────────────────────
    component MediaButton: Rectangle {
        id: btn
        property string icon: ""
        property bool highlighted: false
        property color accentColor: PanelColors.pillClock
        property bool enabled: true
        signal clicked()

        width: 40
        height: 40
        radius: 8

        color: {
            if (!enabled) return Qt.rgba(Qt.color(PanelColors.rowBackground).r, Qt.color(PanelColors.rowBackground).g, Qt.color(PanelColors.rowBackground).b, 0.35)
            if (highlighted) return btnMouse.containsMouse ? Qt.lighter(accentColor, 1.1) : accentColor
            return btnMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
        }

        border.color: highlighted ? "transparent" : Qt.rgba(1, 1, 1, btnMouse.containsMouse ? 0.10 : 0.04)
        border.width: 1
        scale: btnMouse.pressed ? 0.91 : 1.0

        Behavior on color { ColorAnimation { duration: 120 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.pixelSize: 18
            font.family: Theme.fontFamily
            color: {
                if (!btn.enabled) return PanelColors.textMuted
                if (btn.highlighted) return Colors.onPrimaryColor
                return btn.accentColor
            }
            Behavior on color { ColorAnimation { duration: 120 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: btn.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    // ── Player Nav Button Component (Floating Arrows) ─────────────────────
    component PlayerNavButton: Rectangle {
        id: navBtn
        property string icon: ""
        property color accentColor: PanelColors.pillClock
        signal clicked()

        implicitWidth: 36
        implicitHeight: 36
        width: 36
        height: 36
        radius: 10

        color: navMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.3) : PanelColors.rowBackground
        border.color: PanelColors.border
        border.width: 1
        scale: navMouse.pressed ? 0.88 : 1.0

        Behavior on color { ColorAnimation { duration: 120 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

        Text {
            anchors.centerIn: parent
            text: navBtn.icon
            font.pixelSize: 16
            font.family: Theme.fontFamily
            color: navBtn.accentColor
            Behavior on color { ColorAnimation { duration: 120 ; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
        }

        MouseArea {
            id: navMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: navBtn.clicked()
        }
    }
}
