# イシュー下書き: /design にビジュアル QA ステップを追加

## タイトル

【Phase 1】/design コマンドに Browser Use CLI によるビジュアル QA ステップを追加

## ラベル

- `Phase 1`
- `priority: medium`

## 本文

### 概要

`/design` コマンドの HTML 生成後 → Figma キャプチャ前に、Browser Use CLI 2.0 でスクリーンショットを自動取得してビジュアル確認を挟むステップを追加する。

### 背景

- 現状 `/design` は HTML を生成して Figma に直接キャプチャしている
- HTML の見た目に問題があっても Figma キャプチャ後にしか気づけない
- Browser Use CLI（トークン効率が MCP の4倍良い）でキャプチャ前の QA ステップを自動化する

### やること

- [ ] Browser Use CLI のセットアップ手順をドキュメント化
  - `uv add browser-use` + `playwright install chromium`
- [ ] `.claude/settings.json` に `Bash(browser-use:*)` を `allow` に追加
- [ ] `.claude/commands/design.md` の Step 4 と Step 5 の間に「Step 4.5: ビジュアル QA」を追加
  - `npx serve` 起動後に `browser-use open` → `browser-use screenshot` で各画面のスクショ取得
  - スクリーンショットの保存先: `docs/outputs/{slug}/design/screenshots/`
  - AskUserQuestion で確認: `この見た目で Figma にキャプチャする` / `修正する`
- [ ] `docs/roadmap.md` に Browser Use CLI 導入を記載

### 変更対象ファイル

| ファイル | 変更内容 |
|---------|---------|
| `.claude/commands/design.md` | Step 4.5 挿入 |
| `.claude/settings.json` | allow リスト追加 |
| `docs/roadmap.md` | ロードマップ更新 |

### 関連イシュー

- #77（`/design` コマンドのコア実装）

### 備考

> ⚠️ 仮定：現状 `/design` はデスクトップ幅固定（1280px）のため、レスポンシブ QA は今回のスコープ外。将来レスポンシブ対応を入れた際にビューポート切り替え QA を拡張する。
