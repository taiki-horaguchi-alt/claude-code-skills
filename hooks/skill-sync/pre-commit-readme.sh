#!/bin/bash
# Git pre-commit hook: skills/ に変更があればREADMEを自動再生成
#
# インストール:
#   ln -sf ../../hooks/skill-sync/pre-commit-readme.sh .git/hooks/pre-commit

REPO_DIR="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_DIR/hooks/skill-sync"

# staged files に skills/ の変更があるかチェック
if git diff --cached --name-only | grep -q '^skills/'; then
  echo "[pre-commit] skills/ changed, regenerating README.md..."
  bash "$SCRIPT_DIR/generate-readme.sh"
  git add README.md
  echo "[pre-commit] README.md updated and staged."
fi
