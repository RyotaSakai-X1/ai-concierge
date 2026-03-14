# ミッション

## 目的

実業務で Claude Code を活用しながら、そのプロセス自体をナレッジとして体系化する。

- **実践**: 日常のエンジニアリング・デザイン業務を Claude Code で効率化する
- **体系化**: 効果的だったプロンプト・ワークフロー・ルールをリポジトリに蓄積し、再現可能にする
- **共有**: 蓄積したナレッジを社内外に展開できる形にまとめる

## スコープ

| 対象 | 対象外 |
|------|--------|
| エンジニアリング（設計・実装・レビュー・CI/CD） | 営業・経理 |
| 要件定義・見積もり（技術判断を伴うもの） | 汎用的な AI エージェント基盤の構築 |
| デザイン（Figma 連携・UI 実装） | |
| QA・テスト管理（テスト項目生成・実行・レポート） | |
| 開発プロセスの自動化 | |

> 📌 各業務は専用レーンで動かし、コンテキストの混在を防ぐ。
> コーディング系: `/work-on-issue`, `/parallel-work`, `/reviewing`, `/creating-pr`
> 分析系: `/extract-requirements`, `/estimating`, `/generate-screens`
> テスター系: `/generate-test-cases`, `/run-ui-test`, `/test-report`
> デザイナー系: `/sync-design-system`, `/design`, `/design-review`

## 対象ユーザー

- 自分自身（テックリード兼プレイヤー）
- 将来的にはチームメンバー（エンジニア・デザイナー）

## 現在のフェーズ

**Phase 1: 基盤固め** — コマンド・ルール・ナレッジを手動運用で磨き込むフェーズ。

詳細は `docs/roadmap.md` を参照。

## アーキテクチャ概要

```
Claude Code CLI（テックリードエージェント）
  ├── CLAUDE.md          — ロール定義・基本方針
  ├── knowledge/         — ルール・テンプレート・ミッション
  ├── .claude/commands/  — スラッシュコマンド（skill）
  │     ├── [コーディング系] /work-on-issue, /parallel-work, /reviewing, /creating-pr
  │     ├── [分析系]       /extract-requirements, /estimating, /generate-screens
  │     ├── [テスター系]   /generate-test-cases, /run-ui-test, /test-report
  │     ├── [デザイナー系] /sync-design-system, /design, /design-review
  │     └── [横断系]       /briefing, /generating-spec, /executing-plan, /checking-ready
  ├── .claude/hooks/     — 自動ガードレール
  └── Agent tool (worktree isolation) — 並列実行
```

- **単一エージェント・4レーン構成**: コーディング系・分析系・テスター系・デザイナー系を分離し、コンテキストの混在を防ぐ
- **並列実行**: Agent tool の `isolation: "worktree"` で複数イシューを同時処理
- **ナレッジ駆動**: `knowledge/` 配下のルール・テンプレートで品質を担保
