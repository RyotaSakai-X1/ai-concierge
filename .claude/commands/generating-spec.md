# /generating-spec — 仕様書から実装計画・技術設計を生成

引数の仕様書ファイルから、技術構成・タスク・リスクを生成する。

## 引数

- `$ARGUMENTS` — 仕様書ファイルパス（例: `docs/specs/2025-01-01-feedback-system.md`）

## Step 1: 技術選定・設計

入力: `$ARGUMENTS` の仕様書 + `knowledge/` 配下の全ファイル（既存ルール・技術スタック）

技術選定の優先順:

| 優先度 | 基準 |
|--------|------|
| 1 | `knowledge/business-rules.md` の制約に従う |
| 2 | 既存コードのスタックを優先 |
| 3 | 不明な場合は複数案を並記しトレードオフを明示 |

## Step 2: 出力ファイル生成

出力先: `docs/outputs/{spec-slug}/`

| ファイル名 | 内容 |
|---|---|
| `architecture.md` | 技術構成・データフロー図（Mermaid 形式） |
| `tasks.md` | 実装タスクの詳細チェックリスト |
| `risks.md` | リスク一覧と対策 |
