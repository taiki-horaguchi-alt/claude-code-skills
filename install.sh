#!/bin/bash
# Claude Code Skills & Hooks Installer
# - Skills: symlinks to ~/.claude/skills/
# - Hooks: registers hook scripts in ~/.claude/settings.json

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"
HOOKS_SRC="$SCRIPT_DIR/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"

FORCE=false
[ "$1" = "--force" ] && FORCE=true

# ─── Skills ───────────────────────────────────────────────
mkdir -p "$SKILLS_DST"

echo "=== Installing Skills ==="
echo "Source: $SKILLS_SRC"
echo "Target: $SKILLS_DST"
echo ""

skill_count=0
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DST/$skill_name"

  if $FORCE; then
    rm -rf "$target"
    ln -s "$skill_dir" "$target"
    echo "  [link] $skill_name"
    skill_count=$((skill_count + 1))
  elif [ -L "$target" ]; then
    echo "  [skip] $skill_name (symlink exists)"
  elif [ -d "$target" ]; then
    echo "  [skip] $skill_name (directory exists, use --force)"
  else
    ln -s "$skill_dir" "$target"
    echo "  [link] $skill_name"
    skill_count=$((skill_count + 1))
  fi
done

echo ""
echo "$skill_count skills installed."

# ─── Hooks ────────────────────────────────────────────────
echo ""
echo "=== Installing Hooks ==="

if [ ! -d "$HOOKS_SRC" ]; then
  echo "No hooks directory found, skipping."
  exit 0
fi

# Ensure settings.json exists
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "{}" > "$SETTINGS_FILE"
fi

hook_count=0

# session-log: Stop hook
SESSION_LOG_SCRIPT="$HOOKS_SRC/session-log/save-session-log.sh"
if [ -f "$SESSION_LOG_SCRIPT" ]; then
  chmod +x "$SESSION_LOG_SCRIPT"

  # Check if hook already registered
  if grep -q "save-session-log.sh" "$SETTINGS_FILE" 2>/dev/null && ! $FORCE; then
    echo "  [skip] session-log (already registered)"
  else
    # Use node to safely merge hook into settings.json
    node -e "
      const fs = require('fs');
      const settings = JSON.parse(fs.readFileSync('$SETTINGS_FILE', 'utf8'));

      if (!settings.hooks) settings.hooks = {};
      if (!settings.hooks.Stop) settings.hooks.Stop = [];

      // Remove existing session-log hook if force
      settings.hooks.Stop = settings.hooks.Stop.filter(
        s => !JSON.stringify(s).includes('save-session-log.sh')
      );

      settings.hooks.Stop.push({
        matcher: '',
        hooks: [{
          type: 'command',
          command: 'bash $SESSION_LOG_SCRIPT'
        }]
      });

      fs.writeFileSync('$SETTINGS_FILE', JSON.stringify(settings, null, 2));
    "
    echo "  [registered] session-log (Stop hook)"
    hook_count=$((hook_count + 1))
  fi
fi

echo ""
echo "$hook_count hooks installed."
echo ""
echo "Done! Use --force to overwrite existing."
