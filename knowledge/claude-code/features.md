# その他機能（連携・拡張・特殊機能）

> 公式ドキュメント + リリースノート（v2.1.16〜v2.1.74）から抽出。最終更新: 2026-03-12

## エージェント・並列処理

| 機能 | 説明 |
|-----|------|
| Agent Teams | マルチエージェント協調（research preview） |
| `isolation: "worktree"` | エージェントをワークツリーで隔離実行 |
| Agent Memory Scope | `user`/`project`/`local`永続メモリ |

## イベント駆動

| 機能 | 説明 |
|-----|------|
| Hooks | イベント駆動処理（PreTool/PostTool/SessionStart/SessionEnd等） |
| HTTP Hooks | URLにPOSTしてJSON応答受信 |

## 外部サービス連携

| 機能 | 説明 |
|-----|------|
| MCP OAuth | MCPサーバーのOAuth認証 |
| MCP Prompts | MCPサーバー提供のプロンプトをコマンド化 |
| Plugin Marketplace | git/npmソースからプラグイン導入 |
| Remote Control | claude.aiからローカルセッションを操作 |
| Teleport | Webセッションをローカルターミナルに移行 |
| Chrome Integration | ブラウザ自動操作・Webテスト |
| Slack Integration | Slackからバグ報告→PR作成 |
| GitHub Actions | PR自動レビュー・イシュートリアージ |
| GitLab CI/CD | GitLabパイプライン連携 |
| GitHub Code Review | PR自動コードレビュー |

## エディタ・表示

| 機能 | 説明 |
|-----|------|
| Vim Mode | Vim風キーバインド編集 |
| Sandbox | ファイルシステム・ネットワーク隔離実行 |
| Fast Mode | 同一モデルで高速出力 |
| Voice Mode | pushToTalk、20言語STT対応 |
| PR Review Status | PRリンクにレビュー状態を色表示 |
| Prompt Suggestions | 会話履歴ベースの次アクション提案 |

## テンプレート変数

| 変数 | 説明 |
|-----|------|
| `$0`/`$1` | カスタムコマンドの引数参照 |
| `${CLAUDE_SKILL_DIR}` | スキル自身のディレクトリパス参照 |
| `${CLAUDE_SESSION_ID}` | セッションID参照 |

## その他

| 機能 | 説明 |
|-----|------|
| CLAUDE.md `<!-- -->` | HTMLコメントは自動注入時に非表示 |
