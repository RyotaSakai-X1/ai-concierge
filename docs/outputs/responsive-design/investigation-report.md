# モバイル・レスポンシブデザイン対応 — 調査レポート

## 概要

Figma MCP の `generate_figma_design` ツールによるマルチデバイス対応の技術的可能性を検証し、既存ワークフローへの影響を評価した。

## 評価

| 軸 | 評価 | 補足 |
|---|---|---|
| インパクト | 高 | 設計原則と実装の矛盾を解消し、モバイル対応プロジェクトに対応可能になる |
| 工数 | M | テンプレート4ファイル新規作成 + コマンド2ファイル修正 |
| リスク | 低 | 既存ワークフローは変更なし（オプトイン方式） |
| 依存関係 | なし | Figma MCP の既存機能のみで実現可能 |

## 背景・課題

### 現在の矛盾

| 定義 | 実装 |
|------|------|
| ブレイクポイント定義あり（sm:640px〜2xl:1536px） | テンプレートで未使用 |
| 「モバイルファースト」方針（design-system.md） | `width: 1280px` 固定 |
| 「Responsive First」原則（design-direction.md） | 「レスポンシブ対応不要」と明記 |
| 横スクロールをアンチパターンと定義 | モバイル表示の検証不可 |

### 対象ファイル

| ファイル | 現状 |
|---------|------|
| `knowledge/templates/wireframe.html` | viewport=1280, body width=1280px |
| `knowledge/templates/design.html` | viewport=1280, body width=1280px |
| `knowledge/templates/diagram.html` | viewport=1440, body width=1440px |
| `.claude/commands/wireframe.md` | 「デスクトップ幅固定（1280px）、レスポンシブ対応不要」 |
| `.claude/commands/design.md` | 「デスクトップ幅固定（1280px）、レスポンシブ対応不要」 |

## 調査結果

### 1. `generate_figma_design` のパラメータ仕様

| パラメータ | 型 | 必須 | 用途 |
|-----------|---|-----|------|
| `URL` | string | 必須 | キャプチャ対象の Web ページ URL |
| `outputMode` | string | 必須 | `newFile` / `existingFile` / `clipboard` |
| `planKey` | string | 任意 | Figma チーム/プロジェクトの出力先指定 |

**確認された制限:**
- ビューポート幅を指定するパラメータ（width, viewport 等）は **存在しない**
- ページ名・フレーム名を指定するパラメータは **存在しない**
- 既存ファイルへの追加時のページ/フレーム位置指定も **不可**

### 2. ビューポート幅の制御方法

ビューポート幅は HTML 側で制御する:

```html
<!-- 現在の方式（デスクトップ固定） -->
<meta name="viewport" content="width=1280">
<style>body { width: 1280px; }</style>

<!-- モバイル対応（新方式） -->
<meta name="viewport" content="width=375">
<style>body { width: 375px; }</style>
```

`generate_figma_design` は指定 URL をそのままキャプチャするため、HTML の viewport 設定がそのまま Figma フレームのサイズに反映される。

### 3. マルチデバイス対応の実現方式

`generate_figma_design` でデバイス別のキャプチャを実現する方法:

**方式: デバイス別 HTML → 個別キャプチャ**

```
/tmp/wireframes-{slug}/
  01-dashboard.html          # Desktop (1280px)
  01-dashboard-mobile.html   # Mobile (375px)
  01-dashboard-tablet.html   # Tablet (768px)
```

各ファイルを個別に `generate_figma_design` で順次キャプチャする。

- 同一 Figma ファイルへの追加: `outputMode: existingFile` で可能
- ただしページ/フレーム命名は自動（手動で Figma 上で整理が必要な可能性あり）

### 4. 既存プロジェクト出力への影響評価

`docs/outputs/` 配下の既存成果物:

| ディレクトリ | 影響 |
|---|---|
| `design-foundation/` | なし（Figma MCP 能力ドキュメント、参照のみ） |
| `declarative-commands/` | なし（コマンド設計の仕様書） |
| `system-flowchart/` | なし（フロー図、diagram.html 使用、スコープ外） |
| `issue-status-lifecycle/` | なし |
| `meetings/` | なし |

**結論: 既存出力への影響はゼロ。** モバイル対応はオプトイン方式で追加するため、既存ワークフローを使い続ける限り変更はない。

### 5. diagram.html のスコープ判定

ダイアグラム（`diagram.html`）はデバイス非依存のコンテンツ（フローチャート、シーケンス図等）であり、1440px 幅はデバイスのビューポートではなく図の可読性のための設定。**スコープ外と判定。**

## 結論

| 項目 | 結果 |
|------|------|
| 異なるビューポート幅でのキャプチャ | 可能（HTML 側で制御） |
| 同一ファイルへのマルチアートボード | 可能（existingFile モード） |
| フレーム/ページ命名のカスタマイズ | 不可（Figma API の制限） |
| 既存ワークフローへの影響 | なし（オプトイン方式） |

> ⚠️ 仮定：`generate_figma_design` が HTML の `<meta name="viewport">` を正しく解釈し、指定幅でレンダリングすることを前提としている。実機テスト（Figma MCP 接続環境）での最終検証が必要。
