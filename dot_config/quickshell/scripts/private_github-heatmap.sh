#!/usr/bin/env bash
# github-heatmap.sh
# Fetches GitHub contribution heatmap for the authenticated user via gh CLI GraphQL.
# Outputs JSON: { username, total_contributions, days: [{date, count, level}] }
# Level 0–4 computed using GitHub's relative quartile method (based on max contributions in period).

set -euo pipefail

# ── Fetch username + contribution calendar ────────────────────────────────────
RAW=$(gh api graphql -f query='
{
  viewer {
    login
    contributionsCollection {
      contributionCalendar {
        totalContributions
        weeks {
          contributionDays {
            date
            contributionCount
          }
        }
      }
    }
  }
}') || {
  # gh not available or not authenticated — emit a safe fallback
  printf '{"username":"unknown","total_contributions":0,"days":[]}\n'
  exit 0
}

# ── Process with jq ───────────────────────────────────────────────────────────
# Level computation (matches GitHub's own site):
#   0  → 0 contributions
#   1  → 1 .. floor(max * 0.25)
#   2  → floor(max * 0.25)+1 .. floor(max * 0.50)
#   3  → floor(max * 0.50)+1 .. floor(max * 0.75)
#   4  → floor(max * 0.75)+1 .. max
# If max == 0, all days are level 0.

echo "$RAW" | jq '
  .data.viewer as $v |
  ($v.contributionsCollection.contributionCalendar) as $cal |

  # Flatten all days into one array
  [ $cal.weeks[].contributionDays[] ] as $allDays |

  # Find max contributions in the period (avoid division by zero)
  ([ $allDays[].contributionCount ] | max) as $max |
  (if $max == 0 then 1 else $max end) as $safeMax |

  # Quartile thresholds (integer floors)
  ($safeMax * 0.25 | floor) as $q1 |
  ($safeMax * 0.50 | floor) as $q2 |
  ($safeMax * 0.75 | floor) as $q3 |

  {
    username: $v.login,
    total_contributions: $cal.totalContributions,
    days: [
      $allDays[] |
      . as $day |
      ($day.contributionCount) as $c |
      {
        date:  $day.date,
        count: $c,
        level: (
          if $c == 0         then 0
          elif $c <= $q1     then 1
          elif $c <= $q2     then 2
          elif $c <= $q3     then 3
          else                    4
          end
        )
      }
    ]
  }
'
