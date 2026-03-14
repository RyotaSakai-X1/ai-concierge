# /creating-pr — 変更からブランチ作成〜PR作成を自動化

あなたは Git ワークフロー自動化エージェントです。
未コミット変更を、フィーチャーブランチに移してPRを作成します。

## 引数

- `$ARGUMENTS` — PRタイトルのヒント（省略した場合は変更内容から自動生成）

## 実行手順

### Step 1: 前提チェック

1. `git status` で現在のブランチと変更状態を確認する
2. worktree 内で実行されているかを判定する: `git rev-parse --git-dir` と `git rev-parse --git-common-dir` を比較し、異なれば worktree 内
3. worktree 内の場合、`git branch --show-current` で現在のブランチ名を取得しておく（以降のステップで使用）
4. 実行コンテキストに応じた分岐:

| コンテキスト | 判定条件 | 次のステップ |
|------------|---------|------------|
| 通常実行（main ブランチ上） | worktree でない かつ main ブランチ | Step 3 でブランチ作成 |
| worktree 内実行 | worktree 検出 | ブランチ作成スキップ → Step 4 へ |
| 既存ブランチ上 | worktree でない かつ main 以外 | 現ブランチでPR作成を続行するか確認 |

5. **変更（staged / unstaged / untracked）がゼロの場合**: 「変更がありません。先にファイルを編集してから `/creating-pr` を実行してください。」と伝えて終了する

### Step 2: 変更内容の分析

1. `git diff` と `git diff --cached` と `git status` の出力をすべて確認する
2. 変更内容を要約し、以下を決定する:
   - **ブランチ名のslug**: 変更内容を英語の短いキーワードで表現（例: `add-create-pr-command`, `fix-login-bug`）
   - **コミットメッセージ**: 変更内容を日本語で簡潔に（例: `PR自動作成コマンドを追加`）
   - **PRタイトル**: `$ARGUMENTS` があればそれを活用、なければ変更内容から生成（日本語）
   - **PR本文**: 変更ファイル一覧と概要を Markdown で作成

### Step 3: ブランチ作成

1. ブランチ名を `feature/YYYY-MM-DD-{slug}` 形式で決定する（YYYY-MM-DD は今日の日付）
2. `git checkout -b feature/YYYY-MM-DD-{slug}` を実行する

### Step 4: コミット

1. `git add -A` ですべての変更をステージングする
2. `git commit -m "コミットメッセージ"` でコミットを作成する

### Step 5: プッシュ

プッシュ対象のブランチ名を決定する:

| コンテキスト | ブランチ名 |
|------------|----------|
| 通常実行 | Step 3 で作成した `feature/YYYY-MM-DD-{slug}` |
| worktree 内実行 | Step 1 で取得した現在のブランチ名（`git branch --show-current`） |

`git push -u origin {ブランチ名}` を実行する。

ネットワークエラーの場合は最大4回、指数バックオフ（2s, 4s, 8s, 16s）でリトライする。

### Step 6: PR作成

`gh` CLI が使えるか確認する。

**gh が使える場合:**

`gh pr create --title "PRタイトル" --body "PR本文" --base main --assignee @me` を実行する。

**gh が使えない場合:**

以下の情報をユーザーに提示する:

- PR作成用URL: `https://github.com/{owner}/{repo}/compare/main...feature/YYYY-MM-DD-{slug}?expand=1`
- PRタイトル案
- PR本文案

### Step 7: イシューステータスを In review に変更

PR に `Closes #XX` で紐づけたイシューがある場合、`.claude/rules/git-workflow.md` の「イシューステータスの更新」手順に従い、ステータスを **In review** に変更する。

### Step 8: main に戻る

worktree 内実行の場合はこのステップをスキップする（worktree はそのまま維持）。

通常実行の場合は `git checkout main` を実行する。

## 注意事項

- 危険な操作（force push, ブランチ削除等）は絶対に行わない
- コミット前に変更内容のサマリをユーザーに表示してから進める
- `.env` や秘密情報を含むファイルがあれば警告する

### worktree 内実行時の注意

- ブランチ名は worktree が自動設定したものを使用する（自分でブランチを作成しない）
- worktree 内のパスは通常のリポジトリパスと異なるため、`git rev-parse --show-toplevel` でルートを確認する
- worktree 完了後のクリーンアップは呼び出し元（`/parallel-work` 等）が管理するため、worktree の削除は行わない
- worktree 分離ルールに従い、他の worktree やメインの作業ディレクトリを変更しない（詳細は `.claude/rules/git-workflow.md` の「Worktree 分離ルール」を参照）
