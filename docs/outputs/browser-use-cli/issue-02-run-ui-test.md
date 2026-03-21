# イシュー下書き: /run-ui-test を Browser Use CLI で実装

## タイトル

【Phase 1】/run-ui-test コマンドを Browser Use CLI 2.0 で実装

## ラベル

- `Phase 1`
- `priority: medium`

## 本文

### 概要

ロードマップに記載されている `/run-ui-test` コマンドを、Browser Use CLI 2.0 を使って実装する。当初 Playwright MCP で計画していたが、トークン効率（4倍）と速度（3-5倍）の優位性から Browser Use CLI に変更する。

### 背景

- ロードマップに `/run-ui-test`（テスト項目に基づく UI テスト実行・結果記録）が Phase 1 で計画されている
- 現状は「手順書生成+手動記録」で、自動化は未着手
- Browser Use CLI は Playwright MCP と比較して:
  - トークン効率が4倍良い（27,000 vs 114,000 トークン）
  - 3-5倍高速（ChatBrowserUse 利用時）
  - Real Browser モードで既存 Chrome のログイン状態を使える（認証が必要なページのテストに有利）

### やること

- [ ] `.claude/commands/run-ui-test.md` コマンド定義を新規作成
  - 入力: テスト対象 URL + テストケース（Google Sheets URL またはローカルファイル）
  - 処理: Browser Use CLI で各テスト項目を自動実行
  - 出力: テスト結果（OK/NG + スクリーンショット + Google Sheets 書き戻し）
- [ ] `knowledge/templates/ui-test-result.md` テンプレートを新規作成
- [ ] Browser Use CLI セットアップ（イシュー「/design ビジュアル QA」と共通）
  - `uv add browser-use` + `playwright install chromium`
  - `.claude/settings.json` に `Bash(browser-use:*)` を `allow` に追加
- [ ] `docs/roadmap.md` の `/run-ui-test` 備考を更新（Playwright MCP → Browser Use CLI）

### コマンドフロー（案）

```
/run-ui-test {テスト対象URL} {テストケーススプシURL}

Step 1: テスト項目読み込み
  - Google Sheets からテストケースを読み込み（mcp__google-workspace__read_sheet_values）
  - ローカルファイルの場合は Read で読み込み

Step 2: ブラウザセッション開始
  - browser-use open {テスト対象URL}
  - 認証が必要なら Real Browser モード（--browser real --profile "Default"）

Step 3: テスト実行ループ
  各テスト項目について:
  a. 操作手順を Browser Use CLI で実行（click, type, select, etc.）
  b. 期待結果の検証（browser-use state / browser-use get text）
  c. スクリーンショット取得（browser-use screenshot）
  d. 結果を記録（OK/NG + スクリーンショットパス + 備考）

Step 4: 結果出力
  - docs/outputs/{slug}/test-results/YYYY-MM-DD.md に結果サマリー保存
  - Google Sheets に結果を書き戻し（mcp__google-workspace__modify_sheet_values）
  - スクリーンショットは docs/outputs/{slug}/test-results/screenshots/ に保存

Step 5: 後続アクション提案
  - NG 項目があれば /test-report 連携を提案
  - 全 OK なら完了報告
```

### テストケーススプレッドシートの想定フォーマット

| # | 画面 | 操作手順 | 期待結果 | 結果 | エビデンス | 備考 |
|---|------|---------|---------|------|-----------|------|
| 1 | ログイン | メールアドレスに test@example.com を入力→ログインボタン押下 | ダッシュボードに遷移 | | | |

### 変更対象ファイル

| ファイル | 変更内容 | 種別 |
|---------|---------|------|
| `.claude/commands/run-ui-test.md` | コマンド定義 | **新規** |
| `knowledge/templates/ui-test-result.md` | 結果テンプレート | **新規** |
| `.claude/settings.json` | allow リスト追加 | 変更（イシュー1と共通） |
| `docs/roadmap.md` | 備考更新 | 変更 |

### 関連イシュー

- `/generate-test-cases`（テストケース生成 — 上流）
- `/test-report`（テスト結果集計 — 下流）

### 設計上の論点

1. **操作手順の構造化レベル**: テストケースの「操作手順」を自然言語のまま LLM が解釈して操作するか、構造化コマンド（click #1, type "text"）にするか
   - 推奨: 自然言語のまま → Browser Use の Agent が解釈。テスター（人間）が書きやすい
2. **認証フロー**: Real Browser モードで既存ログインを使うか、毎回ログインフローを自動実行するか
   - 推奨: Real Browser モードをデフォルトにし、認証済みページのテストを容易にする
3. **並列実行**: 複数画面のテストを並列実行するか（`--session` オプションで可能）
   - 推奨: 初期は順次実行。安定したら並列実行を検討

### 備考

> ⚠️ 仮定：Browser Use CLI のバージョンは 0.12.3（2025-03-20 時点）。1.0 未満のため、API 変更の可能性がある。コマンド定義は CLI のインターフェースに薄くラップし、変更に追従しやすくする。
