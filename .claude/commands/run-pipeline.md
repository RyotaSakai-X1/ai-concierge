# /run-pipeline — 対話的パイプライン実行

議事録やヒアリング情報を起点に、要件抽出 → 要件定義 → イシュー起票 → 画面設計 → ダイアグラム → ワイヤーフレーム → 見積もりの各ステップを対話的に進めるワンストップコマンド。

各ステップで成果物サマリを提示し、AskUserQuestion で次のアクションを選択する。

## 引数

- `$ARGUMENTS` — 以下のいずれか:
  - Google Docs URL（議事録）
  - ローカルファイルパス（Markdown 議事録）
  - Google Drive フォルダ URL（複数ファイル）
  - 省略時は Step 1 で入力を求める

## Step 1: 入力の取得

`$ARGUMENTS` が指定されていない場合、AskUserQuestion で入力ソースを選択する。

選択肢: `Google Docs URL を入力` / `ローカルファイルパスを入力` / `Google Drive フォルダ URL を入力`

入力を取得したら案件 slug を決定する。既存の `docs/outputs/` 内に該当案件があればそれを使い、なければ新規作成する。

## Step 2: 要件抽出（/extract-requirements）

`/extract-requirements` を実行し、議事録・ヒアリングデータから構造化レポートを生成する。

**成果物サマリの提示:**
- 抽出した議題数
- 決定事項・未確認事項の件数
- ネクストアクションの件数
- 出力ファイルパス

AskUserQuestion の選択肢:
- `両方実行する（要件定義 + イシュー起票）`（推奨）
- `要件定義に進む（/define-requirements）`
- `イシューを起票する（/create-issues-from-meeting）`
- `ここで終了`

## Step 3: 要件定義 + イシュー起票

選択に応じて `/define-requirements` と `/create-issues-from-meeting` を実行する。

**要件定義の成果物サマリ:**
- 課題数・要望数
- 機能要件数・非機能要件数
- 優先度マトリクスの概要
- 出力ファイルパス

**イシュー起票の成果物サマリ:**
- 起票件数
- イシュー一覧（番号・タイトル・URL）

AskUserQuestion の選択肢:
- `画面設計に進む（/generate-screens）`（推奨）
- `工数見積に進む（/estimating → /create-estimate-doc）`
- `両方（画面設計 → 見積の順で実行）`
- `ここで終了`

## Step 4: 画面設計（/generate-screens）

`/generate-screens` を実行し、画面一覧と画面遷移図を生成する。

**成果物サマリの提示:**
- 画面数
- 画面一覧テーブル（簡易版）
- 画面遷移図（Mermaid コードブロック）
- 出力ファイルパス

AskUserQuestion の選択肢:
- `ダイアグラムを FigJam に生成（/generate-diagrams）`（推奨）
- `ワイヤーフレームに進む（/wireframe）`
- `両方（ダイアグラム → ワイヤーフレーム）`
- `ここで終了`

## Step 5: ダイアグラム生成（/generate-diagrams）

`/generate-diagrams` を実行し、FigJam にダイアグラムを生成する。

**成果物サマリの提示:**
- 生成した図の種類と件数
- FigJam URL（マークダウンリンク）

AskUserQuestion の選択肢:
- `ワイヤーフレームに進む（/wireframe）`（推奨）
- `ここで終了`

## Step 6: ワイヤーフレーム生成（/wireframe）

`/wireframe` を実行し、HTML ワイヤーフレームを一時生成して Figma にキャプチャ出力する。

**成果物サマリの提示:**
- 生成した画面数
- Figma ファイル URL（マークダウンリンク）

AskUserQuestion の選択肢:
- `工数見積に進む（/estimating → /create-estimate-doc）`
- `レビューする（/reviewing）`
- `完了`

## Step 7: 工数見積（/estimating → /create-estimate-doc）

見積ルートが選択された場合に実行する。

1. 要件定義書を Google Sheets に書き出し
2. `/estimating` で工数を見積もり・書き戻し
3. `/create-estimate-doc` で見積書を生成

**成果物サマリの提示:**
- 合計工数（人日）
- 合計金額
- 見積書ファイルパス

AskUserQuestion の選択肢:
- `レビューする（/reviewing）`
- `完了`

## 完了時の報告

パイプライン全体の実行結果をまとめて報告する。

| 項目 | 内容 |
|------|------|
| 案件 slug | `{slug}` |
| 出力ディレクトリ | `docs/outputs/{slug}/` |
| 実行したステップ | 実行済みのコマンド一覧 |
| 生成された成果物 | ファイル一覧 |
| 起票されたイシュー | イシュー一覧（ある場合） |
| FigJam URL | ダイアグラム URL（ある場合） |

## 制約

- 各ステップは対応するコマンドの定義に従って実行する（このコマンドは呼び出しの制御のみ）
- 「ここで終了」が選択された場合、その時点までの成果物サマリを報告して終了
- 各ステップでエラーが発生した場合、エラー内容を報告し、スキップするか中止するか AskUserQuestion で確認
- 案件 slug は全ステップで一貫して同じものを使用する

## 関連コマンド

- `/extract-requirements` — Step 2 で実行
- `/define-requirements` — Step 3 で実行
- `/create-issues-from-meeting` — Step 3 で実行
- `/generate-screens` — Step 4 で実行
- `/generate-diagrams` — Step 5 で実行
- `/wireframe` — Step 6 で実行
- `/estimating` — Step 7 で実行
- `/create-estimate-doc` — Step 7 で実行
- `/reviewing` — 最終レビュー
