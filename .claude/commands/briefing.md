# /briefing — エンジニアリングブリーフィング

PR状況・CI・worktree 状態・レビュー依頼をまとめて報告します。

## 手順

### 1. PR状況の確認

`gh pr list --assignee @me --json number,title,state,checks,reviewDecision,url` で自分がアサインされているオープンPRを確認する。

以下の形式で報告:

**オープンPR一覧** — 各PRについて番号、タイトル、レビュー状態（レビュー待ち / 変更要求あり）、CI状態（passed / failed）を表示する。オープンPRがない場合は「オープンPRはありません」と報告する。

### 2. レビュー依頼の確認

`gh pr list --search "review-requested:@me" --json number,title,url,author` で自分にレビューが依頼されているPRを確認する。

各PRについて番号、タイトル、作成者を表示する。レビュー依頼がない場合は「レビュー依頼はありません」と報告する。

### 3. Worktree 状態の確認

`git worktree list` で作業中の worktree を確認する。

追加の worktree がある場合はパスとブランチ名を表示する。メインのみの場合は「追加の worktree はありません」と報告する。

### 4. イシュー状況の確認

`gh issue list --assignee @me --json number,title,labels,updatedAt` でアサイン済み未完了イシューを確認する。

各イシューについて番号、タイトル、ラベル、最終更新日を表示する。7日以上更新がないイシューには「⚠️ 放置気味」と付ける。

### 5. 直近のマージ状況

`gh pr list --state merged --json number,title,mergedAt --limit 5` で直近24時間以内にマージされたPRを確認する。

### 6. 今日の作業提案

上記の情報を踏まえ、優先順位付きで今日やるべきことを提案する:

1. CI失敗の修正（最優先）
2. レビュー対応（変更要求への対応）
3. レビュー依頼への対応
4. 未完了イシューの着手

## 注意事項

- 各ステップでエラーが発生した場合（API未接続等）はスキップして次へ進む
- 情報が多い場合は重要度順に絞る
