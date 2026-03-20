#!/bin/bash
# Claude Code Skills & Hooks Uninstaller
# - Skills: removes symlinks from ~/.claude/skills/
# - Hooks: removes hook entries from ~/.claude/settings.json

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"
HOOKS_SRC="$SCRIPT_DIR/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"

# ─── Skills ───────────────────────────────────────────────
echo "=== Uninstalling Skills ==="

skill_count=0
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DST/$skill_name"

  if [ -L "$target" ]; then
    rm "$target"
    echo "  [removed] $skill_name"
    skill_count=$((skill_count + 1))
  else
    echo "  [skip] $skill_name (not a symlink)"
  fi
done

echo "$skill_count skills removed."

# ─── Hooks ────────────────────────────────────────────────
echo ""
echo "=== Uninstalling Hooks ==="

hook_count=0

if [ -f "$SETTINGS_FILE" ]; then
  # Remove session-log hook
  if grep -q "save-session-log.sh" "$SETTINGS_FILE" 2>/dev/null; then
    node -e "
      const fs = require('fs');
      const settings = JSON.parse(fs.readFileSync('$SETTINGS_FILE', 'utf8'));

      if (settings.hooks && settings.hooks.Stop) {
        settings.hooks.Stop = settings.hooks.Stop.filter(
          s => !JSON.stringify(s).includes('save-session-log.sh')
        );
        if (settings.hooks.Stop.length === 0) delete settings.hooks.Stop;
        if (Object.keys(settings.hooks).length === 0) delete settings.hooks;
      }

      fs.writeFileSync('$SETTINGS_FILE', JSON.stringify(settings, null, 2));
    "
    echo "  [removed] session-log (Stop hook)"
    hook_count=$((hook_count + 1))
  else
    echo "  [skip] session-log (not found)"
  fi
fi

echo "$hook_count hooks removed."
echo ""
echo "Done!"
