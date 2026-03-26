#!/bin/bash
# スキル一覧からREADME.mdを自動生成する（カテゴリ別表示）
# SKILL.md のフロントマターから name, description, command, category を抽出

REPO_DIR="$HOME/Dev/claude-code-skills"
SKILLS_DIR="$REPO_DIR/skills"
README="$REPO_DIR/README.md"

# カテゴリの表示順序
CATEGORY_ORDER=(
  "ベストプラクティス"
  "開発ワークフロー"
  "X運用"
  "リサーチ・分析"
  "エージェント・学習"
  "ユーティリティ"
)

# フロントマターからフィールドを抽出
extract_field() {
  local file="$1"
  local field="$2"
  sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | sed "s/^${field}:[[:space:]]*//"
}

# スキル情報を収集（category|skill_name|name|desc|cmd|lines）
declare -a SKILL_ENTRIES=()

for skill_dir in "$SKILLS_DIR"/*/; do
  [ ! -d "$skill_dir" ] && continue
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  if [ -f "$skill_file" ]; then
    name=$(extract_field "$skill_file" "name")
    desc=$(extract_field "$skill_file" "description")
    cmd=$(extract_field "$skill_file" "command")
    category=$(extract_field "$skill_file" "category")
    [ -z "$name" ] && name="$skill_name"
    [ -z "$desc" ] && desc="-"
    [ -z "$category" ] && category="その他"
  else
    name="$skill_name"
    desc="-"
    cmd=""
    category="その他"
  fi

  lines=$(wc -l < "$skill_file" 2>/dev/null || echo "0")
  lines=$(echo "$lines" | tr -d ' ')

  SKILL_ENTRIES+=("$category|$skill_name|$name|$desc|$cmd|$lines")
done

total=${#SKILL_ENTRIES[@]}

# Hook情報を収集
declare -a HOOK_ENTRIES=()
for hook_dir in "$REPO_DIR/hooks"/*/; do
  [ ! -d "$hook_dir" ] && continue
  hook_name=$(basename "$hook_dir")
  main_script=$(ls "$hook_dir"/*.sh 2>/dev/null | head -1)
  if [ -n "$main_script" ]; then
    hook_desc=$(sed -n '2s/^#[[:space:]]*//p' "$main_script")
  else
    hook_desc="-"
  fi
  HOOK_ENTRIES+=("$hook_name|$hook_desc")
done

# --- README生成 ---
cat > "$README" << 'HEADER'
# Claude Code Skills & Hooks

<!-- AUTO-GENERATED: generate-readme.sh で自動生成。手動編集しないでください -->

Claude Code のカスタムスキル (`~/.claude/skills/`) と自動フック集。

HEADER

# サマリー + 目次
cat >> "$README" << EOF
**${total} skills** | **${#HOOK_ENTRIES[@]} hooks**

EOF

# 目次生成
echo "### 目次" >> "$README"
for cat_name in "${CATEGORY_ORDER[@]}"; do
  # カテゴリ内のスキル数をカウント
  count=0
  for entry in "${SKILL_ENTRIES[@]}"; do
    entry_cat=$(echo "$entry" | cut -d'|' -f1)
    [ "$entry_cat" = "$cat_name" ] && ((count++))
  done
  [ "$count" -eq 0 ] && continue
  # アンカーリンク用にカテゴリ名を変換
  anchor=$(echo "$cat_name" | sed 's/・/-/g')
  echo "- [${cat_name}](#${anchor})（${count}）" >> "$README"
done

# 「その他」カテゴリがあるかチェック
other_count=0
for entry in "${SKILL_ENTRIES[@]}"; do
  entry_cat=$(echo "$entry" | cut -d'|' -f1)
  found=0
  for cat_name in "${CATEGORY_ORDER[@]}"; do
    [ "$entry_cat" = "$cat_name" ] && found=1
  done
  [ "$found" -eq 0 ] && ((other_count++))
done
[ "$other_count" -gt 0 ] && echo "- [その他](#その他)（${other_count}）" >> "$README"

echo "" >> "$README"
echo "---" >> "$README"
echo "" >> "$README"

# カテゴリ別スキル出力
for cat_name in "${CATEGORY_ORDER[@]}"; do
  # このカテゴリのエントリを収集
  declare -a cat_entries=()
  for entry in "${SKILL_ENTRIES[@]}"; do
    entry_cat=$(echo "$entry" | cut -d'|' -f1)
    [ "$entry_cat" = "$cat_name" ] && cat_entries+=("$entry")
  done

  [ "${#cat_entries[@]}" -eq 0 ] && unset cat_entries && continue

  echo "### ${cat_name}" >> "$README"
  echo "" >> "$README"
  echo "| Skill | Command | Description |" >> "$README"
  echo "|-------|---------|-------------|" >> "$README"

  # スキル名でソート
  IFS=$'\n' sorted_cat=($(for e in "${cat_entries[@]}"; do echo "$e"; done | sort -t'|' -k2))
  unset IFS

  for entry in "${sorted_cat[@]}"; do
    skill_name=$(echo "$entry" | cut -d'|' -f2)
    name=$(echo "$entry" | cut -d'|' -f3)
    desc=$(echo "$entry" | cut -d'|' -f4)
    cmd=$(echo "$entry" | cut -d'|' -f5)

    cmd_display=""
    [ -n "$cmd" ] && cmd_display="\`${cmd}\`"

    echo "| [${name}](skills/${skill_name}/) | ${cmd_display} | ${desc} |" >> "$README"
  done

  echo "" >> "$README"
  unset cat_entries
done

# 「その他」カテゴリ
if [ "$other_count" -gt 0 ]; then
  echo "### その他" >> "$README"
  echo "" >> "$README"
  echo "| Skill | Command | Description |" >> "$README"
  echo "|-------|---------|-------------|" >> "$README"

  for entry in "${SKILL_ENTRIES[@]}"; do
    entry_cat=$(echo "$entry" | cut -d'|' -f1)
    found=0
    for cat_name in "${CATEGORY_ORDER[@]}"; do
      [ "$entry_cat" = "$cat_name" ] && found=1
    done
    [ "$found" -eq 1 ] && continue

    skill_name=$(echo "$entry" | cut -d'|' -f2)
    name=$(echo "$entry" | cut -d'|' -f3)
    desc=$(echo "$entry" | cut -d'|' -f4)
    cmd=$(echo "$entry" | cut -d'|' -f5)

    cmd_display=""
    [ -n "$cmd" ] && cmd_display="\`${cmd}\`"

    echo "| [${name}](skills/${skill_name}/) | ${cmd_display} | ${desc} |" >> "$README"
  done
  echo "" >> "$README"
fi

# Hooks セクション
cat >> "$README" << 'EOF'
---

## Hooks

| Hook | Description |
|------|-------------|
EOF

for entry in "${HOOK_ENTRIES[@]}"; do
  hook_name=$(echo "$entry" | cut -d'|' -f1)
  hook_desc=$(echo "$entry" | cut -d'|' -f2-)
  echo "| [${hook_name}](hooks/${hook_name}/) | ${hook_desc} |" >> "$README"
done

# フッター
cat >> "$README" << 'FOOTER'

---

## セットアップ

```bash
git clone https://github.com/taiki-horaguchi-alt/claude-code-skills.git
cd claude-code-skills
bash install.sh
```

個別インストール: `cp -r skills/<skill-name> ~/.claude/skills/`

## スキルの管理

- **追加**: `~/.claude/skills/` にスキルを作成すると PostToolUse hook で自動同期＆プッシュ
- **削除**: `~/.claude/skills/<name>/` と `skills/<name>/` を両方削除してコミット
- **カテゴリ変更**: SKILL.md のフロントマターの `category` フィールドを編集

```yaml
---
name: my-skill
description: スキルの説明（日本語）
category: ベストプラクティス  # カテゴリ名
command: /my-command           # オプション
---
```

## License

MIT
FOOTER
