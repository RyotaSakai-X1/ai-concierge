# Claude-Factory ユーザー操作フロー図

> 作成日: 2026-03-20
> 対象: 全 19 スラッシュコマンド + セッション開始フロー
> コマンド一覧・使用例: [README（.claude/commands/README.md）](../../../.claude/commands/README.md)

## 凡例

| 形状 | 意味 | 色 |
|------|------|----|
| `{ひし形}` | ユーザー選択（AskUserQuestion） | 黄 |
| `[四角]` | 自動処理ステップ | 青 |
| `([スタジアム])` | 出力成果物 | 緑 |
| `((円))` | エントリーポイント | 紫 |
| `[[二重四角]]` | コマンド呼び出し | シアン |

---

## A. システム全体俯瞰

```mermaid
graph TD
    classDef userChoice fill:#FFE082,stroke:#F9A825,color:#000
    classDef autoStep fill:#E3F2FD,stroke:#1565C0,color:#000
    classDef output fill:#C8E6C9,stroke:#2E7D32,color:#000
    classDef entryPoint fill:#F3E5F5,stroke:#7B1FA2,color:#000
    classDef command fill:#E0F7FA,stroke:#00838F,color:#000

    START(("セッション開始")):::entryPoint
    BRIEFING["/briefing 自動ブリーフィング"]:::autoStep
    PROPOSAL["今日やるべきことを提案"]:::autoStep

    START --> BRIEFING --> PROPOSAL

    CHOICE{"作業を選択"}:::userChoice
    PROPOSAL --> CHOICE

    subgraph LANE_A ["分析・設計レーン"]
        direction TB
        CMD_PIPELINE[["🔄 /run-pipeline\n対話的にパイプライン全体を実行"]]:::command
        CMD_EXTRACT[["📋 /extract-requirements\nMTG・ヒアリングから情報を構造化抽出"]]:::command
        CMD_DEFINE[["📝 /define-requirements\n案件概要から要件定義書を作成"]]:::command
        CMD_SCREENS[["🖥️ /generate-screens\n画面一覧・画面遷移図を自動生成"]]:::command
        CMD_DIAGRAMS[["📊 /generate-diagrams\n要件からダイアグラムを Figma に生成"]]:::command
        CMD_WIREFRAME[["🔲 /wireframe\nワイヤーフレームを Figma に生成"]]:::command
        CMD_DESIGN[["🎨 /design\nビジュアルデザインを Figma に生成"]]:::command
        CMD_ESTIMATING[["🔢 /estimating\n機能要件から工数を自動算出"]]:::command
        CMD_ESTIMATE_DOC[["💰 /create-estimate-doc\n工数見積から見積書を生成"]]:::command
    end

    subgraph LANE_B ["コーディングレーン"]
        direction TB
        CMD_WORK[["🔨 /work-on-issue\nイシュー起点で実装〜PR 作成"]]:::command
        CMD_PARALLEL[["⚡ /parallel-work\n複数イシューを同時並列で実装"]]:::command
        CMD_PR[["🚀 /creating-pr\n変更からブランチ作成〜PR 作成"]]:::command
    end

    subgraph LANE_C ["レビュー・品質レーン"]
        direction TB
        CMD_REVIEW[["🔍 /reviewing\n仕様書・成果物・PR をレビュー"]]:::command
        CMD_READY[["✅ /checking-ready\nイシューの着手可否を依存関係から判定"]]:::command
    end

    subgraph LANE_D ["横断機能レーン"]
        direction TB
        CMD_SPEC[["📐 /generating-spec\n仕様書から実装計画・技術設計を生成"]]:::command
        CMD_EXEC[["▶️ /executing-plan\nタスクリストを順次自律実行"]]:::command
        CMD_ISSUES[["🎫 /create-issues-from-meeting\n議事録からイシューを一括起票"]]:::command
        CMD_SYNC[["🔗 /sync-design-system\nFigma ↔ ローカルのトークンを同期"]]:::command
    end

    CHOICE --> LANE_A
    CHOICE --> LANE_B
    CHOICE --> LANE_C
    CHOICE --> LANE_D

    OUT_LOCAL(["ローカルファイル docs/outputs/"]):::output
    OUT_FIGMA(["Figma"]):::output
    OUT_SHEETS(["Google Sheets"]):::output
    OUT_GITHUB(["GitHub PR / Issues"]):::output

    LANE_A --> OUT_LOCAL
    LANE_A --> OUT_FIGMA
    LANE_A --> OUT_SHEETS
    LANE_B --> OUT_GITHUB
    LANE_C --> OUT_LOCAL
    LANE_D --> OUT_LOCAL
    LANE_D --> OUT_GITHUB
    LANE_D --> OUT_FIGMA
```

---

## B. パイプラインフロー（`/run-pipeline`）

