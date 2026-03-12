# 設定・環境変数・キーバインド

> 公式ドキュメント + リリースノート（v2.1.16〜v2.1.74）から抽出。最終更新: 2026-03-12

## 設定（settings.json）

### コア設定

| 設定 | 説明 |
|-----|------|
| `apiKeyHelper` | APIキー生成スクリプト |
| `cleanupPeriodDays` | セッションクリーンアップ期間（デフォルト: 30） |
| `companyAnnouncements` | 起動時アナウンス |
| `env` | セッション環境変数 |
| `attribution` | Git commit/PR帰属表記 |
| `includeGitInstructions` | Gitワークフロー指示をプロンプトに含有 |
| `language` | 応答言語 |
| `outputStyle` | 出力スタイルプリセット |

### パーミッション・セキュリティ

| 設定 | 説明 |
|-----|------|
| `permissions.allow` | 許可ツールパターン |
| `permissions.ask` | 確認要ツールパターン |
| `permissions.deny` | 禁止ツールパターン |
| `permissions.additionalDirectories` | 追加ワーキングディレクトリ |
| `permissions.defaultMode` | デフォルトパーミッションモード |
| `permissions.disableBypassPermissionsMode` | バイパスモード無効化 |

### モデル設定

| 設定 | 説明 |
|-----|------|
| `model` | デフォルトモデル |
| `availableModels` | 選択可能モデル制限 |
| `modelOverrides` | モデルIDのカスタムマッピング |
| `alwaysThinkingEnabled` | 拡張思考をデフォルト有効化 |

### フック・自動化

| 設定 | 説明 |
|-----|------|
| `hooks` | ライフサイクルイベントコマンド |
| `disableAllHooks` | 全フック無効化 |
| `allowedHttpHookUrls` | HTTPフックURL許可リスト |
| `httpHookAllowedEnvVars` | HTTPフック許可環境変数 |

### MCPサーバー

| 設定 | 説明 |
|-----|------|
| `enableAllProjectMcpServers` | プロジェクトMCPサーバー自動承認 |
| `enabledMcpjsonServers` | 承認MCPサーバー指定 |
| `disabledMcpjsonServers` | 拒否MCPサーバー指定 |

### プラグイン

| 設定 | 説明 |
|-----|------|
| `enabledPlugins` | プラグイン有効/無効 |
| `extraKnownMarketplaces` | チームマーケットプレイス |
| `strictKnownMarketplaces` | マーケットプレイス許可リスト |
| `pluginTrustMessage` | プラグイン信頼警告メッセージ |

### UI・表示

| 設定 | 説明 |
|-----|------|
| `statusLine` | カスタムステータスライン |
| `showTurnDuration` | ターン所要時間表示 |
| `spinnerVerbs` | スピナー動詞カスタマイズ |
| `spinnerTipsEnabled` | スピナーチップ表示 |
| `spinnerTipsOverride` | スピナーチップカスタマイズ |
| `terminalProgressBarEnabled` | プログレスバー表示 |
| `prefersReducedMotion` | アニメーション軽減 |
| `fileSuggestion` | `@`ファイル補完カスタマイズ |
| `respectGitignore` | ファイルピッカーで.gitignore尊重 |

### 認証

| 設定 | 説明 |
|-----|------|
| `forceLoginMethod` | ログイン方式制限 |
| `forceLoginOrgUUID` | 組織自動選択 |

### その他

| 設定 | 説明 |
|-----|------|
| `autoUpdatesChannel` | リリースチャネル（stable/latest） |
| `fastModePerSessionOptIn` | Fast Modeのセッション毎オプトイン |
| `plansDirectory` | プランファイル保存先 |
| `teammateMode` | チームメイト表示方式 |
| `autoMemoryDirectory` | 自動メモリ保存先 |

## 環境変数

### 認証・APIキー

| 変数 | 説明 |
|-----|------|
| `ANTHROPIC_API_KEY` | Claude SDK用APIキー |
| `ANTHROPIC_AUTH_TOKEN` | カスタムAuthorizationヘッダー値 |
| `ANTHROPIC_CUSTOM_HEADERS` | カスタムヘッダー |
| `ANTHROPIC_FOUNDRY_API_KEY` | Microsoft Foundry認証 |
| `ANTHROPIC_FOUNDRY_BASE_URL` | FoundryベースURL |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock APIキー |
| `CLAUDE_CODE_CLIENT_CERT` | mTLSクライアント証明書パス |
| `CLAUDE_CODE_CLIENT_KEY` | mTLSクライアントキーパス |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | 資格情報リフレッシュ間隔 |

### モデル設定

