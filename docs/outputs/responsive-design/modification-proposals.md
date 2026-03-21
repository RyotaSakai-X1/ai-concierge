# モバイル・レスポンシブデザイン対応 — 変更提案

## 概要

調査レポートと実装方針に基づく、具体的なファイル変更提案。本イシュー（#130）では提案のみ作成し、実装は後続イシューで行う。

## 実装ステップ

- [ ] Phase B: テンプレート作成（wireframe-mobile/tablet, design-mobile/tablet）
- [ ] Phase C: コマンド修正（wireframe.md, design.md にデバイス選択 UI 追加）
- [ ] Phase D: Figma 実機テスト・フィードバック反映

## 変更提案

### 1. テンプレート新規作成（4ファイル）

#### 1-1. `knowledge/templates/wireframe-mobile.html`

`wireframe.html` をベースに以下を変更:

```html
<!-- viewport を 375px に変更 -->
<meta name="viewport" content="width=375">

<style>
  body {
    width: 375px;  /* 1280px → 375px */
    margin: 0 auto;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  }

  /* サイドバー → 非表示（ハンバーガーメニューに置換） */
  .sidebar { display: none; }
  .hamburger-menu { display: block; }

  /* グリッド → 1列化 */
  .grid { grid-template-columns: 1fr; }

  /* テーブル → カード形式（またはスクロールコンテナ） */
  .table-container { overflow-x: auto; }

  /* フォーム → 1列 */
  .form-grid { grid-template-columns: 1fr; }
</style>
```

主なレイアウト変更:
- サイドバー非表示、ハンバーガーメニューアイコン追加
- ヘッダーをロゴ + ハンバーガーに簡略化
- グリッドレイアウトを全て1列に
- テーブルをカード形式または横スクロールに
- フッターを1列スタックに

#### 1-2. `knowledge/templates/wireframe-tablet.html`

`wireframe.html` をベースに以下を変更:

```html
<meta name="viewport" content="width=768">

<style>
  body { width: 768px; }

  /* サイドバー → アイコンのみ（64px） */
  .sidebar { width: 64px; }
  .sidebar .menu-label { display: none; }

  /* グリッド → 2列 */
  .grid-3, .grid-4 { grid-template-columns: repeat(2, 1fr); }

  /* テーブル → 横スクロール対応 */
  .table-container { overflow-x: auto; }
</style>
```

主なレイアウト変更:
- サイドバーを 240px → 64px（アイコンのみ、design-system.md の折りたたみ幅に準拠）
- 3列・4列グリッドを2列に
- ヘッダーナビを簡略化

#### 1-3. `knowledge/templates/design-mobile.html`

`design.html` をベースに以下を変更:
- viewport・body 幅を 375px に
- レイアウト変更は wireframe-mobile.html と同じ方針
- デザイントークン（CSS 変数）は全て維持（色・フォント・スペーシング共通）
- コンポーネント（ボタン・入力欄等）のサイズ・パディングはモバイル向けに調整

#### 1-4. `knowledge/templates/design-tablet.html`

`design.html` をベースに以下を変更:
- viewport・body 幅を 768px に
- レイアウト変更は wireframe-tablet.html と同じ方針
- デザイントークンは全て維持

### 2. コマンド修正（2ファイル）

#### 2-1. `.claude/commands/wireframe.md`

**変更箇所 1: デバイス選択ステップ追加**

Step 1（入力分析）の後に Step 1.5 を追加:

```markdown
### Step 1.5: デバイスターゲット選択

AskUserQuestion でデバイスターゲットを確認する:

- `Desktop のみ (1280px)`（デフォルト）
- `Desktop + Mobile (1280px + 375px)`
- `Desktop + Tablet + Mobile (1280px + 768px + 375px)`

プロジェクトタイプが判明している場合は推奨デバイスを提示する:
- LP / EC: 「Desktop + Mobile」を推奨
- 管理画面 / 社内ツール: 「Desktop のみ」を推奨
```

**変更箇所 2: テンプレート選択ロジック**

Step 2（HTML 生成）を修正:

```markdown
選択されたデバイスごとにテンプレートを適用:
- Desktop: `wireframe.html` を使用（従来通り）
- Mobile:  `wireframe-mobile.html` を使用
- Tablet:  `wireframe-tablet.html` を使用

ファイル命名:
- Desktop: `{nn}-{slug}.html`
- Mobile:  `{nn}-{slug}-mobile.html`
- Tablet:  `{nn}-{slug}-tablet.html`
```

**変更箇所 3: キャプチャループ**

Step 3（Figma キャプチャ）を修正:

```markdown
デバイスが複数選択されている場合:
1. Desktop 版を newFile でキャプチャ
2. Mobile 版を existingFile で同一ファイルに追加キャプチャ
3. Tablet 版を existingFile で同一ファイルに追加キャプチャ
```

**変更箇所 4: 「レスポンシブ対応不要」の削除**

「デスクトップ幅固定（1280px）、レスポンシブ対応不要」を以下に置換:

```markdown
デフォルトはデスクトップ幅（1280px）。デバイスターゲット選択でモバイル・タブレット対応を追加可能。
```

#### 2-2. `.claude/commands/design.md`

`wireframe.md` と同じ変更パターン:
- デバイス選択ステップ追加
- テンプレート選択ロジック修正
- キャプチャループ修正
- 「レスポンシブ対応不要」削除

### 3. 変更不要と判断したファイル

| ファイル | 理由 |
|---------|------|
| `knowledge/design-system.md` | ブレイクポイント定義は既に正しい。変更不要 |
| `knowledge/design-direction.md` | 「Responsive First」原則は既に記載。変更不要 |
| `knowledge/templates/diagram.html` | デバイス非依存。1440px はダイアグラム可読性用。スコープ外 |
| `.claude/commands/generate-diagrams.md` | ダイアグラムはデバイス非依存。変更不要 |

## 想定される成果物

Phase B〜C 完了後:
- テンプレート 4 ファイル新規作成（wireframe-mobile/tablet, design-mobile/tablet）
- コマンド 2 ファイル修正（wireframe.md, design.md）
- `/wireframe` と `/design` でデバイス選択が可能になる
- 既存の「Desktop のみ」ワークフローは完全に維持

## 後続イシューの提案

| イシュー | 内容 | 優先度 |
|---------|------|--------|
| テンプレート作成 | wireframe-mobile/tablet, design-mobile/tablet の HTML 実装 | High |
| コマンド修正 | wireframe.md, design.md へのデバイス選択 UI 追加 | High |
| Figma 実機テスト | 375px / 768px でのキャプチャ検証、フレーム整理手順の確立 | Medium |

## 備考

> ⚠️ 仮定：テンプレートの CSS クラス名（`.sidebar`, `.grid`, `.form-grid` 等）は実際のテンプレート実装に合わせて調整が必要。上記はコンセプト例。

> ⚠️ 仮定：モバイル版テーブルの「カード形式変換」は CSS のみで対応する想定。HTML 構造を変更する場合はコマンド側のロジック修正が必要になる。
