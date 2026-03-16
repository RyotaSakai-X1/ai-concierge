# Figma MCP 能力・制約ドキュメント

## 概要

Figma MCP（Model Context Protocol）は、Figma のデザインデータに AI エージェントがアクセスするための公式サーバー。
HTTP 型（`https://mcp.figma.com/mcp`）で動作し、OAuth 認証で接続する。

## ツール一覧と検証結果

### 1. whoami

| 項目 | 内容 |
|------|------|
| 機能 | 認証ユーザーの情報取得 |
| 入力 | なし |
| 出力 | email, handle, plans（所属チーム・権限・プラン種別） |
| 用途 | 認証状態の確認、権限チェック |
| テスト結果 | OK |

返却情報:
- `email`: ユーザーのメールアドレス
- `handle`: 表示名
- `plans[]`: 所属チーム/組織の一覧（`name`, `seat`（Full/View）, `tier`（starter/pro/org））

### 2. get_metadata

| 項目 | 内容 |
|------|------|
| 機能 | ファイル/ノードの構造取得（XML形式） |
| 入力 | fileKey, nodeId |
| 出力 | ノードツリー（ID, name, type, position, size） |
| 用途 | ファイル構造の俯瞰、ノードIDの特定 |
| テスト結果 | OK |

制約:
- スタイル情報（色・フォント等）は含まれない
- 構造のみの軽量レスポンス
- `nodeId: "0:1"` でページ全体を取得可能

### 3. get_screenshot

| 項目 | 内容 |
|------|------|
| 機能 | ノードのスクリーンショット画像取得 |
| 入力 | fileKey, nodeId |
| 出力 | PNG画像 |
| 用途 | デザインの視覚的確認 |
| テスト結果 | OK |

特徴:
- Section 全体やページ単位でも取得可能
- AI の視覚理解と組み合わせてデザインの判断ができる

### 4. get_design_context（最重要ツール）

| 項目 | 内容 |
|------|------|
| 機能 | デザインからコード生成 + スクリーンショット + メタデータ |
| 入力 | fileKey, nodeId |
| 出力 | React+Tailwind コード, スクリーンショット, スタイル情報, アセットURL |
| 用途 | デザインからの実装コード生成 |
| テスト結果 | OK |

特徴:
- コードは React + Tailwind CSS で生成される（参考実装として使用）
- デザイントークンは CSS 変数形式で出力される
- フォント情報（family, weight, size, lineHeight, letterSpacing）が付随する
- 画像アセットは URL で提供（7日間有効）
- Code Connect が設定済みの場合、コードベースのコンポーネントにマッピングされる

制約:
- 出力は React+Tailwind 前提。プロジェクトのスタックに変換が必要
- 大きなノードではコードではなくメタデータのみが返る場合がある（`forceCode` で強制可能）
- アセット URL は一時的（7日間）

### 5. get_variable_defs

| 項目 | 内容 |
|------|------|
| 機能 | デザイントークン（変数定義）の取得 |
| 入力 | fileKey, nodeId |
| 出力 | JSON（カラー、タイポグラフィ、スペーシング等のトークン） |
| 用途 | デザインシステムのトークン抽出 |
| テスト結果 | OK |

出力例:
- カラー: `"Color/Dashboard/Theming/Theming-6/Theming-6": "#ffc145"`
- フォントファミリー: `"Typography/Family/BNE-JP": "Noto Sans JP"`
- フォントサイズ: `"Typography/Scale/10": "10"`
- フォントスタイル: `"Noto Sans JP/UI-Label/Bold/10,100,0%": "Font(...)"`

### 6. generate_diagram

| 項目 | 内容 |
|------|------|
| 機能 | Mermaid.js 記法から FigJam にダイアグラム生成 |
| 入力 | name, mermaidSyntax |
| 出力 | FigJam ファイルの URL |
| 用途 | フローチャート、シーケンス図、ガント図の自動生成 |
| テスト結果 | OK |

対応図種:
- graph / flowchart（LR推奨）
- sequenceDiagram
- stateDiagram / stateDiagram-v2
- gantt

制約:
- クラス図、タイムライン、ヴェン図、ER図は非対応
- フォント変更や個別シェイプの移動は不可（Figma で直接編集が必要）
- 絵文字は使用不可

### 7. generate_figma_design

| 項目 | 内容 |
|------|------|
| 機能 | Web ページのキャプチャ → Figma デザインへの変換 |
| 入力 | URL（ローカル・外部とも可）, outputMode（newFile/existingFile/clipboard） |
| 出力 | Figma ファイル |
| 用途 | 既存 Web ページの Figma 取り込み |
| テスト結果 | 未テスト（キャプチャ対象が必要） |

