# /creating-pr — main の変更からブランチ作成〜PR作成を自動化

あなたは Git ワークフロー自動化エージェントです。
`main` ブランチ上の未コミット変更を、フィーチャーブランチに移してPRを作成します。

## 引数

- `$ARGUMENTS` — PRタイトルのヒント（省略した場合は変更内容から自動生成）

## 実行手順

### Step 1: 前提チェック

1. `git status` で現在のブランチと変更状態を確認する
2. **現在 `main` ブランチにいない場合**: 「⚠️ 現在 `{ブランチ名}` にいます。`main` ブランチに切り替えてから再実行してください。」と伝えて終了する
3. **変更（staged / unstaged / untracked）がゼロの場合**: 「変更がありません。先にファイルを編集してから `/creating-pr` を実行してください。」と伝えて終了する

### Step 2: 変更内容の分析

1. `git diff` と `git diff --cached` と `git status` の出力をすべて確認する
2. 変更内容を要約し、以下を決定する:
   - **ブランチ名のslug**: 変更内容を英語の短いキーワードで表現（例: `add-create-pr-command`, `fix-login-bug`）
   - **コミットメッセージ**: 変更内容を日本語で簡潔に（例: `PR自動作成コマンドを追加`）
   - **PRタイトル**: `$ARGUMENTS` があればそれを活用、なければ変更内容から生成（日本語）
   - **PR本文**: 変更ファイル一覧と概要を Markdown で作成

### Step 3: ブランチ作成

1. ブランチ名を `feature/YYYY-MM-DD-{slug}` 形式で決定する（YYYY-MM-DD は今日の日付）
2. 以下を実行:
   ```bash
   git checkout -b feature/YYYY-MM-DD-{slug}
   ```

### Step 4: コミット

1. すべての変更をステージング:
   ```bash
   git add -A
   ```
2. コミットを作成:
   ```bash
   git commit -m "コミットメッセージ"
   ```

### Step 5: プッシュ

```bash
git push -u origin feature/YYYY-MM-DD-{slug}
```

ネットワークエラーの場合は最大4回、指数バックオフ（2s, 4s, 8s, 16s）でリトライする。

### Step 6: PR作成

`gh` CLI が使えるか確認する:

**gh が使える場合:**
```bash
gh pr create --title "PRタイトル" --body "PR本文" --base main --assignee @me
```

**gh が使えない場合:**
以下のようにユーザーにURLを提示する:
```
✅ ブランチをプッシュしました！
以下のURLからPRを作成してください:

https://github.com/{owner}/{repo}/compare/main...feature/YYYY-MM-DD-{slug}?expand=1

---
📋 PRタイトル案: {タイトル}

📝 PR本文案:
{本文}
```

### Step 7: main に戻る

```bash
git checkout main
```

## 注意事項

- 危険な操作（force push, ブランチ削除等）は絶対に行わない
- コミット前に変更内容のサマリをユーザーに表示してから進める
- `.env` や秘密情報を含むファイルがあれば警告する
