# pat_event

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@pat_event`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| 項目実績情報 |  |  |
| [{ |  |  |
|  |  | 下記設定項目実績JSONの配列 |
| }..] |  |  |
| 設定項目実績 | テキスト |  |
| { |  |  |
| format_class | Number | 0: テキスト |
| result_value | String | 入力値 |
| } |  |  |
| 設定項目実績 | テキストエリア |  |
| { |  |  |
| format_class | Number | 1: テキストエリア |
| result_value | String | 入力値<br>書式指定なし時はプレーンテキスト、書式指定ありではHTML |
| } |  |  |
| 設定項目実績 | 画像 |  |
| { |  |  |
| format_class | Number | 2: 画像 |
| result_value | JSON配列 | 画像情報配列 |
| } |  |  |
|  | result_value |  |
| [{ |  |  |
| name | String | 画像名<br>(サブカテゴリがVAの場合はVA名) |
| file_name | String | 画像ファイル名 |
| file_path | String | 画像ファイルパス<br>※S3のパス |
| is_send_va | String | VA転送対象フラグ["0"：非対象/"1"：対象]<br>※サブカテゴリがVAの場合のみ編集可能 |
| }...] |  |  |
| 設定項目実績 | リスト項目 |  |
| { |  |  |
| format_class | Number | 3: リスト選択 |
| result_value | JSON | 下記 |
| } |  |  |
|  | result_value |  |
| { |  |  |
| name | String | リスト名 |
| score | Number | スコア |
| } |  |  |
| 設定項目実績 | ラジオボタン |  |
| { |  |  |
| format_class | Number | 4:ラジオボタン |
| result_value | JSON | 下記 |
| } |  |  |
|  | result_value |  |
| { |  |  |
| name | String | 項目名 |
| score | Number | スコア |
| } |  |  |
| 設定項目実績 | 日付 |  |
| { |  |  |
| format_class | Number | 5:日付 |
| result_value | String | 日付文字列(日付フォーマット：'YYYY-MM-DD'、空欄の場合：null) |
| } |  |  |
| 設定項目実績 | チェックボックス |  |
| { |  |  |
| format_class | Number | 6:チェックボックス |
| result_value | JSON配列 | 下記 |
| } |  |  |
|  | result_value |  |
| [{ |  |  |
| name | String | 項目名 |
| score | Number | スコア |
| }...] |  |  |
| 設定項目実績 | 添付ファイル |  |
| { |  |  |
| format_class | Number | 7:添付ファイル |
| result_value | JSON | 下記 |
| } |  |  |
|  | result_value |  |
| { |  |  |
| file_name | String | 添付ファイル名 |
| file_path | String | 添付ファイルパス<br>※S3のバケット？ |
| } |  |  |
| 設定項目実績 | スコア計算 |  |
| { |  |  |
| format_class | Number | 8:スコア計算 |
| result_value | JSON | 下記 |
| } |  |  |
|  | result_value |  |
| { |  |  |
| score | Number | 計算結果 |
| unit | String | 単位 |
| } |  |  |
| 設定項目実績 | 治療実績リンク |  |
| { |  |  |
| format_class | Number | 9:治療実績リンク |
| result_value | null | 特になし（ord_noはテーブルのカラムに保存） |
| } |  |  |
| 設定項目実績 | 掲示板リンク |  |
| { |  |  |
| format_class | Number | 10:掲示板リンク |
| result_value | JSON | 下記（bbs_ctl_noはテーブルのカラムに保存） |
| } |  |  |
|  | result_value |  |
| { |  |  |
| notice_start_date | String | 掲載開始日時 |
| notice_end_date | String | 掲載終了日時 |
| staff_info | JSON | 下記 |
| } |  |  |
|  | staff_info |  |
| { |  |  |
| target | String | 対象（'0':個別、'1':全指定）, |
| staff_cd | Number[] | スタッフコードの配列 |
| } |  |  |
| reg_staff_info |  |  |
| 起票者情報 |  |  |
| { |  |  |
| reg_staff_cd | Number | 起票者コード<br>mst_user.user_id |
| reg_staff_name | String | mst_personal_user<br>※起票者名<br>※暗号化対象 |
| } |  |  |
| up_staff_info |  |  |
| 編集者情報 |  |  |
| { |  |  |
| up_staff_cd | Number | スタッフマスタ.スタッフコード　<br>※編集者コード |
| up_staff_name | String | スタッフマスタ.スタッフ名<br>※編集者名<br>※暗号化対象 |
| } |  |  |
