# /wireframe — ワイヤーフレーム生成（Figma 出力）

`/generate-screens` で定義した画面一覧をもとに、HTML ワイヤーフレームを一時生成し、Figma にキャプチャして出力する。

## 引数

- `$ARGUMENTS` — 以下のいずれか:
  - `/generate-screens` の出力ディレクトリパス（`docs/outputs/{slug}/screens/`）
  - `/define-requirements` の出力ファイルパス（画面一覧を自動生成してからレイアウト作成）
  - テキストでの直接指示

## Step 1: 入力の取得と分析

| 入力形式 | 取得方法 |
|---------|---------|
| `/generate-screens` 出力 | Read で `screens.md` を取得し、画面一覧を抽出 |
| 要件定義書 | Read で取得し、画面に紐づく機能要件を抽出 |
| テキスト指示 | そのまま分析。不明な点は `> ⚠️ 仮定：` で明示 |

画面一覧がない場合（要件定義書やテキスト指示の場合）は、まず画面一覧を簡易生成してからレイアウトに進む。

## Step 1.5: デバイス選択

AskUserQuestion で対応デバイスを確認する:

- `デスクトップのみ（1280px）（推奨）` — 社内管理画面、バックオフィスツール、ダッシュボード向け
- `デスクトップ + モバイル` — LP、商用サイト、EC サイト向け
- `全デバイス（Mobile + Tablet + Desktop）` — モバイルアプリ、フルレスポンシブ対応向け

### テンプレートマッピング

| 選択 | 使用テンプレート |
|------|----------------|
| デスクトップのみ | `wireframe.html` |
| デスクトップ + モバイル | `wireframe.html` + `wireframe-mobile.html` |
| 全デバイス | 上記 + `wireframe-tablet.html` |

## Step 2: HTML ワイヤーフレーム生成

Step 1.5 で選択されたデバイスに対応するテンプレートを参照し、各画面ごとに HTML ファイルを生成する。

### 出力先

一時ディレクトリ: `/tmp/wireframes-{slug}/`

### 生成ファイル

#### デスクトップのみの場合

| ファイル | 内容 |
|---------|------|
| `index.html` | 全画面を1ページにまとめた一覧（各画面へのアンカーリンク付き） |
| `{nn}-{画面名slug}.html` | 各画面のワイヤーフレーム（1画面1ファイル） |

#### 複数デバイス対応の場合

| ファイル | 内容 |
|---------|------|
| `index.html` | デバイス別セクション（Desktop / Mobile / Tablet）に分けた一覧 |
| `{nn}-{画面名slug}-desktop.html` | デスクトップ版（1280px） |
| `{nn}-{画面名slug}-mobile.html` | モバイル版（375px）※選択時のみ |
| `{nn}-{画面名slug}-tablet.html` | タブレット版（768px）※全デバイス選択時のみ |

### HTML 生成ルール

- スタイル: グレースケール、システムフォント、ボーダーベースのシンプルなレイアウト
- 共通要素（ヘッダー、サイドバー、フッター）は全画面に含める
- 各画面に画面タイトルとナビゲーションパスを上部に表示
- デフォルトはデスクトップ幅固定（1280px）。Step 1.5 でモバイル・タブレット対応を選択可能
- プレースホルダー要素: テーブル、フォーム、ボタン、カード、モーダル等を適切に配置

## Step 3: ローカルサーバー起動 + Figma キャプチャ

### 3-1: ローカルサーバー起動

```bash
npx serve /tmp/wireframes-{slug}/ -l 3456 &
```

サーバーが起動したことを確認してから次へ進む。

### 3-2: Figma 出力先の選択

`destination-defaults.md` の Figma 出力先判定フローに従う。

- `FIGMA_DEFAULT_PLAN_KEY` 設定済み → 選択肢: `デフォルトのチーム/プロジェクトに作成` / `Drafts に作成` / `既存の Figma ファイルに追加（URL を入力）`
- `FIGMA_DEFAULT_PLAN_KEY` 未設定 → 選択肢: `新しい Figma ファイルを作成` / `既存の Figma ファイルに追加（URL を入力）`

### 3-3: Figma キャプチャの実行

`generate_figma_design` を呼び出し、`http://localhost:3456/index.html` をキャプチャする。

- `newFile` の場合: `planKey` に `FIGMA_DEFAULT_PLAN_KEY` の値を渡す（未設定なら `planKey` 省略 = Drafts に作成）
- 各画面を個別にキャプチャする場合は、画面ごとの URL（`http://localhost:3456/{nn}-{slug}.html`）を使用
- AskUserQuestion で確認: `全画面を1ページにまとめてキャプチャ` / `画面ごとに個別キャプチャ`

#### 複数デバイス対応時のキャプチャ

複数デバイスが選択された場合、デバイスごとにキャプチャを実行する:

- キャプチャ順: Desktop → Tablet → Mobile（大→小）
- Figma フレーム命名規則: `{nn}-{画面名}/Desktop`, `{nn}-{画面名}/Mobile`, `{nn}-{画面名}/Tablet`
- 各デバイスの URL: `http://localhost:3456/{nn}-{slug}-desktop.html`, `-mobile.html`, `-tablet.html`

### 3-4: クリーンアップ

キャプチャ完了後:
1. ローカルサーバーを停止（`kill` でプロセス終了）
2. 一時ディレクトリを削除（`rm -rf /tmp/wireframes-{slug}/`）

## Step 4: 結果の報告

報告項目:
- Figma ファイル URL（マークダウンリンク）
- 生成した画面数

次のアクション:

| 状況 | 推奨 |
|------|------|
| ダイアグラムがまだ | `/generate-diagrams` で FigJam にフロー図を生成 |
| 工数見積もりが必要 | `/estimating` でスプレッドシートから見積もり |
| 技術設計に進む | `/generating-spec` で技術設計 |
| レビューが必要 | `/reviewing` で成果物レビュー |

## 制約

- 要件にない画面のレイアウトを作成しない
- レイアウトはワイヤーフレームレベルの概要に留める（ピクセル詳細やカラー指定は `/design` の領域）
- 仮定を置いた場合は `> ⚠️ 仮定：` で明示
- 画面一覧の `#` と番号を一致させ、トレーサビリティを確保する
- HTML は一時生成物であり、永続的に保存しない
- Figma キャプチャ後は必ずサーバー停止・一時ファイル削除を行う

## 関連コマンド

- `/generate-screens` — この入力となる画面一覧・遷移図を生成
- `/generate-diagrams` — FigJam にダイアグラムを生成
- `/generating-spec` — この出力を元に技術設計を行う
- `/reviewing` — この出力をレビュー
