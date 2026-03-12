#!/bin/bash
# ============================================================
# Issue 管理スクリプト
# 使い方: gh auth login 後に実行
#   chmod +x docs/outputs/manage-issues.sh
#   ./docs/outputs/manage-issues.sh
# ============================================================

set -euo pipefail

REPO="RyotaSakai-X1/ai-concierge"

echo "================================================"
echo "  Phase 1: 既存Issueの棚卸し"
echo "================================================"
echo ""
echo "まず既存のオープンIssueを確認してください："
echo "  gh issue list --repo $REPO --state open"
echo ""
echo "以下のIssueは方針変更により Close 候補です："
echo "（中身を確認してから判断してください）"
echo ""
echo "  #12 /create-estimate-doc — 営業PMレーン。Cowork移行の可能性あり"
echo "  #13 /define-requirements — 営業PMレーン。Cowork移行の可能性あり"
echo "  #14 /wireframe — 営業PMレーン。Cowork移行の可能性あり"
echo "  #15 main直コミット禁止 — 方針変更。並列対応の新Issueで再定義"
echo "  #16 /work-on-issue — 方針変更。Agent Teams方式で再設計"
echo "  #17 /create-pr イシュー連携 — creating-prの並列対応Issueで再定義"
echo ""
echo "Close する場合は以下を実行："
echo '  gh issue close <NUMBER> --repo '$REPO' --comment "方針変更（Agent Teams + Worktree 対応）により、新しいIssueで再定義します。詳細: docs/decisions/001_agent-teams-architecture.md"'
echo ""

read -p "Issueの棚卸しが完了したら Enter を押してください（スキップ可）..." _

echo ""
echo "================================================"
echo "  Phase 2: ラベル作成"
echo "================================================"

# Phase ラベル
gh label create "Phase 1.5" --repo "$REPO" --color "FEF3C7" --description "構造整理・並列対応準備" 2>/dev/null || echo "Label 'Phase 1.5' already exists"
gh label create "Phase 2" --repo "$REPO" --color "DBEAFE" --description "Agent Teams + Worktree 並列実行基盤" 2>/dev/null || echo "Label 'Phase 2' already exists"

# Priority ラベル（既存でなければ作成）
gh label create "high" --repo "$REPO" --color "DC2626" --description "優先度：高" 2>/dev/null || echo "Label 'high' already exists"
gh label create "medium" --repo "$REPO" --color "F59E0B" --description "優先度：中" 2>/dev/null || echo "Label 'medium' already exists"
gh label create "low" --repo "$REPO" --color "10B981" --description "優先度：低" 2>/dev/null || echo "Label 'low' already exists"

# Type ラベル
gh label create "structure" --repo "$REPO" --color "8B5CF6" --description "構造整理" 2>/dev/null || echo "Label 'structure' already exists"
gh label create "infrastructure" --repo "$REPO" --color "6366F1" --description "基盤構築" 2>/dev/null || echo "Label 'infrastructure' already exists"
gh label create "documentation" --repo "$REPO" --color "60A5FA" --description "ドキュメント" 2>/dev/null || echo "Label 'documentation' already exists"

echo ""
echo "================================================"
echo "  Phase 3: 新規Issue作成"
echo "================================================"

# ── A. 構造整理系（Phase 1.5）──

gh issue create --repo "$REPO" \
  --title "【Phase 1.5】CLAUDE.md の軽量化・エンジニア特化" \
  --label "Phase 1.5,high,structure" \
  --body "$(cat <<'BODY'
## 概要

現在の CLAUDE.md は単一エージェント逐次実行を前提とし、エンジニア/非エンジニア向けの内容が混在している。
Agent Teams + Worktree 方式に対応するため、以下を行う。

## チェックリスト

- [ ] 非エンジニア系の記述を削除（ブリーフィング手順、議事録フロー等）
- [ ] 「並列実行モード」セクションを追加
- [ ] 「秘書」ロールの記述を「開発チームオーケストレーター」に変更
- [ ] 単一エージェント前提の記述を修正（「mainに戻るか聞く」等）
- [ ] `.claude/agents/` ディレクトリへの参照を追加

## 関連

- ADR: docs/decisions/001_agent-teams-architecture.md
BODY
)"

echo "Created: CLAUDE.md の軽量化・エンジニア特化"

