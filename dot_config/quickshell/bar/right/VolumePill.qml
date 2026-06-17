import QtQuick
import "../../components"
import "../../theme"
import "../../services"
import "../../state"

Item {
    id: root

    implicitWidth:  pill.implicitWidth
    implicitHeight: pill.implicitHeight

    function _icon() {
        if (!Audio.sinkReady || Audio.sinkEffMuted) return "󰝟"
        if (Audio.sinkVolumeInt >= 70) return "󰕾"
        if (Audio.sinkVolumeInt >= 30) return "󰖀"
        return "󰕿"
    }

    StatusChip {
        id: pill
        icon: _icon()
        label: Audio.sinkReady ? (Audio.sinkVolumeInt + "%") : "--"
        backgroundColor: PanelColors.pillAudio
        foregroundColor: PanelColors.pillTextAudio
        borderColor: "transparent"
        minWidth: 0

        onClicked: AudioState.toggle()
    }
}