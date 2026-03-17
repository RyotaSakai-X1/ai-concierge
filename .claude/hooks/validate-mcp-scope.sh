#!/bin/bash
# Layer 2: MCP ツールのスコープ検証フック
# stdin から JSON を読み取り、許可されたスコープ内かチェックする
# exit 0 = 許可, exit 2 = ブロック

set -euo pipefail

SCOPE_FILE="$(dirname "$0")/../security/mcp-scope.json"

# スコープ設定ファイルがなければ pass
if [ ! -f "$SCOPE_FILE" ]; then
  exit 0
fi

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# 対象外のツールは pass
case "$TOOL_NAME" in
  mcp__figma__*)
    ;;
  mcp__google-workspace__list_drive_items)
    ;;
  *)
    exit 0
    ;;
esac

# Figma ツール: fileKey のスコープチェック
if [[ "$TOOL_NAME" == mcp__figma__* ]]; then
  ALLOWED_KEYS=$(jq -r '.allowed_figma_file_keys // [] | length' "$SCOPE_FILE")
  if [ "$ALLOWED_KEYS" -eq 0 ]; then
    exit 0
  fi

  FILE_KEY=$(echo "$INPUT" | jq -r '.tool_input.fileKey // .tool_input.file_key // empty')
  if [ -z "$FILE_KEY" ]; then
    exit 0
  fi

  MATCH=$(jq -r --arg key "$FILE_KEY" '.allowed_figma_file_keys | map(select(. == $key)) | length' "$SCOPE_FILE")
  if [ "$MATCH" -eq 0 ]; then
    echo "ブロック: Figma fileKey '$FILE_KEY' は許可リストに含まれていません。.claude/security/mcp-scope.json の allowed_figma_file_keys に追加してください。" >&2
    exit 2
  fi
fi

# Drive list_drive_items: folder_id のスコープチェック
if [ "$TOOL_NAME" = "mcp__google-workspace__list_drive_items" ]; then
  ALLOWED_FOLDERS=$(jq -r '.allowed_drive_folder_ids // [] | length' "$SCOPE_FILE")
  if [ "$ALLOWED_FOLDERS" -eq 0 ]; then
    exit 0
  fi

  FOLDER_ID=$(echo "$INPUT" | jq -r '.tool_input.folder_id // .tool_input.folderId // empty')
  if [ -z "$FOLDER_ID" ]; then
    exit 0
  fi

  MATCH=$(jq -r --arg id "$FOLDER_ID" '.allowed_drive_folder_ids | map(select(. == $id)) | length' "$SCOPE_FILE")
  if [ "$MATCH" -eq 0 ]; then
    echo "ブロック: Drive folder_id '$FOLDER_ID' は許可リストに含まれていません。.claude/security/mcp-scope.json の allowed_drive_folder_ids に追加してください。" >&2
    exit 2
  fi
fi

exit 0
