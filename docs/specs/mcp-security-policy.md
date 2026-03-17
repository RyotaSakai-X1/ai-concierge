# MCP セキュリティポリシー

## 概要

MCP ツールへのアクセスを最小権限の原則に基づいて制限する4層防御アーキテクチャ。

## 4層防御

| Layer | 仕組み | ファイル | 役割 |
|-------|--------|---------|------|
| 1 | allow/deny リスト | `.claude/settings.json` | ツール単位の許可・拒否・確認を制御 |
| 2 | スコープ検証フック | `.claude/hooks/validate-mcp-scope.sh` | リソースID（fileKey, folder_id）のホワイトリスト検証 |
| 3 | プロンプトルール | `.claude/rules/mcp-security.md` | プロンプトインジェクション防御、行動規範 |
| 4 | このドキュメント | `docs/specs/mcp-security-policy.md` | 運用方針、変更手順、インシデント対応 |

## ツール分類表

### allow（確認なしで実行）

| カテゴリ | ツール |
|---------|--------|
| Drive 読み取り | list_drive_items, get_doc_as_markdown, get_drive_file_content, get_doc_content, search_drive_files, search_docs, list_docs_in_folder, inspect_doc_structure, get_drive_file_download_url, get_drive_shareable_link, get_drive_file_permissions, check_drive_file_public_access, debug_table_structure, list_document_comments, list_spreadsheet_comments |
| Sheets コアワークフロー | read_sheet_values, get_spreadsheet_info, list_spreadsheets, create_spreadsheet, modify_sheet_values, create_sheet, format_sheet_range |
| Gmail 読み取り（GWS） | search_gmail_messages, get_gmail_message_content, get_gmail_messages_content_batch, get_gmail_thread_content, get_gmail_threads_content_batch, get_gmail_attachment_content, list_gmail_labels |
| Gmail 読み取り（Claude AI） | gmail_get_profile, gmail_read_message, gmail_read_thread, gmail_search_messages, gmail_list_labels, gmail_list_drafts |
| Calendar 読み取り | gcal_list_events, gcal_list_calendars, gcal_find_my_free_time, gcal_find_meeting_times, gcal_get_event |
| Figma 読み取り | get_screenshot, get_metadata, get_design_context, get_figjam, get_variable_defs, get_code_connect_map, get_code_connect_suggestions, whoami, generate_diagram |
| context7 | resolve-library-id, query-docs |

### ask（毎回ユーザー確認）

| カテゴリ | ツール |
|---------|--------|
| Calendar 書き込み | gcal_create_event, gcal_update_event, gcal_respond_to_event |
| Docs 書き込み | create_doc, batch_update_doc, modify_doc_text, insert_doc_elements, insert_doc_image, find_and_replace_doc, update_paragraph_style, update_doc_headers_footers, create_table_with_data, import_to_google_doc, export_doc_to_pdf, manage_document_comment, manage_spreadsheet_comment, manage_conditional_formatting |
| Drive 書き込み | create_drive_folder, create_drive_file, update_drive_file, copy_drive_file |
| Figma 書き込み | generate_figma_design, create_design_system_rules, add_code_connect_map, send_code_connect_mappings |

### deny（常にブロック）

| カテゴリ | ツール | 理由 |
|---------|--------|------|
| Gmail 送信・変更 | send_gmail_message, draft_gmail_message, manage_gmail_filter, manage_gmail_label, modify_gmail_message_labels, batch_modify_gmail_message_labels, gmail_create_draft | 誤送信リスク |
| 権限・認証 | manage_drive_access, set_drive_file_permissions, start_google_auth | 権限昇格リスク |
| Apps Script（全件） | run_script_function, create_script_project 他14件 | 任意コード実行リスク |
| Chat | send_message, search_messages 他4件 | 誤送信リスク |
| 連絡先 | manage_contact 他7件 | 個人情報操作リスク |
| タスク | manage_task 他5件 | スコープ外 |
| カレンダー削除 | gcal_delete_event, manage_event 他3件 | 破壊的操作 |
| フォーム・プレゼン・サイト | create_form 他14件 | スコープ外 |

## 変更手順

### ツール分類の変更

1. `.claude/settings.json` の allow/deny リストを編集
2. この仕様書のツール分類表を更新
3. PR で変更をレビュー

### スコープ制限の追加

1. `.claude/security/mcp-scope.json` に ID を追加
2. 空配列 → ID リストに変更するとホワイトリストモードに切替

例:
  "allowed_figma_file_keys": ["abc123", "def456"],
  "allowed_drive_folder_ids": ["1A2B3C"]

### スコープ制限の解除

対象の配列を空 `[]` に戻す。

## インシデント対応

| 状況 | 対応 |
|------|------|
| deny ツールが実行された | settings.json の deny リストを確認、フック動作を検証 |
| MCP ツール結果に不審な指示が含まれている | 実行を中止し、ユーザーに報告 |
| 予期しない外部リソースへのアクセス | スコープ設定を見直し、必要ならホワイトリストを有効化 |