特徴:
- localhost のローカル開発サーバーにも対応
- `captureId` でポーリングして完了を待つ非同期処理
- 既存ファイルへの追加や新規ファイル作成が可能

### 8. get_figjam

| 項目 | 内容 |
|------|------|
| 機能 | FigJam ファイルのノード情報取得 |
| 入力 | fileKey, nodeId |
| 出力 | FigJam ノードの情報（画像含む） |
| 用途 | FigJam ボードからの情報取得 |
| テスト結果 | 未テスト（FigJam ファイルが必要） |

制約:
- FigJam ファイル専用（通常の Figma デザインファイルでは使用不可）

### 9. create_design_system_rules

| 項目 | 内容 |
|------|------|
| 機能 | デザインシステムルール生成のためのプロンプトテンプレート提供 |
| 入力 | なし |
| 出力 | コードベース分析用の質問リスト（プロンプト） |
| 用途 | CLAUDE.md 等にデザインシステムルールを追加する際のガイド |
| テスト結果 | OK |

特徴:
- ツールというよりプロンプトテンプレート
- トークン定義、コンポーネント構成、スタイリングアプローチ等の分析観点を提供
- 出力を元にコードベースを分析し、ルールドキュメントを生成する

### 10. get_code_connect_map

| 項目 | 内容 |
|------|------|
| 機能 | Figma コンポーネントとコードベースのマッピング取得 |
| 入力 | fileKey, nodeId |
| 出力 | JSON（nodeId → コンポーネント名・ソースパスのマッピング） |
| 用途 | 既存の Code Connect マッピングの確認 |
| テスト結果 | OK（マッピング未設定のため空オブジェクト） |

### 11. add_code_connect_map

| 項目 | 内容 |
|------|------|
| 機能 | Figma ノードとコードコンポーネントのマッピングを追加 |
| 入力 | fileKey, nodeId, source, componentName, label（フレームワーク） |
| 出力 | マッピング結果 |
| 用途 | Figma コンポーネントをコードベースに紐づける |
| テスト結果 | 未テスト（コードベースのコンポーネントが必要） |

対応フレームワーク:
React, Vue, Svelte, Web Components, Storybook, Javascript, Swift, SwiftUI, Compose, Flutter, Markdown 等

### 12. get_code_connect_suggestions

| 項目 | 内容 |
|------|------|
| 機能 | AI によるコンポーネントマッピングの提案 |
| 入力 | fileKey, nodeId |
| 出力 | マッピング提案リスト |
| 用途 | Code Connect の自動設定支援 |
| テスト結果 | 未テスト（コードベースのコンポーネントが必要） |

### 13. send_code_connect_mappings

| 項目 | 内容 |
|------|------|
| 機能 | Code Connect マッピングの一括保存 |
| 入力 | fileKey, nodeId, mappings[] |
| 出力 | 保存結果 |
| 用途 | get_code_connect_suggestions で承認されたマッピングの保存 |
| テスト結果 | 未テスト |

## 能力サマリー

### できること

| カテゴリ | 能力 |
|---------|------|
| 読み取り | ファイル構造の取得、スクリーンショット、デザイントークン抽出 |
| コード生成 | デザインから React+Tailwind コードの参考実装を生成 |
| ダイアグラム | Mermaid.js → FigJam にフローチャート等を自動生成 |
| キャプチャ | Web ページ → Figma デザインへの変換 |
| Code Connect | Figma コンポーネントとコードベースの双方向マッピング |
| 認証 | OAuth ベースのユーザー認証、チーム/権限の確認 |

### できないこと・制約

| カテゴリ | 制約 |
|---------|------|
| デザイン編集 | 既存ノードのスタイル変更・レイアウト調整は不可 |
| コンポーネント作成 | Figma 上に新しいコンポーネントを直接作成する機能はない |
| 出力形式 | コード生成は React+Tailwind 固定（他フレームワークへの変換はエージェント側の責務） |
| アセット有効期限 | 画像 URL は7日間のみ有効 |
| ダイアグラム | クラス図・ER図・タイムライン等は非対応 |
| FigJam | FigJam 操作は get_figjam（読み取り）と generate_diagram（図生成）のみ |
| プロトタイプ | インタラクション・遷移の情報取得は不可 |
| バージョン管理 | ファイルの履歴やブランチ操作は不可 |

## 認証・権限

- 認証方式: OAuth 2.0（初回ツール呼び出し時にブラウザでフローが開始）
- `.mcp.json` に設定を追加することでプロジェクト共有が可能
- 各ユーザーが個別に認証を完了する必要がある（認証情報はリポジトリに含まれない）
- `seat: "Full"` のプランでのみ完全な機能が利用可能
