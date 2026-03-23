# /design — ビジュアルデザイン生成（Figma 出力）

ワイヤーフレームや要件定義をもとに、`design-system.md` のデザイントークン（カラー・タイポグラフィ・スペーシング）を適用した UI デザインを HTML で生成し、Figma にキャプチャして出力する。

## 引数

- `$ARGUMENTS` — 以下のいずれか:
  - `/wireframe` の出力（Figma URL またはスクリーンショット）
  - `/generate-screens` の出力ディレクトリパス（`docs/outputs/{slug}/screens/`）
  - `/define-requirements` の出力ファイルパス
  - テキストでの直接指示

## Step 1: 入力の取得と分析

| 入力形式 | 取得方法 |
|---------|---------|
| ワイヤーフレーム出力 | Figma URL → `get_screenshot` / `get_design_context` で構造を取得。ローカルファイルなら Read で取得 |
| `/generate-screens` 出力 | Read で `screens.md` を取得し、画面一覧を抽出 |
| 要件定義書 | Read で取得し、画面に紐づく機能要件を抽出 |
| テキスト指示 | そのまま分析。不明な点は `> ⚠️ 仮定：` で明示 |

画面一覧がない場合（テキスト指示の場合）は、まず画面一覧を簡易生成してからデザインに進む。

## Step 1.5: デバイス選択

AskUserQuestion で対応デバイスを確認する:

- `デスクトップのみ（1280px）（推奨）` — 社内管理画面、バックオフィスツール、ダッシュボード向け
- `デスクトップ + モバイル` — LP、商用サイト、EC サイト向け
- `全デバイス（Mobile + Tablet + Desktop）` — モバイルアプリ、フルレスポンシブ対応向け

### テンプレートマッピング

| 選択 | 使用テンプレート |
|------|----------------|
| デスクトップのみ | `design.html` |
| デスクトップ + モバイル | `design.html` + `design-mobile.html` |
| 全デバイス | 上記 + `design-tablet.html` |

## Step 1.7: バリエーションモード選択

AskUserQuestion でデザインの提案数を確認する:

- `単一デザイン（1案）` — 1つのトーン・カラーで生成（従来動作）
- `複数バリエーション（3案）` — A/B/C の3パターンを生成し、顧客に選択肢を提示

> 「単一デザイン」選択時は、以降のステップは従来通り。バリエーション固有の記述はすべてスキップする。

## Step 2: デザイントークンの確認

`knowledge/design-system.md` を Read で読み込み、案件のデザイントークンを確認する。

### 確認項目

| 項目 | 確認先 | 未定義時の対応 |
|------|--------|-------------|
| カラーパレット | `docs/outputs/{slug}/` 配下のカラー定義、または案件の要件定義書 | **必ず** AskUserQuestion で方針を確認する（下記参照） |
| フォント | 案件固有指定、または `design-system.md` のデフォルト推奨 | デフォルト（Noto Sans JP + Inter）を使用 |
| スペーシング | `design-system.md` の 8px グリッド | デフォルト値をそのまま使用 |

### カラーパレット未定義の場合

以下の AskUserQuestion で**必ず**方針を確認する:

- 選択肢: `カラーパレットを先に決める（トレンド調査 → 候補提示）` / `デフォルトのニュートラルカラーで仮生成する` / `カラーの方向性をテキストで指示する`

`カラーパレットを先に決める` → `design-system.md` のカラー選定プロセスに従い、トレンド調査 → 候補生成 → ユーザー選定を実施してから Step 3 に進む。

### 複数バリエーション時のトークン生成

Step 1.7 で「複数バリエーション（3案）」を選択した場合、以下の手順で3つのパレットを同時生成する:

1. **UI トレンド調査**（`design-direction.md` のプロセスに従う）
2. `design-direction.md` のトーン候補 + トレンド調査結果から **3つのパレット候補を生成**:
   - **Variation A**: モダン・ミニマル系（例: モノクロ + アクセントカラー1色、控えめなシャドウ）
   - **Variation B**: プロフェッショナル・信頼感系（例: ニュートラルベース + ブランドカラー差し色、カードシャドウ）
   - **Variation C**: クリエイティブ・モダン系（例: グラデーション活用、大胆なブランドカラー、ダーク対応）
