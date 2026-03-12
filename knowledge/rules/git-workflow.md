# Git ワークフロー詳細

## ブランチ運用

- **main に直接コミットしない**。すべての変更はブランチ → PR 経由
- ブランチ名: `feature/YYYY-MM-DD-{スラグ}`（修正は `fix/`）

### 作業の流れ

1. `git checkout -b feature/YYYY-MM-DD-{slug}` でブランチ作成
2. 関連イシューのステータスを **In progress** に変更する（後述「イシューステータスの更新」参照）
3. 作業・コミット
4. **PR 作成前に必ずローカルで `/review` を実行する**
5. レビューで指摘があれば修正してから次へ進む
6. `git push -u origin {ブランチ名}` でプッシュ
7. `gh pr create --assignee @me` で PR 作成
   - Assignees に自分を追加する（`--assignee @me`）
   - レビュー結果を PR 本文に含める
   - 関連イシューがあれば PR 本文に `Closes #XX` を記載して紐づける
8. 関連イシューのステータスを **In review** に変更する
9. ユーザーが最終レビュー・マージ

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

## コミット

- コミットメッセージは**日本語**で書く
- コミット前に AskUserQuestion（OK / NG）で確認を取る:
  - 今回の変更概要
  - コミットメッセージ案

## イシューステータスの更新

GitHub Projects のステータスを以下のタイミングで変更する：

| タイミング | ステータス |
|-----------|-----------|
| イシューに着手（ブランチ作成時） | **In progress** |
| PR 作成後 | **In review** |
| PR マージ後 | **Done**（GitHub の自動化で設定済み） |

### 更新コマンド

```bash
# 1. イシューの Project Item ID を取得
ITEM_ID=$(gh project item-list 1 --owner RyotaSakai-X1 --format json \
  | jq -r '.items[] | select(.content.number == {イシュー番号} and .content.type == "Issue") | .id')

# 2. ステータスを変更
gh project item-edit --project-id PVT_kwHOB_Hl9M4BRRtG \
  --id "$ITEM_ID" \
  --field-id PVTSSF_lAHOB_Hl9M4BRRtGzg_Jsyk \
  --single-select-option-id {ステータスのオプションID}
```

ステータスのオプション ID:
- `47fc9ee4` — In progress
- `df73e18b` — In review
- `98236657` — Done
