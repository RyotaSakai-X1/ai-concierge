# /sync-design-system — Figma ↔ ローカル デザインシステム同期

Figma ファイルのデザイントークンと `knowledge/design-system.md` を比較し、差分レポートとルール文書を生成する。

## 引数

- `$ARGUMENTS` — Figma ファイル URL（例: `https://www.figma.com/design/XXXXX/project-name`）
  - 省略時は Step 4 のみ実行

## 動作モード

| 条件 | Step 1-3（Figma 同期） | Step 4（ルール文書生成） |
|------|----------------------|------------------------|
| URL あり | ✅ | ✅ |
| URL なし | ⬚ スキップ | ✅ |

## Step 1: Figma トークン取得

入力: `$ARGUMENTS` の Figma URL（fileKey は `figma.com/design/{fileKey}/` or `figma.com/file/{fileKey}/` から抽出）

| 操作 | MCP ツール | 目的 |
|------|-----------|------|
| ノードツリー取得 | `get_metadata`（fileKey, nodeId: "0:1"） | デザインシステム用ページを特定 |
| トークン取得 | `get_variable_defs`（fileKey, nodeId） | デザイントークン一覧を取得 |

トークン分類:

| カテゴリ | プレフィックス |
|---------|--------------|
| カラー | `Color/` |
| タイポグラフィ | `Typography/` |
| スペーシング | `Spacing/`, `Space/` |
| その他 | 上記以外 |

## Step 2: 差分検出・レポート生成

比較対象: Figma トークン（Step 1）↔ `knowledge/design-system.md`

差分分類:

| 状態 | 条件 |
|------|------|
| 追加候補 | Figma にあってローカルにない |
| 未反映 | ローカルにあって Figma にない |
| 不整合 | 両方にあり値が異なる |

出力先: `docs/outputs/{project-slug}/design-system-sync-report-{YYYY-MM-DD}.md`

レポート内容:
- 同期元（Figma URL、取得日時）
- サマリー（追加候補・未反映・不整合のトークン数）
- 各カテゴリのトークン一覧テーブル（トークン名・値・カテゴリ or 備考）

## Step 3: ローカル反映

レポート提示後、AskUserQuestion で反映可否を確認:
- 追加候補トークンをローカルに反映するか
- 不整合トークンを Figma 値で上書きするか

承認された変更のみ `knowledge/design-system.md` に反映する。

## Step 4: ルール文書生成

入力: `knowledge/design-system.md`（現在の定義）
テンプレート: `create_design_system_rules` の出力に従う

生成内容:
- デザイントークン一覧と用途
- コンポーネントのスタイリング方針（Tailwind クラス使用ルール等）
- カラー・タイポグラフィ・スペーシングの制約
- コンポーネント設計時の判断基準

出力先: `docs/outputs/{project-slug}/design-system-rules-{YYYY-MM-DD}.md`

> この文書は CLAUDE.md やコードレビューのチェックリストとして活用できる。

## 制約

- Figma MCP はデザインの直接編集不可。ローカル→Figma の書き込みはできない
- `get_variable_defs` はトークン未設定ファイルで空データを返す場合がある
- project-slug が不明な場合は Figma ファイル名 or `design-system` を使用する
