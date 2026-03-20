# Claude Code Skills

Claude Code (`~/.claude/skills/`) で使用するカスタムスキル集。

## Skills一覧

### オリジナル

| Skill | Description | Command |
|-------|-------------|---------|
| [worker-assignment](skills/worker-assignment/) | 設計書のタスクに作業者（ツール＋モデル）を自動割り当てし、コスト見積もりを付与 | `/assign-workers` |
| [creator-marketing-system](skills/creator-marketing-system/) | クリエイター向け対話型マーケティング戦略フレームワーク | `/creator-marketing-system` |
| [diary](skills/diary/) | 今日の日付で日記テンプレートファイルを作成 | `/diary` |

### 開発ワークフロー

| Skill | Description |
|-------|-------------|
| [coding-standards](skills/coding-standards/) | TypeScript/JavaScript/React/Node.js のコーディング規約 |
| [tdd-workflow](skills/tdd-workflow/) | TDD（テスト駆動開発）ワークフロー。80%+カバレッジ |
| [eval-harness](skills/eval-harness/) | Claude Codeセッションの評価フレームワーク (EDD) |
| [verification-loop](skills/verification-loop/) | セッション検証システム |
| [security-review](skills/security-review/) | セキュリティチェックリスト・パターン集 |

### 学習・最適化

| Skill | Description |
|-------|-------------|
| [continuous-learning](skills/continuous-learning/) | セッションからパターンを抽出し再利用可能スキルとして保存 |
| [continuous-learning-v2](skills/continuous-learning-v2/) | Instinctベースの学習システム。hooks/agents/commands付き |
| [strategic-compact](skills/strategic-compact/) | コンテキスト圧縮の最適タイミングを提案 |
| [iterative-retrieval](skills/iterative-retrieval/) | サブエージェントのコンテキスト問題を解決する段階的検索 |

### 技術パターン集

| Skill | Description |
|-------|-------------|
| [backend-patterns](skills/backend-patterns/) | Node.js/Express/Next.js バックエンドパターン |
| [frontend-patterns](skills/frontend-patterns/) | React/Next.js フロントエンドパターン |
| [golang-patterns](skills/golang-patterns/) | Go言語のイディオムとベストプラクティス |
| [golang-testing](skills/golang-testing/) | Goテストパターン（テーブル駆動、ベンチマーク、ファジング） |
| [postgres-patterns](skills/postgres-patterns/) | PostgreSQL クエリ最適化・スキーマ設計 |
| [clickhouse-io](skills/clickhouse-io/) | ClickHouse 分析クエリ最適化 |
| [project-guidelines-example](skills/project-guidelines-example/) | プロジェクト固有スキルのテンプレート例 |

## インストール

### 全スキルをインストール

```bash
git clone https://github.com/taiki-horaguchi-alt/claude-code-skills.git
cd claude-code-skills
bash install.sh
```

### 個別スキルをインストール

```bash
# 例: worker-assignment のみ
cp -r skills/worker-assignment ~/.claude/skills/
```

### アンインストール

```bash
bash uninstall.sh
```

## スキルの構造

各スキルは [Agent Skills 仕様](https://github.com/anthropics/skills) に準拠:

```
skill-name/
├── SKILL.md          # メインファイル（YAMLフロントマター + 指示）
├── scripts/          # ヘルパースクリプト（オプション）
├── commands/         # サブコマンド（オプション）
├── agents/           # エージェント定義（オプション）
├── hooks/            # フック（オプション）
└── config.json       # 設定（オプション）
```

## 自作スキルの追加方法

1. `skills/` に新しいディレクトリを作成
2. `SKILL.md` を作成（フロントマター必須）:

```markdown
---
name: my-skill
description: スキルの説明
---

# スキル名

指示内容...
```

3. `install.sh` を実行してシンボリックリンクを更新

## License

MIT
