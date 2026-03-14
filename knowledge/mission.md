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
| 開発プロセスの自動化 | |

> 📌 要件定義・見積もりはスコープ内だが、コーディングエージェントとは別レーンで動かす。
> コーディング系: `/work-on-issue`, `/parallel-work`
> 分析系: `/extract-requirements`, `/estimating`, `/generate-screens`

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
  │     ├── [コーディング系] /work-on-issue, /parallel-work, /creating-pr
  │     └── [分析系]       /extract-requirements, /estimating, /generate-screens
  ├── .claude/hooks/     — 自動ガードレール
  └── Agent tool (worktree isolation) — 並列実行
```

- **単一エージェント・2レーン構成**: コーディング系と分析系を分離し、コンテキストの混在を防ぐ
- **並列実行**: Agent tool の `isolation: "worktree"` で複数イシューを同時処理
- **ナレッジ駆動**: `knowledge/` 配下のルール・テンプレートで品質を担保
