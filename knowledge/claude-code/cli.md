# CLIフラグ・サブコマンド一覧

> 公式ドキュメント + リリースノート（v2.1.16〜v2.1.74）から抽出。最終更新: 2026-03-12

## CLIフラグ

| フラグ | 説明 |
|-------|------|
| `--add-dir` | 追加ワーキングディレクトリ指定 |
| `--agent` | エージェント指定 |
| `--agents` | サブエージェントJSON定義 |
| `--allow-dangerously-skip-permissions` | パーミッションバイパスを有効化（オプション） |
| `--allowedTools` | 許可ツールパターン指定 |
| `--append-system-prompt` | システムプロンプトにテキスト追加 |
| `--append-system-prompt-file` | システムプロンプトにファイル内容追加 |
| `--betas` | APIベータヘッダー指定 |
| `--chrome` | Chrome連携有効化 |
| `--continue`, `-c` | 最新セッション継続 |
| `--dangerously-skip-permissions` | 全パーミッションスキップ |
| `--debug` | デバッグモード（カテゴリフィルタ対応） |
| `--disable-slash-commands` | スキル・コマンド無効化 |
| `--disallowedTools` | 禁止ツール指定 |
| `--fallback-model` | フォールバックモデル指定（printモード） |
| `--fork-session` | セッション分岐（resume/continue時） |
| `--from-pr` | PR番号からセッション再開 |
| `--ide` | IDE自動接続 |
| `--init` | 初期化フック実行後に対話モード |
| `--init-only` | 初期化フック実行のみ |
| `--include-partial-messages` | 部分ストリーミングイベント出力 |
| `--input-format` | 入力フォーマット指定（text/stream-json） |
| `--json-schema` | JSON Schema検証出力（printモード） |
| `--maintenance` | メンテナンスフック実行 |
| `--max-budget-usd` | API費用上限（printモード） |
| `--max-turns` | エージェントターン数制限（printモード） |
| `--mcp-config` | MCP設定ファイル指定 |
| `--model` | モデル指定 |
| `--no-chrome` | Chrome連携無効化 |
| `--no-session-persistence` | セッション保存無効化（printモード） |
| `--output-format` | 出力フォーマット（text/json/stream-json） |
| `--permission-mode` | パーミッションモード指定 |
| `--permission-prompt-tool` | パーミッションプロンプト用MCPツール |
| `--plugin-dir` | ローカルプラグインディレクトリ |
| `--print`, `-p` | 非対話モード出力 |
| `--remote` | Webセッション作成 |
| `--resume`, `-r` | セッション再開（ID/名前指定） |
| `--session-id` | カスタムセッションID指定（UUID） |
| `--setting-sources` | 設定ソース指定（user/project/local） |
| `--settings` | 追加設定ファイル/JSON指定 |
| `--strict-mcp-config` | --mcp-configのMCPサーバーのみ使用 |
| `--system-prompt` | システムプロンプト全置換 |
| `--system-prompt-file` | システムプロンプトをファイルから全置換 |
| `--teleport` | Webセッションをローカルに移行 |
| `--teammate-mode` | チームメイト表示方式（auto/in-process/tmux） |
| `--tools` | 使用可能ツール制限 |
| `--verbose` | 詳細ログ出力 |
| `--version`, `-v` | バージョン表示 |
| `--worktree`, `-w` | Gitワークツリー分離実行 |

## CLIサブコマンド

| コマンド | 説明 |
|---------|------|
| `claude` | 対話セッション開始 |
| `claude "query"` | 初期プロンプト付きで開始 |
| `claude -p "query"` | SDK経由で問い合わせ後終了 |
| `claude -c` | 最新セッション継続 |
| `claude -r "<session>"` | セッション再開 |
| `claude update` | 最新版に更新 |
| `claude auth login` | ログイン（`--email`, `--sso`対応） |
| `claude auth logout` | ログアウト |
| `claude auth status` | 認証状態表示（`--text`対応） |
| `claude agents` | エージェント一覧表示 |
| `claude plugins` | プラグイン管理 |
| `claude mcp` | MCPサーバー設定 |
| `claude remote-control` | リモート操作サーバー起動 |
| `claude install` | ネイティブインストール |