3. 各パレットは `design-system.md` のトークンスキーマ全体（primary〜status colors、neutral 50-900）を満たすこと
4. WCAG AA コントラスト比を各パレットで検証する
5. **3パレットをサマリ表で一括提示** → AskUserQuestion:
   - `この3案で進める` / `調整したい案がある`

> トーンの方向性はあくまで参考例。案件の業種・ターゲットに応じて適切なトーンを調査・導出する。`design-direction.md` の候補に縛られない。

## Step 3: コンポーネント設計

`design-system.md` の Atoms / Molecules カタログを参照し、各画面に使用するコンポーネントを選定する。

### 実施内容

1. 各画面で使用するコンポーネント（Button, Card, Table, Form, Modal 等）を洗い出す
2. 各コンポーネントのバリアント・サイズを決定する
3. レイアウト方針（グリッド構成、セクション配置）を策定する

### ユーザー承認

**必ず** AskUserQuestion でレイアウト方針を提示し、承認を得る:

- 選択肢: `この方針で進める` / `調整したい点がある`

## Step 4: HTML 生成

Step 1.5 で選択されたデバイスに対応するテンプレートを参照し、デザイントークン適用済みの HTML を生成する。

### 出力先

一時ディレクトリ: `/tmp/design-{slug}/`

### 生成ファイル（単一デザイン時）

#### デスクトップのみの場合

| ファイル | 内容 |
|---------|------|
| `index.html` | 全画面を1ページにまとめた一覧（各画面へのアンカーリンク付き） |
| `{nn}-{画面名slug}.html` | 各画面のデザイン（1画面1ファイル） |

#### 複数デバイス対応の場合

| ファイル | 内容 |
|---------|------|
| `index.html` | デバイス別セクション（Desktop / Mobile / Tablet）に分けた一覧 |
| `{nn}-{画面名slug}-desktop.html` | デスクトップ版（1280px） |
| `{nn}-{画面名slug}-mobile.html` | モバイル版（375px）※選択時のみ |
| `{nn}-{画面名slug}-tablet.html` | タブレット版（768px）※全デバイス選択時のみ |

### 生成ファイル（複数バリエーション時）

バリエーションごとにサブディレクトリを作成し、同じテンプレートに異なるトークン値を適用して生成する。

```
/tmp/design-{slug}/
  index.html                              # 比較ハブ（3案のカラースウォッチ + 各案へのリンク）
  variation-a/
    index.html                            # Variation A の画面一覧
    {nn}-{画面名slug}.html                # 各画面（デスクトップのみ時）
    {nn}-{画面名slug}-desktop.html        # 各画面（複数デバイス時）
    {nn}-{画面名slug}-mobile.html
  variation-b/
    ...（同構成）
  variation-c/
    ...（同構成）
```

#### トーン固有のスタイル調整

各バリエーションの HTML には、テンプレートのベーススタイルに加えてトーン固有の `<style>` オーバーライドブロックを追加する:

| トーン | 調整内容 |
|-------|---------|
| モダン・ミニマル系 | border-radius 大きめ、shadow 控えめ、spacing 広め |
| プロフェッショナル系 | カードベース shadow、標準 border-radius、情報密度やや高め |
| クリエイティブ系 | グラデーションアクセント、shadow 強め、heading サイズ大きめ |

#### トップレベル index.html（比較ハブ）

トップレベルの `index.html` は3案の比較ページとして機能する:
- 各バリエーションのトーン名・キーワード
- カラースウォッチ（primary, secondary, accent の比較）
- 代表画面のサムネイル（あれば）
- 各バリエーションの `index.html` へのリンク

### HTML 生成ルール

- **カラー**: `design-system.md` のセマンティックカラー体系に基づき、CSS 変数で定義。グレースケールではなく実際の色を適用する
- **フォント**: Google Fonts の `<link>` タグで読み込み。`design-system.md` 指定のフォント（デフォルト: Noto Sans JP + Inter + JetBrains Mono）
- **タイポグラフィ**: モジュラースケール（ベース 16px、比率 1.250）に基づくサイズ・行間・ウェイト
- **スペーシング**: 8px グリッドシステムに準拠したパディング・マージン・ギャップ
- **コンポーネント**: `design-system.md` の Atoms / Molecules 仕様に準拠したスタイル（ボーダーラディウス、シャドウ、ホバー状態等）
- **デフォルトはデスクトップ幅固定（1280px）**。Step 1.5 でモバイル・タブレット対応を選択可能
- 共通要素（ヘッダー、サイドバー、フッター）は全画面に含める

