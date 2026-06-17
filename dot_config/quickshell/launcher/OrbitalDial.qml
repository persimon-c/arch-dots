import QtQuick
import Quickshell
import Quickshell.Widgets
import "../theme"
import "../state"

Item {
    id: root

    property var service: null

    readonly property var resultsProxy: service ? service.filteredApps : []
    readonly property bool hasQuery: service && service.query.trim().length > 0
    readonly property int resultCount: resultsProxy ? resultsProxy.length : 0
    readonly property int maxItems: 7
    
    readonly property var displayItems: {
        const source = root.resultsProxy || [];
        if (source.length <= root.maxItems) return source;

        const items = [];
        for (let i = 0; i < root.maxItems; i++) {
            items.push(source[(root.resultOffset + i) % source.length]);
        }
        return items;
    }
    
    readonly property int itemCount: root.displayItems.length
    readonly property real centerX: width / 2
    readonly property real centerY: height / 2
    readonly property real orbitRadius: Math.min(width, height) * 0.34
    readonly property real nodeSize: 68
    readonly property real pillWidth: 188
    readonly property real pillHeight: 36
    readonly property real hubSize: 176
    readonly property var orbitPalette: [
        Colors.primary, 
        Colors.secondary, 
        Colors.tertiary, 
        Colors.error,
        Colors.primaryContainer, 
        Colors.secondaryContainer, 
        Colors.tertiaryContainer
    ]

    property int selectedIndex: 0
    property int resultOffset: 0
    property real orbitSpin: 0
    property real selectionAngleOffset: -selectedIndex * (360 / Math.max(1, itemCount))
    property real wheelAccumulator: 0

    onSelectionAngleOffsetChanged: {
        const currentRot = dialContainer.targetRotation;
        const targetAngle = selectionAngleOffset;
        let diff = targetAngle - currentRot;
        diff = (diff + 180) % 360;
        if (diff < 0) diff += 360;
        diff -= 180;
        dialContainer.targetRotation = currentRot + diff;
    }

    NumberAnimation on orbitSpin {
        running: SessionState.launcherVisible
        from: 0
        to: 360
        duration: 25000
        loops: Animation.Infinite
    }

    function applyAlpha(hexColor, alpha) {
        if (!hexColor) return Qt.rgba(0,0,0,alpha);
        if (hexColor.length === 9) {
            // #AARRGGBB format (though orbitPalette is #RRGGBB)
            return Qt.rgba(
                parseInt(hexColor.slice(3, 5), 16) / 255,
                parseInt(hexColor.slice(5, 7), 16) / 255,
                parseInt(hexColor.slice(7, 9), 16) / 255,
                alpha
            );
        }
        if (hexColor.length === 7) {
            return Qt.rgba(
                parseInt(hexColor.slice(1, 3), 16) / 255,
                parseInt(hexColor.slice(3, 5), 16) / 255,
                parseInt(hexColor.slice(5, 7), 16) / 255,
                alpha
            );
        }
        return Qt.rgba(0, 0, 0, alpha);
    }

    function accentFor(index) {
        return orbitPalette[index % orbitPalette.length];
    }

    function staticAngleForIndex(index, count) {
        if (count <= 0) return -90;
        return -90 + (360 / count) * index;
    }

    function staticNodeX(index, count) {
        const angle = staticAngleForIndex(index, count) * Math.PI / 180;
        return centerX + Math.cos(angle) * orbitRadius;
    }

    function staticNodeY(index, count) {
        const angle = staticAngleForIndex(index, count) * Math.PI / 180;
        return centerY + Math.sin(angle) * orbitRadius;
    }

    function executeSelected() {
        if (!root.displayItems || root.displayItems.length === 0) return;
        const item = root.displayItems[Math.max(0, Math.min(root.selectedIndex, root.displayItems.length - 1))];
        if (item && item.execute) {
            item.execute();
            SessionState.launcherVisible = false;
        }
    }

    function rotateSelection(delta) {
        if (resultCount <= 0 || itemCount <= 0) return;

        if (delta > 0) {
            if (selectedIndex < itemCount - 1) {
                selectedIndex++;
            } else if (resultCount > itemCount) {
                resultOffset = (resultOffset + 1) % resultCount;
            } else {
                selectedIndex = 0;
            }
        } else if (delta < 0) {
            if (selectedIndex > 0) {
                selectedIndex--;
            } else if (resultCount > itemCount) {
                resultOffset = (resultOffset - 1 + resultCount) % resultCount;
            } else {
                selectedIndex = itemCount - 1;
            }
        }
        orbitCanvas.requestPaint();
    }

    onItemCountChanged: {
        resultOffset = Math.min(resultOffset, Math.max(0, resultCount - 1));
        selectedIndex = Math.min(selectedIndex, Math.max(0, itemCount - 1));
        orbitCanvas.requestPaint();
    }

    onDisplayItemsChanged: {
        orbitCanvas.requestPaint();
    }

    onSelectedIndexChanged: orbitCanvas.requestPaint()
    onHasQueryChanged: orbitCanvas.requestPaint()

    Connections {
        target: root.service
        function onQueryChanged() {
            root.resultOffset = 0;
            root.selectedIndex = 0;
        }
    }

    Connections {
        target: SessionState
        function onLauncherVisibleChanged() {
            if (SessionState.launcherVisible) {
                root.resultOffset = 0;
                root.selectedIndex = 0;
                root.wheelAccumulator = 0;
                input.text = "";
                focusTimer.restart();
            } else {
                input.text = "";
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 80
        repeat: false
        onTriggered: input.forceActiveFocus()
    }

    WheelHandler {
        id: launcherWheel
        target: root
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y;
            if (delta !== 0) {
                root.wheelAccumulator += delta;
                const stepThreshold = 360 / Math.max(1, root.itemCount);
                while (Math.abs(root.wheelAccumulator) >= stepThreshold) {
                    if (root.wheelAccumulator > 0) {
                        root.rotateSelection(-1);
                        root.wheelAccumulator -= stepThreshold;
                    } else {
                        root.rotateSelection(1);
                        root.wheelAccumulator += stepThreshold;
                    }
                }
                event.accepted = true;
            }
        }
    }

    Item {
        id: dialContainer
        anchors.fill: parent
        
        property real targetRotation: 0
        rotation: targetRotation

        Behavior on rotation {
            NumberAnimation { duration: 450; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve }
        }

        Canvas {
            id: orbitCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                const cx = root.centerX;
                const cy = root.centerY;
                const minSide = Math.min(width, height);
                const rings = [0.19, 0.28, 0.37];

                for (let r = 0; r < rings.length; r++) {
                    ctx.beginPath();
                    ctx.arc(cx, cy, minSide * rings[r], 0, Math.PI * 2);
                    ctx.strokeStyle = root.applyAlpha(r % 2 === 0 ? Colors.primary : Colors.secondary, 0.34);
                    ctx.lineWidth = r === 1 ? 1.7 : 1.2;
                    ctx.stroke();
                }

                for (let i = 0; i < root.itemCount; i++) {
                    const nx = root.staticNodeX(i, root.itemCount);
                    const ny = root.staticNodeY(i, root.itemCount);
                    const accent = root.accentFor(i);

                    ctx.beginPath();
                    ctx.moveTo(cx, cy);
                    ctx.quadraticCurveTo(cx + (nx - cx) * 0.34, cy + (ny - cy) * 0.34, nx, ny);
                    ctx.strokeStyle = root.applyAlpha(accent, i === root.selectedIndex ? 0.92 : 0.46);
                    ctx.lineWidth = i === root.selectedIndex ? 2.8 : 1.5;
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.arc(nx, ny, 4.5, 0, Math.PI * 2);
                    ctx.fillStyle = root.applyAlpha(accent, 0.95);
                    ctx.fill();
                }
            }
        }

        Repeater {
            model: root.itemCount
            delegate: Rectangle {
                width: 5.6
                height: 5.6
                radius: 2.8
                color: root.applyAlpha(index % 2 === 0 ? Colors.primary : Colors.secondary, 0.72)
                
                readonly property real dotAngle: (root.orbitSpin + index * 64) * Math.PI / 180
                x: root.centerX + Math.cos(dotAngle) * Math.min(root.width, root.height) * 0.27 - width/2
                y: root.centerY + Math.sin(dotAngle) * Math.min(root.width, root.height) * 0.27 - height/2
            }
        }

        Repeater {
            model: root.displayItems

            delegate: Item {
                id: planet
                required property var modelData
                required property int index

                readonly property real globalAngle: root.staticAngleForIndex(index, root.itemCount) + dialContainer.rotation
                readonly property real angleRad: globalAngle * Math.PI / 180
                readonly property bool leftSide: Math.cos(angleRad) < -0.18
                readonly property bool selected: root.selectedIndex === index
                readonly property color accent: root.accentFor(index)
                readonly property real nodeCenterX: root.staticNodeX(index, root.itemCount)
                readonly property real nodeCenterY: root.staticNodeY(index, root.itemCount)

                width: root.nodeSize + root.pillWidth + 18
                height: root.nodeSize + 10
                x: nodeCenterX - (leftSide ? width - root.nodeSize / 2 : root.nodeSize / 2)
                y: nodeCenterY - height / 2
                z: selected ? 20 : 8
                opacity: 1
                scale: selected ? 1.08 : 1.0

                Behavior on x { NumberAnimation { duration: 260; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                Behavior on y { NumberAnimation { duration: 260; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Theme.easingType; easing.bezierCurve: Theme.easingCurve } }

                Rectangle {
                    id: labelPill
                    x: planet.leftSide ? 0 : root.nodeSize * 0.58
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.pillWidth
                    height: root.pillHeight
                    radius: height / 2
                    color: root.applyAlpha(Colors.surfaceContainer, planet.selected ? 0.96 : 0.90)
                    border.width: 1.2
                    border.color: root.applyAlpha(planet.accent, planet.selected ? 0.98 : 0.70)
                    antialiasing: true

                    rotation: -dialContainer.rotation

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: parent.radius - 1
                        color: root.applyAlpha(planet.accent, planet.selected ? 0.10 : 0.035)
                        antialiasing: true
                    }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: planet.leftSide ? 16 : 44
                        anchors.rightMargin: planet.leftSide ? 44 : 16
                        text: modelData.name || modelData.id || ""
                        color: "#f8fbff"
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        horizontalAlignment: planet.leftSide ? Text.AlignRight : Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    id: nodeGlow
                    x: planet.leftSide ? root.pillWidth + 14 : 0
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.nodeSize
                    height: root.nodeSize
                    radius: width / 2
                    color: root.applyAlpha(planet.accent, planet.selected ? 0.40 : 0.24)
                    antialiasing: true

                    rotation: -dialContainer.rotation

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 12
                        height: width
                        radius: width / 2
                        color: root.applyAlpha(Colors.surfaceContainer, 0.98)
                        border.width: 1.4
                        border.color: root.applyAlpha(planet.accent, planet.selected ? 0.96 : 0.64)
                        antialiasing: true
                    }

                    IconImage {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        source: Quickshell.iconPath(modelData.icon || "application-x-executable", "image-missing")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedIndex = index;
                        root.executeSelected();
                    }
                }
            }
        }
    }

    Rectangle {
        id: hubGlow
        anchors.centerIn: parent
        width: root.hubSize + 34
        height: width
        radius: width / 2
        color: root.applyAlpha(Colors.primary, 0.11)
        border.width: 2
        border.color: root.applyAlpha(Colors.secondary, 0.48)
        antialiasing: true

        Rectangle {
            anchors.centerIn: parent
            width: root.hubSize
            height: width
            radius: width / 2
            color: root.applyAlpha(Colors.surfaceContainer, 0.97)
            border.width: 2
            border.color: root.applyAlpha(Colors.primary, 0.86)
            antialiasing: true

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 34
                height: width
                radius: width / 2
                color: root.applyAlpha(Colors.surfaceContainer, 0.52)
                border.width: 1.3
                border.color: root.applyAlpha(Colors.tertiary, 0.72)
                antialiasing: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -18
                text: ":3"
                color: "#f8fbff"
                font.family: Theme.fontFamily
                font.pixelSize: 32
                font.weight: Font.DemiBold
            }

            TextInput {
                id: input
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 28
                width: 116
                height: 30
                focus: true
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.weight: Font.Medium
                color: "#f8fbff"
                selectedTextColor: PanelColors.textOnAccent
                selectionColor: PanelColors.accent
                clip: true

                Text {
                    anchors.centerIn: parent
                    text: root.hasQuery ? "" : "search"
                    color: root.applyAlpha("#f8fbff", 0.66)
                    font: input.font
                    visible: input.text.length === 0
                }

                onTextChanged: debounceTimer.restart()
                onAccepted: root.executeSelected()

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        SessionState.launcherVisible = false;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
                        root.rotateSelection(-1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                        root.rotateSelection(1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.executeSelected();
                        event.accepted = true;
                    }
                }

                Timer {
                    id: debounceTimer
                    interval: 20
                    repeat: false
                    onTriggered: {
                        if (root.service) {
                            root.service.query = input.text;
                        }
                    }
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: Math.min(parent.width - 80, 420)
        text: root.itemCount > 0
            ? ((root.hasQuery ? "search" : "recent") + " / " + (root.displayItems[root.selectedIndex] ? root.displayItems[root.selectedIndex].name : "apps") + (root.resultCount > root.itemCount ? "  " + (root.resultOffset + 1) + "-" + Math.min(root.resultOffset + root.itemCount, root.resultCount) + "/" + root.resultCount : ""))
            : "no results"
        color: root.applyAlpha("#f8fbff", 0.88)
        font.family: Theme.fontFamily
        font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }
}
