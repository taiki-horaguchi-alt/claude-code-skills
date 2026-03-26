#!/bin/bash
# Auto-update PROJECT_DASHBOARD.md with latest git activity
# Triggered by: Stop hook (session end)
# Scans all known project dirs, updates last commit dates

set -e

DASHBOARD="/h/マイドライブ/antigravity/scratch/taikihoraguchi/PROJECT_DASHBOARD.md"

if [ ! -f "$DASHBOARD" ]; then
  exit 0
fi

# Project directories to scan
PROJECT_DIRS=(
  "$HOME/Dev/ebay事業"
  "$HOME/Dev/Projects/BRIDGE-Lite"
  "$HOME/Dev/Projects/BRIDGE-app"
  "$HOME/Dev/claude-code-skills"
  "$HOME/Dev/Projects/APE"
  "$HOME/Dev/agritech-market-data"
  "$HOME/Dev/Projects/personal-os"
  "$HOME/Dev/Projects/portfolio"
  "$HOME/Dev/Projects/smart_pantry_tracker"
)

# Collect latest activity per project
REPORT="<!-- AUTO-GENERATED: $(date '+%Y-%m-%d %H:%M') -->\n"
REPORT+="| プロジェクト | 最終コミット | 経過 | コミットメッセージ |\n"
REPORT+="|-------------|-------------|------|------------------|\n"

for dir in "${PROJECT_DIRS[@]}"; do
  name=$(basename "$dir")
  if [ -d "$dir/.git" ]; then
    last_date=$(git -C "$dir" log -1 --format='%ci' 2>/dev/null | cut -d' ' -f1 || echo "N/A")
    last_ago=$(git -C "$dir" log -1 --format='%cr' 2>/dev/null || echo "N/A")
    last_msg=$(git -C "$dir" log -1 --format='%s' 2>/dev/null | head -c 50 || echo "N/A")
    REPORT+="| $name | $last_date | $last_ago | $last_msg |\n"
  else
    REPORT+="| $name | - | git無し | - |\n"
  fi
done

# Update the auto-generated activity section at the bottom of the dashboard
# If section exists, replace it. If not, append it.
MARKER_START="<!-- ACTIVITY-START -->"
MARKER_END="<!-- ACTIVITY-END -->"

if grep -q "$MARKER_START" "$DASHBOARD" 2>/dev/null; then
  # Replace existing section (use temp file for portability)
  tmpfile=$(mktemp)
  awk -v start="$MARKER_START" -v end="$MARKER_END" -v report="$REPORT" '
    $0 ~ start { print; printf "%s", report; skip=1; next }
    $0 ~ end { skip=0 }
    !skip { print }
  ' "$DASHBOARD" > "$tmpfile"
  # Re-add end marker
  sed -i "s|$MARKER_START|$MARKER_START\n|" "$tmpfile" 2>/dev/null
  mv "$tmpfile" "$DASHBOARD"
else
  # Append new section
  {
    echo ""
    echo "---"
    echo ""
    echo "## Git Activity (自動更新)"
    echo ""
    echo "$MARKER_START"
    echo -e "$REPORT"
    echo "$MARKER_END"
  } >> "$DASHBOARD"
fi
