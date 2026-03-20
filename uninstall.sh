#!/bin/bash
# Claude Code Skills Uninstaller
# Removes symlinks created by install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

echo "Uninstalling Claude Code skills..."

count=0
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DST/$skill_name"

  if [ -L "$target" ]; then
    rm "$target"
    echo "  [removed] $skill_name"
    count=$((count + 1))
  else
    echo "  [skip] $skill_name (not a symlink)"
  fi
done

echo ""
echo "Done! $count symlinks removed."
