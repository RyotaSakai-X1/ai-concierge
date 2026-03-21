# モバイル・レスポンシブデザイン対応 — 実装方針

## 概要

テンプレートとコマンドにデバイス別対応を追加し、「モバイルファースト」設計原則と実装の矛盾を解消する。既存デスクトップワークフローを維持しつつ、オプトインでモバイル/タブレット対応を可能にする。

## 設計判断

### アプローチ: デバイス別テンプレート方式

**採用理由:**
1. Figma MCP の `generate_figma_design` は URL 単位でキャプチャする。メディアクエリでは1回のキャプチャで1ビューポートしか取れない
2. デバイス別テンプレートの方が、各デバイスのレイアウト最適化を明確に制御できる
3. LP 等で同一デザインベースのレスポンシブ構築でも、Figma キャプチャの仕組み上この方式が最適

**不採用理由（メディアクエリ併用方式）:**
- 1テンプレートにメディアクエリを入れても、キャプチャ時に1つのビューポート幅でしかレンダリングされない
- メディアクエリの動作確認が困難（Figma MCP にビューポート制御パラメータがない）

### 設計原則

- **デザイントークン（色・フォント・スペーシング・コンポーネント）は全デバイスで共通**
- **レイアウト（グリッド・サイドバー・ナビゲーション）のみデバイスごとに調整**
- CSS 変数でトークンを共有し、デバイス間のデザイン一貫性を担保

## テンプレート構成

### 新規ファイル一覧

```
knowledge/templates/
  wireframe.html          # 既存（1280px）→ そのまま維持（デフォルト）
  wireframe-mobile.html   # 新規: 375px
  wireframe-tablet.html   # 新規: 768px
  design.html             # 既存（1280px）→ そのまま維持（デフォルト）
  design-mobile.html      # 新規: 375px
  design-tablet.html      # 新規: 768px
  diagram.html            # 変更なし（デバイス非依存、スコープ外）
```

### デバイス別レイアウト仕様

| 要素 | Desktop (1280px) | Tablet (768px) | Mobile (375px) |
|------|------------------|----------------|----------------|
| サイドバー | 240px 固定表示 | 64px アイコンのみ | 非表示（ハンバーガーメニュー） |
| グリッド | 3〜4列 | 2列 | 1列 |
| ヘッダー | フルナビゲーション | 簡略ナビ | ハンバーガー + ロゴ |
| テーブル | 通常表示 | 横スクロールコンテナ | カード形式に変換 |
| フォーム | 2列レイアウト可 | 1列 | 1列 |
| フッター | 複数列 | 2列 | 1列スタック |

### デザイントークンの共有方法

全デバイステンプレートで同じ CSS 変数を使用:

```css
:root {
  /* カラー — 全デバイス共通 */
  --primary: {{TOKEN_PRIMARY}};
  --neutral-50: {{TOKEN_NEUTRAL_50}};
  /* タイポグラフィ — 全デバイス共通 */
  --font-sans: {{TOKEN_FONT_SANS}};
  --font-body: {{TOKEN_FONT_BODY}};
  /* スペーシング — 全デバイス共通 */
  --space-4: 16px;
  --space-8: 32px;
}
```

デバイスごとに変わるのは `body { width }` と レイアウト構造（グリッド・サイドバー等）のみ。

## コマンド UI 設計

### デバイス選択ステップ

`/wireframe` と `/design` の両コマンドに、入力分析後・HTML 生成前に追加:

**AskUserQuestion:**
```
「対象デバイスを選択してください」

選択肢:
- Desktop のみ (1280px)（デフォルト）
- Desktop + Mobile (1280px + 375px)
- Desktop + Tablet + Mobile (1280px + 768px + 375px)
```

### プロジェクトタイプ別推奨ガイド

コマンド実行時、プロジェクト情報（`/define-requirements` や `/generate-screens` の出力）から判断可能な場合、推奨デバイスを提示する:

| プロジェクト種別 | 推奨デバイス | 理由 |
|---|---|---|
| LP・ランディングページ | Desktop + Mobile（必須） | モバイルトラフィックが大半 |
| コーポレートサイト | Desktop + Tablet + Mobile | 多様なデバイスでアクセスされる |
| EC サイト | Desktop + Mobile（必須） | モバイルコンバージョンが重要 |
| SaaS 管理画面 | Desktop のみ | デスクトップ利用が前提 |
| 社内ツール | Desktop のみ | 利用環境が限定 |
| モバイルアプリ Web ビュー | Mobile のみ | モバイル専用 |

### キャプチャフロー

デバイス選択に応じたキャプチャ処理:

```
1. 選択されたデバイスごとにテンプレートを適用して HTML 生成
   - Desktop: wireframe.html / design.html → /tmp/{type}-{slug}/01-dashboard.html
   - Mobile:  wireframe-mobile.html → /tmp/{type}-{slug}/01-dashboard-mobile.html
   - Tablet:  wireframe-tablet.html → /tmp/{type}-{slug}/01-dashboard-tablet.html

2. ローカルサーバー起動（npx serve）

3. デバイスごとに generate_figma_design を呼び出し
   - 1回目: Desktop 版をキャプチャ（newFile）
   - 2回目: Mobile 版をキャプチャ（existingFile で同一ファイルに追加）
   - 3回目: Tablet 版をキャプチャ（existingFile で同一ファイルに追加）

4. クリーンアップ
```

## Figma ファイル構成

### 命名規則

```
Figma ファイル: {Project Name} - Wireframes

フレーム構成（デバイス別にグループ化）:
  Desktop (1280px):
    01-Dashboard
    02-UserList
    03-Settings
  Mobile (375px):
    01-Dashboard-mobile
    02-UserList-mobile
    03-Settings-mobile
  Tablet (768px):
    01-Dashboard-tablet
    02-UserList-tablet
    03-Settings-tablet
```

> ⚠️ 仮定：`generate_figma_design` のページ/フレーム命名は自動のため、実際の Figma 上での整理は手動で行う必要がある可能性がある。実機テストで確認後、必要に応じてキャプチャ後に `get_metadata` で構造確認し、手動整理の手順を追加する。

### Desktop のみ選択時

従来通りの動作。追加テンプレートは使用せず、既存のワークフローがそのまま維持される。

## 段階的採用計画

| フェーズ | 内容 | 影響範囲 |
|---------|------|---------|
| Phase A（本イシュー） | 調査・計画ドキュメント作成 | ドキュメントのみ |
| Phase B（次イシュー） | mobile / tablet テンプレート作成 | `knowledge/templates/` に4ファイル追加 |
| Phase C（次イシュー） | コマンドにデバイス選択 UI 追加 | `wireframe.md`, `design.md` 修正 |
| Phase D（将来） | Figma 実機テスト・フィードバック反映 | テンプレート微調整 |

## 備考

> ⚠️ 仮定：`generate_figma_design` が HTML の `<meta name="viewport" content="width=375">` を正しく解釈し、375px 幅でレンダリングすることを前提としている。Figma MCP 接続環境での実機テストが必要。

> ⚠️ 仮定：`existingFile` モードで同一 Figma ファイルに複数回キャプチャした場合、各キャプチャが別フレームとして追加されることを前提としている。
