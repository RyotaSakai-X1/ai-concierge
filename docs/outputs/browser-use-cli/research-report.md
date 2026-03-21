# Browser Use CLI 2.0 調査レポート

**調査日:** 2026-03-21

## 概要

Browser Use CLI 2.0 は、LLM エージェントがブラウザを操作するための Python ベースの CLI ツール。CDP（Chrome DevTools Protocol）を直接使用し、Playwright や Puppeteer より軽量かつ高速。

## 現状のリポジトリとの関係

### 既存のブラウザ関連機能

| 機能 | 状態 |
|------|------|
| Figma MCP `get_screenshot` | あり — Figma デザインのスクリーンショット取得 |
| Figma MCP `generate_figma_design` | あり — localhost の HTML を Figma に変換 |
| `/design` コマンドで localhost サーバー起動 | あり — `npx serve` でプレビュー生成 |

### まだない機能

| 機能 | ロードマップ上の記載 |
|------|---------------------|
| ブラウザ自動操作 | なし |
| UI テスト自動実行 | `/run-ui-test` として計画あり（「将来 Playwright MCP で自動化」） |
| 実機ブラウザ確認 | なし — 現状は HTML 生成して手動確認 |

## 統合方法の比較

| 方法 | トークン効率 | 長時間タスク | セットアップ |
|------|------------|-------------|-------------|
| **CLI 直接実行** | 最良（~27,000 トークン） | 問題なし | `uv add browser-use` |
| **MCP サーバー** | 悪い（~114,000 トークン、4倍） | HTTP transport 必須 | `.mcp.json` に追加 |
| **Python ライブラリ** | カスタム次第 | 問題なし | プログラミング必要 |

**結論: CLI 直接実行を推奨**

## Playwright MCP との比較

| 項目 | Browser Use CLI | Playwright MCP |
|------|----------------|----------------|
| アプローチ | スクリーンショット + Vision | アクセシビリティツリー |
| トークン効率 | ~27,000 トークン | ~114,000 トークン（4倍） |
| 速度 | 3-5倍速い（ChatBrowserUse 利用時） | 遅め |
| 向いてる用途 | プロダクション自動化 | テストワークフロー |
| コスト | ローカル無料 / Cloud: $0.006/step | — |
| Real Browser | 既存 Chrome のログイン状態を使える | 毎回新規セッション |

## 主な機能

### ナビゲーション
- `browser-use open <url>` — URL を開く
- `browser-use back` — 戻る
- `browser-use scroll down [--amount N]` — スクロール

### ページ状態
- `browser-use state` — URL, タイトル, クリック可能要素を取得
- `browser-use screenshot [path.png]` — スクリーンショット取得

### インタラクション
- `browser-use click <index>` — 要素クリック
- `browser-use type "text"` — テキスト入力
- `browser-use input <index> "text"` — 要素をクリックして入力
- `browser-use keys "Enter"` — キーボード入力
- `browser-use select <index> "option"` — ドロップダウン選択

### データ抽出
- `browser-use eval "document.title"` — JavaScript 実行
- `browser-use get text <index>` — テキスト抽出
- `browser-use get html --selector "h1"` — HTML 取得

### ブラウザモード
- `--browser chromium` — ヘッドレス（デフォルト）
- `--browser chromium --headed` — 画面表示あり
- `--browser real --profile "Default"` — 既存 Chrome のログイン状態を使用
- `--browser remote` — クラウドブラウザ

## セットアップ要件

- Python 3.11+
- `uv add browser-use` または `pip install browser-use`
- Chromium: `playwright install chromium`

## 制約・注意点

- PDF 操作が苦手（shadow DOM の問題）
- MCP の stdio transport だと 60 秒超のタスクでタイムアウト → CLI 推奨
- バージョン 0.12.3（2025-03-20 時点）— 1.0 未満で API 変更の可能性あり
- CAPTCHA / 2FA はクラウド版のみ対応
- DOM スナップショットからパスワードフィールドは自動除外（セキュリティ）

## 活用案

### 1. `/design` のビジュアル QA（優先度: 高）

HTML 生成後 → Figma キャプチャ前にスクリーンショットで確認。

### 2. `/run-ui-test` の自動化（優先度: 高）

テストケースに基づくブラウザ操作の自動実行。

### 3. 競合・参考サイトの自動調査

要件定義の補助として画面構成をスクリーンショット付きでレポート化。

### 4. デプロイ後のスモークテスト

主要ページの表示確認・フォーム送信フローの動作確認。

### 5. デザインと実装の差分検出

Figma スクリーンショットと実装 HTML のスクリーンショットを比較。

### 6. デモ用キャプチャの自動生成

操作フローをスクリーンショット連番化して PR 本文に添付。

## コスト

| モード | コスト |
|--------|--------|
| ローカル実行（推奨） | 無料 |
| Cloud（ChatBrowserUse） | $0.006/step |
| Cloud（Claude Sonnet） | $0.03-0.05/step |
