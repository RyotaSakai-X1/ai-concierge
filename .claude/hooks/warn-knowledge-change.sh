#!/bin/bash
# knowledge/ 配下のファイルが変更されたときに警告を出す
# ルール系ファイルの変更は意図的かどうか確認を促す

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# knowledge/ 配下の変更でなければスルー
if [[ "$FILE_PATH" != */knowledge/* ]]; then
  exit 0
fi

FILENAME=$(basename "$FILE_PATH")
echo "⚠️ knowledge/ のファイルが変更されました: $FILENAME — ルールやテンプレートの変更は影響範囲が大きいので注意してください。" >&2
exit 0
