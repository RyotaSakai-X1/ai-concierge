---
description: 外部ツール（Figma / Google Drive）へのデフォルト出力先判定ロジック
---

# デフォルト出力先ルール

各コマンドが Figma や Google Drive に出力する際、環境変数でデフォルト出力先を参照する。

## Figma 出力先の判定フロー

環境変数: `FIGMA_DEFAULT_PLAN_KEY`

### 判定ロジック

1. `FIGMA_DEFAULT_PLAN_KEY` が**設定済み**の場合:
   - AskUserQuestion の選択肢に `デフォルトのチーム/プロジェクトに作成` を追加する
   - 選択肢の順序: `デフォルトのチーム/プロジェクトに作成` / `Drafts に作成` / `既存の Figma ファイルに追加（URL を入力）`
   - `デフォルトのチーム/プロジェクトに作成` 選択時: `generate_figma_design` に `planKey: $FIGMA_DEFAULT_PLAN_KEY` を渡す
   - `Drafts に作成` 選択時: `planKey` を省略する

2. `FIGMA_DEFAULT_PLAN_KEY` が**未設定**の場合:
   - 従来通りの選択肢: `新しい Figma ファイルを作成` / `既存の Figma ファイルに追加（URL を入力）`
   - `新しい Figma ファイルを作成` 選択時: `planKey` を省略する（= Drafts に作成）

> planKey の初回セットアップ手順は `knowledge/setup-destination-defaults.md` を参照。

## Google Drive 出力先の判定フロー

環境変数: `GDRIVE_DEFAULT_OUTPUT_FOLDER_ID`

### 判定ロジック

1. `GDRIVE_DEFAULT_OUTPUT_FOLDER_ID` が**設定済み**の場合:
   - `mcp__google-workspace__create_spreadsheet` でスプレッドシート作成後、`mcp__google-workspace__update_drive_file` で指定フォルダに移動する
   - 移動パラメータ: `file_id` = 作成したスプレッドシートの ID、`add_parents` = `$GDRIVE_DEFAULT_OUTPUT_FOLDER_ID`、`remove_parents` = 元の親フォルダ ID

2. `GDRIVE_DEFAULT_OUTPUT_FOLDER_ID` が**未設定**の場合:
   - 従来通り（マイドライブ直下に作成、移動なし）

## 注意事項

- 環境変数が設定されていても、ユーザーが明示的に別の出力先を指定した場合はそちらを優先する
- `mcp-scope.json` のホワイトリストと矛盾しないよう注意する（ホワイトリストが空 = 制限なし）
