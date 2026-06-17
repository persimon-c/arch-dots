#!/usr/bin/env bash
# scripts/todo-helper.sh
# Manages a simple todo list in ~/.config/quickshell/data/tasks.json using jq.

set -euo pipefail

DB_FILE="/home/simone/.config/quickshell/data/tasks.json"

init_db() {
  if [[ ! -f "$DB_FILE" || ! -s "$DB_FILE" ]]; then
    mkdir -p "$(dirname "$DB_FILE")"
    echo "[]" > "$DB_FILE"
  fi
}

list_tasks() {
  init_db
  cat "$DB_FILE"
}

add_task() {
  init_db
  local text="$1"
  if [[ -z "$text" ]]; then
    cat "$DB_FILE"
    return
  fi
  local id
  id=$(date +%s%N)
  jq --arg id "$id" --arg text "$text" '. + [{id: $id, text: $text, done: false}]' "$DB_FILE" > "$DB_FILE.tmp"
  mv "$DB_FILE.tmp" "$DB_FILE"
  cat "$DB_FILE"
}

toggle_task() {
  init_db
  local id="$1"
  jq --arg id "$id" 'map(if .id == $id then .done |= not else . end)' "$DB_FILE" > "$DB_FILE.tmp"
  mv "$DB_FILE.tmp" "$DB_FILE"
  cat "$DB_FILE"
}

delete_task() {
  init_db
  local id="$1"
  jq --arg id "$id" 'map(select(.id != $id))' "$DB_FILE" > "$DB_FILE.tmp"
  mv "$DB_FILE.tmp" "$DB_FILE"
  cat "$DB_FILE"
}

ACTION="${1:-list}"

case "$ACTION" in
  list)
    list_tasks
    ;;
  add)
    add_task "${2:-}"
    ;;
  toggle)
    toggle_task "${2:-}"
    ;;
  delete)
    delete_task "${2:-}"
    ;;
  *)
    echo "Usage: $0 {list|add|toggle|delete} [args]" >&2
    exit 1
    ;;
esac
