# Claude Code ユースケース逆引きインデックス

> やりたいことから最適なコマンド・ツール・設定を探す。詳細は各ファイル参照。

## セッション管理

| やりたいこと | 使うもの |
|------------|---------|
| 前回の続きをやりたい | `/resume`, `--continue`, `--resume` |
| セッションを分岐して試したい | `/fork`, `--fork-session` |
| セッション名をつけたい | `/rename` |
| 会話をリセットしたい | `/clear` |
| コンテキストが足りなくなった | `/compact` |
| コンテキスト使用量を確認 | `/context` |
| 会話をエクスポート | `/export` |
| コードを前の状態に戻したい | `/rewind` |

## 定期実行・自動化

| やりたいこと | 使うもの |
|------------|---------|
| コマンドを定期実行したい | `/loop`（例: `/loop 5m /briefing`） |
| cron的にスケジュール実行 | `CronCreate`, `CronDelete`, `CronList` |
| ファイル編集後に自動フォーマット | Hooks（`PostTool` イベント） |
| コミット前に自動チェック | Hooks（`PreTool` イベント） |
| 外部URLに通知したい | HTTP Hooks |
| CI/CDでPR自動レビュー | GitHub Actions, GitLab CI/CD |

## 並列・バックグラウンド処理

| やりたいこと | 使うもの |
|------------|---------|
| 複数タスクを並列実行 | `Agent`ツール（複数同時起動） |
| 処理をバックグラウンドに回す | `Ctrl+B`, `Task*`ツール |
| タスクの進捗を見たい | `/tasks`, `Ctrl+T`, `TaskList` |
| 独立したGit環境で並列作業 | `--worktree`, `EnterWorktree` |
| マルチエージェント協調 | Agent Teams（`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`） |

## 外部連携

| やりたいこと | 使うもの |
|------------|---------|
| MCPサーバーを追加・管理 | `/mcp`, `claude mcp add`, `--mcp-config` |
| Google Drive/Calendar等と連携 | MCP（Google Workspace） |
| Slackと連携 | `/install-slack-app`, Slack Integration |
| GitHub PRコメントを取得 | `/pr-comments` |
| ブラウザを操作したい | `/chrome`, `--chrome` |
| 外出先からセッション操作 | `/remote-control`, `--teleport` |
| Webでセッション開始 | `--remote` |

## モデル・品質調整

| やりたいこと | 使うもの |
|------------|---------|
| モデルを切り替えたい | `/model`, `--model` |
| 推論の深さを調整 | `/effort`, `--effort` |
| 高速に応答してほしい | `/fast` |
| 拡張思考を使いたい | `Alt+T`, `alwaysThinkingEnabled` |
| サブエージェントのモデル指定 | `Agent`ツールの`model`パラメータ |
| 出力トークン上限を変更 | `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |

## コード操作

| やりたいこと | 使うもの |
|------------|---------|
| ファイルを読む | `Read`（PDF pages指定可） |
| ファイルを編集 | `Edit`（差分ベース） |
| ファイルを新規作成 | `Write` |
| ファイルを検索 | `Glob`（パターン）, `Grep`（内容） |
| 定義にジャンプ・参照検索 | `LSP` |
| セキュリティ脆弱性チェック | `/security-review` |
| 未コミット変更を確認 | `/diff` |

## カスタマイズ

| やりたいこと | 使うもの |
|------------|---------|
| プロジェクト固有の指示を設定 | `CLAUDE.md`, `/init`, `/memory` |
| カスタムコマンドを作りたい | `.claude/commands/`にmdファイル作成 |
| カスタムエージェントを定義 | `.claude/agents/`, `--agents` |
| プラグインを導入 | `/plugin`, Plugin Marketplace |
| キーバインドを変更 | `/keybindings` |
| テーマ・色を変更 | `/theme`, `/color` |
| ステータスラインをカスタマイズ | `/statusline` |
| システムプロンプトを変更 | `--system-prompt`, `--append-system-prompt` |
| パーミッションルール設定 | `/permissions`, `permissions.allow/deny` |

## スクリプト・CI利用

| やりたいこと | 使うもの |
|------------|---------|
| 非対話モードで実行 | `--print`, `-p` |
| JSON出力を得たい | `--output-format json` |
| 構造化出力（Schema検証） | `--json-schema` |
| API費用に上限を設ける | `--max-budget-usd` |
| ターン数を制限 | `--max-turns` |
| パイプで入力を渡す | `cat file | claude -p "query"` |

## トラブルシューティング

| やりたいこと | 使うもの |
|------------|---------|
| 環境診断 | `/doctor` |
| デバッグログ確認 | `/debug`, `--debug` |
| 認証状態確認 | `claude auth status` |
| 使用量・コスト確認 | `/cost`, `/usage`, `/stats` |
| セッション分析 | `/insights` |

## 詳細リファレンス

| ファイル | 内容 |
|---------|------|
| [commands.md](commands.md) | スラッシュコマンド全一覧 |
| [cli.md](cli.md) | CLIフラグ・サブコマンド全一覧 |
| [tools.md](tools.md) | ビルトインツール全一覧 |
| [settings.md](settings.md) | 設定・環境変数・キーバインド・設定ファイル配置 |
| [features.md](features.md) | その他機能（連携・拡張・特殊機能） |
