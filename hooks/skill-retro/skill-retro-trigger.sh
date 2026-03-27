#!/bin/bash
# Skill Retrospective Trigger - Stop Hook
# セッション終了時にスキル使用状況を検出し、レトロスペクティブを発動する
#
# 動作:
# 1. 最新セッションJSONLからSkill tool呼び出しを抽出
# 2. スキルが使われていた場合、Claudeにレトロスペクティブ実行を指示するメッセージを返す
# 3. スキル未使用なら無言で終了（Claudeは停止する）

set -e

SOURCE_DIR="$HOME/.claude/projects"
RETRO_DIR="$HOME/Dev/.claude-logs/retro"

mkdir -p "$RETRO_DIR"

# 最新セッションJSONLを特定
SESSION_FILE=$(find "$SOURCE_DIR" -name "*.jsonl" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

if [ -z "$SESSION_FILE" ] || [ ! -f "$SESSION_FILE" ]; then
  exit 0
fi

# セッションからスキル呼び出しを抽出
# JSONL format: "name":"Skill","input":{"skill":"skill-name"
# -P が使えないWindows Git Bash対応: -E (ERE) + sed で抽出
SKILLS_USED=$(grep -o '"name":"Skill"[^}]*' "$SESSION_FILE" 2>/dev/null \
  | grep -oE '"skill":"[^"]*"' \
  | sed 's/"skill":"//;s/"//' \
  | sort | uniq -c | sort -rn)

if [ -z "$SKILLS_USED" ]; then
  exit 0
fi

# ツール呼び出し総数（セッションの規模を判定）
TOOL_COUNT=$(grep -c '"tool_use"' "$SESSION_FILE" 2>/dev/null || echo "0")

# 小規模セッション（ツール10回未満）はスキップ
if [ "$TOOL_COUNT" -lt 10 ]; then
  exit 0
fi

# エージェント使用も抽出
AGENTS_USED=$(grep -o '"subagent_type":"[^"]*"' "$SESSION_FILE" 2>/dev/null \
  | sed 's/"subagent_type":"//;s/"//' \
  | sort | uniq -c | sort -rn || true)

# エラー/リトライパターンを検出（スキルが失敗した可能性）
ERROR_SIGNALS=$(grep -c '"is_error":true' "$SESSION_FILE" 2>/dev/null || echo "0")

# タイムスタンプ
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_ID=$(basename "$SESSION_FILE" .jsonl)

# Claudeへのフィードバックメッセージを出力
# Stop hookの出力はClaudeに送信され、会話が継続する
cat <<RETRO_MSG

---
## Skill Retrospective Triggered

このセッションではスキルが使用されました。レトロスペクティブを実行してください。

### セッション情報
- Session ID: ${SESSION_ID}
- Tool calls: ${TOOL_COUNT}
- Error signals: ${ERROR_SIGNALS}

### 使用されたスキル
${SKILLS_USED}

### 使用されたエージェント
${AGENTS_USED:-なし}

### 指示
以下の手順で /skill-retro を実行してください:
1. 上記のスキル・エージェント使用状況を分析
2. 各スキルが目的を達成できたか評価
3. 改善提案・新スキル提案をMDファイルに出力
4. 出力先: ${RETRO_DIR}/${TIMESTAMP}_retro.md

RETRO_MSG