## Step 4.5: ビジュアル QA（Browser Use CLI）

`npx serve` 起動後、Figma キャプチャの前にスクリーンショットで見た目を確認する。

> ⚠️ Browser Use CLI が未インストールの場合はこのステップをスキップし、Step 5 に進む。

### 4.5-1: ローカルサーバー起動

```bash
npx serve /tmp/design-{slug}/ -l 3458 &
```

### 4.5-2: スクリーンショット取得

各画面の HTML を Browser Use CLI でスクリーンショット取得:

```bash
browser-use screenshot http://localhost:3458/{nn}-{画面名slug}.html --output docs/outputs/{slug}/design/screenshots/{nn}-{画面名slug}.png
```

複数デバイス対応時は各デバイスのスクリーンショットも取得する。

#### 複数バリエーション時

各バリエーションの代表画面（最初の画面）をスクリーンショット取得し、比較用に並べる:

```bash
browser-use screenshot http://localhost:3458/variation-a/{nn}-{画面名slug}.html --output docs/outputs/{slug}/design/screenshots/variation-a/{nn}-{画面名slug}.png
browser-use screenshot http://localhost:3458/variation-b/{nn}-{画面名slug}.html --output docs/outputs/{slug}/design/screenshots/variation-b/{nn}-{画面名slug}.png
browser-use screenshot http://localhost:3458/variation-c/{nn}-{画面名slug}.html --output docs/outputs/{slug}/design/screenshots/variation-c/{nn}-{画面名slug}.png
```

### 4.5-3: ビジュアル確認

取得したスクリーンショットを Read で表示し、AskUserQuestion で確認:

#### 単一デザイン時

- `この見た目で Figma にキャプチャする` → Step 5 へ進む
- `修正する` → Step 4 に戻って HTML を修正し、再度スクリーンショットを取得

#### 複数バリエーション時

3案の代表画面スクリーンショットを提示し、AskUserQuestion で確認:

- `この3案で Figma にキャプチャする` → Step 5 へ進む
- `修正する案がある（A/B/C を指定）` → 指定された案の HTML を修正し、再度スクリーンショットを取得

スクリーンショット保存先: `docs/outputs/{slug}/design/screenshots/`（バリエーション時は `screenshots/variation-a/` 等のサブディレクトリ）

> Step 4.5 でサーバーを起動済みの場合、Step 5-1 のサーバー起動はスキップする。

## Step 5: ローカルサーバー起動 + Figma キャプチャ

### 5-1: ローカルサーバー起動（Step 4.5 で起動済みの場合はスキップ）

```bash
npx serve /tmp/design-{slug}/ -l 3458 &
```

サーバーが起動したことを確認してから次へ進む。

### 5-2: Figma 出力先の選択

`destination-defaults.md` の Figma 出力先判定フローに従う。

- `FIGMA_DEFAULT_PLAN_KEY` 設定済み → 選択肢: `デフォルトのチーム/プロジェクトに作成` / `Drafts に作成` / `既存の Figma ファイルに追加（URL を入力）`
- `FIGMA_DEFAULT_PLAN_KEY` 未設定 → 選択肢: `新しい Figma ファイルを作成` / `既存の Figma ファイルに追加（URL を入力）`

### 5-3: Figma キャプチャの実行

`generate_figma_design` を呼び出し、`http://localhost:3458/index.html` をキャプチャする。

- `newFile` の場合: `planKey` に `FIGMA_DEFAULT_PLAN_KEY` の値を渡す（未設定なら `planKey` 省略 = Drafts に作成）
- 各画面を個別にキャプチャする場合は、画面ごとの URL（`http://localhost:3458/{nn}-{slug}.html`）を使用
- AskUserQuestion で確認: `全画面を1ページにまとめてキャプチャ` / `画面ごとに個別キャプチャ`

#### 複数デバイス対応時のキャプチャ

複数デバイスが選択された場合、デバイスごとにキャプチャを実行する:

