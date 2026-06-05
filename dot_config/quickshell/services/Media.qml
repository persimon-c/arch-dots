// services/Media.qml — MPRIS media service
// Tracks all connected players and exposes the "active" one for the bar pill.
// Active player priority: Playing > Paused > Stopped > first in list.
// Manual override via setActivePlayer() for the multi-player dropdown.
// All controls are guarded by the relevant canXyz properties per the docs.

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    // ── Player list ───────────────────────────────────────────────────────

    readonly property var players: Mpris.players

    readonly property bool hasPlayers: Mpris.players.count > 0

    // ── Active player selection ───────────────────────────────────────────
    // Manual override takes priority. Otherwise: Playing > Paused > Stopped > first.
    // Re-evaluates whenever the players list or any player's state changes.

    // Set by setActivePlayer() — cleared automatically when that player disappears
    property MprisPlayer _manualPlayer: null

    Connections {
        target: Mpris.players
        function onObjectRemovedPost(obj) {
            if (root._manualPlayer === obj) root._manualPlayer = null
        }
    }

    readonly property MprisPlayer activePlayer: {
        if (_manualPlayer !== null) return _manualPlayer;
        if (!Mpris.players || Mpris.players.values.length === 0) return null;

        var playing = null;
        var paused  = null;
        var stopped = null;

        for (var i = 0; i < Mpris.players.values.length; i++) {
            var p = Mpris.players.values[i];
            if (!p) continue;
            if (!playing && p.playbackState === MprisPlaybackState.Playing) playing = p;
            if (!paused  && p.playbackState === MprisPlaybackState.Paused)  paused  = p;
            if (!stopped && p.playbackState === MprisPlaybackState.Stopped) stopped = p;
        }

        return playing || paused || stopped || Mpris.players.values[0] || null;
    }

    // ── Active player state ───────────────────────────────────────────────

    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false
    readonly property bool isPaused:  activePlayer
        ? activePlayer.playbackState === MprisPlaybackState.Paused  : false
    readonly property bool isStopped: activePlayer
        ? activePlayer.playbackState === MprisPlaybackState.Stopped : false

    // ── Track info ────────────────────────────────────────────────────────

    readonly property string title:       activePlayer ? (activePlayer.trackTitle       || "Unknown Title")  : ""
    readonly property string artist:      activePlayer ? (activePlayer.trackArtist      || "Unknown Artist") : ""
    readonly property string album:       activePlayer ? (activePlayer.trackAlbum       || "")               : ""
    readonly property string albumArtist: activePlayer ? (activePlayer.trackAlbumArtist || "")               : ""
    readonly property string artUrl:      activePlayer ? activePlayer.trackArtUrl                            : ""

    // Player identity — e.g. "Spotify", "mpv" — for the dropdown header
    readonly property string playerName:  activePlayer ? activePlayer.identity    : ""

    // Desktop entry — for icon lookup in MediaPill
    readonly property string desktopEntry: activePlayer ? activePlayer.desktopEntry : ""

    // ── Position and length ───────────────────────────────────────────────
    // Per docs: position does NOT update reactively while playing.
    // Components needing a live progress bar must own a Timer and call
    // activePlayer.positionChanged() themselves — see MprisPlayer docs.
    // Media.qml exposes the raw values; MediaPill/MediaDropdown own the timer.

    readonly property bool lengthSupported:   activePlayer ? activePlayer.lengthSupported   : false
    readonly property bool positionSupported: activePlayer ? activePlayer.positionSupported : false

    readonly property real length: lengthSupported ? activePlayer.length : 0

    // Formatted duration — "m:ss"
    readonly property string lengthStr: _formatTime(length)

    // Read current position — always fresh since position isn't reactive
    function getPosition() {
        return (activePlayer && positionSupported) ? activePlayer.position : 0
    }

    function getPositionStr() {
        return _formatTime(getPosition())
    }

    function _formatTime(secs) {
        if (secs <= 0) return "0:00"
        var m = Math.floor(secs / 60)
        var s = Math.floor(secs % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    // ── Shuffle / loop ────────────────────────────────────────────────────

    readonly property bool shuffle:          activePlayer ? activePlayer.shuffle      : false
    readonly property int  loopState:        activePlayer ? activePlayer.loopState    : MprisLoopState.None
    readonly property bool shuffleSupported: activePlayer ? activePlayer.shuffleSupported : false
    readonly property bool loopSupported:    activePlayer ? activePlayer.loopSupported    : false

    // ── Capabilities ──────────────────────────────────────────────────────

    readonly property bool canPlay:       activePlayer ? activePlayer.canPlay          : false
    readonly property bool canPause:      activePlayer ? activePlayer.canPause         : false
    readonly property bool canGoNext:     activePlayer ? activePlayer.canGoNext        : false
    readonly property bool canGoPrevious: activePlayer ? activePlayer.canGoPrevious    : false
    readonly property bool canSeek:       activePlayer ? activePlayer.canSeek          : false
    readonly property bool canToggle:     activePlayer ? activePlayer.canTogglePlaying : false

    // ── Controls ──────────────────────────────────────────────────────────
    // All guarded by canXyz — safe to call unconditionally from UI.

    function togglePlaying() {
        if (activePlayer && canToggle) activePlayer.togglePlaying()
    }

    function play() {
        if (activePlayer && canPlay) activePlayer.play()
    }

    function pause() {
        if (activePlayer && canPause) activePlayer.pause()
    }

    function next() {
        if (activePlayer && canGoNext) activePlayer.next()
    }

    function previous() {
        if (activePlayer && canGoPrevious) activePlayer.previous()
    }

    function seek(offsetSecs) {
        if (activePlayer && canSeek) activePlayer.seek(offsetSecs)
    }

    function setPosition(secs) {
        if (activePlayer && canSeek && positionSupported)
            activePlayer.position = secs
    }

    function toggleShuffle() {
        if (activePlayer && activePlayer.canControl && shuffleSupported)
            activePlayer.shuffle = !activePlayer.shuffle
    }

    function cycleLoop() {
        if (!activePlayer || !activePlayer.canControl || !loopSupported) return
        switch (activePlayer.loopState) {
            case MprisLoopState.None:     activePlayer.loopState = MprisLoopState.Playlist; break
            case MprisLoopState.Playlist: activePlayer.loopState = MprisLoopState.Track;    break
            case MprisLoopState.Track:    activePlayer.loopState = MprisLoopState.None;     break
        }
    }

    // Switch active player — for multi-player UI in MediaDropdown
    function setActivePlayer(player) {
        _manualPlayer = player
    }

    function clearActivePlayer() {
        _manualPlayer = null
    }

    // ── Debug ─────────────────────────────────────────────────────────────
    Component.onCompleted: {
        console.log("Media: service ready — players:", Mpris.players.count)
        if (activePlayer) {
            console.log("Media: active:", playerName, "—", artist, "–", title)
        }
    }
}