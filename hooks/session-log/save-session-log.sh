#!/bin/bash
# Save Claude Code session log automatically on session end
# Triggered by Stop hook - copies one file per session, minimal load

set -e

LOG_DIR="$HOME/Dev/.claude-logs"
SOURCE_DIR="$HOME/.claude/projects"

mkdir -p "$LOG_DIR"

# Find the most recently modified JSONL (current session)
SESSION_FILE=$(find "$SOURCE_DIR" -name "*.jsonl" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

if [ -z "$SESSION_FILE" ] || [ ! -f "$SESSION_FILE" ]; then
  exit 0
fi

SESSION_ID=$(basename "$SESSION_FILE" .jsonl)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEST_FILE="$LOG_DIR/${TIMESTAMP}_${SESSION_ID}.jsonl"

# Skip if already saved (idempotent)
if ls "$LOG_DIR"/*_${SESSION_ID}.jsonl &>/dev/null; then
  exit 0
fi

cp "$SESSION_FILE" "$DEST_FILE"
echo "Session log saved: $DEST_FILE"
