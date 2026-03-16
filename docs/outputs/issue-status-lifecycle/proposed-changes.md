# イシューステータス管理の改善 — 変更提案書

関連イシュー: #84

## 概要

GitHub Projects の5ステータス（Backlog / Ready / In progress / In review / Done）を全てルール化し、イシューのライフサイクルを完全にカバーする。

## ステータス遷移の定義（最終形）

| タイミング | ステータス | オプション ID |
|-----------|-----------|-------------|
| イシュー起票時（トリアージ完了） | **Ready** | 61e4505c |
| ブランチ作成時（着手） | **In progress** | 47fc9ee4 |
| PR 作成後 | **In review** | df73e18b |
| PR マージ後 | **Done** | 98236657（GitHub自動化） |

> Backlog（f75ad846）はトリアージ前のイシューが入る場所。優先度が決まったら Ready に昇格する。

---

## 変更1: `.claude/rules/git-workflow.md`

### 変更箇所: 「イシューステータスの更新」セクション（111行目〜末尾）

以下に全文置き換え:

---

## イシューステータスの更新

GitHub Projects のステータスを以下のタイミングで変更する：

| タイミング | ステータス |
|-----------|-----------|
| イシュー起票時（トリアージ完了） | **Ready** |
| イシューに着手（ブランチ作成時） | **In progress** |
| PR 作成後 | **In review** |
| PR マージ後 | **Done**（GitHub の自動化で設定済み） |

> Backlog はトリアージ前のイシューが入る場所。優先度が決まったら Ready に昇格する。

### 更新コマンド

1. イシューの Project Item ID を取得: `gh project item-list 1 --owner RyotaSakai-X1 --format json --limit 200` で一覧を取得し、該当イシュー番号の `.id` を抽出
2. ステータスを変更: `gh project item-edit` で以下のパラメータを指定

| パラメータ | 値 |
|-----------|-----|
| --project-id | PVT_kwHOB_Hl9M4BRRtG |
| --field-id | PVTSSF_lAHOB_Hl9M4BRRtGzg_Jsyk |

| ステータス | オプション ID |
|-----------|-------------|
| Backlog | f75ad846 |
| Ready | 61e4505c |
| In progress | 47fc9ee4 |
| In review | df73e18b |
| Done | 98236657 |

---

## 変更2: `.claude/rules/issue-management.md`

### 変更箇所: 「手順」セクション（12行目〜）

Step 5 の後に Step 6 を追加:

---

## 手順

1. 議論の内容を TODO として整理する
2. 関連する Phase を判定する
3. `docs/roadmap.md` に追記する
4. `gh issue create` で起票する
5. イシュー間の依存関係を本文に記載する
6. イシューを GitHub Projects の **Ready** ステータスに設定する（`git-workflow.md` の「更新コマンド」セクション参照）

---

## 変更3: `.claude/commands/work-on-issue.md`

### 変更箇所: Step 3（29行目〜）

ブランチ作成後にステータス変更を追加:

---

### Step 3: ブランチ作成（通常実行時のみ）

1. `.claude/rules/git-workflow.md` のブランチ命名規則に従う
2. ブランチ名: `feature/YYYY-MM-DD-{slug}`（イシューの内容から slug を決定）
3. `git checkout -b feature/YYYY-MM-DD-{slug}` を実行する
4. イシューのステータスを **In progress** に変更する（`git-workflow.md` の「更新コマンド」セクション参照）

---

## 変更4: `.claude/commands/parallel-work.md`

### 変更箇所: Step 9（89行目〜）

PR 作成後にステータス変更を追加:

---

### Step 9: PR 作成・プッシュ

ユーザーの承認後、テックリードが各ブランチについて以下を実行する:

1. `git push -u origin {ブランチ名}` でプッシュ
2. `gh pr create --title "PRタイトル" --body "PR本文" --base main --assignee @me` で PR 作成
3. PR 本文に `Closes #XX` を含めてイシューと紐づける
4. 各イシューのステータスを **In review** に変更する（`git-workflow.md` の「更新コマンド」セクション参照）

---

## 既存イシューの Backlog → Ready 昇格

以下の高優先度イシューを Ready に変更する（`gh project item-edit` を使用）:

| イシュー | Project Item ID | 現ステータス |
|---------|----------------|-------------|
| #74 — トンマナ選定プロセスを構築する | PVTI_lAHOB_Hl9M4BRRtGzgncLJI | Backlog |
| #80 — デザインディレクション定義 | PVTI_lAHOB_Hl9M4BRRtGzgncMJE | Backlog |
| #83 — MCP ツールのアクセス権限を最小権限に制限する | PVTI_lAHOB_Hl9M4BRRtGzgnh5kk | Backlog |

実行コマンド（各イシューに対して）:

gh project item-edit --project-id PVT_kwHOB_Hl9M4BRRtG --id {ITEM_ID} --field-id PVTSSF_lAHOB_Hl9M4BRRtGzg_Jsyk --single-select-option-id 61e4505c

> 実行には `gh auth refresh -s project --hostname github.com` で project スコープの追加が必要。
