# team-design-test

## これは何？

チーム全員が AI（Claude Code）を使って業務を自動化するための実験プロジェクトです。

- エンジニアでなくても、チャットで指示するだけで見積もり・報告書・議事録などが作れます
- PM・営業・エンジニアの垣根を超えて、誰もがより上流の業務に関われる環境を目指します

> **注意**: これはテスト用リポジトリです。ここで検証した内容をベースに、会社のリポジトリへ展開していきます。

## できること一覧

<!-- 新しいコマンドを追加したら、ここに必ず追記してください -->

| やりたいこと | コマンド | 使い方 | 説明 |
|------------|---------|--------|------|
| 見積もりを作りたい | `/estimate` | `/estimate スプシURL` | スプシの機能要件から工数を自動算出し、結果をスプシに書き戻します |
| アイデアを仕様書にしたい | `/process-idea` | `/process-idea` | ideas.md の未処理アイデアを評価・精査して仕様書を自動生成します |
| 仕様書や成果物をチェックしたい | `/review` | `/review docs/specs/xxx.md` | チェックリストに基づいてレビューし、問題点や改善案を提示します |
| 仕様書から実装計画を作りたい | `/generate-spec` | `/generate-spec docs/specs/xxx.md` | 仕様書を読み込んで技術設計・タスクリスト・リスク一覧を生成します |
| タスクを自動実行したい | `/execute-plan` | `/execute-plan docs/outputs/xxx/tasks.md` | タスクリストを順番に実行し、完了レポートを生成します |
| 変更をPRにしたい | `/create-pr` | `/create-pr ログイン機能を追加` | main の変更からブランチ作成・コミット・プッシュ・PR作成を一括実行します |
| イシューの優先順位を知りたい | `/triage` | `/triage` | 全オープンイシューを優先度・依存関係で整理して着手順を提案します |
| このイシュー着手できる？ | `/check-ready` | `/check-ready 12` | 依存イシューの完了状況から着手可否を判定します |
| 今週の作業計画を立てたい | `/sprint-plan` | `/sprint-plan` | 着手可能なイシューから作業計画を自動作成します |

> コマンドは今後どんどん追加されます。「こんなことも自動化できない？」と思ったら、Claude に聞いてみてください。

## はじめかた

1. このリポジトリをクローンする
2. `.env.sample` をコピーして `.env` を作成し、必要な情報を入力する
   ```bash
   cp .env.sample .env
   ```
3. 外部サービスの認証情報を設定する（下の「外部サービスの設定」を参照）
4. Claude Code を起動する
5. 上の「できること一覧」からやりたいことを見つけて、コマンドを入力する

## 外部サービスの設定

Claude Code が Google Workspace 等の外部サービスと連携するために、認証情報の設定が必要です。

### Google Workspace MCP（Gmail / Drive / Docs / Sheets / Calendar 等）

[google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp) を使って Google Workspace と連携します。

**1. Google Cloud Console でプロジェクトを作成**
1. [Google Cloud Console](https://console.cloud.google.com) にアクセス
2. 新しいプロジェクトを作成（または既存のものを選択）

**2. 必要な API を有効化**
「APIとサービス」→「有効なAPIとサービス」で以下を有効化：
- Google Drive API
- Google Docs API
- Google Sheets API
- Gmail API
- Google Calendar API

**3. OAuth 同意画面を設定**
1. 「APIとサービス」→「OAuth 同意画面」を開く
2. ユーザーの種類: **外部** を選択
3. テストユーザーに自分のメールアドレスを追加

**4. OAuth クライアント ID を作成**
1. 「APIとサービス」→「認証情報」→「認証情報を作成」→「OAuth クライアント ID」
2. アプリケーションの種類: **デスクトップアプリケーション**
3. 作成後に表示される **Client ID** と **Client Secret** をコピー

**5. `.env` に設定**
```
GOOGLE_OAUTH_CLIENT_ID=コピーした Client ID
GOOGLE_OAUTH_CLIENT_SECRET=コピーした Client Secret
```

### GitHub

PR 作成やイシュー管理に使用します。

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. 「Generate new token」→ `repo` スコープにチェック → Generate
3. `.env` に設定：
   ```
   GITHUB_PERSONAL_ACCESS_TOKEN=生成したトークン
   ```

### Figma

デザインデータの読み取りに使用します。

1. Figma → 左上のアイコン → Settings → Security → Personal access tokens
2. 「Generate new token」でトークンを生成
3. `.env` に設定：
   ```
   FIGMA_API_KEY=生成したトークン
   ```

## コマンドの使い方

Claude Code のチャット欄に `/{コマンド名}` と入力するだけです。

```
例：見積もりを作りたい場合
/estimate https://docs.google.com/spreadsheets/d/xxxxx/edit
```

## フォルダ構成の概要

| フォルダ | 何が入ってる？ |
|---------|--------------|
| `.claude/commands/` | 自動化コマンドの定義 |
| `knowledge/` | AI に教える判断基準・ビジネスルール・テンプレート |
| `docs/ideas.md` | アイデアの投入口 |
| `docs/specs/` | 精査済み仕様書（自動生成） |
| `docs/outputs/` | 実行結果・生成ファイル（自動生成） |

詳しいルールは [CLAUDE.md](CLAUDE.md) に書かれています。
