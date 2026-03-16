#!/bin/bash
# main ブランチでの直接コミットをブロックする
# すべての変更はブランチ → PR 経由で行うルールを物理的に強制する

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# git commit コマンド以外はスルー
if [[ "$COMMAND" != git\ commit* ]]; then
  exit 0
fi

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
if [[ "$CURRENT_BRANCH" == "main" ]]; then
  echo "ブロック: main ブランチへの直接コミットは禁止されています。feature/ または fix/ ブランチを作成してください。" >&2
  exit 2
fi

exit 0
