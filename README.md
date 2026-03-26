# Claude Code Skills & Hooks

<!-- AUTO-GENERATED: generate-readme.sh で自動生成。手動編集しないでください -->

Claude Code のカスタムスキル (`~/.claude/skills/`) と自動フック集。

**29 skills** | **2 hooks**

---

## Skills 一覧

| # | Skill | Command | Description | Lines |
|---|-------|---------|-------------|-------|
| 1 | [backend-patterns](skills/backend-patterns/) |  | Backend architecture patterns, API design, database optimization, and server-side best practices for Node.js, Express, and Next.js API routes. | 587 |
| 2 | [clickhouse-io](skills/clickhouse-io/) |  | ClickHouse database patterns, query optimization, analytics, and data engineering best practices for high-performance analytical workloads. | 429 |
| 3 | [coding-standards](skills/coding-standards/) |  | Universal coding standards, best practices, and patterns for TypeScript, JavaScript, React, and Node.js development. | 520 |
| 4 | [continuous-learning-v2](skills/continuous-learning-v2/) |  | Instinct-based learning system that observes sessions via hooks, creates atomic instincts with confidence scoring, and evolves them into skills/commands/agents. | 257 |
| 5 | [continuous-learning](skills/continuous-learning/) |  | Automatically extract reusable patterns from Claude Code sessions and save them as learned skills for future use. | 110 |
| 6 | [creator-marketing-system](skills/creator-marketing-system/) | `/creator-marketing-system` | クリエイター（配信者、ブロガー、起業家）がゼロからオーディエンスを構築するための対話型マーケティング戦略フレームワーク。段階的に質問を投げかけ、事業計画書（Markdown）を生成する。 | 74 |
| 7 | [diary](skills/diary/) |  | 今日の日付で日記テンプレートファイルを作成する | 80 |
| 8 | [eval-harness](skills/eval-harness/) |  | Formal evaluation framework for Claude Code sessions implementing eval-driven development (EDD) principles | 227 |
| 9 | [frontend-patterns](skills/frontend-patterns/) |  | Frontend development patterns for React, Next.js, state management, performance optimization, and UI best practices. | 631 |
| 10 | [golang-patterns](skills/golang-patterns/) |  | Idiomatic Go patterns, best practices, and conventions for building robust, efficient, and maintainable Go applications. | 673 |
| 11 | [golang-testing](skills/golang-testing/) |  | Go testing patterns including table-driven tests, subtests, benchmarks, fuzzing, and test coverage. Follows TDD methodology with idiomatic Go practices. | 719 |
| 12 | [iterative-retrieval](skills/iterative-retrieval/) |  | Pattern for progressively refining context retrieval to solve the subagent context problem | 202 |
| 13 | [multi-agent-orchestrator](skills/multi-agent-orchestrator/) | `/multi-agent` | タスクを分析し、最適なエージェント構成を自動選定して並列実行するマルチエージェントオーケストレーター | 288 |
| 14 | [multi-stage-research](skills/multi-stage-research/) | `/research` | 複数のサブエージェントで並列調査→統合→ファクトチェック→最終レポート生成の多段階リサーチを実行する | 144 |
| 15 | [news-insight](skills/news-insight/) |  | ネットニュースのURLを深掘りリサーチし、自分や他者の状況に活かせるインサイトと実装プランを生成する。共有可能なレポート出力対応 | 393 |
| 16 | [postgres-patterns](skills/postgres-patterns/) |  | PostgreSQL database patterns for query optimization, schema design, indexing, and security. Based on Supabase best practices. | 146 |
| 17 | [project-guidelines-example](skills/project-guidelines-example/) |  | - | 345 |
| 18 | [security-review](skills/security-review/) |  | Use this skill when adding authentication, handling user input, working with secrets, creating API endpoints, or implementing payment/sensitive features. Provides comprehensive security checklist and patterns. | 494 |
| 19 | [skill-finder](skills/skill-finder/) | `/skill-find` | 会話の文脈から最適なスキル・コマンドを推論し、使用頻度と効果予測でランク付けして提案する「スキルを探すスキル」 | 92 |
| 20 | [strategic-compact](skills/strategic-compact/) |  | Suggests manual context compaction at logical intervals to preserve context through task phases rather than arbitrary auto-compaction. | 63 |
| 21 | [survey-reader](skills/survey-reader/) | `/survey-read` | Supabaseに保存されたアンケート結果・顧客データを読み込み、マーケティング活用のための分析を行う | 128 |
| 22 | [tdd-workflow](skills/tdd-workflow/) |  | Use this skill when writing new features, fixing bugs, or refactoring code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests. | 409 |
| 23 | [verification-loop](skills/verification-loop/) |  | - | 120 |
| 24 | [worker-assignment](skills/worker-assignment/) | `/assign-workers` | 設計書のタスクに作業者（ツール＋モデル）を自動割り当てし、コスト見積もりを付与する。既存設計書の更新にも対応。 | 119 |
| 25 | [x-daily](skills/x-daily/) | `/x-daily` | 自分のX（旧Twitter）アカウントの直近投稿データを取得・分析し、日次パフォーマンスレポートを生成する | 102 |
| 26 | [x-image](skills/x-image/) | `/x-image` | X投稿に添付する画像のプロンプト生成・画像仕様を設計する | 88 |
| 27 | [x-manager](skills/x-manager/) | `/x-manager` | X（旧Twitter）運用に関する複数スキル（x-daily, x-trend, x-writing, x-image）を統括し、ワンストップで実行するマネージャープラグイン | 121 |
| 28 | [x-trend](skills/x-trend/) | `/x-trend` | X（旧Twitter）の競合アカウントやトレンドデータを分析し、市場動向レポートを生成する | 98 |
| 29 | [x-writing](skills/x-writing/) | `/x-write` | 分析・リサーチ結果を踏まえてX（旧Twitter）投稿用の文章を生成する | 89 |

---

## Hooks 一覧

| Hook | Description |
|------|-------------|
| [session-log](hooks/session-log/) | Save Claude Code session log automatically on session end |
| [skill-sync](hooks/skill-sync/) | スキル一覧からREADME.mdを自動生成する |

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
