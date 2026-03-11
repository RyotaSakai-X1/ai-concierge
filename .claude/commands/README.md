# コマンド一覧

Claude Code のチャットで使える自動化コマンドの一覧です。

## 使い方

チャット欄に `/{コマンド名}` と入力するだけで実行できます。

## 現在使えるコマンド

| コマンド | 何ができる？ | 使い方の例 |
|---------|------------|-----------|
| `/estimating` | スプレッドシートの機能要件から工数を自動見積もり | `/estimating https://docs.google.com/spreadsheets/d/xxx/edit` |
| `/processing-idea` | アイデアを精査・評価して仕様書を自動生成 | `/processing-idea` または `/processing-idea --dry-run` |
| `/generating-spec` | 仕様書から実装計画・技術設計を生成 | `/generating-spec docs/specs/2026-03-09-xxx.md` |
| `/reviewing` | 仕様書や成果物をチェックリストに基づいてレビュー | `/reviewing docs/specs/2026-03-09-xxx.md` |
| `/executing-plan` | タスクリストを順次自律実行 | `/executing-plan docs/outputs/xxx/tasks.md` |
| `/creating-pr` | 変更からブランチ作成・コミット・プッシュ・PR作成を一括実行 | `/creating-pr ログイン機能を追加` |
| `/triaging` | 全オープンイシューを優先度・依存関係で整理して着手順を提案 | `/triaging` |
| `/checking-ready` | 指定イシューの着手可否を依存関係から判定 | `/checking-ready 12` |
| `/sprint-planning` | 着手可能なイシューから直近の作業計画を作成 | `/sprint-planning` または `/sprint-planning --days 5` |

## コマンドを追加したい場合

「こういう自動化がほしい」と Claude に伝えてください。
CLAUDE.md のルールに従って、コマンドが自動で作成されます。