```mermaid
graph TD
    classDef userChoice fill:#FFE082,stroke:#F9A825,color:#000
    classDef autoStep fill:#E3F2FD,stroke:#1565C0,color:#000
    classDef output fill:#C8E6C9,stroke:#2E7D32,color:#000
    classDef entryPoint fill:#F3E5F5,stroke:#7B1FA2,color:#000
    classDef command fill:#E0F7FA,stroke:#00838F,color:#000

    ENTRY(("/run-pipeline")):::entryPoint

    S1{"Step 1: 入力ソース選択"}:::userChoice
    S1_A["Google Docs URL を入力"]:::autoStep
    S1_B["ローカルファイルパスを入力"]:::autoStep
    S1_C["Google Drive フォルダ URL を入力"]:::autoStep

    ENTRY --> S1
    S1 --> S1_A
    S1 --> S1_B
    S1 --> S1_C

    EXTRACT[["📋 MTG・ヒアリングから情報を構造化抽出"]]:::command
    S1_A --> EXTRACT
    S1_B --> EXTRACT
    S1_C --> EXTRACT

    OUT_EXTRACT(["requirements-extracted.md"]):::output
    EXTRACT --> OUT_EXTRACT

    S2{"Step 2: 次のアクション"}:::userChoice
    OUT_EXTRACT --> S2
    S2_A["両方実行する（要件定義 + イシュー起票）"]:::autoStep
    S2_B[["📝 要件定義書を作成"]]:::command
    S2_C[["🎫 議事録からイシューを起票"]]:::command
    S2_END["ここで終了"]:::autoStep

    S2 -->|"両方実行する（要件定義 + イシュー起票）"| S2_A
    S2 -->|"要件定義に進む（/define-requirements）"| S2_B
    S2 -->|"イシューを起票する（/create-issues-from-meeting）"| S2_C
    S2 -->|"ここで終了"| DONE

    S2_A --> S2_B
    S2_A --> S2_C

    OUT_DEFINE(["requirements.md"]):::output
    S2_B --> OUT_DEFINE

    S3{"Step 3: 次のアクション"}:::userChoice
    OUT_DEFINE --> S3
    S3_A[["🖥️ 画面一覧・遷移図を生成"]]:::command
    S3_B[["💰 工数算出 → 見積書生成"]]:::command
    S3_BOTH["両方（画面設計 → 見積の順）"]:::autoStep

    S3 -->|"画面設計に進む（/generate-screens）"| S3_A
    S3 -->|"工数見積に進む（/estimating → /create-estimate-doc）"| S3_B
    S3 -->|"両方（画面設計 → 見積の順で実行）"| S3_BOTH
    S3 -->|"ここで終了"| DONE

    S3_BOTH --> S3_A
    S3_A --> OUT_SCREENS(["screens/ 画面一覧・遷移図"]):::output

    S4{"Step 4: 次のアクション"}:::userChoice
    OUT_SCREENS --> S4
    S4_A[["📊 ダイアグラムを Figma に生成"]]:::command
    S4_B[["🔲 ワイヤーフレームを Figma に生成"]]:::command
    S4_BOTH["両方（ダイアグラム → ワイヤーフレーム）"]:::autoStep

    S4 -->|"ダイアグラムを Figma に生成（/generate-diagrams）"| S4_A
    S4 -->|"ワイヤーフレームに進む（/wireframe）"| S4_B
    S4 -->|"両方（ダイアグラム → ワイヤーフレーム）"| S4_BOTH
    S4 -->|"ここで終了"| DONE

    S4_BOTH --> S4_A
    S4_A --> OUT_DIAGRAMS(["Figma ダイアグラム"]):::output

    S5{"Step 5: 次のアクション"}:::userChoice
    OUT_DIAGRAMS --> S5
    S5 -->|"ワイヤーフレームに進む"| S4_B
    S5 -->|"ここで終了"| DONE

    S4_B --> OUT_WIRE(["Figma ワイヤーフレーム"]):::output

    S6{"Step 6: 次のアクション"}:::userChoice
    OUT_WIRE --> S6
    S6 -->|"工数見積に進む"| S3_B
    S6 -->|"レビューする"| REVIEW_CMD
    S6 -->|"完了"| DONE

    S3_B --> OUT_EST(["estimate-doc.md"]):::output
    S3_BOTH -.->|"見積も実行"| S3_B

    S7{"Step 7: 次のアクション"}:::userChoice
    OUT_EST --> S7

    REVIEW_CMD[["🔍 成果物をレビュー"]]:::command
    S7 -->|"レビューする"| REVIEW_CMD
    S7 -->|"完了"| DONE

    DONE(["パイプライン完了"]):::output
    REVIEW_CMD --> DONE
    S2_END --> DONE
```

---

## C. 個別分析コマンド詳細

