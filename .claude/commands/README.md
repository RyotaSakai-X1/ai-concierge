# コマンド一覧

Claude Code のチャットで使える自動化コマンドの一覧です。

## 使い方

チャット欄に `/{コマンド名}` と入力するだけで実行できます。

## 現在使えるコマンド

| コマンド | 何ができる？ | 使い方の例 |
|---------|------------|-----------|
| `/work-on-issue` | イシュー番号→分析→実装→セルフレビュー→PR作成を一括実行 | `/work-on-issue 12` |
| `/parallel-work` | 複数イシューを worktree 並列で同時実行 | `/parallel-work 12 14 16` |
| `/creating-pr` | 変更からブランチ作成・コミット・プッシュ・PR作成を一括実行 | `/creating-pr ログイン機能を追加` |
| `/reviewing` | 仕様書・成果物・PRをチェックリストに基づいてレビュー | `/reviewing docs/specs/2026-03-09-xxx.md` |
| `/briefing` | PR状況・CI・worktree状態・レビュー依頼を報告 | `/briefing` |
| `/estimating` | スプレッドシートの機能要件から工数を自動見積もり | `/estimating https://docs.google.com/spreadsheets/d/xxx/edit` |
| `/generating-spec` | 仕様書から実装計画・技術設計を生成 | `/generating-spec docs/specs/2026-03-09-xxx.md` |
| `/executing-plan` | タスクリストを順次自律実行 | `/executing-plan docs/outputs/xxx/tasks.md` |
| `/define-requirements` | 案件概要から要件定義書を作成し Google Sheets に書き出し | `/define-requirements https://docs.google.com/document/d/xxx` |
| `/extract-requirements` | ミーティング・ヒアリングデータから情報を構造化抽出 | `/extract-requirements https://drive.google.com/drive/folders/xxx` |
| `/generate-screens` | 要件定義から画面一覧・画面遷移図・レイアウトを自動生成 | `/generate-screens docs/outputs/requirements/2026-03-11-xxx.md` |
| `/wireframe` | 要件・画面設計から FigJam に画面遷移図・フロー図を生成 | `/wireframe docs/outputs/prototypes/2026-03-14-xxx/` |
| `/create-issues-from-meeting` | 議事録・レポートのアクションアイテムからイシュー一括起票 | `/create-issues-from-meeting docs/outputs/meetings/2026-03-11-xxx.md` |
| `/checking-ready` | 指定イシューの着手可否を依存関係から判定 | `/checking-ready 12` |

## コマンドを追加したい場合

「こういう自動化がほしい」と Claude に伝えてください。
CLAUDE.md のルールに従って、コマンドが自動で作成されます。
