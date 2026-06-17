// Service: audio — implemented 2026-06-17
// services/Audio.qml — Audio service
// Exposes default sink (output) and source (input) via Pipewire.
// PwObjectTracker binds both nodes so volume/mute properties are valid.
// Sink/source may briefly be null when the default changes — all reads
// are null-guarded so nothing downstream crashes during that window.
pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    // ── Binding ───────────────────────────────────────────────────────────
    // Binds whichever nodes are currently default. Nulls are safe per docs.

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    // ── Internal: raw nodes ───────────────────────────────────────────────

    readonly property PwNode _sink:   Pipewire.defaultAudioSink
    readonly property PwNode _source: Pipewire.defaultAudioSource

    // ── Sink (output) — public ────────────────────────────────────────────

    readonly property bool   sinkReady:       _sink !== null && _sink.ready
    readonly property string sinkName:        sinkReady ? (_sink.nickname || _sink.description || _sink.name) : ""

    // Volume: 0.0 – 1.0 (Pipewire linear scale)
    readonly property real   sinkVolume:      sinkReady && _sink.audio !== null ? _sink.audio.volume : 0.0
    readonly property bool   sinkMuted:       sinkReady && _sink.audio !== null ? _sink.audio.muted  : false

    // Volume as 0–100 integer for display
    readonly property int    sinkVolumeInt:   Math.round(sinkVolume * 100)

    // Effective mute: muted flag OR volume at zero
    readonly property bool   sinkEffMuted:    sinkMuted || sinkVolumeInt === 0

    // ── Source (input / mic) — public ─────────────────────────────────────

    readonly property bool   sourceReady:     _source !== null && _source.ready
    readonly property string sourceName:      sourceReady ? (_source.nickname || _source.description || _source.name) : ""

    readonly property real   sourceVolume:    sourceReady && _source.audio !== null ? _source.audio.volume : 0.0
    readonly property bool   sourceMuted:     sourceReady && _source.audio !== null ? _source.audio.muted  : false
    readonly property int    sourceVolumeInt: Math.round(sourceVolume * 100)

    // ── Setters ───────────────────────────────────────────────────────────

    function setSinkVolume(v) {
        // v: 0.0 – 1.0; clamp to valid range
        if (!sinkReady || _sink.audio === null) return
        _sink.audio.volume = Math.max(0.0, Math.min(1.0, v))
    }

    function setSinkVolumeInt(v) {
        // v: 0 – 100 integer convenience wrapper (used by OSD and slider)
        setSinkVolume(v / 100.0)
    }

    function setSinkMuted(muted) {
        if (!sinkReady || _sink.audio === null) return
        _sink.audio.muted = muted
    }

    function toggleSinkMuted() {
        setSinkMuted(!sinkMuted)
    }

    function setSourceMuted(muted) {
        if (!sourceReady || _source.audio === null) return
        _source.audio.muted = muted
    }

    function toggleSourceMuted() {
        setSourceMuted(!sourceMuted)
    }

    // Raise/lower volume by a step (used by keybinds and scroll wheel)
    function raiseSinkVolume(step) {
        setSinkVolume(Math.min(1.0, sinkVolume + (step || 0.05)))
    }

    function lowerSinkVolume(step) {
        setSinkVolume(Math.max(0.0, sinkVolume - (step || 0.05)))
    }

    // ── Preferred sink switching ──────────────────────────────────────────
    // Used by the volume dropdown to switch output device.

    function setPreferredSink(node) {
        Pipewire.preferredDefaultAudioSink = node
    }

    function setPreferredSource(node) {
        Pipewire.preferredDefaultAudioSource = node
    }

    // ── Debug ─────────────────────────────────────────────────────────────
    Component.onCompleted: {
        console.log("Audio: service ready — Pipewire ready:", Pipewire.ready)
        console.log("Audio: sink:", sinkName, "| vol:", sinkVolumeInt + "%", "| muted:", sinkMuted)
        console.log("Audio: source:", sourceName, "| muted:", sourceMuted)
    }
}