gh issue create --repo "$REPO" \
  --title "【Phase 1.5】非エンジニア系コマンドのCowork移行準備" \
  --label "Phase 1.5,medium,structure" \
  --body "$(cat <<'BODY'
## 概要

`/briefing` と `/meeting-summary` は Cowork に移行する。
移行前に引き継ぎドキュメントを作成し、このリポジトリからは削除する。

## チェックリスト

- [ ] `/briefing` コマンドの機能仕様をドキュメント化
- [ ] `/meeting-summary` コマンドの機能仕様をドキュメント化
- [ ] Cowork 側での再現方法を記述
- [ ] このリポジトリから該当コマンドファイルを削除
- [ ] CLAUDE.md から関連記述を削除
- [ ] README.md のコマンド一覧を更新

## 備考

PM系コマンド（`/triaging`, `/sprint-planning`, `/estimating`）は一旦残す。
GitHub API 操作が必要なため Cowork では代替しづらい。後で再判断。
BODY
)"

echo "Created: 非エンジニア系コマンドのCowork移行準備"

gh issue create --repo "$REPO" \
  --title "【Phase 1.5】git-workflow.md の並列実行対応改修" \
  --label "Phase 1.5,high,structure" \
  --body "$(cat <<'BODY'
## 概要

現在の git-workflow.md は単一エージェントの逐次実行を前提としている。
Agent Teams + Worktree 方式で複数エージェントが並列にブランチ操作できるよう改修する。

## チェックリスト

- [ ] ブランチ命名規則を変更: `feature/{agent-id}/YYYY-MM-DD-{slug}`
- [ ] 「mainに戻るか聞く」フローを廃止
- [ ] worktree 作成・クリーンアップのルールを追加
- [ ] 並列 PR マージ時のコンフリクト対応ルールを追加
- [ ] ブランチ自動削除ルールを worktree 対応に修正

## 現状の問題点

1. ブランチ名に agent-id がないため、同日に同じ slug だと衝突する
2. 「mainに戻るか聞く」は並列エージェントでは無意味
3. `git fetch --prune` + `git branch --merged` が他エージェントのブランチを巻き込む可能性
BODY
)"

echo "Created: git-workflow.md の並列実行対応改修"

# ── B. エージェント定義系（Phase 2）──

gh issue create --repo "$REPO" \
  --title "【Phase 2】.claude/agents/ エージェント定義ファイルの作成" \
  --label "Phase 2,high,infrastructure" \
  --body "$(cat <<'BODY'
## 概要

エージェントチーム組織図に基づき、各ロールの振る舞い定義ファイルを作成する。

## チェックリスト

- [ ] `orchestrator.md` — 司令塔: Issue割り振り、進捗監視、衝突調停
- [ ] `engineer-leader.md` — エンジニアリーダー: 技術方針、PRレビュー、タスク分配
- [ ] `engineer-worker.md` — エンジニアワーカー: worktreeでのIssue実装
- [ ] `tester-leader.md` — テスターリーダー: テスト戦略、品質基準
- [ ] `tester-worker.md` — テスターワーカー: PRレビュー・テスト実行
- [ ] `designer.md` — デザイナー: ワイヤーフレーム・モック作成

## 各定義ファイルに含める内容

- ロール名・責務
- 使用可能なコマンド
- 判断基準（何を自律で行い、何をリーダーに相談するか）
- 出力先ディレクトリ
- 状態報告のフォーマット
BODY
)"

echo "Created: .claude/agents/ エージェント定義ファイルの作成"

gh issue create --repo "$REPO" \
  --title "【Phase 2】並列実行ルール（parallel-execution.md）の策定" \
  --label "Phase 2,high,infrastructure" \
  --body "$(cat <<'BODY'
## 概要

複数エージェントが同時に動作する際のルールを策定する。

## チェックリスト

- [ ] タスクロック機構の定義（同一Issueに複数エージェントが着手しない）
- [ ] ブランチ名衝突防止ルール
- [ ] 冪等性チェックの仕組み（PRが既に存在するか確認してから作成）
- [ ] worktree のライフサイクル管理ルール
- [ ] エージェント間の状態共有プロトコル
- [ ] 重複作業の検知と回避手順
- [ ] 障害時のフォールバック手順（エージェントが応答しない場合）

