# デフォルト出力先のセットアップ

## Figma: planKey の取得方法

1. `mcp__figma__whoami` で認証済みユーザー・チーム情報を確認する
2. `generate_figma_design` を `planKey` なしで呼び出し、返却されるプラン一覧から選択する
3. 選択した `planKey` を `.env` の `FIGMA_DEFAULT_PLAN_KEY` に設定する

## Google Drive: フォルダ ID の設定

1. Google Drive で出力先フォルダを開き、URL からフォルダ ID を取得する
2. `.env` の `GDRIVE_DEFAULT_OUTPUT_FOLDER_ID` に設定する
