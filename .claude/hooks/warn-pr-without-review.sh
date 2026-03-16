#!/bin/bash
# gh pr create 実行前に /reviewing を実行したか警告する
# 完全な検出は困難なため、ブロックではなく警告に留める

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# gh pr create コマンド以外はスルー
if [[ "$COMMAND" != gh\ pr\ create* ]]; then
  exit 0
fi

echo "⚠️ PR 作成前にセルフレビュー（/reviewing）は実施しましたか？ Git ワークフローでは PR 作成前のレビューが必須です。" >&2
exit 0
