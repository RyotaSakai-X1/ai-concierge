# コマンド一覧

Claude Code のチャットで使える自動化コマンドの一覧です。

## 使い方

チャット欄に `/{コマンド名}` と入力するだけで実行できます。

## 現在使えるコマンド

| コマンド | 何ができる？ | 使い方の例 |
|---------|------------|-----------|
| `/estimate` | スプレッドシートの機能要件から工数を自動見積もり | `/estimate https://docs.google.com/spreadsheets/d/xxx/edit` |
| `/process-idea` | アイデアを精査・評価して仕様書を自動生成 | `/process-idea` または `/process-idea --dry-run` |
| `/generate-spec` | 仕様書から実装計画・技術設計を生成 | `/generate-spec docs/specs/2026-03-09-xxx.md` |
| `/review` | 仕様書や成果物をチェックリストに基づいてレビュー | `/review docs/specs/2026-03-09-xxx.md` |
| `/execute-plan` | タスクリストを順次自律実行 | `/execute-plan docs/outputs/xxx/tasks.md` |
| `/create-pr` | 変更からブランチ作成・コミット・プッシュ・PR作成を一括実行 | `/create-pr ログイン機能を追加` |
| `/triage` | 全オープンイシューを優先度・依存関係で整理して着手順を提案 | `/triage` |
| `/check-ready` | 指定イシューの着手可否を依存関係から判定 | `/check-ready 12` |
| `/sprint-plan` | 着手可能なイシューから直近の作業計画を作成 | `/sprint-plan` または `/sprint-plan --days 5` |

## コマンドを追加したい場合

「こういう自動化がほしい」と Claude に伝えてください。
CLAUDE.md のルールに従って、コマンドが自動で作成されます。
