#!/bin/bash
# Claude Code Skills Installer
# Creates symlinks from this repo to ~/.claude/skills/

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

mkdir -p "$SKILLS_DST"

echo "Installing Claude Code skills..."
echo "Source: $SKILLS_SRC"
echo "Target: $SKILLS_DST"
echo ""

count=0
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DST/$skill_name"

  if [ -L "$target" ]; then
    echo "  [skip] $skill_name (symlink exists)"
  elif [ -d "$target" ]; then
    echo "  [skip] $skill_name (directory exists, use --force to overwrite)"
  else
    ln -s "$skill_dir" "$target"
    echo "  [link] $skill_name"
    count=$((count + 1))
  fi
done

echo ""
echo "Done! $count skills installed."
echo ""
echo "To force overwrite existing skills, run:"
echo "  bash install.sh --force"

if [ "$1" = "--force" ]; then
  echo ""
  echo "Force mode: removing existing and re-linking..."
  for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    target="$SKILLS_DST/$skill_name"
    rm -rf "$target"
    ln -s "$skill_dir" "$target"
    echo "  [link] $skill_name"
  done
  echo "All skills force-installed."
fi
