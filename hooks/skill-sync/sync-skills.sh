#!/bin/bash
# PostToolUse hook: スキルが追加/更新されたら自動でGitHubにプッシュ
#
# 環境変数:
#   CLAUDE_TOOL_INPUT - Write ツールの入力JSON (file_path, content)

SKILLS_SRC="$HOME/.claude/skills"
REPO_DIR="$HOME/Dev/claude-code-skills"
REPO_SKILLS="$REPO_DIR/skills"
LOG_FILE="$REPO_DIR/hooks/skill-sync/sync.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Write ツールの file_path を取得
FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('file_path',''))" 2>/dev/null)

# .claude/skills/ 配下のファイルかチェック
if [[ "$FILE_PATH" != *"/.claude/skills/"* && "$FILE_PATH" != *"\\.claude\\skills\\"* ]]; then
  exit 0
fi

log "Skill file changed: $FILE_PATH"

# スキル名を抽出 (例: ~/.claude/skills/my-skill/SKILL.md → my-skill)
SKILL_NAME=$(echo "$FILE_PATH" | sed -E 's|.*[/\\].claude[/\\]skills[/\\]([^/\\]+).*|\1|')
log "Skill detected: $SKILL_NAME"

# リポジトリのskillsディレクトリにコピー
mkdir -p "$REPO_SKILLS/$SKILL_NAME"
cp -r "$SKILLS_SRC/$SKILL_NAME/"* "$REPO_SKILLS/$SKILL_NAME/" 2>/dev/null

# Git操作
cd "$REPO_DIR" || exit 1

git add "skills/$SKILL_NAME/" 2>> "$LOG_FILE"

# 変更があるかチェック
if git diff --cached --quiet; then
  log "No changes to commit for $SKILL_NAME"
  exit 0
fi

git commit -m "feat: sync skill '$SKILL_NAME'" 2>> "$LOG_FILE"
log "Committed skill: $SKILL_NAME"

# README.md を自動再生成
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/generate-readme.sh" 2>> "$LOG_FILE"
git add README.md 2>> "$LOG_FILE"
if ! git diff --cached --quiet; then
  git commit -m "docs: update README (auto-generated)" 2>> "$LOG_FILE"
  log "README updated"
fi

# バックグラウンドでpush（hookの実行時間を短縮）
git push origin master >> "$LOG_FILE" 2>&1 &
log "Push initiated for $SKILL_NAME"
