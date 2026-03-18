# /creating-pr — 変更からブランチ作成〜PR 作成を自動化

未コミット変更をフィーチャーブランチに移して PR を作成する。

## 引数

- `$ARGUMENTS` — PR タイトルのヒント（省略時は変更内容から自動生成）

## Step 1: 前提チェック

入力: `git status` + `git rev-parse --git-dir` / `git rev-parse --git-common-dir`

実行コンテキストの判定:

| コンテキスト | 判定条件 | 動作 |
|------------|---------|------|
| 通常実行（main 上） | worktree でない かつ main ブランチ | Step 2 でブランチ作成 |
| worktree 内実行 | worktree 検出 | ブランチ作成スキップ → Step 3 へ |
| 既存ブランチ上 | worktree でない かつ main 以外 | 現ブランチで続行するか確認 |

変更（staged / unstaged / untracked）がゼロの場合は終了する。

## Step 2: ブランチ作成（通常実行時のみ）

ブランチ名: `feature/YYYY-MM-DD-{slug}`（変更内容から slug を決定）

## Step 3: コミット

入力: `git diff` + `git diff --cached` + `git status`

決定する項目:

| 項目 | ルール |
|------|--------|
| コミットメッセージ | 変更内容を日本語で簡潔に |
| PR タイトル | `$ARGUMENTS` があれば活用、なければ変更内容から生成 |
| PR 本文 | 変更ファイル一覧と概要を Markdown で作成 |

`git add -A` → `git commit`

## Step 4: プッシュ

| コンテキスト | プッシュ先ブランチ |
|------------|------------------|
| 通常実行 | Step 2 で作成したブランチ |
| worktree 内実行 | 現在のブランチ（`git branch --show-current`） |

`git push -u origin {ブランチ名}`。ネットワークエラー時は最大 4 回、指数バックオフ（2s, 4s, 8s, 16s）でリトライ。

## Step 5: PR 作成

`gh pr create --title "PRタイトル" --body "PR本文" --base main --assignee @me`

gh が使えない場合は PR 作成用 URL・タイトル案・本文案をユーザーに提示する。

## Step 6: イシューステータス更新

PR に `Closes #XX` で紐づけたイシューがある場合、`.claude/rules/git-workflow.md` の「イシューステータスの更新」手順に従い **In review** に変更する。

## Step 7: main に戻る

| コンテキスト | 動作 |
|------------|------|
| 通常実行 | `git checkout main` |
| worktree 内実行 | スキップ（worktree はそのまま維持） |

## 制約

- force push・ブランチ削除は行わない
- コミット前に変更内容のサマリをユーザーに表示する
- `.env` や秘密情報を含むファイルがあれば警告する
- worktree 内ではブランチ作成しない。worktree の削除は呼び出し元が管理する
- worktree 分離ルール（`.claude/rules/git-workflow.md`）に従う