```mermaid
graph TD
    classDef userChoice fill:#FFE082,stroke:#F9A825,color:#000
    classDef autoStep fill:#E3F2FD,stroke:#1565C0,color:#000
    classDef output fill:#C8E6C9,stroke:#2E7D32,color:#000
    classDef entryPoint fill:#F3E5F5,stroke:#7B1FA2,color:#000
    classDef command fill:#E0F7FA,stroke:#00838F,color:#000

    %% === /extract-requirements ===
    subgraph EXT ["/extract-requirements"]
        direction TB
        EXT_IN(("入力ソース")):::entryPoint
        EXT_TYPE{"コンテンツタイプ分類"}:::userChoice
        EXT_A["クライアント MTG（要件定義）"]:::autoStep
        EXT_B["クライアント MTG（その他）"]:::autoStep
        EXT_C["勉強会・セミナー"]:::autoStep
        EXT_D["社内検討・ブレスト"]:::autoStep

        EXT_IN --> EXT_TYPE
        EXT_TYPE --> EXT_A
        EXT_TYPE --> EXT_B
        EXT_TYPE --> EXT_C
        EXT_TYPE --> EXT_D

        EXT_OUT_A(["requirements-extracted.md"]):::output
        EXT_OUT_B(["meetings/YYYY-MM-DD-insights.md"]):::output
        EXT_OUT_C(["knowledge/YYYY-MM-DD.md"]):::output
        EXT_OUT_D(["discussions/YYYY-MM-DD.md"]):::output

        EXT_A --> EXT_OUT_A
        EXT_B --> EXT_OUT_B
        EXT_C --> EXT_OUT_C
        EXT_D --> EXT_OUT_D
    end

    %% === /define-requirements ===
    subgraph DEF ["/define-requirements"]
        direction TB
        DEF_IN(("入力ソース")):::entryPoint
        DEF_ANALYZE["要件分析・構造化"]:::autoStep
        DEF_GS{"Google Sheets 出力"}:::userChoice
        DEF_GS_A["新規スプレッドシートを作成して書き出す"]:::autoStep
        DEF_GS_B["既存スプレッドシートに書き出す（URL を入力）"]:::autoStep
        DEF_GS_C["スキップ"]:::autoStep

        DEF_IN --> DEF_ANALYZE --> DEF_GS
        DEF_GS --> DEF_GS_A
        DEF_GS --> DEF_GS_B
        DEF_GS --> DEF_GS_C

        DEF_OUT_MD(["requirements.md"]):::output
        DEF_OUT_GS(["Google Sheets"]):::output

        DEF_GS_A --> DEF_OUT_GS
        DEF_GS_B --> DEF_OUT_GS
        DEF_GS_C --> DEF_OUT_MD
        DEF_GS_A --> DEF_OUT_MD
        DEF_GS_B --> DEF_OUT_MD
    end

    %% === /generate-diagrams ===
    subgraph DIA ["/generate-diagrams"]
        direction TB
        DIA_IN(("入力ソース")):::entryPoint
        DIA_TYPE{"ダイアグラムタイプ選択"}:::userChoice
        DIA_A["画面遷移図"]:::autoStep
        DIA_B["ユーザーフロー"]:::autoStep
        DIA_C["状態遷移図"]:::autoStep
        DIA_D["シーケンス図"]:::autoStep
        DIA_E["全て生成"]:::autoStep

        DIA_IN --> DIA_TYPE
        DIA_TYPE --> DIA_A
        DIA_TYPE --> DIA_B
        DIA_TYPE --> DIA_C
        DIA_TYPE --> DIA_D
        DIA_TYPE --> DIA_E

        DIA_MERMAID["Mermaid コード生成"]:::autoStep
        DIA_HTML["HTML 生成 → ローカルサーバー起動"]:::autoStep
        DIA_FIGMA{"Figma 出力先選択"}:::userChoice
        DIA_F1["デフォルトのチーム/プロジェクトに作成"]:::autoStep
        DIA_F2["Drafts に作成"]:::autoStep
        DIA_F3["既存の Figma ファイルに追加（URL を入力）"]:::autoStep

        DIA_A --> DIA_MERMAID
        DIA_B --> DIA_MERMAID
        DIA_C --> DIA_MERMAID
        DIA_D --> DIA_MERMAID
        DIA_E --> DIA_MERMAID
        DIA_MERMAID --> DIA_HTML --> DIA_FIGMA
        DIA_FIGMA --> DIA_F1
        DIA_FIGMA --> DIA_F2
        DIA_FIGMA --> DIA_F3

        DIA_OUT(["Figma ダイアグラム + diagrams/ ローカルコピー"]):::output
        DIA_F1 --> DIA_OUT
        DIA_F2 --> DIA_OUT
        DIA_F3 --> DIA_OUT
    end

    %% === /wireframe ===
    subgraph WIRE ["/wireframe"]
        direction TB
        WIRE_IN(("入力ソース")):::entryPoint
        WIRE_GEN["HTML ワイヤーフレーム生成"]:::autoStep
        WIRE_FIGMA{"Figma 出力先選択"}:::userChoice
        WIRE_F1["デフォルトのチーム/プロジェクトに作成"]:::autoStep
        WIRE_F2["Drafts に作成"]:::autoStep
        WIRE_F3["既存の Figma ファイルに追加（URL を入力）"]:::autoStep
        WIRE_CAP{"キャプチャモード選択"}:::userChoice
        WIRE_C1["全画面を1ページにまとめてキャプチャ"]:::autoStep
        WIRE_C2["画面ごとに個別キャプチャ"]:::autoStep

        WIRE_IN --> WIRE_GEN --> WIRE_FIGMA
        WIRE_FIGMA --> WIRE_F1
        WIRE_FIGMA --> WIRE_F2
        WIRE_FIGMA --> WIRE_F3
        WIRE_F1 --> WIRE_CAP
        WIRE_F2 --> WIRE_CAP
        WIRE_F3 --> WIRE_CAP
        WIRE_CAP --> WIRE_C1
        WIRE_CAP --> WIRE_C2

        WIRE_OUT(["Figma ワイヤーフレーム"]):::output
        WIRE_C1 --> WIRE_OUT
        WIRE_C2 --> WIRE_OUT
    end

    %% === /design ===
    subgraph DSN ["/design"]
        direction TB
        DSN_IN(("入力ソース")):::entryPoint
        DSN_TOKEN["デザイントークン確認"]:::autoStep
        DSN_COLOR{"カラーパレット判定"}:::userChoice
        DSN_COL_A["カラーパレットを先に決める（トレンド調査 → 候補提示）"]:::autoStep
        DSN_COL_B["デフォルトのニュートラルカラーで仮生成する"]:::autoStep
        DSN_COL_C["カラーの方向性をテキストで指示する"]:::autoStep

        DSN_IN --> DSN_TOKEN --> DSN_COLOR
        DSN_COLOR --> DSN_COL_A
        DSN_COLOR --> DSN_COL_B
        DSN_COLOR --> DSN_COL_C

        DSN_LAYOUT{"レイアウト承認"}:::userChoice
        DSN_L1["この方針で進める"]:::autoStep
        DSN_L2["調整したい点がある"]:::autoStep

        DSN_COL_A --> DSN_LAYOUT
        DSN_COL_B --> DSN_LAYOUT
        DSN_COL_C --> DSN_LAYOUT
        DSN_LAYOUT --> DSN_L1
        DSN_LAYOUT --> DSN_L2
        DSN_L2 -->|"調整後"| DSN_LAYOUT

        DSN_FIGMA{"Figma 出力先選択"}:::userChoice
        DSN_F1["デフォルトのチーム/プロジェクトに作成"]:::autoStep
        DSN_F2["Drafts に作成"]:::autoStep
        DSN_F3["既存の Figma ファイルに追加（URL を入力）"]:::autoStep
        DSN_CAP{"キャプチャモード選択"}:::userChoice
        DSN_CAP1["全画面を1ページにまとめてキャプチャ"]:::autoStep
        DSN_CAP2["画面ごとに個別キャプチャ"]:::autoStep

        DSN_L1 --> DSN_FIGMA
        DSN_FIGMA --> DSN_F1
        DSN_FIGMA --> DSN_F2
        DSN_FIGMA --> DSN_F3
        DSN_F1 --> DSN_CAP
        DSN_F2 --> DSN_CAP
        DSN_F3 --> DSN_CAP
        DSN_CAP --> DSN_CAP1
        DSN_CAP --> DSN_CAP2

        DSN_OUT(["Figma デザイン"]):::output
        DSN_CAP1 --> DSN_OUT
        DSN_CAP2 --> DSN_OUT
    end

    %% === /generate-screens ===
    subgraph SCR ["/generate-screens"]
        direction TB
        SCR_IN(("入力ソース")):::entryPoint
        SCR_EXTRACT["機能要件から画面を抽出"]:::autoStep
        SCR_LIST["画面一覧テーブル生成"]:::autoStep
        SCR_FLOW["画面遷移図 Mermaid 生成"]:::autoStep

        SCR_IN --> SCR_EXTRACT --> SCR_LIST --> SCR_FLOW

        SCR_OUT_LIST(["screens/screens.md"]):::output
        SCR_OUT_FLOW(["screens/flow.md"]):::output
        SCR_LIST --> SCR_OUT_LIST
        SCR_FLOW --> SCR_OUT_FLOW
    end

    %% === /estimating ===
    subgraph ESTM ["/estimating"]
        direction TB
        ESTM_IN(("スプレッドシート URL")):::entryPoint
        ESTM_READ["スプレッドシート読み込み"]:::autoStep
        ESTM_ANALYZE["機能要件分析・複雑度判定"]:::autoStep
        ESTM_CALC["工数算出（基準値 × 複雑度 + 20%バッファ）"]:::autoStep
        ESTM_WRITE["スプレッドシートに書き戻し"]:::autoStep

        ESTM_IN --> ESTM_READ --> ESTM_ANALYZE --> ESTM_CALC --> ESTM_WRITE

        ESTM_OUT(["Google Sheets 更新完了"]):::output
        ESTM_WRITE --> ESTM_OUT
    end

    %% === /create-estimate-doc ===
    subgraph EST ["/create-estimate-doc"]
        direction TB
        EST_IN(("スプレッドシート URL")):::entryPoint
        EST_INFO["プロジェクト情報入力"]:::autoStep
        EST_PRICE{"単価選択"}:::userChoice
        EST_P1["¥50,000 /人日（junior）"]:::autoStep
        EST_P2["¥70,000 /人日（mid）"]:::autoStep
        EST_P3["¥100,000 /人日（senior）"]:::autoStep
        EST_P4["カスタム金額を入力"]:::autoStep

        EST_IN --> EST_INFO --> EST_PRICE
        EST_PRICE --> EST_P1
        EST_PRICE --> EST_P2
        EST_PRICE --> EST_P3
        EST_PRICE --> EST_P4

        EST_PHASE{"フェーズ分割"}:::userChoice
        EST_PH1["フェーズ分割なし"]:::autoStep
        EST_PH2["フェーズ分割あり"]:::autoStep

        EST_P1 --> EST_PHASE
        EST_P2 --> EST_PHASE
        EST_P3 --> EST_PHASE
        EST_P4 --> EST_PHASE
        EST_PHASE --> EST_PH1
        EST_PHASE --> EST_PH2

        EST_OUT(["estimate-doc.md"]):::output
        EST_PH1 --> EST_OUT
        EST_PH2 --> EST_OUT
    end
```

