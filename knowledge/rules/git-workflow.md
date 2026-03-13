# Git ワークフロー詳細

## ブランチ運用

- **main に直接コミットしない**。すべての変更はブランチ → PR 経由
- ブランチ名: `feature/YYYY-MM-DD-{スラグ}`（修正は `fix/`）

### 作業の流れ

1. `git checkout -b feature/YYYY-MM-DD-{slug}` でブランチ作成
2. 作業・コミット
3. **PR 作成前に必ずローカルで `/review` を実行する**
4. レビューで指摘があれば修正してから次へ進む
5. `git push -u origin {ブランチ名}` でプッシュ
6. `gh pr create --assignee @me` で PR 作成
   - Assignees に自分を追加する（`--assignee @me`）
   - レビュー結果を PR 本文に含める
   - 関連イシューがあれば PR 本文に `Closes #XX` を記載して紐づける
7. ユーザーが最終レビュー・マージ

### PR 作成後

- PR 作成が完了したら、AskUserQuestion で **main に戻るかどうか**を聞く
  - 選択肢: `main に戻る` / `このブランチで続ける`
- `main に戻る` → `git checkout main && git pull` → 次のイシュー提案へ

### main に戻った後

- main に戻ったら、必ず次にやるべきイシューを提案する
- `gh issue list` で優先度が高いものから順に確認し、AskUserQuestion で着手するか聞く
  - 選択肢: 提案するイシューのタイトル / `他のイシューを見る` / `今は作業しない`

### ブランチの削除

- PR がマージされたら、リモート・ローカルともにブランチを削除する
- 新しい PR 作成時やセッション開始時に、マージ済みブランチが残っていたら自動で掃除する
  ```bash
  git fetch --prune
  git branch --merged main | grep -v '^\*\|main' | xargs -r git branch -d
  ```

## Worktree 並列実行

### ブランチ命名規則

worktree で作成されるブランチも通常と同じ命名規則に従う:
- `feature/YYYY-MM-DD-{slug}`
- `fix/YYYY-MM-DD-{slug}`

### 並列PR作成時のマージ順序

複数の PR が同時に作成された場合:

1. **独立した変更**: 順序を問わずマージ可能
2. **ファイル競合あり**: 先にマージした PR の変更を後続 PR にリベースしてからマージ
3. **論理的依存あり**: 依存元を先にマージし、依存先は依存元マージ後にリベース

### コンフリクト検出

並列実行完了後、以下のコマンドでコンフリクトを事前検出する:

```bash
# 各ブランチ間の差分ファイル一覧を比較
git diff --name-only main..branch-a
git diff --name-only main..branch-b
# 重複するファイルがあればコンフリクトの可能性を警告
```

### worktree のクリーンアップ

- PR 作成完了後、worktree は自動的にクリーンアップされる（Agent tool が管理）
- 手動で残った worktree は `git worktree prune` で掃除する

## コミット

- コミットメッセージは**日本語**で書く
- コミット前に AskUserQuestion（OK / NG）で確認を取る:
  - 今回の変更概要
  - コミットメッセージ案
