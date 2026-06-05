#!/usr/bin/env bash
# github-activity.sh
# Fetches recent GitHub public events for the authenticated user.
# Outputs JSON: { activity: [{event_type, description, repo, count, total_commits?, time}] }
# Matches the shape expected by the reference shell.qml activity feed.

set -euo pipefail

# ── Get authenticated username first ─────────────────────────────────────────
USERNAME=$(gh api /user --jq '.login' 2>/dev/null) || {
  printf '{"activity":[]}\n'
  exit 0
}

# ── Fetch recent events (max 30 — GitHub API page 1 limit) ───────────────────
EVENTS=$(gh api "/users/${USERNAME}/events?per_page=30" 2>/dev/null) || {
  printf '{"activity":[]}\n'
  exit 0
}

# ── Process with jq ───────────────────────────────────────────────────────────
# Group consecutive events of the same type + repo, compute relative time,
# and map to the shape the QML widget expects.
#
# Supported event types (matching reference widget icons):
#   PushEvent, PullRequestEvent, IssuesEvent, CreateEvent
# Everything else maps to a generic entry but is still included.

NOW=$(date -u +%s)

echo "$EVENTS" | jq --argjson now "$NOW" '
  # ── Relative time helper (returns a human string) ─────────────────────────
  def reltime(ts):
    ($now - (ts | split("Z")[0] | strptime("%Y-%m-%dT%H:%M:%S") | mktime)) as $diff |
    if   $diff < 60        then "just now"
    elif $diff < 3600      then (($diff / 60  | floor | tostring) + "m ago")
    elif $diff < 86400     then (($diff / 3600 | floor | tostring) + "h ago")
    elif $diff < 604800    then (($diff / 86400 | floor | tostring) + "d ago")
    else                        (($diff / 604800 | floor | tostring) + "w ago")
    end;

  # ── Description per event type ────────────────────────────────────────────
  def describe(ev):
    if   ev.type == "PushEvent"
    then "pushed \(ev.payload.commits // [] | length) commit(s)"
    elif ev.type == "PullRequestEvent"
    then "\(ev.payload.action // "updated") PR #\(ev.payload.pull_request.number // "")"
    elif ev.type == "IssuesEvent"
    then "\(ev.payload.action // "updated") issue #\(ev.payload.issue.number // "")"
    elif ev.type == "CreateEvent"
    then "created \(ev.payload.ref_type // "ref")"
    elif ev.type == "ForkEvent"
    then "forked repo"
    elif ev.type == "WatchEvent"
    then "starred repo"
    elif ev.type == "DeleteEvent"
    then "deleted \(ev.payload.ref_type // "ref")"
    elif ev.type == "ReleaseEvent"
    then "\(ev.payload.action // "published") release"
    elif ev.type == "IssueCommentEvent"
    then "commented on issue #\(ev.payload.issue.number // "")"
    elif ev.type == "PullRequestReviewEvent"
    then "reviewed PR #\(ev.payload.pull_request.number // "")"
    else ev.type
    end;

  # ── Total commits for PushEvents ─────────────────────────────────────────
  def total_commits(ev):
    if ev.type == "PushEvent"
    then { total_commits: (ev.payload.commits // [] | length) }
    else {}
    end;

  # ── Build activity array ──────────────────────────────────────────────────
  # Group by (type, repo) to collapse repeated events, take top 15 groups
  [
    group_by(.type + "|" + .repo.name)[] |
    (.[0]) as $first |
    (length) as $count |
    {
      event_type:  $first.type,
      description: describe($first),
      repo:        ($first.repo.name | split("/")[1]),   # strip "user/" prefix
      count:       $count,
      time:        reltime($first.created_at)
    } + total_commits($first)
  ]
  | sort_by(.time)           # most recent first (strings sort: "1m" < "2h" is wrong,
  | .[:15]                   # so we just take first 15 after grouping; order is API order)
  | { activity: . }
'
