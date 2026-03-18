# /briefing — エンジニアリングブリーフィング

PR 状況・CI・worktree 状態・レビュー依頼をまとめて報告する。

## Step 1: PR 状況

入力: `gh pr list --assignee @me --json number,title,state,checks,reviewDecision,url`

各 PR の報告項目: 番号 / タイトル / レビュー状態（レビュー待ち / 変更要求あり） / CI 状態（passed / failed）

オープン PR がない場合は「オープン PR はありません」と報告。

## Step 2: レビュー依頼

入力: `gh pr list --search "review-requested:@me" --json number,title,url,author`

各 PR の報告項目: 番号 / タイトル / 作成者

レビュー依頼がない場合は「レビュー依頼はありません」と報告。

## Step 3: Worktree 状態

入力: `git worktree list`

追加の worktree がある場合はパスとブランチ名を表示。メインのみの場合は「追加の worktree はありません」と報告。

## Step 4: イシュー状況

入力: `gh issue list --assignee @me --json number,title,labels,updatedAt`

各イシューの報告項目: 番号 / タイトル / ラベル / 最終更新日

7 日以上更新なしのイシューには「⚠️ 放置気味」を付与。

## Step 5: 直近のマージ状況

入力: `gh pr list --state merged --json number,title,mergedAt --limit 5`

直近 24 時間以内にマージされた PR を報告。

## Step 6: 今日の作業提案

Step 1〜5 の情報を踏まえ、優先順位付きで提案する。

優先順:

| 優先度 | 内容 |
|--------|------|
| 1 | CI 失敗の修正 |
| 2 | レビュー対応（変更要求への対応） |
| 3 | レビュー依頼への対応 |
| 4 | 未完了イシューの着手 |

## 制約

- 各ステップでエラーが発生した場合（API 未接続等）はスキップして次へ進む
- 情報が多い場合は重要度順に絞る
