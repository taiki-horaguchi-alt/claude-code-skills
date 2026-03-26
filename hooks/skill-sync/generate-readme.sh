#!/bin/bash
# スキル一覧からREADME.mdを自動生成する
# SKILL.md のフロントマターから name, description, command を抽出

REPO_DIR="$HOME/Dev/claude-code-skills"
SKILLS_DIR="$REPO_DIR/skills"
README="$REPO_DIR/README.md"

# フロントマターからフィールドを抽出
extract_field() {
  local file="$1"
  local field="$2"
  sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | sed "s/^${field}:[[:space:]]*//"
}

# スキル情報を収集
declare -a SKILL_ENTRIES=()

for skill_dir in "$SKILLS_DIR"/*/; do
  [ ! -d "$skill_dir" ] && continue
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  if [ -f "$skill_file" ]; then
    name=$(extract_field "$skill_file" "name")
    desc=$(extract_field "$skill_file" "description")
    cmd=$(extract_field "$skill_file" "command")
    [ -z "$name" ] && name="$skill_name"
    [ -z "$desc" ] && desc="-"
  else
    name="$skill_name"
    desc="-"
    cmd=""
  fi

  # ファイルサイズ（行数）
  lines=$(wc -l < "$skill_file" 2>/dev/null || echo "0")

  SKILL_ENTRIES+=("$skill_name|$name|$desc|$cmd|$lines")
done

# スキル数カウント
total=${#SKILL_ENTRIES[@]}
with_cmd=0
for entry in "${SKILL_ENTRIES[@]}"; do
  cmd=$(echo "$entry" | cut -d'|' -f4)
  [ -n "$cmd" ] && ((with_cmd++))
done

# Hook情報を収集
declare -a HOOK_ENTRIES=()
for hook_dir in "$REPO_DIR/hooks"/*/; do
  [ ! -d "$hook_dir" ] && continue
  hook_name=$(basename "$hook_dir")
  # 簡易説明をスクリプトの2行目コメントから取得
  main_script=$(ls "$hook_dir"/*.sh 2>/dev/null | head -1)
  if [ -n "$main_script" ]; then
    hook_desc=$(sed -n '2s/^#[[:space:]]*//p' "$main_script")
  else
    hook_desc="-"
  fi
  HOOK_ENTRIES+=("$hook_name|$hook_desc")
done

# README生成
cat > "$README" << 'HEADER'
# Claude Code Skills & Hooks

<!-- AUTO-GENERATED: generate-readme.sh で自動生成。手動編集しないでください -->

Claude Code のカスタムスキル (`~/.claude/skills/`) と自動フック集。

HEADER

# サマリー
cat >> "$README" << EOF
**${total} skills** | **${#HOOK_ENTRIES[@]} hooks**

---

## Skills 一覧

| # | Skill | Command | Description | Lines |
|---|-------|---------|-------------|-------|
EOF

# スキルをソートして出力
i=1
IFS=$'\n' sorted=($(for entry in "${SKILL_ENTRIES[@]}"; do echo "$entry"; done | sort))
unset IFS

for entry in "${sorted[@]}"; do
  skill_name=$(echo "$entry" | cut -d'|' -f1)
  name=$(echo "$entry" | cut -d'|' -f2)
  desc=$(echo "$entry" | cut -d'|' -f3)
  cmd=$(echo "$entry" | cut -d'|' -f4)
  lines=$(echo "$entry" | cut -d'|' -f5 | tr -d ' ')

  cmd_display=""
  [ -n "$cmd" ] && cmd_display="\`${cmd}\`"

  echo "| ${i} | [${name}](skills/${skill_name}/) | ${cmd_display} | ${desc} | ${lines} |" >> "$README"
  ((i++))
done

# Hooks セクション
cat >> "$README" << 'EOF'

---

## Hooks 一覧

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

### 全スキルをインストール

```bash
git clone https://github.com/taiki-horaguchi-alt/claude-code-skills.git
cd claude-code-skills
bash install.sh
```

### 個別スキルをインストール

```bash
cp -r skills/<skill-name> ~/.claude/skills/
```

### アンインストール

```bash
bash uninstall.sh
```

## スキルの管理

### 追加
`~/.claude/skills/` にスキルを追加すると、PostToolUse hookで自動的にこのリポジトリに同期・プッシュされます。

### 削除
1. `~/.claude/skills/<skill-name>/` を削除
2. `skills/<skill-name>/` をこのリポジトリからも削除
3. コミット＆プッシュ

### 構造

```
skill-name/
└── SKILL.md    # フロントマター（name, description, command）+ 指示
```

## License

MIT
FOOTER
