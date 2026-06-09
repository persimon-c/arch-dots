// Github.qml
// Service: GitHub heatmap + activity feed + local repo list.
// No UI. All data fetched on explicit refresh() call — no background polling.
// Three parallel Process calls, each independent. Failure of one does not affect others.
//
// Consumers bind to:
//   Github.username             string
//   Github.totalContributions   int
//   Github.days                 array of { date, count, level }  (level 0–4)
//   Github.activity             array of { event_type, description, repo, count, time, total_commits? }
//   Github.repos                array of { name, path, branch, last_commit_msg, last_commit_rel, dirty, remote_url }
//   Github.heatmapReady         bool  — true once heatmap data has loaded at least once
//   Github.activityReady        bool
//   Github.reposReady           bool
//   Github.heatmapLoading       bool  — true while fetch is in flight
//   Github.activityLoading      bool
//   Github.reposLoading         bool
//   Github.heatmapError         string — empty if no error
//   Github.activityError        string
//   Github.reposError           string
//   Github.refresh()            call to re-fetch all three

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Config ────────────────────────────────────────────────────────────────
    // Scripts are installed next to the quickshell config.
    // QML cannot expand ~, so we use Quickshell.env("HOME").
    readonly property string _home:       Quickshell.env("HOME")
    readonly property string _scriptDir:  _home + "/.config/quickshell/scripts"

    // ── Heatmap state ─────────────────────────────────────────────────────────
    property string username:            ""
    property int    totalContributions:  0
    property var    days:                []
    property bool   heatmapReady:        false
    property bool   heatmapLoading:      false
    property string heatmapError:        ""

    // ── Activity state ────────────────────────────────────────────────────────
    property var    activity:            []
    property bool   activityReady:       false
    property bool   activityLoading:     false
    property string activityError:       ""

    // ── Repo state ────────────────────────────────────────────────────────────
    property var    repos:               []
    property bool   reposReady:          false
    property bool   reposLoading:        false
    property string reposError:          ""

    // ── Public API ────────────────────────────────────────────────────────────
    function refresh() {
        _startHeatmap();
        _startActivity();
        _startRepos();
    }

    // ── Internal helpers ──────────────────────────────────────────────────────
    function _startHeatmap() {
        if (heatmapProc.running) return;
        heatmapError   = "";
        heatmapLoading = true;
        heatmapProc.running = true;
    }

    function _startActivity() {
        if (activityProc.running) return;
        activityError   = "";
        activityLoading = true;
        activityProc.running = true;
    }

    function _startRepos() {
        if (reposProc.running) return;
        reposError   = "";
        reposLoading = true;
        reposProc.running = true;
    }

    // ── Heatmap process ───────────────────────────────────────────────────────
    Process {
        id: heatmapProc

        // bash -c so the script runs in a login shell that has gh on PATH
        command: ["bash", root._scriptDir + "/github-heatmap.sh"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.heatmapLoading = false;
                const raw = this.text.trim();
                if (!raw) {
                    root.heatmapError = "No output from github-heatmap.sh";
                    return;
                }
                try {
                    const data = JSON.parse(raw);
                    root.username           = data.username           || "";
                    root.totalContributions = data.total_contributions || 0;
                    root.days               = data.days               || [];
                    root.heatmapReady       = true;
                    root.heatmapError       = "";
                } catch (e) {
                    root.heatmapError = "Parse error: " + e;
                    console.warn("[Github] heatmap parse error:", e, "\nraw:", raw);
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const msg = this.text.trim();
                if (msg) {
                    root.heatmapError   = msg;
                    root.heatmapLoading = false;
                    console.warn("[Github] heatmap stderr:", msg);
                }
            }
        }
    }

    // ── Activity process ──────────────────────────────────────────────────────
    Process {
        id: activityProc

        command: ["bash", root._scriptDir + "/github-activity.sh"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.activityLoading = false;
                const raw = this.text.trim();
                if (!raw) {
                    root.activityError = "No output from github-activity.sh";
                    return;
                }
                try {
                    const data = JSON.parse(raw);
                    root.activity      = data.activity || [];
                    root.activityReady = true;
                    root.activityError = "";
                } catch (e) {
                    root.activityError = "Parse error: " + e;
                    console.warn("[Github] activity parse error:", e, "\nraw:", raw);
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const msg = this.text.trim();
                if (msg) {
                    root.activityError   = msg;
                    root.activityLoading = false;
                    console.warn("[Github] activity stderr:", msg);
                }
            }
        }
    }

    // ── Repos process ─────────────────────────────────────────────────────────
    Process {
        id: reposProc

        command: ["bash", root._scriptDir + "/github-repos.sh"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.reposLoading = false;
                const raw = this.text.trim();
                if (!raw) {
                    root.reposError = "No output from github-repos.sh";
                    return;
                }
                try {
                    const data = JSON.parse(raw);
                    root.repos      = data.repos || [];
                    root.reposReady = true;
                    root.reposError = "";
                } catch (e) {
                    root.reposError = "Parse error: " + e;
                    console.warn("[Github] repos parse error:", e, "\nraw:", raw);
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const msg = this.text.trim();
                if (msg) {
                    root.reposError   = msg;
                    root.reposLoading = false;
                    console.warn("[Github] repos stderr:", msg);
                }
            }
        }
    }
}