## 関連

- `.claude/status/agents.json` の設計と連動
BODY
)"

echo "Created: 並列実行ルールの策定"

gh issue create --repo "$REPO" \
  --title "【Phase 2】エージェント間状態共有（.claude/status/）の構築" \
  --label "Phase 2,medium,infrastructure" \
  --body "$(cat <<'BODY'
## 概要

複数エージェントが互いの状態を把握するための仕組みを構築する。

## チェックリスト

- [ ] `.claude/status/agents.json` のスキーマ設計
- [ ] エージェント登録・状態更新のロジック
- [ ] タスク割り当て時のロック取得フロー
- [ ] タスク完了時のロック解放フロー
- [ ] 状態一覧表示コマンドの作成

## agents.json スキーマ案

\`\`\`json
{
  "agents": [
    {
      "id": "engineer-a",
      "role": "engineer-worker",
      "status": "working",
      "issue": 42,
      "worktree": "/path/to/worktree-a",
      "branch": "feature/engineer-a/2026-03-12-add-auth",
      "started_at": "2026-03-12T10:00:00Z"
    }
  ]
}
\`\`\`
BODY
)"

echo "Created: エージェント間状態共有の構築"

# ── C. インフラ系（Phase 2）──

gh issue create --repo "$REPO" \
  --title "【Phase 2】executing-plan のタスクロック機構導入" \
  --label "Phase 2,medium,infrastructure" \
  --body "$(cat <<'BODY'
## 概要

現在の `/executing-plan` は tasks.md を直接読み書きするため、
複数エージェントが同時に実行すると競合が発生する。

## チェックリスト

- [ ] tasks.md の競合防止メカニズムの設計
- [ ] 方式の選定: ファイルロック vs Issue単位タスク管理
- [ ] 選定した方式の実装
- [ ] 並列実行テスト（2エージェントで同時実行して競合しないこと）

## 現状の問題

\`\`\`
Agent A: tasks.md を読む → タスク1 が [ ] → 実行開始
Agent B: tasks.md を読む → タスク1 が [ ] → 実行開始  ← 競合！
\`\`\`
BODY
)"

echo "Created: executing-plan のタスクロック機構導入"

gh issue create --repo "$REPO" \
  --title "【Phase 2】creating-pr のブランチ名衝突防止" \
  --label "Phase 2,medium,infrastructure" \
  --body "$(cat <<'BODY'
## 概要

現在のブランチ命名規則 \`feature/YYYY-MM-DD-{slug}\` では、
同日に同じ slug のブランチを複数エージェントが作成すると衝突する。

## チェックリスト

- [ ] ブランチ命名規則を \`feature/{agent-id}/YYYY-MM-DD-{slug}\` に変更
- [ ] creating-pr コマンドの修正
- [ ] git-workflow.md のブランチ命名セクション更新
- [ ] 既存ブランチとの互換性確認

## 依存

- 【Phase 1.5】git-workflow.md の並列実行対応改修
BODY
)"

echo "Created: creating-pr のブランチ名衝突防止"

# ── D. ドキュメント系 ──

gh issue create --repo "$REPO" \
  --title "【Phase 1.5】secretary-behavior.md の並列対応改修" \
  --label "Phase 1.5,medium,structure" \
  --body "$(cat <<'BODY'
## 概要

現在の secretary-behavior.md はセッション開始時のブリーフィングなど
単一エージェント前提の手順が含まれている。並列実行に対応させる。

## チェックリスト

- [ ] セッション開始手順を並列対応に修正（各エージェントは自分のロール定義を読む）
- [ ] ブリーフィング関連の記述を削除（Cowork移行）
- [ ] 自律行動範囲をロール別に再定義
- [ ] ファイル名を role-behavior.md にリネーム検討

## 関連

- .claude/agents/ の各ロール定義と整合させる
BODY
)"

echo "Created: secretary-behavior.md の並列対応改修"

echo ""
echo "================================================"
echo "  完了！"
echo "================================================"
echo ""
echo "作成されたIssueを確認："
echo "  gh issue list --repo $REPO --state open"
echo ""
echo "GitHub Projects に追加する場合："
echo "  gh issue edit <NUMBER> --add-project '<PROJECT_NAME>'"
