# /wireframe — 要件定義から FigJam にワイヤーフレーム図を生成

要件定義書や画面設計の出力をもとに、画面遷移図・フロー図を FigJam に生成する。

## 引数

- `$ARGUMENTS` — 以下のいずれか:
  - `/generate-screens` の出力ディレクトリパス
  - `/define-requirements` または `/extract-requirements` の出力ファイルパス
  - Google Sheets URL（要件一覧）
  - テキストでの直接指示

## Step 1: 入力の取得と分析

| 入力形式 | 取得方法 | 抽出対象 |
|---------|---------|---------|
| `/generate-screens` 出力 | Read で `screens.md` + `flow.md` 取得 | 画面一覧と既存 Mermaid 遷移図 |
| 要件定義書（Markdown） | Read で取得 | 機能要件一覧、画面に紐づく機能 |
| Google Sheets URL | `mcp__google-workspace__read_sheet_values` | 機能要件の行データ |
| テキスト指示 | そのまま分析 | ユーザーの意図する画面とフロー |

抽出項目: 画面一覧 / 画面間の遷移 / ユーザーアクション / 条件分岐

## Step 2: 図の種類を決定

AskUserQuestion で確認する。

| 図の種類 | 適したケース | Mermaid タイプ |
|---------|------------|---------------|
| 画面遷移図 | 画面間のナビゲーションフロー | `graph LR` |
| ユーザーフロー | 特定タスクの手順（登録、購入等） | `graph TD` |
| 状態遷移図 | ステータスの変化（注文状態、承認フロー等） | `stateDiagram-v2` |
| シーケンス図 | ユーザー・システム間のやり取り | `sequenceDiagram` |

選択肢: `画面遷移図` / `ユーザーフロー` / `状態遷移図` / `シーケンス図` / `全て生成`

## Step 3: Mermaid コード生成

図の種類別ルール:

| 種類 | ルール |
|------|--------|
| 画面遷移図 | ノード: 日本語を引用符で囲む。エッジラベル: ユーザーアクション。共通ナビは subgraph。画面 10 超は subgraph 分割。色は控えめ（エントリーポイント=緑、エラー=赤程度） |
| ユーザーフロー | 上→下の流れ。開始/終了は丸括弧。条件分岐はひし形 |
| 状態遷移図 | 各状態をノード定義。遷移条件をラベルに。開始/終了 `[*]` を含める |
| シーケンス図 | 参加者（ユーザー、FE、BE、外部 API 等）を定義。時系列でメッセージ記述 |

## Step 4: FigJam に生成

`mcp__figma__generate_diagram` を使用。

| パラメータ | 値 |
|-----------|-----|
| name | `{プロジェクト名} {図の種類}` |
| mermaidSyntax | Step 3 の Mermaid コード |
| userIntent | 図の目的を簡潔に |

戻り値の URL を必ずマークダウンリンクでユーザーに表示する。「全て生成」の場合は図の種類ごとに順に呼び出す。

## Step 5: 結果の報告

報告項目: 図の種類と FigJam URL / 画面/ノード数

Mermaid コードのローカル保存先: `docs/outputs/{案件slug}/wireframes/`

| ファイル | 内容 |
|---------|------|
| `screen-flow.md` | 画面遷移図 |
| `user-flow.md` | ユーザーフロー |
| `state-diagram.md` | 状態遷移図 |
| `sequence.md` | シーケンス図 |

次のアクション:

| 状況 | 推奨 |
|------|------|
| 画面設計がまだ | `/generate-screens` で画面レイアウト設計 |
| 工数見積もりが必要 | `/estimating` でスプレッドシートから見積もり |
| 技術設計に進む | `/generating-spec` で技術設計 |

## Mermaid コードの制約

| ルール |
|--------|
| 対応タイプ: `graph`, `flowchart`, `sequenceDiagram`, `stateDiagram`, `stateDiagram-v2`, `gantt` |
| graph/flowchart では全テキストを引用符で囲む |
| 絵文字を使用しない |
| `\n` で改行しない（実際の改行を使う） |
| 色のスタイリングは控えめに |

## 制約

- 要件にない画面や遷移を追加しない（一般的に必要なもののみ例外）
- 画面数が多い場合は subgraph で分割し読みやすさ優先
- FigJam 生成後のレイアウト微調整は Figma 上で行うよう案内
- 仮定を置いた場合は `> ⚠️ 仮定：` で明示

## 関連コマンド

- `/define-requirements` — 要件定義書を生成（この入力になる）
- `/generate-screens` — 画面レイアウトを Markdown で設計（この入力にもなる）
- `/generating-spec` — この出力を元に技術設計