---

## D. コーディングレーン

```mermaid
graph TD
    classDef userChoice fill:#FFE082,stroke:#F9A825,color:#000
    classDef autoStep fill:#E3F2FD,stroke:#1565C0,color:#000
    classDef output fill:#C8E6C9,stroke:#2E7D32,color:#000
    classDef entryPoint fill:#F3E5F5,stroke:#7B1FA2,color:#000
    classDef command fill:#E0F7FA,stroke:#00838F,color:#000

    %% === /work-on-issue ===
    subgraph WOI ["/work-on-issue"]
        direction TB
        WOI_IN(("イシュー番号")):::entryPoint
        WOI_FETCH["イシュー取得・分析"]:::autoStep
        WOI_STATUS["ステータス → In progress"]:::autoStep
        WOI_BRANCH["ブランチ作成 feature/YYYY-MM-DD-slug"]:::autoStep
        WOI_IMPL["チェックリスト順に実装"]:::autoStep
        WOI_REVIEW[["🔍 セルフレビュー実行"]]:::command

        WOI_IN --> WOI_FETCH --> WOI_STATUS --> WOI_BRANCH --> WOI_IMPL --> WOI_REVIEW

        WOI_JUDGE{"レビュー判定"}:::userChoice
        WOI_REVIEW --> WOI_JUDGE
        WOI_JUDGE -->|"REJECT / CONDITIONAL"| WOI_IMPL
        WOI_JUDGE -->|"PASS"| WOI_COMMIT

        WOI_COMMIT{"コミット確認"}:::userChoice
        WOI_CM1["コミットして PR 作成する"]:::autoStep
        WOI_CM2["コミットメッセージを修正する"]:::autoStep
        WOI_CM3["実装を修正する"]:::autoStep

        WOI_COMMIT --> WOI_CM1
        WOI_COMMIT --> WOI_CM2
        WOI_COMMIT --> WOI_CM3
        WOI_CM2 --> WOI_COMMIT
        WOI_CM3 --> WOI_IMPL

        WOI_PUSH["git push → gh pr create"]:::autoStep
        WOI_CM1 --> WOI_PUSH

        WOI_PR_OUT(["PR 作成完了"]):::output
        WOI_PUSH --> WOI_PR_OUT

        WOI_FIX{"修正の有無"}:::userChoice
        WOI_FIX1["修正がある"]:::autoStep
        WOI_FIX2["修正はない"]:::autoStep
        WOI_PR_OUT --> WOI_FIX
        WOI_FIX --> WOI_FIX1
        WOI_FIX --> WOI_FIX2
        WOI_FIX1 --> WOI_IMPL

        WOI_CLEAN{"クリーンアップ"}:::userChoice
        WOI_CL1["ブランチ・worktree を削除して main に戻る"]:::autoStep
        WOI_CL2["このブランチで続ける"]:::autoStep
        WOI_FIX2 --> WOI_CLEAN
        WOI_CLEAN --> WOI_CL1
        WOI_CLEAN --> WOI_CL2

        WOI_NEXT["次のイシュー提案"]:::autoStep
        WOI_CL1 --> WOI_NEXT
    end

    %% === /parallel-work ===
    subgraph PW ["/parallel-work"]
        direction TB
        PW_IN(("イシュー番号（複数）")):::entryPoint
        PW_DEP["依存関係・ファイル競合チェック"]:::autoStep
        PW_PLAN{"実行計画確認"}:::userChoice
        PW_P1["実行する"]:::autoStep
        PW_P2["計画を修正する"]:::autoStep
        PW_P3["キャンセル"]:::autoStep

        PW_IN --> PW_DEP --> PW_PLAN
        PW_PLAN --> PW_P1
        PW_PLAN --> PW_P2
        PW_PLAN --> PW_P3
        PW_P2 --> PW_PLAN

        PW_TEAM["Agent Teams チーム作成"]:::autoStep
        PW_WORKTREE["各メンバー: worktree 作成 + ブランチ"]:::autoStep
        PW_LOCK["ファイルロック宣言（共有タスクリスト）"]:::autoStep
        PW_EXEC["並列実装"]:::autoStep
        PW_REVIEW["テックリード: 各メンバーの diff レビュー"]:::autoStep

        PW_P1 --> PW_TEAM --> PW_WORKTREE --> PW_LOCK --> PW_EXEC --> PW_REVIEW

        PW_APPROVE{"承認"}:::userChoice
        PW_AP1["全て承認して PR 作成"]:::autoStep
        PW_AP2["一部修正が必要"]:::autoStep
        PW_AP3["キャンセル"]:::autoStep

        PW_REVIEW --> PW_APPROVE
        PW_APPROVE --> PW_AP1
        PW_APPROVE --> PW_AP2
        PW_APPROVE --> PW_AP3
        PW_AP2 --> PW_EXEC

        PW_PUSH["各ブランチ push → PR 作成"]:::autoStep
        PW_AP1 --> PW_PUSH

        PW_OUT(["複数 PR 作成完了 + マージ順序提案"]):::output
        PW_PUSH --> PW_OUT

        PW_CLEANUP["worktree・チーム削除"]:::autoStep
        PW_OUT --> PW_CLEANUP
    end

    %% === /creating-pr ===
    subgraph CPR ["/creating-pr"]
        direction TB
        CPR_IN(("現在の変更")):::entryPoint
        CPR_CTX["コンテキスト検出"]:::autoStep
        CPR_DETECT{"ブランチ状態（自動検出）"}:::autoStep
        CPR_D1["main → ブランチ作成"]:::autoStep
        CPR_D2["worktree → そのまま続行"]:::autoStep
        CPR_D3["既存ブランチ → 継続確認"]:::autoStep

        CPR_IN --> CPR_CTX --> CPR_DETECT
        CPR_DETECT --> CPR_D1
        CPR_DETECT --> CPR_D2
        CPR_DETECT --> CPR_D3

        CPR_COMMIT["コミット（日本語メッセージ）"]:::autoStep
        CPR_PUSH["git push -u origin"]:::autoStep
        CPR_CREATE["gh pr create --assignee @me"]:::autoStep

        CPR_D1 --> CPR_COMMIT
        CPR_D2 --> CPR_COMMIT
        CPR_D3 --> CPR_COMMIT
        CPR_COMMIT --> CPR_PUSH --> CPR_CREATE

        CPR_OUT(["PR URL"]):::output
        CPR_CREATE --> CPR_OUT
    end
```