| 変数 | 説明 |
|-----|------|
| `ANTHROPIC_MODEL` | 使用モデル |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Haikuクラスモデル |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Sonnetクラスモデル |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Opusクラスモデル |
| `CLAUDE_CODE_EFFORT_LEVEL` | 努力度（low/medium/high） |
| `CLAUDE_CODE_SUBAGENT_MODEL` | サブエージェントモデル |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 最大出力トークン数（デフォルト: 32000） |
| `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | ファイル読込トークン上限 |

### Bash・実行

| 変数 | 説明 |
|-----|------|
| `BASH_DEFAULT_TIMEOUT_MS` | bashデフォルトタイムアウト |
| `BASH_MAX_OUTPUT_LENGTH` | bash出力最大文字数 |
| `BASH_MAX_TIMEOUT_MS` | bash最大タイムアウト |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | bash後に元ディレクトリに戻る |
| `CLAUDE_CODE_SHELL` | シェル検出オーバーライド |
| `CLAUDE_CODE_SHELL_PREFIX` | 全bashコマンドプレフィックス |

### 機能フラグ

| 変数 | 説明 |
|-----|------|
| `CLAUDE_CODE_DISABLE_1M_CONTEXT` | 1Mコンテキスト無効化 |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | 適応的推論無効化 |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | 自動メモリ無効化 |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | バックグラウンドタスク無効化 |
| `CLAUDE_CODE_DISABLE_CRON` | cronジョブ無効化 |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | Fast Mode無効化 |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | フィードバック調査無効化 |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Git指示無効化 |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | 更新・テレメトリ・エラー報告無効化 |
| `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` | ターミナルタイトル更新無効化 |
| `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION` | プロンプト提案有効化 |
| `CLAUDE_CODE_ENABLE_TASKS` | タスクシステム有効化 |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | OpenTelemetryデータ収集 |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Agent Teams有効化 |
| `CLAUDE_CODE_SIMPLE` | 最小システムプロンプトモード |
| `DISABLE_AUTOUPDATER` | 自動更新無効化 |
| `DISABLE_ERROR_REPORTING` | Sentryエラー報告無効化 |

### クラウドプロバイダ

| 変数 | 説明 |
|-----|------|
| `CLAUDE_CODE_USE_BEDROCK` | AWS Bedrock使用 |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | AWS認証スキップ |
| `CLAUDE_CODE_USE_FOUNDRY` | Microsoft Foundry使用 |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Azure認証スキップ |
| `CLAUDE_CODE_USE_VERTEX` | Google Vertex使用 |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Google認証スキップ |

### ファイル・ディレクトリ

| 変数 | 説明 |
|-----|------|
| `CLAUDE_CODE_TMPDIR` | 一時ディレクトリ |
| `CLAUDE_CONFIG_DIR` | 設定ディレクトリ |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | 追加ディレクトリのCLAUDE.md読込 |

### アカウント・組織

| 変数 | 説明 |
|-----|------|
| `CLAUDE_CODE_ACCOUNT_UUID` | アカウントUUID |
| `CLAUDE_CODE_USER_EMAIL` | ユーザーメール |
| `CLAUDE_CODE_ORGANIZATION_UUID` | 組織UUID |
| `CLAUDE_CODE_HIDE_ACCOUNT_INFO` | UI上のアカウント情報非表示 |

### タスク・エージェント

| 変数 | 説明 |
|-----|------|
| `CLAUDE_CODE_TASK_LIST_ID` | タスクリスト共有用ID |
| `CLAUDE_CODE_TEAM_NAME` | エージェントチーム名 |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | 自動圧縮コンテキスト閾値（1-100%） |

### プラグイン

| 変数 | 説明 |
|-----|------|
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | プラグインGitタイムアウト |
| `FORCE_AUTOUPDATE_PLUGINS` | プラグイン自動更新強制 |

### その他

| 変数 | 説明 |
|-----|------|
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEndフック制限時間 |
| `CLAUDE_CODE_PROXY_RESOLVES_HOSTS` | プロキシDNS解決許可 |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | IDE拡張自動インストールスキップ |
| `CLAUDE_CODE_EXIT_AFTER_STOP_DELAY` | アイドル後自動終了遅延（ms） |

## キーバインド

### 一般操作

| キー | 説明 |
|-----|------|
| `Ctrl+C` | 入力/生成キャンセル |
| `Ctrl+D` | セッション終了 |
| `Ctrl+B` | 処理をバックグラウンド化（tmuxはダブル押し） |
| `Ctrl+F` | 全バックグラウンドエージェント終了（ダブル押しで確認） |
| `Ctrl+G` | 外部テキストエディタで編集 |
| `Ctrl+L` | ターミナル画面クリア |
| `Ctrl+O` | 詳細出力切替 |
| `Ctrl+R` | コマンド履歴逆検索 |
| `Ctrl+T` | タスクリスト表示切替 |
| `Ctrl+V` / `Cmd+V` | クリップボード画像貼付 |
| `Esc` + `Esc` | 巻き戻し/要約 |
| `Shift+Tab` / `Alt+M` | パーミッションモード切替 |
| `Alt+P` | モデル切替 |
| `Alt+T` | 拡張思考切替 |

### テキスト編集

| キー | 説明 |
|-----|------|
| `Ctrl+K` | 行末まで削除 |
| `Ctrl+U` | 行全体削除 |
| `Ctrl+Y` | 削除テキスト貼付 |
| `Alt+Y` | ヤンクポップ（kill ring履歴） |
| `Alt+B` | 1単語戻る |
| `Alt+F` | 1単語進む |

### マルチライン入力

| キー | 説明 |
|-----|------|
| `\` + `Enter` | 全ターミナル対応 |
| `Option+Enter` | macOSデフォルト |
| `Shift+Enter` | iTerm2/WezTerm/Ghostty/Kitty対応 |
| `Ctrl+J` | ラインフィード |

### クイック操作

| キー | 説明 |
|-----|------|
| `/` | コマンド/スキル起動 |
| `!` | bashモード直接実行 |
| `@` | ファイルパス補完 |

## 設定ファイル配置

| 種類 | ユーザー | プロジェクト | ローカル |
|-----|---------|------------|---------|
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| Memory | `~/.claude/CLAUDE.md` | `CLAUDE.md` / `.claude/CLAUDE.md` | — |
| Subagents | `~/.claude/agents/` | `.claude/agents/` | — |
| MCP Servers | `~/.claude.json` | `.mcp.json` | `~/.claude.json`（per-project） |
