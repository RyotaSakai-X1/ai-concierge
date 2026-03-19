# テックリードのベストプラクティス

## 目的

テックリードが異常時・設計判断時に参照するナレッジ。Claude Code 公式推奨、Agent Teams 運用パターン、コミュニティ知見を集約し、判断の一貫性と再現性を確保する。

## Claude Code 公式ベストプラクティス

出典: https://code.claude.com/docs/en/best-practices

| カテゴリ | 推奨事項 |
|---------|---------|
| コンテキスト管理 | コンテキストウィンドウの 60% を超えないようにする。超過すると出力品質が低下する |
| CLAUDE.md | 100 行以内（約 800 トークン）に収める。Claude Code のシステムプロンプトで約 50 命令枠を消費するため、ユーザー側は 100〜150 命令が上限 |
| タスク分割 | 大きなタスクは複数セッションに分割する。`/clear` で会話履歴をリセットし、CLAUDE.md は再読み込みされる |
| Plan モード | Plan モードを活用するとトークン消費を約半分に削減できる |
| PreCompact フック | コンテキスト圧縮時に重要な指示が失われないよう PreCompact フックを設定する |
| コードインテリジェンス | 型付き言語では LSP プラグインを導入し、シンボルナビゲーションとエラー検出を自動化する |
| レビュー分離 | レビューは新しいセッションで行う。自分が書いたコードへのバイアスを排除するため |

出典: https://www.anthropic.com/events/code-with-claude-2025

## Agent Teams 運用パターン

出典: https://code.claude.com/docs/en/agent-teams

### 適用判断

| 条件 | 推奨アプローチ |
|------|-------------|
| 独立した複数タスクが存在する | Agent Teams（並列実行） |
| タスク間にファイル依存がある | 単一セッション or サブエージェント（逐次実行） |
| 同一ファイルの編集が必要 | 単一セッション（競合回避） |
| 調査・レビュー系の並列作業 | Agent Teams（最も効果的なユースケース） |

### チーム構成の推奨事項

| 項目 | 推奨 |
|------|------|
| チームサイズ | 2〜5 メンバーが実用的な上限 |
| タスク粒度 | 1 メンバー = 1 イシュー or 1 機能単位 |
| ファイル境界 | spawn 時に各メンバーの担当ファイルを明示的に指定する |
| 通信方式 | 共有タスクリスト経由。ファイルの直接共有はしない |
| シングルライターパターン | 共有ファイルへの書き込みは 1 メンバーに限定し、他は読み取りのみ |

### worktree 運用

| 項目 | 推奨 |
|------|------|
| 作成方法 | `claude --worktree feature-name` または `claude -w feature-name` |
| クリーンアップ | 変更なし: 自動削除 / 変更あり: 保持 or 削除を選択 |
| .gitignore | `.claude/worktrees/` を .gitignore に追加する |
| サブエージェント分離 | `isolation: worktree` を frontmatter に追加すると自動で worktree 分離される |

出典: https://claudefa.st/blog/guide/agents/agent-teams, https://claudefa.st/blog/guide/development/worktree-guide

## コミュニティ共有パターン

| パターン | 内容 | 出典 |
|---------|------|------|
| バッチ分割パターン | 50 ファイルの移行を 5 エージェント × 10 ファイルに分割して並列実行 | https://claudefa.st/blog/guide/development/worktree-guide |
| Builder-Validator パターン | 実装エージェントとレビューエージェントを分離し、品質を担保する | https://claudefa.st/blog/guide/agents/team-orchestration |
| インターフェース先行パターン | 実装前にエージェント間の契約（型・API）を定義し、結合時の競合を防ぐ | https://claudefa.st/blog/guide/agents/agent-teams-best-practices |
| CI サブエージェントパターン | CI ポーリング・失敗検出・ログ分析を 1 つのバックグラウンドサブエージェントに委譲する | https://gist.github.com/dfed/38189db88bce59599707ecdd9c5725d9 |
| 60% ルール | コンテキストウィンドウの使用率を 60% 以下に保つ。20〜40% で出力品質低下が始まるとの報告あり | https://institute.sfeir.com/en/claude-code/claude-code-context-management/optimization/ |
| `/clear` 活用 | タスク切り替え時に `/clear` で会話履歴をリセットし、コンテキストを節約する | https://code.claude.com/docs/en/best-practices |