---

## E. レビュー・品質レーン

```mermaid
graph TD
    classDef userChoice fill:#FFE082,stroke:#F9A825,color:#000
    classDef autoStep fill:#E3F2FD,stroke:#1565C0,color:#000
    classDef output fill:#C8E6C9,stroke:#2E7D32,color:#000
    classDef entryPoint fill:#F3E5F5,stroke:#7B1FA2,color:#000
    classDef command fill:#E0F7FA,stroke:#00838F,color:#000

    %% === /reviewing ===
    subgraph REV ["/reviewing"]
        direction TB
        REV_IN(("ファイルパス or PR番号")):::entryPoint
        REV_DETECT["入力タイプ自動検出"]:::autoStep

        REV_TYPE{"レビュー対象の種別"}:::userChoice
        REV_T1["docs/specs/ → 仕様書チェックリスト"]:::autoStep
        REV_T2["docs/outputs/ → 成果物チェックリスト"]:::autoStep
        REV_T3[".claude/commands/ → コマンドチェックリスト"]:::autoStep
        REV_T4["#XX → PR コードレビュー"]:::autoStep

        REV_IN --> REV_DETECT --> REV_TYPE
        REV_TYPE --> REV_T1
        REV_TYPE --> REV_T2
        REV_TYPE --> REV_T3
        REV_TYPE --> REV_T4

        REV_EXEC["チェックリストに沿ってレビュー実行"]:::autoStep
        REV_T1 --> REV_EXEC
        REV_T2 --> REV_EXEC
        REV_T3 --> REV_EXEC
        REV_T4 --> REV_EXEC

        REV_JUDGE{"総合判定（自動）"}:::autoStep
        REV_EXEC --> REV_JUDGE

        REV_PASS["✅ PASS（❌=0, ⚠️≤2）"]:::autoStep
        REV_COND["⚠️ CONDITIONAL（❌=0, ⚠️≥3）"]:::autoStep
        REV_REJECT["❌ REJECT（❌≥1）"]:::autoStep

        REV_JUDGE --> REV_PASS
        REV_JUDGE --> REV_COND
        REV_JUDGE --> REV_REJECT

        REV_PASS_NEXT["/executing-plan or /creating-pr へ"]:::autoStep
        REV_COND_NEXT["修正提案 → 再レビュー"]:::autoStep
        REV_REJECT_NEXT["根本原因説明 + 修正方針"]:::autoStep

        REV_PASS --> REV_PASS_NEXT
        REV_COND --> REV_COND_NEXT
        REV_REJECT --> REV_REJECT_NEXT
        REV_COND_NEXT -->|"再レビュー"| REV_EXEC

        REV_OUT(["レビューレポート"]):::output
        REV_PASS_NEXT --> REV_OUT
        REV_REJECT_NEXT --> REV_OUT
    end

    %% === /checking-ready ===
    subgraph CHK ["/checking-ready"]
        direction TB
        CHK_IN(("イシュー番号")):::entryPoint
        CHK_FETCH["イシュー取得 + 依存関係抽出"]:::autoStep
        CHK_DEP["各依存イシューのステータス確認"]:::autoStep

        CHK_JUDGE{"着手可否判定（自動）"}:::autoStep
        CHK_FETCH --> CHK_DEP --> CHK_JUDGE

        CHK_READY["✅ 着手可能: 全依存クローズ済み"]:::autoStep
        CHK_PARTIAL["⚠️ 一部未完了: 並行着手可能"]:::autoStep
        CHK_BLOCKED["❌ 着手不可: 重要依存が未完了"]:::autoStep

        CHK_JUDGE --> CHK_READY
        CHK_JUDGE --> CHK_PARTIAL
        CHK_JUDGE --> CHK_BLOCKED

        CHK_OUT(["判定結果テーブル表示"]):::output
        CHK_READY --> CHK_OUT
        CHK_PARTIAL --> CHK_OUT
        CHK_BLOCKED --> CHK_OUT
    end
```

