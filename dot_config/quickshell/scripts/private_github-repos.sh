#!/usr/bin/env bash
# github-repos.sh
# Scans ~/dev (depth 2) for git repositories and emits metadata for each.
# Outputs JSON: { repos: [{name, path, branch, last_commit_msg, last_commit_time, last_commit_rel, dirty, remote_url}] }
# last_commit_rel is a human-readable relative time string (e.g. "2h ago").
# dirty is true if there are uncommitted changes (staged or unstaged).
# remote_url is the GitHub URL from `git remote get-url origin` (empty string if no remote).

set -euo pipefail

DEV_ROOT="/home/simone/dev"
NOW=$(date -u +%s)

# ── Relative time helper ──────────────────────────────────────────────────────
reltime() {
  local ts="$1"
  local diff=$(( NOW - ts ))
  if   (( diff < 60 ));     then echo "just now"
  elif (( diff < 3600 ));   then echo "$(( diff / 60 ))m ago"
  elif (( diff < 86400 ));  then echo "$(( diff / 3600 ))h ago"
  elif (( diff < 604800 )); then echo "$(( diff / 86400 ))d ago"
  else                           echo "$(( diff / 604800 ))w ago"
  fi
}

# ── Collect repos ─────────────────────────────────────────────────────────────
# find .git dirs up to depth 3 (meaning repo roots are at depth 1 or 2 under DEV_ROOT)
REPOS=()
while IFS= read -r gitdir; do
  REPOS+=("$(dirname "$gitdir")")
done < <(find "$DEV_ROOT" -maxdepth 3 -name ".git" -type d 2>/dev/null)

if [[ ${#REPOS[@]} -eq 0 ]]; then
  printf '{"repos":[]}\n'
  exit 0
fi

# ── Build JSON array ──────────────────────────────────────────────────────────
# Use jq --null-input + --argjson to build cleanly without string escaping issues.

ENTRIES="["
FIRST=true

for REPO_PATH in "${REPOS[@]}"; do
  NAME=$(basename "$REPO_PATH")

  # Branch
  BRANCH=$(git -C "$REPO_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

  # Last commit: message + unix timestamp
  LAST_MSG=$(git -C "$REPO_PATH" log -1 --pretty=format:"%s" 2>/dev/null || echo "")
  LAST_TS=$(git -C "$REPO_PATH" log -1 --pretty=format:"%ct" 2>/dev/null || echo "0")
  LAST_REL=$(reltime "${LAST_TS:-0}")

  # Dirty check: exit code 0 = clean, 1 = dirty
  if git -C "$REPO_PATH" diff --quiet 2>/dev/null && \
     git -C "$REPO_PATH" diff --cached --quiet 2>/dev/null; then
    DIRTY="false"
  else
    DIRTY="true"
  fi

  # Remote URL (origin → convert SSH to HTTPS if needed)
  RAW_URL=$(git -C "$REPO_PATH" remote get-url origin 2>/dev/null || echo "")
  # Convert git@github.com:user/repo.git → https://github.com/user/repo
  if [[ "$RAW_URL" == git@github.com:* ]]; then
    REMOTE_URL="https://github.com/${RAW_URL#git@github.com:}"
    REMOTE_URL="${REMOTE_URL%.git}"
  elif [[ "$RAW_URL" == https://github.com/* ]]; then
    REMOTE_URL="${RAW_URL%.git}"
  else
    REMOTE_URL=""
  fi

  # Escape strings for JSON (jq handles this safely via --arg)
  ENTRY=$(jq -n \
    --arg name       "$NAME" \
    --arg path       "$REPO_PATH" \
    --arg branch     "$BRANCH" \
    --arg msg        "$LAST_MSG" \
    --argjson ts     "${LAST_TS:-0}" \
    --arg rel        "$LAST_REL" \
    --argjson dirty  "$DIRTY" \
    --arg url        "$REMOTE_URL" \
    '{
      name:             $name,
      path:             $path,
      branch:           $branch,
      last_commit_msg:  $msg,
      last_commit_time: $ts,
      last_commit_rel:  $rel,
      dirty:            $dirty,
      remote_url:       $url
    }')

  if [[ "$FIRST" == true ]]; then
    FIRST=false
  else
    ENTRIES+=","
  fi
  ENTRIES+="$ENTRY"
done

ENTRIES+="]"

# Sort by last_commit_time descending (most recently committed first), take top 20
echo "{\"repos\": $ENTRIES}" | jq '{repos: (.repos | sort_by(-.last_commit_time) | .[:20])}'
