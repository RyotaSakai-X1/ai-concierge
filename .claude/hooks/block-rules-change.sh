#!/bin/bash
# .claude/rules/ 配下のファイルが Claude によって変更された場合にブロックする
# ルールの変更は人間の責務であり、AI が勝手に書き換えてはいけない

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# .claude/rules/ 配下の変更でなければスルー
if [[ "$FILE_PATH" != */.claude/rules/* ]]; then
  exit 0
fi

FILENAME=$(basename "$FILE_PATH")
echo "ブロック: .claude/rules/ のファイル ($FILENAME) は人間が管理するファイルです。Claude による直接変更は許可されていません。" >&2
exit 2
