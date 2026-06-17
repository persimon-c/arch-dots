#!/usr/bin/env bash
# scripts/weather.sh
# Fetches current weather from wttr.in and returns it as a clean JSON.
# Format: { "emoji": "🌦️", "temp": "+31°C", "wind": "9km/h", "desc": "Patchy rain nearby" }

set -euo pipefail

CACHE_FILE="/tmp/quickshell-weather.cache"
CACHE_TTL=1800 # 30 mins

get_weather() {
  local raw
  raw=$(curl -s --max-time 5 "wttr.in/?format=%c;%t;%w;%C" || echo "")
  if [[ -n "$raw" && "$raw" == *";"* ]]; then
    raw=$(echo "$raw" | tr -s ' ')
    echo "$raw" > "$CACHE_FILE"
    echo "$raw"
  else
    if [[ -f "$CACHE_FILE" ]]; then
      cat "$CACHE_FILE"
    else
      echo "❓;N/A;N/A;Unknown"
    fi
  fi
}

if [[ -f "$CACHE_FILE" ]]; then
  MOD_TIME=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo "0")
  CUR_TIME=$(date +%s)
  if (( CUR_TIME - MOD_TIME < CACHE_TTL )); then
    RAW_DATA=$(cat "$CACHE_FILE")
  else
    RAW_DATA=$(get_weather)
  fi
else
  RAW_DATA=$(get_weather)
fi

IFS=';' read -r EMOJI TEMP WIND DESC <<< "$RAW_DATA"

EMOJI=$(echo "${EMOJI:-❓}" | xargs)
TEMP=$(echo "${TEMP:-N/A}" | xargs)
WIND=$(echo "${WIND:-N/A}" | xargs)
DESC=$(echo "${DESC:-Unknown}" | xargs)

# Output JSON
jq -n \
  --arg emoji "$EMOJI" \
  --arg temp "$TEMP" \
  --arg wind "$WIND" \
  --arg desc "$DESC" \
  '{emoji: $emoji, temp: $temp, wind: $wind, desc: $desc}'
