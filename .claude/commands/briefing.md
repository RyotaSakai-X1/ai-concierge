# /briefing — エンジニアリングブリーフィング

PR状況・CI・worktree 状態・レビュー依頼をまとめて報告します。

## 手順

### 1. PR状況の確認

自分がアサインされているオープンPRを確認する:

```bash
gh pr list --assignee @me --json number,title,state,checks,reviewDecision,url
```

以下の形式で報告:

```
🔀 オープンPR

- #12: ○○機能を追加（レビュー待ち / CI: ✅ passed）
- #14: △△を修正（変更要求あり / CI: ❌ failed）
- オープンPRなし の場合は「オープンPRはありません」
```

### 2. レビュー依頼の確認

自分にレビューが依頼されているPRを確認する:

```bash
gh pr list --search "review-requested:@me" --json number,title,url,author
```

```
👀 レビュー依頼

- #15: □□の改善（by: username）
- レビュー依頼なし の場合は「レビュー依頼はありません」
```

### 3. Worktree 状態の確認

作業中の worktree を確認する:

```bash
git worktree list
```

```
🌲 Worktree 状態

- /path/to/worktree-1 [branch-a]（作業中）
- メインのみ の場合は「追加の worktree はありません」
```

### 4. イシュー状況の確認

アサイン済み未完了イシューを確認する:

```bash
gh issue list --assignee @me --json number,title,labels,updatedAt
```

```
📋 未完了イシュー

- #12: ○○機能を追加（enhancement, 最終更新: 2日前）
- #16: △△コマンド作成（enhancement, 最終更新: 5日前）⚠️ 放置気味
```

7日以上更新がないイシューには「⚠️ 放置気味」と付ける。

### 5. 直近のマージ状況

直近24時間以内にマージされたPRを確認する:

```bash
gh pr list --state merged --json number,title,mergedAt --limit 5
```

### 6. 今日の作業提案

上記の情報を踏まえ、優先順位付きで今日やるべきことを提案する:

1. CI失敗の修正（最優先）
2. レビュー対応（変更要求への対応）
3. レビュー依頼への対応
4. 未完了イシューの着手

## 注意事項

- 各ステップでエラーが発生した場合（API未接続等）はスキップして次へ進む
- 情報が多い場合は重要度順に絞る
