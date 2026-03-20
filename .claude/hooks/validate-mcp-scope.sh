#!/bin/bash
# Layer 2: MCP ツールのスコープ検証フック（fail-closed）
# .env の環境変数 + mcp-scope.json をホワイトリストとして使用
# 許可リストに含まれないリソースへのアクセスはブロックする
# exit 0 = 許可, exit 2 = ブロック

set -euo pipefail

ENV_FILE="${CLAUDE_PROJECT_DIR:-.}/.env"
SCOPE_FILE="$(dirname "$0")/../security/mcp-scope.json"

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# --- Figma ツール ---
if [[ "$TOOL_NAME" == mcp__figma__* ]]; then

  # fileKey 不要のツールは常に許可（新規作成・認証確認等）
  case "$TOOL_NAME" in
    mcp__figma__whoami|mcp__figma__generate_figma_design|mcp__figma__generate_diagram|mcp__figma__create_design_system_rules)
      exit 0
      ;;
  esac

  # fileKey を取得
  FILE_KEY=$(echo "$INPUT" | jq -r '.tool_input.fileKey // .tool_input.file_key // empty')
  if [ -z "$FILE_KEY" ]; then
    echo "ブロック: fileKey が指定されていません。" >&2
    exit 2
  fi

  # .env から許可リストを読み取り（カンマ区切り）
  ENV_KEYS=""
  if [ -f "$ENV_FILE" ]; then
    ENV_KEYS=$(grep -E '^FIGMA_ALLOWED_FILE_KEYS=' "$ENV_FILE" 2>/dev/null | head -1 | sed 's/^FIGMA_ALLOWED_FILE_KEYS=//' || true)
  fi

  # .env のリストをチェック
  if [ -n "$ENV_KEYS" ]; then
    if echo ",$ENV_KEYS," | grep -q ",$FILE_KEY,"; then
      exit 0
    fi
  fi

  # mcp-scope.json の補助リストをチェック
  if [ -f "$SCOPE_FILE" ]; then
    MATCH=$(jq -r --arg key "$FILE_KEY" '.allowed_figma_file_keys // [] | map(select(. == $key)) | length' "$SCOPE_FILE")
    if [ "$MATCH" -gt 0 ]; then
      exit 0
    fi
  fi

  echo "ブロック: Figma fileKey '$FILE_KEY' は許可されていません。.env の FIGMA_ALLOWED_FILE_KEYS に追加してください。" >&2
  exit 2
fi

# --- Drive ツール: folder_id のスコープチェック ---
if [ "$TOOL_NAME" = "mcp__google-workspace__list_drive_items" ]; then

  FOLDER_ID=$(echo "$INPUT" | jq -r '.tool_input.folder_id // .tool_input.folderId // empty')
  if [ -z "$FOLDER_ID" ]; then
    # folder_id なし = ルート一覧。許可する
    exit 0
  fi

  # .env から許可フォルダ ID を収集
  ALLOWED_IDS=""
  if [ -f "$ENV_FILE" ]; then
    for VAR_NAME in GDRIVE_DEFAULT_OUTPUT_FOLDER_ID MEET_RECORDING_FOLDER_ID; do
      VAL=$(grep -E "^${VAR_NAME}=" "$ENV_FILE" 2>/dev/null | head -1 | sed "s/^${VAR_NAME}=//" || true)
      if [ -n "$VAL" ]; then
        ALLOWED_IDS="${ALLOWED_IDS},${VAL}"
      fi
    done
  fi

  # .env のリストをチェック
  if [ -n "$ALLOWED_IDS" ]; then
    if echo ",$ALLOWED_IDS," | grep -q ",$FOLDER_ID,"; then
      exit 0
    fi
  fi

  # mcp-scope.json の補助リストをチェック
  if [ -f "$SCOPE_FILE" ]; then
    MATCH=$(jq -r --arg id "$FOLDER_ID" '.allowed_drive_folder_ids // [] | map(select(. == $id)) | length' "$SCOPE_FILE")
    if [ "$MATCH" -gt 0 ]; then
      exit 0
    fi
  fi

  echo "ブロック: Drive folder_id '$FOLDER_ID' は許可されていません。.env の GDRIVE_DEFAULT_OUTPUT_FOLDER_ID または MEET_RECORDING_FOLDER_ID に設定するか、mcp-scope.json に追加してください。" >&2
  exit 2
fi

# 対象外のツールは許可
exit 0
