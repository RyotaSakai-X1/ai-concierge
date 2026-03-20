# コマンド一覧

Claude Code のチャットで使える自動化コマンドの一覧です。

## 使い方

チャット欄に `/{コマンド名}` と入力するだけで実行できます。

## 現在使えるコマンド

| コマンド                      | 目的                       | 使用例                                                                                |
| ----------------------------- | -------------------------- | ------------------------------------------------------------------------------------- |
| `/run-pipeline`               | 対話的パイプライン実行     | `/run-pipeline https://docs.google.com/document/d/xxx`                                |
| `/work-on-issue`              | イシュー実装〜PR作成       | `/work-on-issue 12`                                                                   |
| `/parallel-work`              | 複数イシュー並列実行       | `/parallel-work 12 14 16`                                                             |
| `/creating-pr`                | ブランチ作成〜PR作成       | `/creating-pr ログイン機能を追加`                                                     |
| `/reviewing`                  | 成果物・PRレビュー         | `/reviewing docs/specs/2026-03-09-xxx.md`                                             |
| `/briefing`                   | 状況報告                   | `/briefing`                                                                           |
| `/estimating`                 | 工数見積もり               | `/estimating https://docs.google.com/spreadsheets/d/xxx/edit`                         |
| `/create-estimate-doc`        | 見積書生成                 | `/create-estimate-doc https://docs.google.com/spreadsheets/d/xxx/edit`                |
| `/generating-spec`            | 実装計画・技術設計生成     | `/generating-spec docs/specs/2026-03-09-xxx.md`                                       |
| `/executing-plan`             | タスクリスト順次実行       | `/executing-plan docs/outputs/xxx/tasks.md`                                           |
| `/define-requirements`        | 要件定義書作成             | `/define-requirements https://docs.google.com/document/d/xxx`                         |
| `/extract-requirements`       | ヒアリング情報抽出         | `/extract-requirements https://drive.google.com/drive/folders/xxx`                    |
| `/generate-screens`           | 画面一覧・遷移図生成       | `/generate-screens docs/outputs/my-project/requirements.md`                           |
| `/generate-diagrams`          | ダイアグラム生成（Figma 出力） | `/generate-diagrams docs/outputs/my-project/screens/`                                 |
| `/wireframe`                  | ワイヤーフレーム生成（Figma 出力） | `/wireframe docs/outputs/my-project/screens/`                                         |
| `/create-issues-from-meeting` | 議事録からイシュー起票     | `/create-issues-from-meeting docs/outputs/my-project/meetings/2026-03-11-insights.md` |
| `/checking-ready`             | イシュー着手可否判定       | `/checking-ready 12`                                                                  |
| `/sync-design-system`         | デザインシステム同期       | `/sync-design-system https://www.figma.com/design/XXXXX/project`                      |

## パイプラインの流れ

```
/extract-requirements → /define-requirements → /generate-screens → /generate-diagrams → /wireframe → /estimating
```

`/run-pipeline` を使うと、この一連の流れを対話的に実行できます。

## コマンドを追加したい場合

「こういう自動化がほしい」と Claude に伝えてください。
CLAUDE.md のルールに従って、コマンドが自動で作成されます。
