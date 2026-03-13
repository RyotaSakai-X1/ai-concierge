# /parallel-work — 複数イシューの並列実行

複数のイシュー番号を受け取り、依存関係をチェックした上で、独立したイシューを Agent tool（worktree 分離）で並列実行します。

## 引数

- `$ARGUMENTS` — スペース区切りのイシュー番号（例: `12 14 16`）

## 実行手順

### Step 1: イシュー情報の取得

各イシューの情報を取得する:

```bash
gh issue view {番号} --json title,body,labels,assignees
```

### Step 2: 依存関係チェック

イシュー間の依存関係を分析する:

1. イシュー本文に `depends on #XX` や `blocked by #XX` がないか確認
2. 各イシューの影響ファイルを推定し、ファイル競合の可能性を検出
3. 結果を以下に分類:
   - **独立**: 並列実行可能
   - **依存あり**: 順次実行が必要（依存元を先に実行）
   - **競合リスク**: 並列実行可能だが、マージ時にコンフリクトの可能性あり

### Step 3: 実行計画の提示

分析結果をユーザーに提示し、AskUserQuestion で承認を得る:

```
📋 並列実行計画

並列実行（独立）:
  - #12: ○○機能を追加
  - #14: △△を修正

順次実行（依存あり）:
  - #16: □□を追加（#12 に依存）

⚠️ 競合リスク:
  - #12 と #14 は knowledge/rules/git-workflow.md を両方変更する可能性

選択肢: [実行する / 計画を修正する / キャンセル]
```

### Step 4: 並列実行

独立したイシューを Agent tool で並列起動する:

```
Agent(
  prompt: "/work-on-issue {番号}",
  isolation: "worktree",
  description: "Issue #{番号} の実装"
)
```

- 各 Agent は独立した worktree で作業するため、互いに干渉しない
- `knowledge/rules/parallel-execution.md` のルールに従う

### Step 5: 結果集約

全 Agent の完了を待ち、結果を集約する:

1. 各 Agent の実行結果（成功/失敗、PR URL）を収集
2. 失敗したイシューがあれば、エラー内容を報告
3. コンフリクト検出:
   ```bash
   # 各PRのブランチで変更されたファイルを比較
   git diff --name-only main..{branch-a}
   git diff --name-only main..{branch-b}
   ```
4. 重複ファイルがあればコンフリクトリスクを警告

### Step 6: マージ順序の提案

```
✅ 並列実行完了

成功:
  - #12: PR #XX（https://github.com/...）
  - #14: PR #YY（https://github.com/...）

失敗:
  - なし

⚠️ コンフリクトリスク:
  - PR #XX と PR #YY は git-workflow.md を共有 → #XX を先にマージ推奨

推奨マージ順序: #XX → #YY
```

### Step 7: 順次実行（依存ありのイシュー）

Step 4 の並列実行が完了し、依存元の PR がマージされた後に、依存ありのイシューを順次実行する。

## 注意事項

- 最大並列数は 3 を推奨（リソース消費を考慮）
- 1つの Agent が失敗しても、他の Agent は影響を受けない
- worktree は Agent 完了後に自動クリーンアップされる
- 大規模な変更を含むイシューは並列実行ではなく単独実行を推奨