- キャプチャ順: Desktop → Tablet → Mobile（大→小）
- Figma フレーム命名規則: `{nn}-{画面名}/Desktop`, `{nn}-{画面名}/Mobile`, `{nn}-{画面名}/Tablet`
- 各デバイスの URL: `http://localhost:3458/{nn}-{slug}-desktop.html`, `-mobile.html`, `-tablet.html`

#### 複数バリエーション時のキャプチャ

バリエーションごとに Figma の別ページとしてキャプチャする:

- **ページ命名**: `Variation A - {トーン名}`, `Variation B - {トーン名}`, `Variation C - {トーン名}`
- **キャプチャ順**: Variation A → B → C（各バリエーション内はデバイス順: Desktop → Tablet → Mobile）
- **各バリエーションの URL**: `http://localhost:3458/variation-a/{nn}-{画面名slug}.html` 等
- **フレーム命名**: 既存規則通り `{nn}-{画面名}/Desktop` 等（ページで分離されるためプレフィックス不要）

`generate_figma_design` をバリエーション数 × 画面数分（× デバイス数分）呼び出す。

### 5-4: クリーンアップ

キャプチャ完了後:
1. ローカルサーバーを停止（`kill` でプロセス終了）
2. 一時ディレクトリは削除しない（Step 6 のフォールバック保存で使用する可能性があるため、結果報告後に削除）

## Step 6: フォールバック（Figma MCP 未接続時）

Figma MCP が未接続または `generate_figma_design` が失敗した場合:

1. `/tmp/design-{slug}/` の HTML ファイルを `docs/outputs/{slug}/design/` にコピーする
2. ユーザーに報告: 「Figma MCP が未接続のため、HTML ファイルをローカルに保存しました。ブラウザで直接開いてプレビューできます。」

フォールバック後もサーバーは停止し、一時ディレクトリは削除する。

## Step 7: 結果の報告

### 単一デザイン時

報告項目:
- Figma ファイル URL（マークダウンリンク）またはローカル保存先パス
- 生成した画面数
- 適用したデザイントークンの概要（カラーテーマ、フォント）

### 複数バリエーション時

報告項目:
- Figma ファイル URL（各バリエーションのページへのリンク）またはローカル保存先パス
- 生成した画面数 × バリエーション数
- **バリエーション比較テーブル**:

| 案 | トーン | キーワード | Primary カラー | 特徴 |
|----|--------|-----------|---------------|------|
| A | {トーン名} | {キーワード} | {色コード} | {1行で特徴} |
| B | {トーン名} | {キーワード} | {色コード} | {1行で特徴} |
| C | {トーン名} | {キーワード} | {色コード} | {1行で特徴} |

AskUserQuestion で次のアクションを確認:

- `A案で確定する` / `B案で確定する` / `C案で確定する` → 選択した案のトークンを案件のデザイントークンとして確定。他の案のファイルは削除
- `○案をベースに調整する` → どの案かを AskUserQuestion で選択後、その案を起点に Step 4 に戻り微調整
- `技術設計に進む（/generating-spec）` → バリエーション選定を保留して先に進む

### 次のアクション（共通）

| 状況 | 推奨 |
|------|------|
| 工数見積もりが必要 | `/estimating` でスプレッドシートから見積もり |
| 技術設計に進む | `/generating-spec` で技術設計 |
| レビューが必要 | `/reviewing` で成果物レビュー |
| ダイアグラムがまだ | `/generate-diagrams` で FigJam にフロー図を生成 |

## 制約

- 要件にない画面のデザインを作成しない
- デザイントークンが未定義の場合は先に定義を促す（勝手に色を決めない）
- 仮定を置いた場合は `> ⚠️ 仮定：` で明示
- 画面一覧の `#` と番号を一致させ、トレーサビリティを確保する
- `design-system.md` のアクセシビリティ基準（WCAG AA コントラスト比等）を遵守する
- Figma キャプチャ後は必ずサーバー停止・一時ファイル削除を行う

## 関連コマンド

- `/wireframe` — この入力となるワイヤーフレームを生成
- `/generate-screens` — 画面一覧・遷移図を生成（入力として使用可能）
- `/define-requirements` — 要件定義書を生成（入力として使用可能）
- `/sync-design-system` — Figma ↔ ローカルのデザインシステム同期
- `/generating-spec` — この出力を元に技術設計を行う
- `/reviewing` — この出力をレビュー
