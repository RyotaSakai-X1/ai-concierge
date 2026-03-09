# /generate-spec — 仕様書から実装計画・技術設計を生成

## 処理フロー

引数として渡された仕様書ファイル（`docs/specs/*.md`）を読み込み、以下を実行する。

1. `knowledge/` 配下の全ファイルを参照して既存ルール・技術スタックを把握する
2. 技術選定・アーキテクチャ設計を行う
3. `docs/outputs/{spec-slug}/` ディレクトリを作成して以下を生成する：

### 生成ファイル一覧

| ファイル名 | 内容 |
|---|---|
| `architecture.md` | 技術構成・データフロー図（Mermaid形式） |
| `tasks.md` | 実装タスクの詳細チェックリスト |
| `risks.md` | リスク一覧と対策 |

## 使用例

```
/generate-spec docs/specs/2025-01-01-feedback-system.md
```

## 注意事項

- 技術選定は `knowledge/business-rules.md` の制約に従う
- 既存コードがある場合は既存スタックを優先する
- 不明な場合は複数案を並記してトレードオフを明示する
