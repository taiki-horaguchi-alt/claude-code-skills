# session-log

Claude Codeのセッション終了時に会話ログを自動保存するStop hook。

## 概要

- **トリガー**: セッション終了時 (Stop hook)
- **保存先**: `~/Dev/.claude-logs/`
- **ファイル名**: `YYYYMMDD_HHMMSS_<session-id>.jsonl`
- **負荷**: 1ファイルコピーのみ（瞬時完了）
- **重複防止**: 同じセッションIDは2回保存しない

## インストール

`install.sh` で自動設定されます。手動で設定する場合は `~/.claude/settings.json` に以下を追加:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash <path-to>/save-session-log.sh"
          }
        ]
      }
    ]
  }
}
```

## 動機

過去の会話履歴を一括処理するとPC負荷が高くなる。
セッションごとに1ファイルずつ自動保存することで、負荷ゼロで履歴を蓄積できる。
