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

# ── Language mapping helper ───────────────────────────────────────────────────
map_lang() {
  local ext="${1:-}"
  case "$ext" in
    qml) echo "QML" ;;
    js)  echo "JavaScript" ;;
    ts)  echo "TypeScript" ;;
    py)  echo "Python" ;;
    go)  echo "Go" ;;
    rs)  echo "Rust" ;;
    cpp|cc|cxx) echo "C++" ;;
    c)   echo "C" ;;
    h|hpp)  echo "Header" ;;
    java) echo "Java" ;;
    sh)  echo "Shell" ;;
    lua) echo "Lua" ;;
    css) echo "CSS" ;;
    html) echo "HTML" ;;
    json) echo "JSON" ;;
    md)  echo "Markdown" ;;
    yml|yaml) echo "YAML" ;;
    rb)  echo "Ruby" ;;
    php) echo "PHP" ;;
    cs)  echo "C#" ;;
    swift) echo "Swift" ;;
    kt)  echo "Kotlin" ;;
    *)   # Capitalize first letter (bash 4+)
         echo "${ext^}" ;;
  esac
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

  # Commits count
  COMMITS_COUNT=$(git -C "$REPO_PATH" rev-list --count HEAD 2>/dev/null || echo "0")

  # File counts
  MODIFIED_COUNT=$(git -C "$REPO_PATH" diff --name-only 2>/dev/null | wc -l || echo "0")
  STAGED_COUNT=$(git -C "$REPO_PATH" diff --cached --name-only 2>/dev/null | wc -l || echo "0")
  UNTRACKED_COUNT=$(git -C "$REPO_PATH" ls-files --others --exclude-standard 2>/dev/null | wc -l || echo "0")

  # Size
  REPO_SIZE=$(du -sh "$REPO_PATH" 2>/dev/null | cut -f1 || echo "0B")

  # Active branches & tags count
  BRANCHES_COUNT=$(git -C "$REPO_PATH" branch --list 2>/dev/null | wc -l || echo "0")
  TAGS_COUNT=$(git -C "$REPO_PATH" tag 2>/dev/null | wc -l || echo "0")

  # Sync status (ahead/behind tracking branch)
  AHEAD_COUNT="0"
  BEHIND_COUNT="0"
  TRACKING=$(git -C "$REPO_PATH" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)
  if [[ -n "$TRACKING" ]]; then
    AHEAD_COUNT=$(git -C "$REPO_PATH" rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    BEHIND_COUNT=$(git -C "$REPO_PATH" rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
  fi

  # Primary language
  LANG_EXT=$(find "$REPO_PATH" -maxdepth 3 -type f -not -path '*/.*' -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/build/*' -not -path '*/dist/*' -not -path '*/.venv/*' 2>/dev/null | grep -E '\.([a-zA-Z0-9]+)$' | awk -F. '{print $NF}' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}' || true)
  PRIMARY_LANG=$(map_lang "$LANG_EXT")

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
    --argjson commits "$COMMITS_COUNT" \
    --argjson modified "$MODIFIED_COUNT" \
    --argjson staged   "$STAGED_COUNT" \
    --argjson untracked "$UNTRACKED_COUNT" \
    --arg size       "$REPO_SIZE" \
    --argjson branches "$BRANCHES_COUNT" \
    --argjson tags     "$TAGS_COUNT" \
    --argjson ahead    "$AHEAD_COUNT" \
    --argjson behind   "$BEHIND_COUNT" \
    --arg lang       "$PRIMARY_LANG" \
    '{
      name:             $name,
      path:             $path,
      branch:           $branch,
      last_commit_msg:  $msg,
      last_commit_time: $ts,
      last_commit_rel:  $rel,
      dirty:            $dirty,
      remote_url:       $url,
      commits_count:    $commits,
      modified_count:   $modified,
      staged_count:     $staged,
      untracked_count:  $untracked,
      size:             $size,
      branches_count:   $branches,
      tags_count:       $tags,
      ahead_count:      $ahead,
      behind_count:     $behind,
      primary_lang:     $lang
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
