---
description: "ブランチ運用、PR作成、コミット、イシューステータス更新のルール"
---

# Git ワークフロー詳細

## ブランチ運用

- **main に直接コミットしない**。すべての変更はブランチ → PR 経由
- ブランチ名: `feature/YYYY-MM-DD-{スラグ}`（修正は `fix/`）

### 作業の流れ

1. 関連イシューのステータスを **In progress** に変更する（後述「イシューステータスの更新」参照）
2. `git checkout -b feature/YYYY-MM-DD-{slug}` でブランチ作成
3. 作業・コミット
4. **PR 作成前に必ずローカルで `/review` を実行する**
5. レビューで指摘があれば修正してから次へ進む
6. `git push -u origin {ブランチ名}` でプッシュ
7. `gh pr create --assignee @me` で PR 作成
   - Assignees に自分を追加する（`--assignee @me`）
   - レビュー結果を PR 本文に含める
   - 関連イシューがあれば PR 本文に `Closes #XX` を記載して紐づける
8. 関連イシューのステータスを **In review** に変更する
9. **ここで Claude の作業は完了**。マージは必ずユーザー（人間）が行う

> ⚠️ Claude は PR の作成までが責務。マージ・クローズは絶対に行わない。

### PR 作成後

1. AskUserQuestion で **修正の有無**を確認する
   - 選択肢: `修正がある` / `修正はない`
   - `修正がある` → このブランチ（または worktree）で修正作業を継続
2. 「修正はない」の場合、AskUserQuestion で **クリーンアップ**を確認する
   - 選択肢: `ブランチ・worktree を削除して main に戻る` / `このブランチで続ける`
   - `ブランチ・worktree を削除して main に戻る` → ローカルブランチ・worktree を削除 → `git checkout main && git pull` → 次のイシュー提案へ

### main に戻った後

- main に戻ったら、必ず次にやるべきイシューを提案する
- `gh issue list` で優先度が高いものから順に確認し、AskUserQuestion で着手するか聞く
  - 選択肢: 提案するイシューのタイトル / `他のイシューを見る` / `今は作業しない`

### ブランチ・worktree の削除

- ユーザーから「マージ完了」の報告を受けてから、リモート・ローカルともにブランチを削除する
- PR 作成直後には削除しない（レビュー修正に備えて保持する）
- セッション開始時にマージ済みブランチが残っていたら削除を提案する
  - `git fetch --prune` でリモート追跡ブランチを整理
  - `git branch --merged main` でマージ済みブランチを確認し削除を提案

## 並列実行（Agent Teams）

並列実行で作成されるブランチも通常と同じ命名規則（`feature/` / `fix/`）に従う。

チーム分離・コンフリクト検出・マージ戦略の詳細は `parallel-execution.md` を参照。

> 要点: メンバーは独自 worktree で作業、push/PR作成はテックリードが担当、コンフリクトは事前・動的・事後の3段階で検出。マージは独立→任意順、競合→変更少を先に、依存→依存元を先に。worktree・ブランチの削除はマージ完了報告を受けてから実行する。

## コミット

- コミットメッセージは**日本語**で書く
- コミット前に AskUserQuestion（OK / NG）で確認を取る:
  - 今回の変更概要
  - コミットメッセージ案

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

以下の手順で GitHub Projects のステータスを動的に更新する。ID はすべて `gh` CLI で動的取得し、ハードコードしない。

#### 1. プロジェクト情報の取得

```bash
# リポジトリオーナーを取得
OWNER=$(gh repo view --json owner -q '.owner.login')

# プロジェクト一覧を取得（複数ある場合はユーザーに選択させる）
gh project list --owner $OWNER --format json
```

#### 2. フィールド ID・オプション ID の取得

```bash
# Status フィールドとオプション ID を取得
gh project field-list {プロジェクト番号} --owner $OWNER --format json
```

返却される JSON から以下を抽出する:
- `name: "Status"` のフィールド → `--field-id` に使用
- 各 `options` の `id` → ステータス名に対応するオプション ID

#### 3. イシューのステータス変更

```bash
# Project Item ID を取得
gh project item-list {プロジェクト番号} --owner $OWNER --format json --limit 200

# ステータスを変更
gh project item-edit --project-id {取得したプロジェクトID} --id {Item ID} --field-id {Status フィールドID} --single-select-option-id {対象ステータスのオプションID}
```

> プロジェクトが1つしかない場合は自動選択する。複数ある場合は AskUserQuestion で選択させる。