---

## F. 横断機能レーン

```mermaid
graph TD
    classDef userChoice fill:#FFE082,stroke:#F9A825,color:#000
    classDef autoStep fill:#E3F2FD,stroke:#1565C0,color:#000
    classDef output fill:#C8E6C9,stroke:#2E7D32,color:#000
    classDef entryPoint fill:#F3E5F5,stroke:#7B1FA2,color:#000
    classDef command fill:#E0F7FA,stroke:#00838F,color:#000

    %% === /briefing ===
    subgraph BRF ["/briefing"]
        direction TB
        BRF_IN(("セッション開始")):::entryPoint
        BRF_S1["Step 1: オープン PR 状況確認"]:::autoStep
        BRF_S2["Step 2: レビュー依頼確認"]:::autoStep
        BRF_S3["Step 3: worktree 状態確認"]:::autoStep
        BRF_S4["Step 4: 未完了イシュー確認（⚠️ 7日以上放置）"]:::autoStep
        BRF_S5["Step 5: 直近24h のマージ確認"]:::autoStep
        BRF_S6["Step 6: 今日の行動提案"]:::autoStep

        BRF_IN --> BRF_S1 --> BRF_S2 --> BRF_S3 --> BRF_S4 --> BRF_S5 --> BRF_S6

        BRF_OUT(["ブリーフィングレポート"]):::output
        BRF_S6 --> BRF_OUT
    end

    %% === /generating-spec ===
    subgraph SPEC ["/generating-spec"]
        direction TB
        SPEC_IN(("仕様書ファイルパス")):::entryPoint
        SPEC_READ["仕様書 + knowledge/ 読み込み"]:::autoStep
        SPEC_TECH{"技術選択が必要？"}:::userChoice
        SPEC_T1["技術オプション A / B / C を提示"]:::autoStep
        SPEC_T2["既存コード・ルールから自動決定"]:::autoStep

        SPEC_IN --> SPEC_READ --> SPEC_TECH
        SPEC_TECH -->|"選択必要"| SPEC_T1
        SPEC_TECH -->|"自動決定"| SPEC_T2

        SPEC_GEN["architecture.md + tasks.md + risks.md 生成"]:::autoStep
        SPEC_T1 --> SPEC_GEN
        SPEC_T2 --> SPEC_GEN

        SPEC_OUT(["docs/outputs/slug/ に3ファイル出力"]):::output
        SPEC_GEN --> SPEC_OUT
    end

    %% === /executing-plan ===
    subgraph EXEC ["/executing-plan"]
        direction TB
        EXEC_IN(("タスクファイルパス")):::entryPoint
        EXEC_READ["未完了タスク抽出"]:::autoStep

        EXEC_LOOP["タスクを順次実行"]:::autoStep
        EXEC_IN --> EXEC_READ --> EXEC_LOOP

        EXEC_DANGER{"危険操作？"}:::userChoice
        EXEC_LOOP --> EXEC_DANGER
        EXEC_D1["実行する"]:::autoStep
        EXEC_D2["スキップ"]:::autoStep
        EXEC_DANGER -->|"外部API・データ削除等"| EXEC_D1
        EXEC_DANGER -->|"スキップ"| EXEC_D2
        EXEC_DANGER -->|"安全な操作"| EXEC_SAFE

        EXEC_SAFE["タスク実行 → チェックボックス更新"]:::autoStep
        EXEC_D1 --> EXEC_SAFE
        EXEC_D2 --> EXEC_NEXT

        EXEC_DEP{"依存未完了？"}:::userChoice
        EXEC_SAFE --> EXEC_NEXT
        EXEC_LOOP -.-> EXEC_DEP
        EXEC_DEP -->|"依存先を先に実行"| EXEC_LOOP
        EXEC_DEP -->|"このタスクをスキップ"| EXEC_NEXT

        EXEC_NEXT["次のタスクへ"]:::autoStep
        EXEC_NEXT -->|"残タスクあり"| EXEC_LOOP

        EXEC_OUT(["execution-report.md"]):::output
        EXEC_NEXT -->|"全タスク完了"| EXEC_OUT
    end

    %% === /create-issues-from-meeting ===
    subgraph ISS ["/create-issues-from-meeting"]
        direction TB
        ISS_IN(("議事録ファイルパス")):::entryPoint
        ISS_EXTRACT["アクションアイテム抽出"]:::autoStep
        ISS_PREVIEW["プレビューテーブル表示"]:::autoStep

        ISS_CONFIRM{"起票確認"}:::userChoice
        ISS_C1["全件起票する"]:::autoStep
        ISS_C2["選択して起票する"]:::autoStep
        ISS_C3["キャンセル"]:::autoStep

        ISS_IN --> ISS_EXTRACT --> ISS_PREVIEW --> ISS_CONFIRM
        ISS_CONFIRM --> ISS_C1
        ISS_CONFIRM --> ISS_C2
        ISS_CONFIRM --> ISS_C3

        ISS_SELECT{"各アイテム"}:::userChoice
        ISS_C2 --> ISS_SELECT
        ISS_S1["起票する"]:::autoStep
        ISS_S2["スキップする"]:::autoStep
        ISS_SELECT --> ISS_S1
        ISS_SELECT --> ISS_S2

        ISS_CREATE["gh issue create 実行"]:::autoStep
        ISS_C1 --> ISS_CREATE
        ISS_S1 --> ISS_CREATE

        ISS_OUT(["GitHub Issues 作成完了"]):::output
        ISS_CREATE --> ISS_OUT
        ISS_C3 --> ISS_CANCEL(["キャンセル"]):::output
    end

    %% === /sync-design-system ===
    subgraph SYNC ["/sync-design-system"]
        direction TB
        SYNC_IN(("Figma URL（任意）")):::entryPoint
        SYNC_HAS_URL{"URL あり？"}:::userChoice

        SYNC_IN --> SYNC_HAS_URL
        SYNC_HAS_URL -->|"あり"| SYNC_EXTRACT
        SYNC_HAS_URL -->|"なし"| SYNC_RULES

        SYNC_EXTRACT["Figma トークン抽出"]:::autoStep
        SYNC_DIFF["Figma ↔ ローカル差分検出"]:::autoStep
        SYNC_REPORT(["sync-report.md"]):::output
        SYNC_EXTRACT --> SYNC_DIFF --> SYNC_REPORT

        SYNC_APPROVE{"差分承認"}:::userChoice
        SYNC_REPORT --> SYNC_APPROVE
        SYNC_AP1["承認 → design-system.md 更新"]:::autoStep
        SYNC_AP2["却下"]:::autoStep
        SYNC_APPROVE --> SYNC_AP1
        SYNC_APPROVE --> SYNC_AP2

        SYNC_RULES["デザインシステムルール生成"]:::autoStep
        SYNC_AP1 --> SYNC_RULES

        SYNC_OUT(["design-system-rules.md"]):::output
        SYNC_RULES --> SYNC_OUT
    end
```

---

## コマンド網羅チェック

| # | コマンド | ダイアグラム |
|---|---------|------------|
| 1 | `/briefing` | F |
| 2 | `/run-pipeline` | B |
| 3 | `/extract-requirements` | C |
| 4 | `/define-requirements` | C |
| 5 | `/generate-screens` | B + C |
| 6 | `/generate-diagrams` | C |
| 7 | `/wireframe` | C |
| 8 | `/design` | C |
| 9 | `/estimating` | B + C |
| 10 | `/create-estimate-doc` | C |
| 11 | `/work-on-issue` | D |
| 12 | `/parallel-work` | D |
| 13 | `/creating-pr` | D |
| 14 | `/reviewing` | E |
| 15 | `/checking-ready` | E |
| 16 | `/generating-spec` | F |
| 17 | `/executing-plan` | F |
| 18 | `/create-issues-from-meeting` | F |
| 19 | `/sync-design-system` | F |