## 異常時の判断フロー

### 主要異常ケースの判断テーブル

| 異常ケース | 検出方法 | 判断基準 | アクション |
|-----------|---------|---------|-----------|
| CI 失敗 | `gh pr checks` でステータス確認 | 失敗ログのエラー分類（lint / test / build） | エラー種別に応じて修正を提案。修正不可能な場合はユーザーに報告 |
| ファイル競合 | `git diff --name-only main..branch` で変更ファイル比較 | 複数ブランチで同一ファイルを変更 | 変更行数が少ない PR を先にマージ → 後続をリベース。解消不能ならユーザーに報告 |
| メンバークラッシュ | 共有タスクリストに進捗報告がない / エラー報告を受信 | メンバーの応答有無・エラー内容 | 他メンバーは継続。クラッシュしたメンバーのタスクはユーザーに報告し、再実行 or 手動対応を判断させる |
| トークン枯渇 | コンテキストウィンドウ使用率の監視 | 60% 超過で警告、80% 超過で対応必須 | タスクを分割して新セッションで継続。スコープを縮小。`/clear` でリセット |
| OAuth トークン期限切れ | 401 認証エラーの発生 | API コール失敗時のエラーコード | 手動での再ログインが必要。ユーザーに `claude login` の実行を依頼する |
| ネットワークエラー（push/PR） | `git push` / `gh pr create` の失敗 | HTTP エラーコード | 最大 3 回リトライ（2秒、4秒、8秒の指数バックオフ）。上限超過でユーザーに報告 |
| イシュー本文の曖昧さ | メンバーからの情報不足報告 | 仕様未定義・判断材料の欠如 | メンバーの処理を中断し、ユーザーに仕様確認を求める |

### 判断の優先順位

1. **安全性**: データ損失・本番影響のリスクがある場合は即座に中断しユーザーに報告
2. **継続性**: 他メンバーに影響しない異常は、該当メンバーのみ中断し他は継続
3. **効率性**: 自動リカバリ可能な異常（リトライで解消するネットワークエラー等）は自動対応
4. **透明性**: すべての異常とその対応をユーザーに報告する

## 将来検討事項

- `/update-best-practices` コマンド（Web 検索でベストプラクティスを自動更新するワークフロー）は Phase 1 スコープ外として見送り、Phase 2 以降で検討する
- Agent Teams の安定版リリースに合わせて運用パターンを更新する
- OAuth トークン自動更新の仕組みが公式に実装された場合、異常時フローを簡素化する

## 参考リンク

### 公式ドキュメント

- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices)
- [Agent Teams — Claude Code Docs](https://code.claude.com/docs/en/agent-teams)
- [Common Workflows — Claude Code Docs](https://code.claude.com/docs/en/common-workflows)
- [Context Windows — Claude API Docs](https://platform.claude.com/docs/en/build-with-claude/context-windows)
- [How Anthropic teams use Claude Code（PDF）](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf)
- [Code w/ Claude — Anthropic Developer Conference](https://www.anthropic.com/events/code-with-claude-2025)

### コミュニティリソース

- [Claude Code Agent Teams Best Practices & Troubleshooting](https://claudefa.st/blog/guide/agents/agent-teams-best-practices)
- [Claude Code Worktrees: Run Parallel Sessions Without Conflicts](https://claudefa.st/blog/guide/development/worktree-guide)
- [Claude Code Sub-Agents: Parallel vs Sequential Patterns](https://claudefa.st/blog/guide/agents/sub-agent-best-practices)
- [Claude Code Team Orchestration: Builder-Validator Patterns](https://claudefa.st/blog/guide/agents/team-orchestration)
- [Context Management Optimization — SFEIR Institute](https://institute.sfeir.com/en/claude-code/claude-code-context-management/optimization/)
- [Claude Code Ultimate Guide（GitHub）](https://github.com/FlorianBruniaux/claude-code-ultimate-guide)
- [Shipping faster with Claude Code and Git Worktrees — incident.io](https://incident.io/blog/shipping-faster-with-claude-code-and-git-worktrees)
- [CI Sub-Agent Pattern（GitHub Gist）](https://gist.github.com/dfed/38189db88bce59599707ecdd9c5725d9)
