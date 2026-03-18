# /sync-design-system — Figma ↔ ローカル デザインシステム同期

Figma ファイルからデザイントークンを抽出し、`knowledge/design-system.md` との差分を検出・レポートします。
また、ローカルのデザインシステム定義を開発ルール文書として整備します。

## 引数

- `$ARGUMENTS` — Figma ファイル URL（例: `https://www.figma.com/design/XXXXX/project-name`）
  - 省略した場合はローカル→ルール文書生成モードのみ実行

## 実行手順

### Step 1: 引数の解析

1. `$ARGUMENTS` が提供されている場合:
   - URL から fileKey を抽出する（`figma.com/design/{fileKey}/` または `figma.com/file/{fileKey}/` の形式）
   - fileKey が取得できない場合は処理を中断しユーザーに正しい URL を求める
2. `$ARGUMENTS` が省略されている場合:
   - Step 4（ローカル→ルール文書生成）のみ実行する

### Step 2: Figma ファイル構造の取得（Figma URL が提供された場合のみ）

1. `get_metadata` で fileKey と `nodeId: "0:1"` を指定し、ページ・セクション・コンポーネントのノードツリーを取得する
2. 取得したノードツリーから以下を把握する:
   - ページ一覧と構成
   - デザインシステム用と思われるページ（"Design System", "Tokens", "Colors" 等の名称を探す）
   - 主要コンポーネントの nodeId 一覧
3. デザインシステムページが見つかった場合はその nodeId を以降のステップで使用する。見つからない場合は `"0:1"` を使用する

### Step 3: デザイントークンの抽出（Figma URL が提供された場合のみ）

1. `get_variable_defs` で fileKey と nodeId を指定し、デザイントークンを取得する
2. 取得したトークンを以下のカテゴリに分類する:
   - **カラー**: `Color/` プレフィックスのトークン
   - **タイポグラフィ**: `Typography/` プレフィックスのトークン
   - **スペーシング**: `Spacing/` または `Space/` プレフィックスのトークン
   - **その他**: 上記に該当しないトークン

### Step 4: 差分検出とレポート生成（Figma URL が提供された場合のみ）

1. `knowledge/design-system.md` を読み込む
2. Step 3 で抽出した Figma トークンと、`design-system.md` のトークン定義を比較する:
   - Figma にあってローカルにない → **追加候補**
   - ローカルにあって Figma にない → **未反映**（Figma への追加 or ローカルのみで管理）
   - 両方にあって値が異なる → **不整合**
3. 差分レポートを `docs/outputs/{project-slug}/design-system-sync-report-{YYYY-MM-DD}.md` に出力する

差分レポートのフォーマット:

```
# デザインシステム同期レポート {YYYY-MM-DD}

## 同期元
- Figma ファイル: {URL}
- 取得日時: {datetime}

## サマリー
- 追加候補: X トークン
- 未反映: X トークン
- 不整合: X トークン

## 追加候補（Figma にあってローカルにないトークン）
| トークン名 | 値 | カテゴリ |
|-----------|-----|---------|
| ...       | ... | ...     |

## 未反映（ローカルにあって Figma にないトークン）
| トークン名 | ローカル値 | 備考 |
|-----------|-----------|------|
| ...       | ...       | ...  |

## 不整合（値が異なるトークン）
| トークン名 | Figma 値 | ローカル値 |
|-----------|---------|-----------|
| ...       | ...     | ...       |
```

4. レポートの内容をユーザーに提示し、以下を AskUserQuestion で確認する:
   - 「追加候補トークンをローカルに反映しますか？」
   - 「不整合トークンを Figma 値で上書きしますか？」

### Step 5: ローカル更新（ユーザーが承認した場合のみ）

ユーザーが承認した変更を `knowledge/design-system.md` に反映する:

1. **追加候補の反映**: 承認されたトークンを該当カテゴリ（カラー/タイポグラフィ/スペーシング）のテーブルに追加する
2. **不整合の修正**: 承認されたトークンの値を Figma 値に更新する
3. 変更後の `design-system.md` を読み直し、反映内容をユーザーに確認する

### Step 6: ローカル → ルール文書生成

`create_design_system_rules` を呼び出し、プロンプトテンプレートを取得する。
そのテンプレートに従って、`knowledge/design-system.md` の現在の定義を分析し、以下のルール文書を生成する:

出力先: `docs/outputs/{project-slug}/design-system-rules-{YYYY-MM-DD}.md`

生成内容:
- プロジェクトで使用するデザイントークンの一覧と用途
- コンポーネントのスタイリング方針（Tailwind クラスの使用ルール等）
- カラー・タイポグラフィ・スペーシングの制約（デザイントークン外の値を使ってはいけない等）
- コンポーネント設計時の判断基準

> この文書は `CLAUDE.md` やコードレビューのチェックリストとして活用できる。

### Step 7: 結果サマリーの報告

以下をチャットに出力する:

```
## /sync-design-system 完了

### Figma 同期（{URL がある場合}）
- 追加: X トークン
- 不整合修正: X トークン
- レポート: docs/outputs/{slug}/design-system-sync-report-{date}.md

### ルール文書生成
- 出力: docs/outputs/{slug}/design-system-rules-{date}.md

### 次のステップ
- [ ] レポートを確認し、未反映トークンの対応方針を決める
- [ ] ルール文書を CLAUDE.md または設計仕様書に組み込む
```

## 注意事項

- Figma MCP は Figma 上の**デザイン直接編集**は不可能。ローカル→Figma の「書き込み」はできない
- `get_variable_defs` はトークンが未設定のファイルでは空データを返す場合がある
- project-slug が不明な場合は Figma ファイル名 or `design-system` を使用する
- `create_design_system_rules` の出力はプロンプトテンプレートであり、AI 自身がそのテンプレートに従って分析を実行する
