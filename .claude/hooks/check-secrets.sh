#!/bin/bash
# コミット前に機密情報が含まれていないかチェックする
# .env, APIキー, トークン等がステージングされていたらブロック

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# git commit コマンド以外はスルー
if [[ "$COMMAND" != git\ commit* ]]; then
  exit 0
fi

# ステージングされたファイル名をチェック
DANGEROUS_FILES=$(git diff --cached --name-only | grep -iE '^\.(env|env\..*)$|credentials|secret' | grep -v '\.sample$' | grep -vi 'secretary' || true)
if [[ -n "$DANGEROUS_FILES" ]]; then
  echo "ブロック: 機密ファイルがコミットに含まれています: $DANGEROUS_FILES" >&2
  exit 2
fi

# ステージングされた差分の中身をチェック
SECRETS=$(git diff --cached | grep -iE '(api[_-]?key|secret[_-]?key|password|access[_-]?token|private[_-]?key)\s*[=:]\s*["\x27]?[a-zA-Z0-9]' || true)
if [[ -n "$SECRETS" ]]; then
  echo "ブロック: コミット内容に機密情報らしき文字列が含まれています。確認してください。" >&2
  exit 2
fi

exit 0
