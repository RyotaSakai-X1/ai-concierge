# /run-ui-test — UI テスト自動実行（Browser Use CLI）

テストケースに基づき、Browser Use CLI で UI テストを自動実行し、結果を記録する。

## 引数

- `$ARGUMENTS` — 以下の形式:
  - `{テスト対象URL} {テストケースURL}` — テスト対象 URL + Google Sheets URL
  - `{テスト対象URL} {ローカルファイルパス}` — テスト対象 URL + ローカルファイル
  - テキストでの直接指示（テスト対象・テスト項目をインラインで記述）

## 前提条件

- Browser Use CLI がインストール済みであること
  - 未インストールの場合: `uv add browser-use && playwright install chromium`
- テストケースが用意されていること（Google Sheets または Markdown/CSV ファイル）

## Step 1: テスト項目読み込み

| 入力形式 | 取得方法 |
|---------|---------|
| Google Sheets | `mcp__google-workspace__read_sheet_values` で読み込み |
| ローカルファイル | Read で読み込み（Markdown テーブル or CSV） |
| テキスト指示 | テスト項目を構造化して一覧化 |

### テストケースの想定フォーマット

| # | 画面 | 操作手順 | 期待結果 | 結果 | エビデンス | 備考 |
|---|------|---------|---------|------|-----------|------|
| 1 | ログイン | メールアドレスに test@example.com を入力→ログインボタン押下 | ダッシュボードに遷移 | | | |

テスト項目を読み込んだら AskUserQuestion で確認:

- `全項目を実行する` — 全テストケースを順次実行
- `特定の項目のみ実行する` — 実行する項目番号を指定

## Step 2: ブラウザセッション開始

Browser Use CLI でブラウザセッションを開始する。

### 認証が不要な場合

```bash
browser-use open {テスト対象URL}
```

### 認証が必要な場合

Real Browser モードで既存のログイン状態を使用する:

```bash
browser-use open {テスト対象URL} --browser real --profile "Default"
```

AskUserQuestion で認証方式を確認:

- `認証不要（パブリックページ）` — 通常モードで起動
- `既存のログイン状態を使用する（推奨）` — Real Browser モードで起動
- `テスト内でログイン操作を実行する` — 通常モードで起動し、ログイン操作をテストケースに含める

## Step 3: テスト実行ループ

各テスト項目について順次実行する:

### 3-1: 操作の実行

テストケースの「操作手順」を Browser Use CLI で実行する。
操作手順は自然言語のまま Browser Use Agent が解釈・実行する。

```bash
browser-use act "操作手順の内容"
```

### 3-2: 期待結果の検証

操作後の画面状態を確認する:

```bash
browser-use get text
browser-use state
```

期待結果と実際の画面状態を比較し、OK/NG を判定する。

### 3-3: エビデンス取得

```bash
browser-use screenshot --output docs/outputs/{slug}/test-results/screenshots/{nn}.png
```

### 3-4: 結果の記録

各テスト項目の結果を記録する:

| 項目 | 記録内容 |
|------|---------|
| 結果 | OK / NG |
| エビデンス | スクリーンショットのパス |
| 備考 | NG の場合は実際の結果を記載 |

## Step 4: 結果出力

### 4-1: ローカルファイルに保存

`knowledge/templates/ui-test-result.md` テンプレートに基づき、結果レポートを生成する。

出力先: `docs/outputs/{slug}/test-results/{YYYY-MM-DD}.md`

スクリーンショット: `docs/outputs/{slug}/test-results/screenshots/`

### 4-2: Google Sheets への書き戻し（入力が Google Sheets の場合）

`mcp__google-workspace__modify_sheet_values` で結果列・エビデンス列を更新する。

### 4-3: ブラウザセッション終了

```bash
browser-use close
```

## Step 5: 後続アクション提案

結果に応じて次のアクションを提案する:

| 結果 | 推奨アクション |
|------|-------------|
| 全項目 OK | 完了報告。テスト通過を記録 |
| NG 項目あり | NG 項目ごとにバグイシューの起票を提案 |

NG 項目がある場合、AskUserQuestion で確認:

- `NG 項目のバグイシューを起票する` — `gh issue create` で NG ごとにイシュー作成
- `今は起票しない` — 結果レポートのみで終了

## 制約

- テストケースにない操作・検証は行わない
- NG 判定は期待結果との不一致のみ。テスト範囲外の問題は備考に記載するに留める
- 認証情報（パスワード等）をコミット・ログに残さない
- Browser Use CLI が未インストールの場合は、インストール手順を提示して終了する
- 仮定を置いた場合は `> ⚠️ 仮定：` で明示

## 関連コマンド

- `/generate-test-cases` — テストケース生成（上流・未実装）
- `/test-report` — テスト結果集計・バグイシュー自動起票（下流・未実装）
- `/design` — デザイン生成（Step 4.5 でビジュアル QA に Browser Use CLI を使用）
