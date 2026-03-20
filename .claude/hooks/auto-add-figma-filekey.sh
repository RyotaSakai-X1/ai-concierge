#!/bin/bash
# PostToolUse: generate_figma_design / generate_diagram 実行後に
# 作成された Figma ファイルの fileKey を .env の FIGMA_ALLOWED_FILE_KEYS に自動追加する

set -euo pipefail

ENV_FILE="${CLAUDE_PROJECT_DIR:-.}/.env"

# .env がなければスキップ
if [ ! -f "$ENV_FILE" ]; then
  exit 0
fi

INPUT=$(cat)
TOOL_RESULT=$(echo "$INPUT" | jq -r '.tool_result // empty')

if [ -z "$TOOL_RESULT" ]; then
  exit 0
fi

# ツール結果から figma.com URL の fileKey を抽出
# パターン: figma.com/design/{fileKey}/ or figma.com/board/{fileKey}/ or figma.com/file/{fileKey}/
FILE_KEYS=$(echo "$TOOL_RESULT" | grep -oE 'figma\.com/(design|board|file)/[A-Za-z0-9]+' | sed 's|figma\.com/[^/]*/||' | sort -u)

if [ -z "$FILE_KEYS" ]; then
  exit 0
fi

# 現在の FIGMA_ALLOWED_FILE_KEYS を取得
CURRENT=$(grep -E '^FIGMA_ALLOWED_FILE_KEYS=' "$ENV_FILE" | head -1 | sed 's/^FIGMA_ALLOWED_FILE_KEYS=//')

for KEY in $FILE_KEYS; do
  # 既に含まれていればスキップ
  if echo ",$CURRENT," | grep -q ",$KEY,"; then
    continue
  fi

  # 追加
  if [ -z "$CURRENT" ]; then
    CURRENT="$KEY"
  else
    CURRENT="${CURRENT},${KEY}"
  fi
done

# .env に書き戻し
if grep -qE '^FIGMA_ALLOWED_FILE_KEYS=' "$ENV_FILE"; then
  sed -i '' "s|^FIGMA_ALLOWED_FILE_KEYS=.*|FIGMA_ALLOWED_FILE_KEYS=${CURRENT}|" "$ENV_FILE"
else
  echo "FIGMA_ALLOWED_FILE_KEYS=${CURRENT}" >> "$ENV_FILE"
fi

exit 0
