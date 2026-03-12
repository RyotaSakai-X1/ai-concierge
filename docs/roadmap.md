# ロードマップ

## 最終ゴール：Agent Teams + Worktree による並列Issue消化

複数の AI エージェントが**役割分担して並列に Issue を処理する**仕組みを作る。
各エージェントは独立した git worktree で作業し、衝突なく同時に PR を作成・レビュー・マージできる状態を目指す。

### エージェントチーム組織図

```
👤 ユーザー
 │
 ▼
🎯 オーケストレーター（司令塔）
 │  Issue割り振り / 進捗監視 / 衝突調停
 │
 ├── 🔧 エンジニアリーダー
 │    │  技術方針 / PRレビュー / タスク分配
 │    ├── 👷 エンジニア-A（worktree-a）… Issue実装
 │    ├── 👷 エンジニア-B（worktree-b）… Issue実装
 │    └── 👷 エンジニア-C（worktree-c）… Issue実装
 │
 ├── 🧪 テスターリーダー
 │    │  テスト戦略 / 品質基準
 │    ├── 🔍 テスター-A … PRレビュー・テスト
 │    └── 🔍 テスター-B … PRレビュー・テスト
 │
 └── 🎨 デザイナーリーダー
      │  UI/UX方針 / デザインレビュー
      └── ✏️ デザイナー-A … ワイヤーフレーム・モック
```

### ゴールに至るまでのフェーズ

| フェーズ | やること | 状態 |
|---------|---------|------|
| Phase 1 | コマンドとナレッジを手動で回し、精度を上げる | ✅ 完了 |
| Phase 1.5 | 構造整理・エンジニア特化・並列対応準備 | 🔄 今ここ |
| Phase 2 | Agent Teams + Worktree で並列実行基盤を構築 | 未着手 |
| Phase 3 | 本格運用・スケーリング | 未着手 |

---

## Phase 1：基盤固め ✅ 完了

手動運用でナレッジと仕組みの精度を上げるフェーズ。以下を達成済み：

- [x] hooks（機密情報チェック・knowledge変更警告）の導入
- [x] コマンド12本の整備（creating-pr, reviewing, executing-plan 等）
- [x] ルール4本の策定（git-workflow, issue-management, review-response, secretary-behavior）
- [x] テンプレート4本の作成（spec, meeting-summary, report, review-report）
- [x] GitHub Actions（PR自動追加、@claude自動対応）の導入
- [x] 秘書ロール定義とセッション開始手順の確立

---

## Phase 1.5：構造整理（🔄 今ここ）

**方針転換：**
- **エンジニア領域** → このリポジトリ（Claude Code）に集中
- **非エンジニア領域**（ブリーフィング、議事録等）→ Cowork に移行
- **PM系コマンド**（triaging, sprint-planning, estimating）→ 一旦残して後で判断

### やること

#### A. 構造整理

- [ ] CLAUDE.md の軽量化・エンジニア特化
  - 非エンジニア系の記述を削除
  - 並列実行モードのセクションを追加
  - 単一エージェント前提の記述を修正

- [ ] 非エンジニア系コマンドの移行準備
  - `/briefing`, `/meeting-summary` のCowork移行
  - 移行先への引き継ぎドキュメント作成

- [ ] git-workflow.md の並列対応改修
  - ブランチ命名に agent-id を含める（`feature/{agent-id}/YYYY-MM-DD-{slug}`）
  - 「mainに戻るか聞く」フローの廃止
  - worktree 利用時のクリーンアップルール追加

#### B. 新規ディレクトリ・ファイルの作成

- [ ] `.claude/agents/` エージェント定義ディレクトリの作成
  - orchestrator.md, engineer-leader.md, engineer-worker.md
  - tester-leader.md, tester-worker.md, designer.md

- [ ] `knowledge/rules/parallel-execution.md` 並列実行ルールの策定

- [ ] `.claude/status/agents.json` エージェント間状態共有の仕組み

- [ ] `docs/decisions/` 意思決定記録ディレクトリの作成

---

## Phase 2：Agent Teams + Worktree 並列実行基盤（未着手）

### 前提条件

- Phase 1.5 の構造整理が完了していること
- エージェント定義ファイルが揃っていること
- 並列実行ルールが策定されていること

### やること

- [ ] executing-plan のタスクロック機構導入
  - tasks.md の並列読み書き時の競合防止
  - Issue単位のタスク管理への切り替え

- [ ] creating-pr のブランチ名衝突防止
  - `feature/{agent-id}/YYYY-MM-DD-{slug}` 形式への変更

- [ ] エージェント間の状態共有の実装
  - `.claude/status/agents.json` の読み書きロジック
  - 重複作業防止のための冪等性チェック

- [ ] オーケストレーターの実装
  - Issue の自動割り振りロジック
  - 進捗監視・衝突検知

- [ ] worktree ライフサイクル管理
  - 自動作成・クリーンアップスクリプト
  - ブランチとworktreeの紐付け管理

---

## Phase 3：本格運用・スケーリング（未着手）

### 前提条件

- Phase 2 で2-3エージェントの並列実行が安定すること
- エージェントの判断精度が人間のレビューで検証済みであること

### やること

- [ ] エージェント数のスケーリング（3→5→10）
- [ ] パフォーマンスモニタリング・ログ集約
- [ ] エージェント間通信プロトコルの最適化
- [ ] 人間介入ポイントの最小化（承認フローの自動化）

---

## ツール分担方針

| 領域 | ツール | 備考 |
|------|--------|------|
| エンジニアリング（Git/PR/コードレビュー/仕様→実装） | このリポジトリ（Claude Code） | メイン |
| PM（triaging/sprint-planning/estimating） | このリポジトリ | 一旦残す。後で判断 |
| ブリーフィング・議事録 | Cowork | 移行予定 |
| アイデア精査・仕様書生成 | このリポジトリ | エンジニアパイプラインの一部 |

---

## 取り込まないもの

| 内容 | 理由 |
|------|------|
| `tools/scripts/`, `tools/prompts/` | コードベースではないので不要 |
| `src/` 配下のローカル CLAUDE.md | ソースコードがないので現時点では不要 |
| 非エンジニア向けセットアップ自動化 | Cowork側で対応 |
